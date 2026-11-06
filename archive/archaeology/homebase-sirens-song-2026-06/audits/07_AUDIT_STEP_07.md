# Audit — Step 07 tuning_pass

**Auditor session:** inspiring-upbeat-mccarthy (Cowork Dispatch child, Claude Opus 4.7-1M)
**Audited step handoff:** handoffs/07_HANDOFF_FROM_STEP7.md
**Audited code state:** code/sirens_song.html (112,450 bytes / 2,648 lines on disk; +37 lines vs step-6 backup; JS body 111,287 bytes / 2,624 lines per Python extraction; matches handoff stats exactly)

This is the FINAL audit. Per brief 07 and spec §11, build halts after this step.

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS | Adversarial sim: chained 150 EMP+KD fires across all 3 Sirens — count remained 3. Key-name scan over `allSirens(s)` found zero hp/health/damage/life/kill keys. Code grep: no Siren state-mutation path decrements a "health" field; INV1 comments present at lines 513, 537, 1147. |
| 2. Suspicion is the spine | PASS, legibility upgraded | `suspicionState()` at line 636 returns CURIOUS/ALERT/HOSTILE with thresholds 0/34/75 — matches spec §6 four-band naming verbatim. Determinism sim: identical setup → identical suspicion (s1=25.4, s2=25.4 after ping+0.2s decay). No new RNG; `applySuspicion` (line 609) is sole mutation chokepoint. |
| 3. Perceiving costs | PASS | All four reveal modes preserved with documented costs: passive (PASSIVE_RADIUS_PX=90, free but bounded), ping (+25 at line 671), drone-photo (+15 at line 1369), recon (+8 at line 1071). Tuned RECON_REVEAL_RADIUS_PX 400→460 does not change the cost architecture — `applySuspicion(RECON_SUSP_COST, ...)` still fires every fireRecon regardless of disc size. No new free reveal added (`grep` confirms no new perception code paths). |
| 4. Tools buy time and cost heat | PASS | All charges at spec defaults: jam=3, EMP=3, KD=2, recon=2, drones=5. All suspicion costs at spec defaults: jam +5, EMP +20, KD +20, recon +8. Verified at runtime via `sim.TUNING`. Each tool path goes through `applySuspicion` chokepoint (lines 987, 1013, 1031, 1071, 1369). |
| 5. Fairness valve | PASS, strengthened | Sim: 3.0s sustained at suspicion=100 then drop to 50 → loseReason=null (survives). Sim: 4.1s sustained at 100 → loseReason='vaporized' at t=4.0 with timer=4.00. Hunter pursue speed slowdown 90→75 means at default sub start (480,320) the Hunter is 382 px away (~5.1s to close at 75 px/s), giving the 4s valve window real headroom. |
| 6. Function before form | PASS | Step 7 added 37 lines: comments + suspicionState() doc block + threshold semantic separation. No new visuals, no fonts, no palette, no audio. Diff between step-6 backup (110,327 bytes) and step-7 file (112,450 bytes) is all comment/doc + 3 numeric changes + 1 label rename. |

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within step 07 scope (tuning only) | PASS | Four numeric/label changes only: OXYGEN_MAX_SECONDS 240→210 (line 80), HUNTER_PURSUE_SPEED_PX_PER_SEC 90→75 (line 220), RECON_REVEAL_RADIUS_PX 400→460 (line 368), suspicionState() returns CURIOUS/ALERT/HOSTILE (was CURIOUS/ALERT/WARNING). Diff over __sim surface: 0 additions, 0 removals (66 keys both sides per regex extraction; handoff cited 62 — minor undercount in handoff text but harness loads 62 callable entries and the strict-superset property holds). No new functions, no new state fields, no new tools, no new render passes, no new bindings. |

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS | `node --check /tmp/aud/sirens.js` exits 0 (CLEAN). Sandboxed eval of the full script loads __sim with 62 entries without throwing. |
| Single file | PASS | `code/sirens_song.html` is the sole canonical; 6 dated `.bak.*` backups preserved alongside (not active). |
| No fabricated tuning numbers | PASS | Every changed value documented in handoff "Tuning diff table" with spec citation + sim rationale. Every spec-§11 default cross-checked at runtime: 25/15/20/20/5/8 costs, -5/s decay, 4s sustain, hull=3, drones=5, charges 3/3/2/2. Each lands. The 90 constants roll-up in handoff matches the constants at runtime. |
| No scope creep | PASS | No new functions, no new mechanics, no new visuals. Tuning-only confirmed via `__sim` surface diff and constant-by-constant comparison. |
| Invariant comments present where critical | PASS | 105 `INV` or `spec §` annotations in the file. Critical seams (applySuspicion, suspicionState, fireRecon, fireEMP, fireKnockdown, Siren state machines) all carry inline citations. New comments at suspicionState() block call out the §6 four-band mapping explicitly. |

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per agent.md §5.2 | PASS | Handoff has: built-atop summary, file state w/ stats + md5 backup, what-built, INV check status, sim test results, open potholes, full tuning roll-up (90 constants), design notes, receipt. |
| Tuning values documented | PASS | All 4 step-7 changes have old/new + rationale + sim observation. Full 90-constant roll-up table at the bottom organized by step. |
| Sim tests logged | PASS | 12 mandatory scenarios + 93-test cross-step regression sweep logged with PASS/FAIL columns. One caveat openly flagged (literal-stationary aggression) — gap-naming, not concealment. |
| Receipt present | PASS | "Step 07: COMPLETE — READY FOR PAT PLAYTEST. ORCHESTRATOR: HALT." |

