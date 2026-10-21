# HTTPS: DuckDNS + Let's Encrypt

Сервис слушает только `127.0.0.1:8087`. Наружу его выводит reverse-proxy с HTTPS.
В `/opt/sistema/.env` при работе за прокси: `SISTEMA_TRUST_PROXY=1`.

## 0. Сначала проверить порты 80 и 443

```bash
sudo ss -ltnp 'sport = :443'
sudo ss -ltnp 'sport = :80'
```

- Пусто → **вариант 1 (Caddy)**.
- Занято (nginx, apache, другой Caddy, docker…) → **ничего не трогать и написать разработчику (агенту)**,
  приложив вывод этих команд и `ls /etc/nginx/sites-enabled/`. Дальше — вариант 2, только после согласования.

## 1. DuckDNS (домен и IP)

1. Войти на https://www.duckdns.org, создать поддомен, например `my-sistema` → `my-sistema.duckdns.org`.
   Скопировать token (на странице вверху). Token — секрет, в репозиторий не класть.
2. Обновление IP cron'ом (если IP сервера статический — достаточно один раз указать его на сайте):

```bash
sudo install -d -m 0700 /opt/duckdns
sudo tee /opt/duckdns/update.sh >/dev/null <<'EOF'
#!/bin/sh
curl -fsS -o /opt/duckdns/last.log "https://www.duckdns.org/update?domains=my-sistema&token=ВАШ_TOKEN&ip="
EOF
sudo chmod 0700 /opt/duckdns/update.sh
( sudo crontab -l 2>/dev/null; echo '*/5 * * * * /opt/duckdns/update.sh' ) | sudo crontab -
sudo /opt/duckdns/update.sh; cat /opt/duckdns/last.log   # должно быть OK
```

3. Проверка: `dig +short my-sistema.duckdns.org` показывает IP сервера.
4. В файрволе/у хостера открыть входящие 80 и 443 (80 нужен Let's Encrypt для выпуска сертификата).

## Вариант 1. Caddy (порт 443 свободен)

Caddy сам получает и продлевает сертификат Let's Encrypt.

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install -y caddy
```

`/etc/caddy/Caddyfile` (если файл уже содержит чужие сайты — **не заменять**, а дописать блок в конец):

```
my-sistema.duckdns.org {
	encode gzip
	request_body {
		max_size 25MB
	}
	reverse_proxy 127.0.0.1:8087
}
```

```bash
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy
curl https://my-sistema.duckdns.org/healthz
```

Caddy передаёт `X-Forwarded-For` сам. Логи: `journalctl -u caddy -f`.

## Вариант 2. На 443 уже работает nginx

**Только после согласования с разработчиком.** Существующие сайты и конфиги не меняем —
добавляем отдельный файл со своим `server_name`; nginx разводит сайты по имени (SNI).

1. Сертификат через certbot в режиме webroot (не трогает чужие server-блоки):

```bash
sudo apt install -y certbot
sudo install -d /var/www/sistema-acme
```

2. `/etc/nginx/sites-available/sistema.conf`:

```nginx
server {
    listen 80;
    server_name my-sistema.duckdns.org;
    location /.well-known/acme-challenge/ { root /var/www/sistema-acme; }
    location / { return 301 https://$host$request_uri; }
}

# Раскомментировать ПОСЛЕ получения сертификата (шаг 3):
#server {
#    listen 443 ssl;
#    http2 on;                      # для nginx < 1.25: "listen 443 ssl http2;" и убрать эту строку
#    server_name my-sistema.duckdns.org;
#    ssl_certificate     /etc/letsencrypt/live/my-sistema.duckdns.org/fullchain.pem;
#    ssl_certificate_key /etc/letsencrypt/live/my-sistema.duckdns.org/privkey.pem;
#    client_max_body_size 25m;
#    location / {
#        proxy_pass http://127.0.0.1:8087;
#        proxy_set_header Host $host;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_set_header X-Forwarded-Proto $scheme;
#        proxy_read_timeout 60s;
#    }
#}
```

3. Включить, проверить, получить сертификат, включить 443:

```bash
sudo ln -s /etc/nginx/sites-available/sistema.conf /etc/nginx/sites-enabled/sistema.conf
sudo nginx -t && sudo systemctl reload nginx
sudo certbot certonly --webroot -w /var/www/sistema-acme -d my-sistema.duckdns.org
# раскомментировать блок 443 в sistema.conf
sudo nginx -t && sudo systemctl reload nginx
curl https://my-sistema.duckdns.org/healthz
```

Если `nginx -t` ругается — **не перезагружать nginx**, удалить ссылку
`/etc/nginx/sites-enabled/sistema.conf` и написать разработчику.

Продление: certbot ставит свой таймер (`systemctl list-timers | grep certbot`). Чтобы nginx подхватывал
новый сертификат: `echo 'systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh && sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh`.

## В приложении

Адрес сервера: `https://my-sistema.duckdns.org` (экран «Аккаунт»).
