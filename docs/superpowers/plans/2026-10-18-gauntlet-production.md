# Siren's Song production implementation plan

> **For agentic workers:** Use superpowers:subagent-driven-development or superpowers:executing-plans. Execute continuously within the user's autonomous grant; model and review limits in the user request override conflicting skill defaults.

**Goal:** Build the complete Android tactical stealth campaign, verify real output, and preserve actionable quality checkpoints.

**Architecture:** Godot GDScript, deterministic simulation separated from data-driven campaign, presentation/audio/input and versioned persistence. See the architecture for exact invariants and creative decisions; a Sol owner refines implementation interfaces as necessary before shared work begins.

**Tech Stack:** Godot 4.6.3 Compatibility, GDScript, official matching Android export templates, JDK17, Android SDK, Python tooling.

**Spec:** `docs/superpowers/specs/2026-10-18-production-design.md` and `docs/architecture/GAUNTLET.md`.

## Global constraints

- Preserve all imported source files and the existing AGENTS.md model policy.
- Sol6.1 is default for substantial delegated production/critics; explicit smaller-model routing is permitted for appropriately scoped smaller work when reliable fit justifies it. Never claim unavailable actual-model/cost telemetry.
- No omniscient player/AI, time advancement during tactical pause, enemy health combat loop, or hidden persistent route-append trap.
- Physical terrain, route clearance and sensor occlusion agree. Nonlethal tools provide fair recovery.
- Real runtime evidence precedes visual criticism. Android installation/runtime claims require actual device evidence.
- Keep work in `game/`, reproducible tooling in `scripts/`, and durable evidence/continuation in `docs/`.

## Review focus

1. Switching drone→sub during threat must replace the route and clear stale modes; test emergency routing and pass-through speed.
2. Pause/background/resume must preserve resource clocks, queued actions, campaign and active mission state; test corrupted/old saves safely.
3. Contact information behind cover must not leak to player or AI; test sonar/LOS and stale memories separately.
4. Phone aspect ratios and scale must preserve touch target readability and prevent HUD overlap; exercise actual input in runtime captures.
5. Every mission must be completable with ordinary commands/resources, including drone loss fallback; deterministic route scenarios plus fresh play review.

## Verified status — 19 October, through93b8631

Checked items are implemented/reproduced milestones, not user acceptance or a stopping condition. Current command `scripts/toolchain/test.sh` passes88core/campaign +176runtime checks. Actual rendering, command-driven ending, waveform measurements and two independent Sol reviews are indexed in `docs/validation/production/` and `docs/reviews/`. Workbench's current summary takes precedence over historical checkpoint counts. Tooling coordinates sole pushes; native39202066103 passed cover/inner lifecycle, >30s active audio and ordinary Shelf Signal completion/cold campaign restore. Physical Fold7/full-campaign native remain open. Do not rebuild completed foundation work.

## Task 1 — Native production shell and verified toolchain

Files: `game/project.godot`, `game/scenes/main.tscn`, `game/src/main.gd`; tooling owner owns `scripts/toolchain/*`, `game/export_presets.cfg`, environment report. Project owner does not edit tooling-owned files concurrently.

- [x] Create a runnable Godot scene with valid state from frame one, landscape scaling, pause and menu/mission transitions.
- [x] Install official matching templates; record download/source/version. Export a debug APK, inspect its manifest/signature, and document exact reproduction commands.
- [x] Start real rendering with the existing dummy Xorg display. Capture a PNG from the viewport; verify it is actual game output.
- [x] Commit runnable shell and exact evidence. Record runtime/device gaps honestly.

## Task 2 — Deterministic tactical core and fair threats

Files: `game/src/simulation/*`, `game/tests/run_tests.gd`, `game/tests/scenarios/*`.
Interfaces: a mission definition and seeded new state; `step(dt)`/command API; serializable snapshot; observations and events for presentation. Sol owner must document actual class names/signatures before splitting ownership.

- [ ] Write failing assertions for pause invariance, frame-step consistency, replacement after unit switch, pass-through versus stop, known-wall routing, collision, LOS, ping-origin investigation, stunned detector recovery and extraction.
- [x] Implement fixed-step movement, commands, two independent drones, local/active/recon observations, suspicion, fair Siren states, tool resource use and objectives.
- [x] Run the production simulation headlessly; add adversarial tests for hidden-contact leakage and drone-loss fallback. Confirm failures are fixed rather than suppressed.
- [x] Produce a deterministic scenario trace of a legitimate objective→extraction run. Commit.

Task2 remaining qualification: the listed behavior assertions now exist, and focused RED→GREEN regressions cover defects found during implementation/review. Separate initial failing runs were not retained for every first-phase invariant; direct collision-impact/unseen-obstacle discovery coverage remains narrower than the original ambition. Current terrain is a briefed static chart; unknown water/contact memory remains sensor-bounded. Extend targeted missing cases rather than reimplement the passing core.

## Task 3 — Playable art, sound, touch and tactical readability

