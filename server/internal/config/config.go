// Package config загружает и валидирует конфигурацию сервера из переменных окружения.
package config

import (
	"errors"
	"fmt"
	"log/slog"
	"net"
	"strconv"
	"strings"
	"time"
)

// Значения по умолчанию.
const (
	DefaultAddr           = "127.0.0.1:8087"
	DefaultDataDir        = "/opt/sistema/data"
	DefaultLogLevel       = "info"
	DefaultLogFormat      = "json"
	DefaultMemLogInterval = 15 * time.Minute
	DefaultMaxBodyBytes   = 1 << 20 // 1 МиБ; загрузка фото (этап 5) получит отдельный лимит
)

// Config — конфигурация процесса.
type Config struct {
	Addr     string // SISTEMA_ADDR — адрес HTTP-сервера host:port
	DataDir  string // SISTEMA_DATA_DIR — каталог данных (БД, фото, бэкапы)
	LogLevel slog.Level
	// LogFormat — "json" или "text" (SISTEMA_LOG_FORMAT).
	LogFormat string
	// MemLogInterval — период записи потребления памяти в лог (SISTEMA_MEM_LOG_INTERVAL,
	// формат time.ParseDuration, например "15m"; "0" — выключено).
	MemLogInterval time.Duration
	// MaxBodyBytes — лимит размера тела запроса (SISTEMA_MAX_BODY_BYTES).
	MaxBodyBytes int64
}

// Load читает конфиг через getenv (обычно os.Getenv) и валидирует его.
func Load(getenv func(string) string) (Config, error) {
	get := func(key, def string) string {
		if v := strings.TrimSpace(getenv(key)); v != "" {
			return v
		}
		return def
	}

	cfg := Config{
		Addr:      get("SISTEMA_ADDR", DefaultAddr),
		DataDir:   get("SISTEMA_DATA_DIR", DefaultDataDir),
		LogFormat: strings.ToLower(get("SISTEMA_LOG_FORMAT", DefaultLogFormat)),
	}

	var errs []error

	lvl, err := parseLevel(get("SISTEMA_LOG_LEVEL", DefaultLogLevel))
	if err != nil {
		errs = append(errs, err)
	}
	cfg.LogLevel = lvl

	cfg.MemLogInterval = DefaultMemLogInterval
	if v := get("SISTEMA_MEM_LOG_INTERVAL", ""); v != "" {
		d, err := time.ParseDuration(v)
		switch {
		case err != nil:
			errs = append(errs, fmt.Errorf("SISTEMA_MEM_LOG_INTERVAL: %w", err))
		case d < 0:
			errs = append(errs, errors.New("SISTEMA_MEM_LOG_INTERVAL: must be >= 0"))
		case d > 0 && d < time.Second:
			errs = append(errs, errors.New("SISTEMA_MEM_LOG_INTERVAL: must be 0 (off) or >= 1s"))
		default:
			cfg.MemLogInterval = d
		}
	}

	cfg.MaxBodyBytes = DefaultMaxBodyBytes
	if v := get("SISTEMA_MAX_BODY_BYTES", ""); v != "" {
		n, err := strconv.ParseInt(v, 10, 64)
		if err != nil || n <= 0 {
			errs = append(errs, fmt.Errorf("SISTEMA_MAX_BODY_BYTES: positive integer expected, got %q", v))
		} else {
			cfg.MaxBodyBytes = n
		}
	}

	if err := cfg.validate(); err != nil {
		errs = append(errs, err)
	}
	return cfg, errors.Join(errs...)
}

func (c Config) validate() error {
	var errs []error
	host, port, err := net.SplitHostPort(c.Addr)
	if err != nil {
		errs = append(errs, fmt.Errorf("SISTEMA_ADDR: %w", err))
	} else {
		p, err := strconv.Atoi(port)
		if err != nil || p < 1 || p > 65535 {
			errs = append(errs, fmt.Errorf("SISTEMA_ADDR: invalid port %q", port))
		}
		_ = host // пустой host = все интерфейсы; допустимо, но по умолчанию слушаем localhost
	}
	if c.DataDir == "" || (!strings.HasPrefix(c.DataDir, "/") && !isWindowsAbs(c.DataDir)) {
		errs = append(errs, fmt.Errorf("SISTEMA_DATA_DIR: absolute path expected, got %q", c.DataDir))
	}
	if c.LogFormat != "json" && c.LogFormat != "text" {
		errs = append(errs, fmt.Errorf("SISTEMA_LOG_FORMAT: json or text expected, got %q", c.LogFormat))
	}
	return errors.Join(errs...)
}

// isWindowsAbs допускает пути вида C:\... для локального запуска на Windows.
func isWindowsAbs(p string) bool {
	return len(p) >= 3 && p[1] == ':' && (p[2] == '\\' || p[2] == '/')
}

func parseLevel(s string) (slog.Level, error) {
	switch strings.ToLower(s) {
	case "debug":
		return slog.LevelDebug, nil
	case "info":
		return slog.LevelInfo, nil
	case "warn", "warning":
		return slog.LevelWarn, nil
	case "error":
		return slog.LevelError, nil
	}
	return slog.LevelInfo, fmt.Errorf("SISTEMA_LOG_LEVEL: debug|info|warn|error expected, got %q", s)
}
