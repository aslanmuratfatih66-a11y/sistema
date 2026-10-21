// Package media — загрузка фото (WebP ~1600px + миниатюра), отдача только владельцу (SPEC §10).
// КОНТРАКТ каркаса этапа 5; реализация — сабагент C. Маршруты — под httpapi.UploadPathPrefix (/api/v1/photos).
package media

import (
	"database/sql"
	"log/slog"
	"net/http"
)

type Options struct {
	PhotosDir string // <data>/photos
	MaxBytes  int64
	Logger    *slog.Logger
}

type Handler struct {
	db   *sql.DB
	opts Options
}

func New(db *sql.DB, opts Options) *Handler { return &Handler{db: db, opts: opts} }

// Register — маршруты /api/v1/photos...; TODO C.
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}
