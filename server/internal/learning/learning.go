// Package learning — знания (SPEC §8.9): генерация плана курса и уроков с проверкой. Прогресс хранит клиент
// (синхронизируется через records). ИИ — через ai.Client (TaskLearning, Haiku); уроки кэшируются в ai_cache.
package learning

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

const (
	maxBody       = 16 << 10
	maxTopicRunes = 200
	maxTextRunes  = 300
	minLessons    = 5
	maxLessons    = 30
	defLessons    = 10
	cacheKind     = "lesson"
	aiTimeout     = 90 * time.Second
)

type Handler struct {
	db     *sql.DB
	ai     ai.Client
	logger *slog.Logger
}

func New(db *sql.DB, client ai.Client, logger *slog.Logger) *Handler {
	return &Handler{db: db, ai: client, logger: logger}
}

// Register — /api/v1/learning/outline и /api/v1/learning/lesson.
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	mux.Handle("POST /api/v1/learning/outline", require(http.HandlerFunc(h.outline)))
	mux.Handle("POST /api/v1/learning/lesson", require(http.HandlerFunc(h.lesson)))
}

// ---- outline ----

type outlineReq struct {
	Topic   string `json:"topic"`
	Lang    string `json:"lang"`
	Level   string `json:"level"`
	Lessons int    `json:"lessons"`
}

type outlineLesson struct {
	Index int    `json:"index"`
	Title string `json:"title"`
	Goal  string `json:"goal"`
}

type outlineResp struct {
	Title   string          `json:"title"`
	Lessons []outlineLesson `json:"lessons"`
}

func (h *Handler) outline(w http.ResponseWriter, r *http.Request) {
	var req outlineReq
	if !decode(w, r, &req) {
		return
	}
	req.Topic = clip(req.Topic, maxTopicRunes)
	req.Level = clip(req.Level, 60)
	if req.Topic == "" {
		writeError(w, http.StatusBadRequest, "topic_required")
		return
	}
	lang := normLang(req.Lang)
	n := req.Lessons
	if n == 0 {
		n = defLessons
	}
	n = min(max(n, minLessons), maxLessons)

	level := req.Level
	if level == "" {
		level = "beginner"
	}
	user := fmt.Sprintf("Topic: %s\nLevel: %s\nNumber of lessons: %d\nLanguage: %s", req.Topic, level, n, langName(lang))
	sys := `You design short daily self-study courses on any topic (from nunchaku to C++).
Return ONLY a JSON object: {"title": string, "lessons": [{"index": int, "title": string, "goal": string}]}.
Rules: exactly the requested number of lessons, index from 0, ordered from basics to practice; each lesson fits 10–15 minutes;
title ≤ 60 chars, goal — one sentence about what the learner will be able to do. Write all text in the requested language.
For physical skills include safety notes in goals where relevant.`

	var out outlineResp
	if !h.ask(w, r, sys, user, 2000, &out) {
		return
	}
	lessons := make([]outlineLesson, 0, len(out.Lessons))
	for _, l := range out.Lessons {
		t := clip(l.Title, 120)
		if t == "" {
			continue
		}
		lessons = append(lessons, outlineLesson{Index: len(lessons), Title: t, Goal: clip(l.Goal, maxTextRunes)})
		if len(lessons) == maxLessons {
			break
		}
	}
	if len(lessons) == 0 {
		writeError(w, http.StatusBadGateway, "ai_bad_response")
		return
	}
	title := clip(out.Title, 120)
	if title == "" {
		title = req.Topic
	}
	writeJSON(w, http.StatusOK, outlineResp{Title: title, Lessons: lessons})
}

// ---- lesson ----

type lessonReq struct {
	Topic string `json:"topic"`
	Title string `json:"title"`
	Goal  string `json:"goal"`
	Lang  string `json:"lang"`
	Index int    `json:"index"`
}

type block struct {
	Type string `json:"type"`
	Text string `json:"text"`
}

type question struct {
	Q       string   `json:"q"`
	Options []string `json:"options"`
	Answer  int      `json:"answer"`
	Explain string   `json:"explain"`
}

type lessonResp struct {
	Title   string     `json:"title"`
	Content []block    `json:"content"`
	Quiz    []question `json:"quiz"`
}

func (h *Handler) lesson(w http.ResponseWriter, r *http.Request) {
	var req lessonReq
	if !decode(w, r, &req) {
		return
	}
	req.Topic = clip(req.Topic, maxTopicRunes)
	req.Title = clip(req.Title, 120)
	req.Goal = clip(req.Goal, maxTextRunes)
	if req.Topic == "" || req.Title == "" || req.Index < 0 {
		writeError(w, http.StatusBadRequest, "bad_request")
		return
	}
	lang := normLang(req.Lang)
	key := strings.Join([]string{norm(req.Topic), lang, fmt.Sprint(req.Index), norm(req.Title)}, "|")

	if cached, ok := h.cacheGet(r.Context(), key); ok {
		writeJSON(w, http.StatusOK, cached)
		return
	}

	user := fmt.Sprintf("Course topic: %s\nLesson #%d: %s\nLesson goal: %s\nLanguage: %s",
		req.Topic, req.Index+1, req.Title, req.Goal, langName(lang))
	sys := `You write one short daily lesson (10–15 minutes) of a self-study course.
Return ONLY a JSON object:
{"title": string, "content": [{"type": "p"|"example"|"tip", "text": string}], "quiz": [{"q": string, "options": [string], "answer": int, "explain": string}]}.
Rules: 4–10 content blocks: "p" — explanation paragraph, "example" — concrete example or exercise (code as plain text allowed),
"tip" — practical advice or safety note. Quiz: 3–5 questions, 3–4 options each, "answer" — zero-based index of the correct option,
"explain" — one sentence why. Facts must be accurate; if unsure, keep it general. Write all text in the requested language.`

	var out lessonResp
	if !h.ask(w, r, sys, user, 3000, &out) {
		return
	}
	res := sanitizeLesson(out, req.Title)
	if len(res.Content) == 0 {
		writeError(w, http.StatusBadGateway, "ai_bad_response")
		return
	}
	h.cachePut(r.Context(), key, res)
	writeJSON(w, http.StatusOK, res)
}

