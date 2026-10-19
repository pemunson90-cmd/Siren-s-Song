#!/usr/bin/env bash
# Configure the existing workstation; does not download dependencies.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
"$GODOT_BIN" --headless --editor --path "$GAME_DIR" --quit
settings_root="${XDG_CONFIG_HOME:-$HOME/.config}/godot"
settings_file="$settings_root/editor_settings-4.6.tres"
keystore_file="$TOOLCHAIN_CACHE/debug.keystore"
if [[ ! -f "$keystore_file" ]]; then
    echo 'Signing identity cache miss: creating a NEW development key; update compatibility is not established.'
    "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$keystore_file" -storepass android \
        -alias androiddebugkey -keypass android -dname 'CN=Android Debug,O=Android,C=US' \
        -keyalg RSA -keysize 2048 -validity 10000 >/dev/null
    chmod 600 "$keystore_file"
else
    echo 'Reusing external development signing identity; compare the public certificate for APK update compatibility.'
fi
python3 - "$settings_file" "$JAVA_HOME" "$ANDROID_HOME" "$keystore_file" <<'PY'
import json, pathlib, re, sys
path = pathlib.Path(sys.argv[1])
if not path.exists():
    raise SystemExit(f"Godot did not create editor settings: {path}")
text = path.read_text()
for key, value in zip(
    ('export/android/java_sdk_path', 'export/android/android_sdk_path', 'export/android/debug_keystore'),
    sys.argv[2:],
):
    line = key + ' = ' + json.dumps(value)
    pattern = r'^' + re.escape(key) + r' = .*?$'
    if re.search(pattern, text, re.M):
        text = re.sub(pattern, lambda _: line, text, flags=re.M)
    else:
        text = text.rstrip() + '\n' + line + '\n'
path.write_text(text)
print('Configured Android SDK/JDK and external debug keystore in', path)
PY
