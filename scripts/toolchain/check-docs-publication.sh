#!/usr/bin/env bash
# Read-only gate. Run before a separate push of the printed immutable candidate.
# The caller must choose and label the expected runtime base; this script cannot certify it.
set -euo pipefail
if (( $# != 2 )); then
    echo "Usage: $0 EXPECTED_RUNTIME_BASE CANDIDATE" >&2
    exit 2
fi
base_sha="$(git rev-parse --verify --end-of-options "$1^{commit}")"
candidate_sha="$(git rev-parse --verify --end-of-options "$2^{commit}")"
status=0
git diff --quiet "$base_sha" "$candidate_sha" -- game scripts .github || status=$?
if (( status != 0 )); then
    echo "Docs publication rejected: candidate differs from expected runtime base (diff status $status)." >&2
    echo "Expected base: $base_sha; candidate: $candidate_sha" >&2
    exit 1
fi
# Fail closed on changes outside documentation too; inspect both sides of renames.
while IFS= read -r -d '' path; do
    case "$path" in
        docs/*|AGENTS.md) ;;
        *) echo "Docs publication rejected: non-documentation path: $path" >&2; exit 1 ;;
    esac
done < <(git diff --no-renames --name-only -z "$base_sha" "$candidate_sha")
printf 'Expected runtime base: %s\nImmutable docs candidate: %s\n' "$base_sha" "$candidate_sha"
echo 'Gate passed. Push this exact candidate in a separate dependent command; do not substitute HEAD.'
