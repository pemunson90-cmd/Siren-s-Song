# Handoff 076: ARC 6 DISTINCT TOPOLOGIES AND A STAGED CAPSTONE FOR OP 34

Status: CLAIMED
Claimed at: 2026-10-28 00:48:49 UTC
Claimed by: codex-root-resume
Finished at:

Precondition: none. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Re-author arc 6 geometry so each of ops 30 to 36 has its own world size, start, recovery mouth and main traversal shape (for example a vertical shaft, a long gallery, a ring around the casing), instead of one 2800x2800 box.
Turn op 34 'Beneath the Well' into a 3-stage capstone using the existing W.machine and cargo pieces only: three machine work sites in sequence, each opening the next gate, one noisy shortcut and one quiet longer route, with the roster escalating per stage. No new simulation rules.
Give 30 and 31 one local work task each (use the existing W.machine or W.listen helpers) so they are more than two photographs.
Keep every core op finishable by bare Quietus with no finite tools.

Spec basis: Spec: 'varied map sizes/topologies/depth connections must contain meaningful decisions rather than empty travel' and 'Each mission must force meaningfully different decisions... escalating understanding.' Story bible arc 6: 'Shut in the well by hand; the full noise budget of everything learned.'
Evidence it is missing: Calder ops 32 to 36 all use world_size 2800x2800 and the same start and recovery (350,2450) (calder_layouts.gd row defaults). All five are one template: two photos plus one W.machine whose effect dictionary is identical (calder_trench_operations.gd:41-44), with 4 guards from the same buoy/relay/warden/hunter/patroller set. Final pair 30 and 31 are two-photo ops with 2 Sirens, no work task, and a briefing of 'Photograph the core mark in MIDDLE and recover Quietus' (expedition_operations.gd:15); region_table.gd gives them the Iron look. Op 34, the last core op and the END OF LINE trigger (finale_table.gd LAST_ID=34), is the same template as 32 and 33, so the campaign ends without a capstone. Iron Choir (22 to 29) shows the authored bar: sequential locks, towed loads, moving freight.

Orchestrator note: Claude lane C11.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/c11-arc6-capstone

## Files you may edit
campaign/encounters/calder_layouts.gd, final_survey.gd, final_marks.gd, new campaign/encounters/calder_capstone.gd, campaign/calder_trench_operations.gd, campaign/final_pair_operations.gd; retune presentation/landmarks/landmark_data.gd entries for moved sites if needed

## Files you must not touch
New Siren behaviors or senses; changing finale trigger op id or endings logic; reducing any current objective count that the photo wall or route map reads; em dashes in added text. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Update calder_trench_journey_tests.gd for the new geometry (bare Quietus completes 30 to 34); one finishability journey for the new 34 capstone as the core-op rule requires; route_map_tests.gd and finale_provisional_ui_tests.gd must still pass unchanged. Never more than ORCHESTRATION section 5 requires. Suite ranks: local 540-549, CI 640-649.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

Codex recovery: owned source WIP9f6549b5 pushed on claude/c11-arc6-capstone before merging fresh integration abd15c88 (merge5f07f634).
CLAIMED by codex-root-resume; bounded Sol6.1-medium implementation worker completing only076 Calder/final-pair content and named bare-Quietus checks.
Generated imports/UIDs preserved outside commits; no077, APK or protected-mechanics changes. PR/checks pending.
