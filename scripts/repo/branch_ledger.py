#!/usr/bin/env python3
"""Read-only ledger of every remote branch.

For each branch under refs/remotes/<remote>/ this prints the last commit date,
author, ahead and behind counts against the accepted baseline and against the
integration base, whether the tip is fully merged into either, the pull request
state when a PR export is supplied, and one class:

  SHARED           a branch other work is based on or promoted through
  ACTIVE           a run branch, an open pull request, or a commit newer than
                   the activity window
  MERGED           the tip is an ancestor of the baseline or of the base
                   (archivable: nothing is lost when the ref goes)
  UNMERGED-STALE   commits that are on neither line, older than the activity
                   window, not on a keep list (archivable once a tag holds
                   the tip)
  UNMERGED-UNIQUE  commits that are on neither line and that someone still
                   needs as a branch: preservation branches, parked work,
                   branches a living document names

The script never fetches, writes refs, deletes or pushes. It reads the local
remote-tracking refs, so run `git fetch --all` first when freshness matters.

Usage:
  python scripts/repo/branch_ledger.py [--remote origin] [--main main]
      [--base claude/integration] [--now YYYY-MM-DD] [--active-days 10]
      [--prs prs.json] [--keep name-or-prefix ...] [--format md|tsv]

`--prs` takes the output of
  gh pr list --state all --limit 1000 --json number,state,headRefName,baseRefName
"""
import argparse
import datetime
import json
import subprocess
import sys

SHARED = (
    "main",
    "claude/integration",
    "gauntlet/production",
    "codex/handoffs",
    "claude/workflow-v2",
)
# Prefixes that exist to preserve material. They stay branches.
KEEP_PREFIXES = ("archive/",)
RUN_PREFIX = "fable/"


def git(*args):
    out = subprocess.run(
        ["git", *args], capture_output=True, text=True, encoding="utf-8", errors="replace"
    )
    if out.returncode != 0:
        raise SystemExit("git %s failed: %s" % (" ".join(args), out.stderr.strip()))
    return out.stdout


def ahead_behind(ref, other):
    """Commits only on ref, commits only on other."""
    left, right = git("rev-list", "--left-right", "--count", "%s...%s" % (ref, other)).split()
    return int(left), int(right)


def load_prs(path):
    """Map head branch name to the most relevant PR: open beats merged beats closed."""
    if not path:
        return {}
    with open(path, encoding="utf-8") as handle:
        rows = json.load(handle)
    rank = {"OPEN": 3, "MERGED": 2, "CLOSED": 1}
    best = {}
    for row in rows:
        head = row.get("headRefName", "")
        cur = best.get(head)
        if cur is None or rank.get(row["state"], 0) > rank.get(cur["state"], 0) or (
            row["state"] == cur["state"] and row["number"] > cur["number"]
        ):
            best[head] = row
    return best


