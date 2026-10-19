# Siren's Song progress workbench

**Stage:** Active Gauntlet, campaign baseline plus two evidence-driven improvement cycles. This is not a finished or user-accepted game.
**Branch:** `gauntlet/production`; latest committed gameplay reliability cycle `4463446`, current optical/safe-area cycle awaiting checkpoint.
**Player device:** Samsung Galaxy Z Fold7; physical installation/folding/thumb/performance review remains open.

| Workstream | Current state | Evidence / next action |
| --- | --- | --- |
| Sources/architecture | Preserved and implemented | Immutable imported corpus; Godot4.6.3 Compatibility architecture |
| Native tactical core | Runnable, regression tested | Fixed60Hz, inertia/assisted routing, two drones, fair LOS/acoustic/beam, command replacement and tactical pause |
| Campaign/save | Six playable baseline missions and ending | All six ordinary-command fallback runs pass; checksummed active/campaign/settings backup recovery; other missions still need differentiated situations |
| Split Channel proving ground | Connected channels, two separated relays + Quietus uplink | Coordinated39.3s, solo78.6s; latest standoff change yields67.3% hull in each scripted run; these are tactical fixtures, not human balance acceptance |
| Art/input | Actual textured world, physical ray, station-owned optical inset | `docs/validation/production/`; core53checks and runtime142checks pass, including pointer inputs, menu preservation, optical ownership and physical→logical safearea conversion |
| Audio | Original ambience/cues and volume/mute | Signal/headroom checks pass; functional propulsion/mixed-output/listening polish and forced-exit stream leak remain open |
| Android emulator | Native launch/log/UI markers verified by tooling; renderer/lifecycle CI iteration active | See `docs/CODEX_ENVIRONMENT.md` and `docs/validation/android-*`; modern backend retry; no Samsung performance claim |
| Independent criticism | Baseline plus follow-up completed, explicit fresh Sol | `docs/reviews/2026-10-19-baseline-critique.md`; confirmed attention defects fixed, next demonstrate learned safe return |

## Current evidence and highest-value next cycle

Combined validation: `scripts/toolchain/test.sh` → **53 core/campaign +142 runtime checks, zero failures**. Waypoint check totals vary with safe path simplification; invariant tests have been added, not removed. Full framebuffer optical, beam, and connected-channel captures are in `build/captures/cycle2-*` and retained in the validation index. Desktop rendering is distinct from installed Android/Samsung validation.

Next: demonstrate a learned safer Split Channel return/recovery plan with ordinary cover/noise/conditional orders and finite resources; explicitly verify stop/pass-through behavior; deepen mission differentiation and functional sound from the proving ground. Preserve the working baseline while native runtime/cutout/restore evidence matures. Do not stop the Gauntlet at these milestones.

## Continuity

Read `docs/CONTINUATION.md` and the plan before working. Model assignments and telemetry limits: `docs/MODEL_USAGE.md`. All production/critics explicitly request Sol 6.1. Engine decision and creative scope are documented; no additional routine approval is required.

## Production checkpoint 1 — native shell and core

Requested routing: sustained production `gpt-6.1-sol`, fresh-context dispatch accepted. Actual backend/token/cost telemetry unavailable. No nested implementation delegates.

- Created native `game/` project, scene, deterministic `Simulation` and six authored mission definitions, responsive touch HUD and original procedural ocean/stone/craft renderer.
- Interfaces: `Simulation.start(index, upgrade)`, `command(order, args)`, `advance(dt)` (fixed 60Hz), `snapshot()`/`restore()`, `visible(point)`/`line_clear(a,b)`. Commands never advance time. Briefed static terrain chart differs from sensor-observed water/contact memory.
- RED: initial motion test failed against stub. GREEN: `scripts/toolchain/headless.sh --script res://tests/run_tests.gd` → 2 checks, zero failures. This is an initial foundation check, not full gameplay coverage.
- `headless.sh --editor --import --quit` parses. Real GL capture: `CAPTURE_FRAMES=2 CAPTURE_DIR=build/captures/shell scripts/toolchain/capture.sh -- --scenario=planning`; actual PNG inspected.
- Actual visual evidence is currently too sparse/dark and contact/drone labels overlap at launch. High visual-quality gate remains open. Persistence/audio and adversarial/full-campaign tests are next.


## Gauntlet lifecycle

Status: **active, open-ended**. The current five-task production plan is phase one; a playable or app-store-caliber build is a milestone, not user acceptance or termination. After each review cycle record the highest-value next improvement and carry it forward. If execution limits intervene, checkpoint as paused/awaiting continuation. Only explicit user direction ends the Gauntlet.

## Production checkpoint 2 — campaign baseline, awaiting criticism

