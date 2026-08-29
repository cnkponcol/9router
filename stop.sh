#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [ ! -f run/9router.pid ]; then echo "9Router not running"; exit 0; fi
pid="$(cat run/9router.pid)"
if kill -0 "$pid" 2>/dev/null; then kill "$pid"; fi
rm -f run/9router.pid
echo "Stopped 9Router"
