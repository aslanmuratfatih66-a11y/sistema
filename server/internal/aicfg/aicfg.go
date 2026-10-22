// Package aicfg — конфигурация ИИ (SPEC §9.1): ai.yaml (модели по задачам, цены, бюджет, понижение)
// и карточки персонажей characters/<id>.yaml.
//
// Порядок слияния: вшитые значения (server/config) → файлы из каталога SISTEMA_CONFIG_DIR
// (по умолчанию /opt/sistema/config; отсутствие файла — не ошибка) → SISTEMA_AI_MODELS / SISTEMA_AI_BUDGET_USD.
package aicfg

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"gopkg.in/yaml.v3"

	defaults "github.com/aslanmuratfatih66-a11y/sistema/server/config"
)

// DefaultDir — каталог переопределений на сервере.
const DefaultDir = "/opt/sistema/config"

// Провайдеры.
const (
	ProviderAnthropic = "anthropic"
	ProviderGemini    = "gemini"
)

// TaskCfg — модель для задачи.
type TaskCfg struct {
	Model    string `yaml:"model"`
	Provider string `yaml:"provider,omitempty"`
	// NoKeyFallback — модель, если ключа провайдера нет (например, нет ключа Gemini → Claude).
	NoKeyFallback string `yaml:"no_key_fallback,omitempty"`
	Effort        string `yaml:"effort,omitempty"`
}

// PriceChange — цена с даты.
type PriceChange struct {
	From      string  `yaml:"from"` // YYYY-MM-DD (UTC)
	In        float64 `yaml:"in"`
	Out       float64 `yaml:"out"`
	CacheRead float64 `yaml:"cache_read"`
	// CacheWrite 0 — 1.25× входа (Anthropic) / 0 (Gemini).
	CacheWrite float64 `yaml:"cache_write"`
}

// Price — USD за 1 млн токенов.
type Price struct {
	In         float64 `yaml:"in"`
	Out        float64 `yaml:"out"`
	CacheRead  float64 `yaml:"cache_read"`
	CacheWrite float64 `yaml:"cache_write"`
	// LongAbove — порог длины промпта (все входные токены, включая кэш); выше — цены Long*.
	LongAbove      int           `yaml:"long_above,omitempty"`
	LongIn         float64       `yaml:"long_in,omitempty"`
	LongOut        float64       `yaml:"long_out,omitempty"`
	LongCacheRead  float64       `yaml:"long_cache_read,omitempty"`
	LongCacheWrite float64       `yaml:"long_cache_write,omitempty"`
	Changes        []PriceChange `yaml:"changes,omitempty"`
}

// Budget — лимиты расходов (на весь сервер).
type Budget struct {
	MonthlyUSD   float64 `yaml:"monthly_usd"`
	DailyUSD     float64 `yaml:"daily_usd"`
	DailyHardUSD float64 `yaml:"daily_hard_usd"`
	DegradeAt    float64 `yaml:"degrade_at"`
}

// Bench — модели слепого теста по умолчанию.
type Bench struct {
	CharacterModels []string `yaml:"character_models"`
	FoodModels      []string `yaml:"food_models"`
}

// Config — содержимое ai.yaml.
type Config struct {
	AnthropicVersion string             `yaml:"anthropic_version"`
	Budget           Budget             `yaml:"budget"`
	Degrade          map[string]string  `yaml:"degrade"`
	Tasks            map[string]TaskCfg `yaml:"tasks"`
	Prices           map[string]Price   `yaml:"prices"`
	WebSearchUSD     map[string]float64 `yaml:"web_search_usd"`
	Bench            Bench              `yaml:"bench"`
}

// Usage — расход токенов одного вызова (для расчёта стоимости).
type Usage struct {
	InputTokens, OutputTokens, CacheReadTokens, CacheWriteTokens int
	WebSearches                                                  int
}

// Load — вшитый ai.yaml, поверх — <dir>/ai.yaml (если есть). Пустой dir — только вшитые значения.
// Возвращает и путь файла-переопределения, если он применён.
func Load(dir string) (Config, string, error) {
	var c Config
	data, err := defaults.FS.ReadFile("ai.yaml")
	if err != nil {
		return c, "", err
	}
	if err := yaml.Unmarshal(data, &c); err != nil {
		return c, "", fmt.Errorf("aicfg: embedded ai.yaml: %w", err)
	}
	used := ""
	if dir != "" {
		p := filepath.Join(dir, "ai.yaml")
		if data, err := os.ReadFile(p); err == nil {
			var o Config
			if err := yaml.Unmarshal(data, &o); err != nil {
				return c, "", fmt.Errorf("aicfg: %s: %w", p, err)
			}
			c.merge(o)
			used = p
		} else if !errors.Is(err, fs.ErrNotExist) {
			return c, "", fmt.Errorf("aicfg: %s: %w", p, err)
		}
	}
	c.normalize()
	return c, used, nil
}

