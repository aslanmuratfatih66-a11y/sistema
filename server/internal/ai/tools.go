package ai

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/syncapi"
)

// Встроенные инструменты ИИ (SPEC §9.1): квесты, ◆, нормы, штрафной квест, еда.
// Все пишут в records через syncapi.ServerWrite; отмена — универсальная: список изменений (undoChange),
// для журнала quest_events — компенсирующее событие (журнал только на вставку).

const langKey ctxKey = 2

func withLang(ctx context.Context, lang string) context.Context {
	return context.WithValue(ctx, langKey, lang)
}

func langOf(ctx context.Context) string {
	if l, _ := ctx.Value(langKey).(string); l == "tr" {
		return "tr"
	}
	return "ru"
}

// tr — строка на языке пользователя.
func tr(ctx context.Context, ru, trk string) string {
	if langOf(ctx) == "tr" {
		return trk
	}
	return ru
}

// undoChange — сериализуемое изменение для отмены.
type undoChange struct {
	Table   string         `json:"table"`
	ID      string         `json:"id"`
	Fields  map[string]any `json:"fields,omitempty"`
	Deleted *bool          `json:"deleted,omitempty"`
}

type undoData struct {
	Changes []undoChange `json:"changes"`
}

func applyUndo(ctx context.Context, db *sql.DB, uid string, raw json.RawMessage) error {
	var u undoData
	if err := json.Unmarshal(raw, &u); err != nil {
		return err
	}
	if len(u.Changes) == 0 {
		return errors.New("nothing to undo")
	}
	ch := make([]syncapi.ServerChange, 0, len(u.Changes))
	for _, c := range u.Changes {
		id := c.ID
		if id == "$new" { // компенсирующее событие — новая запись
			id = newID()
		}
		ch = append(ch, syncapi.ServerChange{Table: c.Table, ID: id, Fields: c.Fields, Deleted: c.Deleted})
	}
	return write(ctx, db, uid, ch...)
}

func mustUndo(changes ...undoChange) json.RawMessage {
	b, _ := json.Marshal(undoData{Changes: changes})
	return b
}

// baseTool — общая часть: схема + отмена списком изменений.
type baseTool struct {
	db   *sql.DB
	tool Tool
	run  func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error)
}

func (b *baseTool) Tool() Tool { return b.tool }
func (b *baseTool) Run(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
	return b.run(ctx, uid, in)
}
func (b *baseTool) Undo(ctx context.Context, uid string, undo json.RawMessage) error {
	return applyUndo(ctx, b.db, uid, undo)
}

func builtinTools(db *sql.DB) []ToolHandler {
	return []ToolHandler{
		&baseTool{db: db, tool: toolCreateQuest, run: func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
			return createQuest(ctx, db, uid, in, false)
		}},
		&baseTool{db: db, tool: toolUpdateQuest, run: func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
			return updateQuest(ctx, db, uid, in)
		}},
		&baseTool{db: db, tool: toolAward, run: func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
			return diamondsEvent(ctx, db, uid, in, true)
		}},
		&baseTool{db: db, tool: toolPenalty, run: func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
			return diamondsEvent(ctx, db, uid, in, false)
		}},
		&baseTool{db: db, tool: toolSetNorm, run: func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
			return setNorm(ctx, db, uid, in)
		}},
		&baseTool{db: db, tool: toolPenaltyQuest, run: func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
			return createQuest(ctx, db, uid, in, true)
		}},
		&baseTool{db: db, tool: toolLogFood, run: func(ctx context.Context, uid string, in json.RawMessage) (string, string, json.RawMessage, error) {
			return logFood(ctx, db, uid, in)
		}},
	}
}

