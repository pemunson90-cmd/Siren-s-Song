# Audit — Step 05 disruption_tools

**Auditor session:** inspiring-upbeat-mccarthy (Cowork Dispatch child, Claude Opus 4.7-1M)
**Audited step handoff:** handoffs/05_HANDOFF_FROM_STEP5.md
**Audited code state:** code/sirens_song.html (97,702 bytes / 2,321 lines; +18,180 bytes / +394 lines vs. pre-step-5 backup)

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS | Tool fire paths (`fireJam`/`fireEMP`/`fireKnockdown`, sirens_song.html:870–926) store *deadlines* in `state.empStunUntil[type]` and `state.kdImmobUntil[type]`; never decrement any Siren property. Sim T7 fired 100× EMP at the same sentinel — object key shape stayed `["mode","orbitAngle","type","x","y"]`, no HP-like keys appeared. Sim ADV1 chained 50× EMP+KD cycles on sentinel; sentinel survived. Sim T9 confirmed `__sim` exposes zero APIs matching `/^(kill|destroy|deal|damage|hp|health|dead|attack)/i`. |
| 2. Suspicion is the spine | PASS | All three fire paths route through the `applySuspicion(amount, tag)` chokepoint at sirens_song.html:519, lines 858/884/902. Comment-stripped grep returns 0 `Math.random` references. Sim ADV6 confirmed determinism — two identical setups produce byte-identical state after 5 sim seconds. Stun maps and jam window are pure `state.timeSec` vs. deadline comparisons (`isSirenStunned` line 830; `isJamActive` line 838). |
| 3. Perceiving costs | PASS | Step-5 tools are NOT perception modes — they do not call any reveal path. Sim T11/ADV3/ADV4 confirmed `fireJam`/`fireEMP`/`fireKnockdown` never set `lastPing.valid = true`. `fireJam` explicitly *clears* `lastPing.valid` at line 879 (lock-break semantics). The four perception modes (passive, ping, drone-cam, sub-cam) are untouched. |
| 4. Tools buy time and cost heat | PASS | Sim T2 verified suspicion costs: jam +5 (line 858), EMP +20 (line 884), KD +20 (line 902). Sim T3 verified finite charges: 3 jam fires → 4th returns false (no cost, no effect); 3 EMP fires → 4th returns null; 2 KD fires → 3rd returns null. Sim T14 verified chain cost 5+20+20=45 exactly. Each tool buys time per spec windows (T4: jam 4s; T5: EMP exactly 5s; T6: KD exactly 12s). |
| 5. Fairness valve | PASS | Step-2 instakill timer (4s at 100) untouched and exercised: sim T16.1 confirms sustained-100 triggers `loseReason = "vaporized"`. Jam as recovery tool: at sub far from factory, suspicion 80 + 1 touching Patroller → fire jam → suspicion drops below 75 within 3s (sim T15 corrected stage). Mechanic: jam halves Siren proximity contribution during 4s window via `jamProxMultiplier()` at line 685 (sim T13 confirms exact 0.5× factor) and clears active ping lock. |
| 6. Function before form | PASS | All step-5 visuals are placeholder text/dashed shapes. Code grep: zero `<audio>`, zero `<img>`, zero `@font-face`/Google Fonts. HUD line 5 is plain text (`jam[1]: N   emp[2]: N   kd[3]: N   ARMED: ...`). Projectile is a colored line + dot tracer. Stun/immobilize rings are dashed strokes with countdown text. Code comments at lines 803–822 explicitly cite invariant numbers and INV6 placeholder status. |

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within step 5 scope | PASS | Grep for `recon`/`RECON` returns only a code comment ruling it out as step-6 scope (line 60). No new Siren types added. No tuning-pass rebalancing of step 1–4 constants. Patroller gained a `type: "patroller"` field (line 98 of handoff explains this is required to key stun maps consistently with Sentinel/Hunter); additive, not modifying step-2/3/4 logic. |

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS | Extracted `<script>` block (96,539 bytes) passes `node --check` cleanly. |
| Single file | PASS | One file at `code/sirens_song.html`; exactly one `<script>` block; backups (`*.bak.*`) are non-active snapshots. |
| No fabricated tuning numbers | PASS | All new TUNING values either cite spec §5/§6/§11 directly (charges, costs, durations) or are flagged `FLAG step 7` with brief-05 rationale (`JAM_WINDOW_SEC=4.0`, `JAM_EFFECT_PROX_MULT=0.5`, `TARGET_PICK_RADIUS_PX=90`, `PROJECTILE_SPEED_PX_PER_SEC=360`, `PROJECTILE_RADIUS_PX=3`). Reviewed lines 249–286. |
| No scope creep | PASS | Same as step-scope check above. |
| Invariant comments present where critical | PASS | Lines 780–824 are a structured "INV1/INV2/INV4/INV5 enforcement" block above the disruption-tool functions. Stun gate sites in update functions (lines 956, 1037, 1107, 1497) cite INV1 in inline comments. Ram and drone-kill stun checks at lines 1389 and 1458 cite "halts movement" spec language. `sirenProxTerm` at line 680 cites spec §5 EMP "halts movement + detection." |

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per agent.md §5.2 | PASS | Handoff has "What I built," "State of the file," "Spec sections implemented," "Tuning values used (with spec citation)," "Sim tests run," "Open potholes," "Design improvement notes," "Invariant adherence," and "Receipt" — all §5.2 sections present. |
| Tuning values documented | PASS | Table at handoff lines 122–139 lists 11 step-5 TUNING constants with values and source citations. |
| Sim tests logged | PASS | Handoff lines 143–204 log 198 sim tests across groups A–S, including 25 adversarial. Includes test-setup transparency notes (lines 206–218) explaining isolation helpers used. |
| Receipt present | PASS | Lines 274–283: "Step 05: COMPLETE / Files written: ... / 198 sim tests pass / Ready for: audits/05_AUDIT_STEP_05.md". |

