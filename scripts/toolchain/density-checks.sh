#!/usr/bin/env bash
# Actual game density geometry/menu suites; keep script errors fatal even on exit 0.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
for suite in geometry menu scroll; do
    case "$suite" in
        geometry) script=res://tests/density_scenarios.gd; summary='DENSITY CHECKS' ;;
        menu) script=res://tests/density_menu_scenarios.gd; summary='DENSITY MENU CHECKS' ;;
        scroll) script=res://tests/density_scroll_scenarios.gd; summary='DENSITY SCROLL CHECKS' ;;
    esac
    log="$ARTIFACT_DIR/density-$suite-tests.log"
    "$(dirname -- "$0")/headless.sh" --script "$script" 2>&1 | tee "$log"
    if grep -nE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$log"; then
        echo "Godot reported errors in density $suite suite" >&2
        exit 1
    fi
    grep -Eq "^$summary [1-9][0-9]* FAILURES 0$" "$log" || {
        echo "Missing successful $summary summary" >&2; exit 1;
    }
done
