// Package market — маркет покупок (SPEC §8.8): ИИ подбирает товары под план (уход за кожей, питание, инвентарь),
// примерная цена через веб-поиск (ai.Request.WebSearch) с датой и источником, ссылки/поиск на Ozon, Wildberries,
// Яндекс Маркет, Пятёрочку (RU), Trendyol (TR). Пометку «по бюджету» ставит клиент (финансы локальные).
// ИИ — через ai.Client. Кэш цен — ai_cache (kind 'market_price', ~3 дня).
//
// Эндпоинты (под authSvc.Require, JSON; цена — целое в мин. единицах):
//
//	POST /api/v1/market/suggest {"lang","country":"RU|TR","category":"skin|nutrition|equipment|other|",
//	                             "context":{"plan":…,"skin":…,"goals":…,"budget_rub":…},"exclude":[названия]}
//	     → {"items":[{"title","category","reason","price","currency","price_source","price_at":<unix>,
//	                  "links":[{"store","url","search":bool}]}]}
//	POST /api/v1/market/price   {"title","country"} → {"price","currency","price_source","price_at","url"}
//
// Ссылки поиска строит сервер по известным URL поиска магазинов; прямые ссылки на товар — только если их
// вернул веб-поиск модели и домен принадлежит магазину из списка.
package market

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"log/slog"
	"math"
	"net/http"
	"net/url"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

const (
	maxBody       = 64 << 10
	maxContext    = 12 << 10 // байт JSON контекста, отдаваемого модели
	maxExclude    = 60
	maxItems      = 8
	priceCacheTTL = 3 * 24 * time.Hour
	cacheKind     = "market_price"
	aiTimeout     = 120 * time.Second
)

type Handler struct {
	db     *sql.DB
	ai     ai.Client
	logger *slog.Logger

	suggestLimit *limiter
	priceLimit   *limiter
}

func New(db *sql.DB, client ai.Client, logger *slog.Logger) *Handler {
	return &Handler{
		db: db, ai: client, logger: logger,
		suggestLimit: newLimiter(10, time.Hour),
		priceLimit:   newLimiter(30, time.Hour),
	}
}

// Register — маршруты /api/v1/market/...
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	mux.Handle("POST /api/v1/market/suggest", require(http.HandlerFunc(h.suggest)))
	mux.Handle("POST /api/v1/market/price", require(http.HandlerFunc(h.price)))
}

// ---------- общие помощники ----------

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeErr(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}

func begin(w http.ResponseWriter, r *http.Request, dst any) (string, bool) {
	uid := authctx.UserID(r.Context())
	if uid == "" {
		writeErr(w, http.StatusUnauthorized, "unauthorized")
		return "", false
	}
	if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, maxBody)).Decode(dst); err != nil {
		var mbe *http.MaxBytesError
		if errors.As(err, &mbe) {
			writeErr(w, http.StatusRequestEntityTooLarge, "request body too large")
		} else {
			writeErr(w, http.StatusBadRequest, "bad json")
		}
		return "", false
	}
	return uid, true
}

func (h *Handler) rateOK(w http.ResponseWriter, l *limiter, uid string) bool {
	if ok, _ := l.allow(uid, time.Now()); ok {
		return true
	}
	writeErr(w, http.StatusTooManyRequests, "rate_limited")
	return false
}

func (h *Handler) aiFail(w http.ResponseWriter, op string, err error) {
	switch {
	case errors.Is(err, ai.ErrBudget):
		writeErr(w, http.StatusPaymentRequired, "ai_budget")
	case errors.Is(err, ai.ErrUnavailable):
		writeErr(w, http.StatusServiceUnavailable, "ai_unavailable")
	default:
		h.logger.Warn("market: ai", "op", op, "err", err)
		writeErr(w, http.StatusBadGateway, "ai_failed")
	}
}

func normCountry(c string) string {
	if strings.EqualFold(strings.TrimSpace(c), "TR") {
		return "TR"
	}
	return "RU"
}

func langName(lang string) string {
	if strings.HasPrefix(strings.ToLower(lang), "tr") {
		return "Turkish"
	}
	return "Russian"
}

func clip(s string, n int) string {
	s = strings.TrimSpace(s)
	if utf8.RuneCountInString(s) <= n {
		return s
	}
	return strings.TrimSpace(string([]rune(s)[:n]))
}

func normKey(s string) string {
	return strings.Join(strings.Fields(strings.ToLower(s)), " ")
}

func normCategory(c string) string {
	switch strings.ToLower(strings.TrimSpace(c)) {
	case "skin", "nutrition", "equipment":
		return strings.ToLower(strings.TrimSpace(c))
	}
	return "other"
}

