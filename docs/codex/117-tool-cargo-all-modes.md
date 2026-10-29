# Handoff 117: EXTRA TOOLS COST CARGO IN CAREER AND EXPEDITION TOO

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT: do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling (Pat, 29 Oct 2026 ~17:50 ET, chat): Claude asked "Should extra tools cost cargo in Career and Expedition too (today campaign only)? I recommend yes, so the loadout choice matters everywhere." Pat: "Yes to all". Copy this into docs/USER_DIRECTIVES.md. Numbers below are AI-DESIGNED.

## Why
The S7 audit found per-craft tool cargo (098 PR199, lockers 100 PR208) is applied only on the Campaign launch path (`tool_racks` is referenced from main.gd and presentation/flow/campaign_flow.gd; the charge is at economy_panel.gd:111-116). Career and Expedition launches carry tools without the cargo trade-off, so the loadout choice does not matter there.

## Task
Apply the same tool racks, locker defaults and cargo cost to Career and Expedition launches, reusing the Campaign code path (one shared function; no copy). Each mode keeps its own economy (Career contract stock, Expedition run stock). Ironman losses (107) and advanced economy (110) keep working. Old saves and active dives load unchanged.

## Bar
- Before/after full voyages, Quietus SILENT throughout: one Career contract op and one Expedition op where carrying extra tools now costs cargo, bare and equipped, STANDARD and ACCESSIBLE bare, plus controls 2 and 30 in Campaign (must be identical).
- Show that a tool-heavy loadout gives up something real (cargo or a module) in both modes, and that the default locker loadout still finishes bare on ACCESSIBLE and STANDARD.
- Protected rules untouched.

## Files you may edit
tool rack / locker / launch-path code for Career and Expedition, the shared rack function, their fittings or launch UI lines, tests, docs, shared registration lines.

## Files you must not touch
Anything not named above; files of other CLAIMED rows; mission_hud.gd photo functions.

## Checks
Import + core, the tool rack and locker suites, Career and Expedition suites, one new suite asserting the cargo cost in both modes.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row and add one LEDGER line.
