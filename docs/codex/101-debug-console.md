# Handoff 101: DEBUG CONSOLE (developer tools for playtesting and diagnosis)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Pat (verbatim, 28 Oct 2026 ~17:43 ET)
"I think maybe we need a debug console."
Scope below is AI-DESIGNED by Claude for Pat to adjust. Purpose: let Pat and the critics jump straight to any situation and see why an op plays the way it does, especially the walking-simulator problem (093, 094 to 097, 099).

## Task (plain language)
A developer console that exists only in debug builds (`OS.is_debug_build()`), which is what Pat runs on the phone today. Open it from Settings > Developer, and in a dive with a three-finger long press. Touch-first: 48 dp buttons, plus a text command line with history for the desktop.

1. **Jump and set up (between dives):**
   - Launch any op 0 to 41 with a chosen history preset: thread deep or shelf, Confluence concealed or overt, the late votes, Sorley found or not.
   - Set or clear any campaign fact.
   - Mark ops complete.
   - Grant resources, tool charges, modules, hulls and chassis.
   - Unlock everything.
2. **See what is hidden (in a dive, overlays toggle independently):**
   - Siren sight radii (180 m silent / 290 m cruise, scaled by Hunt) and hearing ranges.
   - Each Siren's patrol points and current state.
   - Live Hunt value.
   - Lock timers.
   - Quietus motion-noise radius.
   - Oxygen and endurance margin.
   - Cargo and winch places.
   - Earned-chart cells.
   Overlays are drawn only while the console says DEV.
3. **Bend time and survival:**
   - Time scale 0.25x to 4x.
   - Pause-step.
   - An invulnerable toggle (locks still play and count, nothing dies).
   - Refill oxygen.
4. **Measure:** a DEV debrief panel with the 093 metrics for the dive just played: time, hull, Hunt peak, received lock episodes, oxygen margin, tools spent, drones used. Plus "Export run log" (JSON through the existing share/export path, so Pat can send it).
5. **Safety:**
   - Any console change marks the profile or run DEV. DEV runs never count for Ironman, challenge bests, expedition records or career standing, and the UI shows a small DEV badge.
   - The console only changes state and visibility. It never changes rules: Siren senses, lock timing, beam, collision, damage and hull rules stay as they are.
   - Release builds contain no console entry points.
6. Short help text inside the console listing commands. Docs: MODULES.md row, and a short `docs/DEBUG_CONSOLE.md` for Pat.

## Files you may edit
New `game/src/debug/` module and its view, minimal seams in main/flow/settings and the dive HUD, save flag for DEV, tests, docs as listed, shared registration lines.

## Files you must not touch
Simulation rules (senses, lock, beam, collision, damage, hull), mission data, protected items. Files owned by any other CLAIMED handoff (keep seams small to avoid collisions with 094 to 097 and 100).

## Checks
Import + core. One new suite:
- the console is absent in release mode (simulate the flag)
- jump-to-op with each history preset builds the right mission
- overlays draw without changing simulation hashes over 60 s
- the DEV mark blocks Ironman, challenge, record and career writes
- export produces valid JSON
- UI at both viewports
Rerun the save, profile and settings suites.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; one LEDGER line.

## Completion
(five lines max)
