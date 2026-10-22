package finance

import (
	"fmt"
	"math"
	"net/http"
	"strings"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
)

type budgetReq struct {
	Lang       string `json:"lang"`
	Days       int    `json:"days"`
	Categories []struct {
		ID       string  `json:"id"`
		Name     string  `json:"name"`
		SpentRub []int64 `json:"spent_rub"`
	} `json:"categories"`
	IncomeRub int64 `json:"income_rub"`
}

type budgetOut struct {
	CategoryID string `json:"category_id"`
	Period     string `json:"period"`
	LimitRub   int64  `json:"limit_rub"`
	Reason     string `json:"reason"`
}

// budgetSuggest — POST /finance/budget/suggest: лимиты по категориям после 2–4 недель наблюдений.
// Вход и выход — копейки; модели отдаём и от неё берём рубли.
func (h *Handler) budgetSuggest(w http.ResponseWriter, r *http.Request) {
	var req budgetReq
	uid, ok := begin(w, r, h.limBudget, &req)
	if !ok {
		return
	}
	if len(req.Categories) == 0 {
		writeJSON(w, http.StatusOK, map[string]any{"budgets": []budgetOut{}})
		return
	}
	if len(req.Categories) > 60 {
		writeErr(w, http.StatusBadRequest, "too many categories")
		return
	}
	// Кап лимита: не больше 3× наблюдаемого месячного темпа категории (защита от бессмысленных чисел).
	caps := map[string]int64{}
	var b strings.Builder
	fmt.Fprintf(&b, "Observation days: %d\nMonthly income, RUB: %.0f\nCategories (weekly spending in RUB, oldest first):\n",
		req.Days, float64(max(req.IncomeRub, 0))/100)
	for _, c := range req.Categories {
		id := truncate(c.ID, 64)
		if id == "" {
			continue
		}
		var sum int64
		var weeks []string
		for i, v := range c.SpentRub {
			if i >= 26 {
				break
			}
			v = max(v, 0)
			sum += v
			weeks = append(weeks, fmt.Sprintf("%.0f", float64(v)/100))
		}
		n := max(len(weeks), 1)
		monthly := float64(sum) / float64(n) * 4.345
		caps[id] = int64(math.Max(monthly*3, 100000)) // ≥ 1000 ₽
		fmt.Fprintf(&b, "- id=%s name=%q weeks=[%s]\n", id, truncate(c.Name, 60), strings.Join(weeks, ","))
	}
	system := `Task: propose monthly spending limits per category from observed weekly spending.
JSON schema: {"budgets":[{"category_id":string,"period":"month","limit_rub":number,"reason":string}]}
- limit_rub in whole rubles. Base it on the observed average (weekly × 4.3), slightly below for discretionary categories (cafe, fast food, entertainment, shopping), around the average for essentials (groceries, transport, utilities, health).
- If income is given and total limits exceed ~90% of it, scale discretionary limits down.
- Skip categories with almost no spending. Use only the given ids.
- reason: one short sentence in ` + langName(req.Lang) + `, friendly, with the observed average.`
	var out struct {
		Budgets []struct {
			CategoryID string  `json:"category_id"`
			Period     string  `json:"period"`
			LimitRub   float64 `json:"limit_rub"`
			Reason     string  `json:"reason"`
		} `json:"budgets"`
	}
	if err := h.ask(r.Context(), uid, ai.TaskAnalysis, system, []ai.Part{{Text: b.String()}}, 1500, &out); err != nil {
		h.aiFail(w, "budget_suggest", err)
		return
	}
	res := []budgetOut{}
	seen := map[string]bool{}
	for _, it := range out.Budgets {
		cp, ok := caps[it.CategoryID]
		if !ok || seen[it.CategoryID] {
			continue
		}
		lim, ok := minor(it.LimitRub)
		if !ok {
			continue
		}
		lim = min(lim, cp)
		lim = (lim + 5000) / 10000 * 10000 // округление до 100 ₽
		if lim <= 0 {
			continue
		}
		seen[it.CategoryID] = true
		res = append(res, budgetOut{CategoryID: it.CategoryID, Period: "month", LimitRub: lim, Reason: truncate(it.Reason, 240)})
	}
	writeJSON(w, http.StatusOK, map[string]any{"budgets": res})
}

type commentReq struct {
	Lang       string `json:"lang"`
	Period     string `json:"period"`
	Totals     any    `json:"totals"`
	ByCategory any    `json:"by_category"`
	Budgets    any    `json:"budgets"`
}

// reportComment — POST /finance/report/comment: короткий комментарий ИИ к отчёту за неделю/месяц.
func (h *Handler) reportComment(w http.ResponseWriter, r *http.Request) {
	var req commentReq
	uid, ok := begin(w, r, h.limComment, &req)
	if !ok {
		return
	}
	period := oneOf(req.Period, "week", "month")
	system := `Task: write a short comment (2–4 sentences) on the user's ` + period + ` finance report.
JSON schema: {"comment":string}
- Write in ` + langName(req.Lang) + `. Amounts in the input are in kopecks (1/100 RUB) unless a field name says otherwise; show rubles.
- Mention the biggest category, budgets exceeded or kept, and one practical tip. Supportive, no shaming.`
	prompt := "totals: " + jsonText(req.Totals, 2000) + "\nby_category: " + jsonText(req.ByCategory, 6000) +
		"\nbudgets: " + jsonText(req.Budgets, 4000)
	var out struct {
		Comment string `json:"comment"`
	}
	if err := h.ask(r.Context(), uid, ai.TaskShort, system, []ai.Part{{Text: prompt}}, 500, &out); err != nil {
		h.aiFail(w, "report_comment", err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"comment": truncate(out.Comment, 800)})
}