var (
	toolCreateQuest = Tool{
		Name:        "create_quest",
		Description: "Create a new quest for the user (one-off or recurring). Rewards are computed by the app from difficulty.",
		Schema: json.RawMessage(`{"type":"object","properties":{
"title":{"type":"string","description":"Quest text in the user's language"},
"kind":{"type":"string","enum":["custom","daily","goal"]},
"stat":{"type":"string","enum":["strength","endurance","discipline","intellect","health","looks"]},
"difficulty":{"type":"string","enum":["easy","normal","hard"]},
"minute":{"type":"integer","description":"Start, minute of day 0..1439; omit for 'during the day'"},
"window_minutes":{"type":"integer","description":"Time to complete, minutes (default 60)"},
"weekdays":{"type":"array","items":{"type":"integer"},"description":"1=Mon..7=Sun; empty = every day"},
"one_off":{"type":"boolean","description":"Only today (or only on 'date')"},
"date":{"type":"string","description":"YYYY-MM-DD for a one-off quest"},
"confirm":{"type":"string","enum":["button","timer","steps"]},
"target":{"type":"integer","description":"Steps or minutes for timer/steps quests"},
"subtasks":{"type":"array","items":{"type":"string"}}},
"required":["title","difficulty"]}`),
	}
	toolUpdateQuest = Tool{
		Name:        "update_quest",
		Description: "Change an existing quest template by its id (from the context). Only given fields change.",
		Schema: json.RawMessage(`{"type":"object","properties":{
"quest_id":{"type":"string"},
"title":{"type":"string"},
"minute":{"type":"integer"},
"window_minutes":{"type":"integer"},
"weekdays":{"type":"array","items":{"type":"integer"}},
"target":{"type":"integer"},
"active":{"type":"boolean","description":"false = archive the quest"}},
"required":["quest_id"]}`),
	}
	toolAward = Tool{
		Name:        "award_diamonds",
		Description: "Give the user bonus diamonds (◆) for a real achievement mentioned in the conversation. 1..30.",
		Schema:      json.RawMessage(`{"type":"object","properties":{"amount":{"type":"integer"},"reason":{"type":"string"}},"required":["amount","reason"]}`),
	}
	toolPenalty = Tool{
		Name:        "penalty",
		Description: "Take diamonds (◆) from the user for a confessed slip (skipped training, junk food, etc.). 1..30.",
		Schema:      json.RawMessage(`{"type":"object","properties":{"amount":{"type":"integer"},"reason":{"type":"string"}},"required":["amount","reason"]}`),
	}
	toolSetNorm = Tool{
		Name:        "set_norm",
		Description: "Change a daily norm in the accepted plan. Only within safe ranges; the app validates.",
		Schema: json.RawMessage(`{"type":"object","properties":{
"norm":{"type":"string","enum":["water_ml","calories","protein_g","fat_g","carbs_g","sleep_minutes"]},
"value":{"type":"integer"},"reason":{"type":"string"}},"required":["norm","value"]}`),
	}
	toolPenaltyQuest = Tool{
		Name:        "add_penalty_quest",
		Description: "Add a penalty quest for today (cannot be cancelled), e.g. 15 min cleaning, 20 push-ups, 20 min walk. Never dangerous or humiliating.",
		Schema: json.RawMessage(`{"type":"object","properties":{
"title":{"type":"string"},"reason":{"type":"string"},
"stat":{"type":"string","enum":["strength","endurance","discipline","intellect","health","looks"]}},
"required":["title","reason"]}`),
	}
	toolLogFood = Tool{
		Name:        "log_food",
		Description: "Record a meal the user described into the food diary (estimate macros for the given portion).",
		Schema: json.RawMessage(`{"type":"object","properties":{
"title":{"type":"string"},
"meal_type":{"type":"string","enum":["breakfast","lunch","dinner","snack"]},
"grams":{"type":"number"},
"kcal":{"type":"number"},"protein":{"type":"number"},"fat":{"type":"number"},"carbs":{"type":"number"},
"time":{"type":"string","description":"HH:MM today; omit = now"}},
"required":["title","meal_type","kcal"]}`),
	}
)

var validStats = map[string]bool{"strength": true, "endurance": true, "discipline": true, "intellect": true, "health": true, "looks": true}

// Награды по сложности — как questRewards клиента (daily 5/10, goal 10/20, training 15/25).
func rewardFor(difficulty string) (diamonds, xp int) {
	switch difficulty {
	case "easy":
		return 5, 10
	case "hard":
		return 15, 25
	}
	return 10, 20
}

