#!/usr/bin/env bash
# Optional, sourced after ordinary native gates. Private subshell/archive evidence;
# always use unchanged role restore helper, including failures and interruptions.
native_blackwater_smoke() (
    set -euo pipefail
    if "$role_backup_active"; then echo 'Another fixture archive transaction is active' >&2; exit 1; fi
    output="$output/blackwater"
    mkdir -p "$output"
    local tool_dir profile dimensions suffix name status before_count x y x1 y1 x2 y2 count offset
    tool_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    role_backup_active=false
    trap 'status=$?; trap - EXIT; if ! restore_role_archive; then echo "Blackwater genuine archive restoration failed" >&2; status=1; fi; exit "$status"' EXIT
    stage 'fixture-assisted untouched Blackwater request check begins; not earned chapter progression'
    "$GODOT_BIN" --headless --path "$GAME_DIR" --script "$tool_dir/native-blackwater-fixture.gd" -- \
        "--output=$output/fixture.save" >"$output/fixture-generation.txt" 2>&1
    cat "$output/fixture-generation.txt"
    grep -q 'fresh_snapshot_equal=true' "$output/fixture-generation.txt"
    adb shell am force-stop "$package"
    adb shell run-as "$package" find files -type f -name quietus.save >"$output/save-path.txt"
    mapfile -t save_paths < <(tr -d '\r' <"$output/save-path.txt")
    (( ${#save_paths[@]} == 1 )) || { echo 'Expected one genuine archive path' >&2; exit 1; }
    role_save_path="${save_paths[0]}"
    [[ "$role_save_path" =~ ^files/[a-zA-Z0-9_./-]+$ && "$role_save_path" != *..* ]] || exit 1
    # Never repurpose existing Well backups or an earlier Blackwater transaction.
    test ! -e "$output/role-archive-primary.save"
    for suffix in primary backup temporary; do
        name="$role_save_path"
        [[ "$suffix" != backup ]] || name+=.bak
        [[ "$suffix" != temporary ]] || name+=.tmp
        status=0
        adb shell run-as "$package" test -f "$name" || status=$?
        if (( status == 0 )); then
            adb exec-out run-as "$package" cat "$name" >"$output/role-archive-$suffix.save"
            sha256sum "$output/role-archive-$suffix.save" >>"$output/role-archive-hashes.txt"
        elif (( status != 1 )); then exit "$status"; fi
    done
    test -s "$output/role-archive-primary.save"
    role_backup_active=true
    for profile in cover inner; do
        dimensions=1080x2520; [[ "$profile" != inner ]] || dimensions=1968x2184
        adb shell am force-stop "$package"
        adb shell wm size "$dimensions"
        adb shell wm density 420
        adb shell run-as "$package" rm -f "$role_save_path.bak" "$role_save_path.tmp"
        adb shell -T run-as "$package" tee "$role_save_path" <"$output/fixture.save" >/dev/null
        adb exec-out run-as "$package" cat "$role_save_path" >"$output/$profile-fixture-installed.save"
        cmp "$output/fixture.save" "$output/$profile-fixture-installed.save"
        launch "blackwater-$profile"
        tap_target resume 'SS_SCREEN mission paused=true' "$profile-blackwater-enter"
        tap_target droneA 'SS_ORDER select accepted=true selected=1' "$profile-blackwater-drone"
        tap_target fit 'SS_VIEW zoom=' "$profile-blackwater-fit"
        locate_target objective0 "$profile-blackwater-route"
        adb shell wm density >"$output/$profile-density.txt"
        python3 "$tool_dir/android-blackwater.py" "$output/target-$profile-blackwater-route.txt" \
            "$output/target-$profile-blackwater-route.png" --density "$output/$profile-density.txt" \
            --after-log "$output/target-$profile-blackwater-fit.txt" --kind route --mission 2 >"$output/$profile-route.json"
        read -r x y < <(python3 - "$output/$profile-route.json" <<'PY'
import json,sys
print(*json.load(open(sys.argv[1]))['tap'])
PY
        )
        read_logcat "$output/$profile-before-route.txt"
        before_count="$(grep -Ec 'SS_ORDER route accepted=true selected=1' "$output/$profile-before-route.txt" || true)"
        adb shell input tap "$x" "$y"
        wait_new_marker 'SS_ORDER route accepted=true selected=1' "$before_count" "$profile-blackwater-route" 20
        read_logcat "$output/$profile-before-travel.txt"
        before_count="$(grep -Ec 'SS_CAMERA_READY unit=1 objective=0' "$output/$profile-before-travel.txt" || true)"
        tap_target pause 'SS_PAUSE paused=false' "$profile-blackwater-travel"
        wait_new_marker 'SS_CAMERA_READY unit=1 objective=0' "$before_count" "$profile-blackwater-ready" 60
        tap_target pause 'SS_PAUSE paused=true' "$profile-blackwater-vantage-pause"
        # One finite planned production DISRUPT, not an AI query or immunity.
        tap_target emp 'SS_ORDER emp accepted=true selected=1' "$profile-blackwater-disrupt"
        tap_target camera 'SS_ORDER camera accepted=true selected=1' "$profile-blackwater-sample"
        capture_state_shot "$profile-blackwater-receiving" receiving "$output/target-$profile-blackwater-sample.txt" 2 "$tool_dir/android-blackwater.py"
        read_logcat "$output/$profile-before-sampling.txt"
        before_count="$(grep -Ec 'SS_OBJECTIVE_RECORDED mission=2 objective=0' "$output/$profile-before-sampling.txt" || true)"
        tap_target pause 'SS_PAUSE paused=false' "$profile-blackwater-sample-resume"
        wait_new_marker 'SS_OBJECTIVE_RECORDED mission=2 objective=0' "$before_count" "$profile-blackwater-request-earned" 20
        tap_target pause 'SS_PAUSE paused=true' "$profile-blackwater-earned-pause"
        adb exec-out run-as "$package" cat "$role_save_path" >"$output/$profile-earned.save"
        "$GODOT_BIN" --headless --path "$GAME_DIR" --script "$tool_dir/native-blackwater-fixture.gd" -- \
            "--verify-earned=$output/$profile-earned.save" >"$output/$profile-earned-verification.txt" 2>&1
        grep -q 'earned_request_verified=true' "$output/$profile-earned-verification.txt"
        read_logcat "$output/$profile-before-cold.txt"
        before_count="$(grep -Ec 'SS_RESTORE ok mission=2 .*paused=true' "$output/$profile-before-cold.txt" || true)"
        adb shell am force-stop "$package"
        launch "$profile-blackwater-cold"
        wait_new_marker 'SS_RESTORE ok mission=2 .*paused=true' "$before_count" "$profile-blackwater-cold-restored" 30
        adb exec-out run-as "$package" cat "$role_save_path" >"$output/$profile-cold-restored.save"
        cmp "$output/$profile-earned.save" "$output/$profile-cold-restored.save"
        tap_target resume 'SS_SCREEN mission paused=true' "$profile-blackwater-cold-enter"
        tap_target menu 'SS_SCREEN operations' "$profile-blackwater-menu"
        menu_settings_baseline=""
        menu_snapshot "$profile" blackwater-evidence-entry menu evidence
        for ((count=0; count<8 && menu_status==2; count++)); do
            before_count="$(menu_json_values metrics_count)";offset="$(menu_json_values scroll_vertical)"
            read -r x1 y1 x2 y2 <<<"$(menu_json_values swipe)"
            adb shell input swipe "$x1" "$y1" "$x2" "$y2" 450
            menu_snapshot "$profile" "blackwater-evidence-scroll-$count" menu evidence "$before_count"
            python3 - "$offset" "$(menu_json_values scroll_vertical)" <<'PY'
import sys
assert float(sys.argv[2])>float(sys.argv[1])+1,'Blackwater menu scroll made no progress'
PY
        done
        (( menu_status==0 )) || { echo 'Earned gallery entry not exposed' >&2; exit 1; }
        read -r x y <<<"$(menu_json_values tap)"
        read_logcat "$output/$profile-before-gallery.txt"
        adb shell input tap "$x" "$y"
        capture_state_shot "$profile-blackwater-request-gallery" gallery "$output/$profile-before-gallery.txt" 2 "$tool_dir/android-blackwater.py"
        sha256sum "$output/$profile-earned.save" "$output/$profile-cold-restored.save" >"$output/$profile-earned-hashes.txt"
        stage "$profile fixture-assisted ordinary Blackwater request/paused cold restore/gallery checks passed"
    done
    restore_role_archive
    launch blackwater-genuine-archive-restored
    stage 'Blackwater fixture checks passed; genuine archive restored byte-for-byte'
)
