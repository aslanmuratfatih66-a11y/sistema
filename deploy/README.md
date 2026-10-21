# Деплой сервера «Система» (Debian)

Сервис живёт отдельно от всего, что уже есть на сервере: пользователь `sistema`, папка `/opt/sistema`,
порт `127.0.0.1:8087`, юнит `sistema.service`. Скрипты чужие сервисы, порты и конфиги не трогают.

## Файлы

- `sistema.service` — systemd-юнит (MemoryMax=256M, hardening, запись только в `/opt/sistema/data` и `/opt/sistema/backups`).
- `.env.example` — шаблон `/opt/sistema/.env` (все настройки с комментариями, без секретов).
- `install.sh` — установка/обновление (идемпотентный).
- `restore.sh` — восстановление из бэкапа.
- `https.md` — HTTPS: DuckDNS + Let's Encrypt (Caddy или существующий nginx).

Раскладка на сервере:

```
/opt/sistema/bin/sistema-server     бинарник
/opt/sistema/bin/restore.sh         восстановление
/opt/sistema/.env                   настройки (root:sistema 0640)
/opt/sistema/data/sistema.db        база
/opt/sistema/data/photos/           фото
/opt/sistema/backups/<yyyy-mm-dd>/sistema.db   ежедневные бэкапы БД (14 дней)
/opt/sistema/backups/photos/        зеркало фото (инкрементально)
```

## 1. Бинарник

Вариант А — скачать артефакт CI (GitHub → Actions → последний зелёный run → `sistema-server-linux-amd64`).

Вариант Б — собрать (на любой ОС с Go):

```bash
cd server
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w -X main.version=0.5.0" -o ../deploy/sistema-server ./cmd/sistema
```

(PowerShell: `$env:GOOS="linux"; $env:GOARCH="amd64"; $env:CGO_ENABLED="0"; go build ...`)

## 2. Копирование на сервер

```bash
scp -r deploy user@SERVER:~/sistema-deploy
# бинарник должен лежать в ~/sistema-deploy/sistema-server
```

## 3. Установка

```bash
ssh user@SERVER
cd ~/sistema-deploy
chmod +x install.sh restore.sh
sudo ./install.sh ./sistema-server
```

Скрипт:
- проверяет, что порт из `SISTEMA_ADDR` свободен; если занят чужим процессом — останавливается;
- создаёт пользователя `sistema` и папки `/opt/sistema/{bin,data,backups}`;
- кладёт бинарник и `restore.sh` в `/opt/sistema/bin/`;
- создаёт `/opt/sistema/.env` из шаблона **только если его ещё нет**;
- ставит юнит, `enable --now`, при обновлении — перезапуск; проверяет `/healthz`;
- проверяет порт 443: **только печатает**, кто его занял. Если занят — написать разработчику (см. `https.md`).

## 4. Настройки

```bash
sudo nano /opt/sistema/.env
sudo systemctl restart sistema
```

Главное: `SISTEMA_TRUST_PROXY=1`, если сервис за Caddy/nginx (по умолчанию так). Без прокси — `0`.
Бэкапы на другой диск: `SISTEMA_BACKUP_DIR=/mnt/disk/sistema-backups` **и** тот же путь добавить в
`ReadWritePaths` в `sistema.service`, затем `sudo ./install.sh` ещё раз.

## 5. Проверка

```bash
curl 127.0.0.1:8087/healthz
# {"status":"ok","version":"0.5.0","uptime_s":12,"mem_alloc_mb":0.5}
systemctl status sistema
journalctl -u sistema -f            # логи, строки "msg":"memory" — потребление памяти
journalctl -u sistema --since today -p warning
```

## 6. HTTPS

См. [`https.md`](https.md). Сначала `sudo ss -ltnp 'sport = :443'`:
свободен — Caddy; занят — ничего не трогать, написать разработчику.

## 7. Бэкапы и восстановление

Бэкап делает сам сервер раз в сутки: БД (SQLite online backup) в `backups/<дата>/sistema.db`,
фото — зеркало `backups/photos`. Старше `SISTEMA_BACKUP_KEEP_DAYS` (14) дней удаляются.

```bash
ls /opt/sistema/backups/                       # какие даты есть
sudo apt install -y sqlite3                    # (желательно) для проверки целостности
sqlite3 -readonly /opt/sistema/backups/2026-10-21/sistema.db 'PRAGMA integrity_check'   # ok

sudo /opt/sistema/bin/restore.sh               # список дат
sudo /opt/sistema/bin/restore.sh 2026-10-21    # восстановить БД + фото
sudo /opt/sistema/bin/restore.sh 2026-10-21 --no-photos
```

`restore.sh` останавливает сервис, сохраняет текущую БД в `sistema.db.<время>.bak`, копирует бэкап,
возвращает фото, проверяет `integrity_check` (если есть `sqlite3`) и запускает сервис.
Изменения после даты бэкапа, которые остались на телефоне, приложение отправит при следующей синхронизации.

Копия бэкапов вне сервера (рекомендуется, с компьютера):
`scp -r user@SERVER:/opt/sistema/backups ./sistema-backups` (нужны права: `sudo` или группа `sistema`).

## 8. Обновление

1. Новый бинарник (п.1) → `scp deploy/sistema-server user@SERVER:~/sistema-deploy/` (и другие изменённые файлы `deploy/`).
2. `sudo ./install.sh ./sistema-server` — заменит бинарник/юнит и перезапустит; `.env` не трогает.
3. Новые переменные из `.env.example` дописать в `/opt/sistema/.env` вручную (`diff .env.example /opt/sistema/.env`).
4. `curl 127.0.0.1:8087/healthz` — версия должна смениться. Миграции БД сервер применяет сам при старте;
   перед обновлением можно сделать ручную копию: `sudo cp -a /opt/sistema/data/sistema.db ~/sistema.db.before-update`.

## Удаление

```bash
sudo systemctl disable --now sistema
sudo rm /etc/systemd/system/sistema.service && sudo systemctl daemon-reload
# данные: /opt/sistema/data и /opt/sistema/backups — удалять вручную, только осознанно
```
