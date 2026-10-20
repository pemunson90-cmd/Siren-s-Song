#!/usr/bin/env python3
"""Fail on known-stale Siren's Song entry points; never rewrite worktrees.

This is a structural preflight, not a substitute for semantic agent review.
Use --ref to check the freshly fetched production commit from any worktree.
"""
import argparse
import pathlib
import subprocess
import sys

FILES = (
    "AGENTS.md",
    "docs/USER_DIRECTIVES.md",
    "README.md",
    "docs/START_HERE.md",
    "docs/SOURCE_AUTHORITY.md",
    "docs/CURRENT_GAME_SPEC.md",
    "docs/CONTINUATION.md",
    "docs/WORKBENCH.md",
    "docs/AGENT_BRIEF.md",
    "docs/GAUNTLET_ORCHESTRATION.md",
    "docs/V7_TO_GODOT_PARITY.md",
    "design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md",
    "references/visual/SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md",
    "references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md",
    "references/package/START_HERE.md",
)


def on_disk(root):
    def read(path):
        target = root / path
        if not target.is_file():
            raise FileNotFoundError(path)
        return target.read_text(encoding="utf-8")
    return read


def at_ref(ref):
    if not ref or ref.startswith("-") or not all(c.isalnum() or c in "/-._" for c in ref):
        raise ValueError("invalid git ref")
    def read(path):
        p = subprocess.run(
            ["git", "show", f"{ref}:{path}"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15,
        )
        if p.returncode:
            raise FileNotFoundError(path)
        return p.stdout.decode("utf-8")
    return read


def scan(read):
    errors = []
    docs = {}
    for path in FILES:
        try:
            docs[path] = read(path)
        except (FileNotFoundError, UnicodeError, OSError, subprocess.TimeoutExpired):
            docs[path] = None
    # A deleted living spec in an otherwise active production tree is a failure,
    # not permission to silently treat that branch as historical main.
    production_markers = (
        "docs/CURRENT_GAME_SPEC.md", "docs/CONTINUATION.md",
        "docs/WORKBENCH.md", "docs/GAUNTLET_ORCHESTRATION.md",
    )
    main = not any(docs[p] is not None for p in production_markers)
    required = (
        ("AGENTS.md", "README.md", "docs/START_HERE.md", "docs/SOURCE_AUTHORITY.md")
        if main else FILES
    )
    for path in required:
        if docs[path] is None:
            errors.append("missing or unreadable required document: " + path)
    def require(path, terms, reason):
        body = docs.get(path)
        if body is not None and not any(term.lower() in body.lower() for term in terms):
            errors.append(path + ": " + reason)
    for path in ("AGENTS.md", "README.md", "docs/START_HERE.md"):
        require(path, ("gauntlet/production",), "must point to current production authority")
    for path in ("AGENTS.md", "docs/START_HERE.md"):
        require(path, ("user alone", "only the user", "only pat"), "user-only Gauntlet termination missing")
    readme = docs.get("README.md") or ""
    if "preproduction and source import" in readme.lower() or "engine selection pending" in readme.lower():
        errors.append("README.md: obsolete preproduction/engine-pending status")
    if not main:
        require("AGENTS.md", ("task completion", "task closeout"), "mandatory task-closeout transition missing")
        require("AGENTS.md", ("staleness", "stale"), "staleness reconciliation instruction missing")
        require("AGENTS.md", ("next highest-value", "next biggest"), "continuous next-action instruction missing")
        require("docs/AGENT_BRIEF.md", ("closeout", "stale"), "worker closeout responsibility missing")
        require("docs/GAUNTLET_ORCHESTRATION.md", ("staleness", "stale"), "completion-time staleness mechanism missing")
        require("docs/SOURCE_AUTHORITY.md", ("CURRENT_GAME_SPEC.md",), "current decision hierarchy missing")
        require("docs/SOURCE_AUTHORITY.md", ("bible",), "design-bible precedence not resolved")
        require("docs/CURRENT_GAME_SPEC.md", ("the user alone", "user alone"), "perpetual program user control missing")
        require("docs/CONTINUATION.md", ("next",), "current next task missing")
        require("docs/WORKBENCH.md", ("next",), "current next quality opportunity missing")
        require("references/visual/SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md",
                ("historical handoff", "historical planning snapshot"),
                "visual plan must say its prior approval/status is historical")
        require("references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md",
                ("likely candidate",), "accepted visual exploration status missing")
        require("references/package/START_HERE.md",
                ("quietus", "siren"), "current visual design handoff missing")
    return errors


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    args = parser.add_mutually_exclusive_group()
    args.add_argument("--root", type=pathlib.Path, default=None)
    args.add_argument("--ref", default=None)
    values = parser.parse_args(argv)
    reader = at_ref(values.ref) if values.ref else on_disk((values.root or pathlib.Path.cwd()).resolve())
    errors = scan(reader)
    for issue in errors:
        print("STALE: " + issue, file=sys.stderr)
    if errors:
        print(f"GAUNTLET GUIDANCE FAIL: {len(errors)} issue(s)", file=sys.stderr)
        return 1
    print("GAUNTLET GUIDANCE PASS: canonical entry points and required handoffs structurally consistent")
    print("Human/agent semantic review still required at every task closeout.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
