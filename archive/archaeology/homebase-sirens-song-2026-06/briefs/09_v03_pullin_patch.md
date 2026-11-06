# Brief — Step 09 v0.3 pull-in patch

**Step:** 09 (post-Step-8 extension, claude.ai-track v0.3 ratification pull-in)
**Built atop:** Step 08 GREENLIGHT (`audits/08_AUDIT_STEP_08.md`); inherits Steps 1+1-fixpass+2+3+4+5+6+7+8.
**Authority chain:** `SIRENS_SONG_SPEC.md` (Cowork canonical, v0.2) + v0.3 spec in `Inbox_from_Claude.ai/Siren's Song claude web/SIRENS_SONG_functional_spec.md` (claude.ai-track) > `agent.md` > this file > prior handoffs/audits > current code.

Pat ratified four targeted pull-ins from the claude.ai parallel build (v0.3 decision log, 2026-06-03) into the Cowork chain. Items #1-#4 from `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` §10. This step is **execute the ratified pulls** — not a re-design, not a spec swap, not a rebuild.

---

## 1. Scope (four pulls, in this order)

### Pull 1 — EMP / kill-rule fix (v0.3 §6)

The vaporize trigger at sustained `suspicion == SUSP_MAX` must be gated on at least one **active LOS detector** currently observing the sub. "Active detector" = un-stunned Siren within its per-type detection range with `isLineOfSightClear(sub, siren) == true`.

**Predicate:** `hasActiveDetector()` — returns true iff at least one of {Patroller, Sentinel, Hunter} satisfies (a) `!isSirenStunned(s)`, (b) `dist(s, sub) <= s.detectRadius`, (c) `isLineOfSightClear(s.x, s.y, sub.x, sub.y)`. Per-type detection radii drawn from existing TUNING constants — Patroller `PATROL_RADIUS_PX + 180` (the existing proximity-range arithmetic, ~194 px), Sentinel `SENTINEL_DETECT_RADIUS_PX` (220), Hunter `HUNTER_PROXIMITY_RANGE_PX` (200 — closest existing range constant for Hunter).

**Behavior:**
- At suspicion 100 with `hasActiveDetector() == true`: instakill timer accumulates exactly as before. Vaporize at sustain >= `INSTAKILL_SUSTAIN_SEC` (4.0 s).
- At suspicion 100 with `hasActiveDetector() == false`: instakill timer **pauses** at its current value (does NOT decay to zero; does NOT advance). Suspicion stays at 100 (its own decay logic is unaffected by this gate).
- When an un-stunned detector re-acquires LOS, sustain counter resumes from where it paused.
- Below 100: timer resets to 0 (unchanged from Step 2).

**INV5 citation** at both the predicate and the gate.

### Pull 2 — Shadow-cone LOS rendering

Visible dark wedges behind every terrain rect inside the active ping disc, and inside the passive sonar reveal disc. Render-only change; the geometric LOS test (`isLineOfSightClear`) is unchanged.

