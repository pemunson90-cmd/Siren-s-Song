# NOW: what the root session is doing

Status: LIVE NOTE (rewritten before every step; if a session died, this is the step it died in)
Updated: 2026-11-12 09:58

**To resume after a context clear or a new session:** open this folder as the project and run `/siren-s-start-fable`. The command reads the charter, the target file, `.fable/RUN_STATE.json`, `.fable/RUN_LOG.md` and `.fable/DECISIONS.md`. The `next_action` field in the state file always starts by sending the session to `.fable/HANDOFF.md` and to this file.

## Doing right now

Full-matrix run on the gate fix is running on GitHub; no local job

## In flight

Nothing. WP-00 to WP-12 are merged and pushed. No subagent or test job is running; the Phase 4 CI gate runs on GitHub.

## Next, in order

1. Done: WP-11 merged.
2. Phase 4 gate: `gh workflow run gauntlet-pr-checks.yml --ref fable/overhaul-20261111`; read the result and attribute any failure (render suites touched by WP-08 to WP-11 have not run since the Phase 3 gate).
3. Phase 5: merge `origin/claude/integration` if it moved (it was still cabd5bd5 at the pause); add the Status column to `.fable/PROTECTED_CAPABILITIES.md` and resolve every row; full gate; one debug package with `gh workflow run android-validation.yml --ref fable/overhaul-20261111`, record its SHA-256 and versionCode; behavior-change table from `git diff fable/pre-overhaul-20261111..fable/overhaul-20261111`, checked against the reports in the fable-notes folder and `CHANGELOG.md`.
4. Phase 6: `python scripts/repo/archive_branches.py --dry-run` committed as BRANCH_ARCHIVE_PLAN.md under .fable; FINAL_REPORT.md under .fable and in the body of PR 262; update `docs/STATUS.md` and `CHANGELOG.md`; mark the PR ready; set status DONE; push.
