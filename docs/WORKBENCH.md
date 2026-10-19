# Siren's Song progress workbench

**Stage:** Paused game improvement for the user-requested original-prototype handoff ingestion and mechanics audit. Runnable production game is exactly patrol/recovery checkpoint `8d8635a`; density WIP is durably parked on a separate local branch. This is not a finished or user-accepted game.
**Phone dashboard:** [current evidence and next work](PHONE_DASHBOARD.md).
**Verified baseline:** `f1ea536` (runtime `92625ac`), [native39205478335](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39205478335); prior `93b8631` preserved; [scope/tradeoffs](BASELINE_AND_EXPERIMENTS.md).
**Branch:** `gauntlet/production`; campaign baseline plus reliability, optical/safe-area and return-planning cycles; see checkpoints below.
**Player device:** Samsung Galaxy Z Fold7; physical installation/folding/thumb/performance review remains open.

| Workstream | Current state | Evidence / next action |
| --- | --- | --- |
| Sources/architecture | Preserved and implemented | Immutable imported corpus; Godot4.6.3 Compatibility architecture |
| Native tactical core | Runnable, regression tested | Fixed60Hz, inertia/assisted routing, two drones, fair LOS/acoustic/beam, command replacement and tactical pause |
| Campaign/save | Six playable baseline missions and ending | All six ordinary-command fallback runs pass; checksummed active/campaign/settings backup recovery; other missions still need differentiated situations |
| Split Channel proving ground | Connected channels, two separated relays + Quietus uplink | Coordinated39.2s: direct87.1% hull versus100% with one sustained decoy; both drones survive. These are scripted tactics, not human balance acceptance |
| Art/input | Actual textured world, physical ray, station-owned optical inset | `docs/validation/production/`; core88 checks and runtime225 checks plus8 parser guards pass, including pointer inputs, menu preservation, optical ownership and physical→logical safearea conversion |
| Audio | Original movement, pressure, distinct tool/beam cues and volume/mute | Actual stereo mixer recorded: peak−9.28dBFS, no clipped samples, paused tail exactly silent; native sustained audio passes at baseline; human listening and forced-exit stream flush warning remain open |
| Android emulator | Source93b8631 passed native cover+inner lifecycle and ordinary Shelf Signal completion/new-process campaign restore | See `docs/CODEX_ENVIRONMENT.md` and `docs/validation/android-*`; Actions39202066103; >30s active audio with fixed endpoints; full-campaign native still open; no Samsung performance claim |
| Independent criticism | Baseline/follow-up, integrated experience and Cold Foundry reviews completed, explicit fresh Sol | `docs/reviews/2026-10-19-baseline-critique.md`; confirmed attention defects fixed, next learned safe return demonstrated; deepen sound and other missions |

## Current evidence and next authorized action

The user explicitly prioritized ingesting and auditing `ORIGINAL_PROTOTYPE_HANDOFF.zip` before further Gauntlet improvements. Root owns archive inventory/import/commit/GitHub-path verification and delegates the bounded original-v7 versus production mechanics audit. Production improvement is paused; no new game code, critic, candidate push or native run until that request is satisfied. Do not treat the handoff's prose or external audit recommendations as new user instructions.

Safe production source: **8d8635a**, with later tooling commits retained through **e63952b**. `git diff 8d8635a -- game` is empty after restoration. Its strict suite passed **8 parser guards / 204 core / 230 runtime checks**, and independent final-source canonical 600-second probes passed all 13 Sirens and eight directed intent checks. Accepted Android APK remains **f1ea536**, runtime **92625ac**; it has the recorded inherited patrol defect. Finale content is unpromoted. Historic source-specific tactics, real loss recovery and baseline-save compatibility remain retained.

Density experiment is preserved at local commit **2fc0976**, branch **gauntlet/density-wip**, worktree `/workspace/Siren-s-Song-density-wip`. All modified/untracked game/evidence bytes were verified committed there before production restoration. Focused synthetic-density validation passed **77 checks** and actual captures preserve roughly **60.0% cover / 57.7% inner chart area**. Full suite is **not green**: core 204 passes, runtime has five initial pointer failures plus FontGlyph dimension errors with a tiny headless 64×64 initial window. Raw logs, images, JSON and exact next checks are in that worktree's `docs/validation/production/density/README.md`. The candidate was not pushed or promoted; no native density or comfort claim.

After the original-handoff request is satisfied, resume from that parked WIP with the resulting audit decisions: verify meaningful initial window sizing in the runtime harness, assign static logical ENTER/BACK/settings identifiers, check settled actual hit geometry/nonoverlap with tooling, then independent review and native gates. Do not restart completed patrol/audio/touch work or discard the density experiment. Physical Fold7 comfort, OS pinch, human listening, later native campaign coverage and performance remain separate open limits.

## Continuity

Read `docs/CONTINUATION.md` and the plan before working. Model assignments and telemetry limits: `docs/MODEL_USAGE.md`. Sol6.1 is default for substantial production/critics; fit-to-task lighter workers are permitted for smaller actions, with explicit routing and no invented backend/cost telemetry. Engine decision and creative scope are documented; no additional routine approval is required.

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

