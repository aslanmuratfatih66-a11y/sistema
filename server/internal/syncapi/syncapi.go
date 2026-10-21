// Package syncapi — синхронизация офлайн-first (SPEC §10): push/pull записей, LWW по полю, журнал событий.
package syncapi

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"regexp"
	"strconv"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

const (
	maxChanges   = 1000
	maxIDLen     = 64
	maxBodyBytes = 32 << 20
	defaultLimit = 500
	maxLimit     = 1000
	futureSkew   = 5 * time.Minute
	// Ключ в field_ts для deleted_at (не пересекается с полями data).
	tsDeletedKey = "$deleted_at"
	// Таблица-журнал: только вставка, существующие записи не перезаписываются.
	appendOnlyTable = "quest_events"
)

var tableRe = regexp.MustCompile(`^[a-z_]{1,64}$`)

type Handler struct {
	db     *sql.DB
	logger *slog.Logger
}

func New(db *sql.DB, logger *slog.Logger) *Handler { return &Handler{db: db, logger: logger} }

// Register — маршруты /api/v1/sync/...; require — middleware авторизации (auth.Service.Require).
func (h *Handler) Register(mux *http.ServeMux, require func(http.Handler) http.Handler) {
	mux.Handle("POST /api/v1/sync/push", require(http.HandlerFunc(h.push)))
	mux.Handle("GET /api/v1/sync/pull", require(http.HandlerFunc(h.pull)))
}

type change struct {
	Table     string          `json:"table"`
	ID        string          `json:"id"`
	UpdatedAt int64           `json:"updated_at"`
	DeletedAt json.RawMessage `json:"deleted_at"` // отсутствует — не трогать; null — снять удаление; число — удалить
	Version   int64           `json:"version"`
	Data      json.RawMessage `json:"data"`
}

type pushReq struct {
	DeviceID string   `json:"device_id"`
	Changes  []change `json:"changes"`
}

type outChange struct {
	Table     string          `json:"table"`
	ID        string          `json:"id"`
	UpdatedAt int64           `json:"updated_at"`
	DeletedAt *int64          `json:"deleted_at"`
	Version   int64           `json:"version"`
	DeviceID  string          `json:"device_id"`
	Data      json.RawMessage `json:"data"`
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}

// parsed — проверенное входящее изменение.
type parsed struct {
	c          change
	fields     map[string]json.RawMessage
	hasDeleted bool
	deletedAt  *int64
}

func (h *Handler) push(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	if uid == "" {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	var req pushReq
	dec := json.NewDecoder(http.MaxBytesReader(w, r.Body, maxBodyBytes))
	if err := dec.Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "bad json")
		return
	}
	if len(req.DeviceID) > maxIDLen {
		writeError(w, http.StatusBadRequest, "device_id too long")
		return
	}
	if len(req.Changes) > maxChanges {
		writeError(w, http.StatusRequestEntityTooLarge, "too many changes (max 1000)")
		return
	}
	nowMs := time.Now().UnixMilli()
	limitMs := time.Now().Add(futureSkew).UnixMilli()
	clip := func(t int64) int64 {
		if t > limitMs {
			return nowMs
		}
		return t
	}
	items := make([]parsed, 0, len(req.Changes))
	for i, c := range req.Changes {
		bad := func(msg string) { writeError(w, http.StatusBadRequest, "changes["+strconv.Itoa(i)+"]: "+msg) }
		if !tableRe.MatchString(c.Table) {
			bad("bad table")
			return
		}
		if c.ID == "" || len(c.ID) > maxIDLen {
			bad("bad id")
			return
		}
		if c.UpdatedAt <= 0 {
			bad("bad updated_at")
			return
		}
		c.UpdatedAt = clip(c.UpdatedAt)
		p := parsed{c: c, fields: map[string]json.RawMessage{}}
		d := bytes.TrimSpace(c.Data)
		if len(d) == 0 || d[0] != '{' || json.Unmarshal(d, &p.fields) != nil {
			bad("data must be object")
			return
		}
		if dd := bytes.TrimSpace(c.DeletedAt); len(dd) > 0 {
			p.hasDeleted = true
			if !bytes.Equal(dd, []byte("null")) {
				var t int64
				if json.Unmarshal(dd, &t) != nil || t <= 0 {
					bad("bad deleted_at")
					return
				}
				t = clip(t)
				p.deletedAt = &t
			}
		}
		items = append(items, p)
	}

	applied, cursor, err := h.apply(r.Context(), uid, req.DeviceID, items)
	if err != nil {
		h.logger.Error("sync push", "user", uid, "err", err)
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	writeJSON(w, http.StatusOK, map[string]int64{"applied": int64(applied), "cursor": cursor})
}

