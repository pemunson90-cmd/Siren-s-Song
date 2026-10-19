#!/usr/bin/env bash
# Sourced by android-smoke; two paused capture classes only, no input mutation.
capture_state_shot() {
    local label="$1" kind="$2" before="$3" mission="$4" attempt status
    local checker="$(dirname -- "${BASH_SOURCE[0]}")/android-capture.py"
    local base="$output/ui-metrics-capture-$label" probe="$output/$label-geometry-probe.png" candidate="$output/$label-candidate.png" final="$output/$label.png"
    rm -f "$final" "$candidate"
    adb shell wm density >"$base-density.txt" || return
    adb exec-out screencap -p >"$probe" || return
    for ((attempt=0; attempt<10; attempt++)); do
        read_logcat "$base.txt" || return
        status=0
        python3 "$checker" "$base.txt" "$probe" --density "$base-density.txt" --after-log "$before" --kind "$kind" --mission "$mission" >"$base-pre.json" 2>"$base.stderr.txt" || status=$?
        if (( status == 0 )); then
            adb exec-out screencap -p >"$candidate" || return
            read_logcat "$base.txt" || return
            python3 "$checker" "$base.txt" "$candidate" --density "$base-density.txt" --after-log "$before" --kind "$kind" --mission "$mission" >"$base.json" 2>"$base.stderr.txt" || status=$?
            if (( status == 0 )); then
                python3 - "$base-pre.json" "$base.json" <<'PY' || status=$?
import json,sys
before,after=(json.load(open(p)) for p in sys.argv[1:])
bc=before.pop('metrics_count');ac=after.pop('metrics_count')
bf=before['capture_state'].pop('drawn_frame');af=after['capture_state'].pop('drawn_frame')
if ac<bc or af<bf:print('Capture snapshot count/drawn frame regressed',file=sys.stderr);sys.exit(1)
sys.exit(0 if before==after else 3)
PY
                if (( status == 0 )); then
                    mv "$candidate" "$final"
                    stage "capture $label: matching fresh post_draw state bracket verified; compositor acknowledgment unavailable"
                    return 0
                fi
            fi
            if [[ -f "$candidate" ]]; then mv "$candidate" "$output/$label-rejected-$attempt.png"; fi
        fi
        if (( status != 3 )); then cat "$base.stderr.txt" >&2; return "$status"; fi
        sleep 1
    done
    echo "No fresh stable requested post_draw presentation for $label" >&2
    return 1
}