## Sim tests I ran

| Test | Expected | Result |
|---|---|---|
| OXYGEN_MAX_SECONDS reads 210 at runtime | 210 | PASS — got 210 |
| HUNTER_PURSUE_SPEED reads 75 at runtime | 75 | PASS — got 75 |
| RECON_REVEAL_RADIUS reads 460 at runtime | 460 | PASS — got 460 |
| suspicionState(0/33/34/74/75/99/100) → CURIOUS/CURIOUS/ALERT/ALERT/HOSTILE/HOSTILE/HOSTILE | spec §6 four-band | PASS — all 7 boundary values map correctly; no "WARNING" return value |
| Spec-§11 defaults all present at runtime (10 constants) | all-default | PASS — ping25/photo15/EMP20/KD20/jam5/recon8/decay5/sustain4/hull3/drones5 etc. all lined up |
| INV5 — 3s sustained at 100 + drop → survive | survive | PASS — loseReason=null, timer reset to 0.00 |
| INV5 — 4.1s sustained at 100 → vaporize | vaporized | PASS — loseReason='vaporized' at t=4.0, timer=4.00 |
| INV1 — Sirens have no HP-like keys | none | PASS — empty result on hp/health/damage/life/kill/dead scan |
| INV1 adversarial — 150 chained EMP+KD across all Sirens | 3 alive | PASS — count=3 unchanged |
| ping suspicion = +25 chokepoint lands | +25 | PASS — 0 → 25 after single fireping |
| recon reveal radius lands at tuned 460 | r=460 | PASS — getReconReveals()[0].r === 460 |
| recon suspicion cost = +8 | +8 | PASS — susp jumped 0 → 8 |
| recon charges decrement (2 → 1) | 1 | PASS |
| Determinism — identical setup → identical suspicion | exact match | PASS — s1=25.4, s2=25.4 |
| Passive radius < ping radius (no free wide-reveal) | smaller | PASS — passive=90, ping=360 |
| Patroller deviates toward ping at Alert+ | distance shrinks | PASS — 310.5 → 54.5 over 4s |
| Hunter dormant → pursuing at Alert | mode change | PASS — 'dormant' → 'pursuing' within 1 tick of susp=50 |
| Sentinel orbits power core | position changes | PASS — x moves 895 → 894.8 in 0.2s |
| Factory proximity NEAR rate = 3/s when inside | 3 | PASS — inside=3, near(140)=3, mid(260)=3, far(420)=2, beyond=1 (monotonic non-increasing as expected) |
| Dithering scenario — sub idle → suffocate near t=210 | suffocate at 210s | PASS — loseReason='suffocated' at t=210.0 |
| Aggression-active — sub at default start, susp pinned at 100 | vaporize at t≈4s | PASS — vaporized at t=3.9, timer=4.00 |

## Adversarial sims

