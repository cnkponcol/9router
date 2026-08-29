#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p data logs run
if [ -f run/9router.pid ] && kill -0 "$(cat run/9router.pid)" 2>/dev/null; then
  echo "9Router already running: PID $(cat run/9router.pid)"
  exit 0
fi
TS_IP="$(tailscale ip -4 | head -1)"
if [ -z "$TS_IP" ]; then
  echo "Tailscale IPv4 not available" >&2
  exit 1
fi
export DATA_DIR="$PWD/data"
export NODE_ENV=production
nohup ./node_modules/.bin/9router --host "$TS_IP" --port 20128 --no-browser --skip-update >> logs/9router.log 2>&1 &
echo $! > run/9router.pid
echo "$TS_IP" > run/host
printf 'Started 9Router PID %s on %s:20128\n' "$(cat run/9router.pid)" "$TS_IP"
