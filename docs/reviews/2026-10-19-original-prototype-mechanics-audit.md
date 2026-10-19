# Original prototype → production mechanics audit

19 October 2026 · requested `gpt-6.1-sol`; backend/cost telemetry unavailable · read-only.

**Production retains acoustic stealth, investigation, local suspicion and danger audio; v7's live noise footprint is absent.** User direction ratifies **v7 as the working gameplay implementation reference throughout the Gauntlet**, preserving multiple missions, two drones, unlimited pause, Android and fair sensing. [Ratified Addenda A/B](../source-import/original-prototype-handoff/RATIFICATION.md) govern next work.

Compared exact **8d8635a** patrol/recovery candidate, accepted source **f1ea536** / runtime **92625ac**, and published experimental **d09311c**. Paused a83c99e has identical `game/` to 8d8635a; parked density 2fc0976 excluded. All seven archive files and full v6→v7 differences inspected. [Evidence, source hashes, reproduction and detailed archival caveats](../validation/original-prototype-mechanics/README.md).

Keys: **V7** [original HTML](../../reference/original-prototype/sirens_song_prototype_v7.html); **V6** [previous HTML](../../reference/original-prototype/history/sirens_song_prototype.html); **S** [simulation](https://github.com/pemunson90-cmd/Siren-s-Song/blob/8d8635a/game/src/simulation/simulation.gd); **P** [presentation](https://github.com/pemunson90-cmd/Siren-s-Song/blob/8d8635a/game/src/presentation/ocean_view.gd); **A** [audio](https://github.com/pemunson90-cmd/Siren-s-Song/blob/8d8635a/game/src/audio/soundscape.gd). Production links target committed 8d8635a; numbers below are file lines.

## 1. Already exist in current production

Engine-noise hearing, speed-related investigation, last-known attention, local suspicion accumulation and danger-responsive audio exist. So do disruption, decoys, survey, drone vision/photography, submarine fallback, cover, oxygen and extraction. **Noise emission, hearing, LOS detection, presentation and audio are separate systems**; their differences matter.

## 2. Carried over, with differences

| System | Original implementation | Production implementation |
|---|---|---|
| Movement noise / hearing | V7:332–340: silent signature zero; otherwise `(speed/96)²`, hearing radius `360×signature`; hearing raises global suspicion and sets investigation. V6:324–332 uses linear speed. | S:300–307: velocity **>50** within **430 units** sets local suspicion ≥0.3 and investigation, independently of action-noise events. Continuous radius/gain becomes a threshold. Separate silent/cruise LOS radii are 180/290 even when stationary. |
| Investigation | V7:248–249,339,359–377: ping/heard/last-seen positions, timed search; sight beats decoys. | S:149,304–331: origin-based action hearing, last-known goals, search and terrain-aware routes remain. Event hearing attenuates to 0.36 through cover; velocity hearing has no LOS check. Production 8d adds reachable search/patrol recovery. |
| Suspicion / damage | V7:235–263,335–340,387–395: global 0–100 action/proximity/noise gain and delayed decay; Hostile graze −20 after 1.5 s, 3 s cooldown; max + active detector for 3.5 s vaporizes. | S:291–331: per-Siren 0–1 suspicion influences search/speed; independent **4 s lock** gates beam damage 18/s or drone loss. Stun clears lock; cover prevents firing. Hull attrition remains; global action-cost, graze and vaporize rules do not. |
| Noise footprint | V7:520–535: live amber hearing-radius footprint and planning rings. | **Absent:** P:107–145,205–215 has routes, threats, decoy cue and wake, but no engine hearing-radius display. |
| Danger audio | V7:125–150,349,384–385: action tones, suspicion heartbeat every 0.9/0.45 s, Hunt ambience gain. | **Present, changed:** A:16–17,88–100: speed/silent engine gain/pitch, fresh observed lock alerts every 3 s, beam/action cues, creaks and panning. Original heartbeat/Hunt modulation absent. |
| Silent handling | V7:295–308: engine cut, decaying momentum, current drift, arrival throttling and limited turning. | S:216,237–269: silent speed 42 versus cruise 78; inertia, turning, braking and assisted waypoints remain. |

## 3. Absent or regressed relative to v7

- **Distinct roles:** V7:186–195,362–377 has patrollers, tethered sentinel and fast hunter. Production 8d restores authored loops ([missions:78–87](https://github.com/pemunson90-cmd/Siren-s-Song/blob/8d8635a/game/src/campaign/missions.gd#L78)); sentinel/hunter behavior remains absent. Earlier accepted/published sources retain the reproduced unreachable-goal stall.
- **Hunt / environment:** V7:208–211,305,343–349 implements action spikes, photo floor, decay, detection multipliers, thermal masking and current forces. Production lacks these; Foundry's causal response (S:420–429) is different escalation. V7's proposed stage movement ladder was **deferred**, not lost implemented behavior; idle Hunt can cool.
- **Options/rewards:** V7:236–263,589–590 implements knockdown and proximity/drone photo grades; production lacks these specifics. Drones remain expanded into two battery-limited craft with timed records (S:35–45,163–170,217–230).

## 4. Restore / adapt priorities

1. **Required next: Addendum A, test-first.** Distinct sentinel guards in Cold Foundry and hunter in Listening Well; verify loop coverage, tethers and clearance. Retain production pathfinding, fair sensing, stun and lock telegraph. Reassess strategies/naive policies; do not weaken threats to recover historic perfect-hull results.
2. **Acoustic readability candidate:** compare threshold hearing with v7's continuous signature and truthful footprint, keeping LOS/cover semantics explicit.
3. **Pressure/variety candidates:** compare local suspicion/Foundry response with v7 costs/Hunt; evaluate environmental zones, knockdown or grading through play. Archive presence alone mandates no feature or balance value.
4. **Addendum B:** dimension-specific 10–20 s footage against Door Kickers, Barotrauma and Mark of the Ninja; include idle-world clips, blind where possible, retain losses and Siren's Song's identity.

Limits: real original updates and Godot calls confirm code paths and scheduled danger audio. Prototype 200-unit and production 350-unit fixtures use different scales, **not a difficulty comparison**. No whole-run fidelity, browser rendering, Android, physical Fold7 or human-listening judgment; raw fixture warnings and archival contradictions remain in the evidence README.
