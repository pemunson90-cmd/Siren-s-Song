# Handoff 110: ADVANCED ECONOMY VALUES AND MID-CAMPAIGN EASIER PRESET

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 9 and 10 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
(a) Behind an ADVANCED toggle in new-campaign setup (off by default), three custom values: repair cost multiplier, income multiplier and starting stock, each with a bounded range; a custom campaign is labelled custom in records. (b) Outside Ironman, the player may switch to an easier preset mid-campaign from the campaign menu; one way toward easier only, effective at the next dock, recorded in the ledger. Save fields plus migration.

## Measure
Before/after table in the PR for every behaviour it changes; bare stays finishable on ACCESSIBLE and STANDARD.

## Files you may edit
economy presets, new-campaign setup screen, campaign menu, ledger line, save fields, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