func clampInt(v, lo, hi int) int { return max(lo, min(hi, v)) }

func createQuest(ctx context.Context, db *sql.DB, uid string, raw json.RawMessage, penalty bool) (string, string, json.RawMessage, error) {
	var in struct {
		Title         string   `json:"title"`
		Kind          string   `json:"kind"`
		Stat          string   `json:"stat"`
		Difficulty    string   `json:"difficulty"`
		Minute        *int     `json:"minute"`
		WindowMinutes int      `json:"window_minutes"`
		Weekdays      []int    `json:"weekdays"`
		OneOff        bool     `json:"one_off"`
		Date          string   `json:"date"`
		Confirm       string   `json:"confirm"`
		Target        *int     `json:"target"`
		Subtasks      []string `json:"subtasks"`
		Reason        string   `json:"reason"`
	}
	if err := json.Unmarshal(raw, &in); err != nil {
		return "", "", nil, err
	}
	in.Title = strings.TrimSpace(in.Title)
	if in.Title == "" || len([]rune(in.Title)) > 200 {
		return "", "", nil, errors.New("title required (≤200 chars)")
	}
	loc := userLoc(ctx, db, uid)
	today := dayStart(time.Now(), loc)
	f := map[string]any{
		"title_key": nil, "title": in.Title, "params": "{}", "week_parity": 0,
		"reward_stats": "{}", "refuse_penalty_diamonds": nil, "plan_id": nil, "active": 1,
		"source": "ai", "nag": 1, "cancellable": 1, "confirm": "button", "target": nil,
		"minute": nil, "window_minutes": 60, "weekdays": "", "active_from": nil, "active_until": nil,
	}
	stat := in.Stat
	if !validStats[stat] {
		stat = ""
	}
	if stat == "" {
		f["stat"] = nil
	} else {
		f["stat"] = stat
	}
	subs, _ := json.Marshal(nonNil(in.Subtasks))
	f["subtasks"] = string(subs)
	var summary string
	if penalty {
		if stat == "" {
			f["stat"] = "discipline"
		}
		f["kind"] = "penalty"
		f["reward_diamonds"], f["reward_xp"] = 0, 10 // GameConfig.penaltyQuestReward
		f["penalty_diamonds"] = 15                   // GameConfig.penaltyQuestPenalty
		f["refuse_penalty_diamonds"] = 0
		f["cancellable"], f["nag"] = 0, 0
		f["active_from"], f["active_until"] = today.Unix(), today.Unix()
		f["window_minutes"] = 24 * 60
		summary = tr(ctx, "Система добавила штрафной квест: ", "Sistem ceza görevi ekledi: ") + in.Title
	} else {
		kind := in.Kind
		if kind != "daily" && kind != "goal" {
			kind = "custom"
		}
		f["kind"] = kind
		d, xp := rewardFor(in.Difficulty)
		f["reward_diamonds"], f["reward_xp"] = d, xp
		f["penalty_diamonds"] = max(2, d) // GameRules.failPenaltyFor
		if in.Minute != nil {
			f["minute"] = clampInt(*in.Minute, 0, 1439)
		}
		if in.WindowMinutes > 0 {
			f["window_minutes"] = clampInt(in.WindowMinutes, 5, 24*60)
		}
		f["weekdays"] = weekdaysStr(in.Weekdays)
		if in.OneOff || in.Date != "" {
			day := today
			if t, err := time.ParseInLocation("2006-01-02", in.Date, loc); err == nil && !t.Before(today) {
				day = t
			}
			f["active_from"], f["active_until"] = day.Unix(), day.Unix()
		}
		switch in.Confirm {
		case "timer", "steps":
			if in.Target != nil && *in.Target > 0 {
				f["confirm"] = in.Confirm
				f["target"] = clampInt(*in.Target, 1, 100000)
			}
		}
		summary = tr(ctx, "Система добавила квест: ", "Sistem görev ekledi: ") + in.Title
	}
	id := newID()
	if err := write(ctx, db, uid, syncapi.ServerChange{Table: "quests", ID: id, Fields: f}); err != nil {
		return "", "", nil, err
	}
	undo := mustUndo(undoChange{Table: "quests", ID: id, Fields: map[string]any{"active": 0}, Deleted: boolp(true)})
	return fmt.Sprintf(`{"ok":true,"quest_id":%q}`, id), summary, undo, nil
}

