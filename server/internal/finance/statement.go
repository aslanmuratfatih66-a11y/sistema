package finance

import (
	"bytes"
	"crypto/sha256"
	"encoding/base64"
	"encoding/csv"
	"encoding/hex"
	"fmt"
	"io"
	"math"
	"net/http"
	"strconv"
	"strings"
	"unicode/utf8"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
)

const (
	maxStatementFile = 3 << 20 // после base64 укладывается в общий лимит тела 4 МБ
	maxStatementRows = 2000
	maxAIText        = 60000 // рун CSV/текста для ИИ
)

type statementReq struct {
	Filename string `json:"filename"`
	Mime     string `json:"mime"`
	Data     string `json:"data"`
	Lang     string `json:"lang"`
}

type stRow struct {
	Ref         string `json:"ref"`
	OccurredAt  string `json:"occurred_at"`
	Kind        string `json:"kind"`
	Amount      int64  `json:"amount"`
	Currency    string `json:"currency"`
	Description string `json:"description"`
	Merchant    string `json:"merchant"`
}

// statement — POST /finance/statement: CSV разбирается в Go (шаблоны колонок банков + эвристика), иначе и PDF — ИИ.
func (h *Handler) statement(w http.ResponseWriter, r *http.Request) {
	var req statementReq
	uid, ok := begin(w, r, h.limStatement, &req)
	if !ok {
		return
	}
	s := strings.TrimSpace(req.Data)
	if i := strings.Index(s, ","); strings.HasPrefix(s, "data:") && i > 0 {
		s = s[i+1:]
	}
	data, err := base64.StdEncoding.DecodeString(s)
	if err != nil || len(data) == 0 {
		writeErr(w, http.StatusBadRequest, "bad data")
		return
	}
	if len(data) > maxStatementFile {
		writeErr(w, http.StatusRequestEntityTooLarge, "file too large")
		return
	}
	name := strings.ToLower(req.Filename)
	isPDF := bytes.HasPrefix(data, []byte("%PDF"))
	if !isPDF && (req.Mime == "application/pdf" || strings.HasSuffix(name, ".pdf")) {
		writeErr(w, http.StatusBadRequest, "bad pdf")
		return
	}
	defCur := "RUB"
	if strings.HasPrefix(strings.ToLower(req.Lang), "tr") {
		defCur = "TRY"
	}

	var parts []ai.Part
	if isPDF {
		parts = []ai.Part{{Document: &ai.Document{MediaType: "application/pdf", Data: data}}, {Text: "Extract the transactions from this bank statement."}}
	} else {
		if bytes.IndexByte(data, 0) >= 0 {
			writeErr(w, http.StatusUnsupportedMediaType, "unsupported")
			return
		}
		text := decodeText(data, req.Lang)
		if rows, ok := parseCSVStatement(text, defCur); ok {
			writeJSON(w, http.StatusOK, map[string]any{"rows": rows})
			return
		}
		parts = []ai.Part{{Text: "Bank statement export (text/CSV):\n" + truncate(text, maxAIText)}}
	}

	system := `Task: extract transactions from a bank statement.
JSON schema: {"rows":[{"date":"YYYY-MM-DDTHH:MM:SS","kind":"expense|income|transfer","amount":number,"currency":string,"description":string,"merchant":string}]}
- Only real completed transactions; skip opening/closing balances, totals, holds that were cancelled, declined operations, headers.
- amount: positive, major units (1234.56). kind: debit/purchase/withdrawal → expense; credit/top-up/salary/incoming → income; between own accounts → transfer.
- currency: ISO 4217 (₽ → RUB, TL → TRY); if not stated, ` + defCur + `.
- date: operation date (time if present, else 00:00:00). description: as written, short. merchant: shop/payee or "".
- Keep the original order. Text language is mostly ` + langName(req.Lang) + `.`
	var out struct {
		Rows []struct {
			Date        string  `json:"date"`
			Kind        string  `json:"kind"`
			Amount      float64 `json:"amount"`
			Currency    string  `json:"currency"`
			Description string  `json:"description"`
			Merchant    string  `json:"merchant"`
		} `json:"rows"`
	}
	if err := h.ask(r.Context(), uid, ai.TaskBankParse, system, parts, 8000, &out); err != nil {
		h.aiFail(w, "statement", err)
		return
	}
	refs := refCounter{}
	rows := []stRow{}
	for _, it := range out.Rows {
		at := normTime(it.Date)
		amt, ok := minor(it.Amount)
		if at == "" || !ok {
			continue
		}
		row := stRow{
			OccurredAt:  at,
			Kind:        oneOf(it.Kind, "expense", "income", "transfer"),
			Amount:      amt,
			Currency:    currency(it.Currency, defCur),
			Description: truncate(it.Description, 200),
			Merchant:    truncate(it.Merchant, 120),
		}
		row.Ref = refs.ref(row)
		rows = append(rows, row)
		if len(rows) >= maxStatementRows {
			break
		}
	}
	writeJSON(w, http.StatusOK, map[string]any{"rows": rows})
}

