package finance

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
)

const (
	maxBankItems = 30
	maxBankBody  = 1000
)

type bankReq struct {
	Lang  string `json:"lang"`
	Items []struct {
		ID     string `json:"id"`
		Sender string `json:"sender"`
		Bank   string `json:"bank"`
		Body   string `json:"body"`
	} `json:"items"`
}

type bankItem struct {
	ID         string `json:"id"`
	OK         bool   `json:"ok"`
	Kind       string `json:"kind,omitempty"`
	Amount     int64  `json:"amount,omitempty"`
	Currency   string `json:"currency,omitempty"`
	Merchant   string `json:"merchant,omitempty"`
	CardLast4  string `json:"card_last4,omitempty"`
	OccurredAt string `json:"occurred_at,omitempty"`
}

// bankParse — POST /finance/bank/parse: уведомления/SMS, не распознанные шаблонами клиента, разбирает Haiku.
func (h *Handler) bankParse(w http.ResponseWriter, r *http.Request) {
	var req bankReq
	uid, ok := begin(w, r, h.limBank, &req)
	if !ok {
		return
	}
	if len(req.Items) == 0 {
		writeJSON(w, http.StatusOK, map[string]any{"items": []bankItem{}})
		return
	}
	if len(req.Items) > maxBankItems {
		writeErr(w, http.StatusBadRequest, "too many items")
		return
	}
	type in struct {
		ID     string `json:"id"`
		Sender string `json:"sender,omitempty"`
		Bank   string `json:"bank,omitempty"`
		Text   string `json:"text"`
	}
	ids := map[string]bool{}
	inputs := make([]in, 0, len(req.Items))
	for _, it := range req.Items {
		id := truncate(it.ID, 64)
		if id == "" || ids[id] {
			writeErr(w, http.StatusBadRequest, "bad item id")
			return
		}
		ids[id] = true
		inputs = append(inputs, in{ID: id, Sender: truncate(it.Sender, 80), Bank: truncate(it.Bank, 40), Text: truncate(it.Body, maxBankBody)})
	}
	payload, _ := json.Marshal(inputs)
	system := `Task: parse bank push notifications / SMS into transactions.
JSON schema: {"items":[{"id":string,"ok":boolean,"kind":"expense|income|transfer","amount":number,"currency":"RUB|TRY|USD|EUR|…","merchant":string,"card_last4":string,"occurred_at":string}]}
- One output item per input id, same id.
- ok=false for anything that is not a completed money movement: OTP/confirmation codes, ads, declined or failed payments, balance-only messages, login alerts.
- amount: the transaction amount in major units (e.g. 1234.56), positive; never the balance ("Баланс", "Остаток", "Bakiye", "Kalan limit").
- kind: purchase/debit/withdrawal/payment ("Покупка", "Списание", "Оплата", "Снятие", "Harcama", "Ödeme") → expense; incoming ("Зачисление", "Пополнение", "Поступление", "Перевод от", "Gelen", "Yatırıldı") → income; transfer between own accounts → transfer.
- currency: ISO 4217 code; ₽/р/руб → RUB, TL/₺ → TRY. If absent, guess from the bank (Russian banks RUB, Turkish banks TRY).
- merchant: shop/payee name as written, "" if none. card_last4: 4 digits of the card/account if present, else "".
- occurred_at: "YYYY-MM-DDTHH:MM:SS" only if the date is in the text, else "".`
	var out struct {
		Items []struct {
			ID         string  `json:"id"`
			OK         bool    `json:"ok"`
			Kind       string  `json:"kind"`
			Amount     float64 `json:"amount"`
			Currency   string  `json:"currency"`
			Merchant   string  `json:"merchant"`
			CardLast4  string  `json:"card_last4"`
			OccurredAt string  `json:"occurred_at"`
		} `json:"items"`
	}
	parts := []ai.Part{{Text: "Language of texts: mostly " + langName(req.Lang) + ".\nInput:\n" + string(payload)}}
	if err := h.ask(r.Context(), uid, ai.TaskBankParse, system, parts, 200+len(inputs)*120, &out); err != nil {
		h.aiFail(w, "bank_parse", err)
		return
	}
	got := map[string]bankItem{}
	for _, it := range out.Items {
		if !ids[it.ID] {
			continue
		}
		res := bankItem{ID: it.ID}
		if amt, ok := minor(it.Amount); ok && it.OK {
			res = bankItem{
				ID:         it.ID,
				OK:         true,
				Kind:       oneOf(it.Kind, "expense", "income", "transfer"),
				Amount:     amt,
				Currency:   currency(it.Currency, "RUB"),
				Merchant:   truncate(it.Merchant, 120),
				CardLast4:  last4(it.CardLast4),
				OccurredAt: normTime(it.OccurredAt),
			}
		}
		got[it.ID] = res
	}
	items := make([]bankItem, 0, len(inputs))
	for _, it := range inputs {
		if v, ok := got[it.ID]; ok {
			items = append(items, v)
		} else {
			items = append(items, bankItem{ID: it.ID})
		}
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

// last4 — последние 4 цифры из строки или "".
func last4(s string) string {
	var d []byte
	for i := 0; i < len(s); i++ {
		if s[i] >= '0' && s[i] <= '9' {
			d = append(d, s[i])
		}
	}
	if len(d) < 4 {
		return ""
	}
	return string(d[len(d)-4:])
}

// jsonText — компактный JSON произвольного значения с ограничением длины (для промптов).
func jsonText(v any, n int) string {
	b, err := json.Marshal(v)
	if err != nil {
		return "null"
	}
	return truncate(strings.ToValidUTF8(string(b), ""), n)
}
