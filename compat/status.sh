#!/usr/bin/env bash
set -u
PIDFILE=/home/openclaw/dev/9router/run/compat-shim.pid
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  ps -p "$(cat "$PIDFILE")" -o pid,etime,rss,%mem,%cpu,cmd
else
  echo "Compat shim not running"
fi
ss -lntp 2>/dev/null | grep '127.0.0.1:20130' || true
