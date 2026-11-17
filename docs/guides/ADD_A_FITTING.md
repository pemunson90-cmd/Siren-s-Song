# Add a fitting

A fitting is a piece of hardware the player mounts on Quietus or a drone between dives, for example the Reach directional prism. There are 24 today. This guide describes the current path honestly: a fitting's row is data, but most effects are written as code that checks the item ID, so expect to touch 2 to 8 files (see `.fable/SURVEY.md` section 4). Paths are relative to `game/src/`.

## What Pat decides first

Read [AGENTS.md section 4](../../AGENTS.md#4-rules-that-are-pats-call). A fitting that changes a protected rule (Siren senses, the lock warning, beam, collision, damage, hull, the sight-only Hunt, photography exposure or grading) is Pat's call, and no fitting may disable a Siren permanently. Its name, benefit and cost lines are player-facing text: write them plainly and in the style of the existing rows, and ask Pat when the fitting is tied to the story (for example alien research hardware).

## Steps

1. **Add the row.** Add an entry to `ITEMS` in `equipment/equipment_catalog.gd` with the same keys as its neighbours: `id` (equal to the key), `name`, `compatible_slots` (`quietus`, `drone_a`, `drone_b`), `mount` (one of the existing mount types: HARDWARE, SENSOR, UTILITY, CARGO, OPTICS or PROPULSION), `power`, `cargo`, `noise`, `endurance`, `benefit` and `cost`. `valid_fitting` and `reason` then accept it, the fittings menu lists it, and the power and cargo budgets count it.
2. **Make the effect.** There are two kinds:
   - **Additive stat.** If the effect is a change to a value that `Catalog.stat()` already sums (`noise`, `endurance`, and the optional `reach` and `speed` keys), the row alone is enough. `equipment/craft_upgrades.gd` turns these sums into passive reach, cruise speed, battery drain and life support.
   - **Behavior.** Anything else is code that asks `Equipment.has(fit,unit,"<id>")`. Put it in the owning module, as `simulation/advanced_sonar.gd` does for `quietus_prism`, and keep the simulation's evaluation order unchanged for existing fittings.
3. **Grant it.** A fitting appears only once the player is entitled to it. Pick one source: `RECOVERY_GRANTS` or `recovered()` in `equipment/craft_upgrades.gd` (granted on recovering an operation), `GRANTS` in `campaign/early_reward/reward_table.gd` (early operations), `PROJECTS` in `campaign/photo_intel.gd` or the recipes in `campaign/glass_research.gd` (research), or an economy unlock.
4. **Price and classify it.** If it can be bought, repaired or researched, add it to `campaign/economy_table.gd` (for example the `ALIEN` list for research hardware).
5. **Presentation, if needed.** Fittings with their own instrument or summary line also appear in `presentation/equipment_context.gd`, `presentation/fleet_instruments.gd`, `presentation/module_recovery_view.gd` or `presentation/expedition_operations.gd`. Search for a similar fitting's ID to find these, for example `grep -rn '"quietus_prism"' game/src`.

## Saves

A fit stores item IDs only. Never rename or remove an existing ID: saved fits, entitlements and Career riders refer to them, and an unknown ID makes `valid_fitting` reject the saved fit.

## Tests

- Add `<fitting>_tests.gd` for its effect and register it in `game/tests/suites.txt` ([TESTING](../TESTING.md)).
- Run import, core, `craft_upgrades_tests`, `loadout_frames_tests`, `field_tools_tests` and `campaign_equipment_save_tests`, plus the suite of the module that implements the effect. `loadout_ui_tests` checks the fittings menu.
