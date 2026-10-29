# Handoff 104: SIRENS RADIO EACH OTHER WITH A VISIBLE, INTERRUPTIBLE CHARGE (2+ patrollers)

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 6 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
On ops with two or more patrolling Sirens, a Siren that gains contact starts a short visible report charge (suggested 5 s, shown as a chart cue and a sound) to alert the others; if it completes, the receiving Sirens gain the reporter's last-known position. Breaking contact, a Disrupt or Decoy, or a drone drawing its attention cancels it. Extend any existing report code rather than inventing a second system. The lock warning and the beam stay as they are.

## Fleet bar (mandatory for any change to Siren behaviour)
Before/after table for every op the change touches plus ops 2, 14, 22 and 30 as controls: STANDARD bare (Quietus SILENT throughout) and equipped: result, time, Hunt, received lock s, hull, oxygen. Bare must stay finishable on ACCESSIBLE and STANDARD. The 094 to 097 SILENT-pressure counts must not drop (no op that met the Sirens may stop meeting them), and equipped must stay clearly better. If the change breaks an op, fix it by placement or route (copy the 096 method), never by exemption. Keep the timing constants in one place.

## Files you may edit
Siren report/communication code, chart cue drawing (not mission_hud.gd photo functions), event cue sound line, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
