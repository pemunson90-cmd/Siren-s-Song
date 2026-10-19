#!/usr/bin/env bash
# Godot can exit zero after script errors; require the harness summary as well.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
python3 "$(dirname -- "$0")/test-android-view.py"
python3 "$(dirname -- "$0")/test-android-ui-metrics.py"
log="$ARTIFACT_DIR/tests.log"
"$(dirname -- "$0")/headless.sh" --script res://tests/run_tests.gd 2>&1 | tee "$log"
if grep -nE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$log"; then
    echo 'Godot reported errors despite the test process exit status' >&2
    exit 1
fi
grep -Eq '^CHECKS [1-9][0-9]* FAILURES 0$' "$log" || {
    echo 'Missing successful test-harness summary' >&2; exit 1;
}
runtime_log="$ARTIFACT_DIR/runtime-tests.log"
"$(dirname -- "$0")/headless.sh" --script res://tests/runtime_tests.gd 2>&1 | tee "$runtime_log"
if grep -nE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$runtime_log"; then
    echo 'Godot reported runtime UI test errors' >&2
    exit 1
fi
grep -Eq '^RUNTIME CHECKS [1-9][0-9]* FAILURES 0$' "$runtime_log" || {
    echo 'Missing successful runtime test-harness summary' >&2; exit 1;
}
