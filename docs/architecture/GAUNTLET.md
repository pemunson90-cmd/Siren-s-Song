# Siren's Song production architecture

The user authorized the complete game and autonomous Gauntlet in the kickoff request on 18 October 2026 (America/New_York). This supersedes the earlier import-only scope. Source authority remains `docs/SOURCE_AUTHORITY.md`. Original imported files remain immutable.

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

Start with six authored missions: Shelf Signal (teach sonar and extraction), Split Channel (drone coordination), Blackwater Relay (low visibility and evidence relay), Cold Foundry (industry reconnaissance), The Listening Well (moving threat and sustained observation), and Siren's Song (convergent infiltration/extraction and a narrative resolution). Each needs distinct geography, objective pressure, briefing, outcome, and a tested completion route. Content count alone does not meet the campaign quality bar.

Progression rewards evidence with equipment choices and new tactical opportunities, not enemy damage escalation. Defeats preserve unlocked campaign progress; retry is immediate. Completed missions are replayable. Include settings, clear tutorial affordances, pause/resume, mission briefing/debrief, and ending.

Orders: select SUB or drone; tap to replace route by default; explicit visible queue mode for adding; changing units clears transient append/target state. Pass-through waypoints preserve motion, final stop respects deceleration. Emergency replace clears conditional holds and previous route. Assisted routing avoids known terrain with clearance; unknown terrain causes a readable stop/replan, never silently reveals the map. Conditional hold on observed contact and wait-for-drone support coordination without omniscience.

Threats: patrol, investigate heard locations, search last-known evidence, engage only with legitimate observation. Enemy pathing respects terrain. Suspicion is sticky and legible, danger increases with exposure and noise. A telegraphed beam requires active unstunned detection and line of sight; breaking detection/stunning provides a genuine recovery window. Tune oxygen and pressure around methodical planning, not a frantic clock. Drones can scout, photograph, distract, wait, return, and be lost; two simultaneous drones are an initial requirement.

Perception: unknown water is dark. Known terrain persists as chart memory; stale contacts must look stale. Passive perception is local and blocked by terrain; active sonar reveals more but generates an audible event at the ping origin. Camera/evidence glimpses show richer physical detail at a meaningful exposure cost. Pausing does not reveal new information. Recon remains strategically useful and limited.

## Art and sound targets

Abyssal teal/ink palette; layered stone masses and dark trench depth; cyan/amber alien industry; charcoal Quietus with compact tapered silhouette and tiny warm lamps; razor/ray and serpentine red-lit Sirens. Use limited highlights and recognizable silhouettes before fine texture. Distinguish physical objects, surveyed terrain memory, contacts and planned orders. Sonar shadows and physical cover must agree.

Sound conveys engines/noise, ping and returns, proximity/threat, hull pressure, camera, tools, loss, extraction. Dynamic layers must remain restrained; reserve silence and spectral contrast. Include visual equivalents for actionable audio cues. Measure clipping and event spam before review. Human headphone/listening assessment remains a distinct gate from file generation.

## Verification and critique

First automate parsing, deterministic scenario tests, save round-trip/corruption, pause invariance, fair AI, route replacement, clearance, objective/extraction, all-mission solvability and lifecycle behavior. Then capture real running output at phone and wider aspect ratios. Review states include initial map, planning routes, sonar behind cover, two drones, threat/exposure, camera reveal, debrief, and ending.

User-ratified [Addendum A](../reviews/2026-10-19-external-audit-addendum-A.md) is the next priority after prototype import/comparison/integrity publication and before parked density UI: RED→GREEN authored terrain-safe waypoint loops, distinct sentinel/hunter with intentional Foundry/Listening Well assignments, preserved fair sensing, retired pre-fix balance numbers and rerun strategies/naive policies/critic probes. Do not lower sensing or speed merely to recover historical hull outcomes.

User-ratified [Addendum B](../reviews/2026-10-19-external-audit-addendum-B.md) and [reusable critic brief](../CRITIC_BRIEF.md) require actual 10–20 second clips including an idle world, dimension-matched shipped footage, feasible honest blinding, retained losses and no imitation. Start with Door Kickers planning, Barotrauma sonar/creature behavior/dread and Mark of the Ninja noise/detection clarity. Unavailable footage remains pending; launch-era store claims require current verification before recommending play.

A fresh-context Sol critic receives the build/capture paths and source references before builder interpretation. It inspects actual images and scenarios, identifies the biggest remaining gap, distinguishes defects from aesthetic judgments, and provides reproducible evidence. Improve until consequential deficiencies are addressed or a concrete execution/resource limit requires a checkpoint. No fixed review-round quota. An APK export is not proof of installed Android behavior or production quality.

