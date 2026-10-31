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
shard=""
suites=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) profile="$2"; explicit=true; shift 2 ;;
        --list) list=true; shift ;;
        --skip-core) skip_core=true; shift ;;
        --suite) suite="$2"; explicit=true; shift 2 ;;
        --shard) shard="$2"; explicit=true; shift 2 ;;
        --suites) suites="$2"; explicit=true; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
[[ "$profile" == local || "$profile" == ci ]] || { echo 'Profile must be local or ci' >&2; exit 2; }
if [[ -n "$shard" ]]; then
    [[ "$profile" == ci && -z "$suite" && "$skip_core" == true && "$shard" =~ ^[1-4]$ ]] || {
        echo '--shard 1..4 requires --profile ci --skip-core and no --suite' >&2; exit 2;
    }
fi
if [[ -n "$suites" ]]; then
    [[ "$profile" == ci && -z "$suite" && -z "$shard" && "$suites" =~ ^[a-z0-9_]+(,[a-z0-9_]+)*$ ]] || {
        echo '--suites a,b,c requires --profile ci, no --suite or --shard, and a non-empty list' >&2; exit 2;
    }
fi
# Validate the complete registry before running any suite. Ranks preserve both
# historical runner orders, which differed before the registry was introduced.
selection=$(python3 - "$TOOLCHAIN_ROOT/game/tests/suites.txt" "$profile" "$suite" "$shard" "$suites" <<'PYREGISTRY'
import json, pathlib, re, statistics, sys
path, profile, selected, shard, listed = sys.argv[1:]
listed = listed.split(",") if listed else []
rows, names, ranks = [], set(), [set(), set()]
for line in pathlib.Path(path).read_text().splitlines():
    if not line.strip() or line.startswith("#"):
        continue
    fields = line.split("|")
    assert len(fields) in (4, 5), line
    name, summary, local, ci = fields[:4]
    backend = fields[4] if len(fields) == 5 else "headless"
    assert backend in ("headless", "render"), line
    assert re.fullmatch(r"[a-z0-9_]+", name) and name not in names, line
    assert re.fullmatch(r"[A-Z0-9 ]*", summary), line
    assert pathlib.Path(path).with_name(name + ".gd").is_file(), name
    names.add(name)
    for i, rank in enumerate((local, ci)):
        if rank != "-":
            assert int(rank) > 0 and int(rank) not in ranks[i], line
            ranks[i].add(int(rank))
    rank = local if profile == "local" else ci
    if listed:
        if name in listed:
            assert rank != "-", "Suite not registered for CI: " + name
            rows.append((int(rank), name, summary, backend))
    elif (selected and name == selected) or (not selected and rank != "-"):
        rows.append((0 if selected else int(rank), name, summary, backend))
assert not selected or selected in names, "Unknown suite: " + selected
for name in listed:
    assert name in names, "Unknown suite: " + name
ordered = sorted(rows)
if shard:
    # Core runs once in its own job.
    runtime = [row for row in ordered if row[1] != "run_tests"]
    times_path = pathlib.Path(path).with_name("suite-times.json")
    if times_path.is_file():
        # Duration balance: longest first (CI rank breaks ties) onto the least
        # loaded shard (lowest shard breaks ties); missing suites take the median.
        times = {k: float(v) for k, v in json.loads(times_path.read_text()).items()}
        known = [times[row[1]] for row in runtime if row[1] in times]
        median = statistics.median(known) if known else 1.0
        cost = {row[1]: times.get(row[1], median) for row in runtime}
        loads, owner = [0.0] * 4, {}
        for row in sorted(runtime, key=lambda row: (-cost[row[1]], row[0])):
            target = min(range(4), key=lambda i: (loads[i], i))
            loads[target] += cost[row[1]]
            owner[row[1]] = target
        ordered = [row for row in runtime if owner[row[1]] == int(shard) - 1]
    else:
        # Stable CI-rank order, balanced counts.
        ordered = runtime[int(shard)-1::4]
    assert ordered, "Empty CI shard"
for _, name, summary, backend in ordered:
    print(name + "|" + summary + "|" + backend)
PYREGISTRY
)
if "$list"; then
    while IFS='|' read -r scenario summary backend; do
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
[[ -n "$selection" ]] || { echo 'No suites selected' >&2; exit 1; }
failed=()
while IFS='|' read -r scenario summary backend; do
    if "$skip_core" && [[ "$scenario" == run_tests ]]; then continue; fi
    [[ -n "$scenario" ]] || { echo 'Empty suite name in selection' >&2; exit 1; }
    log="$ARTIFACT_DIR/$scenario.log"
    if [[ "$backend" == render ]]; then
        # Ubuntu's CI image provides Xvfb/xauth; require a real Canvas renderer.
        runner=(xvfb-run -a -s '-screen 0 2520x1968x24' env LIBGL_ALWAYS_SOFTWARE=1
            "$GODOT_BIN" --path "$GAME_DIR" --rendering-method gl_compatibility --audio-driver Dummy)
    else
        runner=("$(dirname -- "$0")/headless.sh")
    fi
    started=$(date +%s)
    rc=0
    timeout --kill-after=10s 480s "${runner[@]}" --script "res://tests/$scenario.gd" 2>&1 | tee "$log" || rc=$?
    # Wall seconds per suite; the nightly merges these into game/tests/suite-times.json.
    printf '%s\t%s\n' "$scenario" "$(( $(date +%s) - started ))" >> "$ARTIFACT_DIR/suite-times.tsv"
    # Keep running the remaining suites; every failure is listed once at the end.
    if [[ "$rc" -eq 124 || "$rc" -eq 137 ]]; then
        echo "Timed out: $scenario (exit $rc)" >&2
        failed+=("$scenario"); continue
    elif [[ "$rc" -ne 0 ]]; then
        echo "Nonzero exit $rc from $scenario" >&2
        failed+=("$scenario"); continue
    fi
    if grep -niE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:|resources still in use|ObjectDB instances leaked' "$log"; then
        echo "Godot reported errors or leaks in $scenario" >&2
        failed+=("$scenario"); continue
    fi
    prefix="${summary:+$summary }"
    if ! grep -Eq "^${prefix}CHECKS [1-9][0-9]* FAILURES 0$" "$log"; then
        echo "Missing successful $scenario summary" >&2
        failed+=("$scenario"); continue
    fi
done <<< "$selection"
if (( ${#failed[@]} )); then
    joined=$(printf '%s, ' "${failed[@]}")
    echo "FAILED SUITES: ${joined%, }" >&2
    exit 1
fi
