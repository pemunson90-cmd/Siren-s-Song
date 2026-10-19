# Siren's Song progress workbench

**Stage:** Architectural kickoff complete; Sol production starting. Full game is not yet built.
**Branch:** `gauntlet/production`, based on `3bfd7f41934d7f302896e5caa71f4a9f3787e4a9`.
**Player device:** Samsung Galaxy Z Fold7. Cover and unfolded layouts are required.

| Workstream | Status | Evidence / next action |
| --- | --- | --- |
| Source import | Complete | 47 immutable source files, original SHA inventories in `docs/source-import/` |
| Corpus/visual/architecture | Complete | `docs/architecture/GAUNTLET.md`, ADR 0001, production design/plan |
| Environment/toolchain | In progress, Sol | Godot4.6.3, JDK17/SDK available; official templates installed and dummy Xorg rendering verified. `docs/CODEX_ENVIRONMENT.md` |
| Native game/simulation | Starting, Sol lead | `game/`; real game tests/captures pending |
| Art/audio/touch | Planned | Compare actual output with C01/C02 and Quietus/Siren references |
| Campaign/progression/save | Planned | Six authored missions, ending, lifecycle and replay gates |
| Android emulator CI | In progress, Sol tooling | GitHub Actions native install, lifecycle, cover/unfolded screenshots |
| Device review | Pending | Actual Z Fold7 installation/touch/fold/performance |

## Evidence and criticism

No new game quality claim yet. Raw evidence, tests, independent critiques and biggest remaining gap will be added here as produced. Initial largest gap: no production executable.

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
