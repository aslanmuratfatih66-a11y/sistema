// Package auth — вход (имя + пароль argon2id + TOTP), токены, сброс по TOTP, ограничение частоты (SPEC §10).
package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"
	"unicode"
	"unicode/utf8"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/authctx"
)

const (
	accessTTL  = 15 * time.Minute
	refreshTTL = 60 * 24 * time.Hour
	maxBody    = 4 << 10
)

// Options — зависимости сервиса.
type Options struct {
	Logger     *slog.Logger
	TrustProxy bool // IP клиента из X-Forwarded-For (для лимитов)
	Now        func() time.Time
}

// Service — регистрация, вход, токены.
type Service struct {
	db   *sql.DB
	opts Options

	ipStrict  *limiter // вход/регистрация/сброс: 5/мин на IP
	nameLimit *limiter // вход/сброс: 10/час на имя
	ipLoose   *limiter // refresh: 30/мин на IP
	userTOTP  *limiter // totp/setup|confirm: 5/мин на пользователя
	totp      *totpGuard

	lastCleanup atomic.Int64
	dummyOnce   sync.Once
	dummyHash   string
}

func New(db *sql.DB, opts Options) *Service {
	if opts.Now == nil {
		opts.Now = time.Now
	}
	if opts.Logger == nil {
		opts.Logger = slog.Default()
	}
	return &Service{
		db: db, opts: opts,
		ipStrict:  newLimiter(5, time.Minute),
		nameLimit: newLimiter(10, time.Hour),
		ipLoose:   newLimiter(30, time.Minute),
		userTOTP:  newLimiter(5, time.Minute),
		totp:      newTOTPGuard(),
	}
}

// Register — маршруты /api/v1/auth/...
func (s *Service) Register(mux *http.ServeMux) {
	mux.HandleFunc("POST /api/v1/auth/register", s.handleRegister)
	mux.HandleFunc("POST /api/v1/auth/login", s.handleLogin)
	mux.HandleFunc("POST /api/v1/auth/refresh", s.handleRefresh)
	mux.HandleFunc("POST /api/v1/auth/reset", s.handleReset)
	mux.Handle("POST /api/v1/auth/logout", s.Require(http.HandlerFunc(s.handleLogout)))
	mux.Handle("POST /api/v1/auth/totp/setup", s.Require(http.HandlerFunc(s.handleTOTPSetup)))
	mux.Handle("POST /api/v1/auth/totp/confirm", s.Require(http.HandlerFunc(s.handleTOTPConfirm)))
	mux.Handle("GET /api/v1/auth/me", s.Require(http.HandlerFunc(s.handleMe)))
}

type sessionKey struct{}

// Require — middleware: Authorization: Bearer <access>, кладёт id пользователя в context (authctx.WithUser);
// иначе 401 {"error":"unauthorized"}.
func (s *Service) Require(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := r.Header.Get("Authorization")
		tok, ok := strings.CutPrefix(h, "Bearer ")
		tok = strings.TrimSpace(tok)
		if !ok || tok == "" {
			writeError(w, http.StatusUnauthorized, "unauthorized")
			return
		}
		var userID, sessID string
		err := s.db.QueryRowContext(r.Context(), `
			SELECT a.user_id, a.session_id FROM access_tokens a
			JOIN sessions s ON s.id = a.session_id
			WHERE a.token_hash = ? AND a.expires_at > ? AND s.revoked_at IS NULL AND s.expires_at > ?`,
			hashToken(tok), s.nowMs(), s.nowMs()).Scan(&userID, &sessID)
		if err != nil {
			if !errors.Is(err, sql.ErrNoRows) {
				s.opts.Logger.Error("auth: require", "err", err)
				writeError(w, http.StatusInternalServerError, "internal")
				return
			}
			writeError(w, http.StatusUnauthorized, "unauthorized")
			return
		}
		ctx := authctx.WithUser(r.Context(), userID)
		ctx = context.WithValue(ctx, sessionKey{}, sessID)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// ---------- JSON ----------

type userJSON struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	TOTPEnabled bool   `json:"totp_enabled"`
}

