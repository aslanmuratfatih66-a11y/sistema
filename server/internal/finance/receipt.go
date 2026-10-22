package finance

import (
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

type qrReq struct {
	QR string `json:"qr"`
}

type receiptItem struct {
	Name  string  `json:"name"`
	Qty   float64 `json:"qty"`
	Price int64   `json:"price"`
}

type qrResp struct {
	Status     string        `json:"status"`
	Total      int64         `json:"total"`
	OccurredAt string        `json:"occurred_at"`
	Store      string        `json:"store"`
	Items      []receiptItem `json:"items"`
	FN         string        `json:"fn,omitempty"`
	FD         string        `json:"i,omitempty"`
	FP         string        `json:"fp,omitempty"`
	OpType     int           `json:"n,omitempty"`
}

// qrFields — поля QR-кода кассового чека ФНС: t (YYYYMMDDTHHMM[SS]), s (сумма, руб.), fn, i (ФД), fp (ФП), n (тип).
type qrFields struct {
	At     time.Time
	Total  int64
	FN, FD string
	FP     string
	N      int
}

func parseFNSQR(s string) (qrFields, bool) {
	var f qrFields
	v, err := url.ParseQuery(strings.TrimSpace(s))
	if err != nil {
		return f, false
	}
	for _, l := range []string{"20060102T150405", "20060102T1504"} {
		if t, err := time.Parse(l, v.Get("t")); err == nil {
			f.At = t
			break
		}
	}
	sum, err := strconv.ParseFloat(strings.ReplaceAll(v.Get("s"), ",", "."), 64)
	if err != nil {
		return f, false
	}
	amt, ok := minor(sum)
	if !ok || f.At.IsZero() {
		return f, false
	}
	f.Total = amt
	f.FN, f.FD, f.FP = digits(v.Get("fn"), 20), digits(v.Get("i"), 20), digits(v.Get("fp"), 20)
	f.N, _ = strconv.Atoi(v.Get("n"))
	return f, f.FN != "" && f.FD != "" && f.FP != ""
}

func digits(s string, n int) string {
	s = strings.TrimSpace(s)
	if s == "" || len(s) > n {
		return ""
	}
	for i := 0; i < len(s); i++ {
		if s[i] < '0' || s[i] > '9' {
			return ""
		}
	}
	return s
}

// receiptQR — POST /finance/receipt/qr. Позиции чека — из ФНС «Проверка чека».
// TODO(ФНС): API проверки чеков ФНС требует регистрации и ключа; протокол здесь не реализован (не выдумываем).
// Когда появится — запрос по fn/i/fp/t/s/n, заполнить store/items, status "ok".
func (h *Handler) receiptQR(w http.ResponseWriter, r *http.Request) {
	var req qrReq
	if _, ok := begin(w, r, h.limReceipt, &req); !ok {
		return
	}
	if len(req.QR) > 512 {
		writeErr(w, http.StatusBadRequest, "bad qr")
		return
	}
	f, ok := parseFNSQR(req.QR)
	if !ok {
		writeErr(w, http.StatusBadRequest, "bad qr")
		return
	}
	writeJSON(w, http.StatusOK, qrResp{
		Status:     "unavailable",
		Total:      f.Total,
		OccurredAt: f.At.Format(localTime),
		Items:      []receiptItem{},
		FN:         f.FN,
		FD:         f.FD,
		FP:         f.FP,
		OpType:     f.N,
	})
}
