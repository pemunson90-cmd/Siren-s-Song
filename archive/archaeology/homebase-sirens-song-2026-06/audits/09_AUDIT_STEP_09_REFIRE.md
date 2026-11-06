# Audit -- Step 09 v0.3_pullin_patch (RE-FIRE)

**Auditor session:** sharp-magical-dirac (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context)
**Audited step handoff:** `handoffs/09_HANDOFF_FROM_STEP9.md` (RE-FIRE handoff)
**Audited code state:** `code/sirens_song.html` 147,438 bytes / 3,462 lines / md5 `477469ef51d2a0876df13d009e7cd610`
**Pre-Step-9 backup:** `code/sirens_song.html.bak.pre-step9-20260605` (135,266 bytes; md5 `9e6d673b4bcc3e8a82a100f414ef0557`)
**Prior audit:** `audits/09_AUDIT_STEP_09.md` -- verdict RED, file truncated mid-comment, no closing tags. This RE-FIRE audit independently verifies the re-built file.
**Authority chain:** `SIRENS_SONG_SPEC.md` > `agent.md` > `briefs/AUDITOR_BRIEF.md` (Step 9 section) > `briefs/09_v03_pullin_patch.md` > re-fire handoff > current code.

---

## TL;DR

**VERDICT: YELLOW -- patch lands cleanly; two documented partial implementations.**

All four ratified pulls landed. File integrity is clean (3,462 lines, 147,438 B, md5 verifies, parses with zero errors, closing tags present). Pull 1 (EMP / kill-rule fix), Pull 2 (shadow cones), Pull 3 (AU module), and the structural skeleton of Pull 4 (silent running + noise computation) are all wired and pass their gate sims. Two intentional deferrals are documented in the handoff:

1. `AU.beat()` HOSTILE-entry seam is defined but not bound to the suspicion rising-edge transition. Brief 09 listed it as desired; handoff defers it. Not a regression (pre-Step-9 chain had no audio at all). All other AU seams are wired.
2. `noiseRForSub` is computed, exposed via `__sim` and HUD, and is consulted on neither the Siren AI investigate-set path nor the suspicion path. The mechanic functionally manifests through the existing proximity term once a Siren closes; the soft-investigate write-through is deferred to preserve INV2 / INV5 from any unverified perturbation.

The two deferrals are surfaced honestly in the re-fire handoff (section 7) and matched in the source. Pat decides whether to accept them as a Step 9 close (RECOMMEND) or queue a Step 9b for the noise-investigate write-through.

No regressions detected. Step 1-8 logic byte-equivalent (`isLineOfSightClear`, `applySuspicion` md5-identical to baseline). The 73 pre-Step-9 `__sim` entries are preserved; 7 new entries added (strict superset).

---

## File integrity check (mandatory gate)

| Check | Expected | Observed | Status |
|---|---|---|---|
| md5sum | `477469ef51d2a0876df13d009e7cd610` | `477469ef51d2a0876df13d009e7cd610` | PASS |
| Line count | 3,462 | 3,462 | PASS |
| Byte count | 147,438 | 147,438 | PASS |
| `</script>` count | 1 | 1 | PASS |
| `</body>` count | 1 | 1 | PASS |
| `</html>` count | 1 | 1 | PASS |
| Tail ends with `</html>\n` | yes | yes -- last 50 bytes: `tAnimationFrame(frame);\n</script>\n</body>\n</html>\n` | PASS |
| `node --check` on extracted JS | EXIT 0 | EXIT 0 -- "PARSE OK" | PASS |

Backup integrity (rollback target):

| Check | Expected | Observed | Status |
|---|---|---|---|
| backup md5sum | `9e6d673b4bcc3e8a82a100f414ef0557` | `9e6d673b4bcc3e8a82a100f414ef0557` | PASS |

File integrity gate: PASS. The first-fire truncation failure is fully remediated.

---

## Pull verification

### Pull 1 -- EMP / kill-rule fix (active detector gate)