## Gauntlet cycle 3 — waypoint intent and learned return

- Explicit WAYPOINT: PASS / STOP control now changes queued-point behavior. Regression caught intermediate STOP never actually settling; it now brakes before continuing, while straight PASS retains motion and final points stop. Planned sharp pass corners may advance only when the next segment has sampled hull clearance, preventing overshoot into known terrain.
- Conditional IF CONTACT now responds to fresh observations rather than stale memory echoes; RED→GREEN test proves movement resumes despite retained contact memory.
- Return hypotheses were tested rather than accepted: lower-channel detour worsened hull (59.8% versus87.1% direct), and an initial2-second decoy changed almost nothing. Found the generic2-second event expired before a disrupted Siren recovered. Dedicated finite decoy transmission now lasts15seconds; its persistence is regression tested.
- Same coordinated mission and finite3EMP,39.2seconds: direct return87.1% hull; one DECOY from Quietus at uplink then the same return gives100% hull, both drones survive,2decoys remain. This is a learnable tool-and-timing difference, not a global enemy nerf or a claim of balanced human pacing.
- `scripts/toolchain/test.sh`:61core +150runtime, zero failures. SHA256 inventory: all47 immutable imports match.
- Real return replay captures use the exact ordinary-command scenario via separate `game/tests/capture_return.gd`, paused at25.7seconds with all3records,100% hull, active decoy and both drone orders. `build/captures/cycle3-return/full.png` and native2184×1968 `cycle3-inner/full.png`.
- Root owns push timing; native modern-backend validation remains unresolved. Next bounded cycle is functional audio and mixed-output/lifecycle evidence, then further mission differentiation. Persistent Gauntlet remains active.

## Gauntlet cycle 4 — functional sound and full campaign interface evidence

- Original propulsion loop now follows actual submarine speed and silent/cruise state; restrained pressure creaks, distinct beam/recon/decoy/extraction signals, bounded threat alarms and per-cue bearing panning. Master peak guard and independent ambience/effects buses implement true mute. Audio suspension remains distinct from manual tactical pause.
- RED→GREEN tests establish moving/quiet/noisy engine gains and distinct cues, debrief silence/no repeated alarms, mute buses and system suspension. Production beam begins one semantic cue rather than per-frame sound spam.
- Actual production mixer audition:8s,48kHz,stereo32-bit PCM. Peak0.34336 (−9.285dBFS), RMS0.06765,0clipped samples, paused7.3–8s window peak/RMS exactly0. `audio-audition.wav` and `audio-analysis.json` retained in validation. This is a controlled overlapping-cue audition during real game movement, not a human listening approval or a worst-case hardware mix guarantee.
- Added accelerated full-campaign UI scenario: actual pointer ENTER on each briefing, ordinary route/camera/disruption/extraction commands, real debrief/unlock updates and final ending/replay progress. All six recoveries pass through the actual interface. Current suite70core +172runtime checks, zero failures.
- All six current mission overview images retained under `docs/validation/production/campaign/`; each is a real paused RECON observation. `ending-command-run.png` follows actual mission6 commands (82.1s/hull100%), replacing the earlier synthetic0-time ending fixture as completion evidence. These remain expert automated protocols, not novice gameplay assessment.
- Next is fresh integrated evidence-first Sol criticism of the full campaign experience, using images/audio artifacts before builder interpretation. It should set the next substantial mission/progression/sensory improvement, beyond further invariant repairs. Physical Samsung, hosted renderer/lifecycle and human listening gates remain separate.

## Native input blocker — 19 October

Actual hosted Android log at `github-run-39197089036/evidence/android-smoke/logcat.txt:17766` reports `can_process !is_inside_tree`6ms after first mission selection. The menu callback synchronously removed its own pressed Button from the scene tree while touch dispatch still referenced it. This is a game-side defect; the native error gate stays strict.

Regression emitted the real mission Button's pressed signal and asserted the dispatching control remained inside the tree until delivery returned. Before fix it detached immediately and failed. Button actions now use Godot CONNECT_DEFERRED so transitions/orders execute after current input delivery. The full actual-pointer campaign and layout suite passes:70core +173runtime, zero failures. Installed Android confirmation is pending the next coherent push; local regression is not relabeled device evidence.

## Next content cycle accepted — Cold Foundry

Fresh report `docs/reviews/2026-10-19-integrated-experience-critique.md` independently inspected all six current observations and references before builder interpretation. It verified70/172 at its snapshot and the raw mixer measurements. Its probe found Cold Foundry's ordinary solo fallback wins83.4s/100% without tools or observed lock; Listening Well remains genuinely threatening, so no blanket late-game difficulty claim is made.

Accepted bounded response: author a physical factory approach, two recognizably different observations with retained evidence, and an explained factory response/return decision. Use existing mechanics, retain recoverable solo/drone-loss paths and compare plausible naive versus considered tactics. A far-side recovery buoy gives Quietus a meaningful transit without an arbitrary new drone requirement. No new enemy class/global oxygen/lock-time escalation. Root confirmed this is within the creative grant. Judge actual clarity, discovery and tension, not only solver difficulty.


