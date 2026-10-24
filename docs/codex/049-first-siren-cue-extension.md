# Handoff 049: FIRST-SIREN CUE EXTENSION, op 1 and a one-time "new Siren type" note

Status: HOLD
Claimed at:
Claimed by:
Finished at:

HOLD: Pat gate. This is adjacent to Siren perception (it reads the same notice event that follows Siren hearing and sight), so Pat must release it. Codex does not start this until Pat sets Status: OPEN here and on the board. Pat said earlier: nothing on Siren sight, hearing or lock timing. This handoff does not touch those, but the gate stands.
Precondition: Pat release. Source: docs/design/COLD_REVIEW_3.md finding F8 (continues COLD_REVIEW_2 B3). Presentation only. AI-DESIGNED proposal, Pat to adjust.
Codex may merge: yes (after release), into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), first_siren_cue_tests (37 checks) and first_siren_cue_ui_tests (52 checks) plus new ones. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers in a data table, optional validated save fields, revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Change no combat, beam, collision, damage, hull, oxygen or Siren sight, hearing, lock or detection rule; the cue stays an observer and never a sensor. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
Today the cue covers player ops 2 to 4 only. Verified: game/src/presentation/first_siren_cue/cue_table.gd has `OPERATIONS=[1,2,3]` (ids; player op = id + 1), `DURATION=2.5`, and the notice tracker (notice_tracker.gd) drops every notice whose mission id is not in that list and shows each Siren id once. The chip text is built in first_siren_cue.gd `label_text()`: "NOTICE · FROM Q · 143°". Op 1 (id 0) already has a patroller and a sweeper but gets no cue, and later new Siren kinds (hunter on op 5, sentinel, warden, interceptor, buoy, relay) arrive unannounced.
1. Op 1: add id 0 to `OPERATIONS` (data change). Confirm the first notice on op 1 shows the chip once per Siren id and that the op 1 journey (opening_depth_journeys.gd) still wins bare with the same result.
2. One-time "new Siren type" note: the first time a Siren `type` (the `type` field read at simulation.gd:1001 contacts, `sirens[i].get("type","patroller")`) appears in a notice across the whole campaign, show a second one-line chip text such as "NEW SIREN TYPE: HUNTER" (a name table in cue_table.gd keyed by type; absent type shows nothing). It reads the type from the notice's Siren through the existing public `sim.sirens[id].type`; it adds no sim field and changes no signal. Persist "types seen" with the existing optional validated cue archive pattern (game/src/presentation/first_siren_cue/cue_archive.gd, extend the optional field to a list of type strings; absent is valid; reject malformed). Existing saves keep working.
3. Optional only if small: an arrow on the chart edge as well as the chip (review remedy). Skip it if it needs more than a draw call in the existing control.
4. Keep the 4 s lock banner and the warning pause exactly as they are.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-first-siren-cue-2

## Files you may edit
cue_table.gd, notice_tracker.gd, first_siren_cue.gd, cue_archive.gd, their tests.

## Files you must not touch
simulation.gd (including the siren_notice emit site), any detection or hearing code, Siren behaviour.

## What done looks like
- Op 1 shows the cue once per Siren id; the NEW SIREN TYPE note shows once per type, survives save and reload, and is absent on a repeat.
- Test: a snapshot of the simulation is byte-equal with the cue enabled and disabled across a scripted op 1 to 6 run (proves observer only).
- By real touch at both Fold7 shapes (2520x1080 and 2184x1968, helpers in tests/fix2_menu_ui_tests.gd and first_siren_cue_ui_tests.gd): chip and note are readable, do not overlap the lock banner, targets stay 48 dp, Android Back unchanged.
- Existing cue suites pass unchanged except where `OPERATIONS` is data-asserted (update that single expectation and say so).

## Return
PR into claude/integration after Pat releases. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)
