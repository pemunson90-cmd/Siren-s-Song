# Handoff 089: THE CHART REVEALS ONLY EARNED KNOWLEDGE, BEYOND CONFLUENCE (V7 restore)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 073 is DONE or not claiming ocean_view/earned_chart_view drawing. The ops you pick must not be owned by another CLAIMED handoff (085 and 088 own ops 30 to 34 until DONE). Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

Source: Claude S5, 28 Oct 2026, from `docs/V7_TO_GODOT_PARITY.md` row "Terrain discovery / chart knowledge" and CURRENT_GAME_SPEC core loop ("The chart reveals only earned knowledge"). Pat 28 Oct ~11:40 ET asked Claude to restore old designs to the current spec. AI-DESIGNED scope; owner may adjust. Not a protected item: Siren senses, collision and physical terrain are unchanged; only what the player's chart shows and routes through changes.

## Task (plain language)
V7 drew a rock only after a sensor revealed it (`obReveal`). Godot has the full machinery for this (`simulation/terrain_chart.gd`, `presentation/earned_chart_view.gd`, earned-chart route repair, per-band depth charts) but only op 11 Confluence sets `m["earned_terrain"]=true` (`campaign/resolution_missions.gd`). Every other operation shows precharted rock silhouettes.

Stage 1 (this handoff): turn earned terrain on for **4 to 6 operations where the water is new to the navy**: core ops in arcs 4 and 5 (14 to 29) plus optional ops among 35 to 39. Keep arcs 1 and 2 and the teaching ops charted (they are surveyed home water and teach the basics). For each chosen op:
1. Set `earned_terrain` and a sensible `launch_seed` rect around the start, as Confluence does.
2. Prove a bare Quietus with no finite tools can still finish it (existing bare journeys; if a journey relied on precharted routing, give it real survey steps, never relax the chart).
3. One short placeholder briefing line: "UNCHARTED: the chart fills in as your sensors find rock." (no em dashes).
4. Check that depth bands, landmarks, photo rows, carry deltas and drone autopilot behave with an initially empty chart on that op.
Add a one-row-per-op table (op, charted or earned, reason) to `docs/V7_TO_GODOT_PARITY.md` under that row, and update the row's disposition. Stage 2 (more ops, or partial old-survey outlines) is a later decision from the cold audit; do not start it.

## Files you may edit
Mission builder files for the chosen ops (one `earned_terrain` + `launch_seed` each), their briefing lines, journeys/tests that need real survey steps, earned_chart_view.gd and terrain_chart.gd only for bugs the new ops expose, docs/V7_TO_GODOT_PARITY.md, shared registration lines.

## Files you must not touch
Physical terrain, collision, Siren senses or behavior, lock, beam, damage, hull rules, photography design, ending resolution, save fields (terrain_chart snapshots already persist in mission state; confirm, do not add fields). Ops 30 to 34 while 085/088 are open. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Bare journeys for every changed op. One small suite: each chosen op starts with only the launch seed charted; legacy ops still precharted; resume mid-op keeps the earned chart. Rerun the existing Confluence earned-chart suites.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; add one line to LEDGER.md.

## Completion
(five lines max; list the ops switched)
