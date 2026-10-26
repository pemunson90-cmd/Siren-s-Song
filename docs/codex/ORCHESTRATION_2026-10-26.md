# Orchestration handoff for Codex, 26 October 2026 (Claude, root orchestrator)

Read this once per session, after README.md Step 0. Where this file and older protocol text disagree, this file wins. Pat's own words in USER_DIRECTIVES.md on claude/integration still outrank it.

## 0. Pause note (26 Oct ~18:30 ET)

Claude's session hit its usage limit. The C stream (C1 to C5) is transferred to Codex as handoffs 054 to 058; while you hold one of those claims you own the files it lists, even where section 3 says Claude. C6 (doc sweep) and the final audit wait for Claude. Work order: 050, 051, 052, 053, then 054 onward, lowest eligible first. Production was promoted to the integration tip via PR148 (merged 26 Oct).

## 1. Pat's ruling today (26 Oct 2026)

Pat, verbatim intent: the goal is to finish the game. Prioritize completing content. Tests only when absolutely necessary. We audit everything at the end. Claude delegates to Codex; Claude and Codex each orchestrate their own subagents and stay out of each other's way. Every task ends with: clean up your task, mark it complete, clean up stale docs you touched.

What that changes for you, effective immediately (including the 050 claim you already hold):

| Before | Now |
|---|---|
| Independent nonauthor exact-head review before every merge | **Dropped.** No per-feature reviewer. One whole-game audit happens at the end. |
| Evidence folders, hosted-log archives, merge-proof write-ups | **Dropped.** The PR and its CI run are the record. Do not create `evidence/` trees or archive branches. |
| Many focused suites per feature | **Minimum only** (section 5). |
| Long Completion sections | Five lines max (section 7). |

Unchanged: merge only on green `guidance` + `game-smoke` for the exact head, merge commit, never to `gauntlet/production` or `main`, no APK, no force push, no branch deletion, Pat-protected mechanics stay protected (section 6).

## 2. The plan to finish the game

Remaining release content from docs/CURRENT_GAME_SPEC.md, split into two non-overlapping streams. Claude runs stream C with its own subagents. You run stream X with yours.

| Stream | Task | Owner |
|---|---|---|
| X | 050 Hunt restore: finish the hosted density fix, merge | Codex (claimed) |
| X | 051 Arc 6 Calder Trench: 3 core + 2 optional ops, 3 artifacts | Codex |
| X | 052 Optional operations: Sorley's trawler + 3 more optionals in arcs 1 to 3, 1 artifact | Codex |
| X | 053 Regional presentation: per-region ambience, palette/lighting tables, dynamic-range setting | Codex |
| C | C1 Economy: resources, presets (Accessible/Standard/Survival, Ironman), manufacturing, paid research, hull/chassis unlocks | Claude |
| C | C2 Equipment and tools: +8 conventional and +2 alien modules, 8-tool field-tool table | Claude |
| C | C3 Modes: mode select, rename player-facing "EXPEDITIONS" strings, seeded roguelite expeditions | Claude |
| C | C4 Naval career: contracts, factions, fleet development | Claude |
| C | C5 Settings gaps: controller focus, frame-rate setting | Claude |
| C | C6 Stale-doc sweep | Claude |
| End | Whole-game cold audit (fresh critic, no build notes), then fix lists | Claude dispatches, both build fixes |

Milestone promotions to production (Pat clicks merge): P1 now (PR148). P2 after 050, 051, C1, C2. P3 after 052, 053, C3, C4, C5. Then the audit.

## 3. File ownership (the "stay out of each other's way" contract)

**Codex owns (X stream):** new `campaign/calder_trench_*.gd` and other new `<region>_operations.gd` / region files; `campaign/operation_catalog.gd`; `campaign/final_pair_operations.gd`; `presentation/finale/*` (only to move the finale trigger); `audio/soundscape.gd` (after 050 lands); `presentation/art/*`; region drawing in `presentation/ocean_view.gd` and `presentation/confluence_world.gd`; `simulation/world_region.gd`; `campaign/terrain/*`; the hunt_pressure module.

**Claude owns (C stream):** `main.gd`; `presentation/flow/campaign_flow.gd`; `presentation/frontend/*`; `presentation/ops_home/*`; `presentation/expedition_*.gd` and `campaign/expedition_campaign.gd` (string rename only); `equipment/*`; `campaign/fleet_inventory.gd`; the functions in `campaign/glass_research.gd`; `presentation/fittings_menu.gd`, `equipment_context.gd`, `fleet_instruments.gd`; new `campaign/economy.gd`, `presentation/economy_panel.gd`, `campaign/runs/*`, `campaign/career/*`; `persistence/profiles/*`, `persistence/save_states/*`, `persistence/settings_store.gd`; `simulation/orders/*` and new tool modules.

