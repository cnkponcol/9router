#!/usr/bin/env bash
set -euo pipefail
PIDFILE=/home/openclaw/dev/9router/run/compat-shim.pid
if [ ! -f "$PIDFILE" ]; then
  echo "Compat shim not running"
  exit 0
fi
PID="$(cat "$PIDFILE")"
if kill -0 "$PID" 2>/dev/null; then
  kill "$PID"
  for _ in $(seq 1 20); do
    kill -0 "$PID" 2>/dev/null || break
    sleep 0.25
  done
fi
rm -f "$PIDFILE"
echo "Stopped compat shim"