func normCurrency(c, country string) string {
	switch strings.ToUpper(strings.TrimSpace(c)) {
	case "RUB", "TRY", "USD", "EUR":
		return strings.ToUpper(strings.TrimSpace(c))
	}
	if country == "TR" {
		return "TRY"
	}
	return "RUB"
}

// toMinor — цена в основных единицах (модель) → целое в минимальных; 0 — неизвестно.
func toMinor(p float64) int64 {
	if math.IsNaN(p) || math.IsInf(p, 0) || p <= 0 || p > 10_000_000 {
		return 0
	}
	return int64(math.Round(p * 100))
}

// ask вызывает модель с веб-поиском и разбирает JSON-ответ.
func (h *Handler) ask(ctx context.Context, uid string, task ai.Task, system, prompt string, maxTokens int, out any) error {
	ctx, cancel := context.WithTimeout(ctx, aiTimeout)
	defer cancel()
	req := ai.Request{
		System:    []ai.SystemBlock{{Text: commonRules, Cache: true}, {Text: system}},
		Messages:  []ai.Message{{Role: ai.RoleUser, Parts: []ai.Part{{Text: prompt}}}},
		MaxTokens: maxTokens,
		// С веб-поиском структурированный вывод у провайдеров часто недоступен — JSON просим текстом.
		WebSearch: true,
	}
	resp, err := h.ai.Do(ctx, uid, task, req)
	if err != nil {
		return err
	}
	raw := extractJSON(resp.Text)
	if raw == "" {
		return errors.New("no json in model reply")
	}
	return json.Unmarshal([]byte(raw), out)
}

// extractJSON — первый JSON-объект в тексте.
func extractJSON(s string) string {
	start := strings.Index(s, "{")
	if start < 0 {
		return ""
	}
	depth, inStr, esc := 0, false, false
	for i := start; i < len(s); i++ {
		c := s[i]
		switch {
		case esc:
			esc = false
		case c == '\\' && inStr:
			esc = true
		case c == '"':
			inStr = !inStr
		case inStr:
		case c == '{':
			depth++
		case c == '}':
			depth--
			if depth == 0 {
				return s[start : i+1]
			}
		}
	}
	return ""
}

const commonRules = `You are the shopping module of a personal self-improvement app.
Rules:
- Reply with ONE JSON object only, no markdown, no comments.
- Use web search to check real products and current approximate prices in the user's country.
- Prices are approximate retail prices in major currency units (e.g. 1290 for 1 290 RUB), never invent precision.
- Product URLs only if you actually found them in search results; otherwise leave "url" empty.
- Safe, mainstream products only: no medicines that need a prescription, no supplements with doubtful claims.`

// ---------- ссылки ----------

type link struct {
	Store  string `json:"store"`
	URL    string `json:"url"`
	Search bool   `json:"search"`
}

// storeHosts — домены магазинов, которым доверяем прямые ссылки.
var storeHosts = []struct{ store, host string }{
	{"ozon", "ozon.ru"},
	{"wildberries", "wildberries.ru"},
	{"wildberries", "wb.ru"},
	{"yandex_market", "market.yandex.ru"},
	{"pyaterochka", "5ka.ru"},
	{"trendyol", "trendyol.com"},
}

func storeOf(raw string) string {
	u, err := url.Parse(strings.TrimSpace(raw))
	if err != nil || u.Scheme != "https" || u.Host == "" {
		return ""
	}
	host := strings.ToLower(u.Hostname())
	for _, s := range storeHosts {
		if host == s.host || strings.HasSuffix(host, "."+s.host) {
			return s.store
		}
	}
	return ""
}

// searchLinks — страницы поиска магазинов страны по запросу.
func searchLinks(country, category, query string) []link {
	q := url.QueryEscape(query)
	if country == "TR" {
		return []link{{Store: "trendyol", URL: "https://www.trendyol.com/sr?q=" + q, Search: true}}
	}
	out := []link{
		{Store: "ozon", URL: "https://www.ozon.ru/search/?text=" + q, Search: true},
		{Store: "wildberries", URL: "https://www.wildberries.ru/catalog/0/search.aspx?search=" + q, Search: true},
		{Store: "yandex_market", URL: "https://market.yandex.ru/search?text=" + q, Search: true},
	}
	if category == "nutrition" || category == "skin" || category == "other" {
		// Точный формат поиска на сайте Пятёрочки не подтверждён — поиск через Яндекс по сайту.
		out = append(out, link{Store: "pyaterochka",
			URL: "https://yandex.ru/search/?text=" + url.QueryEscape(query+" site:5ka.ru"), Search: true})
	}
	return out
}

