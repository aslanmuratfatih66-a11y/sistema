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
}