- Six ordinary-command objective→extraction fallback scenarios pass with finite disruption and no drones. Direct-to-marker naive routes originally lost to upper patrols; tested standoff positions and reactions to observed lock fixed solver tactics without weakening enemies.63–89s accelerated solutions certify solvability, not content quality.
-50 checks pass via `scripts/toolchain/test.sh`;137 actual-pointer/layout/lifecycle checks pass via `headless.sh --script res://tests/runtime_tests.gd`. RED→GREEN save checksum/atomic backup recovery and original audio signal/headroom; malformed snapshots now reject before navigation initialization (prior test reproduced missing-rock errors).
- Integrated versioned campaign/settings/active mission persistence, periodic/order/suspend saves, always-paused restore, separate volume/mute controls, event audio, scrollable briefings/operations, mission debrief/conclusion, full-viewport capture and stable Android diagnostic target/event markers.
- Original generated basalt material, Quietus sprite based on exterior reference, and alien foundry asset integrated as separate objects. Attribution in `game/assets/ATTRIBUTION.md`. Full native-size captures retained under `docs/validation/production/`; these are desktop rendering, not Samsung validation.
- Sole fresh critic dispatched explicit `gpt-6.1-sol`, fresh context/high reasoning: `/root/sol_production_lead/sol_evidence_critic`, read-only evidence review into `docs/reviews/2026-10-19-baseline-critique.md`. Backend/token/cost attestation unavailable. It inspected images/references first. No implementation fanout.
- Review/next cycle remains active. Largest visible concern is still sparse geography and flat threatening contacts versus selected continuous basalt channel concepts; critic also evaluating mission/drone incentives. Short forced capture exit leaks2 audio stream/playback pairs despite explicit stop/clear; unresolved, not hidden.
- Root/tooling investigating first-launch hosted Android PID failure; do not distribute launch-failing shell as user playtest. No production-lead pushes performed while useful CI run pending.

## Gauntlet cycle 1 — trustworthy divided attention + Split Channel proving ground

Independent report: `docs/reviews/2026-10-19-baseline-critique.md` (fresh Sol evidence-first; report includes original repros and independently verified follow-up). Review found briefing preview discarding active dive, zero-time paused plan missing resume, station selection silently canceling/stranding exposure, beam charge transferring targets, and dead-selected drones projecting tools. Focused RED tests reproduced all; fixes passed55core/139runtime before content work.

- Camera acquisition now completes autonomously after the pilot switches stations, while only one acquisition can run at once. Replacing the acquiring unit's route deliberately cancels it. New targets receive a fresh beam telegraph. Lost active drone falls back to Quietus; dead-origin tools reject.
- Briefing is a preview until ENTER WATER; returning from it preserves the active mission/orders. Paused pre-execution plans are resumable. Common enter/resume function emits stable native touch targets.
- Split Channel now has connected coastal masses/central dividing spine, separated WEST/EAST relay records and6-second Quietus-only archive uplink requiring both. Per-unit READY/ROUTE/HOLD/EXPOSING/LOST task labels visible at all layouts.
- The new coordinated scenario exposed a genuine autopilot bug: fast drones orbit/clipped dense40m corners, and a new coastal launch cell had unsafe clearance. Added failing navigation regression; fixed using sampled-clearance string-pulled paths, turn/corner speed assistance, safe launch separation. Pass-through retains speed on straight routes; physical inertia remains.
- Current combined suite:52core checks +139runtime, zero failures (waypoint assertions reduce after path simplification). All six fallback victories remain. Split solo:78.6s/hull81.7%; coordinated two drones+sub uplink:39.3s/hull6.4%, both drones survive, all3EMP spent. Faster coordinated route is risky; these are distinct automated tactics, not a claim of solved pacing/balance.
- Camera named fixture repaired to route a drone normally, acquire, change station and capture mid-exposure; recapture pending after new navigation fix. Next priorities: richer actual camera view/physical beam, safearea response to measured Android cutout, then reassess campaign differentiation and sound rather than expand counts.
- Root/tooling own native backend diagnosis; nextcombined push safe after this green cycle. Persistent Gauntlet continues; no completion claim.

## Gauntlet cycle 2 — observed optical/beam feedback and safe-area handling

- Added separate optical image panel and original generated physical ray asset, directional target/beam/impact overlay, clear contact memory symbol, and locking standoff so the Siren does not continue its stale approach route into the firing target. Regression demonstrated overlap after4.5seconds before fix.
- Follow-up critic independently inspected new framebuffers, verified52/140tests and traced coordinated damage to the return corridor (first damage at33.1seconds, after all collection completed). It reproduced optical inset blocking an actual escape-map tap. Fix: optical inset belongs only to the currently operated camera station; switching toQuietus clears it while acquisition continues. Pointer regression RED→GREEN.
- Native Pixel fixture reports136physicalpx cutout. New pure geometry conversion maps that to90.6667logicalpx at1.5scale; Android root receives safe-area insets. Diagnostic centers remain global/full-viewport logical coordinates. Installed cutout validation is still pending, not assumed from the formula test.
- Current combined53core/142runtime pass. Split coordinated39.3s/hull67.3%, both drones survive,3EMPspent; solo78.6s/hull67.3%. Changed standoff affects balance; continue assessing tactical learning rather than claim tuned difficulty.
- Actual successful optical acquisition captured whileDroneA operates the camera. Switching station acquisition continuity is separately exercised by production simulation and pointer tests. Actual beam capture uses ordinary route+hold after observed acquisition and deliberately stays exposed until96%hull to document emitter→target feedback.
- Repeated forced short capture exit still warns about AudioStreamWAV/playback references. No assertion that it is fixed or harmless on physical hardware. Next cycle follows the current top summary.
