#!/usr/bin/env python3
"""Git-level guard for autonomous runs.

The PreToolUse guard reads the commands Claude writes. This script runs inside
git itself, so it also catches git operations started by scripts, build tools
and subagents. The bootstrap installs small wrappers in the clone's shared
hooks directory (.git/hooks, used by every worktree) that call it:

  pre-commit             refuses commits that delete tracked files (moves into
                         _scrap-* are fine), and commits that add key material
                         other than the listed development keystore.
  pre-push               refuses pushes to refs outside fable/, ref deletions
                         and non-fast-forward updates.
  reference-transaction  refuses local deletion of fable/ branches and of tags.

A hook refuses by exiting non-zero with a message on stderr. git --no-verify
skips pre-commit and pre-push; the PreToolUse guard blocks that flag.
"""
import os
import re
import subprocess
import sys

ZERO = "0" * 40
PUSH_PREFIXES = ("refs/heads/fable/", "refs/tags/fable/")
SCRAP_RE = re.compile(r"^_scrap-[0-9]{8}/")
ALLOWED_KEYS = {"scripts/toolchain/signing/sirens-song-debug.keystore"}
KEY_NAME_RE = re.compile(
    r"(?i)(\.(keystore|jks|p12|pfx|pk8|pem|key|der)$|(^|/)(keystore|signing|release)[^/]*\.properties$|(^|/)\.env(\.|$))"
)
KEY_TEXT_RE = re.compile(rb"-----BEGIN (?:RSA |EC |OPENSSH |ENCRYPTED |DSA )?PRIVATE KEY-----")


def git(*args, inp=None):
    return subprocess.run(["git", *args], input=inp, capture_output=True, timeout=60)


def refuse(msg):
    sys.stderr.write("run git guard: " + msg + "\n")
    sys.exit(1)


def pre_commit():
    out = git("diff", "--cached", "--name-status", "-M", "-z").stdout.decode("utf-8", "replace")
    parts = [p for p in out.split("\0") if p]
    i, deleted, added = 0, [], []
    while i < len(parts):
        status = parts[i]
        if status[0] in "RC":
            src, dst = parts[i + 1], parts[i + 2]
            i += 3
            if status[0] == "R" and SCRAP_RE.match(src) and not SCRAP_RE.match(dst):
                pass  # restoring from scrap is fine
            added.append(dst)
        else:
            path = parts[i + 1]
            i += 2
            if status == "D":
                deleted.append(path)
            elif status[0] in "AM":
                added.append(path)
    if deleted:
        refuse(
            "this commit deletes tracked files: " + ", ".join(deleted[:20])
            + (" ..." if len(deleted) > 20 else "")
            + ". Move them with git mv into the _scrap-<date>/ folder and add a manifest row, "
            "or restore them with git restore --staged --worktree --source=HEAD -- <path>."
        )
    bad = []
    for path in added:
        if path in ALLOWED_KEYS:
            continue
        if KEY_NAME_RE.search(path):
            bad.append(path)
            continue
        blob = git("show", ":" + path).stdout
        if KEY_TEXT_RE.search(blob[:200000]):
            bad.append(path)
    if bad:
        refuse(
            "this commit adds key material or secrets: " + ", ".join(bad)
            + ". Private and release keys stay outside the repository; Pat provides them when needed. "
            "Unstage with git restore --staged -- <path>."
        )


def pre_push():
    for line in sys.stdin.read().splitlines():
        fields = line.split()
        if len(fields) != 4:
            continue
        local_ref, local_sha, remote_ref, remote_sha = fields
        if not remote_ref.startswith(PUSH_PREFIXES):
            refuse("push to " + remote_ref + " refused; runs push only under fable/")
        if local_sha == ZERO:
            refuse("deleting " + remote_ref + " refused; runs never remove refs")
        if remote_sha != ZERO and remote_ref.startswith("refs/heads/"):
            known = git("cat-file", "-e", remote_sha + "^{commit}").returncode == 0
            if not known or git("merge-base", "--is-ancestor", remote_sha, local_sha).returncode != 0:
                refuse(
                    "non-fast-forward update of " + remote_ref + " refused. Fetch, merge the remote "
                    "tip into your branch, and push again."
                )


def reference_transaction(state):
    if state != "prepared":
        return
    for line in sys.stdin.read().splitlines():
        fields = line.split()
        if len(fields) != 3:
            continue
        old, new, ref = fields
        if new == ZERO and (ref.startswith("refs/heads/fable/") or ref.startswith("refs/tags/")):
            refuse("deleting " + ref + " refused; runs never remove their own branches or any tag")


def main():
    if len(sys.argv) < 2:
        refuse("missing hook name")
    hook = sys.argv[1]
    if hook == "pre-commit":
        pre_commit()
    elif hook == "pre-push":
        pre_push()
    elif hook == "reference-transaction":
        reference_transaction(sys.argv[2] if len(sys.argv) > 2 else "")
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as exc:  # fail closed
        sys.stderr.write("run git guard internal error, operation refused: %r\n" % (exc,))
        sys.exit(1)
