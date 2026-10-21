// Package jobs — планировщик внутри процесса (SPEC §10): бэкапы, курсы валют, очистка.
// Генерация сообщений и недельный анализ — этап 6 (заглушки).
package jobs

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// DefaultFXURL — бесплатный источник курсов без ключа.
const DefaultFXURL = "https://open.er-api.com/v6/latest/USD"

const (
	tick       = time.Minute
	retryAfter = 15 * time.Minute // повтор упавшей задачи
	day        = 24 * time.Hour
)

type Options struct {
	DataDir        string
	BackupDir      string
	BackupKeepDays int
	FXURL          string
	Logger         *slog.Logger
	// Этап 6: сообщения наперёд (messages.Service.GenerateAhead) и недельный пересмотр плана. nil — пропуск.
	GenerateMessages func(ctx context.Context) error
	WeeklyReview     func(ctx context.Context) error
}

type Scheduler struct {
	db   *sql.DB
	opts Options
	http *http.Client
	jobs []*job
}

type job struct {
	name     string
	every    time.Duration // интервал; если atMin >= 0 — раз в сутки в atMin минут от полуночи (локально)
	atMin    int
	run      func(ctx context.Context) error
	failedAt time.Time // в памяти: бэкофф после ошибки
}

func New(db *sql.DB, opts Options) *Scheduler {
	if opts.Logger == nil {
		opts.Logger = slog.Default()
	}
	if opts.FXURL == "" {
		opts.FXURL = DefaultFXURL
	}
	if opts.BackupKeepDays < 1 {
		opts.BackupKeepDays = 14
	}
	s := &Scheduler{db: db, opts: opts, http: &http.Client{Timeout: 20 * time.Second}}
	s.jobs = []*job{
		{name: "backup", atMin: 3*60 + 30, run: s.backup},
		{name: "fx_rates", every: 6 * time.Hour, atMin: -1, run: s.fxRates},
		{name: "cleanup", every: day, atMin: -1, run: s.cleanup},
		{name: "messages", every: 3 * time.Hour, atMin: -1, run: s.generateMessages},
		{name: "weekly_analysis", every: 7 * day, atMin: -1, run: s.weeklyAnalysis},
	}
	return s
}

// Run — до отмены ctx.
func (s *Scheduler) Run(ctx context.Context) {
	t := time.NewTicker(tick)
	defer t.Stop()
	s.runDue(ctx)
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			s.runDue(ctx)
		}
	}
}

func (s *Scheduler) runDue(ctx context.Context) {
	for _, j := range s.jobs {
		if ctx.Err() != nil {
			return
		}
		now := time.Now()
		if !j.failedAt.IsZero() && now.Sub(j.failedAt) < retryAfter {
			continue
		}
		last, err := s.lastRun(ctx, j.name)
		if err != nil {
			s.opts.Logger.Error("jobs: read state", "job", j.name, "err", err)
			continue
		}
		if !due(j, last, now) {
			continue
		}
		start := time.Now()
		err = s.safeRun(ctx, j)
		if err != nil {
			j.failedAt = time.Now()
			s.opts.Logger.Error("jobs: failed", "job", j.name, "err", err, "dur", time.Since(start).String())
			s.saveError(ctx, j.name, err)
			continue
		}
		j.failedAt = time.Time{}
		s.opts.Logger.Info("jobs: done", "job", j.name, "dur", time.Since(start).String())
		if _, err := s.db.ExecContext(ctx, `INSERT INTO job_runs(name,last_run,last_error) VALUES(?,?,NULL)
			ON CONFLICT(name) DO UPDATE SET last_run=excluded.last_run, last_error=NULL`,
			j.name, start.UnixMilli()); err != nil {
			s.opts.Logger.Error("jobs: save state", "job", j.name, "err", err)
		}
	}
}

func due(j *job, last, now time.Time) bool {
	if j.atMin >= 0 {
		y, m, d := now.Date()
		slot := time.Date(y, m, d, j.atMin/60, j.atMin%60, 0, 0, now.Location())
		if now.Before(slot) {
			slot = slot.Add(-day)
		}
		return last.Before(slot)
	}
	return now.Sub(last) >= j.every
}

func (s *Scheduler) safeRun(ctx context.Context, j *job) (err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("panic: %v", r)
		}
	}()
	return j.run(ctx)
}

func (s *Scheduler) lastRun(ctx context.Context, name string) (time.Time, error) {
	var ms int64
	err := s.db.QueryRowContext(ctx, `SELECT last_run FROM job_runs WHERE name=?`, name).Scan(&ms)
	if errors.Is(err, sql.ErrNoRows) {
		return time.Time{}, nil
	}
	if err != nil {
		return time.Time{}, err
	}
	return time.UnixMilli(ms), nil
}

