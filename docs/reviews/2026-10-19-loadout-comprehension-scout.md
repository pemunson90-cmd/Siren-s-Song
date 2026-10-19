# Loadout comprehension scout · 19 October 2026

**The existing selection does not explain its resource tradeoff before launch.** The selected name is visible and actual cycling works, but a player must infer what “endurance,” “disruption” and “survey” change. This is a narrow, inherited explanation gap, not evidence of a broken resource mechanic or measured human confusion. One small follow-up is warranted after active Blackwater work.

## Actual evidence

Exact accepted **0afe5fce83c575995b718c5e3d6b152bd7282df2**, running its already-imported read-only source snapshot at `work/blackwater-current-baseline/game`. [Provenance](../validation/production/loadout-comprehension-scout/provenance.json) verifies every tracked game file against that commit. No active Blackwater source or evidence was inspected as accepted behavior.

I rendered and inspected actual Operations at [endurance](../validation/production/loadout-comprehension-scout/operations-endurance.png), [disruption](../validation/production/loadout-comprehension-scout/operations-disruption.png) and [survey](../validation/production/loadout-comprehension-scout/operations-survey.png), then the [prelaunch briefing](../validation/production/loadout-comprehension-scout/briefing-survey-selected.png). Operations shows only `Equipment: <NAME>` and `CYCLE LOADOUT · endurance / disruption / survey`; the entire menu-label trace contains no effect or resource explanation. Briefing explains that disruption interrupts nearby Sirens for12seconds, but neither confirms the chosen loadout nor states its starting quantities. The labels do not say that loadouts change **stock**, rather than sensor range, tool strength, duration or drone endurance.

[GUI input/state trace](../validation/production/loadout-comprehension-scout/capture.log): real engine mouse press/release cycles endurance→disruption→survey. The existing paused endurance dive remains at O₂120%,2disruptors and2surveys while Operations says `Equipment: SURVEY`. Pressing the actual ENTER WATER button starts a fresh survey dive at O₂100%,2disruptors and3surveys. That is consistent with `Simulation.start`; the missing “next dive” distinction can make the menu appear to describe current equipment. No active-dive resource mutation is recommended.

Godot4.6.3 Compatibility/softwareGL;2520×1080 desktop window,420dpi fixture, recorded136px left safe inset. Programmatic scroll reveals the bottom menu; cycle/begin activation uses actual engine pointer events. This proves these bounded desktop labels/state changes, not OS gestures, Android/native behavior, physical Fold7 readability or human comprehension. Isolated XDG data; no player saves. [Driver](../validation/production/loadout-comprehension-scout/capture.gd) is outside the source snapshot. The retained first attempt failed on a stale display146; successful147 capture has no engine error, only unsupported-VSync warning. No broad tests/native/CI rerun.

## Verified effects and opportunity cost

`main.gd` passes the chosen loadout to `Simulation.start`; deterministic starts in the same trace yield:

| Choice | Starting O₂ | Disruptions | Surveys | Actual benefit |
| --- | ---: | ---: | ---: | --- |
| Endurance |120%|2|2|20 additional O₂ percentage points; no drone-battery bonus.|
| Disruption |100%|3|2|One additional disruption pulse; each pulse still has the existing12s effect.|
| Survey |100%|2|3|One additional8s wide survey uplink; each uplink remains audible.|

All three retain3decoys,2drones and the same movement/sensing/tool rules. These are alternatives: choosing one bonus forgoes the other bonuses. There is no extra purchase, unlock, tool-strength or duration penalty in this implementation. The scout makes no new claim that one loadout is best or that oxygen needs tightening.

Relevant v7 reference: fixed starting oxygen/tool stock and visible in-dive counts; no selectable upgrade/loadout system. Production adds an authorized preparation choice. The missing explanation belongs to that added choice; restoring v7 stock, timing or its historical single-mission constraints would not address it.

## One recommended follow-up

**Make the existing selector a compact next-dive comparison, with the selected resources confirmed in briefing.** Retain the cycle control and current mechanics. Show all three stock alternatives together so a player can compare without memorizing previous taps, plus one short effect line: endurance buys oxygen, disruption buys another12s pulse, survey buys another audible8s reveal. Label selection “NEXT DIVE / RETRY”; state that resuming preserves the active dive's equipment. For example, selected survey confirmation can read `NEXT DIVE · SURVEY — O₂100% · DISRUPT2 · SURVEY3`; keep the shared decoys/drones in common copy rather than repeat them per option.

Player gain: deliberate preparation with an accurate expectation of what changes and when. Cost: a little additional menu/briefing space; inspect the same scrolled420dpi cover view and unfolded view to avoid burying actions. A focused follow-up should compare displayed quantities with actual starts and retain the observed active-dive invariance. No equipment economy, balance retune, new selection screen or external-reference campaign is needed for this correction.

Requested routing gpt-6.1-sol/high; actual backend/token/cost telemetry unknown. No delegates, source/assets/tooling/governing/player-save edits, commits or pushes. This scoped menu inspection is not a shipped-game comparison: no blinding, external footage, current-play recommendation, human audio or whole-game verdict is claimed. Scope released; root continues the Gauntlet.
