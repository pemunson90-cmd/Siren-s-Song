# Handoff 109: EXPEDITION SEEDS SHUFFLE SIREN STARTS AND PATROL TIMING

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 8 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
In Expedition mode, the run seed also shifts each Siren's start position (within authored safe zones or along its existing patrol path) and its patrol phase, deterministically per seed. Never change senses, sight ranges, role, lock or beam. The V7-senses sweeper (PR70) keeps its patrol shape; only its phase may shift, and only if safe. Campaign and Career keep authored positions. Records and seed entry (069) still replay identically for a given seed.

## Fleet bar (mandatory for any change to Siren behaviour)
Before/after table for every op the change touches plus ops 2, 14, 22 and 30 as controls: STANDARD bare (Quietus SILENT throughout) and equipped: result, time, Hunt, received lock s, hull, oxygen. Bare must stay finishable on ACCESSIBLE and STANDARD. The 094 to 097 SILENT-pressure counts must not drop (no op that met the Sirens may stop meeting them), and equipped must stay clearly better. If the change breaks an op, fix it by placement or route (copy the 096 method), never by exemption. Keep the timing constants in one place.

## Files you may edit
expedition seed code, Siren spawn and patrol phase hooks, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
