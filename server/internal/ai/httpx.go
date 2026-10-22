package ai

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"
)

// httpClient — общий клиент провайдеров (таймаут на запрос — через контекст в postJSON).
var httpClient = &http.Client{Timeout: 3 * time.Minute}

// APIError — ошибка HTTP провайдера.
type APIError struct {
	Provider string
	Status   int
	Body     string
}

func (e *APIError) Error() string {
	return fmt.Sprintf("ai %s: http %d: %s", e.Provider, e.Status, e.Body)
}

// postJSON отправляет JSON и читает ответ; один повтор на 429/5xx/сетевую ошибку (с паузой retry-after, ≤ 20 с).
func postJSON(ctx context.Context, provider, url string, headers map[string]string, body any, timeout time.Duration) ([]byte, http.Header, error) {
	payload, err := json.Marshal(body)
	if err != nil {
		return nil, nil, err
	}
	var lastErr error
	for attempt := 0; attempt < 2; attempt++ {
		data, hdr, status, err := doOnce(ctx, url, headers, payload, timeout)
		if err == nil && status >= 200 && status < 300 {
			return data, hdr, nil
		}
		retry := err != nil || status == http.StatusTooManyRequests || status >= 500
		if err == nil {
			lastErr = &APIError{Provider: provider, Status: status, Body: truncate(string(data), 500)}
		} else {
			lastErr = fmt.Errorf("ai %s: %w", provider, err)
		}
		if !retry || attempt == 1 || ctx.Err() != nil {
			break
		}
		wait := 2 * time.Second
		if hdr != nil {
			if s, e := strconv.Atoi(hdr.Get("retry-after")); e == nil && s > 0 {
				wait = time.Duration(min(s, 20)) * time.Second
			}
		}
		select {
		case <-ctx.Done():
			return nil, nil, ctx.Err()
		case <-time.After(wait):
		}
	}
	return nil, nil, lastErr
}

func doOnce(ctx context.Context, url string, headers map[string]string, payload []byte, timeout time.Duration) ([]byte, http.Header, int, error) {
	cctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()
	req, err := http.NewRequestWithContext(cctx, http.MethodPost, url, bytes.NewReader(payload))
	if err != nil {
		return nil, nil, 0, err
	}
	req.Header.Set("Content-Type", "application/json")
	for k, v := range headers {
		req.Header.Set(k, v)
	}
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, nil, 0, err
	}
	defer resp.Body.Close()
	data, err := io.ReadAll(io.LimitReader(resp.Body, 32<<20))
	if err != nil {
		return nil, resp.Header, 0, err
	}
	return data, resp.Header, resp.StatusCode, nil
}

func truncate(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n]) + "…"
}

// newID — UUID v4 (как у клиента).
func newID() string {
	var b [16]byte
	_, _ = rand.Read(b[:])
	b[6] = b[6]&0x0f | 0x40
	b[8] = b[8]&0x3f | 0x80
	h := hex.EncodeToString(b[:])
	return h[0:8] + "-" + h[8:12] + "-" + h[12:16] + "-" + h[16:20] + "-" + h[20:32]
}