**Shared, append-only (both may add lines; never edit or reorder the other's lines; whoever merges second keeps both sides):** `persistence/save_checks.gd`, `persistence/save_store.gd` key list, `game/tests/suites.txt`, `.github/workflows/gauntlet-pr-checks.yml` test registration, `docs/MODULES.md`, `docs/RESUME.md` capability bullets, the `RECIPES` table in `campaign/glass_research.gd` (Codex appends rows; Claude owns the functions).

**Neither, unless unavoidable:** `simulation/simulation.gd`, `presentation/mission_hud.gd`. If you need one, keep the change to the smallest seam and say so in your Completion. Do not refactor them.

**Suite rank blocks** (TESTING.md format `suite|prefix|local|CI`): Codex local 300 to 349, CI 400 to 449. Claude local 350 to 399, CI 450 to 499. 050 keeps its existing 264 to 266 / 284 to 286.

**Working copies:** Claude's worktrees live in directories named `Siren-s-Song-claude-*` and in Claude's temp scratchpad. Never open, edit or run Godot in those. Use your own checkout. Branch names: Codex `claude/lane-<name>` (existing convention, keep it); Claude `claude/c<N>-<name>`.

## 4. Interfaces between the streams

- **Artifacts to rewards.** You place and physically recover the artifacts; Claude's C1/C2 makes them pay off. Use exactly these material ids and target ids:

| Material id (you spawn, recover, and append a RECIPES row) | Placed in | Target id (Claude adds the catalog entry or unlock) |
|---|---|---|
| `trench_seal_core` | 051, Calder core op | `quietus_wellhead_seal` (alien module, HARDWARE) |
| `choir_reed` | 051, Calder core op | `drone_choir_tuner` (alien module, SENSOR) |
| `deep_keel_plate` | 051, Calder optional op | `hull:quiet` unlock |
| `trawler_screw` | 052, Sorley's trawler | `hull:fast` unlock |

Append each RECIPES row in the existing shape. If Claude's target id is not on integration yet when you merge, still append the row; Claude's lane resolves it. Do not invent other reward types.
- **Finale.** Today the END OF LINE screen fires after first recovery of id 31. With Calder as the last arc, move that trigger to the last Calder core op. Endings logic (`campaign/endings.gd`) stays unchanged.
- **"Expedition" naming.** Leave the word alone in your files; Claude's C3 renames player-facing strings. Do not rename code ids or save keys.
- **Tools.** The finite tools today are emp, decoy, recon, knock. Claude's C2 adds the rest. Author your encounters for the current four plus the bare-Quietus fallback.

## 5. Testing: what counts as absolutely necessary

Run locally before each push: import, core (`CHECKS N FAILURES 0`). Add a new suite only for:
1. a new save field or validator (one corrupt-field reject + one round trip),
2. each new **core** operation (one bare-Quietus finishability journey, so the campaign cannot softlock),
3. math that decides an outcome (economy prices, caps).

Nothing else. No render/UI suites for new screens unless a touch target is new and custom. No re-running existing suites you did not affect. Hosted `game-smoke` is the gate; if it goes red on a test you did not touch, fix the cause, never the test. Never skip, loosen or delete a test.

## 6. Protected, still Pat's call

Beam lethality and the 4 s interruptible lock warning, collision/hull/damage rules, Siren sight/hearing/speed (except the approved sight-only Hunt), photography design, enemy role senses. Story: the provisional bible (`docs/STORY_BIBLE_DRAFT.md` on integration) is approved for detail that does not contradict it; text stays 1 to 2 line placeholders; Sirens were here first and strike sites they read as threats; rescued people are human survivors from drilling and military sites. No em dashes in added text.

## 7. Closing a task (do all of these, every time)

1. PR merged on green (merge commit). Delete nothing; leave the lane branch.
2. Handoff file: `Status: DONE`, `Finished at:`, Completion in five lines max: what changed, PR, test summary, anything unverified, files outside ownership touched.
3. BOARD.md row updated in the same commit (`done NNN`).
4. Doc hygiene for what you touched: one MODULES.md row per new module; one RESUME capability bullet; remove or correct any line your work made false (for example "050 not implemented"). Do not write session ledgers, evidence folders, or long status prose.
5. Release ownership (no claimed files left), then take the next OPEN handoff. When none is left, follow README Step 2.

## 8. Your own subagents

Orchestrator model (Pat, 26 Oct): the Codex session that runs this stream is **gpt-6.1-sol at medium reasoning effort**. Subagents: always pick the **weakest model that is properly scoped to the subtask** (small model for lookups, mechanical edits and test runs; Sol for feature work). **Never use Astra** (or any premium tier) for subagents. Give each one only its task, its files and the relevant short guidance (Pat's permanent scoping rule). Your subagents follow the same ownership table.

## 9. When Claude is absent

You may continue the X stream alone and merge your own green PRs. If you finish X and Claude has written no new handoff, stop and tell Pat (README Step 2). Do not start C-stream work.
