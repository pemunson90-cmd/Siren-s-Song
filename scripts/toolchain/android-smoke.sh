#!/usr/bin/env bash
# Runtime smoke on an already running emulator/device. Resizing is not Samsung firmware emulation.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
apk="${1:-$ARTIFACT_DIR/sirens-song-debug.apk}"
package=org.sirenssong.game
output="$ARTIFACT_DIR/android-smoke"
mkdir -p "$output"
stage() {
    echo "SS_SMOKE_STAGE $(date -u +%Y-%m-%dT%H:%M:%SZ) $*" | tee -a "$output/progress.txt"
}
adb_bin="$(command -v adb)"
log_read_serial=0
system_intro_checked=false
source "$(dirname -- "$0")/android-role-smoke.sh"
source "$(dirname -- "$0")/android-menu-smoke.sh"
adb() {
    local status=0
    timeout --foreground "${ADB_TIMEOUT_SECONDS:-30}" "$adb_bin" "$@" || status=$?
    if (( status != 0 )) && [[ "$*" != "shell pidof $package" || "$status" != 1 ]]; then
        echo "ADB status $status: ${1:-} ${2:-}" >&2
    fi
    return "$status"
}
read_logcat() {
    local destination="$1" status=0 read_attempt
    ((log_read_serial+=1))
    local serial="$log_read_serial"
    for ((read_attempt=1; read_attempt<=3; read_attempt++)); do
        status=0
        adb logcat -d >"$destination.attempt-$read_attempt.txt" 2>"$destination.attempt-$read_attempt.stderr.txt" || status=$?
        if (( status == 0 )); then
            cp "$destination.attempt-$read_attempt.txt" "$destination"
            return 0
        fi
        # Repeated readiness polls reuse destination names. Preserve failed reads
        # independently so a later successful poll cannot overwrite their errors.
        cp "$destination.attempt-$read_attempt.txt" "$output/failed-logcat-$serial-attempt-$read_attempt.txt"
        cp "$destination.attempt-$read_attempt.stderr.txt" "$output/failed-logcat-$serial-attempt-$read_attempt.stderr.txt"
        cat "$destination.attempt-$read_attempt.stderr.txt" >&2
        stage "logcat read attempt $read_attempt returned $status; partial output retained"
        if (( status != 255 )); then return "$status"; fi
        sleep 1
    done
    return "$status"
}
capture_runtime_state() {
    local label="$1" status=0
    adb shell sh >"$output/runtime-state-$label.txt" 2>&1 <<'ANDROID' || status=$?
for property in sys.boot_completed sys.boot.reason sys.boot.reason.last ro.boot.bootreason init.svc.zygote init.svc.surfaceflinger; do
    printf '%s=' "$property"
    getprop "$property"
done
printf 'kernel_boot_id='
cat /proc/sys/kernel/random/boot_id
printf 'system_server_pid='
pidof system_server
service check window
service check activity
cat /proc/meminfo
ANDROID
    printf 'Diagnostic adb exit status: %s\n' "$status" >>"$output/runtime-state-$label.txt"
}
stage 'smoke script entered after emulator action boot'
adb wait-for-device
adb get-state | grep -Eq '^device$'
adb logcat -c
cleanup() {
    local exit_status=$?
    if ! restore_role_archive; then echo "Failed to restore preserved genuine archive" >&2; exit_status=1; fi
    if (( exit_status != 0 )); then
        capture_runtime_state failure
        adb shell dumpsys activity exit-info "$package" >"$output/app-exit-info.txt" 2>&1 || true
        adb shell dumpsys dropbox --print system_server_crash >"$output/system-server-crash.txt" 2>&1 || true
        adb shell dumpsys dropbox --print system_server_watchdog >"$output/system-server-watchdog.txt" 2>&1 || true
    fi
    read_logcat "$output/logcat.txt" || true
    # Keep one full final log plus deduplicated engine events in the artifact.
    # All intermediate/partial logs remain on disk for the strict error scan below.
    grep -hE '[Gg]odot|FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:' "$output"/*.txt | sort -u >"$output/godot-events.txt" || true
    adb exec-out screencap -p >"$output/final-display.png" 2>/dev/null || true
    adb shell dumpsys activity activities >"$output/final-activity.txt" 2>/dev/null || true
    echo 'Focused Android runtime diagnostics:'
    grep -E 'FATAL EXCEPTION|AndroidRuntime|Fatal signal|org.sirenssong.game|SCRIPT ERROR|[Gg]odot' "$output/logcat.txt" | tail -120 || true
    adb shell wm size reset >/dev/null 2>&1 || true
    adb shell wm density reset >/dev/null 2>&1 || true
    exit "$exit_status"
}
trap cleanup EXIT
ADB_TIMEOUT_SECONDS=120 adb install -r "$apk" | tee "$output/install.txt"
stage 'APK installed'
capture_runtime_state start
component="$(adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$package" | tr -d '\r' | tail -1)"
[[ "$component" == "$package/"* ]] || { echo "No launcher activity resolved: $component" >&2; exit 1; }
printf '%s\n' "$component" | tee "$output/launcher-component.txt"
adb shell getprop ro.build.fingerprint >"$output/fingerprint.txt"
adb shell settings put system accelerometer_rotation 0
# Natural portrait dimensions plus locked landscape produce the requested viewports.
adb shell settings put system user_rotation 1
adb shell settings put secure immersive_mode_confirmations confirmed
launch() {
    local was_running=false screen_before screen_after target_before target_after
    if adb shell pidof "$package" >/dev/null; then was_running=true; fi
    read_logcat "$output/prelaunch-$1.txt"
    screen_before="$(grep -c 'SS_SCREEN' "$output/prelaunch-$1.txt" || true)"
    target_before="$(grep -c 'SS_TARGET' "$output/prelaunch-$1.txt" || true)"
    # wm size/density changes can restore the display's saved portrait rotation.
    # This suite intentionally tests landscape; lock WindowManager directly.
    adb shell wm user-rotation lock 1
    adb shell wm user-rotation | tee "$output/rotation-$1.txt"
    adb shell am start -W -n "$component" | tee "$output/launch-$1.txt"
    ready=false
    for ((attempt=0; attempt<30; attempt++)); do
        read_logcat "$output/readiness-$1.txt"
        screen_after="$(grep -c 'SS_SCREEN' "$output/readiness-$1.txt" || true)"
        target_after="$(grep -c 'SS_TARGET' "$output/readiness-$1.txt" || true)"
        if adb shell pidof "$package" >"$output/pid-$1.txt" && \
            (( screen_after > 0 && target_after > 0 )) && \
            { "$was_running" || (( screen_after > screen_before && target_after > target_before )); }; then
            ready=true
            break
        fi
        sleep 1
    done
    if ! "$ready"; then
        echo "Game process or screen/layout readiness marker missing after launch: $1" >&2
        return 1
    fi
}
shot() {
    stage "capture $1: screenshot begin"
    adb exec-out screencap -p >"$output/$1.png"
    stage "capture $1: screenshot complete; activity dump begin"
    adb shell dumpsys activity activities >"$output/activity-$1.txt"
    stage "capture $1: activity dump complete"
}
acknowledge_system_intro() {
    local coords="" status=0 tap_x tap_y
    adb shell dumpsys window windows >"$output/system-dialog-window.txt"
    adb shell uiautomator dump /sdcard/sirens-system-ui.xml >"$output/system-dialog-dump.txt"
    adb exec-out cat /sdcard/sirens-system-ui.xml >"$output/system-dialog-before.xml"
    coords="$(python3 "$(dirname -- "$0")/android-system-dialog.py" "$output/system-dialog-before.xml")" || status=$?
    if (( status == 2 )); then return 0; fi
    if (( status != 0 )); then return "$status"; fi
    read -r tap_x tap_y <<<"$coords"
    stage "acknowledging known Android immersive intro at accessibility bounds $tap_x,$tap_y"
    adb shell input tap "$tap_x" "$tap_y"
    adb shell uiautomator dump /sdcard/sirens-system-ui.xml >"$output/system-dialog-after-dump.txt"
    adb exec-out cat /sdcard/sirens-system-ui.xml >"$output/system-dialog-after.xml"
    status=0
    python3 "$(dirname -- "$0")/android-system-dialog.py" "$output/system-dialog-after.xml" >/dev/null || status=$?
    (( status == 2 )) || { echo 'Android immersive intro did not dismiss' >&2; return 1; }
}
locate_target() {
    local action="$1" label="$2"
    target_coords=""
    if ! "$system_intro_checked"; then
        acknowledge_system_intro
        system_intro_checked=true
    fi
    for ((attempt=0; attempt<20; attempt++)); do
        # Android and Godot settle asynchronously after a live resize. Refresh
        # both observations; never reuse a PNG captured before the new layout.
        adb exec-out screencap -p >"$output/target-$label.png"
        read_logcat "$output/target-$label.txt"
        if target_coords="$(python3 "$(dirname -- "$0")/android-target.py" "$output/target-$label.txt" "$output/target-$label.png" "$action")"; then return 0; fi
        sleep 1
    done
    cp "$output/target-$label.png" "$output/failed-target.png"
    echo "No current visible target for $action" >&2
    return 1
}
tap_target() {
    local action="$1" expected="$2" stage="$3"
    local before_count after_count tap_x tap_y
    locate_target "$action" "$stage"
    before_count="$(grep -Ec "$expected" "$output/target-$stage.txt" || true)"
    read -r tap_x tap_y <<<"$target_coords"
    echo "Touch $stage at $tap_x,$tap_y"
    adb shell input tap "$tap_x" "$tap_y"
    for ((attempt=0; attempt<20; attempt++)); do
        read_logcat "$output/interaction-$stage.txt"
        after_count="$(grep -Ec "$expected" "$output/interaction-$stage.txt" || true)"
        if (( after_count > before_count )); then return 0; fi
        if ! adb shell pidof "$package" >/dev/null; then break; fi
        sleep 1
    done
    echo "Touch $stage did not emit expected marker: $expected" >&2
    cp "$output/target-$stage.png" "$output/failed-target.png"
    return 1
}
wait_new_marker() {
    local pattern="$1" before="$2" label="$3" limit="${4:-90}"
    local deadline=$((SECONDS + limit)) count
    while (( SECONDS < deadline )); do
        read_logcat "$output/wait-$label.txt"
        if grep -E 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:|[Ee] godot.*ERROR:' "$output/wait-$label.txt" >"$output/runtime-errors.txt"; then
            cat "$output/runtime-errors.txt" >&2
            echo "Native runtime failure while waiting for $label" >&2
            return 1
        fi
        if ! adb shell pidof "$package" >"$output/pid-wait-$label.txt"; then
            echo "Game process died while waiting for $label" >&2
            return 1
        fi
        count="$(grep -Ec "$pattern" "$output/wait-$label.txt" || true)"
        if (( count > before )); then
            stage "$label: fresh marker verified"
            return 0
        fi
        sleep 1
    done
    echo "Timed out after ${limit}s waiting for $label: $pattern" >&2
    return 1
}
navigation_smoke() {
    local profile="$1" action zoom label pan_x pan_y end_x before_views
    local checker="$(dirname -- "$0")/android-view.py"
    read_logcat "$output/navigation-before-$profile.txt"
    # Verify numerical view state as well as a fresh event for each real button tap.
    for specification in 'zoom_in 1.4 first-in' 'zoom_out 1 overview' 'zoom_in 1.4 second-in' 'zoom_in 1.96 detail'; do
        read -r action zoom label <<<"$specification"
        label="$profile-$label"
        tap_target "$action" 'SS_VIEW zoom=' "$label"
        python3 "$checker" "$output/interaction-$label.txt" --zoom "$zoom" | tee "$output/view-check-$label.txt"
    done
    shot "$profile-zoomed"
    locate_target chart_center "$profile-pan"
    read -r pan_x pan_y <<<"$target_coords"
    end_x="$(python3 - "$output/target-$profile-pan.png" "$pan_x" <<'PY'
import pathlib, struct, sys
width, height = struct.unpack('>II', pathlib.Path(sys.argv[1]).read_bytes()[16:24])
print(max(1, int(sys.argv[2]) - round(min(width, height) * 0.12)))
PY
)"
    before_views="$(grep -c 'SS_VIEW zoom=' "$output/target-$profile-pan.txt" || true)"
    stage "$profile native chart swipe from $pan_x,$pan_y to $end_x,$pan_y"
    adb shell input touchscreen swipe "$pan_x" "$pan_y" "$end_x" "$pan_y" 600
    wait_new_marker 'SS_VIEW zoom=' "$before_views" "$profile-pan" 20
    python3 "$checker" "$output/wait-$profile-pan.txt" --zoom 1.96 --panned-from "$output/target-$profile-pan.txt" | tee "$output/view-check-$profile-pan.txt"
    shot "$profile-panned"
    tap_target fit 'SS_VIEW zoom=' "$profile-fit"
    python3 "$checker" "$output/interaction-$profile-fit.txt" --zoom 1 --center 800 480 | tee "$output/view-check-$profile-fit.txt"
    python3 - "$output/navigation-before-$profile.txt" "$output/interaction-$profile-fit.txt" <<'PY'
import pathlib, sys
before, after = (pathlib.Path(p).read_text(errors='replace') for p in sys.argv[1:])
for marker in ('SS_ORDER ', 'SS_PAUSE paused='):
    assert before.count(marker) == after.count(marker), f'Chart navigation emitted an unintended command/state change: {marker}'
print('Native zoom/pan/FIT produced zero orders and zero pause changes')
PY
    stage "$profile native zoom/pan/FIT verified without accidental orders; OS pinch remains unverified"
}
verify_touch_targets() {
    local profile="$1" page="${2:-primary}" checkpoint="${3:-initial}" status attempt label
    label="$profile-$page-$checkpoint"
    # Enable only with a coherent source that emits the agreed atomic metrics.
    # This adds measurements to the existing run; it does not replace input/lifecycle gates.
    adb shell wm density >"$output/density-$profile.txt"
    for ((attempt=0; attempt<10; attempt++)); do
        read_logcat "$output/ui-metrics-$label.txt"
        shot "$profile-touch-targets-$page-$checkpoint"
        status=0
        python3 "$(dirname -- "$0")/android-ui-metrics.py" "$output/ui-metrics-$label.txt" "$output/$profile-touch-targets-$page-$checkpoint.png" \
            --density "$output/density-$profile.txt" --screen mission --orders-page "$page" >"$output/ui-metrics-$label.json" 2>"$output/ui-metrics-$label.stderr.txt" || status=$?
        if (( status == 0 )); then
            stage "$profile $page actual native hit rectangles meet 48 dp recommendation at observed Android density"
            return 0
        fi
        if (( status != 2 )); then
            cat "$output/ui-metrics-$label.json" "$output/ui-metrics-$label.stderr.txt" >&2
            return "$status"
        fi
        sleep 1
    done
    cat "$output/ui-metrics-$label.stderr.txt" >&2
    echo "No fresh native UI metrics for $profile $page" >&2
    return 1
}
for profile in cover inner; do
    stage "$profile viewport and launch"
    case "$profile" in
        cover) adb shell wm size 1080x2520; expected=2520x1080 ;;
        inner) adb shell wm size 1968x2184; expected=2184x1968 ;;
    esac
    # Keep a known UI density and allow the game to resize without a force-stop between profiles.
    adb shell wm density 420
    launch "$profile"
    shot "$profile"
    python3 - "$output/$profile.png" "$expected" <<'PY'
import pathlib, struct, sys
data = pathlib.Path(sys.argv[1]).read_bytes()
assert data[:8] == b'\x89PNG\r\n\x1a\n', 'Screenshot is not PNG'
actual = '%dx%d' % struct.unpack('>II', data[16:24])
assert actual == sys.argv[2], f'Viewport mismatch: expected {sys.argv[2]}, got {actual}'
print('Verified screenshot viewport', actual)
PY
    if [[ "$profile" == inner ]]; then
        # The prior mission remains alive during the live cover-to-inner resize.
        tap_target menu 'SS_SCREEN operations' "$profile-menu"
    fi
    if [[ "${VERIFY_TOUCH_TARGETS:-0}" == 1 ]]; then menu_touch_smoke "$profile"; fi
    tap_target mission0 'SS_MISSION_SELECT 0' "$profile-mission0"
    tap_target begin 'SS_SCREEN mission paused=true' "$profile-begin"
    navigation_smoke "$profile"
    if [[ "${VERIFY_TOUCH_TARGETS:-0}" == 1 ]]; then
        verify_touch_targets "$profile" primary
        tap_target more_orders 'SS_TARGET recon ' "$profile-secondary-page"
        verify_touch_targets "$profile" secondary
        tap_target more_orders 'SS_TARGET ping ' "$profile-primary-page"
        verify_touch_targets "$profile" primary restored
    fi
    tap_target droneA 'SS_ORDER select accepted=true selected=1' "$profile-drone"
    tap_target sub 'SS_ORDER select accepted=true selected=0' "$profile-sub"
    tap_target route 'SS_ORDER route accepted=true' "$profile-route"
    tap_target pause 'SS_PAUSE paused=false' "$profile-unpause"
    tap_target pause 'SS_PAUSE paused=true' "$profile-pause"
    stage "$profile native mission/order/pause taps verified"
    shot "$profile-gameplay"
    adb shell input keyevent KEYCODE_HOME
    stage "$profile background and resume"
    sleep 2
    launch "$profile-resume"
    shot "$profile-resume"
    adb shell input keyevent KEYCODE_HOME
    stage "$profile waiting for background process termination"
    read_logcat "$output/before-kill-$profile.txt"
    restore_before="$(grep -Ec 'SS_RESTORE ok mission=0' "$output/before-kill-$profile.txt" || true)"
    # am kill only terminates background processes; Android's onStop transition is asynchronous.
    for ((attempt=0; attempt<30; attempt++)); do
        adb shell am kill "$package"
        if ! adb shell pidof "$package" >"$output/pid-after-kill-$profile.txt"; then break; fi
        sleep 1
    done
    if adb shell pidof "$package" >"$output/pid-after-kill-$profile.txt"; then
        echo "Background process survived am kill; lifecycle death not verified" >&2
        exit 1
    fi
    launch "$profile-restart"
    stage "$profile process restarted with screen/layout readiness"
    shot "$profile-restart"
    read_logcat "$output/restoration-$profile.txt"
    restore_after="$(grep -Ec 'SS_RESTORE ok mission=0' "$output/restoration-$profile.txt" || true)"
    (( restore_after > restore_before )) || {
        echo 'Missing actual mission archive restoration marker' >&2; exit 1;
    }
    tap_target resume 'SS_SCREEN mission paused=true' "$profile-restored-mission"
    shot "$profile-restored-gameplay"
    stage "$profile mission archive restored and entered"
done
# Complete the introductory dive through ordinary native input. These markers
# only observe canonical camera/range/outcome/save state; they do not alter it.
stage 'Shelf Signal ordinary-command completion begins'
tap_target menu 'SS_SCREEN operations' 'completion-menu'
tap_target mission0 'SS_MISSION_SELECT 0' 'completion-mission0'
tap_target begin 'SS_SCREEN mission paused=true' 'completion-begin'
tap_target fit 'SS_VIEW zoom=' 'completion-fit'
python3 "$(dirname -- "$0")/android-view.py" "$output/interaction-completion-fit.txt" --zoom 1 --center 800 480 | tee "$output/view-check-completion-fit.txt"
tap_target droneA 'SS_ORDER select accepted=true selected=1' 'completion-drone'
tap_target objective0 'SS_ORDER route accepted=true selected=1' 'completion-approach'
read_logcat "$output/completion-before-run.txt"
camera_before="$(grep -Ec 'SS_CAMERA_READY unit=1 objective=0' "$output/completion-before-run.txt" || true)"
tap_target pause 'SS_PAUSE paused=false' 'completion-travel'
wait_new_marker 'SS_CAMERA_READY unit=1 objective=0' "$camera_before" 'camera-ready' 90
tap_target pause 'SS_PAUSE paused=true' 'completion-camera-pause'
shot 'inner-camera-ready'
tap_target camera 'SS_ORDER camera accepted=true selected=1' 'completion-camera'
shot 'inner-camera-exposure'
read_logcat "$output/completion-before-exposure.txt"
record_before="$(grep -Ec 'SS_OBJECTIVE_RECORDED mission=0 objective=0' "$output/completion-before-exposure.txt" || true)"
won_before="$(grep -Ec 'SS_DEBRIEF outcome=won mission=0' "$output/completion-before-exposure.txt" || true)"
save_pattern='SS_SAVE ok mission=0 .*completed=\[0\] unlocked=1'
save_before="$(grep -Ec "$save_pattern" "$output/completion-before-exposure.txt" || true)"
tap_target pause 'SS_PAUSE paused=false' 'completion-exposure-resume'
wait_new_marker 'SS_OBJECTIVE_RECORDED mission=0 objective=0' "$record_before" 'record-secured' 30
wait_new_marker 'SS_DEBRIEF outcome=won mission=0' "$won_before" 'extraction-won' 30
wait_new_marker "$save_pattern" "$save_before" 'campaign-saved' 30
shot 'inner-mission-completed'
stage 'Shelf Signal recorded, Quietus extraction won, campaign saved'
read_logcat "$output/checkpoint-completed-campaign.txt"
capture_runtime_state before-completed-restart
adb shell dumpsys meminfo "$package" >"$output/app-memory-before-completed-restart.txt" 2>&1 || true
adb shell input keyevent KEYCODE_HOME
read_logcat "$output/completion-before-kill.txt"
campaign_restore='SS_RESTORE ok mission=0 .*completed=\[0\] unlocked=1'
campaign_before="$(grep -Ec "$campaign_restore" "$output/completion-before-kill.txt" || true)"
for ((attempt=0; attempt<30; attempt++)); do
    adb shell am kill "$package"
    if ! adb shell pidof "$package" >"$output/pid-after-kill-completed.txt"; then break; fi
    sleep 1
done
if adb shell pidof "$package" >"$output/pid-after-kill-completed.txt"; then
    echo 'Completed-mission process survived am kill; campaign restoration not verified' >&2
    exit 1
fi
launch 'completed-campaign-restart'
capture_runtime_state after-completed-restart
wait_new_marker "$campaign_restore" "$campaign_before" 'campaign-restored' 30
shot 'inner-campaign-restored'
if [[ "${VERIFY_SIREN_ROLES:-0}" == 1 ]]; then native_role_smoke; fi
read_logcat "$output/logcat.txt"
if grep -lE 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:|[Ee] godot.*ERROR:' "$output"/*.txt; then
    grep -hE 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:|[Ee] godot.*ERROR:' "$output"/*.txt | sort -u >"$output/runtime-errors.txt"
    cat "$output/runtime-errors.txt"
    echo 'Runtime errors detected; inspect logcat artifact' >&2
    exit 1
fi
echo 'Android install, native taps/orders/pause, viewports, mission restore and ordinary-command mission completion smoke passed.'
stage 'smoke passed'
echo 'Touch ergonomics, full mission-state fidelity and Samsung fold behavior require further checks.'
