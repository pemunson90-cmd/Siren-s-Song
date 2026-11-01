#!/usr/bin/env bash
# Fails unless every signer certificate SHA-256 in saved apksigner --print-certs output
# equals the pinned development certificate.
set -euo pipefail
report="${1:?Usage: $0 <apksigner-output-file>}"
pinned_file="$(dirname -- "$0")/signing/sirens-song-debug.certificate.sha256"
pinned="$(tr -d '[:space:]' < "$pinned_file")"
mapfile -t signers < <(grep -E 'certificate SHA-256 digest:' "$report" | awk '{print tolower($NF)}')
if [[ ${#signers[@]} -eq 0 ]]; then
    echo "APK signer check failed: no certificate SHA-256 line in $report" >&2
    exit 1
fi
for signer in "${signers[@]}"; do
    if [[ "$signer" != "$pinned" ]]; then
        echo "APK signer check failed: expected $pinned, got $signer" >&2
        exit 1
    fi
done
echo "APK signer SHA-256 matches pinned development certificate: $pinned"
