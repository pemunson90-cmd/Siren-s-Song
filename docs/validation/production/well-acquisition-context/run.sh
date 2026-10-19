#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Siren-s-Song-well-context
TASK_ROOT="$PWD/work/well-context"
TAKE=${1:?baseline-or-challenger}
EVIDENCE="$PWD/docs/validation/production/well-acquisition-context/$TAKE"
mkdir -p "$EVIDENCE" "$TASK_ROOT/$TAKE-userdata"
test ! -e /tmp/.X243-lock
Xorg :243 -config /etc/X11/xorg.conf -noreset -nolisten tcp -logfile "$TASK_ROOT/xorg-$TAKE.log" > "$TASK_ROOT/xorg-$TAKE-start.log" 2>&1 &
DISPLAY_PID=$!
trap 'kill "$DISPLAY_PID" 2>/dev/null || true' EXIT
for i in $(seq 1 40); do
 if DISPLAY=:243 xrandr > "$TASK_ROOT/xrandr-$TAKE.log" 2>&1; then break; fi
 sleep .2
done
set +e
DISPLAY=:243 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME="$TASK_ROOT/$TAKE-userdata" godot --path game --resolution 1280x720 --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 15 --script res://tests/well_camera_feed_render_tests.gd -- > "$EVIDENCE/render-tests.log" 2>&1
RESULT=$?
set -e
echo "$RESULT" > "$EVIDENCE/render-tests.exit"
DISPLAY=:243 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME="$TASK_ROOT/$TAKE-userdata" godot --path game --resolution 1280x720 --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 15 --script "$TASK_ROOT/capture.gd" -- "$EVIDENCE" > "$EVIDENCE/capture.log" 2>&1
exit "$RESULT"
