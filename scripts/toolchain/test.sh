#!/usr/bin/env bash
# Godot can exit zero after script errors; require each harness summary.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
profile=local
list=false
skip_core=false
suite=""
explicit=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) profile="$2"; explicit=true; shift 2 ;;
        --list) list=true; shift ;;
        --skip-core) skip_core=true; shift ;;
        --suite) suite="$2"; explicit=true; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
[[ "$profile" == local || "$profile" == ci ]] || { echo 'Profile must be local or ci' >&2; exit 2; }
# Validate the complete registry before running any suite. Ranks preserve both
# historical runner orders, which differed before the registry was introduced.
selection=$(python3 - "$TOOLCHAIN_ROOT/game/tests/suites.txt" "$profile" "$suite" <<'PYREGISTRY'
import pathlib, re, sys
path, profile, selected = sys.argv[1:]
rows, names, ranks = [], set(), [set(), set()]
for line in pathlib.Path(path).read_text().splitlines():
    if not line.strip() or line.startswith("#"):
        continue
    name, summary, local, ci = line.split("|")
    assert re.fullmatch(r"[a-z0-9_]+", name) and name not in names, line
    assert re.fullmatch(r"[A-Z0-9 ]*", summary), line
    assert pathlib.Path(path).with_name(name + ".gd").is_file(), name
    names.add(name)
    for i, rank in enumerate((local, ci)):
        if rank != "-":
            assert int(rank) > 0 and int(rank) not in ranks[i], line
            ranks[i].add(int(rank))
    rank = local if profile == "local" else ci
    if (selected and name == selected) or (not selected and rank != "-"):
        rows.append((0 if selected else int(rank), name, summary))
assert not selected or selected in names, "Unknown suite: " + selected
for _, name, summary in sorted(rows):
    print(name + "|" + summary)
PYREGISTRY
)
if "$list"; then
    while IFS='|' read -r scenario summary; do
        if "$skip_core" && [[ "$scenario" == run_tests ]]; then continue; fi
        echo "$scenario"
    done <<< "$selection"
    exit 0
fi
if ! "$explicit"; then
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
fi
while IFS='|' read -r scenario summary; do
    if "$skip_core" && [[ "$scenario" == run_tests ]]; then continue; fi
    log="$ARTIFACT_DIR/$scenario.log"
    timeout --kill-after=10s 480s "$(dirname -- "$0")/headless.sh" --script "res://tests/$scenario.gd" 2>&1 | tee "$log"
    if grep -niE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:|resources still in use|ObjectDB instances leaked' "$log"; then
        echo "Godot reported errors or leaks in $scenario" >&2; exit 1
    fi
    prefix="${summary:+$summary }"
    grep -Eq "^${prefix}CHECKS [1-9][0-9]* FAILURES 0$" "$log" || {
        echo "Missing successful $scenario summary" >&2; exit 1;
    }
done <<< "$selection"
