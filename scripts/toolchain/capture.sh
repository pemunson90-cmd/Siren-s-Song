#!/usr/bin/env bash
# Godot Movie Maker writes deterministic rendered frames, unlike headless mode.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
export DISPLAY="$("$(dirname -- "$0")/display.sh")"
export LIBGL_ALWAYS_SOFTWARE=1
capture_dir="${CAPTURE_DIR:-$ARTIFACT_DIR/capture-$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$capture_dir"
"$GODOT_BIN" --path "$GAME_DIR" --rendering-method gl_compatibility \
    --rendering-driver opengl3 --audio-driver Dummy \
    --resolution "${CAPTURE_RESOLUTION:-1280x720}" --fixed-fps "${CAPTURE_FPS:-30}" \
    --write-movie "$capture_dir/frame.png" --quit-after "${CAPTURE_FRAMES:-90}" "$@" \
    2>&1 | tee "$capture_dir/godot.log"
find "$capture_dir" -maxdepth 1 -type f -name '*.png' -print -quit | rg -q . || {
    echo "No PNG frames written to $capture_dir" >&2; exit 1;
}
echo "Capture: $capture_dir"
