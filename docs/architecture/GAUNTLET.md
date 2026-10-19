# Siren's Song — technical production architecture

The Gauntlet's **single operating contract** is `../../AGENTS.md`; the **living intended game** is `../CURRENT_GAME_SPEC.md`. This file preserves technical constraints and gameplay architecture, not an independent workflow, mandatory critic quota, stage-gate schedule or current next-task assignment. Those belong to AGENTS and CONTINUATION. Source authority and ratified player decisions govern implementation.

## Creative contract

One human pilot commands the vulnerable USS Quietus and independently routed drones to investigate superior alien Sirens. A six-mission campaign should move from first contact to discovery and a difficult return with evidence. Decisions come from limited information, acoustic exposure, divided attention, inertia, resources, and terrain. Unlimited tactical pause supports deliberate play. Avoid frantic tapping, conventional combat, omniscient enemies, and failure from hidden UI state.

Confirmed requirements: Android first; 2D; multiple missions/progression/conclusion; queued routes and conditional orders; obstacle collision and visible sonar occlusion; independent drones with submarine fallback camera; slow oxygen pressure; return to extraction. Details below are agent design decisions within the user's creative grant, adjustable after evidence.

## Evidence that drives the architecture

- Design bible §§4–6: inertia, cover in both directions, finite pilot attention, explicit route replacement, stop/pass-through waypoints.
- Transcript turns 28/30: sub fallback camera, return leg, slow oxygen drain; 38–44: terrain must be revealed and occlusion visible; 50: stunned enemies must not detect/kill; 107–111: uneven difficulty and a strong preference against frantic play.
- Drone-command experiment: useful route queues, selected units, hold/wait conditions. Its persistent append mode and near-waypoint slowdown are problems to prevent, not copy.
- User-ratified [original v7](../../reference/original-prototype/sirens_song_prototype_v7.html): working implementation reference for movement, differentiated Sirens, noise/suspicion, ping/last-known investigation, tools, evidence/extraction, atmosphere and procedural audio. Read and compare actual relevant behavior before redesign; record omissions/departures. Current explicit production decisions govern; integrated HTML architecture, historical scope/approval rules and exact balance defaults are not automatically production constraints.
- C01/C02 selected candidates: branching basalt passages, readable physical cover, cyan routes, visible cylindrical drones, monumental cyan/amber factory. Review PDF: low Quietus silhouette, aft central screw, restrained wake, red angular/serpentine Sirens; avoid clutter and airborne smoke.

## Engine and platform

Godot 4.6.3 stable, GDScript, Compatibility renderer, native Android APK via matching official export templates. Reuse engine Control layouts, Input events, Audio buses, Geometry2D and AStarGrid2D where appropriate. No gameplay dependency on WebView, browser, external account, network, or paid services. Development tools may use Python stdlib and installed ffmpeg/Chromium.

Project root: `game/`. Imported archives and visual reference corpus are outside the export tree. Assets included in game are attributable, original production assets; use procedural construction and authored composition with clear silhouette/detail priorities. Do not render a concept screenshot as a supposedly playable game world.

The current1280×720 logical canvas is an implementation baseline, not a fixed UI/screen requirement. User ratified zoom in/out and friendly touch UI as key features; support presentation-only zoom/pan and responsive controls, with gesture conflicts and accidental orders tested. Landscape uses scaling and safe insets. Primary device is the user's Galaxy Z Fold7. Test landscape cover 2520×1080 and unfolded 2184×1968 as representative native pixel sizes, plus wide and 4:3 screens. UI must reflow for the near-square unfolded viewport, with touch controls that remain usable at phone size. GitHub Actions emulation adds Android install/lifecycle/runtime evidence; it does not reproduce Samsung firmware or certify physical folding behavior. Performance target: 60 fps on representative midrange hardware; fallback 30 fps with effects reduction. Desktop software rendering cannot certify device performance. Target API/signing and engine template versions must be recorded in the environment report. Development signing is not release/store signing.

## System boundaries

