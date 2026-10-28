# Handoff 099: SILENT RUNNING COSTS REAL TIME (player-side; Siren senses unchanged)

Status: BLOCKED
Claimed at: 28 Oct 2026 16:44 ET (Claude launch)
Claimed by: codex-fresh-099, claude/silent-speed
Finished at: blocked stop 2026-10-28 21:23 UTC

Precondition: none. Do this before 094 is relaunched. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Pat's ruling (verbatim, 28 Oct 2026 ~16:41 ET)
Claude asked: "may I make silent running clearly slower, so going quiet everywhere costs real time and oxygen? Players would go silent near patrols and cruise elsewhere, and the drones and tools (decoys, scouting the patrol cycle) would matter more. Siren senses stay untouched; this changes only the sub's own speed. I recommend yes." Pat: "Sure".
The exact numbers are AI-DESIGNED for Pat to ratify.

## Why
094 failed three times. In SILENT running a skilled bare Quietus stays outside the 180 m silent Siren sight almost for free: 094b measured only 4 to 14 s per op versus cruise at the crossings. So "silent everywhere" dominates, and the late game plays like a walk.

## Task (plain language)
1. **Measure first.** On the current integration head, for each core op 0 to 36, run the existing bare route in SILENT throughout and in CRUISE throughout (reuse the 093 harness at C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/093). Record time, oxygen used and whether it finishes. Find where Quietus's silent speed is set: `simulation.gd` `_craft_speed`, `CraftUpgrades.cruise_speed`/`frame_speed`, and `RouteProgram.speed` (per-waypoint propulsion programming), plus `photo_rules/rule_table.gd` CRAFT_SPEED silent 42 / cruise 78 as a reference.
2. **Choose a Quietus silent speed** so that:
   - silent-everywhere takes clearly longer than a skilled mix (silent near patrols, cruise in open water), roughly 30 percent or more extra time on most core ops
   - the bare silent-everywhere route is tight on oxygen or runs out in at least a third of the core ops
   - a skilled mixed route still finishes every required op on STANDARD.
   Prefer one number. A per-hull factor is fine if hulls already scale speed (`quiet` hull should keep a real advantage). Keep acceleration and coasting physics; do not change ALL STOP.
3. **Drones:** leave the drone QUIET drive mode unchanged unless measurement shows drones become the new free walk. If so, say so in the PR; do not change them in this handoff.
4. **Never change** Siren sight or hearing ranges (180/290 m and hearing radii), lock timing, beam, collision, damage, hull rules or the motion-noise formula. Only Quietus's travel speed while SILENT changes.
5. **Journeys:** existing source-known journeys that now time out should switch to a skilled mix (route programming with cruise legs in open water) rather than have checks relaxed. Never relax a check.
6. **Teaching:** one tool-help/briefing line: "SILENT is slow. Go quiet near patrols, cruise in open water." (No em dashes.)
7. Docs on integration: Pat's ruling verbatim at the top of `docs/USER_DIRECTIVES.md`; MODULES.md row; the chosen number and the measurement table in the PR.

## Files you may edit
The speed seam(s) for Quietus SILENT travel, journeys/controllers that need cruise legs, tool help / briefing line, tests, docs as listed, shared registration lines.

## Files you must not touch
Siren senses, sight/hearing radii, lock, beam, collision, damage, hull rules, noise formula, drone drive modes (see 3), photography design, mission layouts owned by fleet-fix handoffs 094 to 097. Files owned by any other CLAIMED handoff.

## Checks
Import + core. One new suite: silent speed is below the chosen bound; silent-everywhere vs mixed time ratio on 3 representative ops; a mixed bare route still finishes those ops on STANDARD. Rerun journey suites for every op whose timing changed (CI shards cover the rest).

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; one LEDGER line. Then Claude relaunches 094 and asks open fleet-fix sessions to re-measure.

## Completion
- BLOCKED; candidate6m/s frozen uncommitted at tree db1c475fce0fcc2a8bad0fcd3ecc88e3c5d02a4d, base a658c2ca. No gameplay commit, PR or merge.
- [KEEL: measured] All37 measurements on1b56be6f (before096): SILENT42 wins29, CRUISE78 wins15, no oxygen-tight cases. Same-source candidate6 has19/37 at<=20% reserve, including14 oxygen losses.
- Import/core842/0, Glass70/0 and new suite14/0 pass; its full-route comparisons are one actual mixed policy plus two all-CRUISE policies, ratios5.69 to7.31.
- Required mixed bare8/10/11/12 remain unproven; affected recipient suite58/1 and latest Calder SILENT29/8 fail, pressure3/7 below the existing5 floor. Protected changes are not established as necessary.
- Recovery: `C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/099/` contains frozen-candidate.patch, frozen-source.json, measurement-table.csv and independent-review.txt. Resume with bounded source-known routes and preserved checks; other claims remain untouched.
