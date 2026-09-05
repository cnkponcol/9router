#!/usr/bin/env bash
set -euo pipefail
BASE=/home/openclaw/apps/9router
mkdir -p "$BASE/run" "$BASE/logs"
for _ in $(seq 1 60); do
  TS_IP="$(tailscale ip -4 2>/dev/null | head -1 || true)"
  [ -n "$TS_IP" ] && break
  sleep 2
done
[ -n "${TS_IP:-}" ] || { echo "Tailscale IPv4 unavailable after 120s" >&2; exit 1; }
printf '%s\n' "$$" > "$BASE/run/compat-shim.pid"
export UP_HOST="$TS_IP"
export UP_PORT=20128
export LISTEN_HOST=127.0.0.1
export LISTEN_PORT=20130
exec python3 "$BASE/compat/compat_shim.py"
