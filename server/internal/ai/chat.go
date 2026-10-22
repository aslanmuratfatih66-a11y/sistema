package ai

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

const (
	maxChatMessages = 30
	maxChatText     = 4000
	chatToolSteps   = 4
)

type chatReq struct {
	Messages []struct {
		Role string `json:"role"`
		Text string `json:"text"`
	} `json:"messages"`
	Character struct {
		Archetype  string `json:"archetype"`
		Motivation string `json:"motivation"`
		Name       string `json:"name"`
	} `json:"character"`
	Lang string `json:"lang"`
}

func normLang(l string) string {
	if l == "tr" {
		return "tr"
	}
	return "ru"
}

var archetypes = map[string]string{
	"animeGirl":      "an energetic, warm anime-style girl: lively, teasing, emotional, uses short exclamations",
	"animeGuy":       "a confident anime-style guy: sporty, competitive, friendly rival tone, likes challenges",
	"stoicStrongman": "an imperturbable strongman: calm, laconic, few words, heavy and steady, dry humour",
	"grimSwordsman":  "a grim swordsman: stern, terse, talks about discipline and the path, dark but caring",
}

var motivations = map[string]string{
	"soft":   "Soft mode: gentle, supportive, praise every step, never scold.",
	"normal": "Normal mode: friendly but honest; point out slips calmly and suggest the next step.",
	"strict": "Strict mode: demanding coach; call out excuses directly, insist on doing the quest now.",
	"harsh": "Harsh mode: scold with full severity like a drill sergeant about laziness and broken promises. " +
		"NEVER insult appearance, body, weight or health, never humiliate the person, never give dangerous advice " +
		"(starvation, dehydration, overtraining, self-harm). Severity is about actions, not the person.",
}

// characterBlock — правила персонажа (стабильны для пользователя → кэшируются).
func characterBlock(archetype, motivation, name, lang string) string {
	a, ok := archetypes[archetype]
	if !ok {
		a = archetypes["animeGirl"]
	}
	m, ok := motivations[motivation]
	if !ok {
		m = motivations["normal"]
	}
	language := "Russian"
	if lang == "tr" {
		language = "Turkish"
	}
	who := "the System's companion character"
	if strings.TrimSpace(name) != "" {
		who = fmt.Sprintf("%q, the System's companion character", truncate(name, 40))
	}
	return "You are " + who + " in a gamified self-improvement app called «Система» (Solo-Leveling style quests, ◆ diamonds, XP, stats).\n" +
		"Personality: " + a + ". Original character, never claim to be an existing anime character.\n" +
		m + "\n" +
		"Always reply in " + language + ", in character, briefly (1–4 sentences, spoken style — replies are voiced by TTS; no markdown, no lists unless asked).\n" +
		"Rules:\n" +
		"- Numbers (calories, norms, ◆ balance, money) come from the context below, computed by the app; do not invent or recompute them.\n" +
		"- Use tools only when the user clearly asks or confesses something that warrants it (a slip → penalty or penalty quest in strict/harsh modes; " +
		"an achievement → small award; a described meal → log_food; a request to change the plan → create/update quest or set_norm). " +
		"Keep norms within healthy ranges; never push extreme diets or overtraining.\n" +
		"- After using tools, mention briefly what you changed. Every change is visible to the user and can be undone.\n" +
		"- Medical symptoms: advise seeing a doctor; no diagnoses.\n" +
		"- If asked about places/routes (e.g. no water — nearest shop), suggest a walk quest; the app handles maps."
}

func (s *Service) handleChat(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	var req chatReq
	if !decodeBody(w, r, &req) {
		return
	}
	lang := normLang(req.Lang)
	if len(req.Messages) > maxChatMessages {
		req.Messages = req.Messages[len(req.Messages)-maxChatMessages:]
	}
	var msgs []Message
	for _, m := range req.Messages {
		t := strings.TrimSpace(m.Text)
		if t == "" {
			continue
		}
		role := RoleUser
		if m.Role == "assistant" {
			role = RoleAssistant
		}
		t = truncate(t, maxChatText)
		// Подряд идущие реплики одной роли склеиваем (API требует чередования).
		if n := len(msgs); n > 0 && msgs[n-1].Role == role {
			msgs[n-1].Parts[0].Text += "\n" + t
			continue
		}
		msgs = append(msgs, Message{Role: role, Parts: []Part{{Text: t}}})
	}
	for len(msgs) > 0 && msgs[0].Role != RoleUser {
		msgs = msgs[1:]
	}
	if len(msgs) == 0 || msgs[len(msgs)-1].Role != RoleUser {
		writeError(w, http.StatusBadRequest, "last message must be from user")
		return
	}
	ctx := withLang(r.Context(), lang)
	uc, err := buildUserContext(ctx, s.db, uid)
	if err != nil {
		s.opts.Logger.Error("ai chat context", "err", err)
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	system := []SystemBlock{
		{Text: characterBlock(req.Character.Archetype, req.Character.Motivation, req.Character.Name, lang), Cache: true},
		{Text: uc.Profile, Cache: true},
		{Text: uc.Plan, Cache: true},
		{Text: uc.Today},
	}
	var tools []Tool
	for _, name := range []string{"create_quest", "update_quest", "award_diamonds", "penalty", "set_norm", "add_penalty_quest", "log_food"} {
		if h, ok := s.tools[name]; ok {
			tools = append(tools, h.Tool())
		}
	}
	reply, actions, err := s.toolLoop(ctx, uid, TaskChat, Request{System: system, Messages: msgs, Tools: tools, MaxTokens: 2048})
	if err != nil {
		s.writeAIError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"reply": reply, "actions": actions})
}

