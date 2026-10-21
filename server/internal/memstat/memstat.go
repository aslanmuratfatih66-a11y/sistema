// Package memstat — снимок потребления памяти и периодическая запись его в лог
// (SPEC §10: «потребление памяти в логах»; сервер с 1 ГБ RAM).
package memstat

import (
	"context"
	"log/slog"
	"runtime"
	"time"
)

const mb = 1024 * 1024

// Snapshot — основные показатели runtime.MemStats в мегабайтах.
type Snapshot struct {
	AllocMB      float64
	HeapInuseMB  float64
	SysMB        float64
	NumGC        uint32
	NumGoroutine int
}

// Read делает снимок памяти. runtime.ReadMemStats кратковременно останавливает мир —
// вызывать редко (раз в минуты или по запросу /healthz).
func Read() Snapshot {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return Snapshot{
		AllocMB:      round2(float64(m.Alloc) / mb),
		HeapInuseMB:  round2(float64(m.HeapInuse) / mb),
		SysMB:        round2(float64(m.Sys) / mb),
		NumGC:        m.NumGC,
		NumGoroutine: runtime.NumGoroutine(),
	}
}

// Log пишет снимок памяти в лог.
func Log(logger *slog.Logger, s Snapshot) {
	logger.Info("memory",
		"alloc_mb", s.AllocMB,
		"heap_inuse_mb", s.HeapInuseMB,
		"sys_mb", s.SysMB,
		"num_gc", s.NumGC,
		"goroutines", s.NumGoroutine,
	)
}

// Run пишет снимок памяти сразу и затем каждые interval, пока ctx не отменён.
// interval <= 0 — ничего не делает.
func Run(ctx context.Context, logger *slog.Logger, interval time.Duration) {
	if interval <= 0 {
		return
	}
	Log(logger, Read())
	t := time.NewTicker(interval)
	defer t.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			Log(logger, Read())
		}
	}
}

func round2(f float64) float64 {
	return float64(int64(f*100+0.5)) / 100
}
