# Handoff 106: SONAR SHOWS A ROUGH SIREN TYPE UNTIL SEEN OR PHOTOGRAPHED

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 3 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
A sonar contact shows a coarse class (for example PATROLLER or STATIC) until the role is identified by sight from any craft or by a photograph; then the exact role shows and stays known for that Siren for the dive. If the dossier already records photographed roles, use it to pre-identify. Presentation only: detection, sight ranges, lock and beam are unchanged. Chart, contact list and audio cues must not leak the exact role before identification.

## Measure
Before/after table in the PR for every behaviour it changes; bare stays finishable on ACCESSIBLE and STANDARD.

## Files you may edit
contact presentation and chart labels, contact identification state, dossier hook, tests, docs (not mission_hud.gd photo caption functions), shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
