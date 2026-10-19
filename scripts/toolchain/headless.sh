#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
if [[ $# -eq 0 ]]; then
    set -- --editor --import
fi
exec "$GODOT_BIN" --headless --path "$GAME_DIR" "$@"
