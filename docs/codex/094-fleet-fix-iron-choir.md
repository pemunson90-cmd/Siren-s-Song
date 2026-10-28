# Handoff 094: MAKE THE FLEET MATTER IN THE IRON CHOIR (ops 22 to 29)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none beyond the files below being unclaimed. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

Source: 093 report (docs/design/FLEET_MATTERS_2026-10-28.md, Codex fresh session, 28 Oct) and Pat's 28 Oct finishability ruling. AI-DESIGNED scope; Pat ratifies.

## Task (plain language)
093 measured every Iron Choir op (22 to 29) as WAYPOINT: the bare runs finished with **Hunt 0.0, no lock warnings and 75 to 86 percent oxygen left**. Quietus does every job in sequence, alone, unseen. This is the worst region in the game for Pat's concern and the first fix batch.

For each of ops 22 to 29, apply 1 to 3 patterns so the region becomes a working industrial site under guard:
- **Pattern 4 (placement):** put existing Siren roles where the work is, so sequential solo work draws attention and the bare route has to time gaps.
- **Pattern 2 (two places at once):** 093 names the sequential jobs (22 sled release and gate, 23 valves, 24 ballast and yoke, 27 chocks and winch, 28 two decompression stops, 29 breaker and reconnect). Make at least half of these ops pay off for parallel work: a drone holds a station while Quietus works, or a timed window that one craft can only just make.
- **Pattern 1 (outcome tiers):** 25 Last Shift and 28 Names in the Bell carry people. Fuller rescue (everyone, faster, quieter) should need the fleet; bare lands the minimum.
- **Pattern 5 (endurance):** tighten oxygen so a careless bare sequence runs short and planning has margin.
093's top-5 list includes 22, 25 and 28; start there.

Do not touch the choir_choice / choir_plant fact values (088's ending rule reads them).

## Files you may edit
game/src/campaign/iron_choir_operations.gd and its encounter/layout data, Iron Choir journey suites and controllers, reward hooks in existing systems, briefing lines for these ops, shared registration lines.

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
