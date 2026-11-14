#!/usr/bin/env python3
"""PreToolUse guard for autonomous runs.

Reads the hook event from stdin. Prints a deny decision as JSON and exits 0
when a call breaks a rule. Exits 0 with no output when the call is fine, so the
normal permission flow applies. Exits 2 on an internal error, so a broken guard
blocks the call instead of letting it through.

Rules, and why each exists:
  * Pushes may only write refs under fable/ (branches or tags). Shared branches
    (main, integration, production, handoffs) belong to Pat's promotion flow.
  * No force push, ref deletion, history rewrite or object pruning. These are
    the operations that can lose work on GitHub or in the local object store.
  * No file deletion. Pat's only sanctioned removal route is moving files into
    the scrap folder (git mv), which keeps them recoverable.
  * No edits to the guard, the hook settings, the run charter or the signing
    key. A run must not be able to loosen its own constraints.
  * No edits outside this repository and its git worktrees.
  * No repository-administration commands through gh, and no PR merges. Pat
    merges the final PR.

The guard reads the command text Claude writes. A script file that deletes
things internally is invisible to it. The charter covers that case by rule.
"""
import json
import os
import re
import shlex
import subprocess
import sys

PROTECTED_REL = (
    ".claude/settings.json",
    ".claude/settings.local.json",
    ".claude/hooks/",
    ".claude/agents/",
    ".fable/FABLE_RUN.md",
    ".fable/TARGET.md",
    "scripts/toolchain/signing/",
    ".git/",
)
PROTECTED_TEXT = (
    ".claude/hooks",
    ".claude/settings",
    ".claude/agents",
    ".fable/FABLE_RUN.md",
    ".fable/TARGET.md",
    "scripts/toolchain/signing",
    ".git/hooks",
)
PUSH_REF_PREFIX = "fable/"
PUSH_OK_FLAGS = {
    "-u", "--set-upstream", "--dry-run", "-n", "-q", "--quiet",
    "-v", "--verbose", "--progress", "--porcelain", "--no-progress",
}

