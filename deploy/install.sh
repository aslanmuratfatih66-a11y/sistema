#!/usr/bin/env bash
# Установка/обновление сервера «Система» на Debian.
# Идемпотентен: можно запускать повторно (обновление бинарника и юнита).
# Трогает ТОЛЬКО своё: пользователь sistema, /opt/sistema, /etc/systemd/system/sistema.service.
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
ENV_FILE="$PREFIX/.env"
BIN="$BIN_DIR/sistema-server"
UNIT_DST="/etc/systemd/system/$APP.service"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_BIN="${1:-$SCRIPT_DIR/sistema-server}"
SRC_UNIT="$SCRIPT_DIR/sistema.service"
SRC_ENV="$SCRIPT_DIR/.env.example"

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
install -d -m 0750 -o "$APP_USER" -g "$APP_USER" "$DATA_DIR"

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

# --- Проверка -----------------------------------------------------------------
host="${ADDR%:*}"
[[ -z "$host" || "$host" == "0.0.0.0" ]] && host=127.0.0.1
for _ in $(seq 1 20); do
  if command -v curl >/dev/null && curl -fsS "http://$host:$PORT/healthz" 2>/dev/null; then
    echo
    log "готово: сервис работает на $ADDR"
    exit 0
  fi
  sleep 0.5
done
systemctl --no-pager status "$APP" || true
die "сервис не ответил на /healthz (смотрите: journalctl -u $APP -n 50)"
