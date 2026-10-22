package messages

import (
	"bytes"
	"context"
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

// Сообщение старше этого при отправке не пушим (сервер был выключен — уже неактуально).
const pushStale = 30 * time.Minute

// RunPusher — раз в минуту отправляет наступившие сообщения через ntfy/FCM тем, у кого есть push-токены.
// Сообщения, уже забранные клиентом (fetched_at), не пушатся — они стоят локальными уведомлениями.
// Без NtfyURL и FCMKeyFile сразу возвращается. Запускается из main: go msgSvc.RunPusher(ctx).
func (s *Service) RunPusher(ctx context.Context) {
	if s.opts.NtfyURL == "" && s.opts.FCMKeyFile == "" {
		return
	}
	if s.opts.FCMKeyFile != "" {
		acc, err := loadFCMAccount(s.opts.FCMKeyFile)
		if err != nil {
			s.log.Error("messages: fcm key", "err", err)
		} else {
			s.fcm = acc
		}
	}
	t := time.NewTicker(time.Minute)
	defer t.Stop()
	for {
		if err := s.pushDue(ctx); err != nil && ctx.Err() == nil {
			s.log.Warn("messages: push", "err", err)
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

type dueMsg struct {
	id, user, kind, title, body, ref string
}

func (s *Service) pushDue(ctx context.Context) error {
	now := time.Now()
	rows, err := s.db.QueryContext(ctx,
		`SELECT m.id, m.user_id, m.kind, m.title, m.body, COALESCE(m.quest_ref, '') FROM messages m
		 WHERE m.pushed_at IS NULL AND m.fetched_at IS NULL AND m.kind <> 'chat'
		   AND m.deliver_at <= ? AND m.deliver_at > ?
		   AND EXISTS (SELECT 1 FROM push_tokens p WHERE p.user_id = m.user_id AND p.platform IN ('android', 'ntfy'))
		 ORDER BY m.deliver_at LIMIT 200`, now.UnixMilli(), now.Add(-pushStale).UnixMilli())
	if err != nil {
		return err
	}
	var due []dueMsg
	for rows.Next() {
		var m dueMsg
		if err := rows.Scan(&m.id, &m.user, &m.kind, &m.title, &m.body, &m.ref); err != nil {
			rows.Close()
			return err
		}
		due = append(due, m)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return err
	}
	for _, m := range due {
		// Упрёк — только если квест так и не выполнен (по последней синхронизации).
		if m.kind == "reproach" && m.ref != "" && !s.stillPending(ctx, m.user, m.ref) {
			s.markPushed(ctx, m.id, now)
			continue
		}
		s.sendToUser(ctx, m)
		s.markPushed(ctx, m.id, now)
	}
	return nil
}

func (s *Service) stillPending(ctx context.Context, uid, instanceID string) bool {
	var status string
	err := s.db.QueryRowContext(ctx,
		`SELECT COALESCE(json_extract(data, '$.status'), '') FROM records
		 WHERE user_id = ? AND tbl = 'quest_instances' AND id = ? AND deleted_at IS NULL`, uid, instanceID).Scan(&status)
	return err == nil && (status == "pending" || status == "failed")
}

func (s *Service) markPushed(ctx context.Context, id string, now time.Time) {
	if _, err := s.db.ExecContext(ctx, `UPDATE messages SET pushed_at = ? WHERE id = ?`, now.UnixMilli(), id); err != nil {
		s.log.Warn("messages: mark pushed", "err", err)
	}
}

func (s *Service) sendToUser(ctx context.Context, m dueMsg) {
	rows, err := s.db.QueryContext(ctx,
		`SELECT platform, token FROM push_tokens WHERE user_id = ? AND platform IN ('android', 'ntfy')`, m.user)
	if err != nil {
		s.log.Warn("messages: tokens", "err", err)
		return
	}
	type tok struct{ platform, token string }
	var toks []tok
	for rows.Next() {
		var t tok
		if rows.Scan(&t.platform, &t.token) == nil {
			toks = append(toks, t)
		}
	}
	rows.Close()
	for _, t := range toks {
		var err error
		switch {
		case t.platform == "ntfy" && s.opts.NtfyURL != "":
			err = s.sendNtfy(ctx, t.token, m)
		case t.platform == "android" && s.fcm != nil:
			err = s.sendFCM(ctx, t.token, m)
			if errors.Is(err, errTokenGone) {
				_, _ = s.db.ExecContext(ctx, `DELETE FROM push_tokens WHERE user_id = ? AND platform = ? AND token = ?`,
					m.user, t.platform, t.token)
				err = nil
			}
		}
		if err != nil {
			s.log.Warn("messages: send", "platform", t.platform, "err", err)
		}
	}
}

// ---- ntfy: публикация JSON в корень сервера (UTF-8 в заголовке без перекодировки) ----

func (s *Service) sendNtfy(ctx context.Context, topic string, m dueMsg) error {
	body, _ := json.Marshal(map[string]any{"topic": topic, "title": m.title, "message": m.body, "tags": []string{m.kind}})
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, strings.TrimRight(s.opts.NtfyURL, "/"), bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	if s.opts.NtfyToken != "" {
		req.Header.Set("Authorization", "Bearer "+s.opts.NtfyToken)
	}
	resp, err := s.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
	if resp.StatusCode >= 300 {
		return fmt.Errorf("ntfy: http %d", resp.StatusCode)
	}
	return nil
}

// ---- FCM HTTP v1: JWT сервисного аккаунта (RS256) → access token → messages:send ----

type fcmAccount struct {
	ProjectID   string `json:"project_id"`
	ClientEmail string `json:"client_email"`
	PrivateKey  string `json:"private_key"`
	TokenURI    string `json:"token_uri"`
	key         *rsa.PrivateKey
}

var errTokenGone = errors.New("fcm: token unregistered")

func loadFCMAccount(path string) (*fcmAccount, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var a fcmAccount
	if err := json.Unmarshal(raw, &a); err != nil {
		return nil, err
	}
	if a.ProjectID == "" || a.ClientEmail == "" || a.PrivateKey == "" {
		return nil, errors.New("fcm: incomplete service account json")
	}
	if a.TokenURI == "" {
		a.TokenURI = "https://oauth2.googleapis.com/token"
	}
	block, _ := pem.Decode([]byte(a.PrivateKey))
	if block == nil {
		return nil, errors.New("fcm: bad private key pem")
	}
	if k, err := x509.ParsePKCS8PrivateKey(block.Bytes); err == nil {
		rk, ok := k.(*rsa.PrivateKey)
		if !ok {
			return nil, errors.New("fcm: private key is not RSA")
		}
		a.key = rk
	} else if rk, err2 := x509.ParsePKCS1PrivateKey(block.Bytes); err2 == nil {
		a.key = rk
	} else {
		return nil, fmt.Errorf("fcm: parse key: %w", err)
	}
	return &a, nil
}

func b64(b []byte) string { return base64.RawURLEncoding.EncodeToString(b) }

// fcmToken — access token OAuth2 (кэшируется до истечения минус минута).
func (s *Service) fcmToken(ctx context.Context) (string, error) {
	s.fcmMu.Lock()
	defer s.fcmMu.Unlock()
	if s.fcmTok != "" && time.Now().Before(s.fcmExp) {
		return s.fcmTok, nil
	}
	a := s.fcm
	now := time.Now()
	header, _ := json.Marshal(map[string]string{"alg": "RS256", "typ": "JWT"})
	claims, _ := json.Marshal(map[string]any{
		"iss":   a.ClientEmail,
		"scope": "https://www.googleapis.com/auth/firebase.messaging",
		"aud":   a.TokenURI,
		"iat":   now.Unix(),
		"exp":   now.Add(time.Hour).Unix(),
	})
	signing := b64(header) + "." + b64(claims)
	sum := sha256.Sum256([]byte(signing))
	sig, err := rsa.SignPKCS1v15(nil, a.key, crypto.SHA256, sum[:])
	if err != nil {
		return "", err
	}
	form := url.Values{
		"grant_type": {"urn:ietf:params:oauth:grant-type:jwt-bearer"},
		"assertion":  {signing + "." + b64(sig)},
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, a.TokenURI, strings.NewReader(form.Encode()))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err := s.http.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	var tr struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int    `json:"expires_in"`
	}
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return "", fmt.Errorf("fcm oauth: http %d: %s", resp.StatusCode, b)
	}
	if err := json.NewDecoder(resp.Body).Decode(&tr); err != nil || tr.AccessToken == "" {
		return "", fmt.Errorf("fcm oauth: bad response: %v", err)
	}
	ttl := time.Duration(tr.ExpiresIn) * time.Second
	if ttl <= 2*time.Minute {
		ttl = 30 * time.Minute
	}
	s.fcmTok, s.fcmExp = tr.AccessToken, now.Add(ttl-time.Minute)
	return s.fcmTok, nil
}

func (s *Service) sendFCM(ctx context.Context, token string, m dueMsg) error {
	at, err := s.fcmToken(ctx)
	if err != nil {
		return err
	}
	msg := map[string]any{"message": map[string]any{
		"token":        token,
		"notification": map[string]string{"title": m.title, "body": m.body},
		"data":         map[string]string{"message_id": m.id, "kind": m.kind, "quest_ref": m.ref},
		"android": map[string]any{
			"priority": "high",
			// Канал «Сообщения Системы» создаёт клиент (ai_messages_scheduler.dart).
			"notification": map[string]string{"channel_id": "sistema_ai"},
		},
	}}
	body, _ := json.Marshal(msg)
	u := "https://fcm.googleapis.com/v1/projects/" + url.PathEscape(s.fcm.ProjectID) + "/messages:send"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+at)
	req.Header.Set("Content-Type", "application/json")
	resp, err := s.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	b, _ := io.ReadAll(io.LimitReader(resp.Body, 2048))
	switch {
	case resp.StatusCode == http.StatusOK:
		return nil
	case resp.StatusCode == http.StatusNotFound || bytes.Contains(b, []byte("UNREGISTERED")):
		return errTokenGone
	case resp.StatusCode == http.StatusUnauthorized:
		s.fcmMu.Lock()
		s.fcmTok = "" // токен отозван — получить заново в следующий раз
		s.fcmMu.Unlock()
	}
	return fmt.Errorf("fcm send: http %d: %s", resp.StatusCode, b)
}
