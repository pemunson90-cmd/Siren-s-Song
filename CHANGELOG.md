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

### CI

- The fast `guidance` job also checks documentation links and runs the tool self-tests that no workflow ran before; two helper tests that need Godot run in `game-core`. Nothing redundant was added and the matrix is unchanged.
- While a photograph is framed, the chart draws the shutter-noise reach with its distance, using the same figure the camera panel prints. Every craft under a Siren lock shows a countdown chip beside it. A lost drone reports its cause and bearing ("UNSEEN SIREN" when the player held no contact). A new setting, off by default, pauses the dive when a craft is lost.
- Selecting a craft while the dive is paused no longer moves the camera; on resume the view follows the selected craft again unless the player panned or zoomed. RESUME closes an open command ring or a pending route marker and resumes in one press. The route confirm dialog names its real buttons, shows the craft's live orders, and holds dive time while it is open. The pause control grows to fit its label, which fixes taps on RESUME being ignored.

### Tests

- The protected-rules golden pins 23 more protected numbers (Disrupt, torpedo, decoy, the Hunt table, radio reports, survivor ascent, passive reach, silt screen). A new suite states as one rule that no player tool permanently disables a Siren, for all eight roles. New suites also cover the release build gate and operation metadata parity.

### Tools

- `scripts/critic/`: the blind critic play kit, versioned and reviewed.
- `scripts/repo/`: branch ledger, documentation link check, capabilities ledger check, run-state helpers.
- The guidance checker audits the new document structure; the boundary helper reads the new file list and still reads the old one from commits that predate the consolidation.

### Game

- Release builds refuse the six developer-only travel shortcuts on every profile, including an imported developer-marked one. Debug builds are unchanged. The developer mark and its exclusion from records are unchanged.
- Exported packages no longer contain the test scripts.
- The internal `SS_` diagnostic lines print only in debug builds.
- Per-operation metadata (region, route-map position, endurance, opening-arc gating) lives in one table, `game/src/campaign/operation_meta.gd`. No operation behaves differently; a parity suite proves it against values recorded from the base. `docs/guides/` explains how to add an operation, a region, a Siren role and a fitting.