type tokensJSON struct {
	AccessToken     string   `json:"access_token"`
	AccessExpiresIn int      `json:"access_expires_in"` // секунды
	RefreshToken    string   `json:"refresh_token"`
	User            userJSON `json:"user"`
}

type credsReq struct {
	Name     string `json:"name"`
	Password string `json:"password"`
	TOTP     string `json:"totp"`
	DeviceID string `json:"device_id"`
}

// ---------- handlers ----------

func (s *Service) handleRegister(w http.ResponseWriter, r *http.Request) {
	if !s.limit(w, s.ipStrict, "ip:"+s.clientIP(r)) {
		return
	}
	var req credsReq
	if !decode(w, r, &req) {
		return
	}
	name := strings.TrimSpace(req.Name)
	if !validName(name) {
		writeError(w, http.StatusBadRequest, "invalid_name")
		return
	}
	if !validPassword(req.Password) {
		writeError(w, http.StatusBadRequest, "invalid_password")
		return
	}
	if !s.limit(w, s.nameLimit, "name:"+strings.ToLower(name)) {
		return
	}
	ph, err := hashPassword(req.Password)
	if err != nil {
		s.internal(w, "hash", err)
		return
	}
	u := userJSON{ID: newUUID(), Name: name}
	res, err := s.db.ExecContext(r.Context(),
		`INSERT INTO users(id, name, pass_hash, created_at) VALUES(?,?,?,?) ON CONFLICT(name) DO NOTHING`,
		u.ID, name, ph, s.nowMs())
	if err != nil {
		s.internal(w, "insert user", err)
		return
	}
	if n, _ := res.RowsAffected(); n == 0 {
		writeError(w, http.StatusConflict, "name_taken")
		return
	}
	s.opts.Logger.Info("auth: registered", "user", u.ID)
	s.issue(w, r, http.StatusCreated, u, req.DeviceID)
}

func (s *Service) handleLogin(w http.ResponseWriter, r *http.Request) {
	if !s.limit(w, s.ipStrict, "ip:"+s.clientIP(r)) {
		return
	}
	var req credsReq
	if !decode(w, r, &req) {
		return
	}
	name := strings.TrimSpace(req.Name)
	if name == "" || len(name) > 128 || len(req.Password) > 1024 {
		writeError(w, http.StatusUnauthorized, "invalid_credentials")
		return
	}
	if !s.limit(w, s.nameLimit, "name:"+strings.ToLower(name)) {
		return
	}
	u, ph, secret, err := s.userByName(r.Context(), name)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		s.internal(w, "load user", err)
		return
	}
	if errors.Is(err, sql.ErrNoRows) {
		_, _ = verifyPassword(req.Password, s.dummy()) // выравнивание времени ответа
		writeError(w, http.StatusUnauthorized, "invalid_credentials")
		return
	}
	ok, err := verifyPassword(req.Password, ph)
	if err != nil {
		s.internal(w, "verify", err)
		return
	}
	if !ok {
		writeError(w, http.StatusUnauthorized, "invalid_credentials")
		return
	}
	if u.TOTPEnabled {
		if strings.TrimSpace(req.TOTP) == "" {
			writeError(w, http.StatusUnauthorized, "totp_required")
			return
		}
		if !s.totp.verify(u.ID, secret, req.TOTP, s.opts.Now()) {
			writeError(w, http.StatusUnauthorized, "invalid_totp")
			return
		}
	}
	s.issue(w, r, http.StatusOK, u, req.DeviceID)
}

