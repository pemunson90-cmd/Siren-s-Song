# Handoff 112: SORLEY RESCUE REWARD BECOMES PILOTAGE CHARTS

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 12 and 13 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
Replace the Sorley rescue (092) supplies reward with pilotage charts: a lasting reward that reveals safe routing on named later ops (pre-charted passages or hazard marks through the existing earned-chart system from 089). It must not reveal Siren positions. The rescue still does not vote on the ending (item 13). Old saves that already received supplies keep them and also receive the charts.

## Measure
Before/after table in the PR for every behaviour it changes; bare stays finishable on ACCESSIBLE and STANDARD.

## Files you may edit
sorley_rescue.gd reward, earned-chart hooks, ledger and epilogue line, save migration, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
