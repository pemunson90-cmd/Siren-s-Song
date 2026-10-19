#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Siren-s-Song-gauntlet
TASK_ROOT="$PWD/work/listening-well-signature-experiment"
EVIDENCE="$PWD/docs/validation/production/listening-well-signature-experiment/media/baseline/pages"
mkdir -p "$EVIDENCE"
test ! -e /tmp/.X241-lock
Xorg :241 -config /etc/X11/xorg.conf -noreset -nolisten tcp -logfile "$TASK_ROOT/xorg-241.log" > "$TASK_ROOT/xorg-241-start.log" 2>&1 &
DISPLAY_PID=$!
trap 'kill "$DISPLAY_PID" 2>/dev/null || true' EXIT
for i in $(seq 1 40); do
 if DISPLAY=:241 xrandr > "$TASK_ROOT/xrandr-241.log" 2>&1; then break; fi
 sleep .2
done
DISPLAY=:241 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME="$TASK_ROOT/baseline-pages-userdata" godot --path "$TASK_ROOT/baseline/game" --resolution 2520x1080 --rendering-method gl_compatibility --fixed-fps 15 --script res://tests/well_signature_pages.gd -- "$EVIDENCE" > "$EVIDENCE/capture.log" 2>&1