// saveError пишет ошибку, не сдвигая last_run (0 — если задача ещё ни разу не выполнялась).
func (s *Scheduler) saveError(ctx context.Context, name string, e error) {
	msg := e.Error()
	if len(msg) > 1000 {
		msg = msg[:1000]
	}
	if _, err := s.db.ExecContext(ctx, `INSERT INTO job_runs(name,last_run,last_error) VALUES(?,0,?)
		ON CONFLICT(name) DO UPDATE SET last_error=excluded.last_error`, name, msg); err != nil {
		s.opts.Logger.Error("jobs: save error", "job", name, "err", err)
	}
}

// ---- Курсы валют ----

var fxQuotes = []string{"RUB", "TRY", "USD", "EUR"}

func (s *Scheduler) fxRates(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, s.opts.FXURL, nil)
	if err != nil {
		return err
	}
	req.Header.Set("Accept", "application/json")
	resp, err := s.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("fx: HTTP %d", resp.StatusCode)
	}
	var body struct {
		Result   string             `json:"result"`
		BaseCode string             `json:"base_code"`
		Rates    map[string]float64 `json:"rates"`
	}
	if err := json.NewDecoder(io.LimitReader(resp.Body, 1<<20)).Decode(&body); err != nil {
		return fmt.Errorf("fx: decode: %w", err)
	}
	if body.Result != "" && body.Result != "success" {
		return fmt.Errorf("fx: result %q", body.Result)
	}
	// Приводим к базе USD, если источник отдал другую.
	usd := 1.0
	if b := strings.ToUpper(body.BaseCode); b != "" && b != "USD" {
		usd = body.Rates["USD"]
		if usd <= 0 {
			return errors.New("fx: no USD rate")
		}
	}
	now := time.Now().UnixMilli()
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	n := 0
	for _, q := range fxQuotes {
		r := body.Rates[q]
		if q == "USD" {
			r = usd
		}
		if r <= 0 {
			continue
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO fx_rates(base,quote,rate,updated_at) VALUES('USD',?,?,?)
			ON CONFLICT(base,quote) DO UPDATE SET rate=excluded.rate, updated_at=excluded.updated_at`,
			q, r/usd, now); err != nil {
			return err
		}
		n++
	}
	if n < 2 {
		return errors.New("fx: rates missing")
	}
	return tx.Commit()
}

// ---- Очистка ----

func (s *Scheduler) cleanup(ctx context.Context) error {
	now := time.Now().UnixMilli()
	old := now - (30 * day).Milliseconds()
	if _, err := s.db.ExecContext(ctx, `DELETE FROM access_tokens WHERE expires_at < ?`, now); err != nil {
		return err
	}
	_, err := s.db.ExecContext(ctx,
		`DELETE FROM sessions WHERE (revoked_at IS NOT NULL AND revoked_at < ?) OR expires_at < ?`, old, old)
	return err
}

// ---- Этап 6 (реализации подключает main) ----

func (s *Scheduler) generateMessages(ctx context.Context) error {
	if s.opts.GenerateMessages == nil {
		return nil
	}
	return s.opts.GenerateMessages(ctx)
}

func (s *Scheduler) weeklyAnalysis(ctx context.Context) error {
	if s.opts.WeeklyReview == nil {
		return nil
	}
	return s.opts.WeeklyReview(ctx)
}

// ---- Бэкап ----
// Структура <BackupDir>:
//   <yyyy-mm-dd>/sistema.db   — снимок БД (VACUUM INTO), хранится BackupKeepDays дней;
//   photos/...                — зеркало <DataDir>/photos (новые/изменённые копируются);
//   photos-deleted.json       — когда файл впервые пропал из источника; из зеркала удаляется
//                               через BackupKeepDays дней.

func (s *Scheduler) backup(ctx context.Context) error {
	if err := os.MkdirAll(s.opts.BackupDir, 0o750); err != nil {
		return err
	}
	now := time.Now()
	dir := filepath.Join(s.opts.BackupDir, now.Format("2006-01-02"))
	if err := os.MkdirAll(dir, 0o750); err != nil {
		return err
	}
	dst := filepath.Join(dir, "sistema.db")
	tmp := dst + ".tmp"
	_ = os.Remove(tmp)
	if _, err := s.db.ExecContext(ctx, `VACUUM INTO '`+strings.ReplaceAll(tmp, "'", "''")+`'`); err != nil {
		_ = os.Remove(tmp)
		return fmt.Errorf("vacuum into: %w", err)
	}
	if err := os.Rename(tmp, dst); err != nil {
		return err
	}

	copied, removed, err := s.mirrorPhotos(ctx, now)
	if err != nil {
		return fmt.Errorf("photos: %w", err)
	}
	pruned := s.pruneDB(now)
	s.opts.Logger.Info("backup", "db", dst, "photos_copied", copied, "photos_removed", removed, "db_pruned", pruned)
	return nil
}

