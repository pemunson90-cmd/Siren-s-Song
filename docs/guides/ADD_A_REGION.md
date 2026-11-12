# Add a region

A region is a look and a sound shared by a group of operations: water colour, light falloff, suspended dust, floor and stone, and an ambience bed. A region is a key such as `glass` or `calder`. Since WP-07 each operation names its region in its metadata row, so no code holds ID ranges any more. Paths are relative to `game/` unless they start with `scripts/`.

## What Pat decides first

Read [AGENTS.md section 4](../../AGENTS.md#4-rules-that-are-pats-call). Art direction is Pat's call, and the seven current regions are a protected capability (ledger rows MENU-010 and AUD-006). Propose the new region's palette and sound to Pat before shipping it, and do not change an existing region's values. Region names that appear in story text, and the arc it belongs to, are Pat's call too.

## Steps

1. **Choose the key.** A short lower-case name, for example `abyss`. Use the same key everywhere below.
2. **Add the visual style.** Add a row to `STYLES` in `src/presentation/art/region_table.gd` with every field the other rows have: `water`, `light`, `falloff`, `dust`, `drift`, `floor`, `stone` and `edge`. `region_renderer.gd` and `ocean_view.gd` read these through `region_table.style()`; they need no change.
3. **Generate the ambience bed.** Add a profile line (name, seed, centre, width, air, swell) to `PROFILES` in `scripts/generate_region_audio.py` with a new seed, run `python scripts/generate_region_audio.py`, and confirm that the seven existing `.wav` files under `assets/audio/regions/` are byte-identical afterwards. Import the project so Godot creates the new `.wav.import`.
4. **Register the bed.** Add a row to `BEDS` in `src/audio/region_audio_table.gd` with the new stream and a `gain_db` level. An operation whose region has no bed falls back to the shelf bed.
5. **Point operations at it.** Set `"region":"<key>"` in each operation's row in `ROWS` in `src/campaign/operation_meta.gd`. For a region that depends on the player's route choice, use `route_regions` as operation 6 does. Unknown operation IDs use `DEFAULT_REGION`, which is `shelf`.
6. **Arc heading.** If the region starts a new arc, add the arc to `ARCS` in `src/campaign/arcs/arc_table.gd`. Its `name`, `intro` and `outro` text are Pat's.

## Tests

- `operation_meta_parity_tests` checks that every metadata row names a region that has both a style and a bed. Moving existing operations to a new region changes the golden: regenerate it with `-- --regenerate` only as part of the reviewed change, and check that the diff touches only those operations.
- Run import, core, `operation_meta_parity_tests`, `regional_settings_tests` and `art_tests`. The rendered measurements (`art_render_measurements`) need Linux with Xvfb, or GitHub CI.
- Listening to the new bed on headphones and viewing it on a phone are device observations; scripted checks do not show how it sounds or looks.