## Model policy and continuity

The complete existing AGENTS.md model policy remains binding. Substantial production and review delegations explicitly request `gpt-6.1-sol`, fresh context. The user permits smaller/weaker agents for suitably scoped smaller tasks when reliable fit justifies them; do not buy rework merely to choose cheaper routing. Current collaboration tool exposes that model argument; its response identifies task names but supplies no backend attestation or token/cost totals. Record requested routing separately from actual telemetry. Root/coordinator backend identity is not exposed by runtime tools; do not invent certification. No automatic/inherited premium substitution or premium subagents by default. Exceptional premium use must be permitted and explicitly justified. Escalation requires demonstrated Sol difficulty or a high-consequence decision and a written reason.

Use one production owner and one tooling owner while their files are independent; replace idle builders with fresh critics. Avoid idle premium coordination work: provide concrete briefs and let Sol execute sustained production. `docs/WORKBENCH.md`, `docs/MODEL_USAGE.md`, and `docs/CONTINUATION.md` are the recovery map. Commit meaningful runnable progress and push the development branch. Preserve captures/review records in `docs/validation/`/`docs/reviews/`; large APKs in ignored build output or an explicitly documented downloadable artifact. Never label a milestone complete before running its checks.


## Persistent Gauntlet mandate — user ratified 2026-10-18

**The Gauntlet is an open-ended, user-terminated improvement program.** A working prototype, complete six-mission campaign, passing tests, signed/installable APK, polished vertical slice, or app-store-caliber release candidate is a **baseline milestone, never the automatic stopping condition**. The long-term quality ambition is a cohesive, genuinely publishable Android game of the caliber a player could encounter on an app store; after reaching that bar, keep evaluating and improving until the user explicitly says to stop or changes direction. Do not interpret a task list, quality checklist, reviewer approval, or absence of severe defects as authorization to terminate the program.

After each meaningful milestone: (1) build/run and gather inspectable gameplay, visual, audio, interaction and Android evidence; (2) solicit independent evidence-first criticism when warranted; (3) identify the largest remaining experiential, design, content, technical or accessibility opportunity, including improvements beyond bug fixes; (4) prioritize against the established Siren's Song identity and source hierarchy; (5) implement and validate the next bounded improvement; (6) record results, evidence, known limitations and the next action, then repeat. Revisit the quality bar as the game improves. Avoid aimless feature accumulation, endless cosmetic churn and regressions: prioritize player experience, coherence, performance, and meaningful progress. Existing campaign and implementation tasks are the first production phase, not the entire Gauntlet.

**Session/usage/resource limits:** Stop executing when limits require it, preserve a runnable checkpoint, branch/commit status, exact evidence, remaining gaps and a specific next command in WORKBENCH and CONTINUATION. Label the state 'paused / awaiting continuation' rather than 'complete'. Resume the loop when execution becomes available; do not claim background execution across unavailable sessions or automatically bypass platform limits.

**User involvement:** As playable builds mature, invite targeted hands-on testing and incorporate the user's observations, preferences, and new direction. Human feedback becomes increasingly valuable; do not require it for every routine iteration or replace autonomous progress with approval loops. The user alone determines satisfaction and authorizes ending the Gauntlet. Distinguish internal quality estimates from user acceptance. Respect material premise/identity escalation rules and the existing model-budget policy.


## Ratified evidence workflow — 19 October

`docs/BASELINE_AND_EXPERIMENTS.md` preserves the verified baseline and challenger promotion/tradeoff history. Deterministic comparisons precede independent evidence review; retain failed/rejected experiments. Fresh whole-game criticism is periodic and covers pacing/variety/depth, progression/upgrades, narrative, atmosphere, art/audio, accessibility and comprehension. A separate regression hunter after substantial changes may find no meaningful regression; confirm reproduction and baseline differences, prioritize consequential regressions, and distinguish inherited weaknesses. Passing a narrow metric is not promotion by itself.

`docs/PHONE_DASHBOARD.md` is the persistent phone-readable entry to stage, output, APK, criticism, gains, tradeoffs, weaknesses and next work. Reuse evidence rather than create infrastructure. User hands-on direction is authoritative without routine approval gates. Persist future agreed decisions with rationale/source hierarchy in governing Git docs and continuation; all new briefs inherit `docs/AGENT_BRIEF.md`. The open-ended mandate above remains verbatim and binding.
