#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
target="${1:-android}"
case "$target" in
    android) preset=Android; output="$ARTIFACT_DIR/sirens-song-debug.apk" ;;
    linux) preset=Linux; output="$ARTIFACT_DIR/sirens-song.x86_64" ;;
    *) echo "Usage: $0 [android|linux]" >&2; exit 2 ;;
esac
"$(dirname -- "$0")/configure.sh"
"$GODOT_BIN" --headless --path "$GAME_DIR" --editor --import
"$GODOT_BIN" --headless --path "$GAME_DIR" --export-debug "$preset" "$output"
test -s "$output"
if [[ "$target" == android ]]; then
    apksigner="$(find "$ANDROID_HOME/build-tools" -mindepth 2 -maxdepth 2 -name apksigner | sort -V | tail -1)"
    test -n "$apksigner"
    "$apksigner" verify --verbose --print-certs "$output"
fi
sha256sum "$output"
