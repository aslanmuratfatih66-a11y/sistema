package httpapi

import (
	"bytes"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func newTestHandler(t *testing.T, logBuf *bytes.Buffer) http.Handler {
	t.Helper()
	start := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	if logBuf == nil {
		logBuf = &bytes.Buffer{}
	}
	return New(Options{
		Logger:       slog.New(slog.NewJSONHandler(logBuf, &slog.HandlerOptions{Level: slog.LevelDebug})),
		Version:      "test-1.2.3",
		StartedAt:    start,
		MaxBodyBytes: 16,
		now:          func() time.Time { return start.Add(42 * time.Second) },
	})
}

func TestHealthz(t *testing.T) {
	h := newTestHandler(t, nil)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, httptest.NewRequest(http.MethodGet, "/healthz", nil))

	if rr.Code != http.StatusOK {
		t.Fatalf("status = %d", rr.Code)
	}
	if ct := rr.Header().Get("Content-Type"); !strings.HasPrefix(ct, "application/json") {
		t.Errorf("Content-Type = %q", ct)
	}
	var body map[string]any
	if err := json.Unmarshal(rr.Body.Bytes(), &body); err != nil {
		t.Fatalf("bad json: %v", err)
	}
	if body["status"] != "ok" || body["version"] != "test-1.2.3" || body["uptime_s"] != float64(42) {
		t.Errorf("unexpected body: %v", body)
	}
	if v, ok := body["mem_alloc_mb"].(float64); !ok || v < 0 {
		t.Errorf("mem_alloc_mb = %v", body["mem_alloc_mb"])
	}
	if rr.Header().Get(HeaderRequestID) == "" {
		t.Error("missing request id header")
	}
}

func TestHealthzMethodNotAllowed(t *testing.T) {
	rr := httptest.NewRecorder()
	newTestHandler(t, nil).ServeHTTP(rr, httptest.NewRequest(http.MethodPost, "/healthz", nil))
	if rr.Code != http.StatusMethodNotAllowed {
		t.Errorf("status = %d, want 405", rr.Code)
	}
}

func TestPing(t *testing.T) {
	rr := httptest.NewRecorder()
	newTestHandler(t, nil).ServeHTTP(rr, httptest.NewRequest(http.MethodGet, "/api/v1/ping", nil))
	if rr.Code != http.StatusOK || !strings.Contains(rr.Body.String(), `"pong"`) {
		t.Errorf("status = %d body = %s", rr.Code, rr.Body.String())
	}
}

func TestNotFound(t *testing.T) {
	for _, p := range []string{"/", "/api/v1/unknown", "/api/v2/ping"} {
		rr := httptest.NewRecorder()
		newTestHandler(t, nil).ServeHTTP(rr, httptest.NewRequest(http.MethodGet, p, nil))
		if rr.Code != http.StatusNotFound {
			t.Errorf("%s: status = %d, want 404", p, rr.Code)
		}
	}
}

func TestRequestIDPropagation(t *testing.T) {
	h := newTestHandler(t, nil)

	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	req.Header.Set(HeaderRequestID, "abc-123")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	if got := rr.Header().Get(HeaderRequestID); got != "abc-123" {
		t.Errorf("request id = %q, want abc-123", got)
	}

	req = httptest.NewRequest(http.MethodGet, "/healthz", nil)
	req.Header.Set(HeaderRequestID, "bad id\nwith newline")
	rr = httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	if got := rr.Header().Get(HeaderRequestID); got == "" || strings.ContainsAny(got, " \n") {
		t.Errorf("unsafe request id not replaced: %q", got)
	}
}

func TestRecoverer(t *testing.T) {
	var logBuf bytes.Buffer
	logger := slog.New(slog.NewJSONHandler(&logBuf, nil))
	h := requestID(recoverer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {
		panic("boom")
	}), logger))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, httptest.NewRequest(http.MethodGet, "/x", nil))
	if rr.Code != http.StatusInternalServerError {
		t.Errorf("status = %d, want 500", rr.Code)
	}
	if !strings.Contains(logBuf.String(), `"panic":"boom"`) {
		t.Errorf("panic not logged: %s", logBuf.String())
	}
}

func TestRequestLogging(t *testing.T) {
	var logBuf bytes.Buffer
	h := newTestHandler(t, &logBuf)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, httptest.NewRequest(http.MethodGet, "/api/v1/ping?token=secret", nil))
	out := logBuf.String()
	for _, want := range []string{`"msg":"http"`, `"path":"/api/v1/ping"`, `"status":200`, `"request_id"`} {
		if !strings.Contains(out, want) {
			t.Errorf("log missing %s: %s", want, out)
		}
	}
	if strings.Contains(out, "secret") {
		t.Errorf("query string leaked into log: %s", out)
	}
}

func TestBodyLimit(t *testing.T) {
	logger := slog.New(slog.NewJSONHandler(io.Discard, nil))
	var readErr error
	inner := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, readErr = io.ReadAll(r.Body)
		if readErr != nil {
			writeError(w, http.StatusRequestEntityTooLarge, "too large")
			return
		}
		w.WriteHeader(http.StatusNoContent)
	})
	h := logRequests(limitBody(inner, 8), logger)

	// Content-Length известен и превышает лимит — отказ сразу.
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, httptest.NewRequest(http.MethodPost, "/", strings.NewReader("0123456789")))
	if rr.Code != http.StatusRequestEntityTooLarge {
		t.Errorf("status = %d, want 413", rr.Code)
	}

	// Content-Length неизвестен — срабатывает MaxBytesReader.
	req := httptest.NewRequest(http.MethodPost, "/", io.NopCloser(strings.NewReader("0123456789")))
	req.ContentLength = -1
	rr = httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	if rr.Code != http.StatusRequestEntityTooLarge || readErr == nil {
		t.Errorf("status = %d err = %v, want 413 + error", rr.Code, readErr)
	}

	// В пределах лимита — ок.
	rr = httptest.NewRecorder()
	h.ServeHTTP(rr, httptest.NewRequest(http.MethodPost, "/", strings.NewReader("short")))
	if rr.Code != http.StatusNoContent {
		t.Errorf("status = %d, want 204", rr.Code)
	}
}
