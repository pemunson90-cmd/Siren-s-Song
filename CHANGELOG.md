# Changelog

One entry per run or milestone, newest first. Day-to-day history is in git. Current status is in [docs/STATUS.md](docs/STATUS.md).

## Unreleased: overhaul run `overhaul-20261111` (branch `fable/overhaul-20261111`)

Base: `claude/integration` at `cabd5bd5`. The complete account, including every behavior change, is `.fable/FINAL_REPORT.md` when the run closes.

### Governance and documents

- `AGENTS.md` is the single governing file. `CLAUDE.md` imports it. `docs/STATUS.md` is the one status file. `docs/WORKFLOW.md` holds the branch model, commit format, review and merge rules and CI gating.
- Pat's rulings from `codex/handoffs` (29 October to 1 November) and from this run are copied verbatim into `docs/USER_DIRECTIVES.md`.
- Ten pointer and handoff documents moved to `_scrap-20261111/` with a manifest. `docs/GOVERNANCE_MIGRATION.md` accounts for every rule of the old governing files.
- Stale statements corrected in place: the lifted stop banners, the superseded APK prohibition, the WSL-only instructions, dead links.

### Repository hygiene

- `.gitattributes` stores text with LF on every platform and keeps provenance files and fixtures byte for byte. Twelve scripts with CRLF or mixed endings were normalized (whitespace only).
- The 441 Godot `.gd.uid` files and three title `.import` files that an import generated are now tracked, so an import leaves a clean tree and script identifiers are the same on every machine.
- Added a pull request template, a documentation link check and a branch archive planner (`scripts/repo/archive_branches.py`, dry run by default; it changes nothing without the owner's flag).

### Tools

- `scripts/critic/`: the blind critic play kit, versioned and reviewed.
- `scripts/repo/`: branch ledger, documentation link check, capabilities ledger check, run-state helpers.
- The guidance checker audits the new document structure; the boundary helper reads the new file list and still reads the old one from commits that predate the consolidation.

### Game

Entries are added as work packages land.
