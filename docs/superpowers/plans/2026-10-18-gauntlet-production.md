# Siren's Song production implementation plan

> **For agentic workers:** Use superpowers:subagent-driven-development or superpowers:executing-plans. Execute continuously within the user's autonomous grant; model and review limits in the user request override conflicting skill defaults.

**Goal:** Build the complete Android tactical stealth campaign, verify real output, and preserve actionable quality checkpoints.

**Architecture:** Godot GDScript, deterministic simulation separated from data-driven campaign, presentation/audio/input and versioned persistence. See the architecture for exact invariants and creative decisions; a Sol owner refines implementation interfaces as necessary before shared work begins.

**Tech Stack:** Godot 4.6.3 Compatibility, GDScript, official matching Android export templates, JDK17, Android SDK, Python tooling.

**Spec:** `docs/superpowers/specs/2026-10-18-production-design.md` and `docs/architecture/GAUNTLET.md`.

## Global constraints

- Preserve all imported source files and the existing AGENTS.md model policy.
- All delegated production/critics explicitly request gpt-6.1-sol; do not claim unavailable actual-model/cost telemetry.
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

## Task 1 — Native production shell and verified toolchain

Files: `game/project.godot`, `game/scenes/main.tscn`, `game/src/main.gd`; tooling owner owns `scripts/toolchain/*`, `game/export_presets.cfg`, environment report. Project owner does not edit tooling-owned files concurrently.

- [ ] Create a runnable Godot scene with valid state from frame one, landscape scaling, pause and menu/mission transitions.
- [ ] Install official matching templates; record download/source/version. Export a debug APK, inspect its manifest/signature, and document exact reproduction commands.
- [ ] Start real rendering with the existing dummy Xorg display. Capture a PNG from the viewport; verify it is actual game output.
- [ ] Commit runnable shell and exact evidence. Record runtime/device gaps honestly.

## Task 2 — Deterministic tactical core and fair threats

Files: `game/src/simulation/*`, `game/tests/run_tests.gd`, `game/tests/scenarios/*`.
Interfaces: a mission definition and seeded new state; `step(dt)`/command API; serializable snapshot; observations and events for presentation. Sol owner must document actual class names/signatures before splitting ownership.

- [ ] Write failing assertions for pause invariance, frame-step consistency, replacement after unit switch, pass-through versus stop, known-wall routing, collision, LOS, ping-origin investigation, stunned detector recovery and extraction.
- [ ] Implement fixed-step movement, commands, two independent drones, local/active/recon observations, suspicion, fair Siren states, tool resource use and objectives.
- [ ] Run the production simulation headlessly; add adversarial tests for hidden-contact leakage and drone-loss fallback. Confirm failures are fixed rather than suppressed.
- [ ] Produce a deterministic scenario trace of a legitimate objective→extraction run. Commit.

## Task 3 — Playable art, sound, touch and tactical readability

Files: `game/src/presentation/*`, `game/src/audio/*`, `game/assets/*`, input integration in main; tests for input transforms.

- [ ] Inspect selected references C01/C02, Quietus exterior and Siren studies with view_image before building assets.
- [ ] Build original layered seabed, industrial structures, craft, fog/sonar shadows, routes and controlled VFX. Expose observed information only.
- [ ] Implement clear pause/resume, selected unit, replace/queue/emergency orders, stop/pass-through, conditions and tool feedback with phone-sized targets.
- [ ] Add functional sound layers, mute/volume preferences and background pause handling. Verify generated/bundled assets and avoid audio spam/clipping.
- [ ] Capture actual planning, sonar cover, two-drone and threat states at 1280×720 and 960×540 plus a wide aspect. Record runtime timings and errors.
- [ ] Fresh Sol critic compares captures side-by-side with references and exercises scenarios before reading builder claims. Fix the single biggest consequential gap, recapture, and repeat while useful.

## Task 4 — Campaign, progression, saving and ending

Files: `game/src/campaign/*`, `game/src/persistence/*`, mission data and UI integration.

- [ ] Author six distinct missions with staged mechanics, authored routes, escalating objectives, briefings, debriefings and ending. Record mission design rationale.
- [ ] Add meaningful evidence-driven unlock/loadout choices and replay. Defeat retains earned progress.
- [ ] Implement versioned active mission/settings/campaign saves, atomic replacement, safe corrupt-save recovery, pause on focus loss and resume confirmation.
- [ ] Test every mission via ordinary command-driven completion scenarios, resources and failure/retry; test save round-trip including drone routes, objectives, AI and paused state.
- [ ] Fresh integration critic exercises the actual campaign and reports progression, interaction, pacing, clarity and fairness defects. Resolve consequential findings and commit.

## Task 5 — Android and quality closure

- [ ] Rebuild latest APK; inspect package metadata, signing and included assets. Install/run with adb if a device exists; otherwise retain device validation as blocked, never simulated evidence.
- [ ] Run regression scenarios and actual-render captures; examine Android lifecycle wiring, memory/performance and safe areas. Device claims remain separate from desktop measurements.
- [ ] Independent fresh Sol reviewer inspects integrated outputs and key sources; iterate on material quality gaps without arbitrary round count.
- [ ] Update workbench, model assignment/usage record, evidence index and continuation. Commit and push meaningful progress to development branch; expose APK location/hash and limitations.

## Coordination and checkpoint rules

One Sol production lead owns game code and may use a fresh Sol critic when a working artifact is inspectable. One Sol tooling owner runs concurrently only in assigned files. Tooling publishes script contracts to the lead; lead waits for none of the optional installation work to implement deterministic logic. Do not have two agents edit `main.gd`/`project.godot` concurrently. Each fresh critic gets raw output/reference paths, scenarios and review rubric, then reads implementation as needed.

Tasks 1/2 share main→simulation initialization; task 3 consumes observations/commands, never mutates truth; task 4 consumes snapshot/command APIs; task 5 consumes artifacts from all earlier tasks. The production lead documents final interfaces and records revisions rather than pretending the initial plan anticipated every detail. Save completed task IDs and commit SHAs in WORKBENCH; do not rebuild completed work after context loss.
