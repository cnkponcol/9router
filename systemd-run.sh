#!/usr/bin/env bash
set -euo pipefail
BASE=/home/openclaw/apps/9router
cd "$BASE"
mkdir -p data logs run
for _ in $(seq 1 60); do
  TS_IP="$(tailscale ip -4 2>/dev/null | head -1 || true)"
  [ -n "$TS_IP" ] && break
  sleep 2
done
[ -n "${TS_IP:-}" ] || { echo "Tailscale IPv4 unavailable after 120s" >&2; exit 1; }
printf '%s\n' "$TS_IP" > run/host
printf '%s\n' "$$" > run/9router.pid
export DATA_DIR="$BASE/data"
export NODE_ENV=production
exec "$BASE/node_modules/.bin/9router" --host "$TS_IP" --port 20128 --no-browser --skip-update
