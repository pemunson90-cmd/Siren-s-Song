#!/usr/bin/env bash
# Godot can exit zero after script errors; require the harness summary as well.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
python3 "$(dirname -- "$0")/test-configure-signing.py"
"$(dirname -- "$0")/test-native-role-archive.sh"
"$(dirname -- "$0")/test-decoy-role-contract.sh"
python3 "$(dirname -- "$0")/test-android-role.py"
python3 "$(dirname -- "$0")/test-android-metric-records.py"
python3 "$(dirname -- "$0")/test-android-menu.py"
python3 "$(dirname -- "$0")/test-android-capture.py"
python3 "$(dirname -- "$0")/test-android-resume.py"
python3 "$(dirname -- "$0")/test-android-blackwater.py"
python3 "$(dirname -- "$0")/test-android-view.py"
python3 "$(dirname -- "$0")/test-android-ui-metrics.py"
python3 "$(dirname -- "$0")/test-android-radial.py"
python3 "$(dirname -- "$0")/test-android-planner.py"
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

# Integrated tactical milestone guards: require each actual harness summary,
# since Godot may return zero after a script error.
while IFS='|' read -r scenario summary; do
    tactical_log="$ARTIFACT_DIR/$scenario.log"
    "$(dirname -- "$0")/headless.sh" --script "res://tests/$scenario.gd" 2>&1 | tee "$tactical_log"
    if grep -nE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$tactical_log"; then
        echo "Godot reported errors in $scenario" >&2; exit 1
    fi
    grep -Eq "^$summary CHECKS [1-9][0-9]* FAILURES 0$" "$tactical_log" || {
        echo "Missing successful $scenario summary" >&2; exit 1;
    }
done <<'TACTICAL_SCENARIOS'
polygon_bound_tests|POLYGON BOUND
divergence_tests|DIVERGENCE
divergence_save_tests|DIVERGENCE SAVE
expedition_menu_tests|EXPEDITION MENU
turn_safe_navigation_tests|TURN SAFE NAVIGATION
expanded_region_tests|EXPANDED REGION
expanded_region_journeys|EXPANDED JOURNEYS
route_program_tests|ROUTE PROGRAM
drone_drive_tests|DRONE DRIVE
drone_drive_ui_tests|DRONE DRIVE UI
drone_operations_tests|DRONE OPERATIONS
drone_operations_ui_tests|DRONE OPERATIONS UI
contact_reports_tests|CONTACT REPORT
contact_reports_ui_tests|CONTACT REPORT UI
blackwater_courier_tests|COURIER
route_program_ui_tests|ROUTE PROGRAM UI
planner_navigation_ui_tests|PLANNER NAVIGATION
planner_space_ui_tests|PLANNER SPACE UI
playfield_hud_tests|PLAYFIELD HUD
radial_hud_tests|RADIAL HUD
expedition_instruments_ui_tests|EXPEDITION INSTRUMENT UI
campaign_instruments_tests|CAMPAIGN INSTRUMENT
campaign_instruments_ui_tests|CAMPAIGN INSTRUMENT UI
campaign_debrief_view_tests|CAMPAIGN DEBRIEF VIEW
planner_metrics_tests|PLANNER METRICS
acoustic_path_tests|ACOUSTIC PATH
acoustic_hearing_tests|ACOUSTIC HEARING
acoustic_footprint_tests|ACOUSTIC FOOTPRINT
acoustic_path_affected_tests|AFFECTED ACOUSTIC
acoustic_path_ui_tests|ACOUSTIC PATH UI
decoy_deployment_tests|DECOY DEPLOYMENT
decoy_aim_ui_tests|DECOY AIM UI
knockdown_scenarios|KNOCKDOWN
knockdown_ui_scenarios|KNOCKDOWN UI
torpedo_aim_ui_tests|TORPEDO AIM
foundry_departure_tests|FOUNDRY DEPARTURE
thermal_lee_tests|THERMAL LEE
thermal_transmission_tests|THERMAL TRANSMISSION
thermal_ui_tests|THERMAL UI
terminal_tick_tests|TERMINAL TICK
extraction_survival_tests|EXTRACTION SURVIVAL
tactics_composition_tests|TACTICS COMPOSITION
TACTICAL_SCENARIOS