| Check | Result |
|---|---|
| `function hasActiveDetector()` defined | PASS -- HTML line 2016 |
| Predicate body: un-stunned + per-type radius + LOS | PASS -- iterates `{patroller (PATROL_RADIUS_PX+180=194), sentinel (SENTINEL_DETECT_RADIUS_PX=220), hunter (HUNTER_PROXIMITY_RANGE_PX=200)}`; each branch tests `!isSirenStunned(s)` && `dist^2 <= radius^2` && `isLineOfSightClear(s.x, s.y, sub.x, sub.y)`. Returns true on first satisfying Siren; false if none. |
| Kill gate uses `hasActiveDetector()` | PASS -- HTML line 2178: `if (state.suspicion >= TUNING.SUSP_MAX) { if (hasActiveDetector()) { state.instakillTimer += dt; ... } else { /* paused */ } } else { state.instakillTimer = 0; }`. Exactly matches brief 09 section 1 Pull 1 behavior: detector present -> timer accumulates; detector absent at MAX -> timer pauses; below MAX -> timer resets. |
| INV5 citation present | PASS -- lines 2005, 2012, 2026, 2173 cite INV5 at both predicate and gate. |
| Sim: all 3 Sirens stunned, close, LOS clear | hasActiveDetector returns **false** -- PASS |
| Sim: sentinel un-stunned, dist=150, LOS clear | hasActiveDetector returns **true** -- PASS |
| Sim: sentinel un-stunned, dist=9999 | hasActiveDetector returns **false** -- PASS |
| Sim: sentinel un-stunned, in range, LOS blocked by terrain | hasActiveDetector returns **false** -- PASS (raycast gate honored) |
| Sim: kill-gate sustain 5s w/ active detector | instakillTimer reaches 5.0 -- PASS |
| Sim: stun all for 5s during sustain | instakillTimer holds at 5.0 (PAUSED, no advance, no reset) -- PASS |
| Sim: un-stun after 5s pause, +3s | instakillTimer reaches 8.0 (RESUMED from paused) -- PASS |
| Sim: INV5 boundary 99.99 sustain 10s | instakillTimer = 0, loseReason = null -- PASS (unchanged from Step 8) |
| AU.boom() seam at vaporize | PASS -- line 2182: `if (typeof AU !== "undefined") AU.boom();` |

**Pull 1 verdict: PASS** -- predicate, gate, sustain pause/resume, and INV5 boundary all hold.

### Pull 2 -- Shadow-cone LOS rendering

| Check | Result |
|---|---|
| `function shadowPolyForRect(L, rect, far)` defined | PASS -- HTML line 2818 |
| Geometry algorithm | PASS -- finds angular-extreme corners (uses rect-center angle for +/-pi wrap handling), extends rays through them to `far`, returns 4-pt polygon. Returns `null` if origin is inside rect. |
| Sim: origin OUTSIDE rect (200,200), rect (100,100,50,50), far=1000 | returns 4-pt polygon, first two points are rect corners (100,150) and (150,100), extension distances both ~1000 -- PASS |
| Sim: origin INSIDE rect | returns `null` -- PASS |
| Render call in `drawWorldNear` | PASS -- HTML line 2885: shadow polys filled with `rgba(6, 10, 18, alpha * 0.85)` after terrain rects, inside the existing `ctx.clip()` reveal disc. Performance cap: `distancePointToRect(cx, cy, t) <= radius + diag(t)`. |
| `drawWorldNear` serves passive sonar + active ping + drone-cam | PASS -- structurally same function path; shadow cones inherited by all three reveal modes without code duplication. |
| `isLineOfSightClear` byte-equivalent to baseline | PASS -- md5 of extracted function identical: `007ea911d964dd71206d3bae824753aa` in both. Geometric LOS unchanged. |
| `applySuspicion` byte-equivalent to baseline | PASS -- md5 `86fd7239964f5dcb899567c4524a9c7b` in both. Suspicion math untouched. |

**Pull 2 verdict: PASS** -- shadow cone rendering is render-only, math-correct, and inherited free by all three reveal modes.

### Pull 3 -- Procedural Web Audio module (AU)