// merge — непустые поля o поверх c (карты — по ключам).
func (c *Config) merge(o Config) {
	if o.AnthropicVersion != "" {
		c.AnthropicVersion = o.AnthropicVersion
	}
	if o.Budget.MonthlyUSD > 0 {
		c.Budget.MonthlyUSD = o.Budget.MonthlyUSD
	}
	if o.Budget.DailyUSD > 0 {
		c.Budget.DailyUSD = o.Budget.DailyUSD
	}
	if o.Budget.DailyHardUSD > 0 {
		c.Budget.DailyHardUSD = o.Budget.DailyHardUSD
	}
	if o.Budget.DegradeAt > 0 {
		c.Budget.DegradeAt = o.Budget.DegradeAt
	}
	if c.Degrade == nil {
		c.Degrade = map[string]string{}
	}
	for k, v := range o.Degrade {
		c.Degrade[k] = v
	}
	if c.Tasks == nil {
		c.Tasks = map[string]TaskCfg{}
	}
	for k, v := range o.Tasks {
		c.Tasks[k] = v
	}
	if c.Prices == nil {
		c.Prices = map[string]Price{}
	}
	for k, v := range o.Prices {
		c.Prices[k] = v
	}
	if c.WebSearchUSD == nil {
		c.WebSearchUSD = map[string]float64{}
	}
	for k, v := range o.WebSearchUSD {
		c.WebSearchUSD[k] = v
	}
	if len(o.Bench.CharacterModels) > 0 {
		c.Bench.CharacterModels = o.Bench.CharacterModels
	}
	if len(o.Bench.FoodModels) > 0 {
		c.Bench.FoodModels = o.Bench.FoodModels
	}
}

func (c *Config) normalize() {
	if c.AnthropicVersion == "" {
		c.AnthropicVersion = "2023-06-01"
	}
	if c.Budget.MonthlyUSD <= 0 {
		c.Budget.MonthlyUSD = 27
	}
	if c.Budget.DegradeAt <= 0 || c.Budget.DegradeAt > 1 {
		c.Budget.DegradeAt = 0.8
	}
	if c.Degrade == nil {
		c.Degrade = map[string]string{}
	}
	if c.Tasks == nil {
		c.Tasks = map[string]TaskCfg{}
	}
	if c.Prices == nil {
		c.Prices = map[string]Price{}
	}
	if c.WebSearchUSD == nil {
		c.WebSearchUSD = map[string]float64{}
	}
}

// ApplyModels — переопределения «задача=модель,…» (SISTEMA_AI_MODELS). Провайдер — по имени модели.
func (c *Config) ApplyModels(s string) {
	for _, part := range strings.Split(s, ",") {
		k, v, ok := strings.Cut(strings.TrimSpace(part), "=")
		k, v = strings.TrimSpace(k), strings.TrimSpace(v)
		if !ok || k == "" || v == "" {
			continue
		}
		t := c.Tasks[k]
		t.Model, t.Provider = v, ""
		c.Tasks[k] = t
	}
}

// ProviderOf — провайдер модели по имени.
func ProviderOf(model string) string {
	if strings.HasPrefix(model, "gemini") {
		return ProviderGemini
	}
	return ProviderAnthropic
}

// Task — настройки задачи (неизвестная — Haiku-уровень по задаче short).
func (c *Config) Task(task string) TaskCfg {
	t, ok := c.Tasks[task]
	if !ok || t.Model == "" {
		t = c.Tasks["short"]
		if t.Model == "" {
			t.Model = "claude-haiku-5-5"
		}
	}
	if t.Provider == "" {
		t.Provider = ProviderOf(t.Model)
	}
	return t
}

// PriceOf — цена модели на момент at; неизвестная модель — по похожей (с запасом).
func (c *Config) PriceOf(model string, at time.Time) Price {
	p, ok := c.Prices[model]
	if !ok {
		p = c.similar(model)
	}
	day := at.UTC().Format("2006-01-02")
	for _, ch := range p.Changes { // по возрастанию дат
		if ch.From != "" && day >= ch.From {
			p.In, p.Out, p.CacheRead = ch.In, ch.Out, ch.CacheRead
			if ch.CacheWrite > 0 {
				p.CacheWrite = ch.CacheWrite
			}
		}
	}
	return p
}

// similar — цена близкой модели: по семейству в имени (fable/opus/sonnet/haiku/gemini flash/pro), иначе самая дорогая.
func (c *Config) similar(model string) Price {
	keys := make([]string, 0, len(c.Prices))
	for k := range c.Prices {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	for _, fam := range []string{"fable", "mythos", "opus", "sonnet", "haiku", "flash-lite", "flash", "pro", "argon"} {
		if !strings.Contains(model, fam) {
			continue
		}
		best := Price{}
		for _, k := range keys {
			if strings.Contains(k, fam) && c.Prices[k].In > best.In {
				best = c.Prices[k]
			}
		}
		if best.In > 0 {
			return best
		}
	}
	best := Price{In: 10, Out: 50}
	for _, k := range keys {
		if c.Prices[k].In > best.In {
			best = c.Prices[k]
		}
	}
	return best
}

// Cost — стоимость вызова, USD.
func (c *Config) Cost(provider, model string, u Usage, at time.Time) float64 {
	p := c.PriceOf(model, at)
	in, out, cr, cw := p.In, p.Out, p.CacheRead, p.CacheWrite
	if p.LongAbove > 0 && u.InputTokens+u.CacheReadTokens+u.CacheWriteTokens > p.LongAbove {
		in, out = p.LongIn, p.LongOut
		cr, cw = p.LongCacheRead, p.LongCacheWrite
	}
	if cr == 0 {
		cr = in * 0.1
	}
	if cw == 0 && provider != ProviderGemini {
		cw = in * 1.25
	}
	usd := (float64(u.InputTokens)*in + float64(u.OutputTokens)*out +
		float64(u.CacheReadTokens)*cr + float64(u.CacheWriteTokens)*cw) / 1e6
	if u.WebSearches > 0 {
		usd += float64(u.WebSearches) * c.WebSearchUSD[provider]
	}
	return usd
}

// DefaultFile — вшитый ai.yaml (для aibench apply, если файла на диске ещё нет).
func DefaultFile() []byte {
	b, _ := defaults.FS.ReadFile("ai.yaml")
	return b
}
