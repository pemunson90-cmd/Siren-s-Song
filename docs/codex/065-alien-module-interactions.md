# Handoff 065: Give the two new alien modules (Trench wellhead seal, Choir reed tuner) a world interaction, like the other four alien modules have

Status: OPEN
Claimed at: 
Claimed by: 
Finished at:

Precondition: 055 is DONE. Scout note: Handoff 055 / PR150 merged (the two modules exist only there). Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Add one small physical interaction per module, built on the existing Reach work-site primitives (W.machine with a glass_effect, the decoder hook in glass_reach_work.gd).
1. Wellhead seal: a Quietus carrying it can finish marked local machinery work in about half the audible time and half the noise radius. Reuse the decoder's pattern, add an optional needs-item field to W.machine, and keep the benefit text honest.
2. Reed tuner: a drone carrying it can work a tagged reed or service site quietly from the drone's own position. Bare craft keep the loud 12 s route.
3. Author the use sites as optional work in existing ops 34/35/36 and optional ops 37 to 40. They appear for everyone and pay off in time, noise or a shorter withdrawal. Do not make them required.
4. Mark all numbers AI-DESIGNED, add 1 to 2 line placeholder briefing text, and decide whether the stat bonus stays alongside the interaction (default: keep it).

Spec basis: CURRENT_GAME_SPEC: "Research combines evidence and resources to unlock practical modules, world interactions, routes or strategic capabilities. Lore alone is not the reward." Acceptance: "demonstrated equipment/artifact usefulness".
Evidence it is missing: The four older alien modules each have a dedicated world consumer. quietus_pressure_sleeve is read in simulation/depth_bands.gd, drone_traction_yoke in industrial_jobs.gd, quietus_prism in advanced_sonar.gd and quietus_decoder in glass_reach_work.gd. On origin/claude/c2-equipment, quietus_wellhead_seal (+40% life support, +15% noise) and drone_choir_tuner (+30% passive reach, +15% noise) are pure stat multipliers. A git grep of both ids finds hits only in equipment_catalog.gd, economy_table.gd and glass_research.gd RECIPES. The Calder artifacts that award them (trench_seal_core from op 32, choir_reed from op 33) pay off with no new physical decision anywhere in Calder or the optional ops.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-alien-interactions

## Files you may edit
game/src/simulation/glass_reach_work.gd, game/src/campaign/encounters/work_sites.gd, game/src/campaign/encounters/calder_layouts.gd, game/src/campaign/calder_trench_operations.gd, game/src/campaign/optional_operations.gd, game/src/equipment/equipment_catalog.gd (benefit/cost text only)

## Files you must not touch
Do not change Siren senses, beam or lock timing. Do not gate any core objective on the modules; bare Quietus must still finish ops 32 to 34. No new story beyond 1 to 2 line placeholders. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
One journey per module showing the site completes faster or quieter with it. The existing bare-Quietus Calder journeys must stay green. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
