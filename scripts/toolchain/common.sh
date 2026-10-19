#!/usr/bin/env bash
set -euo pipefail
TOOLCHAIN_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
GAME_DIR="${GAME_DIR:-$TOOLCHAIN_ROOT/game}"
if [[ -d /workspace/.sirens-song-toolchain ]]; then
    default_cache=/workspace/.sirens-song-toolchain
else
    default_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sirens-song-toolchain"
fi
TOOLCHAIN_CACHE="${TOOLCHAIN_CACHE:-$default_cache}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$TOOLCHAIN_CACHE/artifacts}"
GODOT_BIN="${GODOT_BIN:-godot}"
if [[ -z "${JAVA_HOME:-}" ]]; then
    export JAVA_HOME="$(dirname -- "$(dirname -- "$(readlink -f "$(command -v java)")")")"
fi
export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
mkdir -p "$TOOLCHAIN_CACHE" "$ARTIFACT_DIR"

require_project() {
    test -f "$GAME_DIR/project.godot" || { echo "Missing Godot project: $GAME_DIR/project.godot" >&2; exit 1; }
}
