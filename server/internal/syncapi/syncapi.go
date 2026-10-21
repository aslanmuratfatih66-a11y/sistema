// Package syncapi — синхронизация офлайн-first (SPEC §10): push/pull записей, LWW по полю, журнал событий.
// КОНТРАКТ каркаса этапа 5; реализация — сабагент B.
package syncapi

import (
	"database/sql"
	"log/slog"
	"net/http"
)

type Handler struct {
	db     *sql.DB
	logger *slog.Logger
}

func New(db *sql.DB, logger *slog.Logger) *Handler { return &Handler{db: db, logger: logger} }

// Register — маршруты /api/v1/sync/...; require — middleware авторизации (auth.Service.Require). TODO B.
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}
