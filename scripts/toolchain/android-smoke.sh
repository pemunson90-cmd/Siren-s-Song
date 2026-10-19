#!/usr/bin/env bash
# Runtime smoke on an already running emulator/device. Resizing is not Samsung firmware emulation.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
apk="${1:-$ARTIFACT_DIR/sirens-song-debug.apk}"
package=org.sirenssong.game
output="$ARTIFACT_DIR/android-smoke"
mkdir -p "$output"
adb wait-for-device
adb get-state | rg -q '^device$'
adb logcat -c
cleanup() {
    adb logcat -d >"$output/logcat.txt" 2>&1 || true
    adb shell wm size reset >/dev/null 2>&1 || true
    adb shell wm density reset >/dev/null 2>&1 || true
}
trap cleanup EXIT
adb install -r "$apk" | tee "$output/install.txt"
adb shell getprop ro.build.fingerprint >"$output/fingerprint.txt"
adb shell settings put system accelerometer_rotation 0
# Natural portrait dimensions plus locked landscape produce the requested viewports.
adb shell settings put system user_rotation 1
launch() {
    adb shell monkey -p "$package" -c android.intent.category.LAUNCHER 1 >"$output/launch-$1.txt"
    sleep 4
    adb shell pidof "$package" | tee "$output/pid-$1.txt" | rg -q '[0-9]'
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
if rg -n 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:' "$output/logcat.txt"; then
    echo 'Runtime errors detected; inspect logcat artifact' >&2
    exit 1
fi
echo 'Android install, viewports, background/resume and process restart smoke passed.'
echo 'Game-state restoration, touch usability and Samsung fold behavior require further checks.'
