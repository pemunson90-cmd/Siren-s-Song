#!/usr/bin/env bash
# Install the pinned official editor and prebuilt Android templates into a user cache.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
version=4.6.3
downloads="$TOOLCHAIN_CACHE/downloads"
mkdir -p "$downloads" "$TOOLCHAIN_CACHE/bin"
base="https://github.com/godotengine/godot/releases/download/$version-stable"
editor="Godot_v$version-stable_linux.x86_64.zip"
templates="Godot_v$version-stable_export_templates.tpz"
fetch() {
    local name="$1"
    if [[ ! -s "$downloads/$name" ]]; then
        curl --fail --location --retry 2 --silent --show-error "$base/$name" -o "$downloads/$name.partial"
        mv "$downloads/$name.partial" "$downloads/$name"
    fi
}
fetch "$editor"
fetch "$templates"
python3 - "$downloads" "$TOOLCHAIN_CACHE/bin" <<'PY'
import hashlib, os, pathlib, shutil, sys, zipfile
downloads, bin_dir = map(pathlib.Path, sys.argv[1:])
pins = {
    'Godot_v4.6.3-stable_linux.x86_64.zip': 'a035258da32b77f966a5376f9fa29c30a6adde826a85ba918e1605bd1fc9823eba7d85f1dd5e748956bd2ba72827c0025ffa11bb82aec91128c407a2e723c99c',
    'Godot_v4.6.3-stable_export_templates.tpz': 'da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68',
}
template_root = pathlib.Path(os.environ.get('XDG_DATA_HOME', str(pathlib.Path.home()/'.local/share')))/'godot/export_templates/4.6.3.stable'
template_root.mkdir(parents=True, exist_ok=True)
for name, expected in pins.items():
    archive = downloads/name
    with archive.open('rb') as handle:
        actual = hashlib.file_digest(handle, 'sha512').hexdigest()
    if actual != expected:
        raise SystemExit('SHA512 mismatch: '+name)
    with zipfile.ZipFile(archive) as z:
        for entry in z.infolist():
            leaf = pathlib.PurePosixPath(entry.filename).name
            if name.endswith('.tpz'):
                if leaf not in {'android_debug.apk', 'android_release.apk', 'version.txt'}:
                    continue
                dest = template_root/leaf
            else:
                if leaf != 'Godot_v4.6.3-stable_linux.x86_64':
                    continue
                dest = bin_dir/'godot'
            with z.open(entry) as src, dest.open('wb') as dst:
                shutil.copyfileobj(src, dst)
            if dest.name == 'godot':
                dest.chmod(0o755)
print('Verified official Godot editor and Android templates at', bin_dir, template_root)
PY
"$TOOLCHAIN_CACHE/bin/godot" --version
