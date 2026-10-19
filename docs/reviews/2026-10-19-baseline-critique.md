# Siren's Song — independent baseline critique, 19 October 2026

This is a promising, runnable tactical systems baseline with a campaign-shaped shell. It is not yet a compelling production campaign or a close experiential match for the selected references. The largest immediate opportunity is reliable divided-attention play: make coordinating Quietus and two drones trustworthy before expanding content or adding cosmetic detail. After that, develop one genuinely differentiated mission and its physical/sensory presentation as the standard for the remaining campaign.

This review does not authorize ending the Persistent Gauntlet. The ratified mandate makes milestones baselines and leaves satisfaction and termination to the user. There is no arbitrary approval or review-round cap here.

## Follow-up during review: reliability fixes verified locally

The production owner addressed the four numbered defect groups while this report was being written. I inspected the actual diffs and new attention scenarios, then independently reran `scripts/toolchain/test.sh` and `scripts/toolchain/headless.sh --script res://tests/runtime_tests.gd`: **55 core/campaign checks and 139 runtime checks, zero failures**. The regressions now cover continued camera exposure after station switching, released hold after completion, rejection of tools from a lost platform with safe submarine selection, a fresh beam lock after target handoff, resumable zero-time plans, and non-destructive briefing browsing. The owner reports a targeted RED/GREEN check of the target-reset line; this reviewer directly observed the final GREEN runs, not the owner's earlier RED run.

The numbered findings below remain the reproduced baseline history, **not unresolved claims against that follow-up**. Local post-fix checksums were `b9c233027ae086769f64192243d4a4d0d13255a506289b187edc2a0b8f671ce8` for main and `553df59e6c80cdc2969ebeb54f0c2fe42ebea4c02cd272780b46641748478a47` for simulation; presentation/audio/capture checksums were unchanged. New real interaction captures and Android validation are still needed. The failed named camera scenario, campaign sameness, physical threat/camera payoff and audio evidence gaps remain the next work. With these reliability fixes, **the highest-value experiential cycle is the Split Channel proving ground described below**, rather than another general bug pass.

## Evidence and limits

I inspected these actual full framebuffer images with `view_image` **before** reading builder explanations or project documents:

- `build/captures/field/full.png` (1280×720), `cover/full.png` (2048×878), `inner/full.png` (1664×1499), `wide-menu/full.png`, and `briefing/full.png`.
- Then the selected package references `01_TOPDOWN_FACTORY_APPROACH.png`, `02_TOPDOWN_SPLIT_CHANNEL.png`, `07_QUIETUS_EXTERIOR_REFERENCE_PDF_PAGE.png`, `05_SIREN_ANGULAR_RAY.png`, and `06_SIREN_SERPENTINE.png`.

I subsequently read `AGENTS.md`, `docs/START_HERE.md`, `docs/SOURCE_AUTHORITY.md`, the current design bible, architecture, production plan, concept ledger, and actual simulation, missions, UI, presentation, audio, persistence and scenario code. Source authority remains latest user decisions → immutable bible/accepted amendments → selected visual decisions → verified play → original provenance → proposals. Original imports were not edited.

Additional real render captures:

```sh
CAPTURE_DIR=/workspace/Siren-s-Song-gauntlet/build/captures/critic-camera CAPTURE_FRAMES=6 scripts/toolchain/capture.sh -- --scenario=camera
CAPTURE_DIR=/workspace/Siren-s-Song-gauntlet/build/captures/critic-ending CAPTURE_FRAMES=6 scripts/toolchain/capture.sh -- --scenario=ending
```

Both commands completed. I inspected each `full.png`, not the cropped MovieMaker sequence. The camera scenario produced **SIGNAL LOST**, not an optical exposure. The ending scenario produced a readable ending panel but synthetically sets victory; its 00:00 time is fixture evidence, not a completed campaign run.

Verification run in this review:

