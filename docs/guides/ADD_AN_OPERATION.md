# Add an operation

An operation is one dive: a map, its Sirens, its objectives and its place in the campaign graph. Since WP-07 the per-operation metadata (region, route-map position, endurance budget and opening-arc gating) lives in one table, so a new operation needs a factory, a catalog row and a metadata row. Paths are relative to `game/`.

## What Pat decides first

Read [AGENTS.md section 4](../../AGENTS.md#4-rules-that-are-pats-call). The operation's story, briefing and dialogue text, its place in the branch structure, any ending condition it feeds, and its Hunt cap (a protected rule, ledger row SIREN-017) are Pat's call. Build with placeholder labels that already exist, or ask Pat for the text. Never write story text yourself.

## Steps

1. **Pick the next free ID.** IDs are contiguous because `CAPS` in `src/simulation/hunt_pressure/hunt_table.gd` is indexed by ID. Today the next free ID is 42.
2. **Write or extend the factory.** Put geometry, Sirens and objectives in a `<region>_operations.gd` file under `src/campaign/` (see [CONVENTIONS](../CONVENTIONS.md)). It must provide `make` or `build` and `supports_config`, and return a dictionary with `id`, `objectives`, `sirens`, `extraction` and `rocks`. Campaign operations also set `expedition_revision`.
3. **Add the catalog row.** Add a row to `CONTENT` in `src/campaign/operation_catalog.gd`, or to the `entries()` list of the factory that `_ensure()` already reads. Fill `factory`, `config`, `behaviors`, `prerequisites` (and `prerequisite_mode` for "any"), `facts`, `records`, `campaign`, `route` and `required_facts`. `valid_definition` rejects a malformed row.
4. **Add the metadata row.** Add one line to `ROWS` in `src/campaign/operation_meta.gd`:
   - `region`: a key of `STYLES` in `src/presentation/art/region_table.gd`. This one value picks both the regional art and the ambience bed.
   - `position`: a free route-map cell, `Vector2(column,row)`.
   - Optional `oxygen_seconds` and `drone_seconds`: authored endurance. Omit both to get 300 s and 240 s.
   - Optional `route_regions`, for example `{"shelf":"divergence_shelf"}`, when the region depends on the mission's `chosen_route`.
   - Do not set `arc` or `after`. They describe the opening tutorial sequence only.
5. **Add the Hunt cap, with Pat's value.** Append it to `CAPS` in `hunt_table.gd` at the index equal to the new ID. The protected golden (`tests/fixtures/protected_golden.json`) pins `CAPS`, so its owner must update that pin in the same change. Without an entry, `operation_meta.hunt_cap(id)` returns 1.0 and `hunt_cap_coverage_tests` fails.
6. **Place it in an arc.** Add the ID to the right arc's `ids` in `src/campaign/arcs/arc_table.gd` so Operations shows the arc heading and count.
7. **Optional hooks, only if the operation uses them:** carry rows (`campaign/carry/carry_table.gd`), photo subjects (`campaign/photo_ops.gd`), photo pricing (`simulation/photo_pricing/photo_pricing_data.gd`), photo rules (`photo_rules/rule_data.gd`), returned-film reveals (`campaign/route_map/route_graph_table.gd` `REVEALS`), fitting grants (`equipment/craft_upgrades.gd` `RECOVERY_GRANTS`) and ending inputs (`campaign/endings.gd`, Pat's call).
8. **Check for literal IDs.** Some code still names operation IDs directly, for example `src/main.gd`, `src/presentation/flow/campaign_flow.gd` and `finale_table.gd` `LAST_ID`. A new operation that should share such behavior needs a change there.

## Tests

- Update the pinned counts: `route_map_tests` expects 42 positions, and `operation_meta_parity_tests` compares against `tests/fixtures/operation_meta_golden.json`. After a reviewed change, regenerate the golden with `-- --regenerate` (see that suite's header) and review the diff: only the new operation's entries and graph nodes may change.
- Add a `<feature>_tests.gd` for the operation's own rules and register it in `tests/suites.txt` ([TESTING](../TESTING.md)).
- Run import, core, `operation_meta_parity_tests`, `operation_catalog_tests`, `route_map_tests`, `hunt_cap_coverage_tests`, `operation_endurance_tests` and `regional_settings_tests`.
