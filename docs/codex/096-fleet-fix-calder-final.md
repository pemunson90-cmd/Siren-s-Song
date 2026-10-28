# Handoff 096: MAKE THE FLEET MATTER IN CALDER AND THE FINAL OPS (30 to 36)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 088 is DONE (PR193 merged) so endings are settled. Not owned by another CLAIMED handoff. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

Source: 093 report (docs/design/FLEET_MATTERS_2026-10-28.md, Codex fresh session, 28 Oct) and Pat's 28 Oct finishability ruling. AI-DESIGNED scope; Pat ratifies.

## Task (plain language)
093 measured 30, 31, 32, 33, 35 and 36 as WAYPOINT (Hunt 9.2 to 17.2, no lock warnings, 81 to 89 percent oxygen, full hull). It measured 34 Beneath the Well as UNMEASURED: bare finished with Hunt 33 and 40 hull, but the equipped recovery was incomplete. The end of the campaign should be its hardest, most fleet-dependent stretch.

For each op apply 1 to 3 patterns:
- **Pattern 3 and 1:** 30 and 31 skip their bonus images; make the best evidence need a drone viewpoint and earned bearings, while the required photo stays bare-reachable.
- **Pattern 4:** existing roles placed on the work in 32, 33, 35 and 36 (093 notes the lift and breaker shortcuts are skipped bare: make the shortcuts worth their exposure and the long way costly).
- **Pattern 5:** endurance set so a careless bare finale runs short.
- **34:** complete the equipped journey (full recovery flow) and confirm it is clearly better than bare; keep its three stages.
093's top-5 list includes 31.

Do not change carry rows from 085 except where a placement change requires updating the matching row, and keep the empty-history equality test green. Do not touch ending resolution.

## Files you may edit
game/src/campaign/calder_trench_operations.gd and its layout data, Calder and final-pair journey suites and controllers, briefing lines, reward hooks in existing systems, shared registration lines. Also game/src/campaign/onboarding2/briefing_rows.gd and onboarding_text.gd for the changed ops only (067/PR195 added GOAL/DANGER/NEW THIS DIVE rows; keep them true to the new jobs and name the equipped option in one line).

## Pat's rule (28 Oct, verbatim in USER_DIRECTIVES via PR194)
A bare launch (no finite tools) finishing an op is a skill feat for a skilled player: possible, demanding, with worse results. Planning, drones, tools and progression must change the outcome. The game must not feel like a walking simulator in a submarine.

## Hard limits
No change to Siren senses, lock timing (4 s interruptible), beam lethality, collision, damage or hull rules, photography design, art direction or ending conditions. Existing Siren roles keep their behavior; you may change **where Sirens are placed and their authored patrol points**, objectives, work sites, endurance values, optional tiers and rewards. A required route is never gated behind a finite tool or a losable drone. No save-format change unless a new fact is unavoidable (one key, old saves default absent). Story text: 1 to 2 line placeholders, no em dashes.

## Method
Use `docs/design/FLEET_MATTERS_FIX_PATTERNS.md` (patterns 1 to 8) and `docs/design/FLEET_MATTERS_2026-10-28.md` (the 093 measurements, harness at C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/093). Reuse the 093 harness for the before and after numbers.

## Success measure (per op)
Rerun the 093 bare and equipped pair on the changed source:
- **Bare** (STANDARD) still finishes, and **meets the Sirens**: in at least three quarters of the batch's ops the bare route shows a Hunt peak of 20 or more or at least one received lock episode, from placement and authored patrol points of existing roles at the work (pattern 4). Endurance-only pressure (oxygen under 25 percent with Hunt 0) counts for at most a quarter of the ops and must not be the main lever. A route the Sirens never notice is still a walk (Claude S5 correction 28 Oct 14:27 ET after PR198).
- **Equipped** must not take clearly more hull than bare unless the PR states the tradeoff is deliberate; otherwise the fleet reads as the riskier choice.
- **Equipped** (drones used plus plausible tools and fittings for that point in the campaign) is clearly better on a major axis: people or cargo, photo records or grade, recovered material, side objective, reward, or a safer exposure profile.
- The equipped journey must complete the full recovery and departure flow (093 noted INC endings; fix the controller, do not skip the flow).
Report the before and after table rows in the PR body and the Completion lines.

## Checks
Import + core; the region's existing journey suites (update source-known routes where placement changed; never relax a check); the 093 pair rerun for each op. Suite ranks: next free in your block.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; one LEDGER line.

## Completion
(five lines max: per-op before/after class and the main pattern used)
