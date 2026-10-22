// Package messages — сообщения ИИ наперёд (SPEC §9.5): пачка на ближайшие часы (брифинг, подбадривания,
// упрёки на пропуск каждой задачи), ntfy (выключен по умолчанию), FCM для Android.
// ИИ — через ai.Client (TaskShort). Без ИИ сообщения не генерируются — клиент работает на шаблонах.
package messages

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
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
	log  *slog.Logger
	http *http.Client

	mu       sync.Mutex
	busy     map[string]bool      // пользователь, для которого идёт генерация
	lastPull map[string]time.Time // POST /generate — не чаще раза в час

	fcmMu  sync.Mutex
	fcm    *fcmAccount
	fcmTok string
	fcmExp time.Time
}

func New(db *sql.DB, client ai.Client, opts Options) *Service {
	l := opts.Logger
	if l == nil {
		l = slog.Default()
	}
	return &Service{
		db: db, ai: client, opts: opts, log: l,
		http:     &http.Client{Timeout: 20 * time.Second},
		busy:     map[string]bool{},
		lastPull: map[string]time.Time{},
	}
}

const (
	// Окно генерации и выдачи по умолчанию.
	window = 12 * time.Hour
	// Активность за последние N дней — условие генерации в фоне.
	activeDays = 14
	// POST /generate не чаще.
	generateEvery = time.Hour
	// Хранение сообщений.
	keepFor = 7 * 24 * time.Hour
)

// Register — /api/v1/messages, /api/v1/messages/generate, /api/v1/push/register.
func (s *Service) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/messages", require(http.HandlerFunc(s.list)))
	mux.Handle("POST /api/v1/messages/generate", require(http.HandlerFunc(s.generate)))
	mux.Handle("POST /api/v1/push/register", require(http.HandlerFunc(s.registerPush)))
}

// GenerateAhead — задача планировщика: пачки сообщений наперёд для всех активных пользователей.
func (s *Service) GenerateAhead(ctx context.Context) error {
	now := time.Now()
	if _, err := s.db.ExecContext(ctx, `DELETE FROM messages WHERE deliver_at < ?`, now.Add(-keepFor).UnixMilli()); err != nil {
		return err
	}
	if s.ai == nil {
		return nil
	}
	rows, err := s.db.QueryContext(ctx,
		`SELECT user_id FROM records GROUP BY user_id HAVING MAX(updated_at) >= ?`,
		now.Add(-activeDays*24*time.Hour).UnixMilli())
	if err != nil {
		return err
	}
	var users []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			rows.Close()
			return err
		}
		users = append(users, id)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return err
	}
	for _, uid := range users {
		if ctx.Err() != nil {
			return ctx.Err()
		}
		_, err := s.generateFor(ctx, uid, now, genHints{})
		switch {
		case err == nil, errors.Is(err, ai.ErrBudget):
			// бюджет кончился у пользователя — клиент на шаблонах
		case errors.Is(err, ai.ErrUnavailable):
			return nil // ИИ не настроен — остальным тоже не сгенерировать
		default:
			s.log.Warn("messages: generate", "user", uid, "err", err)
		}
	}
	return nil
}

// ---- HTTP ----

