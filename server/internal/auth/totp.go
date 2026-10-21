package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"crypto/subtle"
	"encoding/base32"
	"encoding/binary"
	"fmt"
	"net/url"
	"strings"
	"sync"
	"time"
)

// TOTP по RFC 6238: HMAC-SHA1, шаг 30 с, 6 цифр, окно ±1 шаг.
const (
	totpPeriod = 30
	totpDigits = 6
	totpIssuer = "Sistema"
)

var b32 = base32.StdEncoding.WithPadding(base32.NoPadding)

func newTOTPSecret() (string, error) {
	b := make([]byte, 20)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return b32.EncodeToString(b), nil
}

func totpURI(name, secret string) string {
	label := url.PathEscape(totpIssuer + ":" + name)
	return "otpauth://totp/" + label + "?secret=" + secret + "&issuer=" + totpIssuer
}

func totpCode(key []byte, step int64) string {
	var msg [8]byte
	binary.BigEndian.PutUint64(msg[:], uint64(step))
	h := hmac.New(sha1.New, key)
	h.Write(msg[:])
	sum := h.Sum(nil)
	off := sum[len(sum)-1] & 0x0f
	v := binary.BigEndian.Uint32(sum[off:off+4]) & 0x7fffffff
	return fmt.Sprintf("%06d", v%1_000_000)
}

// totpGuard — защита от повторного использования кода: последний принятый шаг на пользователя (в памяти).
type totpGuard struct {
	mu   sync.Mutex
	last map[string]int64
}

func newTOTPGuard() *totpGuard { return &totpGuard{last: map[string]int64{}} }

// verify проверяет код и помечает шаг использованным. false — неверный или уже использованный код.
func (g *totpGuard) verify(userID, secret, code string, now time.Time) bool {
	code = strings.TrimSpace(code)
	if len(code) != totpDigits {
		return false
	}
	for _, c := range code {
		if c < '0' || c > '9' {
			return false
		}
	}
	key, err := b32.DecodeString(strings.ToUpper(strings.TrimSpace(secret)))
	if err != nil || len(key) == 0 {
		return false
	}
	cur := now.Unix() / totpPeriod
	var matched int64 = -1
	for _, st := range []int64{cur - 1, cur, cur + 1} {
		if subtle.ConstantTimeCompare([]byte(totpCode(key, st)), []byte(code)) == 1 {
			matched = st
		}
	}
	if matched < 0 {
		return false
	}
	g.mu.Lock()
	defer g.mu.Unlock()
	if matched <= g.last[userID] {
		return false
	}
	g.last[userID] = matched
	// Чистка: записи старше окна не нужны.
	if len(g.last) > 1024 {
		for k, st := range g.last {
			if st < cur-2 {
				delete(g.last, k)
			}
		}
	}
	return true
}
