# Handoff 048: HUD SAMENESS, operation-aware status text and an explained ARRIVALS button

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none; if handoff 023 or 038 still holds mission_hud.gd or main.gd, wait for it. Source: docs/design/COLD_REVIEW_3.md finding F14 (low confidence, first frame only). Presentation only.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers and strings in a data table, revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Change no combat, beam, collision, damage, hull, oxygen or Siren sight, hearing or lock rule. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
After tapping Quietus on 23 sampled operations the reviewer saw 8 late operations open with the identical status line "No exact source located · listen from another position or spend local RECON", including Iron Choir operations whose job is machinery, and a button "ARRIVALS 0" with no explanation. The review's op list (7, 10, 12, 23, 25, 28, 29, 30) is in player numbers (ids 6, 9, 11, 22, 24, 27, 28, 29); confirm by reproducing before editing.

### Verified sources
1. The line is produced in `_camera_context_base()` in game/src/simulation/simulation.gd:611, in the branch `mission.has("expedition_revision") and mission.objectives.all(captured) and not any own_origin`, returning "No exact source located · listen from another position or spend local RECON" when `mission.expedition_facts` is empty and mission.id != 8 (else "Observed %s · choose an available named recovery corridor"). The same sentence is therefore shown regardless of the operation's actual task. It reaches the player as `sim.message`/context text in game/src/presentation/mission_hud.gd (`intent.text` around line 399 and `instrument_info.text` around line 406).
2. The ARRIVALS button: game/src/presentation/mission_hud.gd:74 (entry ["arrivals","ARRIVALS"]), text set at :405 and :533 as "ARRIVALS\n%d" from `Expedition.measurements(sim)` (game/src/presentation/expedition_view.gd:9, :20 builds the "RECEIVED ARRIVALS" list). `Expedition.active(sim)` is `expedition_revision in [1,2]`. It is disabled when the count is 0 and never says what an arrival is.
Do NOT edit simulation.gd's context function (it is simulation text and other tests may assert it). Do the replacement in presentation: a new small module (for example game/src/presentation/status_text/status_text.gd with a table) called from the mission_hud.gd seam that sets the displayed text, which maps (mission id, existing state) to a clearer line and passes everything else through unchanged.

## Required behaviour (from existing state only)
1. Status line: when the sim text is exactly the "No exact source located..." sentence, show an operation-aware line chosen from existing public state: unfinished objectives and their kind (photo site, machinery or work site, recovery corridor), the active phase (`mission.get("phase")`), whether a work site or Iron Choir task is available (use the same accessors the HUD already calls, for example the work-site or choir accessors under game/src/campaign/encounters/work_sites.gd and iron_choir_operations.gd; read, never write). Examples of the intent: "Next: reach the machinery at A and work it" for a work-site op, "Next: photograph the three sites" for a photo op, "Source not located: listen from another position or spend local RECON" only when the task really is finding a source. Strings live in the table; one line each, 1 to 2 line placeholders. No hidden information: the line may only name things the player already knows (the HUD already shows known sites; do not reveal unknown positions or Siren data).
2. ARRIVALS: add a one-line explanation, shown when the button is disabled or first shown, such as "ARRIVALS 0: no signal has reached this craft yet" and "ARRIVALS 2: signals received (tap to read)". Keep the button label compact and the 48 dp target; if the label must stay two lines, put the explanation in the page the button opens and in the disabled state's tooltip/status line.
3. Ops where the sentence is correct (a genuine source search) keep their meaning; only the wording becomes explicit.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-hud-sameness

## Files you may edit
mission_hud.gd narrow seam, the new status_text module and table, expedition_view.gd label text only, tests.

## Files you must not touch
simulation.gd, detection, hearing, lock, combat, save schema, operation tables.

## What done looks like
- A test table covering all 8 sampled ops plus op 1 and op 8 (the other branch): none of the Iron Choir and work-site ops shows the "No exact source located" sentence unless the task is truly a source search; assert the displayed string per op.
- Simulation text unchanged (sim.message and context byte-equal with the module on and off; module has an off switch).
- By real touch at both Fold7 shapes (2520x1080 and 2184x1968, helpers in tests/fix2_menu_ui_tests.gd): tap Quietus on at least four of the sampled ops, read the status line and the ARRIVALS control, no clipping, 48 dp targets, Android Back unchanged.
- Existing mission_hud, instruments and expedition tests pass unchanged.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)
