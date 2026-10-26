# Hunt restore (V7 global Hunt, made visible)

## Current sight-only implementation decision, 25 October 2026 Eastern

Pat approved sight-only Hunt first and authorized ordinary table choices to remain reversible. [USER_DIRECTIVES](../USER_DIRECTIVES.md) governs; PR147 supplies the implementation, and the live `codex/handoffs` board owns validation and completion. The proposal below remains historical evidence. Its statements about shared readiness, hearing scaling, guard stamps and unbuilt behavior do not describe this source.

- Shared `Recon.readiness` remains unchanged. A separate pure sight helper uses max(existing local readiness, capped global stage) at the three existing sight calculations and matching observed-contact photo ring. Hearing, movement, four-second lock, beam, hull, damage, goals and reports retain their rules. Increased sight can naturally cause an earlier normal reaction; there is no global hearing or speed bonus.
- Stage thresholds/scales and action delay/decay/floor reuse the existing pressure system. Eligible sight roles are patroller, sentinel, hunter and sweeper. The +6 edge reads ordinary craft lock/beam states. Separate interceptor/warden visual windups and listening buoy/relay systems remain unchanged; all-eight-role acquisition edges are not claimed. IDs 0..29 use the proposed caps; distinct final-pair IDs 30/31 conservatively use 1.00. These are reversible tuning defaults, not campaign-balance acceptance.
- Fresh starts add optional `mission.hunt_pressure`; absent means inactive for old/in-progress saves. Required revision/stage/seen and optional cause/cue_at/pending/stage_cause are validated beside existing save checks, even with the feature off. No `hunt_scale` guard field is persisted. Quiet tools add zero Hunt only in opted-in missions; physical emissions and tool costs remain unchanged.
- One observer commits Hunt at the end of each completed step, after actual sight and photo completion. Deriving the sight floor directly removes the earlier need to stamp guards before sensing. Failing regressions proved that the proposed earlier placement lost a sight edge before paused Disrupt and misattributed a same-step photo rise; both original failures remain evidence. No second sensing pass or new enemy knowledge is introduced.
- The meter uses standard project buttons/help/Back, with word, five pips and global factor. Stage4 has a gentle one-hertz opacity pulse, at least85 percent opaque, using the paused simulation clock; its rate is table-configurable. Touch pauses and explains the last own action; local alert can already be higher. Its own compact help sheet sits beside full-size Back and scrolls at 960x432. Existing unrelated 960 basic/radial clipping remains a historical limit, not a claim of full small-window HUD repair.
- The existing generated rising develop cue, Soundscape event/voice/lifecycle handling and ambience player are reused. Stage-up dispatch is limited to once per 3 seconds; ambience offsets retain the proposed table and early 3 dB cap. Fresh received-contact threat still owns heartbeat/lock warning. Attached AI trace records bounded public Hunt rows separately from per-Siren events, with no new runtime hook.
- Revert: set `simulation/hunt_pressure/hunt_table.gd: enabled=false`; keep validation, files, tests and evidence. Presentation values/text live in `presentation/hunt_meter/meter_table.gd`. Official Godot 4.6 Dictionary, Control/Containers and AudioStreamPlayer references were checked; existing project systems are reused.

This documents concrete source behavior. Exact-head test/review/hosted/merge evidence belongs to PR147 and the handoff. Desktop fixtures do not establish whole-campaign, blind-player, physical-phone or human acceptance. No APK or promotion is authorized here.

## Historical 24 October proposal (retained in full)

**AI-DESIGNED (Claude, 24 Oct 2026). Proposal for Pat's ratification.** Pat, 24 Oct: "we also need to restore the hunt mechanism from v7 parity". That request is the decision to restore the V7 global Hunt pressure. Every number, cap and screen below is a proposal for him to adjust. Baseline: `claude/integration` at 2888192. V7 = `reference/original-prototype/sirens_song_prototype_v7.html` (call it V7:line). Other cites are `file:line` on the baseline.

