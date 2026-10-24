#!/usr/bin/env python3
"""Opt-in, non-destructive shared Git hooks; installer never runs on import."""
import hashlib, os, pathlib, shlex, subprocess, sys
import importlib.util
SOURCE=pathlib.Path(__file__).with_name('gauntlet-boundary.py')
spec=importlib.util.spec_from_file_location('boundary',SOURCE);boundary=importlib.util.module_from_spec(spec);spec.loader.exec_module(boundary)
MARKER='# Managed by Siren\'s Song gauntlet-boundary v1'
HOOKS=('post-commit','post-checkout','pre-merge-commit','pre-push')
def main():
    try:
        configured=subprocess.run(['git','config','--get','core.hooksPath'],capture_output=True,timeout=10)
        if configured.returncode==0:raise ValueError('core.hooksPath is configured; refusing to change it')
        if configured.returncode!=1:raise ValueError('cannot inspect core.hooksPath')
        common=pathlib.Path(boundary.command(['git','rev-parse','--path-format=absolute','--git-common-dir']).decode().strip());hooks=common/'hooks'
        for name in HOOKS:
            path=hooks/name
            if path.is_symlink() or (path.exists() and (not path.is_file() or MARKER not in path.read_text().splitlines()[:2])):raise ValueError('unmanaged hook preserved: '+name)
        data=SOURCE.read_bytes();version=hashlib.sha256(data).hexdigest();helper=common/'gauntlet-boundary/helpers'/version/SOURCE.name
        if helper.exists() and helper.read_bytes()!=data:raise ValueError('versioned helper mismatch')
        boundary.atomic(helper,data)
        for name in HOOKS:
            script='#!/bin/sh\n'+MARKER+'\nexec '+shlex.quote(pathlib.Path(sys.executable).as_posix())+' '+shlex.quote(helper.as_posix())+' --boundary '+name+' "$@"\n'
            boundary.atomic(hooks/name,script.encode());os.chmod(hooks/name,0o755)
        print('Installed four managed hooks; helper '+str(helper));return 0
    except (ValueError,RuntimeError,OSError,subprocess.TimeoutExpired) as error:
        print('Hooks not installed: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
