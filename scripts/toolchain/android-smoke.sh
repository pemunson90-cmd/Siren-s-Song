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
adb() {
    local status=0
    timeout --foreground "${ADB_TIMEOUT_SECONDS:-30}" "$adb_bin" "$@" || status=$?
    if (( status != 0 )) && [[ "$*" != "shell pidof $package" || "$status" != 1 ]]; then
        echo "ADB status $status: ${1:-} ${2:-}" >&2
    fi
    return "$status"
}
stage 'smoke script entered after emulator action boot'
adb wait-for-device
adb get-state | grep -Eq '^device$'
adb logcat -c
cleanup() {
    adb logcat -d >"$output/logcat.txt" 2>&1 || true
    adb exec-out screencap -p >"$output/final-display.png" 2>/dev/null || true
    adb shell dumpsys activity activities >"$output/final-activity.txt" 2>/dev/null || true
    echo 'Focused Android runtime diagnostics:'
    grep -E 'FATAL EXCEPTION|AndroidRuntime|Fatal signal|org.sirenssong.game|SCRIPT ERROR|[Gg]odot' "$output/logcat.txt" | tail -120 || true
    adb shell wm size reset >/dev/null 2>&1 || true
    adb shell wm density reset >/dev/null 2>&1 || true
}
trap cleanup EXIT
ADB_TIMEOUT_SECONDS=120 adb install -r "$apk" | tee "$output/install.txt"
stage 'APK installed'
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
    adb logcat -d >"$output/prelaunch-$1.txt"
    screen_before="$(grep -c 'SS_SCREEN' "$output/prelaunch-$1.txt" || true)"
    target_before="$(grep -c 'SS_TARGET' "$output/prelaunch-$1.txt" || true)"
    adb shell am start -W -n "$component" | tee "$output/launch-$1.txt"
    ready=false
    for ((attempt=0; attempt<30; attempt++)); do
        adb logcat -d >"$output/readiness-$1.txt"
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
tap_target() {
    local action="$1" expected="$2" stage="$3" coords=""
    local before_count after_count
    adb exec-out screencap -p >"$output/target-$stage.png"
    for ((attempt=0; attempt<20; attempt++)); do
        adb logcat -d >"$output/target-$stage.txt"
        if coords="$(python3 "$(dirname -- "$0")/android-target.py" "$output/target-$stage.txt" "$output/target-$stage.png" "$action")"; then break; fi
        sleep 1
    done
    [[ -n "$coords" ]] || { cp "$output/target-$stage.png" "$output/failed-target.png"; echo "No current visible target for $action" >&2; return 1; }
    before_count="$(grep -Ec "$expected" "$output/target-$stage.txt" || true)"
    read -r tap_x tap_y <<<"$coords"
    echo "Touch $stage at $tap_x,$tap_y"
    adb shell input tap "$tap_x" "$tap_y"
    for ((attempt=0; attempt<20; attempt++)); do
        adb logcat -d >"$output/interaction-$stage.txt"
        after_count="$(grep -Ec "$expected" "$output/interaction-$stage.txt" || true)"
        if (( after_count > before_count )); then return 0; fi
        if ! adb shell pidof "$package" >/dev/null; then break; fi
        sleep 1
    done
    echo "Touch $stage did not emit expected marker: $expected" >&2
    cp "$output/target-$stage.png" "$output/failed-target.png"
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
    tap_target mission0 'SS_MISSION_SELECT 0' "$profile-mission0"
    tap_target begin 'SS_SCREEN mission paused=true' "$profile-begin"
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
    adb logcat -d >"$output/before-kill-$profile.txt"
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
    adb logcat -d >"$output/restoration-$profile.txt"
    restore_after="$(grep -Ec 'SS_RESTORE ok mission=0' "$output/restoration-$profile.txt" || true)"
    (( restore_after > restore_before )) || {
        echo 'Missing actual mission archive restoration marker' >&2; exit 1;
    }
    tap_target resume 'SS_SCREEN mission paused=true' "$profile-restored-mission"
    shot "$profile-restored-gameplay"
    stage "$profile mission archive restored and entered"
done
adb logcat -d >"$output/logcat.txt"
if grep -nE 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:|[Ee] godot.*ERROR:' "$output/logcat.txt"; then
    echo 'Runtime errors detected; inspect logcat artifact' >&2
    exit 1
fi
echo 'Android install, native taps/orders/pause, viewports and mission restore smoke passed.'
stage 'smoke passed'
echo 'Touch ergonomics, full mission-state fidelity and Samsung fold behavior require further checks.'