| Check | Result |
|---|---|
| `const AU = { ... }` defined | PASS -- HTML line 567. Methods: `init`, `resume`, `tone`, `noise`, `ping`, `emp`, `knock`, `decoy`, `drone`, `cap`, `boom`, `surface`, `beat`, `startAmb`, `stopAmb`. |
| Try/catch fail-safe around `AudioContext` creation | PASS -- line 571-576: `try { this.ctx = new (window.AudioContext || window.webkitAudioContext)(); ... } catch (e) { this.ctx = null; }`. |
| All methods gated on `this.ctx` | PASS -- every tone/noise/startAmb/stopAmb method short-circuits if `!this.ctx`. |
| Gesture-init seam | PASS -- HTML line 825-827: `AU.init(); AU.resume(); if (!AU.amb) AU.startAmb();` at the top of the keydown listener. |
| Seam: `tryActivePing` -> `AU.ping()` | PASS -- line 1279 |
| Seam: `fireEMP` -> `AU.emp()` | PASS -- line 1619 |
| Seam: `fireKnockdown` -> `AU.knock()` | PASS -- line 1638 |
| Seam: `tryDronePhoto` -> `AU.cap()` | PASS -- line 1977 |
| Seam: `trySubCamPhoto` -> `AU.cap()` | PASS -- line 1997 |
| Seam: vaporized -> `AU.boom()` | PASS -- line 2182 |
| Seam: win extract -> `AU.surface()` | PASS -- line 2357 (`if (!wasWin && typeof AU !== "undefined") AU.surface();`) -- guarded on transition into win to avoid per-frame re-fire. |
| Seam: ambient init -> `AU.startAmb()` | PASS -- line 827 (in keydown gesture-init) |
| `AU.beat()` defined but NOT called | PARTIAL -- defined (line 624: `beat(host){ this.tone(host ? 230 : 150, 0.12, "sine", 0.16); }`); zero call sites in source (`grep AU\.beat\(` returns 0). Handoff section 7 flags this explicitly as "not load-bearing for the four primary pulls" and proposes adding the HOSTILE rising-edge wire in a follow-up. |
| Sim: AU.ctx null -> all methods no-throw | PASS -- ping/emp/knock/cap/boom/surface/beat/startAmb/stopAmb all callable with `AU.ctx === null`, zero exceptions. |
| Sim: stubbed AudioContext mock | PASS -- AU.init() + 8 method calls record 9 createOscillator, 12 createGain, 2 createBuffer (EMP noise + boom noise). All wiring paths exercised. |

**Pull 3 verdict: PARTIAL PASS** -- module + 7 seams + gesture-init + fail-safe all hold. The 8th seam (`AU.beat` on HOSTILE rising edge) is intentionally deferred per handoff section 7.

### Pull 4 -- Speed-as-noise + silent running

| Check | Result |
|---|---|
| TUNING constants present | PASS -- HTML line 553-555: `NOISE_GAIN: 4.5`, `NOISE_HEAR_MAX: 360`, `SILENT_BIND_KEY: "Digit5"`. |
| `state.silentRunning` field in `newState()` | PASS -- HTML line 817. |
| `function noiseRForSub(sub)` defined | PASS -- HTML line 2042. Returns 0 when silent or no sub; else `clamp(speed * NOISE_GAIN, 0, NOISE_HEAR_MAX)`. |
| `function toggleSilentRunning()` defined | PASS -- HTML line 2050. Flips `state.silentRunning`, calls `refreshTouchArmedUI()`, returns new value. |
| `applyInertia` silent-running early return | PASS -- HTML line 2465: `if (state.silentRunning) { s.vx = 0; s.vy = 0; s.angularVel = 0; return; }`. |
| Desktop `Digit5` keybind | PASS -- HTML line 851: `if (e.code === TUNING.SILENT_BIND_KEY) toggleSilentRunning();`. Additive single conditional within existing keydown listener. No pre-Step-9 key rebound. |
| Mobile `#btnSilent` DOM element | PASS -- HTML line 164: `<button class="tbtn" id="btnSilent" type="button">SILENT</button>`. Placed between Help and Restart in the existing tray (additive, no Step 8 button replaced). |
| TOUCH_ACTIONS.btnSilent wiring | PASS -- HTML line 947: `btnSilent: () => { toggleSilentRunning(); }`. |
| HUD "SILENT" indicator | PASS -- HTML line 3226-3227: HUD line 5 includes `silent: off | SILENT` and `noiseR: <px>`. Monospace, plain text per INV6. |
| `refreshTouchArmedUI` toggles `.armed` on `#btnSilent` | PASS -- HTML line 1105-1108. |
| Sim: noiseRForSub at speed 0 / 40 / 80 / 100 | 0 / 180 / 360 / 360 -- PASS (matches `clamp(speed * 4.5, 0, 360)`). |
| Sim: noiseRForSub silent + speed 80 | 0 -- PASS. |
| Sim: toggleSilentRunning round-trip | flips correctly -- PASS. |
| Sim: applyInertia under silent | sub.vx/vy/angularVel all zeroed -- PASS. |
| Sim: TOUCH_ACTIONS.btnSilent tap toggles | PASS. |
| Noise -> Siren AI investigate write-through | DEFERRED -- `noiseR` value is computed and exposed via HUD + `__sim` but `update()` does NOT consume it to write `invX/invY/invT` on Sirens within range. Handoff section 7 paragraph 2 flags this: "Keeps INV2/INV5 perturbation zero in this re-fire pass. The mechanic functionally manifests through the existing proximity term once Sirens close on the sub." |

