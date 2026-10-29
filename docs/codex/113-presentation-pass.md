# Handoff 113: PRESENTATION: SILHOUETTES, ROLE SOUNDS, SEA LIFE, PLACEHOLDER KEY ART

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 15, 16, 17 and 19 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
(a) Distinct silhouettes per hull and chassis, readable at phone size. (b) Each Siren role gets its own sound, played only once sonar or sight has earned that role (use 106's identification if merged, otherwise earned contact). (c) Limited ambient sea life in clearly non-contact colours, never on sonar or chart, off in battery saver. (d) Placeholder title art, icon and splash from the Quietus silhouette, easy to replace. Art direction is Pat's: keep it clearly placeholder and consistent with the current look.

## Measure
Before/after table in the PR for every behaviour it changes; bare stays finishable on ACCESSIBLE and STANDARD.

## Files you may edit
craft drawing code, audio cue table, ambient layer, title/icon/splash assets, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
