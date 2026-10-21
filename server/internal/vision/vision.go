// Package vision — анализ фото (SPEC §5, §9.4): тело, кожа, еда («купил/приготовил», веб-поиск КБЖУ с кэшем), чеки.
// Всё — с пометкой «оценка». КОНТРАКТ каркаса этапа 6; реализация — сабагент B. ИИ — через ai.Client.
package vision

import (
	"database/sql"
	"log/slog"
	"net/http"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
)

type Handler struct {
	db     *sql.DB
	ai     ai.Client
	logger *slog.Logger
}

func New(db *sql.DB, client ai.Client, logger *slog.Logger) *Handler {
	return &Handler{db: db, ai: client, logger: logger}
}

// Register — маршруты /api/v1/vision/... (лимит тела — общий 4 МБ: клиент шлёт JPEG ≤1600px). TODO B.
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}