def classify(name, row, keep, active_days):
    if name in SHARED:
        return "SHARED", "shared line"
    if name.startswith(RUN_PREFIX):
        return "ACTIVE", "run branch"
    pr = row["pr"]
    if pr and pr["state"] == "OPEN":
        return "ACTIVE", "open PR #%d" % pr["number"]
    for item in keep:
        if name == item or (item.endswith("/") and name.startswith(item)):
            return "UNMERGED-UNIQUE" if not row["merged"] else "MERGED", "keep list: %s" % item
    if row["age_days"] <= active_days:
        return "ACTIVE", "commit within %d days" % active_days
    if row["merged"]:
        return "MERGED", "tip is in %s" % row["merged"]
    if any(name.startswith(prefix) for prefix in KEEP_PREFIXES):
        return "UNMERGED-UNIQUE", "preservation branch"
    if pr and pr["state"] == "MERGED":
        return "UNMERGED-STALE", "PR #%d merged; tip has later or rewritten commits" % pr["number"]
    if pr and pr["state"] == "CLOSED":
        return "UNMERGED-STALE", "PR #%d closed unmerged" % pr["number"]
    return "UNMERGED-STALE", "no PR; older than %d days" % active_days


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--remote", default="origin")
    parser.add_argument("--main", default="main")
    parser.add_argument("--base", default="claude/integration")
    parser.add_argument("--now", default="")
    parser.add_argument("--active-days", type=int, default=10)
    parser.add_argument("--prs", default="")
    parser.add_argument("--keep", action="append", default=[])
    parser.add_argument("--format", choices=("md", "tsv"), default="md")
    args = parser.parse_args()

    now = (
        datetime.date.fromisoformat(args.now)
        if args.now
        else datetime.datetime.now(datetime.timezone.utc).date()
    )
    prefix = "refs/remotes/%s/" % args.remote
    main_ref = prefix + args.main
    base_ref = prefix + args.base
    prs = load_prs(args.prs)

    fmt = "%(refname)%09%(objectname)%09%(committerdate:short)%09%(authorname)"
    rows = []
    for line in git("for-each-ref", "--format=" + fmt, prefix).splitlines():
        ref, sha, date, author = line.split("\t")
        name = ref[len(prefix):]
        if name == "HEAD":
            continue
        ahead_main, behind_main = ahead_behind(ref, main_ref)
        ahead_base, behind_base = ahead_behind(ref, base_ref)
        merged = ""
        if ahead_main == 0:
            merged = args.main
        elif ahead_base == 0:
            merged = args.base
        row = {
            "name": name,
            "sha": sha[:8],
            "date": date,
            "author": author,
            "ahead_main": ahead_main,
            "behind_main": behind_main,
            "ahead_base": ahead_base,
            "behind_base": behind_base,
            "merged": merged,
            "pr": prs.get(name),
            "age_days": (now - datetime.date.fromisoformat(date)).days,
        }
        row["class"], row["why"] = classify(name, row, args.keep, args.active_days)
        rows.append(row)

    order = {"SHARED": 0, "ACTIVE": 1, "UNMERGED-UNIQUE": 2, "UNMERGED-STALE": 3, "MERGED": 4}
    rows.sort(key=lambda r: (order[r["class"]], r["name"]))
    counts = {}
    for row in rows:
        counts[row["class"]] = counts.get(row["class"], 0) + 1

    out = sys.stdout
    if args.format == "tsv":
        for row in rows:
            pr = row["pr"]
            out.write("\t".join(str(x) for x in (
                row["class"], row["name"], row["sha"], row["date"], row["author"],
                row["ahead_main"], row["behind_main"], row["ahead_base"], row["behind_base"],
                row["merged"] or "-", ("#%d %s" % (pr["number"], pr["state"])) if pr else "-", row["why"],
            )) + "\n")
        return

    out.write("# Branch ledger\n\n")
    out.write(
        "Produced by `scripts/repo/branch_ledger.py` on %s from the local remote-tracking refs of `%s`. "
        "Baseline `%s` at %s, base `%s` at %s. Activity window: %d days. Nothing was changed.\n\n"
        % (now.isoformat(), args.remote, args.main, git("rev-parse", "--short=8", main_ref).strip(),
           args.base, git("rev-parse", "--short=8", base_ref).strip(), args.active_days)
    )
    out.write("| Class | Count | Meaning |\n| --- | --- | --- |\n")
    meaning = {
        "SHARED": "other work is based on it or promoted through it; keep",
        "ACTIVE": "run branch, open PR or recent commit; keep",
        "UNMERGED-UNIQUE": "unmerged and still needed as a branch; keep",
        "UNMERGED-STALE": "unmerged, old; archivable once a tag holds the tip",
        "MERGED": "tip is in the baseline or the base; archivable",
    }
    for cls in order:
        out.write("| %s | %d | %s |\n" % (cls, counts.get(cls, 0), meaning[cls]))
    out.write("| Total | %d | |\n" % len(rows))
    for cls in order:
        group = [r for r in rows if r["class"] == cls]
        if not group:
            continue
        out.write("\n## %s (%d)\n\n" % (cls, len(group)))
        out.write("| Branch | Tip | Last commit | Author | Ahead/behind %s | Ahead/behind %s | Merged into | PR | Reason |\n"
                  % (args.main, args.base))
        out.write("| --- | --- | --- | --- | --- | --- | --- | --- | --- |\n")
        for row in group:
            pr = row["pr"]
            out.write("| `%s` | %s | %s | %s | %d/%d | %d/%d | %s | %s | %s |\n" % (
                row["name"], row["sha"], row["date"], row["author"],
                row["ahead_main"], row["behind_main"], row["ahead_base"], row["behind_base"],
                row["merged"] or "no", ("#%d %s" % (pr["number"], pr["state"])) if pr else "none", row["why"],
            ))


if __name__ == "__main__":
    main()
