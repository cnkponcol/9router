#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [ -f run/9router.pid ] && kill -0 "$(cat run/9router.pid)" 2>/dev/null; then
  pid="$(cat run/9router.pid)"
  ps -p "$pid" -o pid,etime,rss,%mem,%cpu,cmd
  ss -lntp 2>/dev/null | grep ':20128' || true
  echo "Private URL: http://$(cat run/host):20128"
else
  echo "9Router stopped"
  exit 1
fi
