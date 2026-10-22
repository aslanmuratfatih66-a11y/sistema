package finance

import (
	"math"
	"sync"
	"time"
)

// limiter — токен-бакеты в памяти по ключу (пользователь); копия подхода auth/ratelimit.go.
type limiter struct {
	mu        sync.Mutex
	rate      float64 // токенов в секунду
	burst     float64
	buckets   map[string]*bucket
	lastSweep time.Time
}

type bucket struct {
	tokens float64
	last   time.Time
}

func newLimiter(n int, per time.Duration) *limiter {
	return &limiter{rate: float64(n) / per.Seconds(), burst: float64(n), buckets: map[string]*bucket{}}
}

// allow списывает токен; при отказе возвращает, через сколько придёт следующий.
func (l *limiter) allow(key string, now time.Time) (bool, time.Duration) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if now.Sub(l.lastSweep) > time.Minute {
		l.lastSweep = now
		full := time.Duration(l.burst / l.rate * float64(time.Second))
		for k, b := range l.buckets {
			if now.Sub(b.last) >= full {
				delete(l.buckets, k)
			}
		}
	}
	b := l.buckets[key]
	if b == nil {
		b = &bucket{tokens: l.burst, last: now}
		l.buckets[key] = b
	}
	if el := now.Sub(b.last).Seconds(); el > 0 {
		b.tokens = math.Min(l.burst, b.tokens+el*l.rate)
	}
	b.last = now
	if b.tokens >= 1 {
		b.tokens--
		return true, 0
	}
	return false, time.Duration((1 - b.tokens) / l.rate * float64(time.Second))
}
