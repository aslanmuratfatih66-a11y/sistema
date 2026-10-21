// Package learning — знания (SPEC §8.9): генерация уроков и проверок по курсу. Прогресс хранит клиент
// (синхронизируется через records). КОНТРАКТ каркаса этапа 6; реализация — сабагент F. ИИ — через ai.Client.
package learning

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

// Register — /api/v1/learning/... TODO F.
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}