| Command | Observed result | What this establishes |
| --- | --- | --- |
| `scripts/toolchain/test.sh` | `CHECKS 50 FAILURES 0` | Existing deterministic core, six fallback completion routes, persistence and single-cue audio assertions pass |
| `scripts/toolchain/headless.sh --script res://tests/runtime_tests.gd` | `RUNTIME CHECKS 137 FAILURES 0` | Pointer selection/route/pause on an initial viewport, suspend freeze, control bounds and logical heights at tested sizes |
| Isolated `/tmp/sirens-critic-probes.gd` via `headless.sh --script` | All five reproductions below observed | Specific interaction and fairness defects absent from the existing suites |

Runtime/capture processes emitted `ObjectDB instances leaked at exit`; captures also emitted a software-driver VSync warning. Neither invalidates the images. Leak cause and actual device impact are not established. The builder was already addressing map clipping and audio shutdown; those are acknowledged separately from new findings.

No physical Galaxy Z Fold7 or installed Android play was performed by this reviewer. Button bounds on desktop are not proof of thumb comfort, safe-area behavior, folding, thermal performance or Android process recreation. There was no headphone listening assessment, continuous human campaign playthrough, or measured mixed-output audio recording. These are missing evidence, not claims of observed failure.

Requested model routing: fresh `gpt-6.1-sol` critic. Backend attestation/token/cost telemetry unavailable. No implementation or review delegates were created.

## Confirmed consequential defects

### 1. Previewing a briefing discards the current dive, and a zero-time plan cannot be resumed

**High priority: avoid losing player decisions through navigation.** `main.gd::_briefing` calls `_start_mission` immediately, before ENTER WATER. BACK TO OPERATIONS does not restore the prior dive. Suspend/close can then save the replacement state. Separately, `_show_campaign` only offers RESUME ACTIVE MISSION when `sim.elapsed > 0`; an entirely valid route plan prepared while paused has elapsed zero.

Reproduction against the reviewed UI instance: start mission 0; set Drone A at `(500,800)`; advance 0.2 seconds; pause; OPERATIONS → Shelf Signal → BACK TO OPERATIONS. The isolated fixture observed:

```text
former elapsed=0.2 current elapsed=0.0
former drone=(500.0,800.0) current drone=(140.0,675.0)
```

For the paused-plan case, start mission 0, route Quietus to `(350,800)` without unpausing, then OPERATIONS. The route existed, elapsed was `0.0`, and there were **zero resume buttons**. These are ordinary player actions; they do not require a corrupt save. Existing save round-trip tests correctly preserve snapshots but miss the surrounding UI lifecycle.

Expected player outcome: inspect briefing/menu without implicitly abandoning a dive; resume any valid active plan, including before its first simulation tick. Starting/retrying a new dive should be a deliberate transition.

### 2. Beam charge transfers between targets, eliminating the new target's warning window

**High priority: a fairness defect.** `simulation.gd::_threats` increments `s.lock` whenever any target is detected, without clearing charge when `detected` changes. A nearly completed lock on Quietus can instantly destroy a newly detected drone after Quietus escapes. The code also prioritizes unit array order rather than preserving an explicit target, so the transfer can happen as units enter/leave detection.

Deterministic fixture: mission 0, Siren at `(900,800)`, Quietus and Drone A at `(1000,800)`, Drone B inactive. Call `_threats(1.0/60)` 235 times; the Siren targets Quietus with `lock=3.91666666666666`. Move Quietus to `(140,800)` and call eight more times. **Drone A is dead after 0.133 seconds**, having received none of the advertised four-second preparation window. Positions are fixture setup; the same target handoff occurs naturally while units maneuver.

Expected player outcome: every new target gets consistent beam acquisition, or a clearly communicated different rule. Breaking sight must not quietly turn the previous unit's near miss into another unit's instant death.

### 3. Changing stations during photography cancels exposure and silently strands the previous unit

**High priority for the signature coordination loop.** `command("camera")` sets the unit's hold to `HOLD`. `command("select")` clears `capture_unit` without clearing that hold or reporting an interrupted exposure. The ordinary selection message replaces the only camera feedback. On the reviewed 720px layout, `detail_label` is hidden, so the stranded unit has especially little explanation.

