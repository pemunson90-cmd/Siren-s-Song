#!/usr/bin/env bash
# Godot Movie Maker writes deterministic rendered frames, unlike headless mode.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
export DISPLAY="$("$(dirname -- "$0")/display.sh")"
export LIBGL_ALWAYS_SOFTWARE=1
capture_dir="${CAPTURE_DIR:-$ARTIFACT_DIR/capture-$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$capture_dir"
capture_dir="$(cd -- "$capture_dir" && pwd)"
capture_frames="${CAPTURE_FRAMES:-90}"
[[ "$capture_frames" =~ ^[1-9][0-9]*$ ]] || { echo 'CAPTURE_FRAMES must be a positive integer' >&2; exit 2; }
# The game's full-viewport capture is taken after layout settles on frame4.
if (( capture_frames < 6 )); then capture_frames=6; fi
capture_args=("$@")
screenshot_path="$capture_dir/full.png"
has_separator=false
has_capture=false
for arg in "$@"; do
    if [[ "$arg" == -- ]]; then has_separator=true; fi
    if [[ "$arg" == --capture-path=* ]]; then
        screenshot_path="${arg#--capture-path=}"
        has_capture=true
    fi
done
if ! "$has_capture"; then
    if ! "$has_separator"; then capture_args+=(--); fi
    capture_args+=("--capture-path=$screenshot_path")
fi
"$GODOT_BIN" --path "$GAME_DIR" --rendering-method gl_compatibility \
    --rendering-driver opengl3 --audio-driver Dummy \
    --resolution "${CAPTURE_RESOLUTION:-1280x720}" --fixed-fps "${CAPTURE_FPS:-30}" \
    --write-movie "$capture_dir/frame.png" --quit-after "$capture_frames" "${capture_args[@]}" \
    2>&1 | tee "$capture_dir/godot.log"
find "$capture_dir" -maxdepth 1 -type f -name '*.png' -print -quit | grep -q . || {
    echo "No PNG frames written to $capture_dir" >&2; exit 1;
}
echo "Capture: $capture_dir"
test -s "$screenshot_path" || { echo "Missing full viewport screenshot: $screenshot_path" >&2; exit 1; }
echo "Full viewport: $screenshot_path"
