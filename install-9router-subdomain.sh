#!/usr/bin/env bash
set -euo pipefail

SRC=/home/openclaw/dev/9router/9router-subdomain-nginx.conf
DST=/etc/nginx/sites-available/9router-private
LINK=/etc/nginx/sites-enabled/9router-private
BACKUP_DIR=/home/openclaw/dev/9router/backups/subdomain-$(date +%Y%m%d-%H%M%S)

[ -f "$SRC" ] || { echo "Missing $SRC" >&2; exit 1; }
mkdir -p "$BACKUP_DIR"

if [ -e "$DST" ]; then
  cp -a "$DST" "$BACKUP_DIR/9router-private.previous"
fi

install -o root -g root -m 0644 "$SRC" "$DST"
ln -sfn "$DST" "$LINK"

if ! /usr/sbin/nginx -t; then
  echo "Nginx test failed; disabling new site." >&2
  rm -f "$LINK"
  if [ -f "$BACKUP_DIR/9router-private.previous" ]; then
    cp -a "$BACKUP_DIR/9router-private.previous" "$DST"
    ln -sfn "$DST" "$LINK"
  fi
  exit 1
fi

systemctl reload nginx
echo "OK: http://router.kuskuskuy.my.id -> 9Router (Tailscale clients only)"
