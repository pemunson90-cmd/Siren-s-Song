# Drone operational differentiation · bounded investigation

**Decision: reject the stationary passive-listener v0 for production.** In one ordinary Listening Well plan it supplies no additional warning. Do not add a LISTEN button or tune its range until it appears useful. Current independent routing, fast visual reconnaissance and fragile recovery remain valuable; this result concerns only the new array proposal.

Current source `dced64f`, acoustic candidate `75537f7`, requested Sol6.1/high; actual backend/usage unknown. Isolated branch `gauntlet/feature/drone-operational-investigation`; product files, saves, main/simulation/ocean, APK and critics untouched. Acoustic composition fix took priority, was separately committed2b06815 and approved by its same reviewer. [Raw prototype/evidence](../validation/production/drone-operational-investigation/manifest.json).

## Actual sources

[Official Duskers manual](https://cdn.akamai.steamstatic.com/steam/apps/254320/manuals/DuskersManual.pdf?t=1464910735), Section4 p9, requires stationary Motion use and disconnects Generator when its drone moves. The useful principle is committing a unit to enable information/support rather than adding passive stats. [Developer design discussion](https://steamcommunity.com/app/254320/discussions/3/364042262874890206/) (Tim/Misfits Attic,2016-01-19) also describes sensor overdependence and confusion around inconclusive readings. These are design cautions, not proof of currentpatch balance. Manual'sv2.103 is its heading; actual clientversion unverified.

Actual official Steam movie256655208, *Duskers Gameplay Overview*, retrieved96.07s and inspected decoded sequence plus58–74s excerpt. It shows terminal orders, separate drone/map views and changing room information; edited cuts prevent a controlled stationary-sensor causality claim. No audio assessment, human play, blind comparison or current play recommendation. URLs/hash/viewport/provenance retained; no copied interface or game assets.

Actual v7 source lines350–380 and extracted executable destruction predicate confirm that decoys lure and calm Sirens leave drones alone; close destruction depends on alert/investigation (16original units). Godot deliberately differs: all craft receive fair4s current-LOS beam warnings; drones die at beam, Quietus loses hull. Godot drones share96max movement,330LOS perception and the same tools; manualSILENT changes visual detection but does not lower their movement speed. Battery lasts roughly1400s at the existing constant drain; these short runs establish no battery scarcity. Acoustic candidate makes fast actual drone motion louder through the common squared-speed law. Frozen route5ee9555 (reported integrated483e1bf) explicitly rejects drone SILENT/CRUISE programs, keeps HOLD/observed IF CONTACT/WAIT DRONE, and supports physical STOP then continuation. It preserves fixed96 honesty rather than inventing slower drone propulsion.

## Falsifiable ordinary-play result

Scratch observer only: stop DroneA at300,600 to listen versus the same stationary visual-only control or ordinary moving visual scout to760,200. Quietus cruises toward800,780; DroneB scouts1370,450. A fourth moving-scout control uses one Survey at6s. All normal mission4 starts/productioncommands, no enemy/resource/knowledge edits or forced victories. Receiver needs settled motion; equal engine-speed emission law, optimistic2×stationary sensitivity, terrain paths and own-engine/pulse sector masking. Output is coarse unknown bearing, never visual contact/identity/intent. Parameters were not tuned to recover a benefit.

| Tested result | Current | Acoustic candidate |
| --- | --- | --- |
| First existing live hunter contact, every policy |3.683s|3.683s|
| Additional clear passive bearing |none|none|
| Exposed Quietus outcome, every policy |loss15.033s|loss14.750s|
| DroneA moving scout / stationary post |lost / alive|lost / alive|

The visual-only stationary control preserves DroneA identically: array gains cannot claim credit for safe parking. No policy recovers a record in this exposed finite window; a survivor without evidence is not a mission-quality win. Existing shared visual contacts arrive first, Survey already gives finite broad information, and our own moving craft obscure the proposed passive channel. Seven scratch boundary checks pass (silence≠clear, movement cancels, no hidden fields/mode leak, own masking, read-only pause); no production or human-comprehension claim.

## Next bounded experiment / region needs

The stronger next hypothesis is **optional actual low-thrust drone travel versus existing96m/s sprint**, using the existing acoustic law and inertia; preserve current fast mode as default and legacyactive behavior. A hypothetical60m/s cap estimates254m open-water emission versus651m at96, while staying faster than Quietus'42m/s silent movement. Those are model estimates, not tested benefits. Require one ordinary relay/scouting plan to show a useful noise-versus-arrival/exposure tradeoff; reject it if slow mode simply dominates or only adds travel. Do not change enemy sensing/speed, battery drain, economy or generic drone survival to force a gain.

Precise future ownership needed after current core integration: optional drone propulsion metadata/default/validation; `_tick`'s selected drone speed cap; RouteProgram's current drone-mode restriction; corresponding existing route inspector labels and one focused comparison. No separate tool list, new manager, mandatory station, or silent reuse of the legacySILENT flag whose visual effect differs. This is a proposed isolated prototype, not permission to overwrite active regions or a promotion. Root assigns it if it remains the highest-value next player-facing gain; thermal/current work stays open.