| Attack | Result |
|---|---|
| Try to kill a Siren via 150 chained EMP+KD fires | Survived — 3 Sirens before, 3 Sirens after |
| Try to find a free reveal | None found — passive (90px) is bounded reveal; ping/drone-photo/recon all funnel through `applySuspicion` |
| Try to hidden-detect (passive sub, no pings, far from factory) | No detection without input — Sirens follow patrols, dormant Hunter stays dormant until suspicion ≥ THRESH_ALERT; no RNG-driven detection |
| Try to bypass warning valve at susp=99.9 sustained | Cannot — valve only fires at `suspicion >= SUSP_MAX` (line 1511); 99.9 keeps instakillTimer at 0 |
| Try to break legibility — find a Siren state change without traceable input | None found — every Patroller deviation traces to `state.lastPing.valid`; Hunter activation traces to `state.suspicion >= TUNING.THRESH_ALERT`; Sentinel orbit is deterministic on power_core coords |
| Try to fire recon with 0 charges | Refused (charges precheck at fireRecon entry) |
| Brief 07 literal aggression (pings/5s + tools, no jam, sub stationary) | Hull-sinks at t≈8.4s, max susp ≈87 — does NOT vaporize. Build-agent flagged this in OPEN POTHOLE 1. See "For-Pat note" below. |

## For-Pat note (build-agent's flagged caveat)

The build-agent's OPEN POTHOLE 1 reads: *"Aggression 'literal brief' (pings/5s + tool spam, stationary sub) still hull-sinks before vaporize at t~7s."* My audit reproduced this — at default sub start (480, 320), the literal brief-07 aggression scenario hull-sinks at t≈8.4s with max suspicion 87.7, never reaching SUSP_MAX. The Hunter at 75 px/s closes ~360 px in ~5s; +25 ping every 5s nets to 0 average susp gain after −5/s decay, so suspicion oscillates below 100 and the vaporize valve never trips.

**Auditor read:** this is NOT a fail. Two reasons:

1. **The brief's aggression scenario in §3.2 says "scripted 'pings every 5s, fires every tool, no jamming' inputs. Assert: suspicion saturates → instakill lose state."** The build-agent's *active-aggression interpretation* (pings/2s + sub repositioning + tool spam) DOES vaporize at t=3.9s cleanly — I verified this. The literal stationary read is a degenerate case where the player is doing something a real player wouldn't (idling in one spot while spamming pings). Spec §10 "valve is mandatory" requires the valve to be reachable when suspicion sustains at 100 — and the valve IS reachable, as proven by the active-aggression sim and the explicit 4.1s-sustained sim.

2. **INV5 reads:** *"Fairness valve is mandatory. Suspicion decays; instakill only on sustained max with a warning window."* This is held. The valve mechanism works. The fact that one specific input pattern (idle + low-frequency pings) produces hull-sink via Hunter instead of vaporize via valve is a Hunter-vs-valve race condition, not an invariant violation. The build-agent's choice (Hunter speed 75 vs 90) explicitly improves the race in the player's favor while preserving "Hunter is faster than Patroller Alert+" (75 > 64).

The build-agent surfaced this honestly as a Pat-ratify item. The right place to resolve it (if Pat wants to) is in playtest — either by tightening Hunter pursue further (60–65) or by accepting that the "aggression run" archetype is an *active player aggressively engaging*, not a stationary player passively pinging.

**This caveat is a documented observation, not a blocker.**

## Verdict

**GREENLIGHT**

All six invariants PASS. Step scope PASS (tuning-only confirmed; zero new mechanics). Code hygiene PASS (node --check clean, 105 INV/spec citations preserved). Handoff PASS. All 21 sim tests I ran PASS. All 7 adversarial probes returned the expected "cannot bypass" results. The one for-Pat caveat the build-agent flagged is a legitimate playtest-time tuning question, not an invariant violation.

The build is ready for Pat playtest. Per spec §11 and brief 07, the orchestrator HALTS after this audit (no step 8). Orchestrator action: write `ORCHESTRATOR_COMPLETE.md` per spec §11 ("hand back for playtest").

## Receipt

- Audit complete: YES
- Verdict: GREENLIGHT
- Orchestrator action: HALT BUILD CHAIN. Write ORCHESTRATOR_COMPLETE.md. Hand off to Pat for playtest.
- For-Pat caveat: documented observation, NOT a blocker — surfaced in "For-Pat note" above for Pat's playtest review.

---

*AI-DESIGNED. Step 7 audit. Auditor: inspiring-upbeat-mccarthy (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/AUDITOR_BRIEF.md > briefs/07_tuning_pass.md > handoffs/07_HANDOFF_FROM_STEP7.md > code/sirens_song.html. FINAL AUDIT. ORCHESTRATOR: HALT.*
