package ai

import (
	"strings"
)

// Модели по умолчанию (SPEC §9.1). Переопределение — Options.Models «task=model,…».
const (
	ModelSonnet = "claude-sonnet-5-5"
	ModelHaiku  = "claude-haiku-5-5"
	// TODO: проверить актуальный id Gemini Flash при деплое (переопределяется SISTEMA_AI_MODELS food_vision=…).
	ModelGeminiFlash = "gemini-2.5-flash"
)

var defaultModels = map[Task]string{
	TaskChat:       ModelSonnet,
	TaskAnalysis:   ModelSonnet,
	TaskPlan:       ModelSonnet,
	TaskPlanEdit:   ModelSonnet,
	TaskShort:      ModelHaiku,
	TaskBankParse:  ModelHaiku,
	TaskFoodVision: ModelGeminiFlash,
	TaskBodyVision: ModelSonnet,
	TaskLearning:   ModelHaiku,
}

// price — $ за 1M токенов.
type price struct {
	In, Out, CacheRead, CacheWrite float64
	// LongIn/LongOut — тариф при промпте > LongAbove токенов (0 — нет).
	LongAbove       int
	LongIn, LongOut float64
}

// prices — по данным claude-api (кэш 2026-10) и прайсу Gemini. Запись в кэш (5 мин) — 1.25× входа.
var prices = map[string]price{
	"claude-sonnet-5-5": {In: 2, Out: 10, CacheRead: 0.20, CacheWrite: 2.5},
	"claude-sonnet-5":   {In: 2, Out: 10, CacheRead: 0.20, CacheWrite: 2.5},
	"claude-haiku-5-5":  {In: 0.10, Out: 0.50, CacheRead: 0.01, CacheWrite: 0.125, LongAbove: 100_000, LongIn: 0.50, LongOut: 2.50},
	"claude-opus-5-5":   {In: 4, Out: 20, CacheRead: 0.20, CacheWrite: 5},
	// TODO: сверить прайс Gemini при смене модели.
	"gemini-2.5-flash": {In: 0.30, Out: 2.50, CacheRead: 0.03},
	"gemini-2.5-pro":   {In: 1.25, Out: 10, CacheRead: 0.125, LongAbove: 200_000, LongIn: 2.5, LongOut: 15},
}

// webSearchUSD — цена одного веб-поиска Anthropic ($10 / 1000).
const webSearchUSD = 0.01

// costUSD — стоимость вызова по прайсу модели; неизвестная модель — по прайсу Sonnet (с запасом).
func costUSD(model string, u Usage) float64 {
	p, ok := prices[model]
	if !ok {
		p = matchPrice(model)
	}
	in, out := p.In, p.Out
	if p.LongAbove > 0 && u.InputTokens+u.CacheReadTokens+u.CacheWriteTokens > p.LongAbove {
		in, out = p.LongIn, p.LongOut
	}
	cw := p.CacheWrite
	if cw == 0 {
		cw = in * 1.25
	}
	cr := p.CacheRead
	if cr == 0 {
		cr = in * 0.1
	}
	return (float64(u.InputTokens)*in + float64(u.OutputTokens)*out +
		float64(u.CacheReadTokens)*cr + float64(u.CacheWriteTokens)*cw) / 1e6
}

func matchPrice(model string) price {
	switch {
	case strings.Contains(model, "haiku"):
		return prices[ModelHaiku]
	case strings.Contains(model, "opus"):
		return prices["claude-opus-5-5"]
	case strings.HasPrefix(model, "gemini") && strings.Contains(model, "pro"):
		return prices["gemini-2.5-pro"]
	case strings.HasPrefix(model, "gemini"):
		return prices["gemini-2.5-flash"]
	}
	return prices[ModelSonnet]
}

// parseModels — «task=model,…» → карта переопределений.
func parseModels(s string) map[Task]string {
	m := map[Task]string{}
	for k, v := range defaultModels {
		m[k] = v
	}
	for _, part := range strings.Split(s, ",") {
		k, v, ok := strings.Cut(strings.TrimSpace(part), "=")
		if ok && strings.TrimSpace(k) != "" && strings.TrimSpace(v) != "" {
			m[Task(strings.TrimSpace(k))] = strings.TrimSpace(v)
		}
	}
	return m
}

func isGemini(model string) bool { return strings.HasPrefix(model, "gemini") }

func isSonnetTier(model string) bool {
	return strings.Contains(model, "sonnet") || strings.Contains(model, "opus") || strings.Contains(model, "fable")
}
