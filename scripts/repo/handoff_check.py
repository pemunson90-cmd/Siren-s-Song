#!/usr/bin/env python3
"""Staleness check for an autonomous run's handoff documents. Read-only.

Run it after every finished task and before every pause:

  python scripts/repo/handoff_check.py

It fails (exit 1) when a resume from the documents alone would start from the
wrong place:

  * `.fable/RUN_STATE.json` is not valid JSON, lacks a field, or names a run
    branch that is not checked out;
  * `run_head` in the state is not an ancestor of HEAD;
  * a run document under `.fable/` has no `Status:` line near its top;
  * `decisions_open` disagrees with the OPEN entries in `.fable/DECISIONS.md`;
  * `.fable/HANDOFF.md` or `.fable/NOW.md` is missing, or names a repository
    path that does not exist;
  * `.fable/NOW.md` is older than the newest commit by more than the allowed
    lag (a step was taken without writing the note first).

It warns (exit 0) about uncommitted work, unpushed commits and a state that is
several commits behind HEAD. It never writes, fetches or changes anything.
"""
import datetime
import json
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
FABLE = ROOT / ".fable"
FIELDS = (
    "run_id", "status", "phase", "next_action", "base_ref", "base_sha", "run_branch",
    "run_head", "shared_tips", "work_packages", "decisions_open", "last_checkpoint", "updated",
)
STATUSES = ("NOT_STARTED", "RUNNING", "PAUSED", "STUCK", "DONE")
# The charter and the target file are protected and carry no status line.
NO_STATUS_LINE = {"FABLE_RUN.md", "TARGET.md"}
NOW_LAG_MINUTES = 90
PATH_RE = re.compile(r"`((?:\.fable|\.claude|\.github|docs|scripts|game|design|reference|references|reports|_scrap-\d+)/[^`\s*<>]+|[A-Z_]+\.md)`")


def git(*args):
    out = subprocess.run(["git", "-C", str(ROOT), *args], capture_output=True, text=True, encoding="utf-8", errors="replace")
    return out.returncode, out.stdout.strip()


def main():
    errors, warnings = [], []
    state = {}
    state_path = FABLE / "RUN_STATE.json"
    try:
        state = json.loads(state_path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        errors.append("RUN_STATE.json unreadable: %s" % exc)
    for field in FIELDS:
        if state and field not in state:
            errors.append("RUN_STATE.json lacks field %s" % field)
    if state.get("status") not in STATUSES:
        errors.append("RUN_STATE.json status %r is not one of %s" % (state.get("status"), ", ".join(STATUSES)))

    _, branch = git("rev-parse", "--abbrev-ref", "HEAD")
    if state.get("run_branch") and branch != state["run_branch"]:
        errors.append("checked-out branch %s is not the run branch %s" % (branch, state["run_branch"]))
    head_code, head = git("rev-parse", "HEAD")
    run_head = state.get("run_head", "")
    if run_head:
        code, _ = git("merge-base", "--is-ancestor", run_head, "HEAD")
        if code != 0:
            errors.append("run_head %s is not an ancestor of HEAD %s" % (run_head[:8], head[:8]))
        else:
            _, behind = git("rev-list", "--count", "%s..HEAD" % run_head)
            if behind.isdigit() and int(behind) > 3:
                warnings.append("RUN_STATE.json run_head is %s commits behind HEAD; update it" % behind)
    else:
        errors.append("RUN_STATE.json run_head is empty")

    decisions = (FABLE / "DECISIONS.md").read_text(encoding="utf-8") if (FABLE / "DECISIONS.md").exists() else ""
    open_count = len(re.findall(r"^Status:\s*OPEN\b", decisions, flags=re.M))
    if state and state.get("decisions_open") != open_count:
        errors.append("decisions_open is %r but DECISIONS.md has %d OPEN entries" % (state.get("decisions_open"), open_count))

    for doc in sorted(FABLE.glob("*.md")):
        if doc.name in NO_STATUS_LINE:
            continue
        top = doc.read_text(encoding="utf-8").splitlines()[:8]
        if not any(line.startswith("Status:") for line in top):
            errors.append("%s has no Status: line in its first 8 lines" % doc.relative_to(ROOT).as_posix())

    for name in ("HANDOFF.md", "NOW.md"):
        doc = FABLE / name
        if not doc.exists():
            errors.append(".fable/%s is missing" % name)
            continue
        text = doc.read_text(encoding="utf-8")
        for match in sorted(set(PATH_RE.findall(text))):
            candidate = match.rstrip(".,;:)")
            if "/" not in candidate:
                continue
            if not (ROOT / candidate).exists():
                errors.append(".fable/%s names a path that does not exist: %s" % (name, candidate))

    now_doc = FABLE / "NOW.md"
    if now_doc.exists():
        stamp = re.search(r"^Updated:\s*(\d{4}-\d{2}-\d{2} \d{2}:\d{2})", now_doc.read_text(encoding="utf-8"), flags=re.M)
        _, commit_time = git("log", "-1", "--format=%cd", "--date=format:%Y-%m-%d %H:%M")
        if not stamp:
            errors.append(".fable/NOW.md has no 'Updated: YYYY-MM-DD HH:MM' line")
        elif commit_time:
            noted = datetime.datetime.strptime(stamp.group(1), "%Y-%m-%d %H:%M")
            committed = datetime.datetime.strptime(commit_time, "%Y-%m-%d %H:%M")
            if committed - noted > datetime.timedelta(minutes=NOW_LAG_MINUTES):
                errors.append(".fable/NOW.md was updated %s but the newest commit is %s: the note is stale" % (stamp.group(1), commit_time))

    _, dirty = git("status", "--porcelain", "--untracked-files=all")
    changed = [line for line in dirty.splitlines() if not line.endswith((".uid", ".import"))]
    if changed:
        warnings.append("%d uncommitted paths (generated .uid and .import files not counted): %s" % (len(changed), ", ".join(l[3:] for l in changed[:8])))
    if state.get("run_branch"):
        code, unpushed = git("rev-list", "--count", "origin/%s..HEAD" % state["run_branch"])
        if code == 0 and unpushed.isdigit() and int(unpushed) > 0:
            warnings.append("%s commits are not pushed" % unpushed)

    for line in warnings:
        print("WARN: " + line)
    for line in errors:
        print("STALE: " + line)
    if errors:
        print("HANDOFF CHECK FAIL: %d problem(s)" % len(errors))
        return 1
    print("HANDOFF CHECK PASS: status %s, phase %s, HEAD %s, %d open decision(s), %d warning(s)"
          % (state.get("status"), state.get("phase"), head[:8], open_count, len(warnings)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
