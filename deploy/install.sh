#!/usr/bin/env bash
# Установка/обновление сервера «Система» на Debian.
# Идемпотентен: можно запускать повторно (обновление бинарника и юнита).
# Трогает ТОЛЬКО своё: пользователь sistema, /opt/sistema, /etc/systemd/system/sistema.service.
# Порт 443 и чужие веб-серверы НЕ трогает — только печатает, кто его занял (см. https.md).
# Перед установкой печатает память и занятые порты; если доступно < 300 МБ и swap нет — предлагает
# swap-файл 2 ГБ (только с подтверждением: вопрос в терминале или SISTEMA_SWAP=y).
#
# Использование:
#   sudo ./install.sh [путь/к/sistema-server]
# По умолчанию бинарник ищется рядом со скриптом: ./sistema-server
set -euo pipefail

APP=sistema
APP_USER=sistema
PREFIX=/opt/sistema
BIN_DIR="$PREFIX/bin"
DATA_DIR="$PREFIX/data"
BACKUP_DIR_DEFAULT="$PREFIX/backups"
ENV_FILE="$PREFIX/.env"
BIN="$BIN_DIR/sistema-server"
UNIT_DST="/etc/systemd/system/$APP.service"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_BIN="${1:-$SCRIPT_DIR/sistema-server}"
SRC_UNIT="$SCRIPT_DIR/sistema.service"
SRC_ENV="$SCRIPT_DIR/.env.example"
SRC_RESTORE="$SCRIPT_DIR/restore.sh"

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ОШИБКА: %s\n' "$*" >&2; exit 1; }

# --- Проверки ---------------------------------------------------------------
[[ $EUID -eq 0 ]] || die "запустите через sudo"
command -v systemctl >/dev/null || die "нужен systemd"
command -v ss >/dev/null || die "нужна утилита ss (пакет iproute2)"
[[ -f "$SRC_BIN" ]] || die "не найден бинарник: $SRC_BIN"
[[ -f "$SRC_UNIT" ]] || die "не найден юнит: $SRC_UNIT"
[[ -f "$SRC_ENV" ]] || die "не найден .env.example: $SRC_ENV"

