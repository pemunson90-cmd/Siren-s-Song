# Handoff 062: RESEARCH SCREEN, ARCHIVE AND CREDITS

Status: DONE
Claimed at: 2026-10-28 00:21:22 UTC
Claimed by: claude
Finished at: 2026-10-28 02:23:59 UTC

Precondition: 054 is DONE and 056 is DONE or not CLAIMED. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Research today shows only as debrief text plus the SUPPLIES panel. Build a proper RESEARCH view (all 8 artifacts: recovered or not, what it unlocks, cost, pending/paid/complete) reachable from Operations and Fittings; an ARCHIVE view grouping best photos, evidence, recovered artifacts and the field log (if 061 landed) by region; and real credits content (engine, CC-BY audio attribution from Soundscape.ATTRIBUTION, tools, placeholder team line for Pat). Touch-first 48 dp, Android Back.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-research-archive

## Files you may edit
New presentation/research/* and presentation/archive/* views, presentation/frontend/credits_text.gd, entry buttons in ops_home and fittings (one line each), shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files of any other CLAIMED handoff. Claude lanes in flight: claude/c6-doc-sweep (docs/ only) and claude/c7-economy-calibration (campaign/economy_table.gd numbers + new tools/tests only).

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Ranks: Codex local 300-349 / CI 400-449 (next free).

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
- PR160 head `47bf667ec8805c75da1ea40a8c37938bff9d5169`; fix `1be897fe`, integration reconciled at `8f76485d`.
- Opening radio shortened; full received message retained in FIELD LOG; tests and gameplay rules unchanged.
- Local isolated import OK; onboarding 30/0; core 846/0. Render archive suite skipped by Windows runner.
- CI run40613658993: guidance PASS, game-smoke PENDING; not merged, claim remains active.
- Evidence/next: https://github.com/pemunson90-cmd/Siren-s-Song/pull/160#issuecomment-6458016012; merge commit only after exact-head green checks.

## Claude claim (27 Oct)
Claude builds this in parallel with Codex on branch `claude/c10-archive-log` (worktree Siren-s-Song-claude-*). Codex: skip it; Claude owns its listed files until DONE.

Closeout: merged PR160 as88188bd0; current head47bf667e guidance/game-smoke green40613658993; local onboarding30/0 and core846/0. Windows boundary import blocker is tracked on BOARD; final whole-game audit remains pending.