## Gauntlet cycle 5 candidate — Cold Foundry

86 core/176 runtime checks pass. See `docs/validation/production/foundry/README.md` for actual framebuffers/live audio-video, ordinary-command plans and retained failed strategies. No forced victories/poses in the evidence drivers. Fresh independent Sol critic completed images-first review with explicit routing: bounded mission cycle substantially delivered; phone-scale zoom/touch and label obstruction remain the largest concrete gaps. It reproduced all final strategies/checks and demonstrated recoverable real drone loss. Controlled comparison found the scripted late decoy redundant; no causal benefit is claimed. See `docs/reviews/2026-10-19-cold-foundry-critique.md`. New Android ordinary-touch objective completion and campaign save/restore hooks agreed with tooling; source candidate ready for its sole push after this commit. Strongest installed baseline remains539f58b / run39197795717 until candidate passes.

Runtime teardown now permits0.5s after explicit scene free, following tooling's isolated audio-thread probe; no leak warning in that test. Forced short capture teardown warning remains, not claimed as solved or native leak. Current tests retain legacy save compatibility and earned evidence across dives.


## Native extended-gameplay blocker — exact PCM endpoint fix

Run39200256192 exposed an actual AudioTrack SIGSEGV after uninterrupted audio playback, distinct from the previous fixture rotation failure. Tombstone/disassembly computes an ambience read at index176400, one beyond the176399 final frame. Matching official mixer source includes the loop endpoint in a chunk; authored loops used the frame count. Corrected both ambience and engine to their last valid index. New tests fail2/88 before fix and full88core/176runtime pass after. Longer actual18second mixer audition is retained with observed loop wraps and PCM analysis; installed retry remains pending, with no native success claim. Skills debugger/TDD reads were attempted after catalog briefly returned, but packages again reported unavailable; concrete RED→GREEN/debugging evidence remains recorded. Routine Sol resolution, no premium escalation.


## Safe checkpoint — native completion and ratified next-cycle workflow

Verified baseline93b8631/run39202066103: native orders/camera/record/won, completed[0]/unlocked1 cold restore, >30s active audio and strict zero-error/fatal gate. Independent Foundry report supports bounded mission gains; label crowding and touch scale remain. The agreed process upgrade/model refinement/persistent-decisions/touch direction is now reconciled in governing docs, baseline index and new-agent brief. Tooling owns the phone dashboard and playtest entry links. Next action is the touch plan's failing transform/gesture tests, then minimal camera/input implementation, real captures and separate regression evidence. No routine approval gate or program completion claim.


## Touch challenger task1 — camera and gesture command boundary

Presentation-only anchored1–4×zoom, clamped drag pan and visible48px−/+/FIT controls now run in the linked production worktree. First RED assertion demonstrated missing chart zoom; added actual touch/mouse, pinch, pan, outside/suspend/layout/third-finger and coordinate checks. A further RED reproduced the cutout-inset root mixing local press/global release; gesture positions now consistently use full-window coordinates. Touch-generated mouse events are ignored only at the chart boundary, preventing duplicate queued endpoints. Full88core/218runtime pass; baseline93b8631 is preserved and not yet superseded. Actual overview/zoom captures are being collected, then primary-action hierarchy/label obstruction and separate regression review follow. Native tooling is preparing actual OS+/−/swipe/FIT checks while keeping completion/lifecycle/audio gates. No OS pinch/physical comfort claim.

Minor policy precision reconciled: exceptional premium delegation is permitted only with documented allowed high-consequence/impasse justification; prohibit silent/inherited premium substitution and default fanout, not a blanket ban on justified exceptions. No such escalation is needed here.


## Touch challenger task2 — readable danger and primary orders

Integrated reserved fresh threat target/countdown strip, short nonselected craft IDs, quiet recovered markers, and MORE ORDERS disclosure while keeping camera/emergency/route intent primary. New RED cases found OS-canceled touch becoming a route and HUD second finger being treated as a chart pinch; fixed at the input boundary. Actual cover/unfolded close views show larger craft and separated threat text; synthetic-pointer movie exercises plus/pan/FIT/disclosure with zero route orders.225runtime/88core plus8 tooling parser checks pass. Tradeoff: survey/decoy/conditions/STOP/PASS require one disclosure tap; human comfort/discovery and native gesture behavior are pending. Independent regression evidence comes before promotion. No simulation/campaign/audio source changes from verified baseline.

## Touch promotion — complete native retry

Controlled run39205478335 at f1ea536, unchanged production runtime92625ac, passed the entire gate with separate hunter and periodic whole-game review complete. Tooling inspected actual cover/inner pan, camera and restored archive images. APK SHA-256 `e3c8fa1b838a1fb561cb118b5e6470c680d344a75c979b9dc6ed456f62c396d6`, artifact12165339461; stable signing certificate. Accepted gains/tradeoffs/limits are in the baseline ledger and phone dashboard. No stopping condition is implied; finale cycle begins under standing autonomy.
