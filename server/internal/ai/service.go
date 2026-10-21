package ai

import (
	"context"
	"database/sql"
	"log/slog"
	"net/http"
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

// Service — реализация Client + HTTP API ИИ. TODO A: провайдеры, бюджет, журнал, инструменты, чат, план, TTS.
type Service struct {
	db    *sql.DB
	opts  Options
	tools map[string]ToolHandler
}

func New(db *sql.DB, opts Options) *Service {
	if opts.Logger == nil {
		opts.Logger = slog.Default()
	}
	if opts.MonthlyBudgetUSD <= 0 {
		opts.MonthlyBudgetUSD = 30
	}
	return &Service{db: db, opts: opts, tools: map[string]ToolHandler{}}
}

// RegisterTool — добавить инструмент (вызывать до Register).
func (s *Service) RegisterTool(h ToolHandler) { s.tools[h.Tool().Name] = h }

// Do — см. Client. TODO A.
func (s *Service) Do(ctx context.Context, userID string, task Task, req Request) (Response, error) {
	return Response{}, ErrUnavailable
}

// Register — /api/v1/ai/...: chat, plan/generate, plan/review, usage, actions (+undo), tts. TODO A.
func (s *Service) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}

// WeeklyReview — задача планировщика: недельный пересмотр планов. TODO A.
func (s *Service) WeeklyReview(ctx context.Context) error { return nil }

var _ Client = (*Service)(nil)