**Pull 4 verdict: PARTIAL PASS** -- TUNING + state + helpers + applyInertia gate + Digit5 bind + mobile button + HUD all present and verified by sim. Noise-to-investigate Siren AI write-through is deferred.

---

## Regression check (Step 1-8 systems)

Grep-count comparison between `code/sirens_song.html.bak.pre-step9-20260605` and `code/sirens_song.html`:

| Symbol | Baseline | Current | Delta | Note |
|---|---|---|---|---|
| `isLineOfSightClear` | 13 | 15 | +2 | predicate use + comment in `hasActiveDetector` |
| `applySuspicion` | 12 | 12 | 0 | untouched |
| `tryActivePing` | 5 | 5 | 0 | unchanged |
| `fireEMP` | 5 | 5 | 0 | unchanged |
| `fireKnockdown` | 5 | 5 | 0 | unchanged |
| `tryDronePhoto` | 5 | 5 | 0 | unchanged |
| `trySubCamPhoto` | 5 | 5 | 0 | unchanged |
| `HUNTER_PURSUE_SPEED` | 2 | 2 | 0 | unchanged |
| `PATROL_ALERT_SPEED_MULT` | 2 | 2 | 0 | unchanged |
| `SENTINEL_DETECT_RADIUS_PX` | 3 | 5 | +2 | new use in `hasActiveDetector` + comment |
| `joystick` | 78 | 78 | 0 | Step 8 mobile path untouched |
| `touchstart` | 8 | 8 | 0 | Step 8 touch wiring untouched |
| `pointerdown` | 0 | 0 | 0 | unchanged |
| `btnPing` / `btnEMP` / `btnKD` / `btnRecon` / `btnDecoy` / `btnJam` | 3/3/3/3/2/2 | 3/3/3/3/2/2 | 0 each | Step 8 tray untouched |
| `__sim` | 6 | 6 | 0 | object reference count |
| `isSirenStunned` | 11 | 12 | +1 | new use in `hasActiveDetector` |
| `distancePointToRect` | 4 | 5 | +1 | new use in shadow-perf cap |
| `losClearIgnoring` | 3 | 3 | 0 | factory occlusion untouched |
| `drawWorldNear` | 8 | 8 | 0 | function name count (def + 7 call sites) -- unchanged |
| `update` | 44 | 44 | 0 | reference count steady |
| `newState` | 5 | 5 | 0 | unchanged |
| `applyInertia` | 6 | 7 | +1 | silent-running gate added |

Byte-equivalence spot checks:

| Function | Baseline md5 | Current md5 | Status |
|---|---|---|---|
| `isLineOfSightClear` body | `007ea911d964dd71206d3bae824753aa` | `007ea911d964dd71206d3bae824753aa` | identical |
| `applySuspicion` body | `86fd7239964f5dcb899567c4524a9c7b` | `86fd7239964f5dcb899567c4524a9c7b` | identical |

