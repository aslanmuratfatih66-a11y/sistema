package ai

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"strings"
	"sync"
	"time"
)

// Anthropic — Messages API по HTTP (без SDK).
type Anthropic struct {
	Key     string
	BaseURL string // по умолчанию https://api.anthropic.com
	Timeout time.Duration

	mu  sync.Mutex
	raw map[string]rawTurn // id первого tool_use → исходный контент хода ассистента (с thinking-блоками)
}

type rawTurn struct {
	content []json.RawMessage
	at      time.Time
}

func NewAnthropic(key string) *Anthropic {
	return &Anthropic{Key: key, BaseURL: "https://api.anthropic.com", Timeout: 150 * time.Second, raw: map[string]rawTurn{}}
}

func (a *Anthropic) Name() string { return "anthropic" }

type ctxKey int

const effortKey ctxKey = 1

// withEffort — уровень усилия модели (low/medium/high) для вызова.
func withEffort(ctx context.Context, effort string) context.Context {
	return context.WithValue(ctx, effortKey, effort)
}

type antBlock struct {
	Type         string          `json:"type"`
	Text         string          `json:"text,omitempty"`
	ID           string          `json:"id,omitempty"`
	Name         string          `json:"name,omitempty"`
	Input        json.RawMessage `json:"input,omitempty"`
	ToolUseID    string          `json:"tool_use_id,omitempty"`
	Content      string          `json:"content,omitempty"`
	IsError      bool            `json:"is_error,omitempty"`
	Source       *antSource      `json:"source,omitempty"`
	CacheControl *antCache       `json:"cache_control,omitempty"`
}

type antSource struct {
	Type      string `json:"type"`
	MediaType string `json:"media_type"`
	Data      string `json:"data"`
}

type antCache struct {
	Type string `json:"type"`
}

type antMessage struct {
	Role    string `json:"role"`
	Content any    `json:"content"` // []antBlock или []json.RawMessage
}

type antResponse struct {
	Model      string            `json:"model"`
	Content    []json.RawMessage `json:"content"`
	StopReason string            `json:"stop_reason"`
	Usage      struct {
		InputTokens   int `json:"input_tokens"`
		OutputTokens  int `json:"output_tokens"`
		CacheCreation int `json:"cache_creation_input_tokens"`
		CacheRead     int `json:"cache_read_input_tokens"`
		ServerToolUse struct {
			WebSearchRequests int `json:"web_search_requests"`
		} `json:"server_tool_use"`
	} `json:"usage"`
}

func (a *Anthropic) Complete(ctx context.Context, model string, req Request) (Response, error) {
	if a == nil || a.Key == "" {
		return Response{}, ErrUnavailable
	}
	body := map[string]any{
		"model":      model,
		"max_tokens": max(req.MaxTokens, 1024),
	}
	// Системные блоки: кэш-метки на помеченных (не больше 3 — лимит 4 точки на запрос).
	var sys []antBlock
	marks := 0
	for _, b := range req.System {
		if strings.TrimSpace(b.Text) == "" {
			continue
		}
		blk := antBlock{Type: "text", Text: b.Text}
		if b.Cache && marks < 3 {
			blk.CacheControl = &antCache{Type: "ephemeral"}
			marks++
		}
		sys = append(sys, blk)
	}
	if req.JSON {
		sys = append(sys, antBlock{Type: "text", Text: "Answer with a single JSON object only, without markdown fences or any other text."})
	}
	if len(sys) > 0 {
		body["system"] = sys
	}
	var tools []any
	for _, t := range req.Tools {
		schema := t.Schema
		if len(schema) == 0 {
			schema = json.RawMessage(`{"type":"object","properties":{}}`)
		}
		tools = append(tools, map[string]any{"name": t.Name, "description": t.Description, "input_schema": schema})
	}
	if req.WebSearch {
		typ := "web_search_20250305"
		if isSonnetTier(model) {
			typ = "web_search_20260209"
		}
		tools = append(tools, map[string]any{"type": typ, "name": "web_search", "max_uses": 3})
	}
	if len(tools) > 0 {
		body["tools"] = tools
	}
	if e, _ := ctx.Value(effortKey).(string); e != "" {
		body["output_config"] = map[string]any{"effort": e}
	}
	headers := map[string]string{"x-api-key": a.Key, "anthropic-version": "2023-06-01"}
	if strings.HasPrefix(model, "claude-sonnet-5-5") {
		// Серверный фолбэк при отказе классификаторов (claude-api: Sonnet 5.5, Claude API).
		body["fallbacks"] = "default"
		headers["anthropic-beta"] = "server-side-fallback-2026-07-01"
	}

	msgs := make([]antMessage, 0, len(req.Messages)+2)
	for _, m := range req.Messages {
		msgs = append(msgs, a.encodeMessage(m))
	}

	var out Response
	out.Provider = a.Name()
	out.Model = model
	searches := 0
	var texts []string
	for step := 0; step < 4; step++ {
		body["messages"] = msgs
		data, _, err := postJSON(ctx, "anthropic", strings.TrimRight(a.BaseURL, "/")+"/v1/messages", headers, body, a.Timeout)
		if err != nil {
			return Response{}, err
		}
		var r antResponse
		if err := json.Unmarshal(data, &r); err != nil {
			return Response{}, err
		}
		if r.Model != "" {
			out.Model = r.Model
		}
		out.Usage.InputTokens += r.Usage.InputTokens
		out.Usage.OutputTokens += r.Usage.OutputTokens
		out.Usage.CacheReadTokens += r.Usage.CacheRead
		out.Usage.CacheWriteTokens += r.Usage.CacheCreation
		searches += r.Usage.ServerToolUse.WebSearchRequests

		for _, raw := range r.Content {
			var b struct {
				Type  string          `json:"type"`
				Text  string          `json:"text"`
				ID    string          `json:"id"`
				Name  string          `json:"name"`
				Input json.RawMessage `json:"input"`
			}
			if json.Unmarshal(raw, &b) != nil {
				continue
			}
			switch b.Type {
			case "text":
				texts = append(texts, b.Text)
			case "tool_use":
				in := b.Input
				if len(in) == 0 {
					in = json.RawMessage(`{}`)
				}
				out.ToolCalls = append(out.ToolCalls, ToolCall{ID: b.ID, Name: b.Name, Input: in})
			}
		}
		if r.StopReason == "pause_turn" {
			// Серверный инструмент (веб-поиск) прервал ход — продолжаем тем же контентом.
			msgs = append(msgs, antMessage{Role: "assistant", Content: r.Content})
			continue
		}
		if len(out.ToolCalls) > 0 {
			a.remember(out.ToolCalls[0].ID, r.Content)
		}
		switch r.StopReason {
		case "tool_use":
			out.StopReason = "tool_use"
		case "max_tokens":
			out.StopReason = "max_tokens"
		case "refusal":
			out.StopReason = "refusal"
		default:
			out.StopReason = "end"
		}
		break
	}
	out.Text = strings.TrimSpace(strings.Join(texts, ""))
	if req.JSON {
		out.Text = stripFences(out.Text)
	}
	out.CostUSD = costUSD(model, out.Usage) + float64(searches)*webSearchUSD
	return out, nil
}