SEP = r"(?:^|[\s;&|()`'\"{}$])"
DELETE_PATTERNS = [
    (SEP + r"(?:rm|rmdir|unlink|shred|srm|trash|del|erase|rd)(?=\s|$)", "file deletion"),
    (r"(?i)" + SEP + r"(?:remove-item|ri|clear-recyclebin)(?=\s|$)", "file deletion (PowerShell)"),
    (r"\s-delete(?=\s|$)", "find -delete"),
    (r"shutil\.rmtree|os\.(?:remove|unlink|rmdir|removedirs)\s*\(|\.unlink\s*\(|\.rmdir\s*\(", "file deletion inside inline code"),
    (r"(?i)\[System\.IO\.(?:File|Directory)\]::Delete", "file deletion (.NET)"),
]
GIT_PATTERNS = [
    (r"\bgit\b[^\n;&|]*\sclean\b", "git clean deletes untracked files"),
    (r"\bgit\b[^\n;&|]*\sreset\s+[^\n;&|]*--hard", "git reset --hard discards work; use git revert or a new branch"),
    (r"\bgit\b[^\n;&|]*\sreset\s+--hard", "git reset --hard discards work; use git revert or a new branch"),
    (r"\bgit\b[^\n;&|]*\scheckout\s+(?:-f|--force)\b", "forced checkout discards work"),
    (r"\bgit\b[^\n;&|]*\s(?:checkout|restore)\s+(?:--\s+)?\.(?=\s|$)", "discarding the whole working tree"),
    (r"\bgit\b[^\n;&|]*\sstash\s+(?:drop|clear)\b", "dropping stashes loses work"),
    (r"\bgit\b[^\n;&|]*\sbranch\s+[^\n;&|]*(?:-D|-d|--delete)\b", "branch deletion; the run never removes refs"),
    (r"\bgit\b[^\n;&|]*\stag\s+[^\n;&|]*(?:-d|--delete)\b", "tag deletion; the run never removes refs"),
    (r"\bgit\b[^\n;&|]*\supdate-ref\s+[^\n;&|]*-d\b", "ref deletion"),
    (r"\bgit\b[^\n;&|]*\s(?:filter-branch|filter-repo|replace)\b", "history rewrite"),
    (r"\bgit\b[^\n;&|]*\sreflog\s+(?:expire|delete)\b", "reflog pruning removes recovery points"),
    (r"\bgit\b[^\n;&|]*\sgc\b[^\n;&|]*--prune", "object pruning removes recovery points"),
    (r"\bgit\b[^\n;&|]*\sprune\b", "object pruning removes recovery points"),
    (r"\bgit\b[^\n;&|]*\sworktree\s+(?:remove|prune)\b[^\n;&|]*(?:-f|--force)", "forced worktree removal discards work"),
    (r"\bgit\b[^\n;&|]*\sconfig\b[^\n;&|]*\balias\.", "git aliases can hide guarded commands"),
]
GH_PATTERNS = [
    (r"\bgh\s+repo\s+(?:delete|archive|unarchive|edit|rename|transfer|sync)\b", "repository administration is Pat's"),
    (r"\bgh\s+release\s+(?:delete|delete-asset|edit)\b", "release changes are Pat's"),
    (r"\bgh\s+pr\s+(?:merge|close)\b", "Pat merges or closes PRs"),
    (r"\bgh\s+(?:branch|ruleset|secret|variable)\b", "repository settings are Pat's"),
    (r"\bgh\s+api\b[^\n;&|]*(?:-X|--method)\s*(?:DELETE|PUT|PATCH)\b", "write-method API calls change repository state"),
    (r"\bgh\s+api\b[^\n;&|]*/(?:protection|rulesets|collaborators|hooks|keys|secrets)\b", "repository settings are Pat's"),
]
MISC_PATTERNS = [
    (r"--no-verify\b", "skipping the run's git hooks"),
    (r"\bgit\b[^\n;&|]*\scommit\b[^\n;&|]*\s-[a-zA-Z]*n[a-zA-Z]*(?=\s|$)", "git commit -n skips the run's git hooks"),
    (r"(?i)core\.hookspath", "changing the hooks path disables the run's git hooks"),
    (r"(?:curl|wget|iwr|invoke-webrequest)\b[^\n]*\|\s*(?:sh|bash|zsh|iex|invoke-expression|python3?|py)\b", "piping downloaded code into an interpreter"),
    (r"\bkeytool\b[^\n;&|]*-(?:genkey|genkeypair|delete|changealias|storepasswd|keypasswd)\b", "the signing identity is fixed"),
    (r"(?i)\bformat-volume\b|\bdiskpart\b|\bmkfs\b|\bdd\s+if=", "disk-level command"),
]
WRITE_OPS = re.compile(
    r"(?i)(?:>|\btee\b|\bsed\s+-i|\bmv\b|\bcp\b|\bset-content\b|\badd-content\b|"
    r"\bout-file\b|\bmove-item\b|\bcopy-item\b|\brename-item\b|\btruncate\b|"
    r"\bgit\s+(?:mv|checkout|restore)\b|\bln\b|\bchmod\b|\battrib\b)"
)


def deny(reason):
    out = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "Run guard blocked this: " + reason + ". If the text only mentions a "
                "guarded word (for example inside a commit message), write the message "
                "to a file and use git commit -F. If the action is genuinely needed, "
                "record it in .fable/DECISIONS.md for Pat and continue other work."
            ),
        }
    }
    print(json.dumps(out))
    sys.exit(0)


def norm(path):
    if not path:
        return ""
    p = path.replace("\\", "/")
    m = re.match(r"^/([a-zA-Z])/(.*)$", p)
    if m and os.name == "nt":
        p = m.group(1) + ":/" + m.group(2)
    return os.path.normcase(os.path.realpath(p)).replace("\\", "/")


def roots(project):
    found = [norm(project)]
    try:
        out = subprocess.run(
            ["git", "-C", project, "worktree", "list", "--porcelain"],
            capture_output=True, text=True, timeout=15,
        ).stdout
        for line in out.splitlines():
            if line.startswith("worktree "):
                found.append(norm(line[len("worktree "):].strip()))
    except Exception:
        pass
    return [r for r in found if r]