Fixture: mission 0, Drone A at `(1200,300)`, select A, CAMERA, select Quietus. Output:

```text
before select: active=1 hold=HOLD
after select:  active=-1 hold=HOLD
```

Player effect: assigning the other craft an order silently loses the photo and leaves A stationary. A player may infer that an independent drone is still photographing, or that its previous route will resume. This punishes the expected multi-unit workflow through implicit state.

Whether camera operation itself requires continuous pilot attention is a design choice; the bug is the unannounced cancellation and leftover hold. Choose and communicate the attention rule, then make completion/cancellation/selection obey it. Do not solve it by requiring frantic station tapping.

### 4. A destroyed selected drone can still spend and project tools

**Medium/high priority: invalid command ownership.** Destruction sets `alive=false`, but selection is not transferred. Only the select command checks `alive`; ping, disruption, survey and other commands still operate from `units[selected]`.

Fixture: select Drone A in a new mission, set its `alive=false` to represent the actual destruction result, call EMP then ping. Both returned `true`; EMP stock decreased by one. The dead drone's location remained the pulse/ping origin.

Player effect: dead platforms can distract/reveal/stun, tool stock can disappear from an unusable station, and the disabled unit button gives contradictory feedback. Reject commands from dead units and provide an intelligible live-station recovery policy. Exercise a real death while that drone is selected, not only a pre-mission drone-loss fallback.

## Campaign, incentives and pacing

**Observed structural limitation, not a claim that the six missions are unplayable.** `missions.gd` defines six arrangements of exactly three rock rectangles, one to three similarly rendered photo markers, the same extraction coordinate, and the same Siren behavior. Blackwater reduces sensor radius; later maps add enemies and the factory image. Those create some different routes and pressure, but mission briefs promise more distinction than the mechanics deliver: relay chains, foundry machinery, sustained observation and the finale all reduce to the same four-second camera command and return rule. All first objectives are even named SIGNAL SPIRE regardless of the named mission's premise.

The existing all-mission suite completes **all six with both drones dead** and disruption loadout. Times/hull/oxygen were:

| Mission | Seconds | Hull | Oxygen |
| --- | ---: | ---: | ---: |
| Shelf Signal | 64.5 | 100% | 96.4% |
| Split Channel | 88.2 | 100% | 95.1% |
| Blackwater Relay | 72.9 | 49% | 95.9% |
| Cold Foundry | 86.2 | 100% | 95.2% |
| The Listening Well | 86.8 | 100% | 95.2% |
| Siren's Song | 83.9 | 100% | 95.3% |

These are automated, knowledgeable command routes, not a prediction of novice play time. They establish fallback solvability, which is good. They also expose weak differentiation and uneven threat: five routes return undamaged, one takes substantial damage, and the later missions do not establish an increasing dramatic problem in this evidence. The suite automatically disrupts when a known lock exceeds one second; it does not show human recovery under incomplete information.

Drones do have real incentives: speed 96 versus Quietus' silent 42, passive radius 330 versus 240, parallel routes, disposable exposure and a tool origin away from the sub. Keep those. Their larger problem is consequence and attention: all live drones contribute passive vision simultaneously, losses reset next dive without cost or debrief consequence, battery lasts about 23 minutes versus these approximately 1–1.5 minute routes, and there is no visible battery reading. A lost drone matters tactically for the current attempt, but the campaign does little to make recovery or preservation interesting. All three loadouts are available immediately; evidence progression primarily unlocks mission buttons rather than new tactical opportunities.

Oxygen drains approximately 5% during these routes. This supports the preference for methodical planning, but makes endurance's extra 20% largely an untested long-dive option compared with another disruption. Do not simply accelerate oxygen drain to manufacture urgency. First create decisions worth spending time on: safe versus exposed vantage, separated drone task and submarine passage, useful short survey windows, and readable recovery after a failed plan.