func weekdaysStr(ds []int) string {
	seen := map[int]bool{}
	var parts []string
	for d := 1; d <= 7; d++ {
		for _, x := range ds {
			if x == d && !seen[d] {
				seen[d] = true
				parts = append(parts, fmt.Sprint(d))
			}
		}
	}
	if len(parts) == 7 {
		return ""
	}
	return strings.Join(parts, ",")
}

func nonNil(s []string) []string {
	if s == nil {
		return []string{}
	}
	return s
}

func updateQuest(ctx context.Context, db *sql.DB, uid string, raw json.RawMessage) (string, string, json.RawMessage, error) {
	var in struct {
		QuestID       string  `json:"quest_id"`
		Title         *string `json:"title"`
		Minute        *int    `json:"minute"`
		WindowMinutes *int    `json:"window_minutes"`
		Weekdays      *[]int  `json:"weekdays"`
		Target        *int    `json:"target"`
		Active        *bool   `json:"active"`
	}
	if err := json.Unmarshal(raw, &in); err != nil {
		return "", "", nil, err
	}
	q, deleted, ok, err := getRecord(ctx, db, uid, "quests", in.QuestID)
	if err != nil {
		return "", "", nil, err
	}
	if !ok || deleted {
		return "", "", nil, errors.New("quest not found")
	}
	f := map[string]any{}
	if in.Title != nil && strings.TrimSpace(*in.Title) != "" {
		f["title"] = strings.TrimSpace(*in.Title)
		f["title_key"] = nil
		f["params"] = "{}"
	}
	if in.Minute != nil {
		f["minute"] = clampInt(*in.Minute, 0, 1439)
	}
	if in.WindowMinutes != nil {
		f["window_minutes"] = clampInt(*in.WindowMinutes, 5, 24*60)
	}
	if in.Weekdays != nil {
		f["weekdays"] = weekdaysStr(*in.Weekdays)
	}
	if in.Target != nil && *in.Target > 0 {
		f["target"] = clampInt(*in.Target, 1, 100000)
	}
	if in.Active != nil {
		if q.str("kind") == "penalty" && !*in.Active {
			return "", "", nil, errors.New("penalty quests cannot be cancelled")
		}
		f["active"] = b2i(*in.Active)
	}
	if len(f) == 0 {
		return "", "", nil, errors.New("nothing to change")
	}
	old := map[string]any{}
	for k := range f {
		old[k] = q.Data[k]
	}
	if err := write(ctx, db, uid, syncapi.ServerChange{Table: "quests", ID: q.ID, Fields: f}); err != nil {
		return "", "", nil, err
	}
	name := q.str("title")
	if name == "" {
		name = q.str("title_key")
	}
	summary := tr(ctx, "Система изменила квест: ", "Sistem görevi değiştirdi: ") + name
	if in.Active != nil && !*in.Active {
		summary = tr(ctx, "Система убрала квест: ", "Sistem görevi kaldırdı: ") + name
	}
	return `{"ok":true}`, summary, mustUndo(undoChange{Table: "quests", ID: q.ID, Fields: old}), nil
}

func b2i(b bool) int {
	if b {
		return 1
	}
	return 0
}

