package config

import (
	"log/slog"
	"testing"
	"time"
)

func env(m map[string]string) func(string) string {
	return func(k string) string { return m[k] }
}

func TestLoadDefaults(t *testing.T) {
	cfg, err := Load(env(nil))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if cfg.Addr != DefaultAddr {
		t.Errorf("Addr = %q, want %q", cfg.Addr, DefaultAddr)
	}
	if cfg.DataDir != DefaultDataDir {
		t.Errorf("DataDir = %q", cfg.DataDir)
	}
	if cfg.LogLevel != slog.LevelInfo {
		t.Errorf("LogLevel = %v", cfg.LogLevel)
	}
	if cfg.LogFormat != "json" {
		t.Errorf("LogFormat = %q", cfg.LogFormat)
	}
	if cfg.MemLogInterval != DefaultMemLogInterval {
		t.Errorf("MemLogInterval = %v", cfg.MemLogInterval)
	}
	if cfg.MaxBodyBytes != DefaultMaxBodyBytes {
		t.Errorf("MaxBodyBytes = %d", cfg.MaxBodyBytes)
	}
}

func TestLoadOverrides(t *testing.T) {
	cfg, err := Load(env(map[string]string{
		"SISTEMA_ADDR":             "0.0.0.0:9000",
		"SISTEMA_DATA_DIR":         "/srv/data",
		"SISTEMA_LOG_LEVEL":        "DEBUG",
		"SISTEMA_LOG_FORMAT":       "text",
		"SISTEMA_MEM_LOG_INTERVAL": "5m",
		"SISTEMA_MAX_BODY_BYTES":   "2048",
	}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if cfg.Addr != "0.0.0.0:9000" || cfg.DataDir != "/srv/data" || cfg.LogLevel != slog.LevelDebug ||
		cfg.LogFormat != "text" || cfg.MemLogInterval != 5*time.Minute || cfg.MaxBodyBytes != 2048 {
		t.Errorf("unexpected cfg: %+v", cfg)
	}
}

func TestMemLogIntervalOff(t *testing.T) {
	cfg, err := Load(env(map[string]string{"SISTEMA_MEM_LOG_INTERVAL": "0"}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if cfg.MemLogInterval != 0 {
		t.Errorf("MemLogInterval = %v, want 0", cfg.MemLogInterval)
	}
}

func TestLoadInvalid(t *testing.T) {
	cases := map[string]map[string]string{
		"addr no port":      {"SISTEMA_ADDR": "localhost"},
		"addr bad port":     {"SISTEMA_ADDR": "127.0.0.1:99999"},
		"relative data dir": {"SISTEMA_DATA_DIR": "data"},
		"bad level":         {"SISTEMA_LOG_LEVEL": "loud"},
		"bad format":        {"SISTEMA_LOG_FORMAT": "xml"},
		"bad interval":      {"SISTEMA_MEM_LOG_INTERVAL": "often"},
		"negative interval": {"SISTEMA_MEM_LOG_INTERVAL": "-1m"},
		"tiny interval":     {"SISTEMA_MEM_LOG_INTERVAL": "10ms"},
		"bad body":          {"SISTEMA_MAX_BODY_BYTES": "-5"},
	}
	for name, m := range cases {
		t.Run(name, func(t *testing.T) {
			if _, err := Load(env(m)); err == nil {
				t.Errorf("expected error for %v", m)
			}
		})
	}
}
