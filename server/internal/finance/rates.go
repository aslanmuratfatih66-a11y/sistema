package finance

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"
)

// cgTTL — крипта из CoinGecko обновляется не чаще раза в 10 минут; после ошибки — пауза cgBackoff.
const (
	cgTTL     = 10 * time.Minute
	cgBackoff = 2 * time.Minute
	maxCoins  = 20
)

var coinID = regexp.MustCompile(`^[a-z0-9][a-z0-9-]{0,63}$`)

type ratesResp struct {
	Base      string             `json:"base"`
	UpdatedAt int64              `json:"updated_at"`
	Rates     map[string]float64 `json:"rates"`
}

// rates — GET /finance/rates: фиат из fx_rates (база USD) → ₽ за 1 единицу; крипта — CoinGecko с кэшем.
func (h *Handler) rates(w http.ResponseWriter, r *http.Request) {
	if _, ok := user(w, r, h.limRates); !ok {
		return
	}
	var coins []string
	seen := map[string]bool{}
	for _, c := range strings.Split(r.URL.Query().Get("coins"), ",") {
		c = strings.ToLower(strings.TrimSpace(c))
		if c == "" || seen[c] {
			continue
		}
		if !coinID.MatchString(c) {
			writeErr(w, http.StatusBadRequest, "bad coin id")
			return
		}
		seen[c] = true
		coins = append(coins, c)
	}
	if len(coins) > maxCoins {
		writeErr(w, http.StatusBadRequest, "too many coins")
		return
	}
	ctx := r.Context()
	out := ratesResp{Base: "RUB", Rates: map[string]float64{"RUB": 1}}
	var updated int64

	// Фиат: rate = единиц quote за 1 USD → ₽ за 1 X = RUB/X.
	usd := map[string]float64{}
	rows, err := h.db.QueryContext(ctx, `SELECT quote, rate, updated_at FROM fx_rates WHERE base='USD'`)
	if err != nil {
		h.logger.Error("finance: rates", "err", err)
		writeErr(w, http.StatusInternalServerError, "internal")
		return
	}
	for rows.Next() {
		var q string
		var v float64
		var at int64
		if err := rows.Scan(&q, &v, &at); err == nil && v > 0 {
			usd[q] = v
			if at > updated {
				updated = at
			}
		}
	}
	_ = rows.Close()
	if rub := usd["RUB"]; rub > 0 {
		for q, v := range usd {
			if q != "RUB" {
				out.Rates[q] = rub / v
			}
		}
	}

	if len(coins) > 0 {
		cg := h.crypto(ctx, coins)
		for id, v := range cg {
			out.Rates["cg:"+id] = v.rate
			if v.at > updated {
				updated = v.at
			}
		}
	}
	out.UpdatedAt = updated / 1000
	writeJSON(w, http.StatusOK, out)
}

type cached struct {
	rate float64
	at   int64 // мс
}

// crypto — ₽ за монету: свежий кэш или запрос CoinGecko; при ошибке — что есть в кэше.
func (h *Handler) crypto(ctx context.Context, coins []string) map[string]cached {
	h.cgMu.Lock()
	defer h.cgMu.Unlock()
	res := h.cgCache(ctx, coins)
	now := time.Now()
	var stale []string
	for _, c := range coins {
		v, ok := res[c]
		if !ok || now.Sub(time.UnixMilli(v.at)) > cgTTL {
			stale = append(stale, c)
		}
	}
	if len(stale) == 0 || now.Sub(h.cgFailedAt) < cgBackoff {
		return res
	}
	fresh, err := h.fetchCoinGecko(ctx, stale)
	if err != nil {
		h.cgFailedAt = now
		h.logger.Warn("finance: coingecko", "err", err)
		return res
	}
	at := now.UnixMilli()
	for id, v := range fresh {
		if _, err := h.db.ExecContext(ctx, `INSERT INTO fx_rates(base,quote,rate,updated_at) VALUES('RUB',?,?,?)
			ON CONFLICT(base,quote) DO UPDATE SET rate=excluded.rate, updated_at=excluded.updated_at`,
			"cg:"+id, v, at); err != nil {
			h.logger.Warn("finance: save crypto rate", "err", err)
		}
		res[id] = cached{rate: v, at: at}
	}
	return res
}

func (h *Handler) cgCache(ctx context.Context, coins []string) map[string]cached {
	res := map[string]cached{}
	args := make([]any, 0, len(coins))
	ph := make([]string, 0, len(coins))
	for _, c := range coins {
		args = append(args, "cg:"+c)
		ph = append(ph, "?")
	}
	rows, err := h.db.QueryContext(ctx, `SELECT quote, rate, updated_at FROM fx_rates WHERE base='RUB' AND quote IN (`+
		strings.Join(ph, ",")+`)`, args...)
	if err != nil {
		h.logger.Warn("finance: crypto cache", "err", err)
		return res
	}
	defer rows.Close()
	for rows.Next() {
		var q string
		var c cached
		if rows.Scan(&q, &c.rate, &c.at) == nil && c.rate > 0 {
			res[strings.TrimPrefix(q, "cg:")] = c
		}
	}
	return res
}

func (h *Handler) fetchCoinGecko(ctx context.Context, ids []string) (map[string]float64, error) {
	u := h.coingeckoURL + "?ids=" + url.QueryEscape(strings.Join(ids, ",")) + "&vs_currencies=rub"
	ctx, cancel := context.WithTimeout(ctx, 8*time.Second)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")
	resp, err := h.http.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("coingecko: HTTP %d", resp.StatusCode)
	}
	var body map[string]map[string]float64
	if err := json.NewDecoder(io.LimitReader(resp.Body, 1<<20)).Decode(&body); err != nil {
		return nil, fmt.Errorf("coingecko: decode: %w", err)
	}
	out := map[string]float64{}
	for _, id := range ids {
		if v := body[id]["rub"]; v > 0 {
			out[id] = v
		}
	}
	return out, nil
}