Regression: **CLEAN.** All deltas are explainable additive surface, no negative or unexpected changes. Suspicion math + raycast geometry byte-identical.

---

## `__sim` superset verification

| Metric | Step 8 | Step 9 RE-FIRE | Delta |
|---|---|---|---|
| Total entries | 73 | 80 | +7 |

Step 9 additions (all callable):

| Symbol | Type | Source |
|---|---|---|
| `hasActiveDetector` | function | Pull 1 |
| `shadowPolyForRect` | function | Pull 2 |
| `AU` | object | Pull 3 |
| `noiseRForSub` | function | Pull 4 |
| `toggleSilentRunning` | function | Pull 4 |
| `toggleSilent` | function (alias) | Pull 4 (brief alias) |
| `getSilentRunning` | function | Pull 4 |

Strict superset confirmed: all 73 pre-Step-9 entries verified present (verified by visual diff of the `window.__sim = { ... }` block); 7 new entries appended at the end with a clearly-commented Step 9 banner ("Step 9 v0.3 pull-in 2026-06-05 additions. All additive."). The brief expected 7 (handoff also says 7); this matches.

Note: the prior audit's brief section anticipated 8 (counting `getNoiseR` as a separate accessor). The handoff resolves this by not exposing `getNoiseR` as a distinct method -- `noiseRForSub` plays both roles (computation + exposure). HUD calls `noiseRForSub(s.sub)` directly. This is a defensible simplification, not a regression.

---

