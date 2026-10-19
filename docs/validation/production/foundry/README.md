# Cold Foundry candidate evidence

Production candidate, 19 October 2026. This is a bounded mission experience improvement within the persistent Gauntlet, independently assessed, pending the next installed Android run. Prior verified native baseline: `539f58b`, Actions `39197795717`.

Actual desktop full-view framebuffers: initial uncertainty, commanded approach, two mid-exposure camera views, carrier response, two retained optical records and debrief at 2520×1080; `inner-archive.png` and `inner-response.png` at 2184×1968. These are the running Godot game, not interface mockups. Camera/archive art is separately authored original imagery; physical terrain, structures, craft, sensing, orders and consequences remain live.

`response-live.mp4` is eight seconds of real-time production rendering and actual mixed audio after replaying ordinary commands to the second exposure. From that point it receives no protective commands: record completion, carrier signal and developing beam threat are actual consequences. It is not the fully protected winning trace. Original 240 frames + stereo WAV are in `build/captures/foundry-response-live/`. Sample analysis: `response-audio-analysis.json`; zero clipped samples, peak 0.3690, 48kHz stereo. No human listening/device-audio acceptance claimed. Forced short capture exit still reports the known audio-thread teardown warning; runtime tests now explicitly free the scene and allow 0.5s audio flush, with no such warning.

Reproduce: `CAPTURE_FRAMES=6 CAPTURE_RESOLUTION=2520x1080 CAPTURE_DIR=/absolute/path scripts/toolchain/capture.sh --script res://tests/capture_foundry.gd -- --stage=furnace`; stages initial, approach, furnace, cradle, response, archive_furnace, archive_cradle, debrief. Use response_live and 240 frames for the clip. All mission motion/exposures come from `foundry_command_plan.gd`; no forced poses, captures or victories. Isolated unit fixtures are separate in `foundry_scenarios.gd`.

## Ordinary command comparisons

Same current mission and disruption loadout (3 disruptors, 3 decoys, 2 surveys). Reproduce final comparisons with `headless.sh --script res://tests/probe_foundry.gd`. The probe uses static chart knowledge and reacts only to fresh observed contact locks, never hidden enemy state.

| Plan | Result | Time | Hull | Tools spent | Drones |
| --- | --- | --- | --- | --- | --- |
| Exposed solo, no defensive reaction | Lost after first record | 32.9s | 0% | none | Unused |
| Exposed solo, finite reaction | Won | 55.6s | 100% | 3 disruptors | Unused/alive |
| Staged coordination, no defensive reaction | Both drones lost, no completed archive | 34.3s probe exit | 18.1% | 1 decoy | Both lost |
| Staged coordination, finite reaction | Won | 34.2s | 100% | 3 disruptors + 1 decoy | Both alive |

Earlier inferior vantages and rushed parallel approaches are retained in `foundry-plans.log` and `foundry-plans-staged.log`; final `foundry-plans-staged-vantage.log`. They are evidence of rejected tactics, not deleted failures. A separate full-campaign fallback deliberately starts with both drones lost and still wins this mission at 50.6s/100% hull using available finite tools. Script speed certifies a route; it does not establish human pacing, recognition or balance. The prior mission was a different geometry/objective/return problem, so its earlier 83.4s safe solo probe is not a controlled timing comparison.

Physical changes: connected western shelf/basalt spine, a solid 400×600 factory footprint shared by sight/movement/drawing, furnace before departure interpretation, far-side recovery buoy. A 60m authored pinch proved inaccessible to the 40m navigation grid and was widened; a clear near-wall goal now projects onto a reachable navigation cell. Completed records create a real eight-second acoustic source at the cradle, using existing hearing/occlusion/patrol rules, with no spawned threat or omniscient target assignment.

Candidate verification: `scripts/toolchain/test.sh` → 86 core/campaign + 176 runtime checks, zero failures. Save format retains old archives and validates new evidence metadata; actual disk round-trip and invalid-evidence rejection are covered. Native completion hooks report actual target/range/LOS/record/debrief/save state only. Physical Fold7, human comprehension, comfort and audio remain open gates.

## Independent assessment

`docs/reviews/2026-10-19-cold-foundry-critique.md` independently reproduced all final command outcomes,86core/176runtime zero-failure checks and recorded waveform measurements. It judges the bounded mission cycle substantially delivered, with phone-scale reading/manipulation the largest remaining concrete gap. Labels still obstruct the cradle/live threat, craft remain small without zoom, and the tactical factory is less integrated than the selected monumental references. These remain recorded opportunities, not covered by passing solver tests.

The critic's controlled return **without the late scripted decoy** wins at the same34.2s/100%, both drones alive, zero EMP remaining. The canonical comparison above faithfully reports spent stock; it does not show a causal decoy benefit. Retain that redundant tactic as an experiment, simplify future teaching, and avoid claiming a richer tool economy from it. Additional delayed reaction from mid-cradle exposure permits a real Drone A loss, then wins34.2s/100% with one EMP remaining; exact commands are in the independent report. The lost drone is a recoverable tradeoff in this case, not an automatic mission failure.
