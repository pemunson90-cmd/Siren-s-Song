#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Siren-s-Song-archive-recap
TAKE=${1:?baseline-or-challenger}
TASK_ROOT="$PWD/work/archive-recap"
EVIDENCE="$PWD/docs/validation/production/campaign-evidence-recap/$TAKE"
mkdir -p "$EVIDENCE" "$TASK_ROOT/$TAKE-userdata"
test ! -e /tmp/.X244-lock
Xorg :244 -config /etc/X11/xorg.conf -noreset -nolisten tcp -logfile "$TASK_ROOT/xorg-$TAKE.log" > "$TASK_ROOT/xorg-$TAKE-start.log" 2>&1 &
DISPLAY_PID=$!
trap 'kill "$DISPLAY_PID" 2>/dev/null || true' EXIT
for i in $(seq 1 40); do
 if DISPLAY=:244 xrandr > "$TASK_ROOT/xrandr-$TAKE.log" 2>&1; then break; fi
 sleep .2
done
DISPLAY=:244 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME="$TASK_ROOT/$TAKE-userdata" godot --path game --resolution 2520x1080 --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 15 --script "$TASK_ROOT/capture.gd" -- "$EVIDENCE" > "$EVIDENCE/capture.log" 2>&1
