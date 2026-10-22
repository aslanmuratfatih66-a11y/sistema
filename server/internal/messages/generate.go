package messages

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"
	_ "time/tzdata" // пояса пользователей (IANA) без системной базы

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/ai"
)

// genHints — подсказки клиента, если в профиле нет языка/пояса.
type genHints struct {
	lang     string
	tzOffset *int
}

// userCtx — то, что нужно для промпта: язык, пояс, персонаж, режим мотивации.
type userCtx struct {
	name       string
	lang       string
	loc        *time.Location
	archetype  string
	motivation string
}

type questInfo struct {
	instanceID string
	title      string
	starts     *time.Time
	deadline   time.Time
	penalty    int
}

// slot — что нужно сгенерировать.
type slot struct {
	key   string // для сопоставления ответа модели
	kind  string // briefing | cheer | reproach
	at    time.Time
	quest *questInfo
}

const (
	reproachDelay = 15 * time.Minute
	cheerGap      = 90 * time.Minute
)

// Утренний брифинг и подбадривания — по местному времени пользователя (минуты суток).
var (
	briefingMinute = 7*60 + 30
	cheerMinutes   = []int{10*60 + 30, 14*60 + 30, 18*60 + 30}
)

// generateFor — недостающие сообщения пользователя на окно [now, now+12 ч]. Возвращает число новых.
func (s *Service) generateFor(ctx context.Context, uid string, now time.Time, h genHints) (int, error) {
	s.mu.Lock()
	if s.busy[uid] {
		s.mu.Unlock()
		return 0, nil
	}
	s.busy[uid] = true
	s.mu.Unlock()
	defer func() {
		s.mu.Lock()
		delete(s.busy, uid)
		s.mu.Unlock()
	}()

	u, err := s.loadUser(ctx, uid, h)
	if err != nil {
		return 0, err
	}
	quests, err := s.upcomingQuests(ctx, uid, now)
	if err != nil {
		return 0, err
	}
	slots, err := s.missingSlots(ctx, uid, now, u.loc, quests)
	if err != nil || len(slots) == 0 {
		return 0, err
	}
	texts, err := s.askTexts(ctx, uid, u, now, quests, slots)
	if err != nil {
		return 0, err
	}
	created := now.UnixMilli()
	n := 0
	for _, sl := range slots {
		t, ok := texts[sl.key]
		if !ok || strings.TrimSpace(t.Body) == "" {
			continue
		}
		var ref any
		if sl.quest != nil {
			ref = sl.quest.instanceID
		}
		if _, err := s.db.ExecContext(ctx,
			`INSERT INTO messages (id, user_id, kind, deliver_at, quest_ref, title, body, created_at)
			 VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
			newID(), uid, sl.kind, sl.at.UnixMilli(), ref, cut(t.Title, 80), cut(t.Body, 400), created); err != nil {
			return n, err
		}
		n++
	}
	return n, nil
}

// ---- данные пользователя (records — JSON колонок клиента, snake_case) ----

func (s *Service) recordData(ctx context.Context, uid, tbl, id string) (map[string]any, error) {
	q := `SELECT data FROM records WHERE user_id = ? AND tbl = ? AND deleted_at IS NULL`
	args := []any{uid, tbl}
	if id != "" {
		q += ` AND id = ?`
		args = append(args, id)
	}
	q += ` ORDER BY updated_at DESC LIMIT 1`
	var raw string
	err := s.db.QueryRowContext(ctx, q, args...).Scan(&raw)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var m map[string]any
	if json.Unmarshal([]byte(raw), &m) != nil {
		return nil, nil
	}
	return m, nil
}

func str(m map[string]any, k string) string {
	if v, ok := m[k].(string); ok {
		return v
	}
	return ""
}

func (s *Service) loadUser(ctx context.Context, uid string, h genHints) (userCtx, error) {
	u := userCtx{lang: "ru", motivation: "normal"}
	p, err := s.recordData(ctx, uid, "profiles", "")
	if err != nil {
		return u, err
	}
	u.name = str(p, "name")
	switch lang := str(p, "locale"); {
	case lang == "ru" || lang == "tr":
		u.lang = lang
	case h.lang == "ru" || h.lang == "tr":
		u.lang = h.lang
	}
	u.loc = parseZone(str(p, "timezone"))
	if u.loc == nil && h.tzOffset != nil && *h.tzOffset >= -14*60 && *h.tzOffset <= 14*60 {
		u.loc = time.FixedZone("client", *h.tzOffset*60)
	}
	if u.loc == nil {
		u.loc = time.FixedZone("UTC+3", 3*3600) // TODO: пояс по умолчанию — Москва/Стамбул
	}
	// Персонаж — раздел анкеты character (QuestionnaireSections.payload — JSON-строка).
	c, err := s.recordData(ctx, uid, "questionnaire_sections", "character")
	if err != nil {
		return u, err
	}
	var ch map[string]any
	if raw := str(c, "payload"); raw != "" {
		_ = json.Unmarshal([]byte(raw), &ch)
	}
	u.archetype = str(ch, "archetype")
	if m := str(ch, "motivation"); m == "soft" || m == "normal" || m == "strict" || m == "harsh" {
		u.motivation = m
	}
	return u, nil
}

var offsetRe = regexp.MustCompile(`^(?i:UTC|GMT)?\s*([+-])(\d{1,2})(?::?(\d{2}))?$`)

// parseZone — IANA («Europe/Istanbul») или смещение («UTC+3», «+03:00»). nil — не разобрать.
func parseZone(s string) *time.Location {
	s = strings.TrimSpace(s)
	if s == "" {
		return nil
	}
	if loc, err := time.LoadLocation(s); err == nil {
		return loc
	}
	m := offsetRe.FindStringSubmatch(s)
	if m == nil {
		return nil
	}
	hh, _ := strconv.Atoi(m[2])
	mm, _ := strconv.Atoi(m[3])
	off := hh*3600 + mm*60
	if m[1] == "-" {
		off = -off
	}
	if hh > 14 {
		return nil
	}
	return time.FixedZone(s, off)
}

// unixTime — DateTime Drift (секунды); на всякий случай понимает и миллисекунды.
func unixTime(v any) (time.Time, bool) {
	f, ok := v.(float64)
	if !ok || f <= 0 {
		return time.Time{}, false
	}
	if f > 1e11 {
		return time.UnixMilli(int64(f)), true
	}
	return time.Unix(int64(f), 0), true
}

// upcomingQuests — незакрытые экземпляры, упрёк по которым (дедлайн+15 мин) попадает в окно.
func (s *Service) upcomingQuests(ctx context.Context, uid string, now time.Time) ([]questInfo, error) {
	from := now.Add(-reproachDelay).Unix()
	to := now.Add(window - reproachDelay).Unix()
	rows, err := s.db.QueryContext(ctx,
		`SELECT i.id, i.data, q.data FROM records i
		 LEFT JOIN records q ON q.user_id = i.user_id AND q.tbl = 'quests' AND q.id = json_extract(i.data, '$.quest_id')
		 WHERE i.user_id = ? AND i.tbl = 'quest_instances' AND i.deleted_at IS NULL
		   AND json_extract(i.data, '$.status') = 'pending'
		   AND json_extract(i.data, '$.deadline_at') BETWEEN ? AND ?
		 ORDER BY json_extract(i.data, '$.deadline_at') LIMIT 40`, uid, from, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []questInfo
	for rows.Next() {
		var id, iraw string
		var qraw sql.NullString
		if err := rows.Scan(&id, &iraw, &qraw); err != nil {
			return nil, err
		}
		var inst, quest map[string]any
		if json.Unmarshal([]byte(iraw), &inst) != nil {
			continue
		}
		if qraw.Valid {
			_ = json.Unmarshal([]byte(qraw.String), &quest)
		}
		dl, ok := unixTime(inst["deadline_at"])
		if !ok {
			continue
		}
		qi := questInfo{instanceID: id, deadline: dl, title: questTitle(quest)}
		if st, ok := unixTime(inst["starts_at"]); ok {
			qi.starts = &st
		}
		if p, ok := inst["penalty_diamonds"].(float64); ok {
			qi.penalty = int(p)
		}
		out = append(out, qi)
	}
	return out, rows.Err()
}

// questTitle — свой текст или ключ плана (модель поймёт «water», «workout» и т. п.) с параметрами.
func questTitle(q map[string]any) string {
	if t := strings.TrimSpace(str(q, "title")); t != "" {
		return cut(t, 120)
	}
	key := str(q, "title_key")
	if key == "" {
		return "task"
	}
	if p := str(q, "params"); p != "" && p != "{}" {
		return cut(key+" "+p, 160)
	}
	return key
}

// missingSlots — что ещё не сгенерировано в окне: брифинг, подбадривания, упрёки.
func (s *Service) missingSlots(ctx context.Context, uid string, now time.Time, loc *time.Location, quests []questInfo) ([]slot, error) {
	end := now.Add(window)
	// Существующие сообщения: с запасом на сутки назад (брифинг сегодняшнего утра).
	rows, err := s.db.QueryContext(ctx,
		`SELECT kind, deliver_at, COALESCE(quest_ref, '') FROM messages
		 WHERE user_id = ? AND deliver_at >= ? AND deliver_at < ?`,
		uid, now.Add(-24*time.Hour).UnixMilli(), end.Add(24*time.Hour).UnixMilli())
	if err != nil {
		return nil, err
	}
	type ex struct {
		kind string
		at   time.Time
	}
	var have []ex
	reproached := map[string]bool{}
	for rows.Next() {
		var e ex
		var ms int64
		var ref string
		if err := rows.Scan(&e.kind, &ms, &ref); err != nil {
			rows.Close()
			return nil, err
		}
		e.at = time.UnixMilli(ms)
		have = append(have, e)
		if e.kind == "reproach" && ref != "" {
			reproached[ref] = true
		}
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return nil, err
	}

	var out []slot
	local := now.In(loc)
	for d := 0; d <= 1; d++ {
		day := time.Date(local.Year(), local.Month(), local.Day()+d, 0, 0, 0, 0, loc)
		// Брифинг: один на местные сутки, если утро ещё впереди.
		at := day.Add(time.Duration(briefingMinute) * time.Minute)
		if at.After(now.Add(5*time.Minute)) && at.Before(end) {
			dup := false
			for _, e := range have {
				if e.kind == "briefing" && !e.at.Before(day) && e.at.Before(day.AddDate(0, 0, 1)) {
					dup = true
				}
			}
			if !dup {
				out = append(out, slot{key: fmt.Sprintf("b%d", d), kind: "briefing", at: at})
			}
		}
		for i, m := range cheerMinutes {
			at := day.Add(time.Duration(m) * time.Minute)
			if !at.After(now.Add(10*time.Minute)) || !at.Before(end) {
				continue
			}
			dup := false
			for _, e := range have {
				if e.kind == "cheer" && absDur(e.at.Sub(at)) < cheerGap {
					dup = true
				}
			}
			if !dup {
				out = append(out, slot{key: fmt.Sprintf("c%d_%d", d, i), kind: "cheer", at: at})
			}
		}
	}
	for i := range quests {
		q := &quests[i]
		at := q.deadline.Add(reproachDelay)
		if reproached[q.instanceID] || !at.After(now) || at.After(end) {
			continue
		}
		out = append(out, slot{key: fmt.Sprintf("r%d", i), kind: "reproach", at: at, quest: q})
	}
	return out, nil
}

func absDur(d time.Duration) time.Duration {
	if d < 0 {
		return -d
	}
	return d
}

// ---- промпт ----

var archetypes = map[string]string{
	"animeGirl":      "an original cheerful anime-style girl: bright, warm, playful, emotional, uses lively exclamations",
	"animeGuy":       "an original energetic anime-style guy: confident, competitive, a friendly rival who pushes you forward",
	"stoicStrongman": "an original stoic strongman: calm, laconic, few heavy words, unshakable discipline",
	"grimSwordsman":  "an original grim swordsman: gloomy, terse, speaks of discipline like a blade, dry dark humor",
}

var motivations = map[string]string{
	"soft":   "soft: gentle, supportive, never scolds, only encourages",
	"normal": "normal: friendly but demanding, light reproach when a task is missed",
	"strict": "strict: firm, demanding, clear disappointment on misses",
	"harsh":  "harsh: scolds with full severity like a drill sergeant — but never mocks appearance or health, no insults about the body, no dangerous advice",
}

const rules = `You write short push notifications in advance for a self-improvement app styled as a game "System".
The user receives them later as phone notifications, so each must stand alone.
Rules:
- Reply with ONE JSON object only: {"messages":[{"key":"...","title":"...","body":"..."}]} — one item per requested key.
- title: up to 40 characters; body: up to 160 characters. No markdown, no hashtags, at most one emoji.
- Stay in character and in the motivation mode. Never insult appearance or health, never suggest cutting food or sleep, no medical advice.
- briefing: morning greeting + the day's main tasks in one sentence.
- cheer: short encouragement for the moment of the day (do not invent facts about progress).
- reproach: sent 15 minutes after the deadline of the named task IF it was not done; name the task, say it was missed and what to do now.
- Task titles may be internal keys like "water" or "workout" — translate them into natural words.`

func langName(l string) string {
	if l == "tr" {
		return "Turkish"
	}
	return "Russian"
}

type genText struct {
	Key   string `json:"key"`
	Title string `json:"title"`
	Body  string `json:"body"`
}

func (s *Service) askTexts(ctx context.Context, uid string, u userCtx, now time.Time, quests []questInfo, slots []slot) (map[string]genText, error) {
	hm := func(t time.Time) string { return t.In(u.loc).Format("Mon 15:04") }
	persona := archetypes[u.archetype]
	if persona == "" {
		persona = "the System itself: a cold, concise game interface voice addressing the player"
	}
	var sys strings.Builder
	fmt.Fprintf(&sys, "Character: %s.\nMotivation mode: %s.\nWrite in %s.", persona, motivations[u.motivation], langName(u.lang))
	if u.name != "" {
		fmt.Fprintf(&sys, " The player's name: %s.", cut(u.name, 40))
	}

	type item struct {
		Key      string `json:"key"`
		Kind     string `json:"kind"`
		At       string `json:"at"`
		Task     string `json:"task,omitempty"`
		Deadline string `json:"deadline,omitempty"`
		Penalty  int    `json:"penalty_diamonds,omitempty"`
	}
	items := make([]item, 0, len(slots))
	for _, sl := range slots {
		it := item{Key: sl.key, Kind: sl.kind, At: hm(sl.at)}
		if sl.quest != nil {
			it.Task, it.Deadline, it.Penalty = sl.quest.title, hm(sl.quest.deadline), sl.quest.penalty
		}
		items = append(items, it)
	}
	type task struct {
		Title    string `json:"title"`
		Start    string `json:"start,omitempty"`
		Deadline string `json:"deadline"`
	}
	tasks := make([]task, 0, len(quests))
	for _, q := range quests {
		t := task{Title: q.title, Deadline: hm(q.deadline)}
		if q.starts != nil {
			t.Start = hm(*q.starts)
		}
		tasks = append(tasks, t)
	}
	payload, _ := json.Marshal(map[string]any{"now": hm(now), "upcoming_tasks": tasks, "write": items})

	resp, err := s.ai.Do(ctx, uid, ai.TaskShort, ai.Request{
		System:    []ai.SystemBlock{{Text: rules, Cache: true}, {Text: sys.String()}},
		Messages:  []ai.Message{{Role: ai.RoleUser, Parts: []ai.Part{{Text: string(payload)}}}},
		MaxTokens: 300 + 120*len(slots),
		JSON:      true,
	})
	if err != nil {
		return nil, err
	}
	raw := extractJSON(resp.Text)
	if raw == "" {
		return nil, errors.New("messages: no json in model reply")
	}
	var parsed struct {
		Messages []genText `json:"messages"`
	}
	if err := json.Unmarshal([]byte(raw), &parsed); err != nil {
		return nil, fmt.Errorf("messages: bad json: %w", err)
	}
	out := make(map[string]genText, len(parsed.Messages))
	for _, m := range parsed.Messages {
		out[m.Key] = m
	}
	return out, nil
}

// extractJSON — первый JSON-объект в тексте (модель могла обернуть его в ```).
func extractJSON(s string) string {
	start := strings.Index(s, "{")
	if start < 0 {
		return ""
	}
	depth, inStr, esc := 0, false, false
	for i := start; i < len(s); i++ {
		c := s[i]
		switch {
		case esc:
			esc = false
		case c == '\\' && inStr:
			esc = true
		case c == '"':
			inStr = !inStr
		case inStr:
		case c == '{':
			depth++
		case c == '}':
			depth--
			if depth == 0 {
				return s[start : i+1]
			}
		}
	}
	return ""
}

// cut — не длиннее n рун.
func cut(s string, n int) string {
	s = strings.TrimSpace(s)
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n])
}
