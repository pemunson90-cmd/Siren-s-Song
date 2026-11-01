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
    "$apksigner" verify --verbose --print-certs "$output" | tee "$ARTIFACT_DIR/apk-signature.txt"
    pinned="$(tr -d '[:space:]' < "$(dirname -- "$0")/signing/sirens-song-debug.certificate.sha256")"
    mapfile -t signers < <(grep -E 'certificate SHA-256 digest:' "$ARTIFACT_DIR/apk-signature.txt" | awk '{print tolower($NF)}')
    test "${#signers[@]}" -gt 0 || { echo "APK signer check failed: no certificate SHA-256 line" >&2; exit 1; }
    for signer in "${signers[@]}"; do
        [[ "$signer" == "$pinned" ]] || { echo "APK signer check failed: expected $pinned, got $signer" >&2; exit 1; }
    done
    echo "APK signer SHA-256 matches pinned development certificate: $pinned"
fi
(cd -- "$(dirname -- "$output")" && sha256sum "$(basename -- "$output")") | tee "$output.sha256"
