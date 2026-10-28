# Handoff 090: PROMOTION 3 (content-complete milestone to production)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: content complete = 056, 057, 067, 068, 069, 070, 071, 072, 073, 080, 085, 086, 088, 089, 092, 094, 095, 096, 097, 098 and 099 are DONE (or Pat explicitly drops one). Read HANDOFF.md first. Pat's standing option A covers promotion after independent review.
Codex may merge: yes, into gauntlet/production, under the same process as Promotion 2 (PR179).

## Task (plain language)
Repeat Promotion 2 exactly: freeze an exact `claude/integration` snapshot on `gauntlet/milestone-YYYYMMDD`, open a PR into `gauntlet/production`, obtain independent Sol6.1-high approval of that snapshot, run the full seven required checks on its exact head, merge on green. Record the snapshot SHA, review id and run id on the PR, the BOARD row and one LEDGER line. `main` stays unchanged. No APK.

## Checks
Full seven required checks on the exact milestone head. No new tests.

## Return
Merged promotion PR; then 091 becomes eligible.
