#!/usr/bin/env bash
# Exercise archive restoration's binary integrity/failure path without a device.
set -euo pipefail
source "$(dirname -- "$0")/android-role-smoke.sh"
fixture_dir="$(mktemp -d)"
trap 'rm -rf -- "$fixture_dir"' EXIT
output="$fixture_dir/evidence"
mock_remote="$fixture_dir/remote"
mkdir -p "$output" "$mock_remote/files"
package=test.package
role_save_path=files/quietus.save
stage() { :; }
mock_write_failure=false
adb() {
    local operation="$*"
    if [[ "$operation" == 'shell am force-stop '* ]]; then return 0; fi
    if [[ "$operation" == 'shell -T run-as '* ]]; then
        if "$mock_write_failure"; then return 12; fi
        cat >"$mock_remote/${@: -1}"
    elif [[ "$operation" == 'exec-out run-as '* ]]; then
        cat "$mock_remote/${@: -1}"
    elif [[ "$operation" == 'shell run-as '* ]]; then
        rm -f -- "$mock_remote/${@: -1}"
    else
        echo "Unexpected mock adb operation: $operation" >&2; return 1
    fi
}
# Include NUL and CR/LF; text-only copying would not establish binary fidelity.
printf 'primary\000\377\r\n' >"$output/role-archive-primary.save"
printf 'backup\000\376\r\n' >"$output/role-archive-backup.save"
printf 'stale temporary' >"$mock_remote/$role_save_path.tmp"
role_backup_active=true
restore_role_archive
! "$role_backup_active"
cmp "$output/role-archive-primary.save" "$mock_remote/$role_save_path"
cmp "$output/role-archive-backup.save" "$mock_remote/$role_save_path.bak"
test ! -e "$mock_remote/$role_save_path.tmp"
role_backup_active=true
mock_write_failure=true
if restore_role_archive; then echo 'Failed restoration was falsely accepted' >&2; exit 1; fi
"$role_backup_active"
echo 'Archive restoration: binary primary/backup integrity, absent temporary cleanup, and write-failure propagation pass (mock transport only)'