**Approach:** adapt claude.ai's `shadowPoly()` (lines 207-220 of `Inbox_from_Claude.ai/Siren's Song claude web/sirens_song_prototype_v7.html`). Their geometry assumes circular obstacles; ours are axis-aligned rectangles. The adapted predicate `shadowPolyForRect(L, rect, far)` finds the rect's two "silhouette" corners (the two corners with extreme polar angle from origin L), extends rays from L through those corners out to distance `far`, and returns the four-point polygon `[c1, c2, c2+ray, c1+ray]` filled in the abyss color.

**Render:** inside `drawWorldNear(cx, cy, radius, alpha)`, after terrain rects are drawn, clip to the reveal disc and fill shadow polygons for every rect whose distance from `(cx, cy)` is less than `radius + rect_diagonal` (performance cap). Both passive sonar (small radius, alpha 0.35) and active ping (large radius, scaled alpha) inherit shadows for free because both call `drawWorldNear`.

**No changes** to ping LOS gating, raycast logic, suspicion math, factory occlusion, or recon reveal (recon is "from above" by spec — recon stays not-LOS-gated and not-shadow-cast).

INV1/INV4 not touched. INV6 deferred: shadow rendering is a **legibility affordance**, not aesthetic polish (Klei/Mark-of-the-Ninja precedent; the spec v0.3 §3 says "lit bubble with visible blind cones" — shadows are spec'd geometry, not chrome).

### Pull 3 — Procedural Web Audio module (AU)

Port the `AU` const verbatim from v7 prototype lines 102-119 into our HTML's script section, immediately below the TUNING block. Wire at the existing event seams:

| Seam | Call |
|---|---|
| `tryActivePing` | `AU.ping()` |
| `fireEMP` | `AU.emp()` |
| `fireKnockdown` | `AU.knock()` |
| `tryDronePhoto` + `trySubCamPhoto` | `AU.cap()` |
| `loseReason = "vaporized"` set | `AU.boom()` |
| Win condition (extracted) | `AU.surface()` |
| Suspicion transition into HOSTILE | `AU.beat()` (heartbeat thump on entry) |
| Game start (first input / start) | `AU.startAmb()` |

Gesture-initialized: `AudioContext` created on first user gesture (pointerdown / keydown). Fail-safe try/catch around context creation — if Web Audio is unavailable, game continues normally with `AU.ctx === null` and all AU methods become no-ops.

INV6 deferral: v0.3 promoted audio from form-pass to core pillar; v0.3 wrapper §6 says "Audio and noise are core systems, not polish." Pat ratified this in v0.3 decision log. Our chain inherits the ratification via this brief.

### Pull 4 — Speed-as-noise + silent running toggle

Throttle generates a noise signature; silent toggle zeroes both speed and noise.

**New TUNING:**
- `NOISE_GAIN` — multiplier from sub speed to noise emission radius (default 4.5, picked so terminal-speed sub at 80 px/s gives a ~360 px noise radius matching v7's `noiseHearMax:360`).
- `NOISE_HEAR_MAX` — hard cap on noise radius (360 px).
- `SILENT_BIND_KEY` — keyboard binding (`"Digit5"`).

**Mechanic:** each frame, compute `noiseR = clamp(sub.speed × NOISE_GAIN, 0, NOISE_HEAR_MAX)`. Any Siren within `noiseR` (no LOS gate — noise is omnidirectional) gets a soft investigate event: if the Siren is not already pursuing a higher-priority target (decoy / ping), set `invX/invY/invT` toward the sub at a short attention window (~2.5 s). Investigate event does **not** raise suspicion directly — noise feeds detection through the existing proximity term once the Siren closes.

**Silent toggle:** bound to `Digit5` (desktop) AND to a new `#btnSilent` button in the Step 8 mobile tray (ADDITIVE — added at the end of the tray, no existing button replaced or rebound). When `state.silentRunning == true`:
- `sub.speed` clamped to 0 in `applyInertia`; sub freezes in place (skip drag math too).
- `noiseR = 0`.
- Oxygen drain continues.

**HUD:** small "SILENT" indicator (top-right, monospace text — INV6 placeholder).

**Hard constraint:** desktop input path stays byte-equivalent on `userAgent` mismatch — the new key handler is additive to the existing keydown listener (one new `if (e.code === TUNING.SILENT_BIND_KEY)` line); the mobile button is a new DOM element added at the end of the tray, no existing button id is reused or replaced.

---

## 2. Hard constraints