def under(path, root):
    return path == root or path.startswith(root.rstrip("/") + "/")


def check_path(path, cwd, project):
    if not path:
        return
    full = path if os.path.isabs(path) or re.match(r"^[a-zA-Z]:[\\/]", path) else os.path.join(cwd or project, path)
    p = norm(full)
    rts = roots(project)
    matches = [r for r in rts if under(p, r)]
    owner = max(matches, key=len) if matches else None
    if owner is None:
        deny("edits outside this repository and its worktrees (" + path + ")")
    rel = p[len(owner):].lstrip("/")
    for prot in PROTECTED_REL:
        if rel == prot.rstrip("/") or rel.startswith(prot):
            deny("protected path " + rel)


def segments(cmd):
    return [s for s in re.split(r"&&|\|\||;|\n|(?<!\|)\|(?!\|)", cmd) if s.strip()]


def check_push(seg):
    m = re.search(r"\bgit\b((?:\s+-C\s+\S+|\s+-c\s+\S+|\s+--git-dir(?:=|\s+)\S+|\s+--work-tree(?:=|\s+)\S+)*)\s+push\b(.*)$", seg, re.S)
    if not m:
        return
    tail = re.sub(r"\s\d*>&\d", " ", m.group(2))
    tail = re.sub(r"\s(?:\d|&)?>{1,2}\s*\S+", " ", tail)
    tail = re.sub(r"\s<\s*\S+", " ", tail)
    try:
        args = shlex.split(tail, posix=True)
    except ValueError:
        deny("unparseable git push; write it as git push origin <src>:fable/<name>")
    positional = []
    for a in args:
        if a.startswith("-"):
            if a not in PUSH_OK_FLAGS:
                deny("git push flag " + a + " is not allowed in a run")
        else:
            positional.append(a)
    if len(positional) < 2:
        deny("git push must name the remote and an explicit refspec ending in fable/<name>")
    remote, refspecs = positional[0], positional[1:]
    if remote != "origin":
        deny("pushes go to origin only")
    for spec in refspecs:
        if spec.startswith("+") or spec.startswith(":") or "*" in spec:
            deny("forced, deleting or wildcard refspec " + spec)
        dst = spec.split(":", 1)[1] if ":" in spec else spec
        if dst.startswith("refs/tags/"):
            name = dst[len("refs/tags/"):]
        elif dst.startswith("refs/heads/"):
            name = dst[len("refs/heads/"):]
        elif dst.startswith("refs/"):
            deny("push to non-branch ref " + dst)
        else:
            name = dst
        if not name.startswith(PUSH_REF_PREFIX):
            deny("push target " + dst + " is outside fable/; shared branches are Pat's")


def check_command(cmd):
    text = cmd or ""
    for pat, why in DELETE_PATTERNS + GIT_PATTERNS + GH_PATTERNS + MISC_PATTERNS:
        if re.search(pat, text):
            deny(why)
    for seg in segments(text):
        if re.search(r"\bpush\b", seg) and re.search(r"\bgit\b", seg):
            check_push(seg)
        low = seg.replace("\\", "/")
        if any(t in low for t in PROTECTED_TEXT) and WRITE_OPS.search(low):
            deny("writing to a protected path through the shell")


def main():
    raw = sys.stdin.read()
    event = json.loads(raw) if raw.strip() else {}
    tool = event.get("tool_name", "")
    tin = event.get("tool_input", {}) or {}
    cwd = event.get("cwd") or os.getcwd()
    project = os.environ.get("CLAUDE_PROJECT_DIR") or cwd
    if tool in ("Bash", "PowerShell"):
        check_command(tin.get("command", ""))
    elif tool in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
        check_path(tin.get("file_path") or tin.get("notebook_path") or tin.get("path", ""), cwd, project)
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as exc:  # fail closed
        sys.stderr.write("Run guard internal error, call blocked: %r\n" % (exc,))
        sys.exit(2)
