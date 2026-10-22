package ai

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/syncapi"
)

// План от ИИ (SPEC §5, §9.1). Нормы (калории, БЖУ, вода, сон) считает код клиента — берём их из последнего плана
// пользователя без изменений; ИИ выбирает квесты-черновики из ключей плана, добавляет свои квесты и советы.
// Результат — новый черновик в plans (source = 'ai', «Системное окно» → «Принять» на клиенте) + свои квесты в quests.

var errNoPlan = errors.New("no base plan")

// planQuestKeys — QuestKey клиента (features/plan/model/plan.dart) и их параметры.
var planQuestKeys = map[string]string{
	"leaveHome": "{time}", "attendLesson": "{title,time}", "attendWork": "{title,time}", "water": "{ml}",
	"sleepOnTime": "{time,hours}", "meals": "{count}", "training": "{minutes}", "skincareMorning": "",
	"skincareEvening": "", "wakeOnTime": "{time}", "study": "{minutes}", "trackExpenses": "",
}

// questRewards — как у клиента (draft_plan_builder.dart): категория → (◆, опыт).
var questRewards = map[string][2]int{
	"schedule": {10, 15}, "daily": {5, 10}, "training": {15, 25}, "health": {5, 10}, "goal": {10, 20},
}

type aiPlanOut struct {
	Summary string   `json:"summary"`
	Advice  []string `json:"advice"`
	Quests  []struct {
		Key      string         `json:"key"`
		Category string         `json:"category"`
		Params   map[string]any `json:"params"`
		Minute   *int           `json:"minute"`
		Weekdays []int          `json:"weekdays"`
		Week     int            `json:"week"`
	} `json:"quests"`
	Custom []struct {
		Title      string `json:"title"`
		Stat       string `json:"stat"`
		Difficulty string `json:"difficulty"`
		Minute     *int   `json:"minute"`
		Weekdays   []int  `json:"weekdays"`
	} `json:"custom_quests"`
}

const planInstructions = `You are the planning core of «Система», a gamified self-improvement app.
Build the user's plan from the profile, questionnaire, goals, schedule and the app-computed base plan.
The base plan's norms (calories, macros, water, sleep) are computed by the app: do NOT change them.
Return a JSON object:
{"summary": string (3-6 sentences in the user's language: what the plan focuses on and why),
 "advice": [string] (up to 5 short practical tips, user's language),
 "quests": [{"key": one of %s, "category": "schedule"|"daily"|"training"|"health"|"goal",
             "params": object (per key: %s), "minute": minute of day or null, "weekdays": [1..7] or [], "week": 0|1|2}],
 "custom_quests": [{"title": string (user's language), "stat": "strength"|"endurance"|"discipline"|"intellect"|"health"|"looks",
                    "difficulty": "easy"|"normal"|"hard", "minute": int or null, "weekdays": [1..7] or []}] (at most 5)}
Keep the plan realistic for the schedule; respect health limits and injuries; no extreme diets or overtraining.`

func (s *Service) handlePlan(w http.ResponseWriter, r *http.Request, review bool) {
	uid := authctx.UserID(r.Context())
	var req struct {
		Lang string `json:"lang"`
	}
	if r.ContentLength != 0 && !decodeBody(w, r, &req) {
		return
	}
	summary, actions, err := s.generatePlan(withLang(r.Context(), normLang(req.Lang)), uid, review)
	if errors.Is(err, errNoPlan) {
		writeError(w, http.StatusConflict, "plan_missing")
		return
	}
	if err != nil {
		s.writeAIError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"summary": summary, "actions": actions})
}

