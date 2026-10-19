#!/usr/bin/env bash
# Sourced by android-smoke.sh. One-pointer OS input; no waypoint taps or OS pinch claim.
planner_snapshot() {
    local profile="$1" label="$2" operation="$3" after="$4" baseline="${5:-}" previous="${6:-}" attempt status
    local image_prefix="$output/$profile-planner-$label"
    local prefix="$output/ui-metrics-planner-$profile-$label" checker="$TOOLCHAIN_ROOT/scripts/toolchain/android-planner.py"
    local comparisons=()
    [[ -z "$baseline" ]] || comparisons+=(--baseline "$baseline")
    [[ -z "$previous" ]] || comparisons+=(--previous "$previous")
    planner_report="$prefix.json"; planner_log="$prefix.txt"
    adb shell wm density >"$output/density-$profile.txt"
    adb exec-out screencap -p >"$image_prefix-geometry-probe.png" || return
    for ((attempt=0; attempt<10; attempt++)); do
        read_logcat "$prefix-pre.txt"
        status=0
        python3 "$checker" "$prefix-pre.txt" "$image_prefix-geometry-probe.png" --density "$output/density-$profile.txt" --after-log "$after" --operation "$operation" "${comparisons[@]}" >"$prefix-pre.json" 2>"$prefix.stderr.txt" || status=$?
        if (( status == 0 )); then
            adb exec-out screencap -p >"$image_prefix-candidate.png" || return
            read_logcat "$planner_log"
            status=0
            python3 "$checker" "$planner_log" "$image_prefix-candidate.png" --density "$output/density-$profile.txt" --after-log "$after" --operation "$operation" "${comparisons[@]}" >"$planner_report" 2>"$prefix.stderr.txt" || status=$?
            if (( status == 0 )) && python3 - "$prefix-pre.json" "$planner_report" <<'PY'
import json,sys
before,after=(json.load(open(p)) for p in sys.argv[1:])
assert before['planner']==after['planner'] and before['measurement']==after['measurement'], 'Planner state/layout changed across PNG capture'
assert after['transport'][0]==before['transport'][0] and after['transport'][1]>=before['transport'][1], 'Planner transport regressed across PNG capture'
before_frame=before['capture_state'].pop('drawn_frame');after_frame=after['capture_state'].pop('drawn_frame')
assert after_frame>=before_frame and before['capture_state']==after['capture_state'], 'Planner draw/state changed across PNG capture'
PY
            then
                mv "$image_prefix-candidate.png" "$image_prefix.png"; return 0
            fi
            mv "$image_prefix-candidate.png" "$image_prefix-rejected-$attempt.png"
            if (( status == 0 )); then status=3; fi
        fi
        if (( status != 3 )); then cat "$prefix.stderr.txt" >&2; return "$status"; fi
        sleep 1
    done
    cat "$prefix.stderr.txt" >&2
    echo "No fresh stable planner state: $profile $label" >&2; return 1
}
planner_values() {
    python3 - "$planner_report" "$1" <<'PY'
import json,sys
value=json.load(open(sys.argv[1]))
for key in sys.argv[2].split('.'):value=value[key]
print(*value)
PY
}
planner_touch_smoke() {
    local profile="$1" baseline previous after action operation label tap_x tap_y x1 y1 x2 y2
    stage "$profile paused planner native toolbar/drag/FIT begins"
    read_logcat "$output/ui-metrics-planner-$profile-before-entry.txt"
    tap_target program 'SS_SCREEN program paused=true' "$profile-planner-open"
    planner_snapshot "$profile" initial initial "$output/ui-metrics-planner-$profile-before-entry.txt"
    baseline="$planner_report"
    for specification in 'planner_zoom_in zoom-in in1' 'planner_zoom_in zoom-in in2' 'drag pan pan' 'planner_zoom_out zoom-out out' 'planner_fit fit fit'; do
        read -r action operation label <<<"$specification"
        previous="$planner_report"; after="$planner_log"
        if [[ "$action" == drag ]]; then
            read -r x1 y1 x2 y2 <<<"$(planner_values swipe)"
            adb shell input swipe "$x1" "$y1" "$x2" "$y2" 450
        else
            read -r tap_x tap_y <<<"$(planner_values "taps.$action")"
            adb shell input tap "$tap_x" "$tap_y"
        fi
        planner_snapshot "$profile" "$label" "$operation" "$after" "$baseline" "$previous"
    done
    # DONE is measured by the same geometry gate; secondary HUD must reappear.
    read -r tap_x tap_y <<<"$(planner_values taps.close)"
    read_logcat "$output/ui-metrics-planner-$profile-before-close.txt"
    local before_count
    before_count="$(grep -c 'SS_TARGET recon ' "$output/ui-metrics-planner-$profile-before-close.txt" || true)"
    adb shell input tap "$tap_x" "$tap_y"
    wait_new_marker 'SS_TARGET recon ' "$before_count" "$profile-planner-closed" 20
    cp "$output/wait-$profile-planner-closed.txt" "$output/ui-metrics-planner-$profile-closed.txt"
    python3 - "$baseline" "$output/ui-metrics-planner-$profile-closed.txt" "$TOOLCHAIN_ROOT/scripts/toolchain" <<'PY'
import json,sys
sys.path.insert(0,sys.argv[3])
from android_metric_records import read_records
base=json.load(open(sys.argv[1]))['planner']['intent'];records=read_records(open(sys.argv[2]).read())
assert records and records[-1][1] is not None, 'Incomplete latest close report'
layout=json.loads(records[-1][1]);state=layout['capture_state']
assert layout['screen']=='mission' and 'planner' not in layout and state['paused'] and state['selected']==base['selected'] and state['mission']==base['mission'], 'DONE failed to return to paused selected mission'
print('Planner OS single-pointer zoom/drag/FIT preserved paused own intent and supplies; DONE returned to mission')
PY
    stage "$profile planner native single-pointer navigation verified; OS pinch/comfort remain unverified"
}
