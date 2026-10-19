#!/usr/bin/env bash
# Sourced by android-smoke.sh: reuse bounded adb, input and strict error gates.
role_backup_active=false
restore_role_archive() {
    if ! "$role_backup_active"; then return 0; fi
    stage 'restoring genuine Shelf campaign archive after fixture-assisted Well path'
    adb shell am force-stop "$package" || return 1
    local suffix name
    for suffix in primary backup temporary; do
        name="$role_save_path"
        [[ "$suffix" != backup ]] || name+=.bak
        [[ "$suffix" != temporary ]] || name+=.tmp
        if [[ -f "$output/role-archive-$suffix.save" ]]; then
            adb shell -T run-as "$package" tee "$name" <"$output/role-archive-$suffix.save" >/dev/null || return 1
            adb exec-out run-as "$package" cat "$name" >"$output/role-restored-$suffix.save" || return 1
            cmp "$output/role-archive-$suffix.save" "$output/role-restored-$suffix.save" || return 1
        else
            adb shell run-as "$package" rm -f "$name" || return 1
        fi
    done
    role_backup_active=false
}
native_role_smoke() {
    local tool_dir suffix name initial_return_count
    tool_dir="$(dirname -- "${BASH_SOURCE[0]}")"
    stage 'fixture-assisted Listening Well hunter path begins; not earned campaign progression'
    "$GODOT_BIN" --headless --path "$GAME_DIR" --script "$TOOLCHAIN_ROOT/scripts/toolchain/native-role-fixture.gd" -- \
        "--output=$output/role-fixture.save" >"$output/role-fixture-generation.txt" 2>&1
    cat "$output/role-fixture-generation.txt"
    grep -q 'fresh_snapshot_equal=true' "$output/role-fixture-generation.txt"
    adb shell input keyevent KEYCODE_HOME
    adb shell am force-stop "$package"
    adb shell run-as "$package" find files -type f -name quietus.save >"$output/role-save-path.txt"
    mapfile -t save_paths < <(tr -d '\r' <"$output/role-save-path.txt")
    (( ${#save_paths[@]} == 1 )) || { echo 'Expected one normal Godot archive path' >&2; return 1; }
    role_save_path="${save_paths[0]}"
    # Keep every interpolated remote argument shell-safe; fail on an unfamiliar path.
    [[ "$role_save_path" =~ ^files/[a-zA-Z0-9_./-]+$ && "$role_save_path" != *..* ]] || {
        echo 'Unsupported archive path; refusing fixture injection' >&2; return 1;
    }
    rm -f "$output/role-archive-primary.save" "$output/role-archive-backup.save" "$output/role-archive-temporary.save"
    for suffix in primary backup temporary; do
        name="$role_save_path"
        [[ "$suffix" != backup ]] || name+=.bak
        [[ "$suffix" != temporary ]] || name+=.tmp
        if adb shell run-as "$package" test -f "$name"; then
            adb exec-out run-as "$package" cat "$name" >"$output/role-archive-$suffix.save"
            sha256sum "$output/role-archive-$suffix.save" >>"$output/role-archive-hashes.txt"
        fi
    done
    test -s "$output/role-archive-primary.save"
    role_backup_active=true
    adb shell run-as "$package" rm -f "$role_save_path.bak" "$role_save_path.tmp"
    adb shell -T run-as "$package" tee "$role_save_path" <"$output/role-fixture.save" >/dev/null
    adb exec-out run-as "$package" cat "$role_save_path" >"$output/role-fixture-installed.save"
    cmp "$output/role-fixture.save" "$output/role-fixture-installed.save"
    sha256sum "$output/role-fixture.save" >"$output/role-fixture-hash.txt"
    launch role-fixture-entry
    tap_target resume 'SS_SCREEN mission paused=true' role-fixture-resume
    tap_target fit 'SS_VIEW zoom=' role-fixture-fit
    tap_target sub 'SS_ORDER select accepted=true selected=0' role-fixture-sub
    tap_target role_observer 'SS_ORDER route accepted=true selected=0' role-observer-route
    read_logcat "$output/role-before-observer.txt"
    local observer_before
    observer_before="$(grep -Ec 'SS_ROLE_ROUTE_READY mission=4' "$output/role-before-observer.txt" || true)"
    tap_target pause 'SS_PAUSE paused=false' role-observer-travel
    wait_new_marker 'SS_ROLE_ROUTE_READY mission=4' "$observer_before" role-observer-ready 90
    tap_target pause 'SS_PAUSE paused=true' role-lure-pause
    read_logcat "$output/role-before-lure.txt"
    initial_return_count="$(grep -Ec 'SS_ROLE mission=4 index=1 type=hunter mode=DORMANT' "$output/role-before-lure.txt" || true)"
    tap_target more_orders 'SS_TARGET decoy ' role-secondary-orders
    tap_target decoy 'SS_DECOY_AIM armed=true selected=0' role-arm-decoy
    tap_target role_decoy 'SS_ORDER decoy accepted=true selected=0' role-ordinary-decoy
    tap_target role_home 'SS_ORDER route accepted=true selected=0' role-silent-withdrawal
    shot inner-role-lure-planned
    tap_target pause 'SS_PAUSE paused=false' role-response-resume
    wait_new_marker 'SS_ROLE mission=4 index=1 type=hunter mode=DORMANT' "$initial_return_count" role-home-return 120
    tap_target pause 'SS_PAUSE paused=true' role-return-pause
    read_logcat "$output/role-response.txt"
    python3 "$tool_dir/android-role.py" "$output/role-response.txt" | tee "$output/role-response.json"
    shot inner-role-return
    local genuine_before
    read_logcat "$output/role-before-genuine-restore.txt"
    genuine_before="$(grep -Ec 'SS_RESTORE ok mission=0 .*completed=\[0\] unlocked=1' "$output/role-before-genuine-restore.txt" || true)"
    restore_role_archive
    launch role-genuine-archive-restored
    wait_new_marker 'SS_RESTORE ok mission=0 .*completed=\[0\] unlocked=1' "$genuine_before" role-genuine-restore 30
    stage 'fixture-assisted Well response passed; genuine Shelf archive restored byte-for-byte'
}
