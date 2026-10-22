// Package ai — слой ИИ (SPEC §9.1): провайдеры (Anthropic, Gemini), модель на задачу из конфига,
// кэширование промптов, учёт расходов и бюджет, инструменты (tool use) с журналом и отменой.
// КОНТРАКТ каркаса этапа 6 (типы и интерфейсы правит главный агент); реализация — сабагент A.
// Пакеты vision, messages, learning вызывают ИИ только через [Client].
package ai

import (
	"context"
	"encoding/json"
	"errors"
)

// Task — тип задачи; по нему выбирается модель (SPEC §9.1).
type Task string

const (
	TaskChat       Task = "chat"        // разговор с персонажем — Sonnet
	TaskAnalysis   Task = "analysis"    // анализ дня/недели — Sonnet
	TaskPlan       Task = "plan"        // построение и пересмотр плана — Sonnet
	TaskPlanEdit   Task = "plan_edit"   // изменение плана инструментами — Sonnet
	TaskShort      Task = "short"       // короткие реплики, сообщения наперёд — Haiku
	TaskBankParse  Task = "bank_parse"  // разбор уведомлений банков — Haiku
	TaskFoodVision Task = "food_vision" // еда и чеки по фото — Gemini
	TaskBodyVision Task = "body_vision" // тело и кожа по фото — Sonnet (настраивается)
	TaskLearning   Task = "learning"    // уроки и проверки — Haiku
)

// Role сообщения.
type Role string

const (
	RoleUser      Role = "user"
	RoleAssistant Role = "assistant"
)

// Image — картинка во входе (JPEG/PNG/WebP).
type Image struct {
	MediaType string // image/jpeg …
	Data      []byte
}

// Document — файл во входе (PDF выписки банка, этап 7). Anthropic — блок document, Gemini — inline_data.
type Document struct {
	MediaType string // application/pdf
	Data      []byte
}

// Part — часть сообщения: текст, картинка, документ, вызов инструмента или его результат.
type Part struct {
	Text       string
	Image      *Image
	Document   *Document
	ToolCall   *ToolCall
	ToolResult *ToolResult
}

type Message struct {
	Role  Role
	Parts []Part
}

// SystemBlock — часть системного промпта. Cache — пометить для кэширования (профиль, план, правила персонажа):
// стабильные блоки ставить первыми.
type SystemBlock struct {
	Text  string
	Cache bool
}

// Tool — инструмент, доступный модели. Schema — JSON Schema входа.
type Tool struct {
	Name        string
	Description string
	Schema      json.RawMessage
}

type ToolCall struct {
	ID    string
	Name  string
	Input json.RawMessage
}

type ToolResult struct {
	CallID  string
	Content string
	IsError bool
}

// Request — запрос к модели (провайдер-независимый).
type Request struct {
	System    []SystemBlock
	Messages  []Message
	Tools     []Tool
	MaxTokens int
	// JSON — ждать ответ строго JSON-объектом (структурированный вывод, где провайдер умеет).
	JSON bool
	// WebSearch — разрешить модели веб-поиск (КБЖУ купленного блюда, SPEC §9.4), если провайдер умеет.
	WebSearch bool
}

// Usage — расход токенов одного вызова.
type Usage struct {
	InputTokens      int
	OutputTokens     int
	CacheReadTokens  int
	CacheWriteTokens int
}

type Response struct {
	Text      string
	ToolCalls []ToolCall
	// StopReason — "end", "tool_use", "max_tokens".
	StopReason string
	Usage      Usage
	Model      string
	Provider   string
	// CostUSD — по прайсу модели из конфига.
	CostUSD float64
}

// Provider — один поставщик (Anthropic, Gemini). Реализации — сабагент A.
type Provider interface {
	Name() string
	Complete(ctx context.Context, model string, req Request) (Response, error)
}

// ErrBudget — лимит исчерпан (даже дешёвой моделью нельзя). Клиенту — 402 {"error":"ai_budget"}.
var ErrBudget = errors.New("ai: budget exhausted")

// ErrUnavailable — провайдер не настроен (нет ключа). Клиенту — 503 {"error":"ai_unavailable"}.
var ErrUnavailable = errors.New("ai: provider unavailable")

// Client — точка входа для остальных пакетов: выбор модели по задаче, бюджет (при приближении к лимиту —
// дешёвые модели), запись расхода в ai_usage.
type Client interface {
	Do(ctx context.Context, userID string, task Task, req Request) (Response, error)
}

// ToolHandler исполняет инструмент от имени пользователя и возвращает результат для модели, краткое описание
// для журнала («Система изменила план: …») и данные для отмены. Реализации — в A (план, квесты, ◆, нормы, еда).
type ToolHandler interface {
	Tool() Tool
	Run(ctx context.Context, userID string, input json.RawMessage) (result string, summary string, undo json.RawMessage, err error)
	Undo(ctx context.Context, userID string, undo json.RawMessage) error
}
