#!/usr/bin/env bash
set -euo pipefail
DOMAIN="router.kuskuskuy.my.id"
SITE="/etc/nginx/sites-available/9router-private"
CREDS_DIR="/root/.secrets/certbot"
CREDS="$CREDS_DIR/cloudflare.ini"

[ "${EUID:-$(id -u)}" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }
[ -f "$SITE" ] || { echo "Missing $SITE" >&2; exit 1; }

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-certbot-dns-cloudflare >/dev/null

mkdir -p "$CREDS_DIR"
chmod 700 "$CREDS_DIR"

if [ ! -s "$CREDS" ]; then
  read -rsp "Cloudflare DNS API token: " CF_TOKEN
  echo
  [ -n "$CF_TOKEN" ] || { echo "Token empty." >&2; exit 1; }
  printf 'dns_cloudflare_api_token = %s\n' "$CF_TOKEN" > "$CREDS"
  unset CF_TOKEN
  chmod 600 "$CREDS"
fi
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials "$CREDS" \
  --dns-cloudflare-propagation-seconds 30 \
  --preferred-challenges dns \
  -d "$DOMAIN" \
  --non-interactive --agree-tos --register-unsafely-without-email

CERT="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
KEY="/etc/letsencrypt/live/$DOMAIN/privkey.pem"
[ -s "$CERT" ] && [ -s "$KEY" ] || { echo "Certificate not created." >&2; exit 1; }

BACKUP="${SITE}.pre-https-$(date +%Y%m%d-%H%M%S)"
cp -a "$SITE" "$BACKUP"
TS_IP="$(tailscale ip -4 | head -1)"
[ -n "$TS_IP" ] || { echo "Tailscale IPv4 unavailable." >&2; exit 1; }

cat > "$SITE" <<EOF
server {
    listen $TS_IP:80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen $TS_IP:443 ssl;
    server_name $DOMAIN;

    allow 100.64.0.0/10;
    deny all;

    ssl_certificate $CERT;
    ssl_certificate_key $KEY;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 25M;
    location / {
        proxy_pass http://$TS_IP:20128;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_buffering off;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
    }
}
EOF

if ! nginx -t; then
  cp -a "$BACKUP" "$SITE"
  nginx -t || true
  echo "Nginx config failed; restored $BACKUP" >&2
  exit 1
fi

systemctl reload nginx

HOOK="/etc/letsencrypt/renewal-hooks/deploy/9router-nginx-reload.sh"
cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
set -e
nginx -t
systemctl reload nginx
EOF
chmod 755 "$HOOK"
echo "== HTTPS health =="
for attempt in 1 2 3 4 5; do
  if curl -fsS --connect-timeout 8 --resolve "$DOMAIN:443:$TS_IP" "https://$DOMAIN/api/health"; then
    echo
    break
  fi
  if [ "$attempt" -eq 5 ]; then
    echo "HTTPS config installed, but health verification did not become ready in time." >&2
    exit 1
  fi
  echo "HTTPS not ready yet (attempt $attempt/5), retrying..." >&2
  sleep 2
done
echo "== Certificate =="
openssl x509 -in "$CERT" -noout -subject -issuer -dates
echo "OK: https://$DOMAIN -> 9Router (Tailscale only)"
echo "Renewal: certbot renew + deploy hook reloads Nginx automatically."
