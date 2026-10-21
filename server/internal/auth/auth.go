// Package auth — вход (имя + пароль argon2id + TOTP), токены, сброс по TOTP, ограничение частоты (SPEC §10).
// КОНТРАКТ каркаса этапа 5; реализация — сабагент A.
package auth

import (
	"database/sql"
	"log/slog"
	"net/http"
	"time"
)

// Options — зависимости сервиса.
type Options struct {
	Logger     *slog.Logger
	TrustProxy bool // IP клиента из X-Forwarded-For (для лимитов)
	Now        func() time.Time
}

// Service — регистрация, вход, токены.
type Service struct {
	db   *sql.DB
	opts Options
}

func New(db *sql.DB, opts Options) *Service {
	if opts.Now == nil {
		opts.Now = time.Now
	}
	if opts.Logger == nil {
		opts.Logger = slog.Default()
	}
	return &Service{db: db, opts: opts}
}

// Register — маршруты /api/v1/auth/... (TODO A).
func (s *Service) Register(mux *http.ServeMux) {}

// Require — middleware: Authorization: Bearer <access>, кладёт id пользователя в context (authctx.WithUser);
// иначе 401 (TODO A).
func (s *Service) Require(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
	})
}
