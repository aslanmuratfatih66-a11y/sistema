package httpapi

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"log/slog"
	"net/http"
	"regexp"
	"runtime/debug"
	"time"
)

// HeaderRequestID — заголовок с идентификатором запроса.
const HeaderRequestID = "X-Request-Id"

type ctxKey int

const requestIDKey ctxKey = iota

// RequestID возвращает id запроса из контекста ("" если нет).
func RequestID(ctx context.Context) string {
	s, _ := ctx.Value(requestIDKey).(string)
	return s
}

// Входящий id принимаем только если он короткий и безопасный для логов.
var validRequestID = regexp.MustCompile(`^[A-Za-z0-9._-]{1,64}$`)

func requestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := r.Header.Get(HeaderRequestID)
		if !validRequestID.MatchString(id) {
			id = newID()
		}
		w.Header().Set(HeaderRequestID, id)
		next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), requestIDKey, id)))
	})
}

func newID() string {
	var b [8]byte
	_, _ = rand.Read(b[:])
	return hex.EncodeToString(b[:])
}

func recoverer(next http.Handler, logger *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				if rec == http.ErrAbortHandler {
					panic(rec)
				}
				logger.Error("panic",
					"request_id", RequestID(r.Context()),
					"method", r.Method,
					"path", r.URL.Path,
					"panic", rec,
					"stack", string(debug.Stack()),
				)
				writeError(w, http.StatusInternalServerError, "internal error")
			}
		}()
		next.ServeHTTP(w, r)
	})
}

type statusRecorder struct {
	http.ResponseWriter
	status int
	bytes  int
}

func (s *statusRecorder) WriteHeader(code int) {
	if s.status == 0 {
		s.status = code
	}
	s.ResponseWriter.WriteHeader(code)
}

func (s *statusRecorder) Write(b []byte) (int, error) {
	if s.status == 0 {
		s.status = http.StatusOK
	}
	n, err := s.ResponseWriter.Write(b)
	s.bytes += n
	return n, err
}

// Unwrap позволяет http.ResponseController добраться до исходного writer (Flush и т.п.).
func (s *statusRecorder) Unwrap() http.ResponseWriter { return s.ResponseWriter }

func logRequests(next http.Handler, logger *slog.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w}
		next.ServeHTTP(rec, r)
		status := rec.status
		if status == 0 {
			status = http.StatusOK
		}
		lvl := slog.LevelInfo
		if r.URL.Path == "/healthz" && status == http.StatusOK {
			lvl = slog.LevelDebug // не засорять journald проверками здоровья
		}
		// Тело и query не логируем: там могут быть персональные данные/токены (этап 5).
		logger.Log(r.Context(), lvl, "http",
			"request_id", RequestID(r.Context()),
			"method", r.Method,
			"path", r.URL.Path,
			"status", status,
			"bytes", rec.bytes,
			"dur_ms", time.Since(start).Milliseconds(),
		)
	})
}

func limitBody(next http.Handler, max int64) http.Handler {
	if max <= 0 {
		return next
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.ContentLength > max {
			writeError(w, http.StatusRequestEntityTooLarge, "request body too large")
			return
		}
		r.Body = http.MaxBytesReader(w, r.Body, max)
		next.ServeHTTP(w, r)
	})
}