type outMessage struct {
	ID        string  `json:"id"`
	Kind      string  `json:"kind"`
	DeliverAt int64   `json:"deliver_at"`
	QuestRef  *string `json:"quest_ref"`
	Title     string  `json:"title"`
	Body      string  `json:"body"`
	HasAudio  bool    `json:"has_audio"`
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeErr(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}

// GET /api/v1/messages?from=<ms>&hours=12 — сообщения с deliver_at в [from, from+hours); помечаются fetched_at.
func (s *Service) list(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	now := time.Now()
	from := now.UnixMilli()
	if v := r.URL.Query().Get("from"); v != "" {
		n, err := strconv.ParseInt(v, 10, 64)
		if err != nil || n < 0 {
			writeErr(w, http.StatusBadRequest, "bad from")
			return
		}
		from = n
	}
	hours := 12
	if v := r.URL.Query().Get("hours"); v != "" {
		n, err := strconv.Atoi(v)
		if err != nil || n < 1 || n > 48 {
			writeErr(w, http.StatusBadRequest, "bad hours")
			return
		}
		hours = n
	}
	to := from + int64(hours)*int64(time.Hour/time.Millisecond)
	rows, err := s.db.QueryContext(r.Context(),
		`SELECT id, kind, deliver_at, quest_ref, title, body, audio_path IS NOT NULL
		 FROM messages WHERE user_id = ? AND deliver_at >= ? AND deliver_at < ? AND kind <> 'chat'
		 ORDER BY deliver_at LIMIT 200`, uid, from, to)
	if err != nil {
		s.log.Error("messages: list", "err", err)
		writeErr(w, http.StatusInternalServerError, "internal")
		return
	}
	out := []outMessage{}
	for rows.Next() {
		var m outMessage
		var ref sql.NullString
		if err := rows.Scan(&m.ID, &m.Kind, &m.DeliverAt, &ref, &m.Title, &m.Body, &m.HasAudio); err != nil {
			rows.Close()
			writeErr(w, http.StatusInternalServerError, "internal")
			return
		}
		if ref.Valid {
			m.QuestRef = &ref.String
		}
		out = append(out, m)
	}
	rows.Close()
	fetched := now.UnixMilli()
	if len(out) > 0 {
		if _, err := s.db.ExecContext(r.Context(),
			`UPDATE messages SET fetched_at = ? WHERE user_id = ? AND deliver_at >= ? AND deliver_at < ? AND fetched_at IS NULL`,
			fetched, uid, from, to); err != nil {
			s.log.Warn("messages: mark fetched", "err", err)
		}
	}
	writeJSON(w, http.StatusOK, map[string]any{"messages": out, "fetched_at": fetched})
}

type generateReq struct {
	Lang     string `json:"lang"`      // 'ru' / 'tr' — если в профиле не задан
	TZOffset *int   `json:"tz_offset"` // минуты к UTC — если в профиле нет пояса
}

// POST /api/v1/messages/generate — сгенерировать сейчас (не чаще раза в час).
func (s *Service) generate(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	var req generateReq
	if r.ContentLength != 0 {
		_ = json.NewDecoder(http.MaxBytesReader(w, r.Body, 4096)).Decode(&req)
	}
	now := time.Now()
	s.mu.Lock()
	last, ok := s.lastPull[uid]
	recent := ok && now.Sub(last) < generateEvery
	if !recent {
		s.lastPull[uid] = now
	}
	s.mu.Unlock()
	if recent {
		writeJSON(w, http.StatusOK, map[string]any{"generated": 0, "skipped": "recent"})
		return
	}
	if s.ai == nil {
		writeErr(w, http.StatusServiceUnavailable, "ai_unavailable")
		return
	}
	n, err := s.generateFor(r.Context(), uid, now, genHints{lang: req.Lang, tzOffset: req.TZOffset})
	switch {
	case err == nil:
		writeJSON(w, http.StatusOK, map[string]any{"generated": n})
	case errors.Is(err, ai.ErrBudget):
		writeErr(w, http.StatusPaymentRequired, "ai_budget")
	case errors.Is(err, ai.ErrUnavailable):
		writeErr(w, http.StatusServiceUnavailable, "ai_unavailable")
	default:
		s.log.Warn("messages: generate", "user", uid, "err", err)
		// Не считаем попытку: клиент может повторить позже.
		s.mu.Lock()
		delete(s.lastPull, uid)
		s.mu.Unlock()
		writeErr(w, http.StatusBadGateway, "ai_failed")
	}
}

type pushReq struct {
	Platform string `json:"platform"`
	Token    string `json:"token"`
}

// POST /api/v1/push/register {platform, token}.
func (s *Service) registerPush(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	var req pushReq
	if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, 8192)).Decode(&req); err != nil {
		writeErr(w, http.StatusBadRequest, "bad json")
		return
	}
	switch req.Platform {
	case "android", "ios", "ntfy":
	default:
		writeErr(w, http.StatusBadRequest, "bad platform")
		return
	}
	if req.Token == "" || len(req.Token) > 4096 {
		writeErr(w, http.StatusBadRequest, "bad token")
		return
	}
	if _, err := s.db.ExecContext(r.Context(),
		`INSERT INTO push_tokens (user_id, platform, token, updated_at) VALUES (?, ?, ?, ?)
		 ON CONFLICT (user_id, platform, token) DO UPDATE SET updated_at = excluded.updated_at`,
		uid, req.Platform, req.Token, time.Now().UnixMilli()); err != nil {
		s.log.Error("messages: push register", "err", err)
		writeErr(w, http.StatusInternalServerError, "internal")
		return
	}
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func newID() string {
	var b [16]byte
	_, _ = rand.Read(b[:])
	return hex.EncodeToString(b[:])
}