Files: `game/src/presentation/*`, `game/src/audio/*`, `game/assets/*`, input integration in main; tests for input transforms.

- [x] Inspect selected references C01/C02, Quietus exterior and Siren studies with view_image before building assets.
- [x] Build original layered seabed, industrial structures, craft, fog/sonar shadows, routes and controlled VFX. Expose observed information only.
- [ ] Implement clear pause/resume, selected unit, replace/queue/emergency orders, stop/pass-through, conditions and tool feedback with phone-sized targets.

Controls/gesture behavior exists and native input passes, but the accepted 48-logical-pixel targets are only 27.43/31.20 dp on the measured 420 dpi cover/inner fixture. Density-aware work from 2fc0976 is now selectively integrated locally after the bounded A milestone. Actual 56 dp fixture rows, sticky actions, page replacement and persistent route intent are in focused review; native density and physical comfort remain open.
- [x] Add functional sound layers, mute/volume preferences and background pause handling. Verify generated/bundled assets and avoid audio spam/clipping.
- [x] Capture actual planning, sonar cover, two-drone and threat states at 1280×720 and 960×540 plus a wide aspect. Record runtime timings and errors.
- [x] Fresh Sol critic compares captures side-by-side with references and exercises scenarios before reading builder claims. Fix the single biggest consequential gap, recapture, and repeat while useful.

## Task 4 — Campaign, progression, saving and ending

Files: `game/src/campaign/*`, `game/src/persistence/*`, mission data and UI integration.

- [ ] Author six distinct missions with staged mechanics, authored routes, escalating objectives, briefings, debriefings and ending. Record mission design rationale.
- [ ] Add meaningful evidence-driven unlock/loadout choices and replay. Defeat retains earned progress.
- [x] Implement versioned active mission/settings/campaign saves, atomic replacement, safe corrupt-save recovery, pause on focus loss and resume confirmation.
- [ ] Test every mission via ordinary command-driven completion scenarios, resources and failure/retry; test save round-trip including drone routes, objectives, AI and paused state.
- [ ] Fresh integration critic exercises the actual campaign and reports progression, interaction, pacing, clarity and fairness defects. Resolve consequential findings and commit.

Task4 partial items: six missions, replay, prose ending, saves and actual-pointer campaign progression exist. Split Channel and the independently reviewed Cold Foundry now demonstrate differentiated task/observation pressures; other missions remain active content opportunities. Loadouts are selectable from the start, so meaningful evidence-driven equipment progression is still open. Ordinary all-mission fallback and save corruption/round-trip tests pass, while explicit defeat→retry and broader legacy-save/device lifecycle evidence remain outstanding. Two independent reviews are complete; material content findings remain active work.

## Task 5 — Android and quality closure

- [x] Rebuild latest APK; inspect package metadata, signing and included assets. Install/run with adb if a device exists; otherwise retain device validation as blocked, never simulated evidence.
- [ ] Run regression scenarios and actual-render captures; examine Android lifecycle wiring, memory/performance and safe areas. Device claims remain separate from desktop measurements.
- [x] Independent fresh Sol reviewer inspects integrated outputs and key sources; iterate on material quality gaps without arbitrary round count.
- [x] Update workbench, model assignment/usage record, evidence index and continuation. Commit and push meaningful progress to development branch; expose APK location/hash and limitations.

Task5 partial items: native39202066103/source93b8631 passed current cover/inner touch/lifecycle and ordinary Shelf Signal completion/new-process campaign restore, with>30s active audio and strict error/fatal gate. Exact APK/hash/cert and actual pictures are retained; PCM boundary defect is fixed and reproduced RED→GREEN. Full-campaign native play, physical ZFold7 folding/thumb/performance, human listening and store signing remain uncertified. Do not mark the Gauntlet closed because a build/review exists.

## Coordination and checkpoint rules

One Sol production lead owns game code and may use a fresh Sol critic when a working artifact is inspectable. One Sol tooling owner runs concurrently only in assigned files. Tooling publishes script contracts to the lead; lead waits for none of the optional installation work to implement deterministic logic. Do not have two agents edit `main.gd`/`project.godot` concurrently. Each fresh critic gets raw output/reference paths, scenarios and review rubric, then reads implementation as needed.

Tasks 1/2 share main→simulation initialization; task 3 consumes observations/commands, never mutates truth; task 4 consumes snapshot/command APIs; task 5 consumes artifacts from all earlier tasks. The production lead documents final interfaces and records revisions rather than pretending the initial plan anticipated every detail. Save completed task IDs and commit SHAs in WORKBENCH; do not rebuild completed work after context loss.


## Persistent Gauntlet mandate — user ratified 2026-10-18

**The Gauntlet is an open-ended, user-terminated improvement program.** A working prototype, complete six-mission campaign, passing tests, signed/installable APK, polished vertical slice, or app-store-caliber release candidate is a **baseline milestone, never the automatic stopping condition**. The long-term quality ambition is a cohesive, genuinely publishable Android game of the caliber a player could encounter on an app store; after reaching that bar, keep evaluating and improving until the user explicitly says to stop or changes direction. Do not interpret a task list, quality checklist, reviewer approval, or absence of severe defects as authorization to terminate the program.