**Recommended next content experiment:** rebuild Split Channel around one strong coordinated situation with useful shelter, two genuinely different vantage/task roles, a clear reason to move Quietus, and a recoverable fallback after losing a drone. Compare a solo-sub route with a coordinated route for information gained, exposure, time, attention and losses. Preserve fallback without making the two approaches emotionally identical. Do not implement six new mission systems at once.

## Visual direction and mobile readability

**Confirmed reference gap; aesthetic prioritization is judgment.** The reviewed output has coherent ink/teal color, real textured rock tops/sidewalls, readable gold objective coding, muted unselected routes and a recognizable elongated dark Quietus. Those are useful foundations. The selected references do not demand copying their pixels or full 3D; their most valuable qualities are composition, scale and tactical causality.

The actual maps instead show three isolated, similarly shaped rock islands in a broad flat dark rectangle. C01/C02 show connected basalt masses creating channels, narrow water, recesses, depth changes and tactical separation between the submarine's route and drone activity. Current repeated rock outlines and sparse empty water make navigation feel like crossing a diagram with obstacles rather than entering an alien industrial seabed. Adding more texture alone will not solve that composition problem.

The field image's factory sits partly above the map/header, while the cover image has a conspicuous empty left/right map framing area and the unfolded image gives most attention to enlarged water. Clipping was already assigned to the builder; retest the revised full framebuffer, including the depth/chart text at the right edge. Clipping the factory fixes containment but does not itself make the industrial objective feel monumental or physically integrated. The large factory texture is decorative: `blocked`/`line_clear` use only rocks, so any solid-looking factory mass over water needs a deliberate collision/perception interpretation.

Quietus resembles its selected exterior at a broad silhouette level, but is very dark and small, and drones are tiny capsules. The fresh Siren is an outlined polygon; stale Sirens are another dim version of that polygon. The reference angular/serpentine craft have a sleek physical body and a clear pointed beam emitter; current threats read more as warning symbols than superior entities. There is no serpentine form in the reviewed renderer. That is a direction gap rather than a requirement to add a new enemy class immediately.

The renderer has lock arcs and BEAM text but no actual emitter-to-target beam/impact representation. It has a small optical-progress strip, not a distinct richer camera view or evidence image. World physical detail is generally displayed before that photo. Consequently perception/exposure is mechanically useful but the player's reward for taking a dangerous photograph is primarily a counter and later prose. The failed camera capture scenario prevents even the minimal optical state from being reviewed reliably. A successful optical/threat scenario is needed before claiming this part of the experience is evidenced.

The brief is readable, and the ending text fits at 1280×720. The ending's “warning, not a firing solution” stance gives the campaign a coherent investigative theme; the missing piece is experiential buildup and evidence that makes the conclusion feel earned.

Controls have generous logical heights, and the unfolded control reflow is materially better than squeezing a right sidebar into a square viewport. Nevertheless, the 720px layout presents 16 similarly weighted controls, including terse IF CONTACT and WAIT DRONE labels, with no persistent per-unit task, selected-unit battery, hold reason or target status. The unit names distinguish three buttons; color tint alone carries most selection feedback. The menu's mission list fills the panel and pushes settings beneath a scroll boundary. These are attention and discoverability concerns, not proven touch failures. Test on the cover display with an actual thumb and a novice instruction task before shrinking controls or adding more buttons.

## Sound, perception and lifecycle

Sound generation exists and single-cue tests establish nonzero signal with peak headroom. The actual soundscape plays one ambience loop and up to five cue voices. The `engine` variable is unused; there is no movement-dependent propulsion layer, pressure/creak system, bearing-based threat sound, return distinction, or beam/damage cue. Recon, decoy and alert share the generic two-tone fallback synthesis; record and extraction share a chord. This is a functional starter, not evidence of the distinctive sonic identity the bible calls for.

Threat alert playback depends on a fresh observed contact, so the sensory design should explicitly consider superior enemies detecting from beyond current player visibility. Current passive fog/known-water differences are subtle square tiles, while all charted rocks and installations remain visually available. This respects the briefed-chart premise but needs hands-on checking that a player can explain fresh observation versus memory versus blocked water. Existing tests establish selected LOS rules, not perception comprehension.