// mergeLinks — прямые ссылки (если домен из списка) впереди поисковых, без дублей по магазину.
func mergeLinks(direct []string, search []link) []link {
	out := make([]link, 0, len(search)+len(direct))
	seen := map[string]bool{}
	for _, d := range direct {
		st := storeOf(d)
		if st == "" || seen[st] {
			continue
		}
		seen[st] = true
		out = append(out, link{Store: st, URL: strings.TrimSpace(d)})
	}
	for _, s := range search {
		if seen[s.Store] {
			continue
		}
		out = append(out, s)
	}
	return out
}

// ---------- кэш цен ----------

type priceResp struct {
	Price       int64  `json:"price"`
	Currency    string `json:"currency"`
	PriceSource string `json:"price_source"`
	PriceAt     int64  `json:"price_at"`
	URL         string `json:"url"`
	Cached      bool   `json:"cached,omitempty"`
}

func priceKey(country, title string) string { return country + "|" + normKey(title) }

func (h *Handler) cachedPrice(ctx context.Context, key string) (priceResp, bool) {
	var val string
	var at int64
	err := h.db.QueryRowContext(ctx, `SELECT value, at FROM ai_cache WHERE kind=? AND key=?`, cacheKind, key).Scan(&val, &at)
	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) {
			h.logger.Warn("market: cache read", "err", err)
		}
		return priceResp{}, false
	}
	if time.Since(time.Unix(at, 0)) >= priceCacheTTL {
		return priceResp{}, false
	}
	var out priceResp
	if json.Unmarshal([]byte(val), &out) != nil || out.Price <= 0 {
		return priceResp{}, false
	}
	out.Cached = true
	return out, true
}

func (h *Handler) storePrice(ctx context.Context, key string, p priceResp) {
	if p.Price <= 0 {
		return
	}
	p.Cached = false
	b, err := json.Marshal(p)
	if err != nil {
		return
	}
	if _, err := h.db.ExecContext(ctx,
		`INSERT INTO ai_cache(kind, key, value, source, at) VALUES(?, ?, ?, ?, ?)
		 ON CONFLICT(kind, key) DO UPDATE SET value=excluded.value, source=excluded.source, at=excluded.at`,
		cacheKind, key, string(b), p.PriceSource, p.PriceAt); err != nil {
		h.logger.Warn("market: cache write", "err", err)
	}
}

// ---------- suggest ----------

type suggestReq struct {
	Lang     string          `json:"lang"`
	Country  string          `json:"country"`
	Category string          `json:"category"`
	Context  json.RawMessage `json:"context"`
	Exclude  []string        `json:"exclude"`
}

type modelItem struct {
	Title       string   `json:"title"`
	Category    string   `json:"category"`
	Reason      string   `json:"reason"`
	Query       string   `json:"query"`
	Price       float64  `json:"price"`
	Currency    string   `json:"currency"`
	PriceSource string   `json:"price_source"`
	URLs        []string `json:"urls"`
}

type item struct {
	Title       string `json:"title"`
	Category    string `json:"category"`
	Reason      string `json:"reason"`
	Price       int64  `json:"price"`
	Currency    string `json:"currency"`
	PriceSource string `json:"price_source"`
	PriceAt     int64  `json:"price_at"`
	Links       []link `json:"links"`
}