## Six invariants check

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | **PASS** | hasActiveDetector reads but never mutates Siren state. shadowPolyForRect is render-only. AU is sound only. silent-running freezes the SUB, not any Siren. No new keys on patroller/sentinel/hunter that resemble `hp`/`health`/`damage`. |
| 2. Suspicion is the spine | **PASS** | Thresholds 34/75/100 byte-identical in TUNING. `applySuspicion` body byte-equivalent. No new suspicion gain term added. Noise is computed but does NOT feed `applySuspicion` (deferred). Vaporize remains driven by suspicion >= MAX, now correctly gated on perception (a more honest read of "suspicion is the spine" than the pre-Step-9 timer-only logic). |
| 3. Perceiving costs | **PASS** | No new free reveal mode. Shadow cones narrow what existing reveals show but don't add a new reveal. Recon reveal path (line 1900ish) untouched. AU does not reveal anything -- it's an output. |
| 4. Tools buy time and cost heat | **EXTENDED (PASS)** | Silent running buys time (sub freezes, Sirens may pass; noise=0) at the cost of zero forward progress (oxygen still drains -- verified `state.oxygen -= dt` block at line 2166 unchanged). This is a sound INV4 extension. |
| 5. Fairness valve | **STRENGTHENED (PASS)** | Sim battery confirms: at suspicion=100 with all Sirens EMP-stunned, vaporize does NOT fire and timer PAUSES (not resets). On re-acquisition (un-stun + in-range + LOS), timer RESUMES. INV5 99.99 boundary unchanged. The kill rule is no longer time-only -- it's perception-AND-time, which strengthens the fairness contract. INV5 also doesn't accidentally block legitimate kill: with one un-stunned LOS detector, 5s sustain still vaporizes. |
| 6. Function before form | **EXTENDED PER v0.3 (PASS)** | Audio promoted from form-pass to core pillar per v0.3 spec section 6 (Pat ratified). Shadow cones are legibility geometry (Klei/Mark-of-the-Ninja precedent; v0.3 section 3 says "lit bubble with visible blind cones" -- this is spec'd geometry, not chrome). Files searched: no `<audio>`, no `<video>`, no `<img>`, no `@font-face`, no `@keyframes`, no `animation:` rules, no `transition:` rules. HUD remains plain monospace; SILENT indicator is text. |

No invariant violations.

---

## Edge case verification

1. **Literal-stationary HOSTILE sub edge case.** Pre-Step-9, a stationary sub holding HOSTILE indefinitely could either (a) hull-sink at 8.4 s via oxygen if loss conditions cascade, or (b) vaporize at 4.0 s. Step 9 gates vaporize on `hasActiveDetector()`. **Verified**: if any un-stunned Siren is within its detection radius with LOS clear, vaporize still fires at 4.0 s exactly as INV5 intends. If no detector is present (e.g., all 3 stunned), the timer pauses indefinitely while suspicion holds at 100 -- the sub will lose to oxygen at 210 s instead. This is the intended INV5 strengthening per v0.3 section 6.

2. **EMP all visible Sirens at suspicion ~100.** **Verified by sim**: with all three Sirens in `state.empStunUntil` and timer running, the sustain counter freezes (does not advance, does not reset). Un-stunning the patroller makes the timer resume. The pause / resume cycle is correct.

3. **Audio fail-safe (Web Audio mocked off).** **Verified by sim**: with `global.AudioContext = undefined`, AU.ctx stays null after init, every AU method short-circuits cleanly, the game does not throw on keydown gesture-init. The `try/catch` at line 571-576 + the `if (!this.ctx) return;` guard in every output method form a clean dual-defense.

4. **Silent running near a Hunter.** Pull 4 zeroes `noiseR` and freezes the sub, but does NOT modify Hunter's pre-existing detection. The Hunter's passive proximity term, suspicion-driven activation, and pursue-on-Alert+ behavior all still work. If the Hunter is already in pursuit, silent running does not break its pursue -- the Hunter heads to the last known contact regardless of present noise. The expectation matches the spec (silent = stealth from new contact; not invincibility from active pursuit).

5. **Step 8 byte-equivalence on no-touch path.** Desktop keydown listener: single new conditional added at the end (`if (e.code === TUNING.SILENT_BIND_KEY) toggleSilentRunning();`) plus the gesture-init triple (`AU.init(); AU.resume(); if (!AU.amb) AU.startAmb();`) at the top. No pre-Step-9 key rebound. No existing branch removed. The Step 8 hard rule held: a desktop player who never touches a touch surface sees only an additional `Digit5` binding and (silent) audio init -- no game logic change.

---

## Partial-implementation flags

The handoff (section 7) flags two deferrals; this audit confirms both and assesses impact.

### Flag A: `AU.beat()` HOSTILE-entry seam not wired

- **Status:** defined; zero call sites.
- **Brief 09 expectation:** "Suspicion transition into HOSTILE -> `AU.beat()` (heartbeat thump on entry)."
- **Handoff justification:** "Left as a future seam to avoid double-firing during this re-fire."
- **Audit read:** This is a missed seam, not a regression. The pre-Step-9 chain had no audio; the post-Step-9 chain has 7 of 8 seams wired. The HOSTILE-entry beat is one rising-edge call site away from being wired -- a clean follow-up. Acceptable for Step 9 close if Pat signs off; otherwise a one-line Step 9b adds it.

### Flag B: Noise -> Siren investigate write-through deferred

- **Status:** `noiseRForSub` computed and exposed; the in-update loop that would stamp `invX/invY/invT` on Sirens within `noiseR` is absent.
- **Brief 09 expectation:** "Any Siren within `noiseR` (no LOS gate -- noise is omnidirectional) gets a soft investigate event: if the Siren is not already pursuing a higher-priority target (decoy / ping), set `invX/invY/invT` toward the sub at a short attention window (~2.5 s)."
- **Handoff justification:** "Keeps INV2/INV5 perturbation zero in this re-fire pass. The mechanic functionally manifests through the existing proximity term once Sirens close on the sub."
- **Audit read:** This is a more substantive deferral than Flag A. The brief specifically authored the soft-investigate write-through as the noise mechanic; without it, "noise" is a value displayed on the HUD that has no consequence on AI. The handoff's claim that "the existing proximity term" provides the function is partially true -- a sub at terminal speed near a Siren WILL still be detected by proximity, but the noise-feeds-investigate dynamic from the brief is not present. The silent toggle still pays off (sub freezes; existing proximity term sees nothing if the sub doesn't move), so the silent half of Pull 4 lands fully. The noise-as-investigate-attractor half does not.
- **Recommended:** Pat ratifies the deferral as Step 9 close OR queues a Step 9b for the in-update noise-investigate loop (one new block in `update()`, gated by a guard against decoy/ping priority).