## 1. What V7 actually does (the V7 source is in the repo)
- Meter 0 to 100, reset to 0 at run start (V7:160). Stages by value: 0 to 19 DORMANT, 20 to 44 STIRRING, 45 to 69 SEARCHING, 70 to 89 HUNTING, 90 to 100 LOCKDOWN (V7:210, names V7:573).
- Rises: time nudge +0.2 per second (V7:117, 344); the moment any Siren starts detecting you after none did, +6 (V7:345); photo +8 (V7:262); active sonar ping +5 (V7:248); EMP +4, even with no Siren in blast (V7:253); knockdown hit +4 (V7:238); graze hull hit +6 (V7:391, graze is not in Godot and stays out). Decoy and recon plane add 0 (V7:235, 250; MANIFEST.md:109 says this was deliberate, "quiet/misdirection tools").
- Decay: every rise sets a 6 s delay (huntDelay 6); after it the meter loses 1.0 per second (V7:117, 346), net about 0.8 per second with the nudge.
- Floor: photos taken x 8, so progress never fully cools (V7:347).
- Effect on Sirens: one thing only. Stage multiplies each Siren's sight detect radius by 1.0, 1.15, 1.3, 1.5, 1.7 (V7:209 to 211). Hearing radius, patrol speed, chase speed and hunter behavior are not scaled in the code.
- Effect on world: ambient gain 0.10 + 0.02 x stage (V7:349), the factory border turns red and thick at stage 3 or higher (V7:455), HUD text `HUNT: <STAGE>` colored cyan, cyan, amber, amber, red and blinking at stage 4 (V7:573, 574).
- Proposal-only in the design note, never coded: +10% patrol speed at stage 1, hunter prowling, Sirens drifting to objectives, a Siren roaming extraction (`SIRENS_SONG_pressure_design.md:53 to 58`, deferred at MANIFEST.md:106). The note also says time +0.6 per second; the shipped code uses 0.2. Code wins.

## 2. What Godot does now
The meter already exists; it just does nothing to Sirens.
- `recon_consequences.gd:7 to 14`: `action()` adds and sets a 6 s delay; `tick()` does +0.2 per second and, after the delay, -1 per second, clamped to the floor. Floor is 8 per secured record (`:30`). Stage thresholds 20/45/70/90 and names are identical to V7 (`:59`). It lives in `mission.reconnaissance`, so it starts at 0 every operation.
- Raises: active sonar 5, disruption 4, knockdown 4, decoy 4, survey 4 (`simulation.gd:696, 697`); unusable exposure 3 (`:788`); repeat photo 3 (`photo_orders.gd:23`, `tuning.gd:24`); secured record +8 and floor (`recon_consequences.gd:30`). No detection-edge raise, no graze. Decoy and survey differ from V7 (V7 has 0 for both).
- Effect on Sirens: none from the global meter. Sirens use a per-Siren hidden `alert_floor` (raised 0.12 per heard pulse or sight, `recon_consequences.gd:17, 22, 33`) mapped by `readiness()` to the same 1.0 to 1.7 table (`:25`). It scales sight (`simulation.gd:1043, 1108, 1113`), hearing (`:1110, 1186 to 1195`) and speed +20% per 1.0 of floor (`:1171`). The player cannot see it (STEALTH_AI_ROADMAP 1.2).
- Show: the HUD line `OP PRESSURE · <STAGE>` appears only outside advanced orders and only when hunt > 0 (`mission_hud.gd:542, 543`), so advanced players see nothing. Sound ignores Hunt on purpose (`soundscape.gd:125`, audio ATTRIBUTION.md:56).
- Parity ledger row "Global Hunt and action pressure" is Partial: "no global buffs", "no remote awareness" (`V7_TO_GODOT_PARITY.md:19`); spec asks to "integrate or deliberately replace" the floor without blind copying (`CURRENT_GAME_SPEC.md:78, 91`).

## 3. Design: one module, one seam
**Files.** `game/src/simulation/hunt_pressure/hunt_table.gd` (all numbers, the flag, revert note), `hunt_pressure.gd` (pure functions), `game/src/presentation/hunt_meter.gd` (the display). Tests beside it.

