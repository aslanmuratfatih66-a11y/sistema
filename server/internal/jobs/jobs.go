// Package jobs — планировщик внутри процесса (SPEC §10): бэкапы, курсы валют, очистка.
// КОНТРАКТ каркаса этапа 5; реализация — сабагент C. Генерация сообщений и недельный анализ — этап 6 (заглушки).
package jobs

import (
	"context"
	"database/sql"
	"log/slog"
)

type Options struct {
	DataDir        string
	BackupDir      string
	BackupKeepDays int
	FXURL          string
	Logger         *slog.Logger
}

type Scheduler struct {
	db   *sql.DB
	opts Options
}

func New(db *sql.DB, opts Options) *Scheduler { return &Scheduler{db: db, opts: opts} }

// Run — до отмены ctx (TODO C).
func (s *Scheduler) Run(ctx context.Context) { <-ctx.Done() }
