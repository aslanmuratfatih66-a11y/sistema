// Package store открывает SQLite сервера (modernc.org/sqlite, без CGO) и применяет миграции.
// Схема БД — общий файл: правит только главный агент.
package store

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"path/filepath"

	_ "modernc.org/sqlite"
)

// DBFile — имя файла БД в каталоге данных.
const DBFile = "sistema.db"

// Open открывает (создаёт) БД в dataDir, включает WAL и внешние ключи, применяет миграции.
func Open(ctx context.Context, dataDir string) (*sql.DB, error) {
	if err := os.MkdirAll(dataDir, 0o750); err != nil {
		return nil, fmt.Errorf("data dir: %w", err)
	}
	dsn := "file:" + filepath.ToSlash(filepath.Join(dataDir, DBFile)) +
		"?_pragma=journal_mode(WAL)&_pragma=foreign_keys(1)&_pragma=busy_timeout(5000)&_pragma=synchronous(NORMAL)"
	db, err := sql.Open("sqlite", dsn)
	if err != nil {
		return nil, err
	}
	if err := Migrate(ctx, db); err != nil {
		db.Close()
		return nil, err
	}
	return db, nil
}

// OpenMemory — БД в памяти (тесты). Одно соединение, чтобы все запросы видели одну БД.
func OpenMemory(ctx context.Context) (*sql.DB, error) {
	db, err := sql.Open("sqlite", "file::memory:?_pragma=foreign_keys(1)")
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(1)
	if err := Migrate(ctx, db); err != nil {
		db.Close()
		return nil, err
	}
	return db, nil
}

// Migrate применяет миграции по PRAGMA user_version.
func Migrate(ctx context.Context, db *sql.DB) error {
	var v int
	if err := db.QueryRowContext(ctx, "PRAGMA user_version").Scan(&v); err != nil {
		return err
	}
	for i := v; i < len(migrations); i++ {
		tx, err := db.BeginTx(ctx, nil)
		if err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx, migrations[i]); err != nil {
			tx.Rollback()
			return fmt.Errorf("migration %d: %w", i+1, err)
		}
		if _, err := tx.ExecContext(ctx, fmt.Sprintf("PRAGMA user_version = %d", i+1)); err != nil {
			tx.Rollback()
			return err
		}
		if err := tx.Commit(); err != nil {
			return err
		}
	}
	return nil
}