**Seam.** `HuntPressure.observe(sim, dt)` is called once in the tick right after `Recon.tick(mission, dt)` (`simulation.gd:730`). It (a) feeds the missing V7 raise (+6 on a new sight edge), (b) stamps `guard["hunt_scale"]` on each eligible Siren. `Recon.readiness()` gets one changed line: `return maxf(local_table_value, guard.get("hunt_scale", 1.0))`. Every sense site already calls `readiness`, and so does the photo price estimate (`photo_pricing.gd:216`), so quoted prices stay truthful. The module reads sirens and writes only `hunt_scale` and its own save field. No change to lock, beam, damage, goals, routes, or reports.

**Combining.** `max`, not a product. A Siren with its own earned floor is not double-counted; Hunt lifts Sirens that have not met you. The Hunt term is capped by operation (table below). The local term is untouched.

**Data table (placeholders, Pat adjusts).**

| Item | V7 | Godot now | Proposed |
|---|---|---|---|
| Thresholds | 20/45/70/90 | same | same |
| Stage scale | 1.0/1.15/1.3/1.5/1.7 | same, on alert_floor | same, from Hunt, then capped |
| Time nudge, delay, decay | +0.2, 6 s, -1.0 | same | same |
| Floor | 8 per photo | 8 per record | same |
| Sonar / EMP-disrupt / knockdown | 5 / 4 / 4 | 5 / 4 / 4 | same |
| Photo | 8 | 8 | same |
| Decoy / survey | 0 / 0 | 4 / 4 | 0 / 0 (restores "quiet tools are cheap") |
| Unusable or repeat exposure | none | 3 | 3 (Godot only) |
| New sight edge | +6 | none | +6 when any Siren starts seeing a craft after none did |
| Graze | +6 with hull loss | none | not restored (no new damage) |
| Roles scaled | all | all (via local floor) | patroller, sentinel, hunter, sweeper only |

Excluded: buoy, relay, interceptor, warden. Their ranges are tuned by hand in the listening and industrial modules and they should not scale twice.

**Per-op cap on the Hunt scale (op ids, player number is id + 1).**

| Op ids | 0 to 2 | 3 to 5 | 6 to 13 | 14 to 21 | 22 to 29 |
|---|---|---|---|---|---|
| Max scale | 1.00 (meter shows, no effect) | 1.15 | 1.30 | 1.50 | 1.70 |

Worst case read: a silent craft is seen at 180 x cap, 207 m at ops 3 to 5, 234 m at ops 6 to 13, 306 m at the end. A loud craft starts at 290 m. The per-op table folds into Phase E's `difficulty_curve.gd` when that lands.

**Sound.** Add one short rising cue each time the stage goes up (at most one per 3 s, existing generated-audio path) and move ambience by V7's ratio, 0.10 + 0.02 x stage: +0, +1.6, +2.9, +4.1, +5.1 dB, capped at +3 dB on ops 0 to 5. Stage 4 keeps the heartbeat path unchanged. Hunt is earned from the player's own actions and shown on the HUD, so reading it in audio no longer leaks hidden state; the comment at `soundscape.gd:125` is updated, and source positions and locks stay unread.

**Save.** Optional `mission.hunt_pressure = {"revision": 1, "stage": int, "seen": bool}` (stage memory for the cue, last sight flag for the edge). Validator `HuntPressure.valid(mission)` is registered like the other mission validators (`save_checks.gd:45`) and also checks `reconnaissance` has finite hunt and floor in 0 to 100 with hunt at least floor. Absent field means the module is inactive for that mission, so every old save, and every operation started before this lands, behaves exactly as today. New missions get `revision: 1` at creation. Implementer must confirm the saved Siren validators accept an extra `hunt_scale` key, or strip it from snapshots.

**Flag and revert.** `HuntTable.enabled` (static var, as in `first_siren_cue/cue_table.gd`). Off: no stamp, no sight raise, no cue, HUD identical to today, no new save field written. Revert note in the header: set `enabled=false`, or revert the PR; the single `readiness` line returns to the local table.

