#!/usr/bin/env python3
"""PostToolUse hook: undoes tracked-file deletions made by any shell command.

After each Bash or PowerShell call, this checks the main clone and every
worktree for tracked files that are missing. A missing file that reappears
elsewhere with identical content (a plain mv) is treated as a move and left
alone. Anything else is restored from the index (or from HEAD when the
deletion was staged), and Claude is told what happened and why.

This catches deletions made inside scripts, which the PreToolUse guard cannot
see. Restoring is non-destructive: it only brings files back.
"""
import os
import subprocess
import sys

LIMIT_HASH = 3000


def git(cwd, *args):
    return subprocess.run(["git", "-C", cwd, *args], capture_output=True, text=True, timeout=60)


def worktrees(project):
    out = git(project, "worktree", "list", "--porcelain").stdout
    found = [l[len("worktree "):].strip() for l in out.splitlines() if l.startswith("worktree ")]
    return found or [project]


def check(root):
    status = git(root, "status", "--porcelain=v1", "-z", "--untracked-files=all").stdout
    entries = [e for e in status.split("\0") if e]
    deleted, untracked = [], []
    i = 0
    while i < len(entries):
        e = entries[i]
        code, path = e[:2], e[3:]
        if code[0] in "RC":
            i += 2
            continue
        if code == "??":
            untracked.append(path)
        elif "D" in code:
            deleted.append((code, path))
        i += 1
    if not deleted:
        return []
    untracked_hashes = {}
    if untracked and len(untracked) <= LIMIT_HASH:
        res = subprocess.run(
            ["git", "-C", root, "hash-object", "--stdin-paths"],
            input="\n".join(untracked), capture_output=True, text=True, timeout=120,
        )
        for p, h in zip(untracked, res.stdout.split()):
            untracked_hashes.setdefault(h, p)
    restored = []
    for code, path in deleted:
        source = "HEAD" if code[0] == "D" else None
        spec = ("HEAD:" if source else ":") + path
        blob = git(root, "rev-parse", "--verify", "--quiet", spec).stdout.strip()
        if blob and blob in untracked_hashes:
            continue  # moved, not deleted
        if source:
            git(root, "restore", "--source=HEAD", "--staged", "--worktree", "--", path)
        else:
            git(root, "restore", "--worktree", "--", path)
        restored.append(os.path.join(root, path))
    return restored


def main():
    try:
        sys.stdin.read()
    except Exception:
        pass
    project = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    restored = []
    for root in worktrees(project):
        if os.path.isdir(root):
            restored += check(root)
    if restored:
        sys.stderr.write(
            "Run deletion check: the last command deleted tracked files, so they were restored: "
            + ", ".join(restored[:20]) + (" ..." if len(restored) > 20 else "")
            + ". Removal in this run means git mv into the _scrap-<date>/ folder with a manifest "
            "row (FABLE_RUN.md section 6.2). If a script you wrote deleted them, change the script.\n"
        )
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