---

## Verdict

**YELLOW** -- the patch lands cleanly, integrity gates pass, file is browser-loadable, all four pulls are present at the structural level. Two partial implementations are honestly documented by the handoff and confirmed by this audit:

1. `AU.beat()` defined but not wired to HOSTILE rising-edge. Minor -- one line away from full coverage.
2. Noise -> Siren investigate write-through deferred. Substantive -- the noise half of Pull 4 has no AI consequence beyond the existing proximity term.

The patch is **safe to playtest** (no regressions; INV5 strengthened; all Step 8 systems intact). The two deferrals do not break anything; they leave seams under-utilized.

### Recommended Pat-next-step

**Option 1 (RECOMMEND):** Pat playtests the current Step 9 RE-FIRE build. Three of four pulls land fully (EMP / kill-rule, shadow cones, silent freeze); the audio module is 7/8 seams wired (every event-driven seam except HOSTILE-entry heartbeat); the noise math is computed and exposed on the HUD so Pat can SEE the throttle->noise relationship without it yet driving AI. If playtest feels right, ratify Step 9 closed; queue Step 9b in a future session to wire `AU.beat()` on HOSTILE rising-edge AND the noise-investigate write-through in `update()`.

**Option 2:** Immediately fire Step 9b before any playtest, scoped to two surgical adds:
- One conditional in `update()` to detect HOSTILE rising-edge and call `AU.beat(true)`.
- One loop in `update()` to iterate Sirens, compare distance to `noiseRForSub(state.sub)`, and stamp `invX/invY/invT` on those within range when their priority is lower than noise.

**Option 1 is recommended** because (a) the handoff was honest about the deferrals, (b) the deferrals are low-risk (existing mechanics intact), (c) Pat ratifying based on a real playtest is the spec-compliant path -- abstract follow-up sometimes solves the wrong problem.

### If RED -- N/A
### If GREENLIGHT -- not awarded due to Flag B substance

---

## Notes for the orchestrator

- The first-fire truncation (audit 09) was a delivery-tool failure (`Edit` against a stale Read buffer; FUSE mount caching anomaly per handoff section 7 paragraph 3). The re-fire used an atomic single-pass Python script (`_step9_refire_patch.py`) applying all 21 string substitutions in one write. This pattern should be canonized for future large-file edits.
- The `_step9_refire_patch.py` script is at repo root. The orchestrator should decide whether to keep it (for re-runs) or move it to `_scrap-YYYYMMDD/`.
- A second checkpoint backup `code/sirens_song.html.bak.pre-step9-refire-20260605` was created before the re-fire write. Both backups verify to their stated md5.
- `SIRENS_SONG_SPEC_STEP9_PATCH.md` sidecar exists at repo root (5,061 bytes from prior session; reused unchanged). Awaits Pat merge into `SIRENS_SONG_SPEC.md`.

---

## Receipt

- Audit complete: YES
- Verdict: **YELLOW** -- patch lands; two documented deferrals (AU.beat unwired, noise-investigate write-through deferred).
- Orchestrator action: **OFFER PAT THE CHOICE** -- playtest current build (Option 1, recommended) OR fire Step 9b first (Option 2). Either path is defensible; the build is not broken.
- Blocking flag for Pat: the noise-as-AI-attractor half of Pull 4 is deferred. The silent half lands fully. Pat decides whether this Step 9 closes here or wants a Step 9b before playtest.

---

*AI-DESIGNED. Auditor: sharp-magical-dirac (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context). Authority: `SIRENS_SONG_SPEC.md` > `agent.md` > `briefs/AUDITOR_BRIEF.md` (Step 9 section) > `briefs/09_v03_pullin_patch.md` > re-fire handoff > current code. Audit verifies, does not modify code. This audit ratifies the re-fire as YELLOW with playtest recommendation; the orchestrator routes.*