# Адрес берём из существующего .env (если есть), иначе из .env.example.
env_src="$SRC_ENV"
[[ -f "$ENV_FILE" ]] && env_src="$ENV_FILE"
ADDR="$(grep -E '^SISTEMA_ADDR=' "$env_src" | tail -n1 | cut -d= -f2- | tr -d '"'"'"' ' || true)"
ADDR="${ADDR:-127.0.0.1:8087}"
PORT="${ADDR##*:}"
[[ "$PORT" =~ ^[0-9]+$ ]] || die "не удалось определить порт из SISTEMA_ADDR=$ADDR"
BACKUP_DIR="$(grep -E '^SISTEMA_BACKUP_DIR=' "$env_src" | tail -n1 | cut -d= -f2- | tr -d '"'"'"' ' || true)"
BACKUP_DIR="${BACKUP_DIR:-$BACKUP_DIR_DEFAULT}"
[[ "$BACKUP_DIR" == /* ]] || die "SISTEMA_BACKUP_DIR должен быть абсолютным путём: $BACKUP_DIR"

# Порт должен быть свободен — либо занят нашим же сервисом (повторный запуск).
if ss -Hltn "sport = :$PORT" | grep -q .; then
  our_pid="$(systemctl show -p MainPID --value "$APP" 2>/dev/null || echo 0)"
  if [[ "${our_pid:-0}" != "0" ]] && ss -Hltnp "sport = :$PORT" | grep -q "pid=$our_pid,"; then
    log "порт $PORT занят нашим сервисом $APP — это обновление"
  else
    ss -Hltnp "sport = :$PORT" >&2 || true
    die "порт $PORT занят другим процессом. Чужое не трогаем: выберите другой порт в SISTEMA_ADDR ($env_src) и запустите снова"
  fi
fi

# --- Память и порты: отчёт, при нехватке — swap по согласию (SPEC §10) ---------
log "память:"
free -h | sed 's/^/[install]   /'
log "занятые TCP-порты (слушают):"
ss -Hltn | awk '{print $4}' | sort -u | tr '
' ' ' | sed 's/^/[install]   /'; echo
avail_mb="$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)"
swap_mb="$(awk '/SwapTotal/ {print int($2/1024)}' /proc/meminfo)"
if (( avail_mb < 300 )) && (( swap_mb == 0 )); then
  log "доступно ${avail_mb} МБ памяти и swap нет — при обработке фото сервису может не хватить памяти"
  answer="${SISTEMA_SWAP:-}"
  if [[ -z "$answer" && -t 0 ]]; then
    read -r -p "[install] Создать swap-файл 2 ГБ (/swapfile)? [y/N] " answer
  fi
  if [[ "$answer" =~ ^[YyДд] ]]; then
    [[ -e /swapfile ]] && die "/swapfile уже существует — не трогаю, разберитесь вручную"
    log "создаю /swapfile 2 ГБ"
    fallocate -l 2G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
    chmod 600 /swapfile
    mkswap /swapfile >/dev/null
    swapon /swapfile
    grep -qE '^/swapfile\s' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log "swap включён"
  else
    log "swap не создаю (можно позже: SISTEMA_SWAP=y sudo ./install.sh)"
  fi
else
  log "память в порядке (доступно ${avail_mb} МБ, swap ${swap_mb} МБ)"
fi

# --- Пользователь -------------------------------------------------------------
if id -u "$APP_USER" >/dev/null 2>&1; then
  log "пользователь $APP_USER уже есть"
else
  log "создаю системного пользователя $APP_USER"
  useradd --system --user-group --home-dir "$PREFIX" --no-create-home \
    --shell /usr/sbin/nologin "$APP_USER"
fi

# --- Папки --------------------------------------------------------------------
install -d -m 0755 -o root -g root "$PREFIX" "$BIN_DIR"
install -d -m 0750 -o "$APP_USER" -g "$APP_USER" "$DATA_DIR" "$BACKUP_DIR_DEFAULT"
if [[ "$BACKUP_DIR" != "$BACKUP_DIR_DEFAULT" ]]; then
  [[ -d "$BACKUP_DIR" ]] || install -d -m 0750 -o "$APP_USER" -g "$APP_USER" "$BACKUP_DIR"
  grep -qF "$BACKUP_DIR" "$SRC_UNIT" ||     log "ВНИМАНИЕ: SISTEMA_BACKUP_DIR=$BACKUP_DIR — добавьте его в ReadWritePaths в $SRC_UNIT и запустите снова, иначе бэкапы не запишутся"
fi

# Скрипт восстановления — рядом с бинарником.
if [[ -f "$SRC_RESTORE" ]]; then
  install -m 0750 -o root -g root "$SRC_RESTORE" "$BIN_DIR/restore.sh"
fi

# --- Бинарник (атомарная замена) ----------------------------------------------
bin_changed=0
if ! cmp -s "$SRC_BIN" "$BIN" 2>/dev/null; then
  log "устанавливаю бинарник в $BIN"
  install -m 0755 -o root -g root "$SRC_BIN" "$BIN.new"
  mv -f "$BIN.new" "$BIN"
  bin_changed=1
else
  log "бинарник не изменился"
fi

# --- .env: создаём только если его нет ----------------------------------------
if [[ -f "$ENV_FILE" ]]; then
  log "$ENV_FILE уже есть — не трогаю"
else
  log "создаю $ENV_FILE из .env.example"
  install -m 0640 -o root -g "$APP_USER" "$SRC_ENV" "$ENV_FILE"
fi

# --- systemd-юнит -------------------------------------------------------------
unit_changed=0
if ! cmp -s "$SRC_UNIT" "$UNIT_DST" 2>/dev/null; then
  log "устанавливаю юнит $UNIT_DST"
  install -m 0644 -o root -g root "$SRC_UNIT" "$UNIT_DST"
  unit_changed=1
fi
was_active=0
systemctl is-active --quiet "$APP" && was_active=1
systemctl daemon-reload
systemctl enable --now "$APP.service"

if (( was_active )) && (( bin_changed || unit_changed )); then
  log "перезапускаю $APP"
  systemctl restart "$APP.service"
fi

# --- Порт 443 (только информация) ---------------------------------------------
https_note() {
  if ss -Hltn 'sport = :443' | grep -q .; then
    log "ВНИМАНИЕ: порт 443 уже занят:"
    ss -Hltnp 'sport = :443' | sed 's/^/[install]   /' || true
    log "Чужие конфиги НЕ меняем. Caddy на 443 не ставить. Напишите разработчику (агенту),"
    log "приложив вывод выше — HTTPS настроим отдельным server-блоком (deploy/https.md, вариант 2)."
  else
    log "порт 443 свободен — HTTPS через Caddy: deploy/https.md, вариант 1"
  fi
}

# --- Проверка -----------------------------------------------------------------
host="${ADDR%:*}"
[[ -z "$host" || "$host" == "0.0.0.0" ]] && host=127.0.0.1
for _ in $(seq 1 20); do
  if command -v curl >/dev/null && curl -fsS "http://$host:$PORT/healthz" 2>/dev/null; then
    echo
    log "готово: сервис работает на $ADDR"
    https_note
    exit 0
  fi
  sleep 0.5
done
systemctl --no-pager status "$APP" || true
die "сервис не ответил на /healthz (смотрите: journalctl -u $APP -n 50)"