func (s *Service) generatePlan(ctx context.Context, uid string, review bool) (string, []ActionRef, error) {
	base, ok, err := latestPlan(ctx, s.db, uid)
	if err != nil {
		return "", nil, err
	}
	if !ok {
		return "", nil, errNoPlan
	}
	var payload map[string]any
	if err := json.Unmarshal([]byte(base.str("payload")), &payload); err != nil || payload == nil {
		return "", nil, errNoPlan
	}
	uc, err := buildUserContext(ctx, s.db, uid)
	if err != nil {
		return "", nil, err
	}
	keys := make([]string, 0, len(planQuestKeys))
	var params []string
	for k, p := range planQuestKeys {
		keys = append(keys, k)
		if p != "" {
			params = append(params, k+" "+p)
		}
	}
	sort.Strings(keys) // стабильный системный промпт — кэш
	sort.Strings(params)
	language := "Russian"
	if langOf(ctx) == "tr" {
		language = "Turkish"
	}
	sched := scheduleContext(ctx, s.db, uid)
	basePlan := map[string]any{"norms": payload["norms"], "weeks": payload["weeks"], "quests": payload["quests"], "warnings": payload["warnings"]}
	task := "Create the full plan after onboarding."
	if review {
		task = "Weekly review: adjust the plan using the last 7 days of results (completion rates below). " +
			"Make failing quests easier or reschedule them, raise the bar a little where everything is done."
	}
	user := task + " User language: " + language + ".\n\nSCHEDULE:\n" + sched +
		"\nBASE PLAN (app-computed):\n" + compactJSON(basePlan, 12000)
	if review {
		user += "\n\nLAST 7 DAYS:\n" + weekStats(ctx, s.db, uid)
	}
	req := Request{
		System: []SystemBlock{
			{Text: fmt.Sprintf(planInstructions, strings.Join(keys, ", "), strings.Join(params, "; ")), Cache: true},
			{Text: uc.Profile, Cache: true},
			{Text: uc.Today},
		},
		Messages:  []Message{{Role: RoleUser, Parts: []Part{{Text: user}}}},
		MaxTokens: 8000,
		JSON:      true,
	}
	resp, err := s.Do(ctx, uid, TaskPlan, req)
	if err != nil {
		return "", nil, err
	}
	var out aiPlanOut
	if err := json.Unmarshal([]byte(resp.Text), &out); err != nil {
		return "", nil, fmt.Errorf("plan json: %w", err)
	}

	// Черновики квестов плана: только известные ключи; награды — код.
	var drafts []map[string]any
	for _, q := range out.Quests {
		if _, ok := planQuestKeys[q.Key]; !ok {
			continue
		}
		rw, ok := questRewards[q.Category]
		if !ok {
			q.Category, rw = "daily", questRewards["daily"]
		}
		d := map[string]any{"key": q.Key, "category": q.Category, "diamonds": rw[0], "xp": rw[1]}
		if len(q.Params) > 0 {
			d["params"] = q.Params
		}
		if q.Minute != nil {
			d["minute"] = clampInt(*q.Minute, 0, 1439)
		}
		if wd := validWeekdays(q.Weekdays); len(wd) > 0 && len(wd) < 7 {
			d["weekdays"] = wd
		}
		if q.Week == 1 || q.Week == 2 {
			d["week"] = q.Week
		}
		// Вода — норма из плана (код), не из ответа модели.
		if q.Key == "water" {
			if nm, ok := payload["norms"].(map[string]any); ok && nm["waterMl"] != nil {
				d["params"] = map[string]any{"ml": nm["waterMl"]}
			}
		}
		drafts = append(drafts, d)
	}
	if len(drafts) > 0 {
		payload["quests"] = drafts
	}
	now := time.Now()
	payload["generatedAt"] = now.UTC().Format(time.RFC3339)
	payload["ai"] = map[string]any{"summary": out.Summary, "advice": out.Advice, "review": review, "model": resp.Model}
	pj, _ := json.Marshal(payload)
	planID := newID()
	changes := []syncapi.ServerChange{{Table: "plans", ID: planID, Fields: map[string]any{
		"created_at": now.Unix(), "accepted_at": nil, "source": "ai", "payload": string(pj),
	}}}
	undo := []undoChange{{Table: "plans", ID: planID, Deleted: boolp(true)}}

	// Свои квесты ИИ (вне ключей плана) — сразу в quests (source = 'ai', plan_id).
	if len(out.Custom) > 5 {
		out.Custom = out.Custom[:5]
	}
	for _, c := range out.Custom {
		title := strings.TrimSpace(c.Title)
		if title == "" {
			continue
		}
		d, xp := rewardFor(c.Difficulty)
		f := map[string]any{
			"kind": "goal", "stat": nil, "title_key": nil, "title": truncate(title, 200), "params": "{}", "subtasks": "[]",
			"minute": nil, "window_minutes": 60, "weekdays": weekdaysStr(c.Weekdays), "week_parity": 0,
			"active_from": nil, "active_until": nil, "reward_diamonds": d, "reward_xp": xp, "reward_stats": "{}",
			"penalty_diamonds": max(2, d), "refuse_penalty_diamonds": nil, "confirm": "button", "target": nil,
			"nag": 1, "cancellable": 1, "source": "ai", "plan_id": planID, "active": 1,
		}
		if validStats[c.Stat] {
			f["stat"] = c.Stat
		}
		if c.Minute != nil {
			f["minute"] = clampInt(*c.Minute, 0, 1439)
		}
		id := newID()
		changes = append(changes, syncapi.ServerChange{Table: "quests", ID: id, Fields: f})
		undo = append(undo, undoChange{Table: "quests", ID: id, Fields: map[string]any{"active": 0}, Deleted: boolp(true)})
	}
	if err := write(ctx, s.db, uid, changes...); err != nil {
		return "", nil, err
	}
	tool, sum := "plan_generate", tr(ctx, "Система составила новый план (ждёт принятия)", "Sistem yeni plan hazırladı (onay bekliyor)")
	if review {
		tool, sum = "plan_review", tr(ctx, "Система пересмотрела план на неделю (ждёт принятия)", "Sistem haftalık planı güncelledi (onay bekliyor)")
	}
	input, _ := json.Marshal(map[string]any{"plan_id": planID, "base_plan_id": base.ID})
	ref, err := s.logAction(ctx, uid, tool, input, sum, mustUndo(undo...))
	actions := []ActionRef{}
	if err == nil && ref != nil {
		actions = append(actions, *ref)
	}
	return out.Summary, actions, nil
}