func (s *Scheduler) pruneDB(now time.Time) int {
	ents, err := os.ReadDir(s.opts.BackupDir)
	if err != nil {
		return 0
	}
	y, m, d := now.Date()
	cut := time.Date(y, m, d, 0, 0, 0, 0, now.Location()).AddDate(0, 0, -s.opts.BackupKeepDays)
	n := 0
	for _, e := range ents {
		if !e.IsDir() {
			continue
		}
		t, err := time.ParseInLocation("2006-01-02", e.Name(), now.Location())
		if err != nil || !t.Before(cut) {
			continue
		}
		if err := os.RemoveAll(filepath.Join(s.opts.BackupDir, e.Name())); err != nil {
			s.opts.Logger.Error("backup: prune", "dir", e.Name(), "err", err)
			continue
		}
		n++
	}
	return n
}

func (s *Scheduler) mirrorPhotos(ctx context.Context, now time.Time) (copied, removed int, err error) {
	src := filepath.Join(s.opts.DataDir, "photos")
	dst := filepath.Join(s.opts.BackupDir, "photos")
	if err := os.MkdirAll(dst, 0o750); err != nil {
		return 0, 0, err
	}
	err = filepath.WalkDir(src, func(p string, d os.DirEntry, werr error) error {
		if werr != nil {
			if errors.Is(werr, os.ErrNotExist) {
				return nil
			}
			return werr
		}
		if ctx.Err() != nil {
			return ctx.Err()
		}
		if d.IsDir() || strings.HasPrefix(d.Name(), ".tmp") || !d.Type().IsRegular() {
			return nil
		}
		rel, _ := filepath.Rel(src, p)
		si, err := d.Info()
		if err != nil {
			return nil
		}
		target := filepath.Join(dst, rel)
		if ti, err := os.Stat(target); err == nil && ti.Size() == si.Size() && ti.ModTime().Equal(si.ModTime()) {
			return nil
		}
		if err := copyFile(p, target, si.ModTime()); err != nil {
			return err
		}
		copied++
		return nil
	})
	if err != nil {
		return copied, 0, err
	}

	// Удалённые из источника: помнить дату пропажи, удалять из зеркала через KeepDays.
	statePath := filepath.Join(s.opts.BackupDir, "photos-deleted.json")
	gone := map[string]int64{}
	if b, err := os.ReadFile(statePath); err == nil {
		_ = json.Unmarshal(b, &gone)
	}
	seen := map[string]bool{}
	keep := time.Duration(s.opts.BackupKeepDays) * day
	err = filepath.WalkDir(dst, func(p string, d os.DirEntry, werr error) error {
		if werr != nil || d.IsDir() {
			return werr
		}
		rel, _ := filepath.Rel(dst, p)
		key := filepath.ToSlash(rel)
		if _, err := os.Stat(filepath.Join(src, rel)); err == nil {
			return nil
		}
		seen[key] = true
		first, ok := gone[key]
		if !ok {
			gone[key] = now.UnixMilli()
			return nil
		}
		if now.Sub(time.UnixMilli(first)) >= keep {
			if err := os.Remove(p); err == nil {
				removed++
				delete(gone, key)
				delete(seen, key)
			}
		}
		return nil
	})
	if err != nil {
		return copied, removed, err
	}
	for k := range gone {
		if !seen[k] {
			delete(gone, k) // вернулся в источник или удалён вручную
		}
	}
	b, _ := json.Marshal(gone)
	if err := os.WriteFile(statePath+".tmp", b, 0o640); err == nil {
		_ = os.Rename(statePath+".tmp", statePath)
	}
	return copied, removed, nil
}

func copyFile(src, dst string, mtime time.Time) error {
	if err := os.MkdirAll(filepath.Dir(dst), 0o750); err != nil {
		return err
	}
	in, err := os.Open(src)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil // удалён во время обхода
		}
		return err
	}
	defer in.Close()
	tmp := dst + ".part"
	out, err := os.OpenFile(tmp, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0o640)
	if err != nil {
		return err
	}
	_, err = io.Copy(out, in)
	if cerr := out.Close(); err == nil {
		err = cerr
	}
	if err == nil {
		err = os.Chtimes(tmp, mtime, mtime)
	}
	if err == nil {
		err = os.Rename(tmp, dst)
	}
	if err != nil {
		_ = os.Remove(tmp)
	}
	return err
}
