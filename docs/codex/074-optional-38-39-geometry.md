# Handoff 074: NEW GEOMETRY FOR OPTIONAL OPS 38 AND 39

Status: CLAIMED
Claimed at: 2026-10-28 01:26:30 UTC
Claimed by: codex-root-parallel
Finished at:

Precondition: none beyond ORCHESTRATION. Scout note: None. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Author fresh terrain for ops 38 and 39 (new world size, a different start and recovery mouth, 2 to 3 new landmarks) in the same region palette, keeping each op's one photographed objective and bonus.
Add one real decision per op using existing pieces only: for 38 a middle-depth roof versus a deep contour with a noisy W.machine shortcut, for 39 a masking exhaust front versus a longer outer route with passive information.
Leave op 40 as is; it shares Confluence geometry by design.
Bare Quietus must still finish both.

Spec basis: Spec: 'varied map sizes/topologies/depth connections must contain meaningful decisions' and 'Each mission must force meaningfully different decisions'; optional operations are meant to be distinct jobs, not repeats.
Evidence it is missing: optional_operations.gd _water() copies world_size, rocks, structures, sirens, currents, depth_geometry and thermal fronts from Divergence.make(7) for op 38 and Divergence.make(8) for op 39 (and from Resolution.make(11) for 40), then only swaps objectives. Players who just finished 7 and 8 re-enter the same water with new photo targets. Ops 38 and 39 declare 'No new simulation rules' and add no work task or alternate crossing beyond a roof rect (38) or a note in the brief (39).

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-optional-geometry

## Files you may edit
campaign/optional_operations.gd (_deep, _shelf), new campaign/encounters/optional_layouts.gd, presentation/landmarks/landmark_data.gd entries

## Files you must not touch
Changing prerequisites, route gating (38 deep, 39 shelf) or record keys glass_record_38/39; new simulation rules; em dashes. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Existing optional-op photo-row journey fixtures for 38 and 39 updated for the new geometry; one bare-Quietus journey each. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
[KEEL: verified WIP] claude/lane-optional-geometry at 007405f5e31f1316b5f93100c07764d71ac532b7; PR https://github.com/pemunson90-cmd/Siren-s-Song/pull/162.
Import/core846/0 and two bare journeys18/0; reconciled88188bd0; guidance green; game-smoke40621198714 attempt1 ops_home_ui 480s timeout without assertions; unchanged-head failed-job retry pending. Claim remains active; only074.
Three local landmark metadata entries per map; shared renderer hook deferred to root/076.