## Sim tests I ran

| Test | Expected | Result |
|---|---|---|
| T1.1–T1.6 initial state (jam=3 / emp=3 / kd=2 / armedTool=null / jamActiveUntil<0 / projectiles=[]) | All defaults match spec §11 | PASS (6/6) |
| T2.1 fireJam at susp=0 | susp=5 | PASS (got 5) |
| T2.2–T2.3 fireEMP on sentinel at susp=0 (LOS-clear stage) | returns target with type='sentinel'; susp=20 | PASS |
| T2.4–T2.5 fireKnockdown on hunter at susp=0 | returns target type='hunter'; susp=20 | PASS |
| T3.1–T3.7 charge exhaustion (3/3/2 + 1) | Nth+1 returns false/null, no cost | PASS (7/7) |
| T4.1–T4.3 jam window 4.0s | active at t=0, t=3.9; inactive at t=4.1 | PASS |
| T5.1–T5.3 EMP duration | stunned t=0..4.9; clear t=5.1 | PASS |
| T6.1–T6.3 KD duration | immobilized t=0..11.9; clear t=12.1 | PASS |
| T7.1–T7.3 INV1 100× EMP | sentinel exists; key shape unchanged; no HP keys | PASS |
| T8.1–T8.3 50× chained tools on all 3 Sirens | all 3 still exist | PASS |
| T9.1 __sim API surface | no `kill|destroy|deal|damage|hp|health|dead|attack` keys | PASS |
| T10.1–T10.6 suspicionState boundaries | 0/33=CURIOUS; 34/74=ALERT; 75/100=WARNING | PASS |
| T11.1–T11.2 fire paths do not set lastPing.valid | False after fire | PASS |
| T12.1–T12.2 stunned Siren contributes 0 prox | pre>0; post=0 | PASS |
| T13.1 jam halves prox | jammed = full × 0.5 exactly | PASS |
| T14.1 chain cost 5+20+20 | susp=45 | PASS |
| T15.1 fairness valve | susp 80 + jam + 3s decay (factory-free stage) → susp<75 | PASS (final 66.29) |
| T16.1 instakill at sustained 100 | loseReason set | PASS (loseReason='vaporized') |
| T17.1–T17.4 stack independence | sentinel un-stuns at 5s; hunter still immobilized at 5.5s; mobile at 12.5s | PASS |
| T18.1–T18.2 EMP + KD stack on same Siren | KD continues after EMP expires; clear at 13s | PASS |
| T19.1–T19.2 LOS-blocked EMP | returns null; charge preserved | PASS |
| T20.1 stunned sentinel cannot ram | hull unchanged at Alert+ over 0.5s | PASS |
| T21.1–T21.3 armedTool wiring | set/cycle/clear via setArmedTool | PASS |
| T24.1 active ping +25 (regression) | susp=25 | PASS |
| T25.1 decay -5/sec passive (regression) | susp 50→45 after 1s | PASS |
| T26.1–T26.4 lose state blocks all fires | all return false/null; no cost | PASS |

