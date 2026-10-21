// Package messages — сообщения ИИ наперёд (SPEC §9.5): пачка на ближайшие часы (брифинг, подбадривания,
// упрёки на пропуск каждой задачи), ntfy (выключен по умолчанию), FCM для Android.
// КОНТРАКТ каркаса этапа 6; реализация — сабагент E. ИИ — через ai.Client.
package messages

import (
	"context"
	"database/sql"
	"log/slog"
	"net/http"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
)

type Options struct {
	NtfyURL    string // SISTEMA_NTFY_URL; пусто — ntfy выключен
	NtfyToken  string
	FCMKeyFile string // SISTEMA_FCM_KEY_FILE — JSON сервисного аккаунта Firebase; пусто — FCM выключен
	Logger     *slog.Logger
}

type Service struct {
	db   *sql.DB
	ai   ai.Client
	opts Options
}

func New(db *sql.DB, client ai.Client, opts Options) *Service {
	return &Service{db: db, ai: client, opts: opts}
}

// Register — /api/v1/messages/... TODO E.
func (s *Service) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}

// GenerateAhead — задача планировщика: пачки сообщений наперёд для всех активных пользователей. TODO E.
func (s *Service) GenerateAhead(ctx context.Context) error { return nil }
