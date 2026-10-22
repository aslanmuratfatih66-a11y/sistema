package syncapi

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"
)

// ServerDeviceID — device_id серверных записей (ИИ, задачи): клиенты получат их через pull.
const ServerDeviceID = "server"

// ServerChange — изменение записи от сервера. Fields — значения колонок клиента (snake_case, как в Drift:
// даты — секунды Unix, bool — 0/1 или true/false, JSON-колонки — строкой). Deleted: nil — не трогать,
// true — мягко удалить, false — снять удаление.
type ServerChange struct {
	Table   string
	ID      string
	Fields  map[string]any
	Deleted *bool
}

// ServerWrite применяет изменения сервера тем же LWW по полю (updated_at = сейчас, мс) с новым seq,
// в одной транзакции. Возвращает курсор пользователя после записи.
func ServerWrite(ctx context.Context, db *sql.DB, uid string, changes []ServerChange) (int64, error) {
	if uid == "" {
		return 0, errors.New("syncapi: empty user")
	}
	now := time.Now().UnixMilli()
	items := make([]parsed, 0, len(changes))
	for i, c := range changes {
		if !tableRe.MatchString(c.Table) || c.ID == "" || len(c.ID) > maxIDLen {
			return 0, fmt.Errorf("syncapi: server change %d: bad table/id", i)
		}
		p := parsed{c: change{Table: c.Table, ID: c.ID, UpdatedAt: now}, fields: map[string]json.RawMessage{}}
		for k, v := range c.Fields {
			b, err := json.Marshal(v)
			if err != nil {
				return 0, fmt.Errorf("syncapi: server change %d field %s: %w", i, k, err)
			}
			p.fields[k] = b
		}
		if c.Deleted != nil {
			p.hasDeleted = true
			if *c.Deleted {
				t := now
				p.deletedAt = &t
			}
		}
		items = append(items, p)
	}
	h := &Handler{db: db}
	_, cursor, err := h.apply(ctx, uid, ServerDeviceID, items)
	return cursor, err
}