// refCounter — стабильный ref строки: хэш (дата, тип, сумма, валюта, описание) + номер повтора внутри файла.
// Повторный импорт той же/пересекающейся выписки даёт те же ref → клиент отметит дубли.
type refCounter map[string]int

func (c refCounter) ref(r stRow) string {
	key := strings.Join([]string{r.OccurredAt, r.Kind, strconv.FormatInt(r.Amount, 10), r.Currency,
		strings.ToLower(strings.Join(strings.Fields(r.Description), " "))}, "|")
	sum := sha256.Sum256([]byte(key))
	h := "st:" + hex.EncodeToString(sum[:10])
	c[h]++
	if n := c[h]; n > 1 {
		return fmt.Sprintf("%s:%d", h, n)
	}
	return h
}

// ---------- CSV ----------

// Ключи колонок по приоритету: точное совпадение, затем «содержит». Покрывают выгрузки Т-Банка
// («Дата операции;…;Статус;Сумма операции;Валюта операции;Сумма платежа;Валюта платежа;…;Описание»),
// Сбера/ВТБ/Альфы («Дата», «Сумма», «Расход/Приход», «Описание/Назначение»), Ziraat/İş/Garanti
// («Tarih», «Tutar», «Borç/Alacak», «Açıklama»).
var (
	colDate     = []string{"дата операции", "дата и время операции", "дата транзакции", "дата проводки", "дата", "date", "transaction date", "işlem tarihi", "tarih"}
	colAmount   = []string{"сумма платежа", "сумма операции", "сумма в валюте счета", "сумма в валюте счёта", "сумма", "amount", "işlem tutarı", "tutar"}
	colCurrency = []string{"валюта платежа", "валюта операции", "валюта счета", "валюта", "currency", "para birimi", "döviz"}
	colDebit    = []string{"расход", "списание", "сумма списания", "дебет", "debit", "borç", "çıkan", "giden"}
	colCredit   = []string{"приход", "зачисление", "сумма зачисления", "поступление", "кредит", "credit", "alacak", "giren", "gelen"}
	colDesc     = []string{"описание операции", "описание", "назначение платежа", "назначение", "детали операции", "комментарий", "description", "details", "işlem açıklaması", "açıklama"}
	colMerchant = []string{"мерчант", "контрагент", "получатель", "merchant", "payee", "işyeri", "üye işyeri"}
	colStatus   = []string{"статус", "status", "durum"}
)

type colMap struct {
	date, amount, cur, debit, credit, desc, merchant, status int
}

func normHeader(s string) string {
	s = strings.TrimPrefix(s, string(rune(0xFEFF)))
	s = strings.Trim(strings.ToLower(strings.TrimSpace(s)), `"'`)
	return strings.Join(strings.Fields(s), " ")
}

// findCol — индекс колонки по ключам (сначала точное совпадение, потом подстрока), не занятой ранее.
func findCol(hdr []string, keys []string, used map[int]bool) int {
	for _, k := range keys {
		for i, h := range hdr {
			if !used[i] && h == k {
				used[i] = true
				return i
			}
		}
	}
	for _, k := range keys {
		for i, h := range hdr {
			if !used[i] && h != "" && strings.Contains(h, k) {
				used[i] = true
				return i
			}
		}
	}
	return -1
}

