# Сервер «Система»

Go, один бинарник, только стандартная библиотека (на этапе 0). Описание API — `api/openapi.yaml`.

## Запуск локально

```bash
cd server
SISTEMA_DATA_DIR=/tmp/sistema-data go run ./cmd/sistema
curl 127.0.0.1:8087/healthz
# {"status":"ok","version":"dev","uptime_s":3,"mem_alloc_mb":0.46}
```

Проверки:

```bash
go vet ./...
go test ./...
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w -X main.version=0.1.0" -o sistema-server ./cmd/sistema
./sistema-server --version
```

Остановка — SIGINT/SIGTERM: сервер дожидается текущих запросов (до 15 с).

## Переменные окружения

| Переменная | По умолчанию | Описание |
|---|---|---|
| `SISTEMA_ADDR` | `127.0.0.1:8087` | Адрес HTTP. Снаружи — только через reverse-proxy с HTTPS (этап 5). |
| `SISTEMA_DATA_DIR` | `/opt/sistema/data` | Абсолютный путь к данным (БД, фото, бэкапы — этап 5). |
| `SISTEMA_LOG_LEVEL` | `info` | `debug`, `info`, `warn`, `error`. На `debug` логируются и запросы `/healthz`. |
| `SISTEMA_LOG_FORMAT` | `json` | `json` или `text`. Лог пишется в stdout → journald. |
| `SISTEMA_MEM_LOG_INTERVAL` | `15m` | Как часто писать в лог потребление памяти (`5m`, `1h`; `0` — выключить). |
| `SISTEMA_MAX_BODY_BYTES` | `1048576` | Лимит тела запроса, байт (загрузка фото получит свой лимит на этапе 5). |

Неверное значение любой переменной — процесс сразу завершается с кодом 1 и сообщением в stderr.

## Структура

- `cmd/sistema` — точка входа, конфиг, логгер, graceful shutdown, таймауты HTTP.
- `internal/config` — чтение и валидация переменных окружения.
- `internal/httpapi` — роутер (`GET /healthz`, `GET /api/v1/ping`), middleware: request id, recover, лог запросов, лимит тела.
- `internal/memstat` — снимок памяти и периодическая запись в лог.

Этап 5 (не реализовано): SQLite (`modernc.org/sqlite`), auth, sync, фото, бэкапы, планировщик.