Pause/suspend snapshots and checksummed primary/backup saves are worthwhile protections. Remaining observed failures are UI lifecycle losses described above, not basic byte corruption. Audio shutdown was already being fixed concurrently. Do not claim measured mixed-output clipping, background audio silence, Android restore or installed device frame rate from the present deterministic/headless evidence.

## Highest-value next bounded cycle

1. Fix the four confirmed interaction/fairness defects together as a small reliability cycle. Specify camera attention explicitly, preserve active dives through menus, and make unit validity and target acquisition consistent. Add focused regression scenarios that reproduce these failures before fixing them.
2. Capture a real successful photo while switching orders to another craft, a drone death with that station selected, and a target-handoff escape. Use visible unit task/hold/selection feedback and actual pointer/touch events. Repair the camera scenario so it reliably reaches its named state.
3. Then use Split Channel as a gameplay/visual proving ground: meaningful connected channel geography, different drone/submarine tasks, physical Siren/beam causality, and a richer but bounded camera payoff. Assess a real command-driven run, not only staged victory. Carry its lessons into the other missions.
4. Gather installed Android cover/unfolded lifecycle and human listening evidence. Invite focused human play at this inspectable milestone, while continuing autonomous work authorized by the Persistent Gauntlet.

The immediate bar is that players can state which craft is doing what, why a photo stopped, which threat is locking which target, why a drone died, and how to resume the plan they already made. Meeting that bar will do more for this game's identity than adding more mission buttons or another layer of surface texture.

## Source snapshot and reproduction notes

Review began with working changes over `b9063741778a81ad6713639dbf0556a1cb3a25ac`. During review the builder committed checkpoint `acb1b1d1fb182726651b7e7b44f498bea1f7f6de` and began an attention test file. Main/simulation/presentation/audio/capture checksums below were unchanged between my code inspection, probes and final snapshot; later builder changes are outside this baseline. The initial supplied captures predate this review's additional captures and the builder's map/audio follow-up.

```text
60c8fd03dc075980e97d75879b05d2a288a491098fad92fe70619f27df592a76  game/src/main.gd
4d699746cbbcdd69d981dfc904d86425993ba9a1764c94d9bbb04019094183cf  game/src/simulation/simulation.gd
847b132765691796b19b76f4b4212b34435b1779fd0165db8b11c46ef559d92f  game/src/presentation/ocean_view.gd
978a8ba630267770984dd9be41069d20ce98ecd2af0896c2db8f79372abaa6e3  game/src/audio/soundscape.gd
0ae4153ecad0b99073849701e4cd110e4e5d80d0ddd8f1b9655870db0220ab1c  game/src/campaign/missions.gd
d6452ae87dd05e0708ef6c799699d5cb7856a4626f190d7e15d07c9de066aa58  scripts/toolchain/capture.sh
```

The isolated probes instantiated the production `Simulation` and actual main scene with `capture_scenario="critic-probe"` to suppress archive writes. For reproduction, use a temporary `extends SceneTree` script, preload `res://src/simulation/simulation.gd`, and apply the explicit fixtures/commands/counts above. UI probes instantiate `res://scenes/main.tscn`, add it to `root`, await two frames, and call the same `_start_mission`, `_show_campaign` and `_briefing` methods wired to buttons. The temporary probe file is `/tmp/sirens-critic-probes.gd` in this execution workspace; durable reproduction steps and observations are recorded here so the report remains usable after temporary files disappear.

Only this review document was edited. No game/tooling/import edits or commits were made by the critic.

## Follow-up cycle review — Split Channel, optical feed and physical threat (19 October, 03:38 UTC snapshot)

I first inspected the new actual full framebuffers `build/captures/split-cycle/full.png`, `optical-cycle/full.png`, `beam-oriented/full.png`, and `physical-threat-cycle/full.png`, before reading the cycle's changes or claims. I then inspected the current mission, simulation, camera/feed/UI and tests, including commit `4463446` plus working changes over `5f471b4`. I independently ran `scripts/toolchain/test.sh`: **52 core/campaign checks and 140 runtime checks, zero failures**. The changed check count includes fewer per-waypoint assertions after route simplification; totals alone do not measure coverage or quality. The exit ObjectDB leak warning remains.

