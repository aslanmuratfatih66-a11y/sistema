package ai

import (
	"context"
	"database/sql"
	"encoding/json"
	"strconv"
	"strings"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/syncapi"
)

// rec — запись клиента из records (data — колонки Drift в snake_case).
type rec struct {
	ID        string
	UpdatedAt int64
	Data      map[string]any
}

func (r rec) str(k string) string {
	if v, ok := r.Data[k].(string); ok {
		return v
	}
	return ""
}

func (r rec) num(k string) (float64, bool) {
	switch v := r.Data[k].(type) {
	case float64:
		return v, true
	case json.Number:
		f, err := v.Float64()
		return f, err == nil
	}
	return 0, false
}

func (r rec) int(k string) int64 {
	f, _ := r.num(k)
	return int64(f)
}

// listRecords — неудалённые записи таблицы пользователя, новые первыми (по updated_at), не больше limit.
func listRecords(ctx context.Context, db *sql.DB, uid, tbl string, limit int) ([]rec, error) {
	rows, err := db.QueryContext(ctx,
		`SELECT id, updated_at, data FROM records WHERE user_id = ? AND tbl = ? AND deleted_at IS NULL
		 ORDER BY updated_at DESC LIMIT ?`, uid, tbl, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []rec
	for rows.Next() {
		var r rec
		var data string
		if err := rows.Scan(&r.ID, &r.UpdatedAt, &data); err != nil {
			return nil, err
		}
		_ = json.Unmarshal([]byte(data), &r.Data)
		if r.Data == nil {
			r.Data = map[string]any{}
		}
		out = append(out, r)
	}
	return out, rows.Err()
}

// getRecord — одна запись (в т.ч. удалённая: deleted сообщает об этом).
func getRecord(ctx context.Context, db *sql.DB, uid, tbl, id string) (r rec, deleted bool, ok bool, err error) {
	var data string
	var del sql.NullInt64
	err = db.QueryRowContext(ctx,
		`SELECT id, updated_at, data, deleted_at FROM records WHERE user_id = ? AND tbl = ? AND id = ?`,
		uid, tbl, id).Scan(&r.ID, &r.UpdatedAt, &data, &del)
	if err == sql.ErrNoRows {
		return r, false, false, nil
	}
	if err != nil {
		return r, false, false, err
	}
	_ = json.Unmarshal([]byte(data), &r.Data)
	if r.Data == nil {
		r.Data = map[string]any{}
	}
	return r, del.Valid, true, nil
}

func write(ctx context.Context, db *sql.DB, uid string, changes ...syncapi.ServerChange) error {
	_, err := syncapi.ServerWrite(ctx, db, uid, changes)
	return err
}

func boolp(b bool) *bool { return &b }

// userLoc — часовой пояс пользователя из profiles.timezone (IANA или «UTC+3»); иначе UTC.
func userLoc(ctx context.Context, db *sql.DB, uid string) *time.Location {
	ps, _ := listRecords(ctx, db, uid, "profiles", 1)
	if len(ps) == 0 {
		return time.UTC
	}
	return parseTZ(ps[0].str("timezone"))
}

func parseTZ(tz string) *time.Location {
	tz = strings.TrimSpace(tz)
	if tz == "" {
		return time.UTC
	}
	if l, err := time.LoadLocation(tz); err == nil {
		return l
	}
	s := strings.TrimPrefix(strings.TrimPrefix(strings.ToUpper(tz), "UTC"), "GMT")
	if s == "" {
		return time.UTC
	}
	sign := 1
	switch s[0] {
	case '-':
		sign = -1
		s = s[1:]
	case '+':
		s = s[1:]
	}
	h, m, _ := strings.Cut(s, ":")
	hh, err := strconv.Atoi(h)
	if err != nil {
		return time.UTC
	}
	mm, _ := strconv.Atoi(m)
	return time.FixedZone("UTC"+tz, sign*(hh*3600+mm*60))
}

// dayStart — локальная полночь (как у клиента: секунды Unix).
func dayStart(t time.Time, loc *time.Location) time.Time {
	t = t.In(loc)
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, loc)
}

// compactJSON — данные записи без служебных полей, кратко для контекста модели.
func compactJSON(v any, maxLen int) string {
	b, _ := json.Marshal(v)
	return truncate(string(b), maxLen)
}
