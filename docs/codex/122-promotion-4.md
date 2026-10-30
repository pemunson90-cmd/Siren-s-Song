# Handoff 122: PROMOTION 4 (audit-091 fixes to production)

Status: QUEUED (codex-root)

Precondition: rows 115, 116, 117, 118, 119, 120 and 121 read DONE or BLOCKED on BOARD (the Claude-lane fix cycle for the 091 audit). Then root claims this row. Ruling (Pat, 2026-10-29T20:35:53-0400, widget): "Start the next gauntlet loop (Promotion 4, then a fresh blind critic) after the five audit fixes (116, 118-121) land, about 4 hours, rather than now?" = "After the fixes (Recommended)".
Codex may merge: yes, into gauntlet/production, same process as Promotion 3 (090, PR213).

## Task
Repeat 090 exactly: freeze an exact `claude/integration` snapshot on `gauntlet/milestone-YYYYMMDD`, PR into `gauntlet/production`, independent Sol6.1-high approval of that snapshot, full seven required checks on its exact head, merge on green. Record snapshot SHA, review id and run id on the PR, the BOARD row and one LEDGER line. `main` unchanged. No APK.

## Return
Merged promotion PR; then 123 becomes eligible.