func (s *Service) handleRefresh(w http.ResponseWriter, r *http.Request) {
	if !s.limit(w, s.ipLoose, "ip:"+s.clientIP(r)) {
		return
	}
	var req struct {
		RefreshToken string `json:"refresh_token"`
	}
	if !decode(w, r, &req) {
		return
	}
	if req.RefreshToken == "" {
		writeError(w, http.StatusUnauthorized, "invalid_refresh")
		return
	}
	ctx := r.Context()
	now := s.nowMs()
	oldHash := hashToken(req.RefreshToken)
	var sessID string
	var u userJSON
	err := s.db.QueryRowContext(ctx, `
		SELECT s.id, u.id, u.name, u.totp_enabled FROM sessions s JOIN users u ON u.id = s.user_id
		WHERE s.refresh_hash = ? AND s.revoked_at IS NULL AND s.expires_at > ?`, oldHash, now).
		Scan(&sessID, &u.ID, &u.Name, &u.TOTPEnabled)
	if errors.Is(err, sql.ErrNoRows) {
		writeError(w, http.StatusUnauthorized, "invalid_refresh")
		return
	}
	if err != nil {
		s.internal(w, "load session", err)
		return
	}
	access, refresh := newToken(), newToken()
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		s.internal(w, "begin", err)
		return
	}
	defer tx.Rollback()
	// Ротация: старый refresh перестаёт действовать (условие на старый хэш защищает от гонки).
	res, err := tx.ExecContext(ctx, `UPDATE sessions SET refresh_hash = ?, expires_at = ? WHERE id = ? AND refresh_hash = ? AND revoked_at IS NULL`,
		hashToken(refresh), now+refreshTTL.Milliseconds(), sessID, oldHash)
	if err != nil {
		s.internal(w, "rotate", err)
		return
	}
	if n, _ := res.RowsAffected(); n == 0 {
		writeError(w, http.StatusUnauthorized, "invalid_refresh")
		return
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM access_tokens WHERE session_id = ?`, sessID); err != nil {
		s.internal(w, "drop access", err)
		return
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO access_tokens(token_hash, session_id, user_id, expires_at) VALUES(?,?,?,?)`,
		hashToken(access), sessID, u.ID, now+accessTTL.Milliseconds()); err != nil {
		s.internal(w, "insert access", err)
		return
	}
	if err := tx.Commit(); err != nil {
		s.internal(w, "commit", err)
		return
	}
	writeJSON(w, http.StatusOK, tokensJSON{AccessToken: access, AccessExpiresIn: int(accessTTL.Seconds()), RefreshToken: refresh, User: u})
}

func (s *Service) handleLogout(w http.ResponseWriter, r *http.Request) {
	sessID, _ := r.Context().Value(sessionKey{}).(string)
	if err := s.revoke(r.Context(), `id = ?`, sessID); err != nil {
		s.internal(w, "logout", err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func (s *Service) handleMe(w http.ResponseWriter, r *http.Request) {
	u, err := s.userByID(r.Context(), authctx.UserID(r.Context()))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusUnauthorized, "unauthorized")
			return
		}
		s.internal(w, "me", err)
		return
	}
	writeJSON(w, http.StatusOK, u)
}

func (s *Service) handleTOTPSetup(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	if !s.limit(w, s.userTOTP, "u:"+uid) {
		return
	}
	u, err := s.userByID(r.Context(), uid)
	if err != nil {
		s.internal(w, "totp setup", err)
		return
	}
	if u.TOTPEnabled {
		writeError(w, http.StatusConflict, "totp_already_enabled")
		return
	}
	secret, err := newTOTPSecret()
	if err != nil {
		s.internal(w, "totp secret", err)
		return
	}
	if _, err := s.db.ExecContext(r.Context(), `UPDATE users SET totp_secret = ? WHERE id = ? AND totp_enabled = 0`, secret, uid); err != nil {
		s.internal(w, "totp save", err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"secret": secret, "uri": totpURI(u.Name, secret)})
}

func (s *Service) handleTOTPConfirm(w http.ResponseWriter, r *http.Request) {
	uid := authctx.UserID(r.Context())
	if !s.limit(w, s.userTOTP, "u:"+uid) {
		return
	}
	var req struct {
		Code string `json:"code"`
	}
	if !decode(w, r, &req) {
		return
	}
	var secret sql.NullString
	var enabled bool
	if err := s.db.QueryRowContext(r.Context(), `SELECT totp_secret, totp_enabled FROM users WHERE id = ?`, uid).Scan(&secret, &enabled); err != nil {
		s.internal(w, "totp confirm", err)
		return
	}
	if enabled {
		writeError(w, http.StatusConflict, "totp_already_enabled")
		return
	}
	if !secret.Valid || secret.String == "" {
		writeError(w, http.StatusBadRequest, "totp_not_setup")
		return
	}
	if !s.totp.verify(uid, secret.String, req.Code, s.opts.Now()) {
		writeError(w, http.StatusUnauthorized, "invalid_totp")
		return
	}
	if _, err := s.db.ExecContext(r.Context(), `UPDATE users SET totp_enabled = 1 WHERE id = ? AND totp_secret = ?`, uid, secret.String); err != nil {
		s.internal(w, "totp enable", err)
		return
	}
	s.opts.Logger.Info("auth: totp enabled", "user", uid)
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true, "totp_enabled": true})
}

