// Package finance — финансы на сервере (SPEC §8.7): курсы (ЦБ РФ через jobs.fx_rates + крипта CoinGecko),
// разбор уведомлений/SMS банков дешёвой моделью, импорт выписки (CSV/PDF), чек по QR (ФНС), предложение лимитов
// и комментарий к отчёту. Сами операции живут у клиента и синхронизируются через records.
// КОНТРАКТ каркаса этапа 7; реализация — сабагент B. ИИ — через ai.Client.
//
// Эндпоинты (все под authSvc.Require, JSON; суммы — целые в мин. единицах валюты):
//
//	GET  /api/v1/finance/rates?coins=bitcoin,ethereum
//	     → {"base":"RUB","updated_at":<unix>,"rates":{"USD":95.1,"EUR":…,"TRY":…,"cg:bitcoin":…}}  (₽ за 1 единицу)
//	POST /api/v1/finance/bank/parse      {"lang","items":[{"id","sender","bank","body"}]}  (только нераспознанные шаблонами)
//	     → {"items":[{"id","ok":bool,"kind":"expense|income|transfer","amount","currency","merchant","card_last4","occurred_at"}]}
//	POST /api/v1/finance/statement       {"filename","mime":"text/csv|application/pdf","data":<base64>,"lang"}
//	     → {"rows":[{"ref","occurred_at","kind","amount","currency","description","merchant"}]}
//	POST /api/v1/finance/receipt/qr      {"qr":"t=…&s=…&fn=…&i=…&fp=…&n=1"}
//	     → {"status":"ok|unavailable","total","occurred_at","store","items":[{"name","qty","price"}]}
//	POST /api/v1/finance/budget/suggest  {"lang","days":N,"categories":[{"id","name","spent_rub":[по неделям]}],"income_rub"}
//	     → {"budgets":[{"category_id","period":"month","limit_rub","reason"}]}
//	POST /api/v1/finance/report/comment  {"lang","period":"week|month","totals":{…},"by_category":[…],"budgets":[…]}
//	     → {"comment"}
//
// Ошибки ИИ: 402 {"error":"ai_budget"}, 503 {"error":"ai_unavailable"}.
//
// Уточнения реализации: updated_at — Unix-секунды; occurred_at — локальное время без зоны
// "2006-01-02T15:04:05" (время банка/чека, клиент читает как локальное), пустая строка — неизвестно.
// Частота — токен-бакеты в памяти на пользователя, при превышении 429 {"error":"rate_limited"} + Retry-After.
package finance

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"log/slog"
	"math"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

// maxBody — тело запроса (выписка base64 ≤ ~3 МБ файла); общий лимит сервера тоже 4 МБ.
const maxBody = 4 << 20

// localTime — формат occurred_at.
const localTime = "2006-01-02T15:04:05"

type Handler struct {
	db     *sql.DB
	ai     ai.Client
	logger *slog.Logger

	http *http.Client
	// coingeckoURL — база simple/price (подменяется только в коде при отладке).
	coingeckoURL string

	cgMu       sync.Mutex
	cgFailedAt time.Time

	limRates     *limiter
	limBank      *limiter
	limStatement *limiter
	limReceipt   *limiter
	limBudget    *limiter
	limComment   *limiter
}

func New(db *sql.DB, client ai.Client, logger *slog.Logger) *Handler {
	return &Handler{
		db:           db,
		ai:           client,
		logger:       logger,
		http:         &http.Client{Timeout: 10 * time.Second},
		coingeckoURL: "https://api.coingecko.com/api/v3/simple/price",
		limRates:     newLimiter(60, time.Minute),
		limBank:      newLimiter(20, time.Minute),
		limStatement: newLimiter(10, time.Hour),
		limReceipt:   newLimiter(30, time.Minute),
		limBudget:    newLimiter(10, time.Hour),
		limComment:   newLimiter(30, time.Hour),
	}
}

// Register — маршруты /api/v1/finance/... (лимит тела — общий 4 МБ).
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/finance/rates", require(http.HandlerFunc(h.rates)))
	mux.Handle("POST /api/v1/finance/bank/parse", require(http.HandlerFunc(h.bankParse)))
	mux.Handle("POST /api/v1/finance/statement", require(http.HandlerFunc(h.statement)))
	mux.Handle("POST /api/v1/finance/receipt/qr", require(http.HandlerFunc(h.receiptQR)))
	mux.Handle("POST /api/v1/finance/budget/suggest", require(http.HandlerFunc(h.budgetSuggest)))
	mux.Handle("POST /api/v1/finance/report/comment", require(http.HandlerFunc(h.reportComment)))
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