## Adversarial sims

| Attack | Result |
|---|---|
| ADV1 50× EMP+KD cycle on sentinel | Sentinel alive, no HP keys |
| ADV2 sentinel HP-key regex sweep after chain | No matches |
| ADV3 fireEMP sets lastPing.valid? | No — confirmed false (no free reveal) |
| ADV4 fireKnockdown sets lastPing.valid? | No |
| ADV5 EMP re-fire at same t | Identical deadline (idempotent), no compound |
| ADV6 determinism | Two identical setups produce identical state after 5s |
| T19 LOS-blocked targeting | Returns null; charge preserved (no free fire) |
| T20 stunned ram | Stunned sentinel does not ram at Alert+ (INV5 preserved through stun) |
| T26 fires during lose state | All blocked, no cost |
| Hygiene: Math.random | 0 in stripped code |
| Hygiene: audio/img/font | 0 of each in HTML |

## Verdict

**GREENLIGHT**

All 6 invariants PASS. Step scope clean. Code hygiene clean (`node --check` passes; single file; tuning values cited or flagged for step-7 tuning pass; INV comments present at critical seams). Handoff complete per agent.md §5.2. 50+ sim tests run including 9 adversarial; 0 failures (one test stage initially failed due to placing sub inside factory-prox zone — corrected stage passes; this was an auditor test-setup bug, not a code defect, and the underlying mechanic was confirmed sound).

Key findings:

- INV1 is structurally airtight: stun maps store *time deadlines*, never modify Siren state. Repeated tool fire only refreshes the deadline; Siren always re-activates when window passes. `__sim` exposes zero HP/damage/kill APIs.
- INV4 cost-of-use chokepoint (`applySuspicion`) is the single seam for all three tool fires — costs land identically to step-2/3 patterns.
- INV5 fairness valve preserved: step-2 instakill-at-100-sustain-4s untouched; jam adds a genuine recovery tool (halves prox + breaks ping lock + +5 cost is the tension).
- Stun gate (`isSirenStunned`) is placed at the top of all four Siren update functions (`updatePatroller`, `updatePatrollerWithCuriosity`, `updateSentinel`, `updateHunter`) and inside both the ram loop and drone-kill loop, plus inside `sirenProxTerm`. All movement, detection, ram, and drone-destruction paths are correctly gated.
- The `type: "patroller"` addition to the Patroller initializer is the minimum-necessary change to key stun maps consistently — additive and back-compat with all step-2/3/4 sim tests (regression checks T24/T25 passed).
- All non-spec-default tuning values (`JAM_WINDOW_SEC`, `JAM_EFFECT_PROX_MULT`, `TARGET_PICK_RADIUS_PX`, `PROJECTILE_SPEED_PX_PER_SEC`, `PROJECTILE_RADIUS_PX`) carry `FLAG step 7` comments per spec §11 build-leash discipline.

Step 5 builds cleanly on the GREENLIT step 1+fixpass+2+3+4 substrate and does not regress prior work.

## Receipt

- Audit complete: YES
- Verdict: GREENLIGHT
- Orchestrator action: FIRE NEXT STEP (06 — Recon call-in)