- `game/src/simulation/`: simulation state, seeded randomness, movement, collision, routes, sensors, noise events, Siren state machines, resources, objectives. Fixed 60 Hz simulation ticks independent of frame rate. Pause freezes simulation time and all resource/AI clocks.
- `game/src/campaign/`: data-defined missions, unlocks, progression/loadouts and narrative; no rendering dependencies.
- `game/src/presentation/`: terrain/craft rendering, fog/sonar shadows, camera reveals, particles, HUD and touch orders. Presentation reads permitted observations, not hidden enemy truth. UI never mutates state except through commands.
- `game/src/audio/`: generated or bundled original samples, ambience and spatial/semantic cues. Event-driven one-shots, limited simultaneous voices, independent music/effects/mute preferences, pause/background behavior.
- `game/src/persistence/`: versioned save schema, validation, atomic write/backup, settings, active mission state, campaign progression. No silent destructive load failures.
- `game/tests/`: executable headless scenarios on the production simulation; UI/runtime scenarios exercise actual input and rendering.
- `scripts/toolchain/`: reproducible environment checks, Android export, test/capture commands. No secrets or local SDK absolute paths committed as required project configuration.

The Sol production lead may refine file names and interfaces before implementing and must record refinements. Keep simulation testable without a display. Use small cohesive modules instead of a single all-purpose main script.

## Gameplay design decisions

The current initial campaign comprises six authored missions: Shelf Signal (teach sonar and extraction), Split Channel (drone coordination), Blackwater Relay (low visibility and evidence relay), Cold Foundry (industry reconnaissance), The Listening Well (moving threat and sustained observation), and Siren's Song (convergent infiltration/extraction and a narrative resolution). Each needs distinct geography, objective pressure, briefing, outcome, and a tested completion route. Content count alone does not meet the campaign quality bar.

Progression rewards evidence with equipment choices and new tactical opportunities, not enemy damage escalation. Defeats preserve unlocked campaign progress; retry is immediate. Completed missions are replayable. Include settings, clear tutorial affordances, pause/resume, mission briefing/debrief, and ending.

Orders: select SUB or drone; tap to replace route by default; explicit visible queue mode for adding; changing units clears transient append/target state. Pass-through waypoints preserve motion, final stop respects deceleration. Emergency replace clears conditional holds and previous route. Assisted routing avoids known terrain with clearance; unknown terrain causes a readable stop/replan, never silently reveals the map. Conditional hold on observed contact and wait-for-drone support coordination without omniscience.

Threats: patrol, investigate heard locations, search last-known evidence, engage only with legitimate observation. Enemy pathing respects terrain. Suspicion is sticky and legible, danger increases with exposure and noise. A telegraphed beam requires active unstunned detection and line of sight; breaking detection/stunning provides a genuine recovery window. Tune oxygen and pressure around methodical planning, not a frantic clock. Drones can scout, photograph, distract, wait, return, and be lost; two simultaneous drones are an initial requirement.

Perception: unknown water is dark. Known terrain persists as chart memory; stale contacts must look stale. Passive perception is local and blocked by terrain; active sonar reveals more but generates an audible event at the ping origin. Camera/evidence glimpses show richer physical detail at a meaningful exposure cost. Pausing does not reveal new information. Recon remains strategically useful and limited.

## Art and sound targets

Abyssal teal/ink palette; layered stone masses and dark trench depth; cyan/amber alien industry; charcoal Quietus with compact tapered silhouette and tiny warm lamps; razor/ray and serpentine red-lit Sirens. Use limited highlights and recognizable silhouettes before fine texture. Distinguish physical objects, surveyed terrain memory, contacts and planned orders. Sonar shadows and physical cover must agree.

Sound conveys engines/noise, ping and returns, proximity/threat, hull pressure, camera, tools, loss, extraction. Dynamic layers must remain restrained; reserve silence and spectral contrast. Include visual equivalents for actionable audio cues. Measure clipping and event spam before review. Human headphone/listening assessment remains a distinct gate from file generation.

## Verification approach

Preserve deterministic simulation, observation fairness, input/gesture correctness, terrain pathing, authentic save/restore and regression prevention. Run targeted checks during feature development and affected regressions on integration; batch broad Godot gameplay regression at substantive playable milestones. Per current user preference, build Android packages only on explicit request or for concrete native problems that Godot cannot resolve; ordinary development and previews run directly in Godot or GitHub. Evidence and independent criticism support the Gauntlet's recurring **whole-game quality judgments**, not mandatory ceremony after each small change.

Current feature status and next action: `../CONTINUATION.md`; project history and older external reference methods: recoverable archives. Protect previously accepted gameplay and keep developing the most consequential player-facing opportunity.