// Время везде — миллисекунды Unix (INTEGER), UTC.
var migrations = []string{
	// 1 — этап 5: пользователи, сессии, синхронизация, фото, курсы валют, состояние задач.
	`
CREATE TABLE users (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL UNIQUE COLLATE NOCASE,
  pass_hash    TEXT NOT NULL,            -- argon2id, формат PHC ($argon2id$v=19$m=…,t=…,p=…$salt$hash)
  totp_secret  TEXT,                     -- base32; NULL — TOTP не настроен
  totp_enabled INTEGER NOT NULL DEFAULT 0,
  created_at   INTEGER NOT NULL
);

CREATE TABLE sessions (
  id           TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_hash TEXT NOT NULL UNIQUE,     -- SHA-256 refresh-токена (сам токен не храним)
  device_id    TEXT NOT NULL DEFAULT '',
  created_at   INTEGER NOT NULL,
  expires_at   INTEGER NOT NULL,
  revoked_at   INTEGER
);
CREATE INDEX sessions_user ON sessions(user_id);

-- Access-токены короткие, тоже хранятся хэшем (без подписи/секрета).
CREATE TABLE access_tokens (
  token_hash  TEXT PRIMARY KEY,
  session_id  TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  user_id     TEXT NOT NULL,
  expires_at  INTEGER NOT NULL
);

-- Синхронизация: любая клиентская таблица как JSON-документ (SPEC §10).
-- field_ts — {поле: updated_at_ms} для last-write-wins по полю.
CREATE TABLE records (
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tbl        TEXT NOT NULL,              -- имя таблицы клиента (snake_case, как в Drift)
  id         TEXT NOT NULL,
  data       TEXT NOT NULL,              -- JSON полей записи
  field_ts   TEXT NOT NULL DEFAULT '{}',
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  device_id  TEXT NOT NULL DEFAULT '',
  version    INTEGER NOT NULL DEFAULT 1,
  seq        INTEGER NOT NULL,           -- монотонный номер изменения у пользователя (курсор pull)
  PRIMARY KEY (user_id, tbl, id)
);
CREATE INDEX records_seq ON records(user_id, seq);

-- Счётчик seq на пользователя.
CREATE TABLE sync_cursors (
  user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  seq     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE photos (
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  id         TEXT NOT NULL,              -- id записи Photos клиента
  path       TEXT NOT NULL,              -- относительно <data>/photos
  thumb_path TEXT NOT NULL,
  width      INTEGER NOT NULL,
  height     INTEGER NOT NULL,
  bytes      INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  deleted_at INTEGER,
  PRIMARY KEY (user_id, id)
);

CREATE TABLE fx_rates (
  base       TEXT NOT NULL,
  quote      TEXT NOT NULL,
  rate       REAL NOT NULL,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (base, quote)
);

CREATE TABLE job_runs (
  name       TEXT PRIMARY KEY,
  last_run   INTEGER NOT NULL,
  last_error TEXT
);
`,
	// 2 — этап 6: ИИ (расходы, журнал действий, кэш), сообщения наперёд, push-токены.
	`
CREATE TABLE ai_usage (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id       TEXT,                    -- NULL — системные задачи
  task          TEXT NOT NULL,
  provider      TEXT NOT NULL,
  model         TEXT NOT NULL,
  input_tokens  INTEGER NOT NULL,
  output_tokens INTEGER NOT NULL,
  cache_read    INTEGER NOT NULL DEFAULT 0,
  cache_write   INTEGER NOT NULL DEFAULT 0,
  cost_usd      REAL NOT NULL,
  at            INTEGER NOT NULL
);
CREATE INDEX ai_usage_at ON ai_usage(at);
CREATE INDEX ai_usage_user ON ai_usage(user_id, at);

-- Журнал действий ИИ через инструменты («Система изменила план: …»), с отменой.
CREATE TABLE ai_actions (
  id         TEXT PRIMARY KEY,
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tool       TEXT NOT NULL,
  input      TEXT NOT NULL,              -- JSON аргументов
  summary    TEXT NOT NULL,
  undo       TEXT,                       -- JSON для отмены; NULL — отмена невозможна
  at         INTEGER NOT NULL,
  undone_at  INTEGER
);
CREATE INDEX ai_actions_user ON ai_actions(user_id, at);

-- Кэш ответов (КБЖУ блюд/товаров из веб-поиска, уроки и т.п.).
CREATE TABLE ai_cache (
  kind       TEXT NOT NULL,              -- 'food', 'lesson', …
  key        TEXT NOT NULL,              -- нормализованный ключ запроса
  value      TEXT NOT NULL,              -- JSON
  source     TEXT,                       -- URL/название источника
  at         INTEGER NOT NULL,
  PRIMARY KEY (kind, key)
);

-- Сообщения наперёд (SPEC §9.5): клиент забирает пачку и ставит локальными уведомлениями.
CREATE TABLE messages (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind        TEXT NOT NULL,             -- briefing | cheer | reproach | reminder | chat
  deliver_at  INTEGER NOT NULL,
  quest_ref   TEXT,                      -- id экземпляра квеста (упрёк за пропуск — дедлайн+15 мин)
  title       TEXT NOT NULL DEFAULT '',
  body        TEXT NOT NULL,
  audio_path  TEXT,                      -- озвучка (относительно <data>/audio), если есть
  created_at  INTEGER NOT NULL,
  fetched_at  INTEGER,
  pushed_at   INTEGER                    -- отправлено через FCM/ntfy
);
CREATE INDEX messages_user ON messages(user_id, deliver_at);

CREATE TABLE push_tokens (
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform   TEXT NOT NULL,              -- android | ios | ntfy
  token      TEXT NOT NULL,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (user_id, platform, token)
);
`,
}