func mapHeader(rec []string) (colMap, bool) {
	hdr := make([]string, len(rec))
	for i, c := range rec {
		hdr[i] = normHeader(c)
	}
	used := map[int]bool{}
	m := colMap{}
	m.date = findCol(hdr, colDate, used)
	// Колонки «Дата платежа» и т.п. не должны стать суммой/описанием.
	for i, h := range hdr {
		if strings.Contains(h, "дата") || strings.Contains(h, "date") || strings.Contains(h, "tarih") {
			used[i] = true
		}
	}
	m.debit = findCol(hdr, colDebit, used)
	m.credit = findCol(hdr, colCredit, used)
	m.amount = findCol(hdr, colAmount, used)
	m.cur = findCol(hdr, colCurrency, used)
	m.status = findCol(hdr, colStatus, used)
	m.desc = findCol(hdr, colDesc, used)
	m.merchant = findCol(hdr, colMerchant, used)
	ok := m.date >= 0 && (m.amount >= 0 || m.debit >= 0 || m.credit >= 0)
	return m, ok
}

func cell(rec []string, i int) string {
	if i < 0 || i >= len(rec) {
		return ""
	}
	return strings.TrimSpace(rec[i])
}

// parseCSVStatement — CSV/TSV выписка; false — формат не распознан (тогда ИИ).
func parseCSVStatement(text, defCur string) ([]stRow, bool) {
	for _, delim := range []rune{';', '\t', ','} {
		rd := csv.NewReader(strings.NewReader(text))
		rd.Comma = delim
		rd.LazyQuotes = true
		rd.FieldsPerRecord = -1
		var recs [][]string
		for len(recs) < 20000 {
			rec, err := rd.Read()
			if err == io.EOF {
				break
			}
			if err != nil {
				continue
			}
			recs = append(recs, rec)
		}
		for hi := 0; hi < len(recs) && hi < 40; hi++ {
			if len(recs[hi]) < 3 {
				continue
			}
			m, ok := mapHeader(recs[hi])
			if !ok {
				continue
			}
			rows := csvRows(recs[hi+1:], m, defCur)
			if len(rows) > 0 {
				return rows, true
			}
		}
	}
	return nil, false
}

func csvRows(recs [][]string, m colMap, defCur string) []stRow {
	// Если у суммы нет ни одного минуса и нет колонок расход/приход — всё считается расходом.
	anyNeg := false
	if m.amount >= 0 {
		for _, rec := range recs {
			if v, ok := parseAmount(cell(rec, m.amount)); ok && v < 0 {
				anyNeg = true
				break
			}
		}
	}
	refs := refCounter{}
	var rows []stRow
	for _, rec := range recs {
		t, ok := parseDate(cell(rec, m.date))
		if !ok {
			continue
		}
		st := strings.ToLower(cell(rec, m.status))
		if st != "" && (strings.Contains(st, "fail") || strings.Contains(st, "отклон") || strings.Contains(st, "отмен") ||
			strings.Contains(st, "declin") || strings.Contains(st, "iptal")) {
			continue
		}
		var amount float64
		kind := ""
		if d, ok := parseAmount(cell(rec, m.debit)); ok && d != 0 {
			amount, kind = d, "expense"
		} else if c, ok := parseAmount(cell(rec, m.credit)); ok && c != 0 {
			amount, kind = c, "income"
		} else if a, ok := parseAmount(cell(rec, m.amount)); ok && a != 0 {
			amount = a
			switch {
			case a < 0:
				kind = "expense"
			case anyNeg:
				kind = "income"
			default:
				kind = "expense"
			}
		}
		amt, ok := minor(amount)
		if kind == "" || !ok {
			continue
		}
		desc := cell(rec, m.desc)
		row := stRow{
			OccurredAt:  t.Format(localTime),
			Kind:        kind,
			Amount:      amt,
			Currency:    currency(cell(rec, m.cur), defCur),
			Description: truncate(desc, 200),
			Merchant:    truncate(cell(rec, m.merchant), 120),
		}
		row.Ref = refs.ref(row)
		rows = append(rows, row)
		if len(rows) >= maxStatementRows {
			break
		}
	}
	return rows
}