func (h *Handler) apply(ctx context.Context, uid, device string, items []parsed) (int, int64, error) {
	tx, err := h.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, 0, err
	}
	defer tx.Rollback()
	// Первая операция — запись: сразу берём write-lock SQLite.
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO sync_cursors(user_id, seq) VALUES(?, 0) ON CONFLICT(user_id) DO NOTHING`, uid); err != nil {
		return 0, 0, err
	}
	applied := 0
	for _, p := range items {
		ok, err := h.applyOne(ctx, tx, uid, device, p)
		if err != nil {
			return 0, 0, err
		}
		if ok {
			applied++
		}
	}
	var cursor int64
	if err := tx.QueryRowContext(ctx, `SELECT seq FROM sync_cursors WHERE user_id = ?`, uid).Scan(&cursor); err != nil {
		return 0, 0, err
	}
	if err := tx.Commit(); err != nil {
		return 0, 0, err
	}
	return applied, cursor, nil
}

func nextSeq(ctx context.Context, tx *sql.Tx, uid string) (int64, error) {
	var seq int64
	err := tx.QueryRowContext(ctx,
		`UPDATE sync_cursors SET seq = seq + 1 WHERE user_id = ? RETURNING seq`, uid).Scan(&seq)
	return seq, err
}

// applyOne сливает одно изменение; true — запись изменилась (получила новый seq).
func (h *Handler) applyOne(ctx context.Context, tx *sql.Tx, uid, device string, p parsed) (bool, error) {
	c := p.c
	var (
		dataS, tsS string
		updAt, ver int64
		delAt      sql.NullInt64
	)
	err := tx.QueryRowContext(ctx,
		`SELECT data, field_ts, updated_at, deleted_at, version FROM records WHERE user_id = ? AND tbl = ? AND id = ?`,
		uid, c.Table, c.ID).Scan(&dataS, &tsS, &updAt, &delAt, &ver)
	if errors.Is(err, sql.ErrNoRows) {
		ts := make(map[string]int64, len(p.fields)+1)
		for k := range p.fields {
			ts[k] = c.UpdatedAt
		}
		if p.hasDeleted {
			ts[tsDeletedKey] = c.UpdatedAt
		}
		tsJSON, _ := json.Marshal(ts)
		dataJSON, _ := json.Marshal(p.fields)
		seq, err := nextSeq(ctx, tx, uid)
		if err != nil {
			return false, err
		}
		ver := c.Version
		if ver < 1 {
			ver = 1
		}
		_, err = tx.ExecContext(ctx,
			`INSERT INTO records(user_id, tbl, id, data, field_ts, updated_at, deleted_at, device_id, version, seq)
			 VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			uid, c.Table, c.ID, string(dataJSON), string(tsJSON), c.UpdatedAt, p.deletedAt, device, ver, seq)
		return err == nil, err
	}
	if err != nil {
		return false, err
	}
	if c.Table == appendOnlyTable {
		return false, nil // журнал: существующие события не перезаписываются
	}

	data := map[string]json.RawMessage{}
	ts := map[string]int64{}
	_ = json.Unmarshal([]byte(dataS), &data)
	_ = json.Unmarshal([]byte(tsS), &ts)

	changed := false
	for k, v := range p.fields {
		if c.UpdatedAt >= ts[k] {
			if old, ok := data[k]; !ok || !bytes.Equal(old, v) || ts[k] != c.UpdatedAt {
				changed = true
			}
			data[k] = v
			ts[k] = c.UpdatedAt
		}
	}
	if p.hasDeleted && c.UpdatedAt >= ts[tsDeletedKey] {
		var newDel sql.NullInt64
		if p.deletedAt != nil {
			newDel = sql.NullInt64{Int64: *p.deletedAt, Valid: true}
		}
		if newDel != delAt || ts[tsDeletedKey] != c.UpdatedAt {
			changed = true
		}
		delAt = newDel
		ts[tsDeletedKey] = c.UpdatedAt
	}
	if !changed {
		return false, nil
	}
	if c.UpdatedAt > updAt {
		updAt = c.UpdatedAt
	}
	if c.Version > ver {
		ver = c.Version
	}
	tsJSON, _ := json.Marshal(ts)
	dataJSON, _ := json.Marshal(data)
	seq, err := nextSeq(ctx, tx, uid)
	if err != nil {
		return false, err
	}
	_, err = tx.ExecContext(ctx,
		`UPDATE records SET data = ?, field_ts = ?, updated_at = ?, deleted_at = ?, device_id = ?, version = ?, seq = ?
		 WHERE user_id = ? AND tbl = ? AND id = ?`,
		string(dataJSON), string(tsJSON), updAt, delAt, device, ver, seq, uid, c.Table, c.ID)
	return err == nil, err
}

func (h *Handler) pull(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	if uid == "" {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}
	q := r.URL.Query()
	var since int64
	if s := q.Get("since"); s != "" {
		v, err := strconv.ParseInt(s, 10, 64)
		if err != nil || v < 0 {
			writeError(w, http.StatusBadRequest, "bad since")
			return
		}
		since = v
	}
	limit := defaultLimit
	if s := q.Get("limit"); s != "" {
		v, err := strconv.Atoi(s)
		if err != nil || v < 1 {
			writeError(w, http.StatusBadRequest, "bad limit")
			return
		}
		limit = min(v, maxLimit)
	}
	rows, err := h.db.QueryContext(r.Context(),
		`SELECT tbl, id, updated_at, deleted_at, version, device_id, data, seq
		 FROM records WHERE user_id = ? AND seq > ? ORDER BY seq LIMIT ?`, uid, since, limit+1)
	if err != nil {
		h.logger.Error("sync pull", "user", uid, "err", err)
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	defer rows.Close()
	out := make([]outChange, 0, limit)
	cursor := since
	hasMore := false
	for rows.Next() {
		if len(out) == limit {
			hasMore = true
			break
		}
		var (
			o    outChange
			del  sql.NullInt64
			data string
			seq  int64
		)
		if err := rows.Scan(&o.Table, &o.ID, &o.UpdatedAt, &del, &o.Version, &o.DeviceID, &data, &seq); err != nil {
			h.logger.Error("sync pull scan", "user", uid, "err", err)
			writeError(w, http.StatusInternalServerError, "internal error")
			return
		}
		if del.Valid {
			o.DeletedAt = &del.Int64
		}
		o.Data = json.RawMessage(data)
		out = append(out, o)
		cursor = seq
	}
	if err := rows.Err(); err != nil {
		h.logger.Error("sync pull rows", "user", uid, "err", err)
		writeError(w, http.StatusInternalServerError, "internal error")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"changes": out, "cursor": cursor, "has_more": hasMore})
}
