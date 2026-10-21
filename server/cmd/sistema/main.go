// Команда sistema — сервер проекта «Система» (один бинарник).
package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/config"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/httpapi"
	"github.com/aslanmuratfatih66-a11y/sistema/server/internal/memstat"
)

// version подставляется при сборке: go build -ldflags "-X main.version=1.2.3".
var version = "dev"

const shutdownTimeout = 15 * time.Second

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "-version" || os.Args[1] == "--version") {
		fmt.Println(version)
		return
	}
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "sistema:", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load(os.Getenv)
	if err != nil {
		return fmt.Errorf("config: %w", err)
	}
	logger := newLogger(os.Stdout, cfg)
	slog.SetDefault(logger)

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// TODO(этап 5): открыть SQLite в cfg.DataDir, миграции, планировщик фоновых задач, бэкапы.

	go memstat.Run(ctx, logger, cfg.MemLogInterval)

	srv := &http.Server{
		Addr: cfg.Addr,
		Handler: httpapi.New(httpapi.Options{
			Logger:       logger,
			Version:      version,
			StartedAt:    time.Now(),
			MaxBodyBytes: cfg.MaxBodyBytes,
		}),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      60 * time.Second,
		IdleTimeout:       120 * time.Second,
		MaxHeaderBytes:    32 << 10,
		ErrorLog:          slog.NewLogLogger(logger.Handler(), slog.LevelWarn),
		BaseContext:       func(net.Listener) context.Context { return ctx },
	}

	// Слушаем явно, чтобы ошибка «порт занят» вернулась сразу и процесс завершился с кодом 1.
	ln, err := net.Listen("tcp", cfg.Addr)
	if err != nil {
		return fmt.Errorf("listen %s: %w", cfg.Addr, err)
	}
	logger.Info("starting", "version", version, "addr", ln.Addr().String(), "data_dir", cfg.DataDir)

	errCh := make(chan error, 1)
	go func() { errCh <- srv.Serve(ln) }()

	select {
	case err := <-errCh:
		if !errors.Is(err, http.ErrServerClosed) {
			return fmt.Errorf("serve: %w", err)
		}
		return nil
	case <-ctx.Done():
	}

	logger.Info("shutting down")
	shCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()
	if err := srv.Shutdown(shCtx); err != nil {
		return fmt.Errorf("shutdown: %w", err)
	}
	logger.Info("stopped")
	return nil
}

func newLogger(w io.Writer, cfg config.Config) *slog.Logger {
	opts := &slog.HandlerOptions{Level: cfg.LogLevel}
	if cfg.LogFormat == "text" {
		return slog.New(slog.NewTextHandler(w, opts))
	}
	return slog.New(slog.NewJSONHandler(w, opts))
}
