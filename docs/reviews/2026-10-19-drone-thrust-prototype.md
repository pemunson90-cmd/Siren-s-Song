# Optional drone thrust · bounded prototype

**Reject adding a low-thrust control on this evidence. Preserve the current 96 m/s default.** Lower actual speed reduces emission but earns no useful task/resource advantage in the tested relay operation; faster independent camera drones remain valuable. This is a negative result for this proposal, not a global proof that slower travel can never help.

Exact integrated baseline `483e1bf96354e9ce0ff4aed2b9d56876ab1262f9`; branch `gauntlet/feature/drone-thrust-prototype`, existing isolated drone worktree. Requested Sol 6.1/high, actual backend/usage unavailable. Prior rejected LISTEN investigation `d625e56` remains preserved. No product source, asset, save, UI, enemy, terrain, resource or production-branch edits. [Raw commands, samples, source hashes and scripts](../validation/production/drone-thrust-prototype/manifest.json).

## Ordinary multi-craft result

Split Channel, ordinary Endurance start: independent drones approach west/east relay records while Quietus travels to the submarine uplink; drones return after their exposures, Quietus links both records then extracts. Same routes, shared finite stock and player-observable reactive policy at every speed. The ignored subclass changes only requested drone propulsion; existing acceleration, steering, braking, terrain, squared-speed acoustics and visual detection remain authoritative. Both drone manual SILENT flags remain their original value.

| Requested drone cap | Actual open-water radius at cap | Relay records complete | Quietus win | Hull | East drone home | EMP spent |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
|96 m/s baseline|651 m|15.5 s|39.2 s|61.6%|30.5 s|2|
|72 m/s|366 m|18.4 s|43.1 s|48.4%|36.6 s|2|
|60 m/s|254 m|20.8 s|45.5 s|28.0%|41.8 s|2|

All three recover three records and both drones, spending no decoys, survey or knockdown shots. Uplink completion shifts 21.6→24.5→26.9 s, exposing Quietus later. First player contact shifts 4.2→4.7→5.1 s; that is not proof of a useful stealth gain. Lower west-drone moving time rises 14.1→15.3→16.6 s; east rises 27.6→33.5→38.7 s. Battery remains plentiful: 97.20/96.92/96.75% at each respective ending; oxygen 117.82/117.61/117.47. No scarcity was invented to make speed matter.

**Retained counterexample:** inherited accepted relay script initially spends two pulses 0.1 s apart against the same stale contact at 72/60. Those runs lose the east drone before its record (first one-second samples 17.1/19.1 s), then remain incomplete; 160 s is the script horizon, not a forced mission loss or fair battery comparison. Final matched policy suppresses duplicate pulses for 0.3 s after issuing one, exceeding the 0.15 s sensor refresh, at every speed. This preserves the 96 result and allows all speeds to finish. It neither reads hidden Siren truth nor changes the encounter. Both raw policy versions are retained rather than attributing stale automation losses solely to low thrust.

Forty-second unpaused idle 96/60 controls match exactly in reported state: 100 hull, all craft alive, no record, stock untouched, zero motion/emission, equal battery/oxygen. Default 96 subclass matches the entire ordinary three-second production snapshot; meaningful thrust/motion guards fail before the override and pass afterward. These establish prototype causality, not an experience score.

## Reference, semantics and next action

Actual v7 source lines 324–380 uses fixed 135 drone motion, sub-only squared-speed hearing, and calm Sirens leaving camera drones alone. Current 96 drone emission/4 s visual beam is an acknowledged production departure; this experiment does not restore old invulnerability or suppress drone noise. Current acoustic radius is `430*(actual_speed/78)^2`, including residual velocity. Existing route programming truthfully keeps drones FIXED96 and rejects explicit SILENT/CRUISE; this scratch cap does not pretend that UI already works. No new external footage or human comprehension comparison was performed; primary Duskers reference limits remain in `d625e56`.

Do not merge the subclass or add a speed picker. Advance the already-owned currents/thermal gameplay investigation as the stronger next substantial opportunity: this task shows that a cap alone mainly delays coordinated work. A future actual-medium experiment must distinguish through-water propulsion from current-carried motion before claiming acoustic stealth; current `u.vel` is both because there are no currents yet. Revisit optional per-leg thrust only when a matched useful task earns a route/arrival/stealth choice. Any later implementation needs explicit new metadata/default validation and existing inspector controls; legacy saves and manual SILENT visual behavior must not silently change.

Evidence is deterministic Linux Godot 4.6.3 headless command play, with full ordinary traces. No rendering, audio listening, human play, native APK, broad suite or new critic was claimed or required for this rejected scratch experiment. Worker scope releases to root for continued development.
