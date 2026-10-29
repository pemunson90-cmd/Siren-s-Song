# Handoff 103: SIREN ROLE SENSES: hunter and sentinel hear, search and attend differently

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT (mission_hud.gd photo caption/object-context): do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 5 (copy it verbatim into docs/USER_DIRECTIVES.md, mark QUESTIONS_FOR_PAT ruled). Numbers below are AI-DESIGNED.

## Task
Today Siren roles share one hearing, search and attention model (find it under game/src/simulation, including role senses and the dossier from 083). Give the hunter and the sentinel distinct, readable behaviour so each needs a different plan. Suggested: the hunter hears farther but loses interest sooner and searches by sweeping toward the last noise; the sentinel hears less far but holds attention longer and searches by holding station and turning. Sight ranges (silent 180 m, cruise 290 m), the lock warning and the beam stay exactly as they are. The dossier and briefings describe each role's behaviour in one placeholder line each.

## Fleet bar (mandatory for any change to Siren behaviour)
Before/after table for every op the change touches plus ops 2, 14, 22 and 30 as controls: STANDARD bare (Quietus SILENT throughout) and equipped: result, time, Hunt, received lock s, hull, oxygen. Bare must stay finishable on ACCESSIBLE and STANDARD. The 094 to 097 SILENT-pressure counts must not drop (no op that met the Sirens may stop meeting them), and equipped must stay clearly better. If the change breaks an op, fix it by placement or route (copy the 096 method), never by exemption. Keep the timing constants in one place.

## Files you may edit
role sense tables, Siren search/attention code, dossier and briefing lines, mission Siren placement only if the fleet bar requires it, tests, docs, shared registration lines.

## Files you must not touch
Anything not named in the task; protected rules beyond the named change; files of other CLAIMED rows; mission_hud.gd photo functions while root's experiment holds them.

## Checks
Import + core, one new suite for the new rule or field, and the affected suites only.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.

## 103b revision (Claude, 29 Oct 2026 10:45 ET)
PR216 (head b76ed64b) is held as draft: its table shows every voyage identical before and after, so the roles do not yet need different plans (Pat's words: "each type needs a different plan"). Continue on the same branch and PR. Acceptance, all required:
1. Role-contrast probe: the same noise event against a hunter and against a sentinel; table of time to lose interest, search path length/shape and final position.
2. At least two ops where the role decides the plan: real voyages showing a plan that passes a hunter but fails or costs clearly more against a sentinel (or the reverse). Put these rows in the PR table.
3. If the current values cannot produce that, widen them (sight 180/290 m, lock, beam, sweeper unchanged) and rerun the full fleet bar table; no SILENT-pressure op may be lost.
Fresh independent Sol6.1-high review of the revision before commit; merge only on green exact-head checks.
