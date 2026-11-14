#!/usr/bin/env python3
"""Fail on known-stale Siren's Song entry points; never rewrite worktrees.

This is a structural preflight, not a substitute for semantic agent review.
Use --ref to check the freshly fetched integration commit from any worktree.

Structure audited since the governance consolidation of 2026-11-12:
AGENTS.md is the single governing file, CLAUDE.md imports it, docs/STATUS.md
is the one status file, docs/WORKFLOW.md holds the mechanics and
docs/USER_DIRECTIVES.md is the one home for the owner's rulings. The retired
pointer documents (RESUME, CONTINUATION, WORKBENCH, START_HERE, AGENT_BRIEF,
GAUNTLET_ORCHESTRATION) must not come back as authorities.
"""
import argparse
import pathlib
import subprocess
import sys

FILES = (
    "AGENTS.md",
    "CLAUDE.md",
    "README.md",
    "docs/STATUS.md",
    "docs/WORKFLOW.md",
    "docs/USER_DIRECTIVES.md",
    "docs/GOVERNANCE_MIGRATION.md",
    "docs/SOURCE_AUTHORITY.md",
    "docs/CURRENT_GAME_SPEC.md",
    "docs/V7_TO_GODOT_PARITY.md",
    "design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md",
    "references/visual/SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md",
    "references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md",
    "references/package/START_HERE.md",
)

# Files that must exist on an active development tree. A tree with none of the
# markers below is a historical default branch and gets the reduced check.
ACTIVE_MARKERS = (
    "docs/CURRENT_GAME_SPEC.md", "docs/STATUS.md", "docs/WORKFLOW.md",
    "docs/USER_DIRECTIVES.md",
)
MINIMAL = ("AGENTS.md", "README.md", "docs/SOURCE_AUTHORITY.md")

# Living entry documents may not point at the retired pointer documents or
# carry the dated stop banner. History files (USER_DIRECTIVES, the migration
# table) are exempt because they quote the past.
LIVING = (
    "AGENTS.md", "README.md", "docs/STATUS.md", "docs/WORKFLOW.md",
    "docs/SOURCE_AUTHORITY.md", "docs/CURRENT_GAME_SPEC.md",
    "docs/V7_TO_GODOT_PARITY.md",
)
RETIRED = (
    "RESUME.md", "CONTINUATION.md", "WORKBENCH.md", "docs/START_HERE.md",
    "AGENT_BRIEF.md", "GAUNTLET_ORCHESTRATION.md", "DESKTOP_HANDOFF.md",
    "CODEX_ENVIRONMENT.md",
)
STALE_PHRASES = (
    "observe pat's cloud stop",
    "prohibit apk builds",
    "prohibits apk builds",
)
STATUS_MAX_LINES = 80


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
    # A deleted living spec in an otherwise active tree is a failure, not
    # permission to silently treat that branch as a historical default branch.
    main = not any(docs[p] is not None for p in ACTIVE_MARKERS)
    required = MINIMAL if main else FILES
    for path in required:
        if docs[path] is None:
            errors.append("missing or unreadable required document: " + path)

    def require(path, terms, reason):
        body = docs.get(path)
        if body is not None and not any(term.lower() in body.lower() for term in terms):
            errors.append(path + ": " + reason)

    for path in ("AGENTS.md", "README.md"):
        require(path, ("gauntlet/production",), "must identify the preserved production baseline")
        if not main:
            require(path, ("claude/integration",), "must identify active development integration")
            require(path, ("docs/STATUS.md",), "must point to the single operational status entry")
    require("AGENTS.md", ("user alone", "only the user", "only pat"), "user-only Gauntlet termination missing")
    readme = docs.get("README.md") or ""
    if "preproduction and source import" in readme.lower() or "engine selection pending" in readme.lower():
        errors.append("README.md: obsolete preproduction/engine-pending status")
    if not main:
        # The owner's feature-continuity directive is carried verbatim.
        require("AGENTS.md", ("Non-negotiable feature continuity (owner directive)",),
                "owner feature-continuity directive heading missing")
        require("AGENTS.md", ("If Pat did not explicitly authorize removing a working capability, it stays.",),
                "owner feature-continuity directive text missing")
        require("AGENTS.md", ("nothing is deleted",), "owner removal rule missing")
        require("AGENTS.md", ("task completion", "task closeout"), "mandatory task-closeout transition missing")
        require("AGENTS.md", ("staleness", "stale"), "staleness reconciliation instruction missing")
        require("AGENTS.md", ("next highest-value", "next biggest"), "continuous next-action instruction missing")
        require("AGENTS.md", ("charter",), "bounded chartered-run stop rule missing")
        require("AGENTS.md", ("USER_DIRECTIVES.md",), "pointer to the owner's rulings missing")
        require("AGENTS.md", ("independent reviewer",), "independent review rule missing")
        claude = docs.get("CLAUDE.md")
        if claude is not None:
            first = next((line.strip() for line in claude.splitlines() if line.strip()), "")
            if first != "@AGENTS.md":
                errors.append("CLAUDE.md: must start by importing AGENTS.md (@AGENTS.md)")
        require("README.md", ("AGENTS.md",), "must point to the governing agent file")
        require("docs/STATUS.md", ("claude/integration",), "active integration authority missing")
        require("docs/STATUS.md", ("next action",), "current next action missing")
        status = docs.get("docs/STATUS.md")
        if status is not None and len(status.splitlines()) > STATUS_MAX_LINES:
            errors.append("docs/STATUS.md: longer than %d lines; the status file stays short" % STATUS_MAX_LINES)
        require("docs/WORKFLOW.md", ("claude/integration",), "branch model missing")
        require("docs/WORKFLOW.md", ("once per head",), "CI necessity rule missing")
        require("docs/WORKFLOW.md", ("independent reviewer",), "review rule missing")
        require("docs/USER_DIRECTIVES.md", ("Rulings copied from codex/handoffs",),
                "consolidated rulings section missing")
        require("docs/USER_DIRECTIVES.md", ("you can build the apk",), "1 November debug-package ruling missing")
        require("docs/GOVERNANCE_MIGRATION.md", ("KEPT", ), "migration table missing its dispositions")
        require("docs/SOURCE_AUTHORITY.md", ("CURRENT_GAME_SPEC.md",), "current decision hierarchy missing")
        require("docs/SOURCE_AUTHORITY.md", ("bible",), "design-bible precedence not resolved")
        require("docs/CURRENT_GAME_SPEC.md", ("the user alone", "user alone"), "perpetual program user control missing")
        require("references/visual/SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md",
                ("historical handoff", "historical planning snapshot"),
                "visual plan must say its prior approval/status is historical")
        require("references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md",
                ("likely candidate",), "accepted visual exploration status missing")
        require("references/package/START_HERE.md",
                ("quietus", "siren"), "current visual design handoff missing")
        for path in LIVING:
            body = docs.get(path)
            if body is None:
                continue
            lowered = body.lower()
            for name in RETIRED:
                if name.lower() in lowered:
                    errors.append(path + ": points at retired document " + name)
            for phrase in STALE_PHRASES:
                # The specification is kept as written; its superseded package
                # sentence must carry the dated supersession note instead.
                if path == "docs/CURRENT_GAME_SPEC.md" and "apk" in phrase and "superseded 1 november 2026" in lowered:
                    continue
                if phrase in lowered:
                    errors.append(path + ": carries superseded wording: " + phrase)
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
