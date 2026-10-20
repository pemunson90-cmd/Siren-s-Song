# Siren’s Song · release depth and sonar handoff
Read AGENTS.md, USER_DIRECTIVES.md and CURRENT_GAME_SPEC.md first.
Approved full-release program remains active; human playtesting gates nothing.

Last reconciled source baseline: foundation a6b6701, landed as production fb4cf105.
Current milestone: integrated depth, sonar and stealth across opening0–5.
Same sole builder and branch gauntlet/release/depth-sonar through internal checkpoints.
Root owns independent exact-head review, game-smoke CI, PR and integration.
Other source trees, earned profiles, main, signer and recovery refs stay frozen.

Implemented candidate:
- Shared SHALLOW/MIDDLE/DEEP; adjacent stationary4s transitions occupy both bands.
- Inherited terrain plus authored per-band overrides, clearance and measured charts.
- Acquired enemy depth memory; existing beams remain conditional on current sight.
- Local bearing histories, motion/drone triangulation, own-noise/thermal masking.
- Sector/power selection, reserve cost, delayed emission-time echoes and occlusion.
- Receiver-owned sweeper audio, windup/return-strike windows and local stale reports.
- Craft-local controls, shared gesture ownership, waterfall and band feedback.
- Shelf Signal depth encounter; source-known quiet/deep and active/scout policies.

API: simulation.depth_feedback(), command("depth",{band}),
command("sonar_mode",{sector,power}), command("ping").
Factories may author depth_geometry[band].rocks/structures; omitted rocks inherit.
Machinery remains inherited across bands; local sites/recovery use MIDDLE.
Wreck custody retains its actual band. Current snapshots require depth/sonar state;
older journeys remain playable only on their preserved source, without migration.

Next on this SAME branch before review: develop the complete six-operation opening arc,
including encounter pacing, authored band choices, equipment/enemy interplay and
received story consequences; assess substantial playable milestones sequentially.
Internal checkpoint: only Shelf Signal has a new depth encounter. Remaining original
operations retain baseline middle-band solutions; their whole arc is unfinished.
28 core/12 optional operations, fleet/economy/research/frontend/presentation/audio,
challenges/replay, then expeditions and naval career remain the approved program.
