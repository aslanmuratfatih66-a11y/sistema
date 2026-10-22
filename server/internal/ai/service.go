package ai

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"strconv"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

// Options — ключи и настройки из конфига (только сервер, SPEC §9.1).
type Options struct {
	AnthropicKey string
	GeminiKey    string
	// Models — переопределения «задача=модель» через запятую (SISTEMA_AI_MODELS), напр. "chat=claude-sonnet-5-5".
	Models string
	// MonthlyBudgetUSD — месячный лимит (SISTEMA_AI_BUDGET_USD, по умолчанию 30).
	MonthlyBudgetUSD float64
	// TTSKey — ключ TTS-провайдера с готовыми голосами (ElevenLabs, SISTEMA_TTS_API_KEY); пусто — только системный TTS.
	TTSKey string
	Logger *slog.Logger
}

// Service — реализация Client + HTTP API ИИ: провайдеры, бюджет, журнал действий, инструменты, чат, план, TTS.
type Service struct {
	db        *sql.DB
	opts      Options
	tools     map[string]ToolHandler
	models    map[Task]string
	anthropic *Anthropic
	gemini    *Gemini
	tts       *elevenLabs
}

func New(db *sql.DB, opts Options) *Service {
	if opts.Logger == nil {
		opts.Logger = slog.Default()
	}
	if opts.MonthlyBudgetUSD <= 0 {
		opts.MonthlyBudgetUSD = 30
	}
	s := &Service{db: db, opts: opts, tools: map[string]ToolHandler{}, models: parseModels(opts.Models)}
	if opts.AnthropicKey != "" {
		s.anthropic = NewAnthropic(opts.AnthropicKey)
	}
	if opts.GeminiKey != "" {
		s.gemini = NewGemini(opts.GeminiKey)
	}
	if opts.TTSKey != "" {
		s.tts = newElevenLabs(opts.TTSKey)
	}
	for _, h := range builtinTools(db) {
		s.RegisterTool(h)
	}
	return s
}

// RegisterTool — добавить инструмент (вызывать до Register).
func (s *Service) RegisterTool(h ToolHandler) { s.tools[h.Tool().Name] = h }

// budgetState — расход месяца/дня (все пользователи: бюджет сервера общий).
type budgetState struct {
	MonthUSD, DayUSD, BudgetUSD float64
}

func (b budgetState) exhausted() bool { return b.MonthUSD >= b.BudgetUSD }

// degraded — ≥80% месяца или дневной мягкий лимит (месячный/30×2) → Sonnet-задачи на Haiku.
func (b budgetState) degraded() bool {
	return b.MonthUSD >= 0.8*b.BudgetUSD || b.DayUSD >= b.BudgetUSD/30*2
}

func (s *Service) budget(ctx context.Context) (budgetState, error) {
	now := time.Now().UTC()
	month := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC).UnixMilli()
	day := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC).UnixMilli()
	b := budgetState{BudgetUSD: s.opts.MonthlyBudgetUSD}
	err := s.db.QueryRowContext(ctx,
		`SELECT COALESCE(SUM(cost_usd),0), COALESCE(SUM(CASE WHEN at >= ? THEN cost_usd END),0) FROM ai_usage WHERE at >= ?`,
		day, month).Scan(&b.MonthUSD, &b.DayUSD)
	return b, err
}

// effortFor — уровень усилия по задаче (экономия токенов: разговор и короткие — low).
func effortFor(task Task) string {
	switch task {
	case TaskPlan, TaskAnalysis, TaskBodyVision:
		return "medium"
	}
	return "low"
}

