# Current affordance · bounded investigation

**Reject this throwaway controller for integration.** An authored lane supplies a small transport benefit, but the inherited heading-limited stationkeeping transient makes existing HOLD substantially worse. No meaningful tactical or player-experience gain is demonstrated yet; do not add currents globally or tune enemies to manufacture one.

Exact baseline `25d02069ba986e3839155841e1aec6e66486febe`, branch `gauntlet/experiment/current-affordance`, reused `/workspace/Siren-s-Song-drone-investigation`; requested Sol 6.1/high, actual backend/usage unknown. Scratch and complete source/command/hash manifest: `work/current-affordance/manifest.json` in that worktree. Negative drone results `d625e56` and `c1b96fc` remain preserved. Product/tool/workflow/governance/thermal-worker files untouched; this report is the sole tracked delta.

## Reference and contract

Actual immutable v7 lines 180–181/305 use radially faded `(34,-10)` and `(-26,14)` displacement on Quietus, separately from its engine speed. Extracted actual CFG/updateSub executed in Node: a silent, zero-speed submarine at the first field's center drifts `(17,-5)` in 0.5 s; halfway out `(8.5,-2.5)`; at the radius zero. Drone/Siren updates do not receive this drift. V7's current streaks are globally drawn; neither selective transport nor unearned field display is silently adopted here.

[NOAA CO-OPS glossary](https://tidesandcurrents.noaa.gov/glossary.html), actually retrieved/read: current is horizontal water movement; set is its direction, drift its speed; a log measures vessel speed through water or current from an anchored vessel. That supports separating water-relative propulsion from chart displacement, not our numeric calibration or controller. SHA256 `19d1dfb942e916ff65e4d7fb1d8334c0c30b4f0234f8830671eeea27e3dcee03`. The other NOAA tutorial URL returned HTTP 200 with a **Page Not Found** body and was excluded. No shipped-game footage, blinding, audio assessment or current play recommendation is claimed.

Current Godot uses `u.vel` for position, noise/footprint, STOP, Blackwater settled reception, Well engine comparison and extraction. Scratch keeps it as through-water velocity for sound and Well reference, adds flow only to ground displacement, and uses ground speed for STOP/receiver settling. Course tracking cancels sideways flow while preserving axial assistance/opposition; bounded existing 42 m/s silent thrust, 42 m/s² acceleration and 1.8 rad/s turn remain. Commanded HOLD/finalSTOP counterthrust physically, including real noise and transients. Collision tests reject current transport into rock. No new fuel, stock, engine capacity, manager or perfect hold.

## One predeclared ordinary operation and control

Earned same-state checkpoint: ordinary Shelf route toward `(650,800)`, settle then HOLD at 12.9 s, actual position `(642.908,799.994)`. No enemies/resources/terrain/knowledge edited. **Authored counterfactual only:** add one radially faded lane centered `(700,820)`, radius 160, peak `(34,-10)` after that checkpoint. These are v7-scale game numbers, not realistic ocean speeds or existing production mission content. The generic scratch flow applies to bodies inside the lane; other craft and patrols stay outside it in these traces.

Fixed SILENT Quietus course: queue `(900,800)` then `(1300,500)`, CAMERA; return via `(900,640)`, `(350,640)`, extraction. Return skirt deliberately avoids the lane. The policy is unchanged between field-off/on and does not inspect hidden threats. No alternative route search or campaign solver grid.

| Same fixed policy | No flow | Authored flow |
| --- | ---: | ---: |
| Approach from checkpoint |18.8 s|17.2 s|
| Return after record |31.1 s|31.1 s|
| Checkpoint → archive win |54.0 s|52.4 s|
| Hull / craft / tool spending |100%, all survive, none|same|
| Ground distance |2011.3 m|2011.3 m|
| Propulsion distance diagnostic |2011.7 m|1942.2 m|

The 1.6 s approach gain establishes transport feasibility only. No threat/resource/mission decision changes here; lower propulsion distance is not an experience score or invented fuel reward. Both maintain the same 125 m peak engine footprint; sampled ground speed reaches 69.9 m/s in the lane while propulsion stays capped at 42 m/s. First incorrect scratch decomposition canceled axial flow and earned only 0.4 s; its code/results are retained under `initial-ground-target/`, then corrected against a failing through-water/ground-motion check.

**No-new-input control:** same existing HOLD, 20.1 s unpaused. Baseline stays motionless and silent. Current controller moves 62.4 m from its exact anchor at 2.1 s and travels 128.9 m cumulatively before returning. It ends nearly ground-still, counterthrusting 22.0 m/s with a 34.3 m footprint; transient footprint reaches 125 m. Hull/stock stay unchanged in this safe water. The excursion is a consequential lost-control/acquisition risk, not acceptable merely because final position passes. It is retained, with no reverse-thrust or instant cancellation quietly granted to rescue it.

Focused physical checks distinguish drift from engine noise, noisy stationkeeping, ground-settled receivers, STOP, pause, terrain and old snapshots without the fixture. Initial two motion checks fail before implementation; the axial-decomposition check separately fails before correction. No broad suite/native acceptance or claim that twelve checks establish quality. Scratch station anchor/field survive a fixture snapshot; production metadata validation/migration remains undesigned and unpromoted.

## Smallest coherent next action

Do not integrate v0. Before another current gameplay trial, specify how existing HOLD/STOP may physically stationkeep without a 62 m surprise, and what the player is told about unavoidable drift/noise. Any later reverse or lateral authority must be an explicit craft capability with bounded acceleration, not a hidden controller exemption. Retain legacy no-flow snapshots; validate any future fresh mission fields/station intent strictly. Extraction/receiver ground settling and propulsion-based acoustic/Well/HUD semantics need one coherent contract.

Proposed earned cues, **not implemented or tested for comprehension**: local measured flow vector from own ground movement minus water-relative motion, explicitly labeled water/ground speeds, and suspended-particle streaks only in current sensor-visible water. Remember sampled flow as dated local evidence; do not reveal an entire field ellipse, unseen terrain, hidden receiver/emitter or precise future route timing. Current declarations in debug traces are fixture provenance, not player chart knowledge.

This is deterministic Linux Godot 4.6.3 headless command simulation, not rendered/human/physical Fold7/audio evidence. Thermal worker's separate sensing/path transmission work remains untouched. Root receives the bounded rejection and chooses the next substantive cycle; no overall Gauntlet stop is implied.
