package ai

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"strings"
	"time"
)

// Gemini — REST generateContent (ключ в заголовке x-goog-api-key).
type Gemini struct {
	Key     string
	BaseURL string // по умолчанию https://generativelanguage.googleapis.com/v1beta
	Timeout time.Duration
}

func NewGemini(key string) *Gemini {
	return &Gemini{Key: key, BaseURL: "https://generativelanguage.googleapis.com/v1beta", Timeout: 90 * time.Second}
}

func (g *Gemini) Name() string { return "gemini" }

type gemPart struct {
	Text             string          `json:"text,omitempty"`
	InlineData       *gemInline      `json:"inline_data,omitempty"`
	FunctionCall     *gemFuncCall    `json:"functionCall,omitempty"`
	FunctionResponse *gemFuncResp    `json:"functionResponse,omitempty"`
	ThoughtSignature json.RawMessage `json:"thoughtSignature,omitempty"`
}

type gemInline struct {
	MimeType string `json:"mime_type"`
	Data     string `json:"data"`
}

type gemFuncCall struct {
	Name string          `json:"name"`
	Args json.RawMessage `json:"args,omitempty"`
}

type gemFuncResp struct {
	Name     string         `json:"name"`
	Response map[string]any `json:"response"`
}

type gemContent struct {
	Role  string    `json:"role,omitempty"`
	Parts []gemPart `json:"parts"`
}

func (g *Gemini) Complete(ctx context.Context, model string, req Request) (Response, error) {
	if g == nil || g.Key == "" {
		return Response{}, ErrUnavailable
	}
	body := map[string]any{}
	var sys []string
	for _, b := range req.System {
		if strings.TrimSpace(b.Text) != "" {
			sys = append(sys, b.Text)
		}
	}
	if len(sys) > 0 {
		body["systemInstruction"] = gemContent{Parts: []gemPart{{Text: strings.Join(sys, "\n\n")}}}
	}
	// Имена вызовов по id — для functionResponse.
	callNames := map[string]string{}
	var contents []gemContent
	for _, m := range req.Messages {
		role := "user"
		if m.Role == RoleAssistant {
			role = "model"
		}
		var parts []gemPart
		for _, p := range m.Parts {
			switch {
			case p.Document != nil:
				parts = append(parts, gemPart{InlineData: &gemInline{MimeType: p.Document.MediaType, Data: base64.StdEncoding.EncodeToString(p.Document.Data)}})
			case p.Image != nil:
				parts = append(parts, gemPart{InlineData: &gemInline{MimeType: p.Image.MediaType, Data: base64.StdEncoding.EncodeToString(p.Image.Data)}})
			case p.ToolCall != nil:
				callNames[p.ToolCall.ID] = p.ToolCall.Name
				parts = append(parts, gemPart{FunctionCall: &gemFuncCall{Name: p.ToolCall.Name, Args: p.ToolCall.Input}})
			case p.ToolResult != nil:
				name := callNames[p.ToolResult.CallID]
				if name == "" {
					name = p.ToolResult.CallID
				}
				key := "result"
				if p.ToolResult.IsError {
					key = "error"
				}
				parts = append(parts, gemPart{FunctionResponse: &gemFuncResp{Name: name, Response: map[string]any{key: p.ToolResult.Content}}})
			case p.Text != "":
				parts = append(parts, gemPart{Text: p.Text})
			}
		}
		if len(parts) > 0 {
			contents = append(contents, gemContent{Role: role, Parts: parts})
		}
	}
	body["contents"] = contents
	gc := map[string]any{}
	if req.MaxTokens > 0 {
		gc["maxOutputTokens"] = req.MaxTokens
	}
	// JSON-режим несовместим с инструментами/поиском у Gemini — тогда только инструкция.
	if req.JSON && len(req.Tools) == 0 && !req.WebSearch {
		gc["responseMimeType"] = "application/json"
	}
	body["generationConfig"] = gc
	var tools []any
	if len(req.Tools) > 0 {
		var decls []map[string]any
		for _, t := range req.Tools {
			d := map[string]any{"name": t.Name, "description": t.Description}
			if len(t.Schema) > 0 {
				d["parameters"] = json.RawMessage(t.Schema)
			}
			decls = append(decls, d)
		}
		tools = append(tools, map[string]any{"functionDeclarations": decls})
	}
	if req.WebSearch {
		tools = append(tools, map[string]any{"google_search": map[string]any{}})
	}
	if len(tools) > 0 {
		body["tools"] = tools
	}

	url := strings.TrimRight(g.BaseURL, "/") + "/models/" + model + ":generateContent"
	data, _, err := postJSON(ctx, "gemini", url, map[string]string{"x-goog-api-key": g.Key}, body, g.Timeout)
	if err != nil {
		return Response{}, err
	}
	var r struct {
		Candidates []struct {
			Content      gemContent `json:"content"`
			FinishReason string     `json:"finishReason"`
		} `json:"candidates"`
		UsageMetadata struct {
			PromptTokenCount        int `json:"promptTokenCount"`
			CandidatesTokenCount    int `json:"candidatesTokenCount"`
			CachedContentTokenCount int `json:"cachedContentTokenCount"`
			ThoughtsTokenCount      int `json:"thoughtsTokenCount"`
		} `json:"usageMetadata"`
		ModelVersion string `json:"modelVersion"`
	}
	if err := json.Unmarshal(data, &r); err != nil {
		return Response{}, err
	}
	out := Response{Provider: g.Name(), Model: model, StopReason: "end"}
	u := r.UsageMetadata
	out.Usage = Usage{
		InputTokens:     max(0, u.PromptTokenCount-u.CachedContentTokenCount),
		OutputTokens:    u.CandidatesTokenCount + u.ThoughtsTokenCount,
		CacheReadTokens: u.CachedContentTokenCount,
	}
	if len(r.Candidates) > 0 {
		c := r.Candidates[0]
		var texts []string
		for i, p := range c.Content.Parts {
			if p.FunctionCall != nil {
				args := p.FunctionCall.Args
				if len(args) == 0 {
					args = json.RawMessage(`{}`)
				}
				out.ToolCalls = append(out.ToolCalls, ToolCall{ID: p.FunctionCall.Name + "#" + itoa(i), Name: p.FunctionCall.Name, Input: args})
			} else if p.Text != "" {
				texts = append(texts, p.Text)
			}
		}
		out.Text = strings.TrimSpace(strings.Join(texts, ""))
		switch {
		case len(out.ToolCalls) > 0:
			out.StopReason = "tool_use"
		case c.FinishReason == "MAX_TOKENS":
			out.StopReason = "max_tokens"
		case c.FinishReason == "SAFETY" || c.FinishReason == "PROHIBITED_CONTENT":
			out.StopReason = "refusal"
		}
	}
	if req.JSON {
		out.Text = stripFences(out.Text)
	}
	out.CostUSD = costUSD(model, out.Usage)
	return out, nil
}

func itoa(i int) string {
	b, _ := json.Marshal(i)
	return string(b)
}