// parseAmount — «-1 234,56», «1.234,56», «1,234.56», «(12.00)», «−500 ₽».
func parseAmount(s string) (float64, bool) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, false
	}
	neg := false
	if strings.HasPrefix(s, "(") && strings.HasSuffix(s, ")") {
		neg = true
	}
	var b strings.Builder
	for _, r := range s {
		switch {
		case r >= '0' && r <= '9', r == ',', r == '.':
			b.WriteRune(r)
		case r == '-' || r == '−' || r == '–':
			if b.Len() == 0 {
				neg = true
			}
		}
	}
	n := b.String()
	if n == "" {
		return 0, false
	}
	lc, ld := strings.LastIndex(n, ","), strings.LastIndex(n, ".")
	switch {
	case lc >= 0 && ld >= 0:
		if lc > ld { // 1.234,56
			n = strings.ReplaceAll(n[:lc], ".", "") + "." + n[lc+1:]
		} else { // 1,234.56
			n = strings.ReplaceAll(n, ",", "")
		}
	case lc >= 0:
		if strings.Count(n, ",") > 1 {
			n = strings.ReplaceAll(n, ",", "")
		} else {
			n = strings.Replace(n, ",", ".", 1)
		}
	case strings.Count(n, ".") > 1:
		n = strings.ReplaceAll(n, ".", "")
	}
	v, err := strconv.ParseFloat(n, 64)
	if err != nil || math.IsNaN(v) || math.IsInf(v, 0) {
		return 0, false
	}
	if neg {
		v = -v
	}
	return v, true
}

// ---------- кодировки ----------

// decodeText — UTF-8 (с BOM или без); иначе Windows-1251 (RU) или Windows-1254 (TR).
func decodeText(b []byte, lang string) string {
	b = bytes.TrimPrefix(b, []byte{0xEF, 0xBB, 0xBF})
	if utf8.Valid(b) {
		return string(b)
	}
	tr := strings.HasPrefix(strings.ToLower(lang), "tr")
	var sb strings.Builder
	sb.Grow(len(b) * 2)
	for _, c := range b {
		switch {
		case c < 0x80:
			sb.WriteByte(c)
		case tr:
			sb.WriteRune(cp1254(c))
		case c >= 0xC0:
			sb.WriteRune(rune(0x0410 + int(c) - 0xC0))
		default:
			sb.WriteRune(cp1251hi[c-0x80])
		}
	}
	return sb.String()
}

var cp1251hi = [64]rune{
	0x0402, 0x0403, 0x201A, 0x0453, 0x201E, 0x2026, 0x2020, 0x2021, 0x20AC, 0x2030, 0x0409, 0x2039, 0x040A, 0x040C, 0x040B, 0x040F,
	0x0452, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0xFFFD, 0x2122, 0x0459, 0x203A, 0x045A, 0x045C, 0x045B, 0x045F,
	0x00A0, 0x040E, 0x045E, 0x0408, 0x00A4, 0x0490, 0x00A6, 0x00A7, 0x0401, 0x00A9, 0x0404, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x0407,
	0x00B0, 0x00B1, 0x0406, 0x0456, 0x0491, 0x00B5, 0x00B6, 0x00B7, 0x0451, 0x2116, 0x0454, 0x00BB, 0x0458, 0x0405, 0x0455, 0x0457,
}

// cp1254 — Latin-1 с турецкими буквами (0x80–0x9F упрощены до Latin-1).
func cp1254(c byte) rune {
	switch c {
	case 0xD0:
		return 'Ğ'
	case 0xDD:
		return 'İ'
	case 0xDE:
		return 'Ş'
	case 0xF0:
		return 'ğ'
	case 0xFD:
		return 'ı'
	case 0xFE:
		return 'ş'
	case 0x80:
		return '€'
	}
	return rune(c)
}
