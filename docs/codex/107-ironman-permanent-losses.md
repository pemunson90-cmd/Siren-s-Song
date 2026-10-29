# Handoff 107: IRONMAN: LOST DRONES AND MODULES ARE GONE FOR GOOD

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 1 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
In Ironman only, a drone or fitted module lost in a dive (by the existing loss and non-recovery rules) is removed from the profile permanently; replacing it costs the normal manufacturing price. Other modes keep today's behaviour. The debrief and ledger name each permanent loss in one line. Never make a campaign unwinnable: Quietus itself is never permanently lost by this rule, and an empty drone bay stays launchable (Pat's bare floor). Save field plus migration; respect the Ironman single timeline (079).

## Measure
Before/after table in the PR for every behaviour it changes; bare stays finishable on ACCESSIBLE and STANDARD.

## Files you may edit
Ironman/profile loss state, debrief and ledger lines, economy replacement hook, save field plus migration, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