// toolLoop — вызов модели с инструментами, до chatToolSteps шагов.
func (s *Service) toolLoop(ctx context.Context, uid string, task Task, req Request) (string, []ActionRef, error) {
	actions := []ActionRef{}
	var text string
	for step := 0; step < chatToolSteps; step++ {
		resp, err := s.Do(ctx, uid, task, req)
		if err != nil {
			if len(actions) > 0 {
				// Действия уже применены — вернём их, даже если финальный ответ не получен.
				return text, actions, nil
			}
			return "", nil, err
		}
		if resp.Text != "" {
			text = resp.Text
		}
		if len(resp.ToolCalls) == 0 || step == chatToolSteps-1 {
			break
		}
		call := Message{Role: RoleAssistant}
		if resp.Text != "" {
			call.Parts = append(call.Parts, Part{Text: resp.Text})
		}
		results := Message{Role: RoleUser}
		for _, tc := range resp.ToolCalls {
			tc := tc
			call.Parts = append(call.Parts, Part{ToolCall: &tc})
			res, ref := s.runTool(ctx, uid, tc)
			results.Parts = append(results.Parts, Part{ToolResult: &res})
			if ref != nil {
				actions = append(actions, *ref)
			}
		}
		req.Messages = append(req.Messages, call, results)
	}
	return text, actions, nil
}

// userContext — блоки контекста из records пользователя.
type userContext struct {
	Profile string // профиль, цели, анкета (кэш)
	Plan    string // нормы и распорядок плана (кэш)
	Today   string // время, квесты на сегодня, события, еда/вода, баланс (без кэша)
}