// user — пользователь из контекста + проверка частоты.
func user(w http.ResponseWriter, r *http.Request, l *limiter) (string, bool) {
	uid := authctx.UserID(r.Context())
	if uid == "" {
		writeErr(w, http.StatusUnauthorized, "unauthorized")
		return "", false
	}
	if ok, wait := l.allow(uid, time.Now()); !ok {
		w.Header().Set("Retry-After", strconv.Itoa(int(math.Ceil(wait.Seconds()))))
		writeErr(w, http.StatusTooManyRequests, "rate_limited")
		return "", false
	}
	return uid, true
}

// begin — пользователь, частота и JSON-тело.
func begin(w http.ResponseWriter, r *http.Request, l *limiter, dst any) (string, bool) {
	uid, ok := user(w, r, l)
	if !ok {
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

// aiFail переводит ошибку ИИ в ответ клиенту.
func (h *Handler) aiFail(w http.ResponseWriter, op string, err error) {
	switch {
	case errors.Is(err, ai.ErrBudget):
		writeErr(w, http.StatusPaymentRequired, "ai_budget")
	case errors.Is(err, ai.ErrUnavailable):
		writeErr(w, http.StatusServiceUnavailable, "ai_unavailable")
	default:
		h.logger.Warn("finance: ai", "op", op, "err", err)
		writeErr(w, http.StatusBadGateway, "ai_failed")
	}
}

func langName(lang string) string {
	if strings.HasPrefix(strings.ToLower(lang), "tr") {
		return "Turkish"
	}
	return "Russian"
}

const commonRules = `You are the finance module of a personal self-improvement app.
Rules:
- Reply with ONE JSON object only, no markdown, no comments.
- Never invent transactions or numbers that are not in the input.
- Be neutral, kind and factual.`

// ask вызывает модель и разбирает JSON-ответ в out.
func (h *Handler) ask(ctx context.Context, uid string, task ai.Task, system string, parts []ai.Part, maxTokens int, out any) error {
	req := ai.Request{
		System:    []ai.SystemBlock{{Text: commonRules, Cache: true}, {Text: system}},
		Messages:  []ai.Message{{Role: ai.RoleUser, Parts: parts}},
		MaxTokens: maxTokens,
		JSON:      true,
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

// truncate — не длиннее n рун.
func truncate(s string, n int) string {
	s = strings.TrimSpace(s)
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n])
}

// minor — сумма в основных единицах → мин. единицы (×100), только конечные положительные и разумные.
func minor(v float64) (int64, bool) {
	if math.IsNaN(v) || math.IsInf(v, 0) {
		return 0, false
	}
	v = math.Abs(v)
	if v <= 0 || v > 1e11 {
		return 0, false
	}
	return int64(math.Round(v * 100)), true
}

// currency — ISO-код из 3 латинских букв (₽/TL/р. → коды).
func currency(s, def string) string {
	s = strings.ToUpper(strings.TrimSpace(s))
	switch s {
	case "₽", "Р", "Р.", "РУБ", "РУБ.", "RUR", "RUB":
		return "RUB"
	case "TL", "₺", "TRY":
		return "TRY"
	case "$", "USD":
		return "USD"
	case "€", "EUR":
		return "EUR"
	}
	if len(s) == 3 && s[0] >= 'A' && s[0] <= 'Z' && s[1] >= 'A' && s[1] <= 'Z' && s[2] >= 'A' && s[2] <= 'Z' {
		return s
	}
	return def
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

// normTime — разбор времени из ответа модели/файла в localTime; "" — не распознано.
func normTime(s string) string {
	s = strings.TrimSpace(s)
	if s == "" {
		return ""
	}
	if t, ok := parseDate(s); ok {
		return t.Format(localTime)
	}
	return ""
}

var dateLayouts = []string{
	time.RFC3339,
	"2006-01-02T15:04:05",
	"2006-01-02T15:04",
	"2006-01-02 15:04:05",
	"2006-01-02 15:04",
	"2006-01-02",
	"02.01.2006 15:04:05",
	"02.01.2006 15:04",
	"02.01.2006",
	"02.01.06 15:04",
	"02.01.06",
	"02/01/2006 15:04:05",
	"02/01/2006 15:04",
	"02/01/2006",
	"02-01-2006 15:04:05",
	"02-01-2006",
}

// parseDate — дата из выписки/ответа; RFC3339 переводится в «локальное» время зоны строки (без зоны в ответе).
func parseDate(s string) (time.Time, bool) {
	s = strings.TrimSpace(s)
	for _, l := range dateLayouts {
		if t, err := time.Parse(l, s); err == nil {
			if t.Year() < 2000 || t.Year() > 2100 {
				return time.Time{}, false
			}
			return t, true
		}
	}
	return time.Time{}, false
}
