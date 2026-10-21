package auth

import (
	"math"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

// limiter — токен-бакеты в памяти по ключу (IP, имя, пользователь).
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
		l.sweep(now)
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
	wait := time.Duration((1 - b.tokens) / l.rate * float64(time.Second))
	return false, wait
}

// sweep удаляет бакеты, которые уже полностью восполнились (эквивалентны новым).
func (l *limiter) sweep(now time.Time) {
	l.lastSweep = now
	full := time.Duration(l.burst / l.rate * float64(time.Second))
	for k, b := range l.buckets {
		if now.Sub(b.last) >= full {
			delete(l.buckets, k)
		}
	}
}

// clientIP — RemoteAddr; при TrustProxy — последний адрес из X-Forwarded-For (его добавил наш прокси).
func (s *Service) clientIP(r *http.Request) string {
	if s.opts.TrustProxy {
		if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
			parts := strings.Split(xff, ",")
			for i := len(parts) - 1; i >= 0; i-- {
				if ip := strings.TrimSpace(parts[i]); ip != "" {
					return ip
				}
			}
		}
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}