### What materially improved

Split Channel now has connected coast edges and a long central spine that genuinely separates relay sightlines. WEST and EAST RELAY lie in different channels; UPLINK ANCHOR requires both records and six seconds operated by Quietus. The sub must do something beyond waiting at extraction. This is a meaningful first mission distinction, and the fallback remains possible. The brief now states the task dependency clearly. It would be inaccurate to repeat the original “all six are identical photo-return missions” finding without this exception.

Unit buttons now show ROUTE/READY/EXPOSING and hold state, and observed locks explicitly name their target. The physical ray asset is closer to the approved strange, pointed craft than the old warning polygon; stale contacts use a different abstract symbol. The optical inset is an actual richer presentation while exposure progresses, and the named camera fixture now reaches a live exposure instead of SIGNAL LOST. Target-oriented beam lines and an impact ring make causality more visible. These are tangible improvements, not merely more assets.

### Tactical evidence: faster collection is established; balanced coordination is not

The ordinary-command coordinated scenario completes in **39.3 seconds, 6.4% hull, zero disruption charges remaining; both drones survive**. The solo-sub fallback takes **78.6 seconds, 81.7% hull**. The faster plan saves about half the elapsed simulation time but almost loses Quietus. Its automation checks observed contacts each 0.1 seconds and fires disruption from the nearest surviving platform, so this is evidence of possibility under knowledgeable control, not a novice success rate or proof that coordination is satisfying.

I localized the risk by cloning the same production test into `/tmp/sirens-split-trace.gd` and adding read-only trace output:

```text
RETURN START time=21.6 hull=100.0 sub=(790.8411,781.3786) tools=0
FIRST DAMAGE time=33.1 sub=(392.8277,808.9018) capture=-1 records=[true,true,true] tools=0
SPLIT COORDINATED outcome=won time=39.3 hull=6.4 EMP remaining=0
```

The coordinated collection/uplink succeeds intact; the near-loss happens on the **return corridor after resources have been spent**. Six percent hull is a narrow remaining margin, not automatically unfair difficulty. It calls for an inspectable recovery plan and hands-on assessment. The largest remaining gameplay opportunity is a learnable extraction decision: can a player recognize that the initial fastest return is unsafe, use cover/noise/drone diversion or a conditional route, and reach home with a margin that follows from that decision? Prove at least one such route, then deliberately compare it with the exposed route. Do not assume adding drone use or shortening the uplink will solve a return-leg problem, or globally weaken Sirens before understanding it.

### Concrete new input defect: the optical reward masks evacuation commands

In the supplied optical frame, the inset covers Quietus and the extraction area while Quietus is selected and Drone A is photographing. Its Control uses `MOUSE_FILTER_STOP`. I confirmed the actual input consequence with `/tmp/sirens-inset-probe.gd`, instantiating the real camera scenario at logical 1280×720 and injecting pointer down/up through `root.push_input`:

- Drone A exposure was active, selected unit was Quietus.
- The inset's global rectangle was `(40,426)` size `(390,228)`.
- A tap at world `(320,800)`, logical `(206.8,567.8)`, produced no route command; Quietus' route stayed empty.
- A tap at uncovered open water `(800,800)` produced `SS_ORDER route accepted=true`, route size 1, with Drone A's exposure still active.

This is a definite divided-attention regression: the new reward hides and intercepts useful water precisely while the player should be coordinating another platform. It also prevents a paused player from ordering that covered escape point until the view is dismissed or exposure ends. Blind click-through is not an adequate sole remedy because it still hides the commanded water. At report handoff the owner is implementing station-owned display: show the feed when that platform is selected and hide it when another station is selected, while the commanded exposure continues. That fix is **in progress, not yet independently verified in this appendix**; the task label should preserve awareness of the continuing action.

