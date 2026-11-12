# Add a Siren role

A Siren role is a kind of enemy, for example `patroller`, `hunter` or `warden`. There are eight today. This guide describes the current path honestly: roles are not data-driven yet. A role is a string in each Siren's `type` field, and about 30 non-test source files outside the campaign factories compare against role names directly (see `.fable/SURVEY.md` section 4). Expect to touch 10 to 30 files. Paths are relative to `game/src/`.

## What Pat decides first

Read [AGENTS.md section 4](../../AGENTS.md#4-rules-that-are-pats-call). A new role's senses (sight and hearing ranges, attention, lock behavior), its interaction with the sight-only Hunt, its damage and its appearance are protected rules or art direction, so they are Pat's call. The player-facing name and dossier text are Pat's too. No player tool may disable a Siren permanently. Bring Pat a short proposal with the numbers before you build.

## Steps

1. **Register the name.** Add it to `ALL` in `simulation/enemy_types.gd`. `simulation.gd` uses this list to accept or reject a saved Siren, so a save containing the new role fails to load until it is listed.
2. **Give it senses and movement.** Hearing, attention and search come from the per-role rows in `simulation/sweeper_senses.gd`; sight and lock live in `simulation/simulation.gd`. A role with its own behavior gets its own module, as `simulation/industrial_threats.gd` (`interceptor`, `warden`) and `simulation/acoustic_network.gd` (`buoy`, `relay`) do. Keep evaluation order inside the simulation unchanged for the existing roles.
3. **Decide its Hunt and report behavior.** `ROLES` in `simulation/hunt_pressure/hunt_table.gd` lists the roles whose sight the Hunt scales; `contact_reports.gd` lists the roles that file radio reports. Both are protected; add the role only with Pat's ruling.
4. **Identification and photography.** Add the role to `ROLES` in `simulation/contact_identity.gd`, `SIREN_TYPES` in `simulation/photo_capture.gd`, the behavior text map in `simulation/photo_findings.gd`, and `photo_context.gd` and `photo_pricing/photo_pricing_table.gd` if it moves differently.
5. **Presentation.** Name and drawing: `presentation/contact_feedback.gd`, `presentation/first_siren_cue/cue_table.gd`, `presentation/siren_dossier/dossier_table.gd`, `presentation/ocean_view.gd`, `presentation/photo_scene.gd`, `presentation/art/art_table.gd` and `art_renderer.gd`. Sound: `SIGNATURES` and `PASSIVE_ROLES` in `audio/siren_role_cues.gd`. Debug: `debug/debug_overlay.gd` and `diagnostics/ai_trace_table.gd`.
6. **Place it in operations.** Use `R.guard("<role>",position,band,points)` from `campaign/encounters/roster.gd` inside an operation factory.
7. **Find the rest.** Search for an existing role with similar behavior, for example `grep -rn '"warden"' game/src`, and decide for each hit whether the new role belongs there. Files that do not list the new role silently treat it as unknown.

## Tests

- Add `<role>_tests.gd` for its senses and behavior, and register it in `game/tests/suites.txt` ([TESTING](../TESTING.md)).
- If Pat accepts new protected numbers, the owner of `game/tests/protected_rules_tests.gd` and its golden pins them.
- Run import, core, `protected_rules_tests`, `hunt_pressure_tests`, the suites for every operation that uses the role, and a save round trip of a mission that contains it.
