#!/usr/bin/env bash
# Runtime smoke on an already running emulator/device. Resizing is not Samsung firmware emulation.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
apk="${1:-$ARTIFACT_DIR/sirens-song-debug.apk}"
package=org.sirenssong.game
output="$ARTIFACT_DIR/android-smoke"
mkdir -p "$output"
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
adb install -r "$apk" | tee "$output/install.txt"
component="$(adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$package" | tr -d '\r' | tail -1)"
[[ "$component" == "$package/"* ]] || { echo "No launcher activity resolved: $component" >&2; exit 1; }
printf '%s\n' "$component" | tee "$output/launcher-component.txt"
adb shell getprop ro.build.fingerprint >"$output/fingerprint.txt"
adb shell settings put system accelerometer_rotation 0
# Natural portrait dimensions plus locked landscape produce the requested viewports.
adb shell settings put system user_rotation 1
launch() {
    adb shell am start -W -n "$component" | tee "$output/launch-$1.txt"
    ready=false
    for ((attempt=0; attempt<30; attempt++)); do
        adb logcat -d >"$output/readiness-$1.txt"
        if adb shell pidof "$package" >"$output/pid-$1.txt" && \
            grep -q 'SS_SCREEN' "$output/readiness-$1.txt" && \
            grep -q 'SS_TARGET' "$output/readiness-$1.txt"; then
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
    adb exec-out screencap -p >"$output/$1.png"
    adb shell dumpsys activity activities >"$output/activity-$1.txt"
}
for profile in cover inner; do
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
    adb shell input keyevent KEYCODE_HOME
    sleep 2
    launch "$profile-resume"
    shot "$profile-resume"
    adb shell input keyevent KEYCODE_HOME
    adb shell am kill "$package"
    sleep 2
    if adb shell pidof "$package" >"$output/pid-after-kill-$profile.txt"; then
        echo "Background process survived am kill; lifecycle death not verified" >&2
        exit 1
    fi
    launch "$profile-restart"
    shot "$profile-restart"
done
adb logcat -d >"$output/logcat.txt"
if grep -nE 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:' "$output/logcat.txt"; then
    echo 'Runtime errors detected; inspect logcat artifact' >&2
    exit 1
fi
echo 'Android install, viewports, background/resume and process restart smoke passed.'
echo 'Game-state restoration, touch usability and Samsung fold behavior require further checks.'