func (s *Service) handleReset(w http.ResponseWriter, r *http.Request) {
	if !s.limit(w, s.ipStrict, "ip:"+s.clientIP(r)) {
		return
	}
	var req struct {
		Name        string `json:"name"`
		TOTP        string `json:"totp"`
		NewPassword string `json:"new_password"`
	}
	if !decode(w, r, &req) {
		return
	}
	if !validPassword(req.NewPassword) {
		writeError(w, http.StatusBadRequest, "invalid_password")
		return
	}
	name := strings.TrimSpace(req.Name)
	if name == "" || len(name) > 128 {
		writeError(w, http.StatusUnauthorized, "invalid_credentials")
		return
	}
	if !s.limit(w, s.nameLimit, "name:"+strings.ToLower(name)) {
		return
	}
	u, _, secret, err := s.userByName(r.Context(), name)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		s.internal(w, "load user", err)
		return
	}
	if err != nil || !u.TOTPEnabled || !s.totp.verify(u.ID, secret, req.TOTP, s.opts.Now()) {
		writeError(w, http.StatusUnauthorized, "invalid_credentials")
		return
	}
	ph, err := hashPassword(req.NewPassword)
	if err != nil {
		s.internal(w, "hash", err)
		return
	}
	if _, err := s.db.ExecContext(r.Context(), `UPDATE users SET pass_hash = ? WHERE id = ?`, ph, u.ID); err != nil {
		s.internal(w, "reset", err)
		return
	}
	if err := s.revoke(r.Context(), `user_id = ?`, u.ID); err != nil {
		s.internal(w, "revoke all", err)
		return
	}
	s.opts.Logger.Info("auth: password reset", "user", u.ID)
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

// ---------- helpers ----------

