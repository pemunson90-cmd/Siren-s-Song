#!/usr/bin/env bash
# Sourced by the native smoke; only enabled with matching density-aware source.
menu_snapshot() {
    local profile="$1" label="$2" screen="$3" action="$4" after="${5:-0}" attempt status
    menu_report="$output/ui-metrics-menu-$profile-$label.json"
    adb shell wm density >"$output/density-$profile.txt"
    for ((attempt=0; attempt<10; attempt++)); do
        adb exec-out screencap -p >"$output/$profile-menu-$label.png"
        read_logcat "$output/ui-metrics-menu-$profile-$label.txt"
        status=0
        python3 "$(dirname -- "${BASH_SOURCE[0]}")/android-menu.py" \
            "$output/ui-metrics-menu-$profile-$label.txt" "$output/$profile-menu-$label.png" \
            --density "$output/density-$profile.txt" --screen "$screen" --action "$action" --after-count "$after" \
            >"$menu_report" 2>"$output/ui-metrics-menu-$profile-$label.stderr.txt" || status=$?
        if (( status == 0 || status == 2 )); then menu_status="$status"; return 0; fi
        if (( status != 3 )); then cat "$output/ui-metrics-menu-$profile-$label.stderr.txt" >&2; return "$status"; fi
        sleep 1
    done
    echo "Fresh actual menu metrics missing: $profile $label" >&2
    return 1
}
menu_json_values() {
    python3 - "$menu_report" "$1" <<'PY'
import json,sys
value=json.load(open(sys.argv[1]))[sys.argv[2]]
print(*value) if isinstance(value,list) else print(value)
PY
}
menu_touch_smoke() {
    local profile="$1" swipe_index before_count before_offset after_offset x1 y1 x2 y2 tap_x tap_y initial_log
    stage "$profile actual OS menu scroll/Settings/sticky BACK begins"
    # This is the first input path on cover, before locate_target is reached.
    ensure_system_intro || return
    initial_log="$output/ui-metrics-menu-$profile-before.txt"
    read_logcat "$initial_log"
    menu_snapshot "$profile" initial menu settings
    for ((swipe_index=0; swipe_index<8 && menu_status==2; swipe_index++)); do
        before_count="$(menu_json_values metrics_count)"
        before_offset="$(menu_json_values scroll_vertical)"
        read -r x1 y1 x2 y2 <<<"$(menu_json_values swipe)"
        stage "$profile menu OS swipe $swipe_index inside measured scroll body"
        adb shell input swipe "$x1" "$y1" "$x2" "$y2" 450
        menu_snapshot "$profile" "scroll-$swipe_index" menu settings "$before_count"
        after_offset="$(menu_json_values scroll_vertical)"
        python3 - "$before_offset" "$after_offset" <<'PY'
import sys
assert float(sys.argv[2]) > float(sys.argv[1])+1, 'OS swipe did not advance actual menu scroll offset'
PY
    done
    (( menu_status == 0 )) || { echo 'Settings never became fully exposed in bounded scroll attempts' >&2; return 1; }
    if (( swipe_index == 0 )); then stage "$profile Settings initially fully exposed; no overflow scroll demonstrated"; fi
    before_count="$(menu_json_values metrics_count)"
    read -r tap_x tap_y <<<"$(menu_json_values tap)"
    adb shell input tap "$tap_x" "$tap_y"
    menu_snapshot "$profile" settings settings back "$before_count"
    (( menu_status == 0 )) || { echo 'Sticky Settings BACK is not fully exposed' >&2; return 1; }
    before_count="$(menu_json_values metrics_count)"
    read -r tap_x tap_y <<<"$(menu_json_values tap)"
    adb shell input tap "$tap_x" "$tap_y"
    menu_snapshot "$profile" returned menu settings "$before_count"
    python3 - "$initial_log" "$output/ui-metrics-menu-$profile-returned.txt" <<'PY'
from pathlib import Path
import sys
before,after=(Path(x).read_text() for x in sys.argv[1:])
for marker in ('SS_MISSION_SELECT ','SS_ORDER ','SS_PAUSE paused='):
    assert before.count(marker)==after.count(marker), f'Menu scroll/Settings/BACK emitted unintended {marker}'
print('Real menu inputs returned to operations without mission/order/pause events')
PY
    stage "$profile measured Settings/sticky BACK native input verified; scroll gestures=$swipe_index"
}
