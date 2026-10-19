#!/usr/bin/env bash
# Sourced by the native smoke; only enabled with matching density-aware source.
menu_snapshot() {
    local profile="$1" label="$2" screen="$3" action="$4" after="${5:-0}" attempt status pre_status
    local capture="$output/$profile-menu-$label.png" probe="$output/$profile-menu-$label-geometry-probe.png" candidate="$output/$profile-menu-$label-candidate.png"
    local state_args=()
    if [[ -n "${menu_settings_baseline:-}" ]]; then state_args+=(--unchanged-settings "$menu_settings_baseline"); fi
    menu_report="$output/ui-metrics-menu-$profile-$label.json"
    # The probe establishes native PNG geometry only, never requested-screen pixels.
    # Final capture follows matching fresh metrics, then is checked against a
    # second observation. There is no compositor/presented-frame acknowledgment.
    rm -f "$capture" "$candidate"
    adb shell wm density >"$output/density-$profile.txt"
    adb exec-out screencap -p >"$probe" || return
    for ((attempt=0; attempt<10; attempt++)); do
        read_logcat "$output/ui-metrics-menu-$profile-$label.txt"
        status=0
        python3 "$(dirname -- "${BASH_SOURCE[0]}")/android-menu.py" \
            "$output/ui-metrics-menu-$profile-$label.txt" "$probe" \
            --density "$output/density-$profile.txt" --screen "$screen" --action "$action" --after-count "$after" --wait-for-screen "${state_args[@]}" \
            >"$menu_report.pre-capture.json" 2>"$output/ui-metrics-menu-$profile-$label.stderr.txt" || status=$?
        if (( status == 0 || status == 2 )); then
            pre_status="$status"
            adb exec-out screencap -p >"$candidate" || return
            read_logcat "$output/ui-metrics-menu-$profile-$label.txt"
            status=0
            python3 "$(dirname -- "${BASH_SOURCE[0]}")/android-menu.py" \
                "$output/ui-metrics-menu-$profile-$label.txt" "$candidate" \
                --density "$output/density-$profile.txt" --screen "$screen" --action "$action" --after-count "$after" --wait-for-screen "${state_args[@]}" \
                >"$menu_report" 2>"$output/ui-metrics-menu-$profile-$label.stderr.txt" || status=$?
            if (( status == pre_status )) && python3 - "$menu_report.pre-capture.json" "$menu_report" <<'PY'
import json,sys
before,after=(json.load(open(path)) for path in sys.argv[1:])
# Legitimate identical layout re-emission advances the count; it need not freeze.
before_count=before.pop('metrics_count');after_count=after.pop('metrics_count')
sys.exit(0 if after_count>=before_count and before==after else 1)
PY
            then
                mv "$candidate" "$capture"
                menu_status="$status"; return 0
            fi
            if (( status == 0 || status == 2 )); then
                echo "Menu state changed across screenshot; retrying: $profile $label" >&2
                mv "$candidate" "$output/$profile-menu-$label-rejected-$attempt.png"
                status=3
            fi
        fi
        if (( status != 3 )); then cat "$output/ui-metrics-menu-$profile-$label.stderr.txt" >&2; return "$status"; fi
        sleep 1
    done
    echo "Fresh stable menu state around screenshot missing: $profile $label" >&2
    return 1
}
menu_json_values() {
    python3 - "$menu_report" "$1" <<'PY'
import json,sys
value=json.load(open(sys.argv[1]))[sys.argv[2]]
print(*value) if isinstance(value,list) else print(value)
PY
}
menu_assert_scroll_progress() {
    python3 - "$@" <<'PY'
import sys
before,after,y1,y2=map(float,sys.argv[1:])
assert (after-before)*(y1-y2)>abs(y1-y2), 'OS swipe made no progress in emitted swipe direction'
PY
}
menu_touch_smoke() {
    local profile="$1" swipe_index before_count before_offset after_offset x1 y1 x2 y2 tap_x tap_y initial_log action settings_swipes=0 operations_swipes=0
    menu_settings_baseline=""
    stage "$profile actual OS menu scroll/Settings/sticky BACK begins"
    # This is the first input path on cover, before locate_target is reached.
    ensure_system_intro || return
    initial_log="$output/ui-metrics-menu-$profile-before.txt"
    read_logcat "$initial_log"
    menu_snapshot "$profile" initial menu settings
    menu_settings_baseline="$output/ui-metrics-menu-$profile-settings-baseline.json"
    cp "$menu_report" "$menu_settings_baseline"
    for ((swipe_index=0; swipe_index<8 && menu_status==2; swipe_index++)); do
        before_count="$(menu_json_values metrics_count)"
        before_offset="$(menu_json_values scroll_vertical)"
        read -r x1 y1 x2 y2 <<<"$(menu_json_values swipe)"
        stage "$profile menu OS swipe $swipe_index inside measured scroll body"
        adb shell input swipe "$x1" "$y1" "$x2" "$y2" 450
        menu_snapshot "$profile" "scroll-$swipe_index" menu settings "$before_count"
        after_offset="$(menu_json_values scroll_vertical)"
        menu_assert_scroll_progress "$before_offset" "$after_offset" "$y1" "$y2"
    done
    (( menu_status == 0 )) || { echo 'Settings never became fully exposed in bounded scroll attempts' >&2; return 1; }
    operations_swipes="$swipe_index"
    if (( swipe_index == 0 )); then stage "$profile Settings initially fully exposed; no overflow scroll demonstrated"; fi
    before_count="$(menu_json_values metrics_count)"
    read -r tap_x tap_y <<<"$(menu_json_values tap)"
    adb shell input tap "$tap_x" "$tap_y"
    menu_snapshot "$profile" settings settings back "$before_count"
    (( menu_status == 0 )) || { echo 'Sticky Settings BACK is not fully exposed' >&2; return 1; }
    for action in volume_effects mute; do
        menu_snapshot "$profile" "settings-$action" settings "$action"
        for ((swipe_index=0; swipe_index<4 && menu_status==2; swipe_index++)); do
            before_count="$(menu_json_values metrics_count)"
            before_offset="$(menu_json_values scroll_vertical)"
            read -r x1 y1 x2 y2 <<<"$(menu_json_values swipe)"
            stage "$profile Settings OS swipe from measured empty gap to expose $action"
            adb shell input swipe "$x1" "$y1" "$x2" "$y2" 450
            ((settings_swipes+=1))
            menu_snapshot "$profile" "settings-$action-scroll-$swipe_index" settings "$action" "$before_count"
            after_offset="$(menu_json_values scroll_vertical)"
            menu_assert_scroll_progress "$before_offset" "$after_offset" "$y1" "$y2"
        done
        (( menu_status == 0 )) || { echo "Settings $action never fully exposed" >&2; return 1; }
    done
    stage "$profile Settings effects/mute reachability verified; unchanged settings; scroll gestures=$settings_swipes"
    menu_snapshot "$profile" settings-back settings back
    (( menu_status == 0 )) || { echo 'Sticky Settings BACK not exposed after body scroll' >&2; return 1; }
    before_count="$(menu_json_values metrics_count)"
    read -r tap_x tap_y <<<"$(menu_json_values tap)"
    adb shell input tap "$tap_x" "$tap_y"
    menu_snapshot "$profile" returned menu settings "$before_count"
    menu_settings_baseline=""
    python3 - "$initial_log" "$output/ui-metrics-menu-$profile-returned.txt" <<'PY'
from pathlib import Path
import sys
before,after=(Path(x).read_text() for x in sys.argv[1:])
for marker in ('SS_MISSION_SELECT ','SS_ORDER ','SS_PAUSE paused='):
    assert before.count(marker)==after.count(marker), f'Menu scroll/Settings/BACK emitted unintended {marker}'
print('Real menu inputs returned to operations without mission/order/pause events')
PY
    stage "$profile measured Settings/sticky BACK native input verified; operations scroll gestures=$operations_swipes"
}