func validWeekdays(ds []int) []int {
	var out []int
	seen := map[int]bool{}
	for _, d := range ds {
		if d >= 1 && d <= 7 && !seen[d] {
			seen[d] = true
			out = append(out, d)
		}
	}
	return out
}

// scheduleContext — расписание (schedule_settings, schedule_items) кратко.
func scheduleContext(ctx context.Context, db *sql.DB, uid string) string {
	var b strings.Builder
	if ss, err := listRecords(ctx, db, uid, "schedule_settings", 1); err == nil && len(ss) > 0 {
		d := map[string]any{}
		for _, k := range []string{"institution_type", "alternation_enabled", "wake_minute", "bed_minute", "commute_minutes", "weekend_days"} {
			d[k] = ss[0].Data[k]
		}
		b.WriteString("settings: " + compactJSON(d, 500) + "\n")
	}
	if items, err := listRecords(ctx, db, uid, "schedule_items", 100); err == nil && len(items) > 0 {
		var list []map[string]any
		for _, it := range items {
			list = append(list, map[string]any{"kind": it.Data["kind"], "title": it.Data["title"], "weekday": it.Data["weekday"],
				"start": it.Data["start_minute"], "dur": it.Data["duration_minutes"], "week": it.Data["week_parity"]})
		}
		b.WriteString("items: " + compactJSON(list, 5000) + "\n")
	}
	if b.Len() == 0 {
		return "none\n"
	}
	return b.String()
}

// weekStats — выполнение квестов за 7 дней: по шаблону done/failed/refused (считает код).
func weekStats(ctx context.Context, db *sql.DB, uid string) string {
	since := time.Now().Add(-7 * 24 * time.Hour).Unix()
	insts, _ := listRecords(ctx, db, uid, "quest_instances", 1000)
	quests, _ := listRecords(ctx, db, uid, "quests", 300)
	names := map[string]string{}
	for _, q := range quests {
		names[q.ID] = questTitle(q)
	}
	type st struct{ Done, Failed, Refused, Total int }
	stats := map[string]*st{}
	for _, in := range insts {
		if in.int("day") < since {
			continue
		}
		name := names[in.str("quest_id")]
		if name == "" {
			name = in.str("quest_id")
		}
		x := stats[name]
		if x == nil {
			x = &st{}
			stats[name] = x
		}
		x.Total++
		switch in.str("status") {
		case "done":
			x.Done++
		case "failed":
			x.Failed++
		case "refused":
			x.Refused++
		}
	}
	return compactJSON(stats, 5000)
}

// WeeklyReview — задача планировщика: недельный пересмотр планов пользователей с принятым планом
// (не чаще раза в 6 дней на пользователя).
func (s *Service) WeeklyReview(ctx context.Context) error {
	if s.anthropic == nil {
		return nil
	}
	rows, err := s.db.QueryContext(ctx,
		`SELECT DISTINCT user_id FROM records WHERE tbl = 'plans' AND deleted_at IS NULL
		 AND json_extract(data, '$.accepted_at') IS NOT NULL`)
	if err != nil {
		return err
	}
	var users []string
	for rows.Next() {
		var u string
		if rows.Scan(&u) == nil {
			users = append(users, u)
		}
	}
	rows.Close()
	cutoff := time.Now().Add(-6 * 24 * time.Hour).UnixMilli()
	var errs []error
	for _, uid := range users {
		var n int
		_ = s.db.QueryRowContext(ctx,
			`SELECT COUNT(*) FROM ai_actions WHERE user_id = ? AND tool = 'plan_review' AND at >= ?`, uid, cutoff).Scan(&n)
		if n > 0 {
			continue
		}
		lang := "ru"
		if ps, _ := listRecords(ctx, s.db, uid, "profiles", 1); len(ps) > 0 && ps[0].str("locale") == "tr" {
			lang = "tr"
		}
		if _, _, err := s.generatePlan(withLang(ctx, lang), uid, true); err != nil {
			if errors.Is(err, ErrBudget) || errors.Is(err, ErrUnavailable) {
				return err
			}
			s.opts.Logger.Warn("weekly review", "user", uid, "err", err)
			errs = append(errs, err)
		}
	}
	return errors.Join(errs...)
}
