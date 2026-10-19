#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Siren-s-Song-listening-well
TASK_ROOT="$PWD/work/listening-well-render-fix"
TAKE=${1:?red-or-green}
EVIDENCE="$PWD/docs/validation/production/listening-well-signature-experiment/camera-key-guard/$TAKE"
mkdir -p "$EVIDENCE" "$TASK_ROOT/userdata"
test ! -e /tmp/.X242-lock
Xorg :242 -config /etc/X11/xorg.conf -noreset -nolisten tcp -logfile "$TASK_ROOT/xorg-242-$TAKE.log" > "$TASK_ROOT/xorg-242-$TAKE-start.log" 2>&1 &
DISPLAY_PID=$!
trap 'kill "$DISPLAY_PID" 2>/dev/null || true' EXIT
for i in $(seq 1 40); do
 if DISPLAY=:242 xrandr > "$TASK_ROOT/xrandr-242-$TAKE.log" 2>&1; then break; fi
 sleep .2
done
DISPLAY=:242 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME="$TASK_ROOT/userdata" godot --path "$PWD/game" --resolution 1280x720 --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 15 --script res://tests/well_camera_feed_render_tests.gd -- --folder="$EVIDENCE" > "$EVIDENCE/render.log" 2>&1
