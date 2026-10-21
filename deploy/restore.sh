#!/usr/bin/env bash
# Восстановление сервера «Система» из бэкапа.
#
# Использование:
#   sudo ./restore.sh                 # показать доступные даты
#   sudo ./restore.sh 2026-10-21      # восстановить БД за дату + фото из зеркала
#   sudo ./restore.sh 2026-10-21 --no-photos
#
# Что делает: останавливает sistema, сохраняет текущую БД в sistema.db.<время>.bak,
# копирует <backups>/<дата>/sistema.db, возвращает фото из <backups>/photos (зеркало <data>/photos),
# проверяет БД (sqlite3 PRAGMA integrity_check, если sqlite3 установлен), запускает сервис.
# Пути берёт из /opt/sistema/.env (SISTEMA_DATA_DIR, SISTEMA_BACKUP_DIR).
set -euo pipefail

APP=sistema
APP_USER=sistema
ENV_FILE=/opt/sistema/.env
DB_NAME=sistema.db

log() { printf '[restore] %s\n' "$*"; }
die() { printf '[restore] ОШИБКА: %s\n' "$*" >&2; exit 1; }

env_get() { # env_get KEY DEFAULT
  local v=""
  [[ -f "$ENV_FILE" ]] && v="$(grep -E "^$1=" "$ENV_FILE" | tail -n1 | cut -d= -f2- | tr -d '"'"'"' ' || true)"
  printf '%s' "${v:-$2}"
}

[[ $EUID -eq 0 ]] || die "запустите через sudo"
DATA_DIR="$(env_get SISTEMA_DATA_DIR /opt/sistema/data)"
BACKUP_DIR="$(env_get SISTEMA_BACKUP_DIR "$(dirname "$DATA_DIR")/backups")"
[[ -d "$BACKUP_DIR" ]] || die "нет каталога бэкапов: $BACKUP_DIR"

list_dates() {
  find "$BACKUP_DIR" -mindepth 2 -maxdepth 2 -name "$DB_NAME" -printf '%h\n' 2>/dev/null \
    | xargs -r -n1 basename | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort || true
}

DATE="${1:-}"
WITH_PHOTOS=1
[[ "${2:-}" == "--no-photos" ]] && WITH_PHOTOS=0

if [[ -z "$DATE" ]]; then
  log "доступные бэкапы в $BACKUP_DIR:"
  dates="$(list_dates)"
  [[ -n "$dates" ]] || die "бэкапов не найдено"
  printf '  %s\n' $dates
  log "запустите: sudo $0 <дата>   (например: sudo $0 $(tail -n1 <<<"$dates"))"
  exit 0
fi

[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "дата в формате yyyy-mm-dd, получено: $DATE"
SRC_DB="$BACKUP_DIR/$DATE/$DB_NAME"
[[ -f "$SRC_DB" ]] || die "нет файла $SRC_DB (список: sudo $0)"

HAVE_SQLITE=0
command -v sqlite3 >/dev/null && HAVE_SQLITE=1

check_db() { # check_db FILE
  (( HAVE_SQLITE )) || return 0
  local r
  r="$(sqlite3 -readonly "$1" 'PRAGMA integrity_check;' 2>&1 || true)"
  [[ "$r" == "ok" ]] || { printf '%s\n' "$r" >&2; return 1; }
}

if (( HAVE_SQLITE )); then
  log "проверяю бэкап $SRC_DB"
  check_db "$SRC_DB" || die "бэкап повреждён (integrity_check), ничего не менял"
else
  log "sqlite3 не установлен — проверка целостности пропущена (apt install sqlite3)"
fi

read -r -p "[restore] Восстановить БД за $DATE$( ((WITH_PHOTOS)) && echo ' и фото'). Сервис будет остановлен. Продолжить? [y/N] " ans
[[ "$ans" == "y" || "$ans" == "Y" ]] || die "отменено"

log "останавливаю $APP"
systemctl stop "$APP"

started=0
on_exit() {
  if (( ! started )); then
    log "запускаю $APP после ошибки (проверьте journalctl -u $APP)"
    systemctl start "$APP" || true
  fi
}
trap on_exit EXIT

DST_DB="$DATA_DIR/$DB_NAME"
if [[ -f "$DST_DB" ]]; then
  bak="$DST_DB.$(date +%Y%m%d-%H%M%S).bak"
  log "сохраняю текущую БД в $bak"
  cp -a "$DST_DB" "$bak"
  for ext in -wal -shm; do
    if [[ -f "$DST_DB$ext" ]]; then mv -f "$DST_DB$ext" "$bak$ext"; fi
  done
fi

log "копирую $SRC_DB -> $DST_DB"
install -m 0640 -o "$APP_USER" -g "$APP_USER" "$SRC_DB" "$DST_DB.new"
mv -f "$DST_DB.new" "$DST_DB"

if (( WITH_PHOTOS )); then
  if [[ -d "$BACKUP_DIR/photos" ]]; then
    log "возвращаю фото из $BACKUP_DIR/photos -> $DATA_DIR/photos"
    install -d -m 0750 -o "$APP_USER" -g "$APP_USER" "$DATA_DIR/photos"
    if command -v rsync >/dev/null; then
      rsync -a "$BACKUP_DIR/photos/" "$DATA_DIR/photos/"
    else
      cp -a "$BACKUP_DIR/photos/." "$DATA_DIR/photos/"
    fi
    chown -R "$APP_USER:$APP_USER" "$DATA_DIR/photos"
  else
    log "зеркала фото $BACKUP_DIR/photos нет — фото пропущены"
  fi
fi

if (( HAVE_SQLITE )); then
  check_db "$DST_DB" || die "восстановленная БД не прошла integrity_check; прежняя — в ${bak:-<нет>}"
  log "integrity_check: ok"
fi

log "запускаю $APP"
systemctl start "$APP"
started=1
sleep 1
if command -v curl >/dev/null; then
  curl -fsS http://127.0.0.1:"$(env_get SISTEMA_ADDR 127.0.0.1:8087 | sed 's/.*://')"/healthz && echo || \
    log "сервис не ответил на /healthz — journalctl -u $APP -n 50"
fi
log "готово: восстановлено на $DATE"