1. **Desktop input path byte-equivalent.** Step 8 audit established this. Same rule here: any new mobile button is ADDITIVE; any new key handler is additive within the existing keydown listener; no existing binding is rebound.
2. **No suspicion threshold change.** 34 / 75 / 100 hold.
3. **No oxygen change.** 210 s holds (Step 7 tuning).
4. **No decay change.** -5/s clean, paused during ping. Step 2 behavior holds.
5. **No HUNT meter, no graze damage, no 4th Siren, no narrative logs, no portrait scroll, no map shape change, no thermal, no currents.** Out of scope. Pat is holding these pending v7 playtest.
6. **Six invariants preserved.** Quoted at the top of every new section. Cited at every new seam.
7. **No deletions.** Surgical additions only.
8. **Backup mandatory.** `code/sirens_song.html.bak.pre-step9-20260605` before any edit.
9. **Sim harness extension.** `__sim` gets `hasActiveDetector`, `shadowPolyForRect`, `silentRunning` accessors, `noiseRForSub` so the auditor can verify each pull deterministically.
10. **Spec append-only.** Add a "Step 9 patch" section to the bottom of `SIRENS_SONG_SPEC.md`; do not modify existing content.

---

## 3. Audit gates

The auditor verifies, in addition to the six invariants and code hygiene:

| Gate | Pass condition |
|---|---|
| Pull 1 — active detector gate | Sim: sub at sustained 100 with EMP-stunned Patroller (only nearby siren) → no vaporize. Same setup, un-stunned Patroller in LOS → vaporize at sustain >= 4.0 s. Stun Patroller after 2 s of sustain → timer pauses; un-stun → timer resumes and fires at the original sustain target. |
| Pull 2 — shadow cones rendered | Visual: in headless DOM stub, instrument `ctx.fill` calls during a ping reveal frame; assert >= 1 fill call inside the ping disc clip with the abyss color, for each terrain rect inside `pingReachedRadius + diag`. |
| Pull 3 — audio module | `__sim.AU` exposes `ping/emp/knock/cap/boom/surface/beat/startAmb` as callable functions; calling them with no AudioContext (stubbed) does not throw; calling them with a stubbed context produces calls into the stubbed `createOscillator` / `createGain` / `createBuffer` paths. |
| Pull 4 — noise + silent | `__sim.noiseRForSub(state.sub)` returns a number in [0, NOISE_HEAR_MAX]; sub at 0 speed → 0; sub at terminal speed → NOISE_HEAR_MAX (or close). Silent toggle: `__sim.toggleSilent()` flips `state.silentRunning`; an update tick under silent leaves `sub.x/y` unchanged regardless of input keys; `noiseR == 0` while silent. Mobile-tray `#btnSilent` button exists and toggles. Desktop keydown `Digit5` toggles. |
| INV5 — fairness valve still holds | Sim: chain disrupt-tools + sustain max. With at least one un-stunned LOS detector, vaporize fires at 4.0 s (unchanged). With all detectors stunned, vaporize is suspended; warning UI still shows. |
| INV1-INV4 — sims pass at parity with Step 8 | Re-run Step 8's 53-sim battery; expect 53 PASS / 0 FAIL. Plus the four new gate sims for the four pulls. |

---

## 4. Spec ambiguity flagged for resolution

The v0.3 spec §6 says vaporize requires "at least one un-stunned Siren currently has detection (proximity + line-of-sight) on the sub." Our chain has no single `DETECT_RADIUS` per Siren type — we have per-type proximity ranges (`PATROL_RADIUS_PX + 180`, `SENTINEL_DETECT_RADIUS_PX`, `HUNTER_PROXIMITY_RANGE_PX`). Resolution adopted in this brief: each Siren type's existing range constant **is** its detection radius for the kill-gate. The brief locks this so the auditor knows the mapping.

The v0.3 spec mentions "silent-running breath-hold bed" as a distinct audio cue (§10). Not implemented in this pull — only `AU.startAmb()` is wired. A silent-mode-specific audio cue is form-pass / next-step.

---

*AI-DESIGNED. Step 9 brief authored 2026-06-05. Authority order at top. Pat ratifies via accept/reject of the deliverables.*
