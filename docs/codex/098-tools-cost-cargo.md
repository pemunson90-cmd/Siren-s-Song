# Handoff 098: CARRYING TOOLS COSTS CARGO (loadout becomes a real plan)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none of the files below claimed by another handoff. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Pat's ruling (verbatim, 28 Oct 2026 ~14:13 ET)
Claude asked (QUESTIONS_FOR_PAT 13): "today every loadout gets a fixed free bundle of tools. Should carrying tools cost module slots or cargo space, so a tool-heavy loadout means giving up a module? I recommend yes, because it turns the loadout into a real planning choice." Pat: "Yes to your open question."
The exact design below is AI-DESIGNED for Pat to ratify. It serves Pat's 28 Oct rule that planning, tools and drones must change the outcome (093 found most tools never decisive).

## Task (plain language)
Today `game/src/equipment/field_tools.gd` gives each campaign loadout (endurance, disruption, survey) a fixed free tool bundle, outside the hull and chassis budgets in `equipment_catalog.gd` (power, cargo, mounts per craft).

1. **Tool racks use cargo.** Each craft (Quietus, drone A, drone B) carries finite tool charges in its cargo budget. Give each tool a small cargo weight (light: Decoy, Sonobuoy, Disrupt; medium: Survey, Torpedo, Silt screen; heavy: Hull patch, Relay buoy). More tools leave less cargo for modules and winch work, and fewer tools free room for modules.
2. **The carrying craft uses it.** A tool is deployed by the craft that carries it, if the existing order code can do that without changing a tool's effect. A drone carrying Sonobuoys or a Relay buoy can place them forward; that is new planning, not a new rule. If an existing owner (emp, decoy, recon, knock in sim.tools/weapon_orders/sensor_orders) is Quietus-only today, keep it Quietus-only and state that in the PR.
3. **Loadouts become templates.** ENDURANCE, DISRUPTION and SURVEY become one-tap starting fills of the racks, editable on the fittings screen (064 surface). Show the cargo used and left per craft. 48 dp targets, Back handled.
4. **Economy.** Charges beyond the free template cost resources through existing manufacturing (054). On ACCESSIBLE the template stays free. An **empty rack is always launchable** (Pat's floor: bare finish stays possible).
5. **Saves.** One per-profile rack field, with old saves migrated to the template their loadout used. Ironman respects it.
6. **Keep test controllers working.** Journeys and the 093 harness that call `initial_counts(loadout)` or supply tools directly must still work. Keep that API as "template fill", so 094 to 097 fleet-fix journeys keep passing.
7. Docs on integration: add Pat's ruling verbatim to `docs/USER_DIRECTIVES.md`; mark QUESTIONS_FOR_PAT 13 ruled; update MODULES.md rows.

## Files you may edit
equipment/field_tools.gd, equipment/equipment_catalog.gd (tool cargo weights only), the fittings/briefing surface for racks, tool order seams only where needed for item 2, economy hooks for charge cost, save/profile field plus migration, field_tools_view.gd, tool_help.gd lines, tests, docs as listed, shared registration lines.

## Files you must not touch
Tool effects (stun time, decoy pull, silt duration, repair amount and so on), Siren senses, lock, beam, collision, damage, hull rules, photography design, mission data owned by 094 to 097. Files owned by any other CLAIMED handoff.

## Checks
Import + core. One new suite covering:
- the cargo arithmetic per craft
- a template fill equals the old counts
- an empty rack launches
- a drone-carried tool deploys from the drone (if item 2 applies)
- an old save migrates
- the Ironman lock is respected
- the fittings UI at both viewports
Rerun the field tool, economy, fittings and save suites.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; one LEDGER line.

## Completion
(five lines max; list the cargo weights chosen and whether drones deploy tools)
