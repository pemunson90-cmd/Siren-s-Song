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
- Receiver-owned listening clocks/sweeper audio, return-strike windows and stale reports.
- Craft-local controls, shared gesture ownership, waterfall and band feedback.
- All opening0–5 author distinct band crossings, local threats and ascent cover.
- Blackwater physical custody, Foundry thermal/motor, Well comparison, finale decode.
- Briefings are concise; own-state/received-evidence hints teach choices in play.

API: simulation.depth_feedback(), command("depth",{band}),
command("sonar_mode",{sector,power}), command("ping").
Factories may author depth_geometry[band].rocks/structures; omitted rocks inherit.
Machinery remains inherited across bands; local sites/recovery use MIDDLE.
Wreck custody retains its actual band. Current snapshots require depth/sonar state;
older journeys remain playable only on their preserved source, without migration.

Builder verification: all0–5 source-known input/render journeys finish on both views;
new1–5 policies spend no finite tool. Core672/runtime563, interaction72, context60,
Shelf input118, remaining input404 and rendered Song82 pass.
Fresh repair: band-aware cached torpedo aims/physical launches and craft-local recovery;
witness/module custody and plant continuity covered. Root independently reviews accumulated
source next. FIT/craft-handle friction and Well balance remain findings.
Only after that review/fixes: final-head CI and normal milestone PR.
28 core/12 optional, fleet/economy/research/frontend/presentation/audio,
challenges/replay, expeditions and naval career remain the approved program.
