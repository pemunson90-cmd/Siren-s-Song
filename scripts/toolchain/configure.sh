#!/usr/bin/env bash
# Configure the existing workstation; does not download dependencies.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
require_project
keystore_file="$TOOLCHAIN_ROOT/scripts/toolchain/signing/sirens-song-debug.keystore"
fingerprint_file="$TOOLCHAIN_ROOT/scripts/toolchain/signing/sirens-song-debug.certificate.sha256"
if [[ ! -f "$keystore_file" || ! -f "$fingerprint_file" ]]; then
    echo 'Missing canonical versioned debug signing identity or certificate fingerprint; restore the tracked files. No key will be generated.' >&2
    exit 1
fi
expected_certificate_sha256="$(tr -d '[:space:]' < "$fingerprint_file")"
if [[ ! "$expected_certificate_sha256" =~ ^[0-9a-f]{64}$ ]]; then
    echo 'Invalid canonical debug certificate fingerprint; configuration stopped.' >&2
    exit 1
fi
if ! certificate_sha256="$("$JAVA_HOME/bin/keytool" -exportcert -keystore "$keystore_file" -storepass android -alias androiddebugkey | sha256sum | awk '{print $1}')"; then
    echo 'Cannot read canonical debug signing certificate; configuration stopped without generating a key.' >&2
    exit 1
fi
if [[ "$certificate_sha256" != "$expected_certificate_sha256" ]]; then
    echo "Canonical debug certificate mismatch: expected $expected_certificate_sha256, got $certificate_sha256; configuration stopped." >&2
    exit 1
fi
echo "Reusing versioned debug signing identity; public certificate SHA256: $certificate_sha256"
"$GODOT_BIN" --headless --editor --path "$GAME_DIR" --quit
settings_root="${XDG_CONFIG_HOME:-$HOME/.config}/godot"
settings_file="$settings_root/editor_settings-4.6.tres"
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
print('Configured Android SDK/JDK and canonical versioned debug keystore in', path)
PY
