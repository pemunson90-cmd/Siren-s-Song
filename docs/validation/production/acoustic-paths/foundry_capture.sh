#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Siren-s-Song-acoustic-paths
TASK_ROOT="$PWD/work/acoustic-paths"
test ! -e /tmp/.X246-lock
Xorg :246 -config /etc/X11/xorg.conf -noreset -nolisten tcp -logfile "$TASK_ROOT/xorg-foundry.log" > "$TASK_ROOT/xorg-foundry-start.log" 2>&1 &
DISPLAY_PID=$!
trap 'kill "$DISPLAY_PID" 2>/dev/null || true' EXIT
for i in $(seq 1 40);do if DISPLAY=:246 xrandr > "$TASK_ROOT/xrandr-foundry.log" 2>&1;then break;fi;sleep .2;done
for VARIANT in baseline challenger;do
 GAME_PATH="$PWD/game"
 if [[ "$VARIANT" == baseline ]];then GAME_PATH="$TASK_ROOT/baseline/game";fi
 FRAMES="$TASK_ROOT/foundry-frames-$VARIANT"
 EVIDENCE="$PWD/docs/validation/production/acoustic-paths/foundry-$VARIANT"
 mkdir -p "$FRAMES" "$EVIDENCE" "$TASK_ROOT/foundry-userdata-$VARIANT"
 DISPLAY=:246 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME="$TASK_ROOT/foundry-userdata-$VARIANT" godot --path "$GAME_PATH" --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 15 --resolution 1280x720 --script "$TASK_ROOT/foundry_capture.gd" -- "$FRAMES" > "$EVIDENCE/capture.log" 2>&1
 ffmpeg -y -hide_banner -loglevel error -framerate 15 -i "$FRAMES/%04d.png" -c:v libx264 -crf 23 -pix_fmt yuv420p "$EVIDENCE/ordinary-replay.mp4"
 cp "$FRAMES"/*.json "$EVIDENCE/"
 ffmpeg -y -hide_banner -loglevel error -i "$EVIDENCE/ordinary-replay.mp4" -vf 'fps=1,scale=320:-1,tile=4x3' -frames:v 1 "$EVIDENCE/contact.png"
 printf '%s\n' "$VARIANT foundry captured"
done
