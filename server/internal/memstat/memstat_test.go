package memstat

import (
	"bytes"
	"context"
	"log/slog"
	"strings"
	"sync"
	"testing"
	"time"
)

type syncBuf struct {
	mu sync.Mutex
	b  bytes.Buffer
}

func (s *syncBuf) Write(p []byte) (int, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.b.Write(p)
}

func (s *syncBuf) String() string {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.b.String()
}

func TestReadPositive(t *testing.T) {
	s := Read()
	if s.SysMB <= 0 || s.NumGoroutine <= 0 {
		t.Errorf("unexpected snapshot: %+v", s)
	}
}

func TestRunLogsPeriodically(t *testing.T) {
	buf := &syncBuf{}
	logger := slog.New(slog.NewJSONHandler(buf, nil))
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan struct{})
	go func() { Run(ctx, logger, 10*time.Millisecond); close(done) }()

	deadline := time.Now().Add(2 * time.Second)
	for strings.Count(buf.String(), `"msg":"memory"`) < 2 && time.Now().Before(deadline) {
		time.Sleep(5 * time.Millisecond)
	}
	cancel()
	<-done
	if n := strings.Count(buf.String(), `"msg":"memory"`); n < 2 {
		t.Fatalf("expected >=2 memory log lines, got %d: %s", n, buf.String())
	}
	if !strings.Contains(buf.String(), `"alloc_mb"`) {
		t.Errorf("alloc_mb missing: %s", buf.String())
	}
}

func TestRunDisabled(t *testing.T) {
	buf := &syncBuf{}
	Run(context.Background(), slog.New(slog.NewJSONHandler(buf, nil)), 0)
	if buf.String() != "" {
		t.Errorf("expected no output, got %q", buf.String())
	}
}
