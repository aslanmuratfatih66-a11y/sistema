# Деплой сервера «Система» (Debian)

Сервис живёт отдельно от всего, что уже есть на сервере: пользователь `sistema`, папка `/opt/sistema`,
порт `127.0.0.1:8087`, юнит `sistema.service`. Скрипт установки чужие сервисы, порты и конфиги не трогает.

## Файлы

- `sistema.service` — systemd-юнит (MemoryMax=256M, hardening, запись только в `/opt/sistema/data`).
- `.env.example` — шаблон `/opt/sistema/.env` (без секретов).
- `install.sh` — установка/обновление (идемпотентный).

## Установка / обновление

1. Взять бинарник `linux/amd64` из артефакта CI (или собрать:
   `cd server && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w -X main.version=X.Y.Z" -o ../deploy/sistema-server ./cmd/sistema`).
2. Скопировать на сервер папку `deploy/` вместе с бинарником `sistema-server`.
3. Запустить:

```bash
cd deploy
chmod +x install.sh
sudo ./install.sh ./sistema-server
```

Скрипт:
- проверяет, что порт из `SISTEMA_ADDR` свободен (`ss -ltn`); если занят чужим процессом — останавливается;
- создаёт системного пользователя `sistema` (если нет) и папки `/opt/sistema/{bin,data}`;
- кладёт бинарник в `/opt/sistema/bin/sistema-server`;
- создаёт `/opt/sistema/.env` из шаблона **только если его ещё нет** (существующий не перезаписывается);
- ставит юнит, `daemon-reload`, `enable --now`, при обновлении — перезапуск;
- проверяет `/healthz`.

Если порт 8087 занят — поменяйте `SISTEMA_ADDR` в `/opt/sistema/.env` (или в `.env.example` перед первой
установкой) и запустите скрипт снова.

## Проверка

```bash
curl 127.0.0.1:8087/healthz
# {"status":"ok","version":"X.Y.Z","uptime_s":12,"mem_alloc_mb":0.5}
systemctl status sistema
journalctl -u sistema -f          # логи, в т.ч. строки "msg":"memory" с потреблением памяти
```

Настройки — `/opt/sistema/.env`, после изменения: `sudo systemctl restart sistema`.

## HTTPS

Инструкция на этапе 5: DuckDNS + Caddy (Let's Encrypt), **только если порт 443 свободен**
(`ss -ltn 'sport = :443'`). Если 443 занят — ничего не трогать и спросить пользователя.

## Удаление

```bash
sudo systemctl disable --now sistema
sudo rm /etc/systemd/system/sistema.service && sudo systemctl daemon-reload
# данные: /opt/sistema/data — удалять вручную, только осознанно
```