## 4. Readability and fairness
**Visible rule.** Hunt is never hidden. A meter sits on the chart at all times in a mission, in advanced orders too (today it does not). Layout: one chip `HUNT · SEARCHING ×1.30` with five pips, 48 dp tall, anchored under the top instrument, clear of the warnings stack and the arrivals badge; word plus pips, never color alone (cyan, cyan, amber, amber, red as V7); a stage-4 pulse no faster than 1 Hz. Tap it and the pause panel says what raised it last and that Sirens now notice from farther by that factor. Verify at both Fold7 shapes and 960x432. Hunt stops while paused so it can always be read.

**Fairness.** No change to the 4 s lock window, beam, damage or hull. Hunt scales existing sight and hearing radii only, inside the caps. Existing aids (first-Siren cue, lock countdown) are unchanged. Ops 0 to 2 cannot be made harder. The meter shows what the player did to earn it, so a larger radius is explainable.

## 5. What changes about "no global buffs, no remote awareness"
Those were deliberate choices (`V7_TO_GODOT_PARITY.md:19`, `recon_consequences.gd:4`). Pat has now overridden the first: Hunt is a global, public multiplier on Siren senses. The second stays: Hunt gives no Siren a goal, a position or a report, and V7's deferred convergence (Sirens drift to objectives, a roaming extractor) is not restored. A Siren far from you does nothing different. Only the radius at which it can notice you grows, and only if you are already within it.

## 6. Interaction with the roadmap
- **Phase B (tiers and indicators).** Global Hunt (this doc) and per-Siren `alert_floor` stay separate: the chip shows the global stage, B's "wary" mark shows a Siren's own floor. Share one glyph set and the stage names. Pat's open B question (does `readiness` stay) is answered for the Hunt part; the local floor is still B's call.
- **Phase D (alert sharing).** A delivered report is Siren to Siren, not a player action, and adds no Hunt. The report-triggering sight already counts through the sight edge. D must not call `HuntPressure` for relay or buoy hops.
- **Phase E.** The cap table moves into the difficulty curve. **Phase G.** The AI trace should log `hunt_stage` changes with cause (sonar, photo, sight edge, decay) so tuning is measurable; this restore can land before G with tests only.

## 7. Tests
- Determinism: same scripted run twice gives identical hunt, scale and cue timing; no random calls; save at any tick and restore replays the same values.
- Raises: each action adds exactly its table amount and resets the 6 s delay; decay is -1.0 less the 0.2 nudge after the delay; floor holds after N records; sight edge fires once per none-to-some change, not every tick.
- Stages and caps: scale equals the V7 table, never exceeds the op cap, ops 0 to 2 stay 1.00, excluded roles stay unscaled, `max` rule with a local floor.
- Fairness: lock timer, beam and damage outputs identical flag on and off in a scripted lock; sight radii never exceed cap x base.
- Save: old save (no field) loads and plays identically; new save round-trips; corrupt field is rejected like the other validators.
- Flag off: whole existing core suite unchanged. Journeys for ops 1 to 5 (player 2 to 6) still win bare with identical results at the proposed low caps; photo price tests rebased only where Hunt is above 20.
- Presentation: meter present in advanced and basic HUD, 48 dp, by real touch at both Fold7 shapes and 960x432; cue plays once per rise.

## 8. Pat to ratify
1. The numbers in section 3, especially decoy and survey at 0, and the new +6 sight edge.
2. The per-op caps, and whether ops 0 to 2 show the meter without effect.
3. Whether Hunt persists between operations (proposed no: resets each op, as now) or carries a decayed value.
4. What the HUD shows: chip with stage word, five pips and the ×factor, plus tap-to-explain; or word only.
5. Whether hearing and the +20% alert speed are scaled (proposed: sight and hearing yes through `readiness`, speed no, as V7 code).
6. Excluding buoy, relay, interceptor and warden.
7. Ambience shift, stage-up cue, and the +3 dB early cap.
8. Whether graze (hull damage plus Hunt) stays out. Proposed yes, since it would add damage.
