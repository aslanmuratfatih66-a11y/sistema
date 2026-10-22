// Package market — маркет покупок (SPEC §8.8): ИИ подбирает товары под план (уход за кожей, питание, инвентарь),
// примерная цена через веб-поиск (ai.Request.WebSearch) с датой и источником, ссылки/поиск на Ozon, Wildberries,
// Яндекс Маркет, Пятёрочку (RU), Trendyol (TR). Пометку «по бюджету» ставит клиент (финансы локальные).
// КОНТРАКТ каркаса этапа 7; реализация — сабагент C. ИИ — через ai.Client. Кэш цен — ai_cache.
//
// Эндпоинты (под authSvc.Require, JSON; цена — целое в мин. единицах):
//
//	POST /api/v1/market/suggest {"lang","country":"RU|TR","category":"skin|nutrition|equipment|other|",
//	                             "context":{"plan":…,"skin":…,"goals":…,"budget_rub":…},"exclude":[названия]}
//	     → {"items":[{"title","category","reason","price","currency","price_source","price_at":<unix>,
//	                  "links":[{"store","url","search":bool}]}]}
//	POST /api/v1/market/price   {"title","country"} → {"price","currency","price_source","price_at","url"}
package market

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

// Register — маршруты /api/v1/market/... TODO C.
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {}
