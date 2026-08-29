#!/usr/bin/env bash
set -euo pipefail
BASE=/home/openclaw/dev/9router
PIDFILE="$BASE/run/compat-shim.pid"
LOGFILE="$BASE/logs/compat-shim.log"
mkdir -p "$BASE/run" "$BASE/logs"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Compat shim already running: PID $(cat "$PIDFILE")"
  exit 0
fi
TS_IP="$(tailscale ip -4 | head -1)"
[ -n "$TS_IP" ] || { echo "Tailscale IPv4 unavailable" >&2; exit 1; }
nohup env UP_HOST="$TS_IP" UP_PORT=20128 LISTEN_HOST=127.0.0.1 LISTEN_PORT=20130 \
  python3 "$BASE/compat/compat_shim.py" >> "$LOGFILE" 2>&1 &
echo $! > "$PIDFILE"
echo "Started compat shim PID $(cat "$PIDFILE") on 127.0.0.1:20130 -> $TS_IP:20128"
