#!/usr/bin/env bash
# Actual Godot GUI/target trace; no device/OS-input or campaign-progression claim.
set -euo pipefail
source "$(dirname -- "$0")/common.sh"
bash -n "$TOOLCHAIN_ROOT/scripts/toolchain/android-role-smoke.sh"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
XDG_DATA_HOME="$test_dir/userdata" "$GODOT_BIN" --headless --path "$GAME_DIR" --script res://tests/probe_native_roles.gd >"$test_dir/role.txt" 2>&1 || { cat "$test_dir/role.txt"; exit 1; }
cat "$test_dir/role.txt"
python3 - "$test_dir/role.txt" "$TOOLCHAIN_ROOT/scripts/toolchain/android-role-smoke.sh" <<'CHECK'
import pathlib,re,sys
text=pathlib.Path(sys.argv[1]).read_text()
arm=text.index('SS_DECOY_AIM armed=true selected=0')
target=re.search(r'SS_TARGET role_decoy center=(\d+),(\d+) viewport=(\d+),(\d+)',text[arm:])
assert target,'No fresh own-deployment target after arm'
x,y,w,h=map(int,target.groups());assert 0<=x<w and 0<=y<h
launch=text.index('SS_ORDER decoy accepted=true selected=0',arm)
assert arm+target.end()<launch
assert 'ROLE_PROTOCOL decoy_count=2 ok=true' in text
assert not any(s in text for s in ('SCRIPT ERROR','FAIL','ERROR:'))
script=pathlib.Path(sys.argv[2]).read_text()
assert script.index("tap_target decoy 'SS_DECOY_AIM armed=true selected=0'")<script.index("tap_target role_decoy 'SS_ORDER decoy accepted=true selected=0'")
print('Decoy native adapter: actual GUI arm, fresh own target, one launch, finite real-hearing return pass; no native claim')
CHECK
