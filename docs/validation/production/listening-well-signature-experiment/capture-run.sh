#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Siren-s-Song-gauntlet
TASK_ROOT="$PWD/work/listening-well-signature-experiment"
EVIDENCE="$PWD/docs/validation/production/listening-well-signature-experiment"
test ! -e /tmp/.X240-lock
Xorg :240 -config /etc/X11/xorg.conf -noreset -nolisten tcp -logfile "$TASK_ROOT/xorg-240.log" > "$TASK_ROOT/xorg-240-start.log" 2>&1 &
DISPLAY_PID=$!
trap 'kill "$DISPLAY_PID" 2>/dev/null || true' EXIT
for i in $(seq 1 40); do
 if DISPLAY=:240 xrandr > "$TASK_ROOT/xrandr-240.log" 2>&1; then break; fi
 sleep .2
done
for TAKE in baseline/moving optional/moving optional/idle baseline/remote optional/remote optional/solo; do
 VARIANT=${TAKE%/*}
 MODE=${TAKE#*/}
 CAPTURE_DIR="$EVIDENCE/media/$TAKE"
 mkdir -p "$CAPTURE_DIR"
 DISPLAY=:240 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME="$TASK_ROOT/$VARIANT-userdata" godot --path "$TASK_ROOT/$VARIANT/game" --resolution 2520x1080 --rendering-method gl_compatibility --fixed-fps 15 --script res://tests/well_signature_capture.gd -- --folder="$CAPTURE_DIR" --mode="$MODE" > "$CAPTURE_DIR/capture.log" 2>&1
 if [[ $MODE == moving || $MODE == idle ]]; then
  ffmpeg -v error -framerate 15 -i "$CAPTURE_DIR/%04d.png" -c:v libx264 -crf 21 -pix_fmt yuv420p -y "$CAPTURE_DIR/sequence.mp4"
  ffmpeg -v error -i "$CAPTURE_DIR/sequence.mp4" -vf 'fps=1,scale=420:180,tile=4x4' -frames:v 1 -y "$CAPTURE_DIR/decoded-1fps.jpg"
  ffprobe -v error -count_frames -show_entries format=duration,size:stream=width,height,r_frame_rate,nb_read_frames -of json "$CAPTURE_DIR/sequence.mp4" > "$CAPTURE_DIR/media-probe.json"
 fi
 echo "FINISHED $TAKE"
done