func (h *Handler) suggest(w http.ResponseWriter, r *http.Request) {
	var req suggestReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	if len(req.Context) > maxContext {
		writeErr(w, http.StatusRequestEntityTooLarge, "context too large")
		return
	}
	if !h.rateOK(w, h.suggestLimit, uid) {
		return
	}
	country := normCountry(req.Country)
	category := strings.ToLower(strings.TrimSpace(req.Category))
	if category != "" {
		category = normCategory(category)
	}
	stores := "Ozon, Wildberries, Yandex Market, Pyaterochka (groceries)"
	currency := "RUB"
	if country == "TR" {
		stores, currency = "Trendyol", "TRY"
	}
	catRule := "Cover the categories that the plan needs: skin (skin care), nutrition (food/groceries for the meal plan), equipment (home training gear), other."
	if category != "" {
		catRule = "Only category \"" + category + "\"."
	}
	system := `Task: pick products the user should buy to follow their self-improvement plan (skin care routine, meal plan, home training).
Country: ` + country + `. Stores: ` + stores + `. Currency: ` + currency + `.
JSON schema:
{"items":[{"title":string,"category":"skin|nutrition|equipment|other","reason":string,"query":string,"price":number,"currency":"` + currency + `","price_source":string,"urls":[string]}]}
- 3–` + itoa(maxItems) + ` items, most useful first. ` + catRule + `
- title: concrete product (brand + product + size) available in the country.
- reason: one short sentence — which part of the plan it serves (e.g. "evening routine: gentle cleanser for oily skin").
- query: short search query for store search (brand + product).
- price: typical current price in ` + currency + ` found via search; 0 if unknown.
- price_source: where the price was seen (store or site name).
- urls: direct product page URLs on the listed stores, only if found in search; else [].
- Respect the user's budget if given; prefer affordable options.
- Do not repeat excluded products.
Texts (title, reason) in ` + langName(req.Lang) + `.`

	var b strings.Builder
	if len(req.Context) > 0 && string(req.Context) != "null" {
		b.WriteString("User context (plan, skin, goals, budget):\n")
		b.Write(req.Context)
		b.WriteString("\n")
	}
	if len(req.Exclude) > 0 {
		b.WriteString("Exclude (already have or rejected):\n")
		for i, e := range req.Exclude {
			if i >= maxExclude {
				break
			}
			if e = clip(e, 120); e != "" {
				b.WriteString("- " + e + "\n")
			}
		}
	}
	b.WriteString("Suggest products.")

	var out struct {
		Items []modelItem `json:"items"`
	}
	if err := h.ask(r.Context(), uid, ai.TaskAnalysis, system, b.String(), 3000, &out); err != nil {
		h.aiFail(w, "suggest", err)
		return
	}
	now := time.Now().Unix()
	excluded := map[string]bool{}
	for _, e := range req.Exclude {
		excluded[normKey(e)] = true
	}
	items := make([]item, 0, len(out.Items))
	for _, m := range out.Items {
		if len(items) >= maxItems {
			break
		}
		title := clip(m.Title, 160)
		if title == "" || excluded[normKey(title)] {
			continue
		}
		cat := normCategory(m.Category)
		if category != "" {
			cat = category
		}
		query := clip(m.Query, 120)
		if query == "" {
			query = title
		}
		it := item{
			Title:       title,
			Category:    cat,
			Reason:      clip(m.Reason, 300),
			Price:       toMinor(m.Price),
			Currency:    normCurrency(m.Currency, country),
			PriceSource: clip(m.PriceSource, 80),
			Links:       mergeLinks(m.URLs, searchLinks(country, cat, query)),
		}
		if it.Price > 0 {
			it.PriceAt = now
			direct := ""
			if len(it.Links) > 0 && !it.Links[0].Search {
				direct = it.Links[0].URL
			}
			h.storePrice(r.Context(), priceKey(country, title),
				priceResp{Price: it.Price, Currency: it.Currency, PriceSource: it.PriceSource, PriceAt: now, URL: direct})
		} else {
			it.PriceSource = ""
		}
		items = append(items, it)
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

// ---------- price ----------

type priceReq struct {
	Title   string `json:"title"`
	Country string `json:"country"`
	Force   bool   `json:"force"`
}

func (h *Handler) price(w http.ResponseWriter, r *http.Request) {
	var req priceReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	req.Title = clip(req.Title, 160)
	if req.Title == "" {
		writeErr(w, http.StatusBadRequest, "title_required")
		return
	}
	country := normCountry(req.Country)
	key := priceKey(country, req.Title)
	if !req.Force {
		if p, ok := h.cachedPrice(r.Context(), key); ok {
			writeJSON(w, http.StatusOK, p)
			return
		}
	}
	if !h.rateOK(w, h.priceLimit, uid) {
		return
	}
	stores, currency := "Ozon, Wildberries, Yandex Market, Pyaterochka", "RUB"
	if country == "TR" {
		stores, currency = "Trendyol", "TRY"
	}
	system := `Task: find the current typical retail price of one product in country ` + country + ` using web search.
Prefer stores: ` + stores + `.
JSON schema:
{"price":number,"currency":"` + currency + `","price_source":string,"url":string}
- price in major units of ` + currency + `; 0 if nothing reliable found.
- price_source: store/site name where the price was seen.
- url: the product page on one of the preferred stores if found in search, else "".`
	var m struct {
		Price       float64 `json:"price"`
		Currency    string  `json:"currency"`
		PriceSource string  `json:"price_source"`
		URL         string  `json:"url"`
	}
	if err := h.ask(r.Context(), uid, ai.TaskShort, system, "Product: "+req.Title, 1000, &m); err != nil {
		h.aiFail(w, "price", err)
		return
	}
	out := priceResp{
		Price:       toMinor(m.Price),
		Currency:    normCurrency(m.Currency, country),
		PriceSource: clip(m.PriceSource, 80),
		PriceAt:     time.Now().Unix(),
	}
	if storeOf(m.URL) != "" {
		out.URL = strings.TrimSpace(m.URL)
	}
	if out.Price <= 0 {
		out.PriceSource, out.URL = "", ""
	}
	h.storePrice(r.Context(), key, out)
	writeJSON(w, http.StatusOK, out)
}

func itoa(n int) string {
	b, _ := json.Marshal(n)
	return string(b)
}
