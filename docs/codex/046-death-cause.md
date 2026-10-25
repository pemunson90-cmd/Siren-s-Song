# Handoff 046: DEATH CAUSE, one plain line saying why the player was found

Status: DONE
Claimed at: 2026-10-24 23:34:02 UTC
Claimed by: claude (orchestrator, split with Codex by Pat 24 Oct)
Finished at: 2026-10-25 02:10:00 UTC

Precondition: none. Source: docs/design/COLD_REVIEW_3.md finding F9 (continues COLD_REVIEW_2 B1). Presentation only, read-only from records that already exist. AI-DESIGNED proposal, Pat to adjust wording.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers in a data table, optional validated save fields, revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Change no oxygen, hull, combat, beam, collision, damage or Siren sight, hearing or lock rule; no detection change of any kind. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
Today a beam death says where ("Last observed S1 at 176 m before the beam hit Quietus.") but not why the Siren came. Add ONE more plain line under it on the loss debrief, for example "It was drawn by: ACTIVE SONAR 6 s before the lock." or "It heard Quietus moving at speed." or "Quietus entered its sight line while moving quietly." If no cause can be shown from records, show nothing (never invent a cause).

### What records exist (verified in source at 30f555a)
1. game/src/presentation/loss_summary.gd, `line(sim)`: the existing seam. It already reads `sim.contacts` (each entry: pos, time, mode LOCKING or BEAM, target, type, source "optical"), `sim.units`, `sim.elapsed`, `sim.hull`, `sim.oxygen`. It is called from game/src/presentation/expedition_operations.gd:65 and game/src/presentation/flow/campaign_flow.gd:176. Extend this module or add a sibling module called from the same two lines.
2. `sim.noises` (simulation.gd:87, appended by `_noise()` at :695): each entry has label ("ACTIVE SONAR", "CAMERA", "DISRUPTION", "KNOCKDOWN", "RECON UPLINK", "DECOY" ...), pos, radius, band. They live only about 2 s (`noises.filter(time>0)` at :734), so by the time of the debrief the list is empty. There is NO history. Do not make Simulation keep one.
3. `signal siren_notice(id, source_position)` (simulation.gd:3, emitted at :1129 when `craft_heard or detected>=0`). game/src/presentation/first_siren_cue/notice_tracker.gd already listens to it without writing anything. It carries no cause.
4. `NoticeSources.CRAFT_EMISSIONS` (cue_table.gd) names the own-craft emission labels.
5. Sirens carry `mode`, `suspicion`, `last_known`, `attention_time`, and the recon/`Sweeper.note_heard` data, but these are Siren state, not records of why. Do not read them as a cause.
Finding to report: the sim does not store a cause. A read-only cause line therefore needs a presentation-side observer, like notice_tracker, that is bound to the existing signals/arrays and keeps a small ring buffer of the last 20 s. Choose the least invasive of these and say which you chose:
- (A, preferred) a new presentation observer (for example game/src/presentation/death_cause/cause_log.gd) that each frame copies the labels of `sim.noises` whose label is in CRAFT_EMISSIONS plus whether any own craft had `sim.motion_radius(id)` above a table threshold (propulsion), with `sim.elapsed` and unit name, into a ring buffer of the last 20 s. It never writes to sim. It is cleared on mission change (use the `is_same(mission_ref, sim.mission)` / elapsed-decrease pattern in notice_tracker.gd `_observe_clock`).
- (B) if (A) cannot be done read-only at a sampling rate that does not miss a 2 s noise (it can, `_process` runs every frame, but tactical pause and test stepping do not call it), say so and fall back to the sentence only when the cause is the visual contact already in `sim.contacts` ("Quietus was in sight at N m when the Siren turned").
Cause choice rule (table-driven, in the module): the most recent own emission within 20 s before the first LOCKING contact; else propulsion above the table threshold; else "Quietus was in the Siren's sight line." only if the last contact `source=="optical"`; else no line. Oxygen and hull losses keep their current lines and get no cause line.
Add the buffer to the save only if the debrief can be reached after a reload; otherwise do not persist and show no cause (optional validated field, absent is valid).

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-death-cause

## Files you may edit
loss_summary.gd (or the new sibling module), the new observer and its table, the two debrief call lines, tests.

## Files you must not touch
simulation.gd detection, hearing, sight, lock or noise code; Siren behaviour; combat; hull; oxygen.

## What done looks like
- A beam death after an active ping shows the ping as the cause, a death after fast movement shows movement, a death in plain sight shows sight, and a death with no record shows no cause line. Oxygen deaths unchanged.
- Test: replay at least three scripted deaths (ping, fast motion, sight only) and assert the line, and assert `sim.snapshot()` is byte-equal with the observer on and off (proves read-only). The existing fix2_state_tests loss assertions still pass unchanged.
- By real touch at both Fold7 shapes (2520x1080 and 2184x1968, helpers in tests/fix2_menu_ui_tests.gd): the loss debrief shows the new line without clipping and the buttons keep 48 dp targets and Android Back works.
- Revert note in the module header: remove the one call line and the new folder.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board. In Completion say which option (A or B) you used and what the sim did not record.

## Completion

DONE by Claude (orchestrator). PR135 via batch PR140 (merge 246eb72). Loss debrief shows one plain cause line (an own emission or loud motion the Siren reacted to within 3 s, else the sight line, else nothing). Presentation-side observer with a bounded 20 s ring buffer; simulation.gd untouched; log not persisted (no line after reload). Review found and fixed over-blaming of stale noises (counterexample test added). Tests: death_cause 46/0, death_cause_ui 44/0, core 835/0. Wording is AI-DESIGNED for Pat to adjust.
