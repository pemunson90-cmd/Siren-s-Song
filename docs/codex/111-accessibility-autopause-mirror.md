# Handoff 111: AUTO-PAUSE ON FIRST NOTICE AND MIRRORED ONE-HANDED HUD

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 11 and 18 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
(a) Accessible options, off by default: auto-pause when a Siren first notices any craft, and when a lock warning starts (the warning timing itself is unchanged). (b) A mirrored HUD layout for one-handed play that swaps the left and right control clusters, persisted in settings, 48 dp targets, both Fold shapes. Keep edits out of mission_hud.gd photo caption and object-context functions while root's EXP-PHOTO-INTENT holds them.

## Measure
Before/after table in the PR for every behaviour it changes; bare stays finishable on ACCESSIBLE and STANDARD.

## Files you may edit
settings, pause hook, HUD layout code, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
