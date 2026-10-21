// Package httpapi — HTTP-роутер сервера (net/http, паттерны Go 1.22+) и middleware.
package httpapi

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/memstat"
)

// Options — зависимости роутера.
type Options struct {
	Logger       *slog.Logger
	Version      string
	StartedAt    time.Time
	MaxBodyBytes int64
	// Mount регистрирует маршруты модулей (auth, sync, media) в mux /api/v1/... (собирает main).
	Mount func(api *http.ServeMux)
	// now — для тестов; nil = time.Now.
	now func() time.Time
}

// UploadPathPrefix — маршруты загрузки фото: общий лимит тела к ним не применяется.
const UploadPathPrefix = "/api/v1/photos"

// New собирает http.Handler со всеми маршрутами и middleware.
func New(opts Options) http.Handler {
	if opts.Logger == nil {
		opts.Logger = slog.Default()
	}
	if opts.now == nil {
		opts.now = time.Now
	}
	if opts.StartedAt.IsZero() {
		opts.StartedAt = opts.now()
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", healthz(opts))

	// /api/v1 — версия API (SPEC §10). Этап 5: auth, sync, photos — регистрировать здесь.
	api := http.NewServeMux()
	api.HandleFunc("GET /api/v1/ping", ping)
	if opts.Mount != nil {
		opts.Mount(api)
	}
	mux.Handle("/api/v1/", api)

	var h http.Handler = mux
	h = limitBody(h, opts.MaxBodyBytes)
	h = logRequests(h, opts.Logger)
	h = recoverer(h, opts.Logger)
	h = requestID(h)
	return h
}

type healthResponse struct {
	Status     string  `json:"status"`
	Version    string  `json:"version"`
	UptimeS    int64   `json:"uptime_s"`
	MemAllocMB float64 `json:"mem_alloc_mb"`
}

func healthz(opts Options) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, healthResponse{
			Status:     "ok",
			Version:    opts.Version,
			UptimeS:    int64(opts.now().Sub(opts.StartedAt).Seconds()),
			MemAllocMB: memstat.Read().AllocMB,
		})
	}
}

func ping(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"pong": "ok"})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

// writeError — единый формат ошибки API: {"error":"..."}.
func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