func diamondsEvent(ctx context.Context, db *sql.DB, uid string, raw json.RawMessage, award bool) (string, string, json.RawMessage, error) {
	var in struct {
		Amount int    `json:"amount"`
		Reason string `json:"reason"`
	}
	if err := json.Unmarshal(raw, &in); err != nil {
		return "", "", nil, err
	}
	if in.Amount < 1 || in.Amount > 30 {
		return "", "", nil, errors.New("amount must be 1..30")
	}
	typ, sign := "bonus", 1
	if !award {
		typ, sign = "penalty", -1
	}
	now := time.Now().Unix()
	ev := func(t string, d int, extra map[string]any) map[string]any {
		p := map[string]any{"reason": truncate(in.Reason, 200), "source": "ai"}
		for k, v := range extra {
			p[k] = v
		}
		pj, _ := json.Marshal(p)
		return map[string]any{"type": t, "occurred_at": now, "quest_id": nil, "instance_id": nil,
			"diamonds": d, "xp": 0, "stats": "{}", "payload": string(pj)}
	}
	id := newID()
	if err := write(ctx, db, uid, syncapi.ServerChange{Table: "quest_events", ID: id, Fields: ev(typ, sign*in.Amount, nil)}); err != nil {
		return "", "", nil, err
	}
	// Отмена — компенсирующее событие противоположного знака (журнал не перезаписывается).
	undoType := "penalty"
	if !award {
		undoType = "bonus"
	}
	undo := mustUndo(undoChange{Table: "quest_events", ID: "$new", Fields: ev(undoType, -sign*in.Amount, map[string]any{"undoOf": id})})
	var summary string
	if award {
		summary = fmt.Sprintf(tr(ctx, "Система начислила +%d ◆: %s", "Sistem +%d ◆ verdi: %s"), in.Amount, in.Reason)
	} else {
		summary = fmt.Sprintf(tr(ctx, "Система списала −%d ◆: %s", "Sistem −%d ◆ düştü: %s"), in.Amount, in.Reason)
	}
	return `{"ok":true}`, summary, undo, nil
}

// Нормы: ключ инструмента → ключ PlanNorms в plans.payload и безопасный диапазон.
var norms = map[string]struct {
	key    string
	lo, hi int
	ru, tr string
}{
	"water_ml":      {"waterMl", 1000, 5000, "вода, мл", "su, ml"},
	"calories":      {"calories", 1200, 4500, "калории", "kalori"},
	"protein_g":     {"proteinG", 30, 300, "белок, г", "protein, g"},
	"fat_g":         {"fatG", 30, 200, "жиры, г", "yağ, g"},
	"carbs_g":       {"carbsG", 50, 600, "углеводы, г", "karbonhidrat, g"},
	"sleep_minutes": {"sleepTargetMinutes", 360, 600, "сон, мин", "uyku, dk"},
}

// latestPlan — последний принятый план, иначе последний черновик.
func latestPlan(ctx context.Context, db *sql.DB, uid string) (rec, bool, error) {
	ps, err := listRecords(ctx, db, uid, "plans", 50)
	if err != nil {
		return rec{}, false, err
	}
	var best, draft *rec
	for i := range ps {
		p := &ps[i]
		if _, ok := p.num("accepted_at"); ok {
			if best == nil || p.int("accepted_at") > best.int("accepted_at") {
				best = p
			}
		} else if draft == nil || p.int("created_at") > draft.int("created_at") {
			draft = p
		}
	}
	if best == nil {
		best = draft
	}
	if best == nil {
		return rec{}, false, nil
	}
	return *best, true, nil
}