func buildUserContext(ctx context.Context, db *sql.DB, uid string) (userContext, error) {
	var uc userContext
	loc := userLoc(ctx, db, uid)
	now := time.Now().In(loc)

	// --- профиль ---
	var b strings.Builder
	b.WriteString("USER PROFILE (from the app):\n")
	if ps, err := listRecords(ctx, db, uid, "profiles", 1); err == nil && len(ps) > 0 {
		p := ps[0]
		fields := map[string]any{}
		for _, k := range []string{"name", "sex", "city", "height_cm", "activity_level", "workload", "timezone", "locale"} {
			if v, ok := p.Data[k]; ok && v != nil && v != "" {
				fields[k] = v
			}
		}
		if bd, ok := p.num("birth_date"); ok {
			fields["age"] = int(now.Sub(time.Unix(int64(bd), 0)).Hours() / 24 / 365.25)
		}
		b.WriteString("profile: " + compactJSON(fields, 800) + "\n")
	}
	if ms, err := listRecords(ctx, db, uid, "body_measurements", 20); err == nil && len(ms) > 0 {
		sort.Slice(ms, func(i, j int) bool { return ms[i].int("measured_at") > ms[j].int("measured_at") })
		m := ms[0]
		keep := map[string]any{"date": time.Unix(m.int("measured_at"), 0).In(loc).Format("2006-01-02")}
		for _, k := range []string{"weight_kg", "waist_cm", "body_fat_pct"} {
			if v, ok := m.Data[k]; ok && v != nil {
				keep[k] = v
			}
		}
		b.WriteString("latest measurement: " + compactJSON(keep, 300) + "\n")
	}
	if gs, err := listRecords(ctx, db, uid, "goals", 20); err == nil && len(gs) > 0 {
		var goals []map[string]any
		for _, g := range gs {
			goals = append(goals, map[string]any{"kind": g.Data["kind"], "title": g.Data["title"], "priority": g.Data["priority"]})
		}
		b.WriteString("goals: " + compactJSON(goals, 800) + "\n")
	}
	if qs, err := listRecords(ctx, db, uid, "questionnaire_sections", 20); err == nil {
		sort.Slice(qs, func(i, j int) bool { return qs[i].ID < qs[j].ID })
		for _, q := range qs {
			if q.ID == "permissions" || q.ID == "character" {
				continue
			}
			b.WriteString("questionnaire." + q.ID + ": " + truncate(q.str("payload"), 700) + "\n")
		}
	}
	uc.Profile = b.String()

	// --- план ---
	b.Reset()
	b.WriteString("CURRENT PLAN:\n")
	if plan, ok, err := latestPlan(ctx, db, uid); err == nil && ok {
		var payload map[string]any
		_ = json.Unmarshal([]byte(plan.str("payload")), &payload)
		accepted := "draft"
		if _, ok := plan.num("accepted_at"); ok {
			accepted = "accepted"
		}
		b.WriteString("status: " + accepted + ", source: " + plan.str("source") + "\n")
		b.WriteString("norms: " + compactJSON(payload["norms"], 600) + "\n")
		if ai, ok := payload["ai"].(map[string]any); ok {
			b.WriteString("plan notes: " + compactJSON(ai["summary"], 800) + "\n")
		}
	} else {
		b.WriteString("no plan yet\n")
	}
	uc.Plan = b.String()

	// --- сегодня (динамика) ---
	b.Reset()
	fmt.Fprintf(&b, "NOW: %s (%s, weekday %d)\n", now.Format("2006-01-02 15:04"), now.Weekday(), isoWeekday(now))
	quests, _ := listRecords(ctx, db, uid, "quests", 300)
	qByID := map[string]rec{}
	var active []map[string]any
	for _, q := range quests {
		qByID[q.ID] = q
		if q.int("active") != 1 {
			continue
		}
		if until, ok := q.num("active_until"); ok && int64(until) < dayStart(now, loc).Add(-14*time.Hour).Unix() {
			continue
		}
		active = append(active, map[string]any{"id": q.ID, "title": questTitle(q), "kind": q.Data["kind"],
			"minute": q.Data["minute"], "weekdays": q.Data["weekdays"], "reward": q.Data["reward_diamonds"]})
	}
	if len(active) > 60 {
		active = active[:60]
	}
	b.WriteString("active quest templates (id, title, kind, minute of day, weekdays): " + compactJSON(active, 6000) + "\n")

	start := dayStart(now, loc)
	insts, _ := listRecords(ctx, db, uid, "quest_instances", 400)
	var today []map[string]any
	for _, in := range insts {
		d := in.int("day")
		if d < start.Add(-14*time.Hour).Unix() || d > start.Add(14*time.Hour).Unix() {
			continue
		}
		item := map[string]any{"quest_id": in.str("quest_id"), "status": in.str("status")}
		if q, ok := qByID[in.str("quest_id")]; ok {
			item["title"] = questTitle(q)
		}
		if dl, ok := in.num("deadline_at"); ok {
			item["deadline"] = time.Unix(int64(dl), 0).In(loc).Format("15:04")
		}
		today = append(today, item)
	}
	b.WriteString("today's quests: " + compactJSON(today, 4000) + "\n")

	// Баланс ◆ и последние события — суммы считает код.
	var balance sql.NullFloat64
	_ = db.QueryRowContext(ctx,
		`SELECT SUM(json_extract(data, '$.diamonds')) FROM records WHERE user_id = ? AND tbl = 'quest_events' AND deleted_at IS NULL`,
		uid).Scan(&balance)
	fmt.Fprintf(&b, "diamond balance: %d ◆\n", int64(balance.Float64))
	evs, _ := listRecords(ctx, db, uid, "quest_events", 60)
	sort.Slice(evs, func(i, j int) bool { return evs[i].int("occurred_at") > evs[j].int("occurred_at") })
	var recent []map[string]any
	for i, e := range evs {
		if i >= 15 {
			break
		}
		recent = append(recent, map[string]any{"type": e.Data["type"], "diamonds": e.Data["diamonds"],
			"at": time.Unix(e.int("occurred_at"), 0).In(loc).Format("01-02 15:04"), "payload": truncate(e.str("payload"), 120)})
	}
	b.WriteString("recent events: " + compactJSON(recent, 2500) + "\n")

	var kcal, prot float64
	meals, _ := listRecords(ctx, db, uid, "meal_entries", 200)
	for _, m := range meals {
		if m.int("eaten_at") >= start.Unix() {
			k, _ := m.num("kcal")
			p, _ := m.num("protein")
			kcal += k
			prot += p
		}
	}
	var water int64
	ws, _ := listRecords(ctx, db, uid, "water_logs", 200)
	for _, wl := range ws {
		if wl.int("logged_at") >= start.Unix() {
			water += wl.int("ml")
		}
	}
	fmt.Fprintf(&b, "eaten today: %.0f kcal, protein %.0f g; water today: %d ml\n", kcal, prot, water)
	if fin, _, ok, _ := getRecord(ctx, db, uid, "questionnaire_sections", "finance"); ok {
		b.WriteString("finances (questionnaire): " + truncate(fin.str("payload"), 500) + "\n")
	}
	uc.Today = b.String()
	return uc, nil
}

func isoWeekday(t time.Time) int {
	if t.Weekday() == time.Sunday {
		return 7
	}
	return int(t.Weekday())
}

// questTitle — свой текст или ключ локализации с параметрами.
func questTitle(q rec) string {
	if t := q.str("title"); t != "" {
		return t
	}
	k := q.str("title_key")
	if p := q.str("params"); p != "" && p != "{}" {
		k += " " + p
	}
	return k
}
