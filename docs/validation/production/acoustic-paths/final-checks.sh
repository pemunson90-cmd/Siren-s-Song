#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Siren-s-Song-acoustic-paths
for TEST_NAME in acoustic_path acoustic_hearing acoustic_footprint acoustic_path_affected acoustic_path_ui;do
 XDG_DATA_HOME="$PWD/work/acoustic-paths/final-test-userdata" godot --headless --path game --script "res://tests/${TEST_NAME}_tests.gd" > "docs/validation/production/acoustic-paths/final-${TEST_NAME}.log" 2>&1
 rg 'CHECKS|ERROR|FAIL' "docs/validation/production/acoustic-paths/final-${TEST_NAME}.log"
done
git diff --check