After each meaningful milestone: (1) build/run and gather inspectable gameplay, visual, audio, interaction and Android evidence; (2) solicit independent evidence-first criticism when warranted; (3) identify the largest remaining experiential, design, content, technical or accessibility opportunity, including improvements beyond bug fixes; (4) prioritize against the established Siren's Song identity and source hierarchy; (5) implement and validate the next bounded improvement; (6) record results, evidence, known limitations and the next action, then repeat. Revisit the quality bar as the game improves. Avoid aimless feature accumulation, endless cosmetic churn and regressions: prioritize player experience, coherence, performance, and meaningful progress. Existing campaign and implementation tasks are the first production phase, not the entire Gauntlet.

**Session/usage/resource limits:** Stop executing when limits require it, preserve a runnable checkpoint, branch/commit status, exact evidence, remaining gaps and a specific next command in WORKBENCH and CONTINUATION. Label the state 'paused / awaiting continuation' rather than 'complete'. Resume the loop when execution becomes available; do not claim background execution across unavailable sessions or automatically bypass platform limits.

**User involvement:** As playable builds mature, invite targeted hands-on testing and incorporate the user's observations, preferences, and new direction. Human feedback becomes increasingly valuable; do not require it for every routine iteration or replace autonomous progress with approval loops. The user alone determines satisfaction and authorizes ending the Gauntlet. Distinguish internal quality estimates from user acceptance. Respect material premise/identity escalation rules and the existing model-budget policy.


## Ratified continuation beyond phase one

Follow `docs/BASELINE_AND_EXPERIMENTS.md` for preserved baseline/challenger comparisons, accepted tradeoffs and rejected experiments. Periodic fresh whole-game criticism and a separate evidence-based regression hunter follow deterministic comparisons after substantial changes; no invented faults or fixed round quota. Keep `docs/PHONE_DASHBOARD.md` phone-readable and current with existing artifacts. New workers inherit `docs/AGENT_BRIEF.md`; fit-to-task lighter agents are permitted, Sol remains the substantial-work default, premium is justified escalation only. Persist future agreed decisions in governing Git docs with rationale/source hierarchy.

Next focused cycle: user-prioritized zoom/pan and friendly touch UI. Prototype UI/screen dimensions are not constraints. Touch spec/plan dated19October defines the next challenger; preserve pause, explicit route intent and bounded observations, and verify gesture conflicts/accidental orders at cover/unfolded sizes. User hands-on direction remains authoritative without routine approval gates. Milestones never terminate the Persistent Gauntlet.

## Current ratified A checkpoint — 19 October

The original handoff/import/audit/remote-byte gate is satisfied. Preserve 8d8635a patrol/recovery and accepted f1ea536 APK while evaluating the local role challenger.

- [x] Retain pre-fix role RED and visible-pursuit RED; implement distinct Foundry sentinels / Well hunter using actual v7 behavior with production terrain/sensing/lock safety.
- [x] Verify conditional tether, stimulus/search/home return, actual visible pursuit/standoff, save/pause/legacy continuation and intentional no-input station stillness. Independent exact-source directed replay passes.
- [x] Rerun fixed naive panel, all-mission fallback, retained tactics and prior critic/loadout probes with source-labeled losses.
- [x] Capture actual 16-second passive player-view and response/failure footage with explicit no-input interval and perceptual limits; retain rejected setups.
- [x] Resolve fresh separate regression criticism and execute one coherent native candidate including explicit fixture-assisted Well role response/return. Numerical native 39216492480 passes; direct new APK bytes/pixels remain pending host access, not silently certified.
- [ ] Compare the selected dimension against actual shipped-game footage. Public media access is blocked; original-v7 local browser footage is supplementary, not a substitute.

Latest local gate 234 core / 230 runtime plus 8 navigation and 19 geometry parser checks passes; no native promotion follows from it. Source-specific figures and actual loss/return distinctions: docs/validation/production/siren-roles/README.md. After supported A checkpoint, resume parked density correction before unrelated feature expansion.

A numerical checkpoint 6388113 supports the demonstrated role/native gains only; candidate APK retains experimental finale ancestry, so native finale/full-campaign quality remains open. Preserve fully inspected f1ea fallback. Resume existing density 2fc0976 via selective UI/test/evidence integration after the guarded docs checkpoint; keep later governance/role/native diagnostics and fix initial-window/static-ID/actual geometry before focused review/native density. External shipped reference motion remains pending.

Density local checkpoint 6ce6cc0 plus focused route-intent feedback: 234 simulation / 230 runtime, final 699 geometry/text/GUI checks; actual cover/inner/menu captures and 16-second planning clips retained. Fresh separate critic confirmed the hidden-queue feedback regression, now fixed without changing simulation. Coordinate reviewed exact-source native metric/OS scroll gates; no pixel/physical/full-campaign acceptance implied.
