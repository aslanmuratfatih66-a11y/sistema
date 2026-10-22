// Package vision — анализ фото (SPEC §5, §9.4): тело, кожа, еда («купил/приготовил», веб-поиск КБЖУ с кэшем), чеки.
// Всё — с пометкой «оценка» ("estimate": true). ИИ — только через ai.Client.
package vision

import (
	"context"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

// maxBody — тело запроса (base64 JPEG ≤1600px); общий лимит сервера тоже 4 МБ.
const maxBody = 4 << 20

// foodCacheTTL — сколько живёт найденное КБЖУ в ai_cache.
const foodCacheTTL = 180 * 24 * time.Hour

type Handler struct {
	db     *sql.DB
	ai     ai.Client
	logger *slog.Logger
}

func New(db *sql.DB, client ai.Client, logger *slog.Logger) *Handler {
	return &Handler{db: db, ai: client, logger: logger}
}

// Register — маршруты /api/v1/vision/... (лимит тела — общий 4 МБ: клиент шлёт JPEG ≤1600px).
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	mux.Handle("POST /api/v1/vision/body", require(http.HandlerFunc(h.body)))
	mux.Handle("POST /api/v1/vision/skin", require(http.HandlerFunc(h.skin)))
	mux.Handle("POST /api/v1/vision/food", require(http.HandlerFunc(h.food)))
	mux.Handle("POST /api/v1/vision/food/lookup", require(http.HandlerFunc(h.foodLookup)))
	mux.Handle("POST /api/v1/vision/food/estimate", require(http.HandlerFunc(h.foodEstimate)))
	mux.Handle("POST /api/v1/vision/receipt", require(http.HandlerFunc(h.receipt)))
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

// begin проверяет пользователя и читает JSON-тело.
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

// decodeImage — base64 (допускается data:URL) → ai.Image.
func decodeImage(s string) (*ai.Image, error) {
	s = strings.TrimSpace(s)
	if i := strings.Index(s, ","); strings.HasPrefix(s, "data:") && i > 0 {
		s = s[i+1:]
	}
	data, err := base64.StdEncoding.DecodeString(s)
	if err != nil || len(data) < 16 {
		return nil, errors.New("bad image")
	}
	return &ai.Image{MediaType: http.DetectContentType(data), Data: data}, nil
}

func (h *Handler) image(w http.ResponseWriter, s string) (*ai.Image, bool) {
	img, err := decodeImage(s)
	if err != nil {
		writeErr(w, http.StatusBadRequest, "bad image")
		return nil, false
	}
	switch img.MediaType {
	case "image/jpeg", "image/png", "image/webp":
		return img, true
	}
	writeErr(w, http.StatusBadRequest, "bad image")
	return nil, false
}

// aiFail переводит ошибку ИИ в ответ клиенту.
func (h *Handler) aiFail(w http.ResponseWriter, op string, err error) {
	switch {
	case errors.Is(err, ai.ErrBudget):
		writeErr(w, http.StatusPaymentRequired, "ai_budget")
	case errors.Is(err, ai.ErrUnavailable):
		writeErr(w, http.StatusServiceUnavailable, "ai_unavailable")
	default:
		h.logger.Warn("vision: ai", "op", op, "err", err)
		writeErr(w, http.StatusBadGateway, "ai_failed")
	}
}

func langName(lang string) string {
	if strings.HasPrefix(strings.ToLower(lang), "tr") {
		return "Turkish"
	}
	return "Russian"
}

// commonRules — общие правила для всех промптов (безопасные формулировки, только JSON).
const commonRules = `You are the photo analysis module of a personal self-improvement app.
Rules:
- Reply with ONE JSON object only, no markdown, no comments.
- Every number is an estimate from a photo; prefer honest ranges over false precision.
- Be neutral, kind and factual. Never judge attractiveness, never use insulting or shaming words, no diagnoses.
- If the photo does not show what is asked, return the JSON with empty/neutral values and explain briefly in "notes".`

// ask вызывает модель и разбирает JSON-ответ в out.
func (h *Handler) ask(ctx context.Context, uid string, task ai.Task, system, prompt string, img *ai.Image, web bool, maxTokens int, out any) error {
	parts := []ai.Part{}
	if img != nil {
		parts = append(parts, ai.Part{Image: img})
	}
	parts = append(parts, ai.Part{Text: prompt})
	req := ai.Request{
		System:    []ai.SystemBlock{{Text: commonRules, Cache: true}, {Text: system}},
		Messages:  []ai.Message{{Role: ai.RoleUser, Parts: parts}},
		MaxTokens: maxTokens,
		// С веб-поиском структурированный вывод у провайдеров часто недоступен — JSON просим текстом.
		JSON:      !web,
		WebSearch: web,
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

// extractJSON — первый JSON-объект в тексте (модель могла обернуть его в ``` или пояснения).
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

func clamp(v, lo, hi float64) float64 {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

func oneOf(v string, allowed ...string) string {
	v = strings.ToLower(strings.TrimSpace(v))
	for _, a := range allowed {
		if v == a {
			return v
		}
	}
	return allowed[0]
}

// ---------- тело ----------

type bodyReq struct {
	Image    string `json:"image"`
	Lang     string `json:"lang"`
	Previous []struct {
		At      string `json:"at"`
		Summary string `json:"summary"`
	} `json:"previous"`
}

type rangeF struct {
	Min float64 `json:"min"`
	Max float64 `json:"max"`
}

type bodyResp struct {
	Estimate   bool     `json:"estimate"`
	BodyFatPct rangeF   `json:"body_fat_pct"`
	Muscle     string   `json:"muscle"`
	Posture    []string `json:"posture"`
	Swelling   string   `json:"swelling"`
	Notes      string   `json:"notes"`
	Comparison string   `json:"comparison,omitempty"`
}

func (h *Handler) body(w http.ResponseWriter, r *http.Request) {
	var req bodyReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	img, ok := h.image(w, req.Image)
	if !ok {
		return
	}
	system := `Task: estimate body composition from a body photo (front/side, fitted clothes or underwear).
JSON schema:
{"body_fat_pct":{"min":number,"max":number},"muscle":"low|medium|high","posture":[string],"swelling":"none|mild|noticeable","notes":string,"comparison":string}
- body_fat_pct: a plausible range, width 3–6 percentage points.
- posture: short neutral observations (e.g. "shoulders slightly forward"), empty array if nothing notable.
- swelling: visible puffiness/water retention (face, legs), "none" if unclear.
- notes: 1–3 supportive sentences with practical focus (training, sleep, salt/water), no judgement of looks.
- comparison: only if previous results are given — what changed, cautiously (lighting/pose differ); else "".
All texts in ` + langName(req.Lang) + `.`
	prompt := "Analyze this photo."
	if len(req.Previous) > 0 {
		var b strings.Builder
		b.WriteString("Previous results (oldest first):\n")
		for i, p := range req.Previous {
			if i >= 5 {
				break
			}
			b.WriteString("- " + p.At + ": " + p.Summary + "\n")
		}
		prompt = b.String() + prompt + " Compare with previous results."
	}
	var out bodyResp
	if err := h.ask(r.Context(), uid, ai.TaskBodyVision, system, prompt, img, false, 800, &out); err != nil {
		h.aiFail(w, "body", err)
		return
	}
	out.Estimate = true
	out.BodyFatPct.Min = clamp(out.BodyFatPct.Min, 3, 60)
	out.BodyFatPct.Max = clamp(out.BodyFatPct.Max, out.BodyFatPct.Min, 60)
	out.Muscle = oneOf(out.Muscle, "medium", "low", "high")
	out.Swelling = oneOf(out.Swelling, "none", "mild", "noticeable")
	if out.Posture == nil {
		out.Posture = []string{}
	}
	if len(req.Previous) == 0 {
		out.Comparison = ""
	}
	writeJSON(w, http.StatusOK, out)
}

// ---------- кожа ----------

type imgReq struct {
	Image string `json:"image"`
	Lang  string `json:"lang"`
}

type skinResp struct {
	Estimate bool   `json:"estimate"`
	SkinType string `json:"skin_type"`
	Acne     struct {
		Score float64 `json:"score"`
		Label string  `json:"label"`
	} `json:"acne"`
	Notes string `json:"notes"`
}

func (h *Handler) skin(w http.ResponseWriter, r *http.Request) {
	var req imgReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	img, ok := h.image(w, req.Image)
	if !ok {
		return
	}
	system := `Task: estimate facial skin condition from a face photo (cosmetic, not medical).
JSON schema:
{"skin_type":"dry|normal|oily|combination|sensitive","acne":{"score":number,"label":string},"notes":string}
- acne.score: 0 (clear) … 10 (many active inflammations); label: 1–3 neutral words.
- notes: 1–3 sentences with gentle care tips; suggest a dermatologist only for clearly severe cases.
Texts (label, notes) in ` + langName(req.Lang) + `.`
	var out skinResp
	if err := h.ask(r.Context(), uid, ai.TaskBodyVision, system, "Analyze this photo.", img, false, 500, &out); err != nil {
		h.aiFail(w, "skin", err)
		return
	}
	out.Estimate = true
	out.SkinType = oneOf(out.SkinType, "normal", "dry", "oily", "combination", "sensitive")
	out.Acne.Score = clamp(out.Acne.Score, 0, 10)
	writeJSON(w, http.StatusOK, out)
}

// ---------- еда: распознавание ----------

type foodItem struct {
	Name     string  `json:"name"`
	GramsEst float64 `json:"grams_est"`
}

type foodResp struct {
	Estimate    bool       `json:"estimate"`
	Items       []foodItem `json:"items"`
	Description string     `json:"description"`
	Question    string     `json:"question"`
}

func (h *Handler) food(w http.ResponseWriter, r *http.Request) {
	var req imgReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	img, ok := h.image(w, req.Image)
	if !ok {
		return
	}
	system := `Task: recognize food on the photo.
JSON schema:
{"items":[{"name":string,"grams_est":number}],"description":string}
- items: each distinct dish/product with an estimated portion weight in grams; branded packaged product — keep the brand in the name.
- description: one short sentence about what is on the photo.
Texts in ` + langName(req.Lang) + `.`
	var out foodResp
	if err := h.ask(r.Context(), uid, ai.TaskFoodVision, system, "What food is on this photo?", img, false, 600, &out); err != nil {
		h.aiFail(w, "food", err)
		return
	}
	out.Estimate = true
	out.Question = "bought_or_cooked"
	items := out.Items[:0]
	for _, it := range out.Items {
		it.Name = strings.TrimSpace(it.Name)
		if it.Name == "" {
			continue
		}
		it.GramsEst = clamp(it.GramsEst, 0, 5000)
		items = append(items, it)
	}
	if items == nil {
		items = []foodItem{}
	}
	out.Items = items
	writeJSON(w, http.StatusOK, out)
}

// ---------- еда: поиск КБЖУ купленного ----------

type nutr struct {
	Kcal    float64 `json:"kcal"`
	Protein float64 `json:"protein"`
	Fat     float64 `json:"fat"`
	Carbs   float64 `json:"carbs"`
}

type source struct {
	Title string `json:"title"`
	URL   string `json:"url"`
}

type lookupResp struct {
	Estimate bool   `json:"estimate"`
	Name     string `json:"name"`
	Per100   nutr   `json:"per100"`
	Serving  *struct {
		Grams float64 `json:"grams"`
		Label string  `json:"label,omitempty"`
	} `json:"serving,omitempty"`
	Source source `json:"source"`
	Cached bool   `json:"cached"`
}

type lookupReq struct {
	Name  string `json:"name"`
	Place string `json:"place"`
	Lang  string `json:"lang"`
}

func normKey(s string) string {
	return strings.Join(strings.Fields(strings.ToLower(s)), " ")
}

func (h *Handler) foodLookup(w http.ResponseWriter, r *http.Request) {
	var req lookupReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" || len(req.Name) > 200 || len(req.Place) > 200 {
		writeErr(w, http.StatusBadRequest, "bad name")
		return
	}
	key := normKey(req.Name) + "|" + normKey(req.Place)
	ctx := r.Context()

	var val string
	var at int64
	err := h.db.QueryRowContext(ctx, `SELECT value, at FROM ai_cache WHERE kind='food' AND key=?`, key).Scan(&val, &at)
	if err == nil && time.Since(time.Unix(at, 0)) < foodCacheTTL {
		var out lookupResp
		if json.Unmarshal([]byte(val), &out) == nil {
			out.Estimate, out.Cached = true, true
			writeJSON(w, http.StatusOK, out)
			return
		}
	} else if err != nil && !errors.Is(err, sql.ErrNoRows) {
		h.logger.Warn("vision: cache read", "err", err)
	}

	system := `Task: find nutrition facts (per 100 g) of a bought dish or packaged product using web search.
Prefer: the seller's/manufacturer's own page, then the menu of the named place, then reliable nutrition databases.
JSON schema:
{"name":string,"per100":{"kcal":number,"protein":number,"fat":number,"carbs":number},"serving":{"grams":number,"label":string}|null,"source":{"title":string,"url":string}}
- serving: typical portion/package of this product if known, else null.
- source: the page the numbers come from; if nothing reliable was found, give typical values for this kind of dish with source title "typical values" and empty url.
Name and serving label in ` + langName(req.Lang) + `.`
	prompt := "Product/dish: " + req.Name
	if strings.TrimSpace(req.Place) != "" {
		prompt += "\nBought at: " + strings.TrimSpace(req.Place)
	}
	var out lookupResp
	if err := h.ask(ctx, uid, ai.TaskShort, system, prompt, nil, true, 1200, &out); err != nil {
		h.aiFail(w, "food_lookup", err)
		return
	}
	if strings.TrimSpace(out.Name) == "" {
		out.Name = req.Name
	}
	out.Per100 = clampNutr(out.Per100, 100)
	if out.Serving != nil && out.Serving.Grams <= 0 {
		out.Serving = nil
	}
	out.Estimate, out.Cached = true, false
	if b, err := json.Marshal(out); err == nil {
		if _, err := h.db.ExecContext(ctx,
			`INSERT INTO ai_cache(kind, key, value, source, at) VALUES('food', ?, ?, ?, ?)
			 ON CONFLICT(kind, key) DO UPDATE SET value=excluded.value, source=excluded.source, at=excluded.at`,
			key, string(b), out.Source.URL, time.Now().Unix()); err != nil {
			h.logger.Warn("vision: cache write", "err", err)
		}
	}
	writeJSON(w, http.StatusOK, out)
}

// clampNutr ограничивает значения на grams граммов разумными пределами.
func clampNutr(n nutr, grams float64) nutr {
	k := grams / 100
	return nutr{
		Kcal:    clamp(n.Kcal, 0, 900*k),
		Protein: clamp(n.Protein, 0, 100*k),
		Fat:     clamp(n.Fat, 0, 100*k),
		Carbs:   clamp(n.Carbs, 0, 100*k),
	}
}

// ---------- еда: «приготовил» ----------

type estItem struct {
	Name  string  `json:"name"`
	Grams float64 `json:"grams"`
	nutr
}

type estimateReq struct {
	Image string `json:"image"`
	Items []struct {
		Name  string  `json:"name"`
		Grams float64 `json:"grams"`
	} `json:"items"`
	Lang string `json:"lang"`
}

type estimateResp struct {
	Estimate bool      `json:"estimate"`
	Items    []estItem `json:"items"`
	Total    nutr      `json:"total"`
}

func (h *Handler) foodEstimate(w http.ResponseWriter, r *http.Request) {
	var req estimateReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	var img *ai.Image
	if req.Image != "" {
		if img, ok = h.image(w, req.Image); !ok {
			return
		}
	}
	if len(req.Items) == 0 && img == nil {
		writeErr(w, http.StatusBadRequest, "no items")
		return
	}
	if len(req.Items) > 40 {
		writeErr(w, http.StatusBadRequest, "too many items")
		return
	}
	system := `Task: estimate calories and macros of a home-cooked meal. The user listed ingredients/dishes with grams (trust the grams); the photo, if given, helps to judge cooking method and oil.
JSON schema:
{"items":[{"name":string,"grams":number,"kcal":number,"protein":number,"fat":number,"carbs":number}]}
- values are for the given grams of each item (not per 100 g); keep the user's items and grams in the same order.
- if no items are given, recognize them from the photo with estimated grams.
Names in ` + langName(req.Lang) + `.`
	var b strings.Builder
	b.WriteString("Items:\n")
	for _, it := range req.Items {
		b.WriteString("- " + strings.TrimSpace(it.Name) + ": ")
		b.WriteString(jsonNum(it.Grams) + " g\n")
	}
	var out estimateResp
	if err := h.ask(r.Context(), uid, ai.TaskFoodVision, system, b.String(), img, false, 1200, &out); err != nil {
		h.aiFail(w, "food_estimate", err)
		return
	}
	out.Estimate = true
	out.Total = nutr{}
	items := make([]estItem, 0, len(out.Items))
	for i, it := range out.Items {
		// Граммы — пользовательские, если модель вернула те же позиции.
		if i < len(req.Items) && len(out.Items) == len(req.Items) && req.Items[i].Grams > 0 {
			it.Grams = req.Items[i].Grams
		}
		it.Grams = clamp(it.Grams, 0, 5000)
		it.nutr = clampNutr(it.nutr, it.Grams)
		out.Total.Kcal += it.Kcal
		out.Total.Protein += it.Protein
		out.Total.Fat += it.Fat
		out.Total.Carbs += it.Carbs
		items = append(items, it)
	}
	out.Items = items
	writeJSON(w, http.StatusOK, out)
}

func jsonNum(f float64) string {
	b, _ := json.Marshal(f)
	return string(b)
}

// ---------- чек ----------

type receiptItem struct {
	Name  string  `json:"name"`
	Qty   float64 `json:"qty"`
	Price float64 `json:"price"`
}

type receiptResp struct {
	Estimate bool          `json:"estimate"`
	Store    string        `json:"store"`
	Date     string        `json:"date,omitempty"`
	Currency string        `json:"currency"`
	Items    []receiptItem `json:"items"`
	Total    float64       `json:"total"`
}

func (h *Handler) receipt(w http.ResponseWriter, r *http.Request) {
	var req imgReq
	uid, ok := begin(w, r, &req)
	if !ok {
		return
	}
	img, ok := h.image(w, req.Image)
	if !ok {
		return
	}
	system := `Task: read a shop receipt from the photo.
JSON schema:
{"store":string,"date":"YYYY-MM-DD"|"","currency":"RUB|TRY|USD|EUR|…","items":[{"name":string,"qty":number,"price":number}],"total":number}
- price: line total for the item (qty × unit price, after line discounts), in receipt currency units (not cents).
- total: the receipt total as printed; currency as ISO 4217 code.
- keep item names as printed (fix obvious OCR noise only).`
	var out receiptResp
	if err := h.ask(r.Context(), uid, ai.TaskFoodVision, system, "Read this receipt.", img, false, 2000, &out); err != nil {
		h.aiFail(w, "receipt", err)
		return
	}
	out.Estimate = true
	out.Currency = strings.ToUpper(strings.TrimSpace(out.Currency))
	if len(out.Currency) != 3 {
		out.Currency = "RUB"
	}
	if _, err := time.Parse("2006-01-02", out.Date); err != nil {
		out.Date = ""
	}
	if out.Items == nil {
		out.Items = []receiptItem{}
	}
	var sum float64
	for i := range out.Items {
		if out.Items[i].Qty <= 0 {
			out.Items[i].Qty = 1
		}
		sum += out.Items[i].Price
	}
	if out.Total <= 0 {
		out.Total = sum
	}
	writeJSON(w, http.StatusOK, out)
}