### Beam correspondence and feedback still require close-range evidence

Aim now follows the observed target, and the sprite's pointed emitter is at its forward/right end. However, the reviewed draw code starts the line at `center + aim * min(62,distance/2)`, while the physical sprite's emitter is approximately +63 world units. For a target 60 units from the Siren center, the beam begins about 30 units forward, inside its body, rather than at the snout. The beam-oriented frame also compresses craft, target label, countdown, impact and lock ring into one overlapping patch. The rule is consequentially clearer than before, but the physical source remains inconsistent at close range.

This is a reproduced code/geometry mismatch, not a demand for extra graphical effects. At handoff the owner is adding a standoff regression and fixing the beam origin to the actual emitter; these changes need a fresh close-range image and dynamic approach/escape evidence. Verify body scale and collision/approach behavior together, rather than moving a beam endpoint until one still image looks acceptable. The correct test is that a player can visually locate emitter, path and struck craft throughout the engagement. During damage, “BEAM 0.0s” could also become an explicit firing state; a frozen zero countdown communicates less than the otherwise good target label.

### Camera payoff and composition remain development opportunities

The optical feed has stronger detail and a progress reward, but the first three missions still show the same ribbed spire close-up, and later missions share the same foundry image. WEST/EAST differ by their label rather than visibly different evidence. The feed disappears at completion and records remain chiefly counters/prose; this is an improved observation state, not yet a memorable recovered archive. A small mission-specific detail or retained evidence view would make exposure yield knowledge the player can recognize. Prioritize meaningful differences and a coherent record, not six decorative zooms. The uplink should feel like combining those records rather than photographing another indistinguishable spire.

The new Split Channel geography is materially closer to C01/C02's tactical separation. It still reads as a few tall, repeated extruded slabs against empty gridded water, rather than layered basalt channels with recesses, meaningful depth and an integrated industrial destination. The other supplied missions retain the original isolated-island composition. Physical-threat imagery now better expresses alien superiority, but tiny dark craft need label support, and terrain still has a repeated outline and abrupt square fog boundaries. These are aesthetic/legibility judgments grounded in the images, not claims of broken collision. Preserve the useful new channel logic as composition improves.

The safe-area conversion test now checks that 136 physical pixels on a 2520-wide window become approximately 90.6667 logical pixels on a 1680-wide canvas. That is useful deterministic math evidence. The reported native cutout measurement and this test do not establish installed layout/input behavior; reinstallation and actual native touch remain pending for these changes.

### Next bounded cycle and evidence

Finish the inset input and emitter/standoff fixes, then capture a coordinated **return and recovery** with actual pause/select/route/tool input. Include an unsuccessful exposed return for comparison, one safe recovery route, the moment the threat becomes legible, and the information available to the pilot at that moment. Measure hull, tool expenditure, exposure and timing separately. Review camera station ownership and threatening close-range craft at cover/unfolded sizes. Continue improving one mission's geography and recognizable recovered evidence from that play result. This remains a Persistent Gauntlet iteration; neither the passing suites nor the newly differentiated mission is a stopping condition.

Reviewed source hashes before the owner's subsequent fixes:

```text
f474205c5891548a5ccafd3cb966668fe434f52e43c61ce0c3af81bfb84f67f2  game/src/main.gd
a4d7455884776d2fb7674aa90ee5e0ba753f414355e83db5b99a8388e172a05b  game/src/simulation/simulation.gd
1c5e7c6ec51d0e77818ca0b82cd79025212ab6f17e622c8c4891c6e3afa6b17a  game/src/presentation/ocean_view.gd
07b9b39c14548904457e29dc8bab095d6c60caa49ec65c3f53c87b4374616730  game/src/presentation/camera_feed.gd
70e6de3fd6bd119a0c3e3a132b0171275097544887f214a789d4fe271ce57528  game/src/campaign/missions.gd
```

This appendix owns no implementation files, creates no delegates, and makes no installed-device or listening claim. The original findings and earlier fix verification remain preserved above.