func sanitizeLesson(in lessonResp, fallbackTitle string) lessonResp {
	out := lessonResp{Title: clip(in.Title, 120), Content: []block{}, Quiz: []question{}}
	if out.Title == "" {
		out.Title = fallbackTitle
	}
	for _, b := range in.Content {
		t := strings.TrimSpace(b.Text)
		if t == "" {
			continue
		}
		switch b.Type {
		case "p", "example", "tip":
		default:
			b.Type = "p"
		}
		out.Content = append(out.Content, block{Type: b.Type, Text: t})
	}
	for _, q := range in.Quiz {
		qq := strings.TrimSpace(q.Q)
		opts := make([]string, 0, len(q.Options))
		for _, o := range q.Options {
			if o = strings.TrimSpace(o); o != "" {
				opts = append(opts, o)
			}
		}
		if qq == "" || len(opts) < 2 || q.Answer < 0 || q.Answer >= len(opts) {
			continue
		}
		out.Quiz = append(out.Quiz, question{Q: qq, Options: opts, Answer: q.Answer, Explain: strings.TrimSpace(q.Explain)})
	}
	return out
}

// ---- ИИ ----

// ask вызывает модель и разбирает JSON-ответ в v. false — ответ клиенту уже записан.
func (h *Handler) ask(w http.ResponseWriter, r *http.Request, sys, user string, maxTokens int, v any) bool {
	ctx, cancel := context.WithTimeout(r.Context(), aiTimeout)
	defer cancel()
	resp, err := h.ai.Do(ctx, authctx.UserID(r.Context()), ai.TaskLearning, ai.Request{
		System:    []ai.SystemBlock{{Text: sys, Cache: true}},
		Messages:  []ai.Message{{Role: ai.RoleUser, Parts: []ai.Part{{Text: user}}}},
		MaxTokens: maxTokens,
		JSON:      true,
	})
	switch {
	case errors.Is(err, ai.ErrBudget):
		writeError(w, http.StatusPaymentRequired, "ai_budget")
		return false
	case errors.Is(err, ai.ErrUnavailable):
		writeError(w, http.StatusServiceUnavailable, "ai_unavailable")
		return false
	case err != nil:
		h.logger.Warn("learning: ai", "err", err)
		writeError(w, http.StatusBadGateway, "ai_error")
		return false
	}
	if err := json.Unmarshal([]byte(extractJSON(resp.Text)), v); err != nil {
		h.logger.Warn("learning: bad ai json", "err", err, "stop", resp.StopReason)
		writeError(w, http.StatusBadGateway, "ai_bad_response")
		return false
	}
	return true
}

// extractJSON — объект из ответа (модель может обернуть его в ```json … ```).
func extractJSON(s string) string {
	i, j := strings.IndexByte(s, '{'), strings.LastIndexByte(s, '}')
	if i < 0 || j < i {
		return s
	}
	return s[i : j+1]
}

// ---- кэш ----

func (h *Handler) cacheGet(ctx context.Context, key string) (lessonResp, bool) {
	var raw string
	err := h.db.QueryRowContext(ctx, `SELECT value FROM ai_cache WHERE kind = ? AND key = ?`, cacheKind, key).Scan(&raw)
	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) {
			h.logger.Warn("learning: cache get", "err", err)
		}
		return lessonResp{}, false
	}
	var v lessonResp
	if json.Unmarshal([]byte(raw), &v) != nil || len(v.Content) == 0 {
		return lessonResp{}, false
	}
	return v, true
}

func (h *Handler) cachePut(ctx context.Context, key string, v lessonResp) {
	b, err := json.Marshal(v)
	if err != nil {
		return
	}
	if _, err := h.db.ExecContext(ctx,
		`INSERT INTO ai_cache(kind, key, value, source, at) VALUES(?, ?, ?, 'ai', ?)
		 ON CONFLICT(kind, key) DO UPDATE SET value = excluded.value, at = excluded.at`,
		cacheKind, key, string(b), time.Now().UnixMilli()); err != nil {
		h.logger.Warn("learning: cache put", "err", err)
	}
}

// ---- утилиты ----

func decode(w http.ResponseWriter, r *http.Request, v any) bool {
	r.Body = http.MaxBytesReader(w, r.Body, maxBody)
	if err := json.NewDecoder(r.Body).Decode(v); err != nil {
		writeError(w, http.StatusBadRequest, "bad_json")
		return false
	}
	return true
}

func normLang(l string) string {
	if strings.EqualFold(strings.TrimSpace(l), "tr") {
		return "tr"
	}
	return "ru"
}

func langName(l string) string {
	if l == "tr" {
		return "Turkish"
	}
	return "Russian"
}

func norm(s string) string { return strings.Join(strings.Fields(strings.ToLower(s)), " ") }

func clip(s string, n int) string {
	s = strings.TrimSpace(s)
	if utf8.RuneCountInString(s) <= n {
		return s
	}
	return strings.TrimSpace(string([]rune(s)[:n]))
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