func (a *Anthropic) encodeMessage(m Message) antMessage {
	role := "user"
	if m.Role == RoleAssistant {
		role = "assistant"
		for _, p := range m.Parts {
			if p.ToolCall != nil {
				if raw, ok := a.recall(p.ToolCall.ID); ok {
					return antMessage{Role: role, Content: raw}
				}
				break
			}
		}
	}
	blocks := make([]antBlock, 0, len(m.Parts))
	for _, p := range m.Parts {
		switch {
		case p.Image != nil:
			blocks = append(blocks, antBlock{Type: "image", Source: &antSource{
				Type: "base64", MediaType: p.Image.MediaType, Data: base64.StdEncoding.EncodeToString(p.Image.Data)}})
		case p.Document != nil:
			blocks = append(blocks, antBlock{Type: "document", Source: &antSource{
				Type: "base64", MediaType: p.Document.MediaType, Data: base64.StdEncoding.EncodeToString(p.Document.Data)}})
		case p.ToolCall != nil:
			in := p.ToolCall.Input
			if len(in) == 0 {
				in = json.RawMessage(`{}`)
			}
			blocks = append(blocks, antBlock{Type: "tool_use", ID: p.ToolCall.ID, Name: p.ToolCall.Name, Input: in})
		case p.ToolResult != nil:
			c := p.ToolResult.Content
			if c == "" {
				c = "ok"
			}
			blocks = append(blocks, antBlock{Type: "tool_result", ToolUseID: p.ToolResult.CallID, Content: c, IsError: p.ToolResult.IsError})
		case p.Text != "":
			blocks = append(blocks, antBlock{Type: "text", Text: p.Text})
		}
	}
	if len(blocks) == 0 {
		blocks = append(blocks, antBlock{Type: "text", Text: "…"})
	}
	return antMessage{Role: role, Content: blocks}
}

// remember/recall — ход ассистента с tool_use возвращается в API без изменений (thinking-блоки обязаны сохраниться).
func (a *Anthropic) remember(id string, content []json.RawMessage) {
	a.mu.Lock()
	defer a.mu.Unlock()
	now := time.Now()
	for k, v := range a.raw {
		if now.Sub(v.at) > 30*time.Minute {
			delete(a.raw, k)
		}
	}
	a.raw[id] = rawTurn{content: content, at: now}
}

func (a *Anthropic) recall(id string) ([]json.RawMessage, bool) {
	a.mu.Lock()
	defer a.mu.Unlock()
	v, ok := a.raw[id]
	return v.content, ok
}

// stripFences убирает ```json … ``` и текст вокруг JSON-объекта.
func stripFences(s string) string {
	s = strings.TrimSpace(s)
	if i := strings.Index(s, "{"); i >= 0 {
		if j := strings.LastIndex(s, "}"); j > i {
			return s[i : j+1]
		}
	}
	return s
}
