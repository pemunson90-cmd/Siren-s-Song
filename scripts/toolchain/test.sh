#!/usr/bin/env bash
# Godot can exit zero after script errors; require the harness summary as well.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
"$(dirname -- "$0")/test-native-role-archive.sh"
python3 "$(dirname -- "$0")/test-android-role.py"
python3 "$(dirname -- "$0")/test-android-metric-records.py"
python3 "$(dirname -- "$0")/test-android-menu.py"
python3 "$(dirname -- "$0")/test-android-capture.py"
python3 "$(dirname -- "$0")/test-android-resume.py"
python3 "$(dirname -- "$0")/test-android-blackwater.py"
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
loadout_log="$ARTIFACT_DIR/loadout-ui-tests.log"
"$(dirname -- "$0")/headless.sh" --script res://tests/loadout_ui_tests.gd 2>&1 | tee "$loadout_log"
if grep -nE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$loadout_log"; then
    echo 'Godot reported loadout UI test errors' >&2
    exit 1
fi
grep -Eq '^LOADOUT CHECKS [1-9][0-9]* FAILURES 0$' "$loadout_log" || {
    echo 'Missing successful loadout UI summary' >&2; exit 1;
}
navigation_log="$ARTIFACT_DIR/navigation-departure-tests.log"
"$(dirname -- "$0")/headless.sh" --script res://tests/navigation_departure_tests.gd 2>&1 | tee "$navigation_log"
if grep -nE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$navigation_log"; then
    echo 'Godot reported navigation departure test errors' >&2
    exit 1
fi
grep -Eq '^NAVIGATION CHECKS [1-9][0-9]* FAILURES 0$' "$navigation_log" || {
    echo 'Missing successful navigation departure summary' >&2; exit 1;
}
well_shape_log="$ARTIFACT_DIR/well-save-shape-tests.log"
"$(dirname -- "$0")/headless.sh" --script res://tests/well_signature_save_shape_tests.gd 2>&1 | tee "$well_shape_log"
if grep -nE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$well_shape_log"; then
    echo 'Godot reported Well save-shape errors' >&2
    exit 1
fi
grep -Eq '^WELL SAVE SHAPE CHECKS [1-9][0-9]* FAILURES 0$' "$well_shape_log" || {
    echo 'Missing successful Well save-shape summary' >&2; exit 1;
}
"$(dirname -- "$0")/density-checks.sh"