// issue создаёт сессию и пару токенов.
func (s *Service) issue(w http.ResponseWriter, r *http.Request, status int, u userJSON, deviceID string) {
	ctx := r.Context()
	s.cleanup(ctx)
	if len(deviceID) > 128 {
		deviceID = deviceID[:128]
	}
	now := s.nowMs()
	access, refresh := newToken(), newToken()
	sessID := newUUID()
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		s.internal(w, "begin", err)
		return
	}
	defer tx.Rollback()
	if _, err := tx.ExecContext(ctx, `INSERT INTO sessions(id, user_id, refresh_hash, device_id, created_at, expires_at) VALUES(?,?,?,?,?,?)`,
		sessID, u.ID, hashToken(refresh), deviceID, now, now+refreshTTL.Milliseconds()); err != nil {
		s.internal(w, "insert session", err)
		return
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO access_tokens(token_hash, session_id, user_id, expires_at) VALUES(?,?,?,?)`,
		hashToken(access), sessID, u.ID, now+accessTTL.Milliseconds()); err != nil {
		s.internal(w, "insert access", err)
		return
	}
	if err := tx.Commit(); err != nil {
		s.internal(w, "commit", err)
		return
	}
	writeJSON(w, status, tokensJSON{AccessToken: access, AccessExpiresIn: int(accessTTL.Seconds()), RefreshToken: refresh, User: u})
}

// revoke отзывает сессии по условию (where — фрагмент с одним параметром) и удаляет их access-токены.
func (s *Service) revoke(ctx context.Context, where string, arg string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err := tx.ExecContext(ctx, `DELETE FROM access_tokens WHERE session_id IN (SELECT id FROM sessions WHERE `+where+`)`, arg); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `UPDATE sessions SET revoked_at = ? WHERE revoked_at IS NULL AND `+where, s.nowMs(), arg); err != nil {
		return err
	}
	return tx.Commit()
}

// cleanup — не чаще раза в час удаляет истёкшие access-токены и старые сессии.
func (s *Service) cleanup(ctx context.Context) {
	now := s.nowMs()
	last := s.lastCleanup.Load()
	if now-last < time.Hour.Milliseconds() || !s.lastCleanup.CompareAndSwap(last, now) {
		return
	}
	if _, err := s.db.ExecContext(ctx, `DELETE FROM access_tokens WHERE expires_at <= ?`, now); err != nil {
		s.opts.Logger.Warn("auth: cleanup access", "err", err)
	}
	old := now - 30*24*time.Hour.Milliseconds()
	if _, err := s.db.ExecContext(ctx, `DELETE FROM sessions WHERE expires_at <= ? OR (revoked_at IS NOT NULL AND revoked_at <= ?)`, now, old); err != nil {
		s.opts.Logger.Warn("auth: cleanup sessions", "err", err)
	}
}

func (s *Service) userByName(ctx context.Context, name string) (u userJSON, passHash, secret string, err error) {
	var sec sql.NullString
	err = s.db.QueryRowContext(ctx, `SELECT id, name, pass_hash, totp_secret, totp_enabled FROM users WHERE name = ?`, name).
		Scan(&u.ID, &u.Name, &passHash, &sec, &u.TOTPEnabled)
	return u, passHash, sec.String, err
}

func (s *Service) userByID(ctx context.Context, id string) (u userJSON, err error) {
	err = s.db.QueryRowContext(ctx, `SELECT id, name, totp_enabled FROM users WHERE id = ?`, id).Scan(&u.ID, &u.Name, &u.TOTPEnabled)
	return u, err
}

func (s *Service) dummy() string {
	s.dummyOnce.Do(func() {
		h, err := hashPassword(newToken())
		if err == nil {
			s.dummyHash = h
		}
	})
	return s.dummyHash
}

// limit — 429 + Retry-After при исчерпании бакета.
func (s *Service) limit(w http.ResponseWriter, l *limiter, key string) bool {
	ok, wait := l.allow(key, s.opts.Now())
	if ok {
		return true
	}
	sec := int(wait.Seconds()) + 1
	w.Header().Set("Retry-After", strconv.Itoa(sec))
	writeError(w, http.StatusTooManyRequests, "rate_limited")
	return false
}

func (s *Service) internal(w http.ResponseWriter, what string, err error) {
	s.opts.Logger.Error("auth: "+what, "err", err)
	writeError(w, http.StatusInternalServerError, "internal")
}

func (s *Service) nowMs() int64 { return s.opts.Now().UnixMilli() }

func decode(w http.ResponseWriter, r *http.Request, v any) bool {
	r.Body = http.MaxBytesReader(w, r.Body, maxBody)
	if err := json.NewDecoder(r.Body).Decode(v); err != nil {
		writeError(w, http.StatusBadRequest, "bad_json")
		return false
	}
	return true
}

// validName — 3–32 символа: буквы, цифры, «_», «-», «.».
func validName(n string) bool {
	c := utf8.RuneCountInString(n)
	if c < 3 || c > 32 || !utf8.ValidString(n) {
		return false
	}
	for _, r := range n {
		if !unicode.IsLetter(r) && !unicode.IsDigit(r) && r != '_' && r != '-' && r != '.' {
			return false
		}
	}
	return true
}

// validPassword — от 8 символов, не длиннее 256 байт.
func validPassword(p string) bool {
	return utf8.RuneCountInString(p) >= 8 && len(p) <= 256
}

func newToken() string {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		panic(err) // crypto/rand не падает на поддерживаемых ОС
	}
	return base64.RawURLEncoding.EncodeToString(b)
}

func hashToken(t string) string {
	sum := sha256.Sum256([]byte(t))
	return hex.EncodeToString(sum[:])
}

func newUUID() string {
	var b [16]byte
	if _, err := rand.Read(b[:]); err != nil {
		panic(err)
	}
	b[6] = b[6]&0x0f | 0x40
	b[8] = b[8]&0x3f | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
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
