# Handoff 062: RESEARCH SCREEN, ARCHIVE AND CREDITS

Status: OPEN
Claimed at:
Claimed by:
Finished at:

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
(five lines max)