func setNorm(ctx context.Context, db *sql.DB, uid string, raw json.RawMessage) (string, string, json.RawMessage, error) {
	var in struct {
		Norm  string `json:"norm"`
		Value int    `json:"value"`
	}
	if err := json.Unmarshal(raw, &in); err != nil {
		return "", "", nil, err
	}
	n, ok := norms[in.Norm]
	if !ok {
		return "", "", nil, errors.New("unknown norm")
	}
	if in.Value < n.lo || in.Value > n.hi {
		return "", "", nil, fmt.Errorf("value out of safe range %d..%d", n.lo, n.hi)
	}
	plan, ok, err := latestPlan(ctx, db, uid)
	if err != nil {
		return "", "", nil, err
	}
	if !ok {
		return "", "", nil, errors.New("no plan yet")
	}
	oldPayload := plan.str("payload")
	var payload map[string]any
	if err := json.Unmarshal([]byte(oldPayload), &payload); err != nil || payload == nil {
		return "", "", nil, errors.New("plan payload unreadable")
	}
	nm, _ := payload["norms"].(map[string]any)
	if nm == nil {
		nm = map[string]any{}
	}
	nm[n.key] = in.Value
	payload["norms"] = nm
	pj, _ := json.Marshal(payload)
	changes := []syncapi.ServerChange{{Table: "plans", ID: plan.ID, Fields: map[string]any{"payload": string(pj)}}}
	undo := []undoChange{{Table: "plans", ID: plan.ID, Fields: map[string]any{"payload": oldPayload}}}
	// Квест воды из плана показывает норму в params.ml — обновляем вместе с нормой.
	if in.Norm == "water_ml" {
		qs, _ := listRecords(ctx, db, uid, "quests", 500)
		for _, q := range qs {
			if q.str("title_key") == "water" && q.int("active") == 1 {
				var params map[string]any
				_ = json.Unmarshal([]byte(q.str("params")), &params)
				if params == nil {
					params = map[string]any{}
				}
				params["ml"] = in.Value
				b, _ := json.Marshal(params)
				changes = append(changes, syncapi.ServerChange{Table: "quests", ID: q.ID, Fields: map[string]any{"params": string(b)}})
				undo = append(undo, undoChange{Table: "quests", ID: q.ID, Fields: map[string]any{"params": q.str("params")}})
			}
		}
	}
	if err := write(ctx, db, uid, changes...); err != nil {
		return "", "", nil, err
	}
	summary := fmt.Sprintf(tr(ctx, "Система изменила норму (%s): %d", "Sistem normu değiştirdi (%s): %d"), tr(ctx, n.ru, n.tr), in.Value)
	return `{"ok":true}`, summary, mustUndo(undo...), nil
}

func logFood(ctx context.Context, db *sql.DB, uid string, raw json.RawMessage) (string, string, json.RawMessage, error) {
	var in struct {
		Title    string   `json:"title"`
		MealType string   `json:"meal_type"`
		Grams    *float64 `json:"grams"`
		Kcal     float64  `json:"kcal"`
		Protein  float64  `json:"protein"`
		Fat      float64  `json:"fat"`
		Carbs    float64  `json:"carbs"`
		Time     string   `json:"time"`
	}
	if err := json.Unmarshal(raw, &in); err != nil {
		return "", "", nil, err
	}
	in.Title = strings.TrimSpace(in.Title)
	if in.Title == "" || in.Kcal < 0 || in.Kcal > 5000 {
		return "", "", nil, errors.New("bad title or kcal")
	}
	switch in.MealType {
	case "breakfast", "lunch", "dinner", "snack":
	default:
		in.MealType = "snack"
	}
	loc := userLoc(ctx, db, uid)
	at := time.Now()
	if t, err := time.ParseInLocation("15:04", in.Time, loc); err == nil {
		d := dayStart(at, loc)
		cand := d.Add(time.Duration(t.Hour())*time.Hour + time.Duration(t.Minute())*time.Minute)
		if !cand.After(at) {
			at = cand
		}
	}
	r1 := func(v float64) float64 { return math.Round(math.Max(0, v)*10) / 10 }
	f := map[string]any{
		"eaten_at": at.Unix(), "meal_type": in.MealType, "title": truncate(in.Title, 200),
		"food_item_id": nil, "recipe_id": nil, "grams": nil, "photo_id": nil,
		"kcal": r1(in.Kcal), "protein": r1(in.Protein), "fat": r1(in.Fat), "carbs": r1(in.Carbs),
	}
	if in.Grams != nil && *in.Grams > 0 {
		f["grams"] = r1(*in.Grams)
	}
	id := newID()
	if err := write(ctx, db, uid, syncapi.ServerChange{Table: "meal_entries", ID: id, Fields: f}); err != nil {
		return "", "", nil, err
	}
	summary := fmt.Sprintf(tr(ctx, "Система записала еду: %s (%.0f ккал)", "Sistem yemeği kaydetti: %s (%.0f kcal)"), in.Title, in.Kcal)
	return `{"ok":true}`, summary, mustUndo(undoChange{Table: "meal_entries", ID: id, Deleted: boolp(true)}), nil
}
