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
package finance

import (
	"database/sql"
	"log/slog"
	"net/http"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
)

type Handler struct {
	db     *sql.DB
	ai     ai.Client
	logger *slog.Logger
}

func New(db *sql.DB, client ai.Client, logger *slog.Logger) *Handler {
	return &Handler{db: db, ai: client, logger: logger}
}

// Register — маршруты /api/v1/finance/... TODO B.
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}
