#!/usr/bin/env bash

set -euo pipefail

if command -v polybar-msg >/dev/null 2>&1; then
  polybar-msg cmd quit >/dev/null 2>&1 || true
fi

while pgrep -x polybar >/dev/null 2>&1; do
  pkill -x polybar || true
  sleep 1
done

polybar top >/dev/null 2>&1 &