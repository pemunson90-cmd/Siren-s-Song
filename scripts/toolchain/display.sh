#!/usr/bin/env bash
# Use the preinstalled dummy Xorg config; no Xvfb or physical GPU required.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
export DISPLAY="${DISPLAY:-:99}"
if DISPLAY="$DISPLAY" xrandr --current >/dev/null 2>&1; then
    echo "$DISPLAY"
    exit 0
fi
Xorg "$DISPLAY" -config /etc/X11/xorg.conf -noreset -nolisten tcp \
    -logfile "$TOOLCHAIN_CACHE/xorg.log" >"$TOOLCHAIN_CACHE/xorg-start.log" 2>&1 &
xorg_pid=$!
for ((attempt=0; attempt<50; attempt++)); do
    if DISPLAY="$DISPLAY" xrandr --current >/dev/null 2>&1; then
        echo "$DISPLAY"
        exit 0
    fi
    if ! kill -0 "$xorg_pid" 2>/dev/null; then
        cat "$TOOLCHAIN_CACHE/xorg-start.log" >&2
        exit 1
    fi
    sleep 0.1
done
echo "Xorg did not become ready; inspect $TOOLCHAIN_CACHE/xorg.log" >&2
exit 1
