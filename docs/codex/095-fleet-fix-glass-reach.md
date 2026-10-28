# Handoff 095: MAKE THE FLEET MATTER IN GLASS REACH (ops 14 to 21)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 089/PR191 (earned chart on 14, 15, 16, 20) is merged, so you build on the earned chart. Not owned by another CLAIMED handoff. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

Source: 093 report (docs/design/FLEET_MATTERS_2026-10-28.md, Codex fresh session, 28 Oct) and Pat's 28 Oct finishability ruling. AI-DESIGNED scope; Pat ratifies.

## Task (plain language)
093 measured 14 to 20 as WAYPOINT (Hunt 9.2, no lock warnings, 74 to 90 percent oxygen) and 21 UNMEASURED (bare got one warning; equipped recovery incomplete). 15 and 20 lose hull to collisions, but that is terrain, not tactics. 093 measured this before the earned chart (PR191) landed, so first rerun the 093 pair on the current head and work from those numbers.

For each op apply 1 to 3 patterns:
- **Pattern 3 (earned information):** with the chart now earned, place the required receiver or account and the safe gap where scouting (drone, Sonobuoy, Survey) finds them safely and a bare sub finds them by exposure.
- **Pattern 4 (placement):** existing guards near the work and the shortcuts (19's decoder shortcut, 14's hidden optional photo).
- **Pattern 6 (progression):** Glass research and the alien modules (065) should open quieter or shorter paths here; the bare route is longer and louder.
- **Pattern 1:** optional photos and records that need a drone viewpoint.
093's top-5 list includes 14.

Keep the glass_choice fact values unchanged (088 reads them). Keep the earned-chart policy from 089.

## Files you may edit
game/src/campaign/glass_reach_operations.gd and its layout data, glass_reach_journeys and related suites and controllers, briefing lines, reward hooks in existing systems, shared registration lines.

## Pat's rule (28 Oct, verbatim in USER_DIRECTIVES via PR194)
A bare launch (no finite tools) finishing an op is a skill feat for a skilled player: possible, demanding, with worse results. Planning, drones, tools and progression must change the outcome. The game must not feel like a walking simulator in a submarine.

## Hard limits
No change to Siren senses, lock timing (4 s interruptible), beam lethality, collision, damage or hull rules, photography design, art direction or ending conditions. Existing Siren roles keep their behavior; you may change **where Sirens are placed and their authored patrol points**, objectives, work sites, endurance values, optional tiers and rewards. A required route is never gated behind a finite tool or a losable drone. No save-format change unless a new fact is unavoidable (one key, old saves default absent). Story text: 1 to 2 line placeholders, no em dashes.

## Method
Use `docs/design/FLEET_MATTERS_FIX_PATTERNS.md` (patterns 1 to 8) and `docs/design/FLEET_MATTERS_2026-10-28.md` (the 093 measurements, harness at C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/093). Reuse the 093 harness for the before and after numbers.

## Success measure (per op)
Rerun the 093 bare and equipped pair on the changed source:
- **Bare** (STANDARD) still finishes, and shows real risk: at least one received lock episode, OR a Hunt peak of 20 or more, OR an oxygen margin under 25 percent.
- **Equipped** (drones used plus plausible tools and fittings for that point in the campaign) is clearly better on a major axis: people or cargo, photo records or grade, recovered material, side objective, reward, or a safer exposure profile.
- The equipped journey must complete the full recovery and departure flow (093 noted INC endings; fix the controller, do not skip the flow).
Report the before and after table rows in the PR body and the Completion lines.

## Checks
Import + core; the region's existing journey suites (update source-known routes where placement changed; never relax a check); the 093 pair rerun for each op. Suite ranks: next free in your block.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; one LEDGER line.

## Completion
(five lines max: per-op before/after class and the main pattern used)