// Do — см. Client: модель по задаче, бюджет, вызов провайдера, запись расхода в ai_usage.
func (s *Service) Do(ctx context.Context, userID string, task Task, req Request) (Response, error) {
	b, err := s.budget(ctx)
	if err != nil {
		return Response{}, err
	}
	if b.exhausted() {
		return Response{}, ErrBudget
	}
	model := s.models[task]
	if model == "" {
		model = ModelHaiku
	}
	if b.degraded() && isSonnetTier(model) {
		model = s.models[TaskShort]
		if model == "" || isGemini(model) {
			model = ModelHaiku
		}
	}
	var p Provider
	switch {
	case isGemini(model) && s.gemini != nil:
		p = s.gemini
	case isGemini(model) && s.anthropic != nil:
		model = ModelHaiku // нет ключа Gemini — vision через Haiku
		p = s.anthropic
	case !isGemini(model) && s.anthropic != nil:
		p = s.anthropic
	default:
		return Response{}, ErrUnavailable
	}
	if req.MaxTokens <= 0 {
		req.MaxTokens = 4096
	}
	resp, err := p.Complete(withEffort(ctx, effortFor(task)), model, req)
	if err != nil {
		return Response{}, err
	}
	if resp.Model == "" {
		resp.Model = model
	}
	var uid any
	if userID != "" {
		uid = userID
	}
	if _, err := s.db.ExecContext(context.WithoutCancel(ctx),
		`INSERT INTO ai_usage(user_id, task, provider, model, input_tokens, output_tokens, cache_read, cache_write, cost_usd, at)
		 VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		uid, string(task), resp.Provider, resp.Model, resp.Usage.InputTokens, resp.Usage.OutputTokens,
		resp.Usage.CacheReadTokens, resp.Usage.CacheWriteTokens, resp.CostUSD, time.Now().UnixMilli()); err != nil {
		s.opts.Logger.Error("ai usage", "err", err)
	}
	return resp, nil
}

// Register — /api/v1/ai/...: chat, plan/generate, plan/review, usage, actions (+undo), voices, tts.
func (s *Service) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	h := func(f http.HandlerFunc) http.Handler { return require(f) }
	mux.Handle("POST /api/v1/ai/chat", h(s.handleChat))
	mux.Handle("POST /api/v1/ai/plan/generate", h(func(w http.ResponseWriter, r *http.Request) { s.handlePlan(w, r, false) }))
	mux.Handle("POST /api/v1/ai/plan/review", h(func(w http.ResponseWriter, r *http.Request) { s.handlePlan(w, r, true) }))
	mux.Handle("GET /api/v1/ai/usage", h(s.handleUsage))
	mux.Handle("GET /api/v1/ai/actions", h(s.handleActions))
	mux.Handle("POST /api/v1/ai/actions/{id}/undo", h(s.handleUndo))
	mux.Handle("GET /api/v1/ai/voices", h(s.handleVoices))
	mux.Handle("POST /api/v1/ai/tts", h(s.handleTTS))
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

// writeAIError — ErrBudget → 402 ai_budget, ErrUnavailable → 503 ai_unavailable, прочее → 502.
func (s *Service) writeAIError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, ErrBudget):
		writeError(w, http.StatusPaymentRequired, "ai_budget")
	case errors.Is(err, ErrUnavailable):
		writeError(w, http.StatusServiceUnavailable, "ai_unavailable")
	default:
		s.opts.Logger.Error("ai", "err", err)
		writeError(w, http.StatusBadGateway, "ai_error")
	}
}

func decodeBody(w http.ResponseWriter, r *http.Request, v any) bool {
	if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20)).Decode(v); err != nil {
		writeError(w, http.StatusBadRequest, "bad json")
		return false
	}
	return true
}

func (s *Service) handleUsage(w http.ResponseWriter, r *http.Request) {
	b, err := s.budget(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	now := time.Now().UTC()
	month := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC).UnixMilli()
	rows, err := s.db.QueryContext(r.Context(),
		`SELECT task, SUM(cost_usd), COUNT(*) FROM ai_usage WHERE at >= ? GROUP BY task ORDER BY SUM(cost_usd) DESC`, month)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	defer rows.Close()
	type row struct {
		Task  string  `json:"task"`
		USD   float64 `json:"usd"`
		Calls int     `json:"calls"`
	}
	by := []row{}
	for rows.Next() {
		var x row
		if rows.Scan(&x.Task, &x.USD, &x.Calls) == nil {
			by = append(by, x)
		}
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"month_usd": b.MonthUSD, "budget_usd": b.BudgetUSD, "day_usd": b.DayUSD,
		"degraded": b.degraded() || b.exhausted(), "by_task": by,
	})
}

// ActionRef — действие ИИ в ответе чата/плана.
type ActionRef struct {
	ID      string `json:"id"`
	Summary string `json:"summary"`
}

// runTool исполняет вызов инструмента и пишет ai_actions. Ошибка инструмента — результат для модели (is_error).
func (s *Service) runTool(ctx context.Context, uid string, call ToolCall) (ToolResult, *ActionRef) {
	h, ok := s.tools[call.Name]
	if !ok {
		return ToolResult{CallID: call.ID, Content: "unknown tool", IsError: true}, nil
	}
	result, summary, undo, err := h.Run(ctx, uid, call.Input)
	if err != nil {
		return ToolResult{CallID: call.ID, Content: "error: " + err.Error(), IsError: true}, nil
	}
	ref, err := s.logAction(ctx, uid, call.Name, call.Input, summary, undo)
	if err != nil {
		s.opts.Logger.Error("ai action log", "err", err)
	}
	return ToolResult{CallID: call.ID, Content: result}, ref
}

func (s *Service) logAction(ctx context.Context, uid, tool string, input json.RawMessage, summary string, undo json.RawMessage) (*ActionRef, error) {
	id := newID()
	var u any
	if len(undo) > 0 {
		u = string(undo)
	}
	if len(input) == 0 {
		input = json.RawMessage(`{}`)
	}
	_, err := s.db.ExecContext(context.WithoutCancel(ctx),
		`INSERT INTO ai_actions(id, user_id, tool, input, summary, undo, at) VALUES(?, ?, ?, ?, ?, ?, ?)`,
		id, uid, tool, string(input), summary, u, time.Now().UnixMilli())
	if err != nil {
		return nil, err
	}
	return &ActionRef{ID: id, Summary: summary}, nil
}

func (s *Service) handleActions(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	limit := 50
	if v, err := strconv.Atoi(r.URL.Query().Get("limit")); err == nil && v > 0 {
		limit = min(v, 200)
	}
	rows, err := s.db.QueryContext(r.Context(),
		`SELECT id, tool, summary, at, undone_at, undo IS NOT NULL FROM ai_actions WHERE user_id = ? ORDER BY at DESC LIMIT ?`,
		uid, limit)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	defer rows.Close()
	type item struct {
		ID       string `json:"id"`
		Tool     string `json:"tool"`
		Summary  string `json:"summary"`
		At       int64  `json:"at"`
		UndoneAt *int64 `json:"undone_at"`
		CanUndo  bool   `json:"can_undo"`
	}
	out := []item{}
	for rows.Next() {
		var it item
		var undone sql.NullInt64
		var hasUndo bool
		if err := rows.Scan(&it.ID, &it.Tool, &it.Summary, &it.At, &undone, &hasUndo); err != nil {
			continue
		}
		if undone.Valid {
			it.UndoneAt = &undone.Int64
		}
		it.CanUndo = hasUndo && !undone.Valid
		out = append(out, it)
	}
	writeJSON(w, http.StatusOK, map[string]any{"actions": out})
}

func (s *Service) handleUndo(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	id := r.PathValue("id")
	var tool string
	var undo sql.NullString
	var undone sql.NullInt64
	err := s.db.QueryRowContext(r.Context(),
		`SELECT tool, undo, undone_at FROM ai_actions WHERE id = ? AND user_id = ?`, id, uid).Scan(&tool, &undo, &undone)
	if errors.Is(err, sql.ErrNoRows) {
		writeError(w, http.StatusNotFound, "not found")
		return
	}
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	if undone.Valid {
		writeError(w, http.StatusConflict, "already undone")
		return
	}
	if !undo.Valid {
		writeError(w, http.StatusConflict, "cannot undo")
		return
	}
	// Сначала «занимаем» отмену (повторный запрос не отменит дважды), при ошибке — возвращаем.
	res, err := s.db.ExecContext(r.Context(),
		`UPDATE ai_actions SET undone_at = ? WHERE id = ? AND undone_at IS NULL`, time.Now().UnixMilli(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	if n, _ := res.RowsAffected(); n == 0 {
		writeError(w, http.StatusConflict, "already undone")
		return
	}
	// Действия плана и неизвестные инструменты — универсальная отмена списком изменений.
	if h, ok := s.tools[tool]; ok {
		err = h.Undo(r.Context(), uid, json.RawMessage(undo.String))
	} else {
		err = applyUndo(r.Context(), s.db, uid, json.RawMessage(undo.String))
	}
	if err != nil {
		_, _ = s.db.ExecContext(context.WithoutCancel(r.Context()), `UPDATE ai_actions SET undone_at = NULL WHERE id = ?`, id)
		s.opts.Logger.Error("ai undo", "id", id, "err", err)
		writeError(w, http.StatusInternalServerError, "undo failed")
		return
	}
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

var _ Client = (*Service)(nil)
