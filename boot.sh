#!/usr/bin/env bash
set -u
cd /home/openclaw/dev/9router
for _ in $(seq 1 60); do
  if tailscale ip -4 2>/dev/null | grep -q .; then
    ./start.sh || exit 1
    for _ in $(seq 1 30); do
      ss -lnt 2>/dev/null | grep -q ':20128 ' && break
      sleep 1
    done
    ./compat/start.sh || exit 1
    exit 0
  fi
  sleep 2
done
echo "Tailscale not ready after 120s" >> logs/9router.log
exit 1
