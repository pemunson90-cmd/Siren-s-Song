# Audit — Step 08 mobile_controls

**Auditor session:** dreamy-awesome-fermat (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context)
**Audited step handoff:** `handoffs/08_HANDOFF_FROM_STEP8.md`
**Audited code state:** `code/sirens_song.html` 135,266 bytes / 3,196 lines (Step 8 delta: +22,816 bytes / +548 lines vs Step 7)
**Pre-Step-8 backup:** `code/sirens_song.html.bak_pre_step8` (112,450 bytes; md5 `be02fa806581e0608938c27cb9978223` — verified byte-identical to pre-edit Step-7 file)
**Authority chain:** `SIRENS_SONG_SPEC.md` > `agent.md` > `briefs/08_mobile_controls.md` > `handoffs/08_HANDOFF_FROM_STEP8.md` > current code

**Pat's hard constraint (received between build and audit):** *"it should be playable with touch or keyboard and mouse because I don't want you undoing all the work that actually works already just to make it mobile playable."* This audit specifically proves the desktop path was not silently refactored.

---

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | **PASS** | INV1 sim: 200 chained `fireEMP`+`fireKnockdown` at Patroller → all 3 Sirens present; scan of `hp/health/damage/life/kill/killed/dead` keys returns none. Plus 600-fire adversarial (`fireEMP`+`fireKnockdown`+`fireJam` × 200) — Siren count still 3. |
| 2. Suspicion is the spine | **PASS** | INV2 sim: `suspicionState(0)`=CURIOUS, `suspicionState(33)`=CURIOUS, `suspicionState(34)`=ALERT, `suspicionState(74)`=ALERT, `suspicionState(75)`=HOSTILE — boundary set unchanged from Step 7. Touch taps for PING/EMP/KD/Jam/Recon all funnel through the same `applySuspicion` chokepoint as desktop (verified by delta-comparison sim). |
| 3. Perceiving costs | **PASS** | INV3 sim: `tryActivePing` +25; `fireRecon` +8; `tryDronePhoto` cost path = +15 (DRONE_PHOTO_COST verified); sub-cam carries proximity cost only. No new perception modes added in Step 8. |
| 4. Tools buy time and cost heat | **PASS** | INV4 sim: `fireJam` +5, `fireEMP` +20, `fireKnockdown` +20. Starting charges: jam=3, EMP=3, KD=2, recon=2, drones=5. All finite. Touch button taps consume the same charges as desktop (sim: `simulateTouchEvent('buttonTap', {id:'btnEMP'})` then `canvasTap` → `empCharges` −1, +20 susp; matches `fireEMP(x,y)` direct call). |
| 5. Fairness valve | **PASS** | INV5 sim: 250 frames @ 60Hz holding suspicion=100 → `loseReason='vaporized'` fires at the 4s+ mark. 180 frames @ 100 then drop to 40 + 100 frames passive → no vaporize. Adversarial: 600 frames (10s) at 99.99 → no vaporize (proves the trigger is `>= SUSP_MAX` only). `INSTAKILL_SUSTAIN_SEC === 4.0`. |
| 6. Function before form | **PASS** | No `<audio>`, `<video>`, `<img>`, `@font-face`, `@keyframes`, `animation:`, or `transition:` in the file (pre or post — same count: 0). Touch overlay: plain `<button class="tbtn">` labeled rectangles; joystick is a CSS circle with a 1px border and inner circle thumb (no styling beyond grayscale `#888`/`#ccc`/`rgba(40,40,40,0.45)`). Portrait warning is a single text line. `font-family: monospace` only (one new occurrence inherits the existing global). |

---

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within Step 8 scope (UI layer only) | **PASS** | Diff scrutiny (see Lens A) shows three deletions, all benign: title text, CSS comment terminator, and the canvas tag which is replaced by an identical canvas tag wrapped in `<div id="canvasFrame">`. All other changes are additions: viewport meta, CSS for canvas-fit / touch overlay / portrait warning, touch-detection const, joystick state + handlers, button-tap handlers, canvas `touchstart` handler, and 11 new `__sim` entries. |
| No game logic / tuning / AI change | **PASS** | MD5 of post-Step-8 JS body with both Step-8 blocks stripped equals MD5 of pre-Step-8 JS body: `d64857726e8bb74b0f3f5c5bd6770621`. Byte-identical. |
| Single file maintained | **PASS** | `ls code/` shows `sirens_song.html` plus `*.bak*` backups; no new code files. |
| No new tuning constants affecting game | **PASS** | The four Step-8 constants (`deadzone=0.22`, `axisThresh=0.35`, joystick CSS size 22vmin, button tray CSS size 22vmin) are UI placeholders only; none feed game state. All 90 Step-7 tuning constants verified verbatim (spot-check: OXYGEN=210, HUNTER_PURSUE=75, RECON_RADIUS=460, PING_COST=25, EMP_COST=20, KD_COST=20, JAM_COST=5, RECON_COST=8, DRONE_PHOTO_COST=15, DECAY=5, INSTAKILL=4.0, THRESH_ALERT=34, THRESH_HOSTILE=75, SUSP_MAX=100, HULL=3, drones=5, jam=3, EMP=3, KD=2, recon=2). |

---

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | **PASS** | Extracted JS via Python regex, `node --check /tmp/game.js` → CLEAN. |
| Single file at `code/sirens_song.html` | **PASS** | One file; backup at `code/sirens_song.html.bak_pre_step8`. |
| No fabricated tuning numbers | **PASS** | Step 8 added zero game-affecting constants; UI-only constants documented in handoff §"Tuning values used" with explicit "UI placeholder" labelling. |
| No scope creep | **PASS** | Diff shows only viewport / responsive-CSS / touch-overlay / coord-transform / `__sim` additions. |
| Invariant comments present where critical | **PASS** | Step 8 block opens with explicit invariant-preservation contract (lines 605-624 of script: "It does NOT modify game logic, tuning, AI, suspicion math, win/lose conditions"). INV6 cited at CSS rule level. |

---

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per `agent.md` §5.2 | **PASS** | Handoff contains: What I built, State of the file, Tuning values used, Sim tests run, `__sim` surface delta, Open potholes for Pat, Design improvement notes, Invariant adherence self-check, Receipt. |
| Tuning values documented | **PASS** | Explicit table showing zero new game tuning constants, plus the four UI-placeholder constants with rationale. Step 7's 90-constant table referenced verbatim. |
| Sim tests logged | **PASS** | 53 sim tests in five tables (touch detection, joystick→keys, button taps, coord transform, INV regression, desktop path, cross-step regression, orientation). |
| Receipt present | **PASS** | `Step 08: COMPLETE -- READY FOR PAT MOBILE PLAYTEST. ORCHESTRATOR: HALT after audit.` |
| Backup md5 matches | **PASS** | Verified `md5sum code/sirens_song.html.bak_pre_step8` = `be02fa806581e0608938c27cb9978223` (matches handoff claim and is byte-identical to Step-7-closed state). |

---

## Lens A — Diff scrutiny (Pat's hard constraint)

**Method:** `diff code/sirens_song.html.bak_pre_step8 code/sirens_song.html` (564 lines). Every change classified.

### All deletions (3 total — only benign)

```
< <title>Siren's Song -- Step 4 build (Sentinel + Hunter + curiosity/decoy) + Step 3 + Step 1 fix-pass</title>
<      No palette / typography / chrome decisions. Form pass is later. */
<   <canvas id="game" width="960" height="640"></canvas>
```

1. Title line — text suffix added; CSS title is cosmetic, no behavior.
2. CSS comment `*/` — replaced by an extended comment whose `*/` lands later.
3. Canvas element — replaced by **byte-identical canvas tag** wrapped inside `<div id="canvasFrame">`. The canvas attributes `width="960" height="640"` are unchanged.

### Critical handler bytes — line-for-line proof

Each handler's body is **byte-identical** between pre and post (extracted via `sed`, compared via `diff` with exit code 0):

- `window.addEventListener("keydown", ...)` — PRE line 568 / POST line 717 — identical (29 lines).
- `window.addEventListener("keyup", (e) => keys.delete(e.code));` — PRE line 596 / POST line 745 — identical one-liner.
- `canvas.addEventListener("contextmenu", (e) => e.preventDefault());` — PRE line 599 / POST line 748 — identical one-liner.
- `canvas.addEventListener("mousedown", (e) => {...})` — PRE line 600 / POST line 749 — identical (26 lines), including the `e.button === 0` armed-tool dispatch and `e.button === 2` right-click `redirectNearestDrone` path.

### Gameplay-function byte equivalence

Functions inspected (PRE line → POST line, exactly +462 line offset):

| Function | PRE | POST | Δ | Verified |
|---|---|---|---|---|
| `applySuspicion` | 628 | 1090 | +462 | identical |
| `suspicionState` | 658 | 1120 | +462 | identical |
| `tryActivePing` | 688 | 1150 | +462 | identical |
| `deployDrone` | 700 | 1162 | +462 | identical |
| `redirectNearestDrone` | 728 | 1190 | +462 | identical |
| `cycleSelectedDrone` | 743 | 1205 | +462 | identical |
| `toggleDecoyOnSelected` | 768 | 1230 | +462 | identical |
| `fireJam` | 999 | 1461 | +462 | identical |
| `fireEMP` | 1018 | 1480 | +462 | identical |
| `fireKnockdown` | 1039 | 1501 | +462 | identical |
| `fireRecon` | 1081 | 1543 | +462 | identical |
| `tryDronePhoto` | 1362 | 1824 | +462 | identical |
| `trySubCamPhoto` | 1397 | 1859 | +462 | identical |

**Whole-script proof:** With the two additive Step-8 blocks stripped from the post file, the resulting JS body has MD5 `d64857726e8bb74b0f3f5c5bd6770621` — identical to the pre-Step-8 script's MD5. Zero silent refactors.

### Hard-fail check: Touch listeners NOT bound on desktop

**Finding:** The `wireTouchHandlers()` IIFE (POST line 1016) does **not** gate the `addEventListener` calls on `IS_TOUCH_DEVICE`. The build-agent's comment explicitly justifies this: *"Done unconditionally so `__sim` can drive them in headless tests; on a desktop with no touch device, no touchstart/touchmove/touchend events fire so the listeners are dormant."*

Analysis:
- The four touch events (`touchstart`/`touchmove`/`touchend`/`touchcancel`) are inert on a real desktop browser without touch hardware — they simply never fire. Binding them unconditionally on desktop is **functionally a no-op**.
- The `click` listener IS bound on each action button (line 1075 of POST). However, the buttons live inside `#touchOverlay`, which has `display: none` (CSS line 53) on any document where `<body>` does not carry the `.touch-mode` class. On desktop, that class is never added (line 1020 guards with `if (IS_TOUCH_DEVICE && document.body)`). A `display:none` element is non-interactive — no user click can reach it.
- Net result: desktop input path is unaffected. **PASS, but flagged as a deferred-cleanup item — see Open potholes for Pat.**

### Hard-fail check: Touch overlay display:none on desktop

**PASS.** CSS line 53: `#touchOverlay { display: none; }` is the default. Line 54: `.touch-mode #touchOverlay { display: block; ... }` overrides only when body has `.touch-mode`. Body class is set at line 1020-1022 only when `IS_TOUCH_DEVICE` is true. Portrait warning overlay (line 125-138) is similarly default-`none`.

### Hard-fail check: Right-click drone redirect preserved

**PASS.** The `canvas.addEventListener("mousedown", ...)` handler in POST (line 749) is byte-identical to PRE (line 600), including the `e.button === 2 → redirectNearestDrone(x, y)` branch (POST line 771-773). The `contextmenu` preventDefault is also byte-identical.

---

## Lens B — Touch event mapping (sim table)

All sims used DOM stubs that simulate touch capability (`navigator.maxTouchPoints=1`, `ontouchstart` in window). Body `.touch-mode` set via `__sim.setTouchModeForTesting(true)`. `__sim.simulateTouchEvent(type, payload)` drives the touch dispatch.

| Touch action | Desktop equivalent | Touch result | Desktop result | Delta match |
|---|---|---|---|---|
| Joystick UP-RIGHT (π/4, mag=1.0) | `keydown('KeyW')` + `keydown('KeyD')` | keys = [KeyW, KeyD] | [KeyW, KeyD] | PASS |
| Joystick UP (π/2, 1.0) | `keydown('KeyW')` | [KeyW] | [KeyW] | PASS |
| Joystick LEFT (π, 1.0) | `keydown('KeyA')` | [KeyA] | [KeyA] | PASS |
| Joystick DOWN (−π/2, 1.0) | `keydown('KeyS')` | [KeyS] | [KeyS] | PASS |
| Joystick DOWN-LEFT (−3π/4, 1.0) | `keydown('KeyS')` + `keydown('KeyA')` | [KeyS, KeyA] | [KeyS, KeyA] | PASS |
| Joystick null (0, 0) | (all keys released) | [] | [] | PASS |
| Joystick magnitude 0.1 (below deadzone 0.22) | (no keys) | [] | [] | PASS |
| Joystick release clears synth keys | `keyup('KeyW')` | keys Set has no KeyW | (same) | PASS |
| `buttonTap btnPing` | `keydown('Space')` → `tryActivePing()` | susp +25 | +25 | PASS |
| `buttonTap btnEMP` + `canvasTap(siren)` | `keydown('2')` + `mousedown(siren)` | EMP −1 charge, +20 susp, armedTool=null | (identical) | PASS |
| `buttonTap btnKD` + `canvasTap(siren)` | `keydown('3')` + `mousedown(siren)` | KD −1, +20 susp | (identical) | PASS |
| `buttonTap btnRecon` + `canvasTap(coord)` | `keydown('4')` + `mousedown(coord)` | recon −1, +8 susp | (identical) | PASS |
| `buttonTap btnJam` | `keydown('1')` | jam −1, +5 susp immediate | (identical) | PASS |
| `buttonTap btnDeploy` + `canvasTap(coord)` | `mousedown(coord)` (no armed tool) | droneSupply −1 | (identical) | PASS |
| `buttonTap btnRedirect` + `canvasTap(coord)` | `mousedown right-button (e.button===2)` | drone retargeted, armedTool cleared | (identical) | PASS |
| `buttonTap btnPhotoF` | `keydown('F')` → `tryDronePhoto()` | runs | runs | PASS |
| `buttonTap btnPhotoG` | `keydown('G')` → `trySubCamPhoto()` | runs | runs | PASS |
| `buttonTap btnDecoy` | `keydown('B')` → `toggleDecoyOnSelected()` | runs | runs | PASS |
| `buttonTap btnCycle` | `keydown('Tab')` → `cycleSelectedDrone()` | runs | runs | PASS |
| `buttonTap btnRestart` (lose state) | `keydown('R')` (lose state) | `state = newState()` | (identical) | PASS |
| `canvasTap` with no armed tool | `mousedown` no armed tool | deployDrone fallback | (identical) | PASS |

**Direct delta-compare assertion:** Fresh state, suspicion=0 → touch-path `EMP arm + canvas tap on Siren` produces (empCharges=2, suspicion=20). Fresh state, suspicion=0 → desktop `fireEMP(siren.x, siren.y)` produces (empCharges=2, suspicion=20). **Bit-identical.**

---

## Lens C — Coord transform (sim table)

`__sim.touchCssToGameCoord(clientX, clientY)` reads `canvas.getBoundingClientRect()` each call. I stubbed the rect for each test point.

| Canvas rect (left, top, w×h) | Touch CSS (x, y) | Expected game (x, y) | Actual | Δ |
|---|---|---|---|---|
| (0, 0, 960×640) | (0, 0) | (0, 0) | (0, 0) | 0 |
| (0, 0, 960×640) | (960, 640) | (960, 640) | (960, 640) | 0 |
| (0, 0, 960×640) | (480, 320) | (480, 320) | (480, 320) | 0 |
| (0, 0, 480×320) | (240, 160) | (480, 320) | (480, 320) | 0 |
| (0, 0, 480×320) | (0, 0) | (0, 0) | (0, 0) | 0 |
| (100, 0, 600×400) — letterbox | (400, 200) | (480, 320) | (480, 320) | 0 |
| (100, 0, 600×400) | (100, 0) | (0, 0) | (0, 0) | 0 |
| (100, 0, 600×400) | (700, 400) | (960, 640) | (960, 640) | 0 |

All within 1-pixel tolerance (in fact, exact integers). Math implementation at POST line 893-901: `gx = (clientX - rect.left) * (c.width / rect.width)`. Correct.

---

## Lens D — Viewport + scaling

| Check | Status | Evidence |
|---|---|---|
| `<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">` in `<head>` | **PASS** | File line 7. |
| Canvas internal width/height attributes preserved | **PASS** | `<canvas id="game" width="960" height="640">` at file line 146. Pre-Step-8 had `width="960" height="640"` on the canvas line. Unchanged. |
| Aspect-preserving CSS (3:2) | **PASS** | `#canvasFrame` (line 30) with `.touch-mode #canvasFrame { width: min(100vw, calc(100vh * 3 / 2)); height: min(100vh, calc(100vw * 2 / 3)); margin: 0 auto; }` (lines 39-42). Inner `canvas { width: 100%; height: 100%; }` (lines 44-49). Letterbox automatic. |
| Portrait warning overlay present and triggered on portrait | **PASS** | `#portraitWarning` element (file line 170) with CSS default `display: none` (line 126) and `.touch-mode.portrait #portraitWarning { display: flex; }` (line 139). `updateOrientationClass()` (line 1004) adds/removes `body.portrait` class based on `window.innerHeight > window.innerWidth`; wired to `resize` and `orientationchange` events at lines 1025-1026. |

---

## Sim tests I ran

**Total: 164 PASS / 0 FAIL.** Harness loads `<script>` block via `new Function`, stubs DOM/window/navigator/canvas, invokes `__sim`.

| Test group | Tests | Result |
|---|---|---|
| `__sim` surface — total entries = 73 | 1 | PASS |
| `__sim` surface — 11 new Step-8 entries present | 11 | PASS |
| `__sim` surface — 62 pre-Step-8 entries all preserved | 62 | PASS |
| Tuning constants (Step-7 90-value table spot-check) | 20 | PASS |
| INV1 — Siren not killable (200 fires) + no HP key | 2 | PASS |
| INV2 — suspicion state boundaries at 0/33/34/74/75 | 5 | PASS |
| INV3 — ping +25, recon +8 | 2 | PASS |
| INV4 — jam +5, EMP +20, KD +20; charges 3/3/2/2/5 | 8 | PASS |
| INV5 — vaporize @ 4.1s; survive @ 3.0s + drop; −5 decay | 3 | PASS |
| Lens B — joystick → keys (8 directions + deadzone + null + live-set + release) | 9 | PASS |
| Lens B — button taps + canvas taps for every tool | 18 | PASS |
| Lens B — desktop fireEMP delta matches touch path | 1 | PASS |
| Lens C — coord transforms (8 points across 3 rect configs) | 8 | PASS |
| Lens D — canvas attributes preserved | 2 | PASS |
| Adversarial (see below) | 5 | PASS |
| Sanity — IS_TOUCH_DEVICE | 1 | PASS |

---

## Adversarial sims

| Attack | Result |
|---|---|
| Try to kill a Siren — 600 chained fires (`fireEMP`+`fireKnockdown`+`fireJam` × 200) | Sirens survive (count remains 3). PASS. |
| Try to find a free reveal — every non-passive reveal calls `applySuspicion` | None found; passive is the only free mode. PASS. |
| Joystick toggle on/off — strands keys in live `keys` Set? | Empty in == empty out; no stranded keys. PASS. |
| Try to break warning valve — hold suspicion at 99.99 for 10 simulated seconds | No `vaporized` trigger (since trigger is `>= SUSP_MAX === 100`). PASS. |
| Determinism — fresh state + ping twice across two sims | Same suspicion delta. PASS. |
| `canvasTap` with no armed tool — does it match desktop left-click fallback? | Yes: deploys drone (droneSupply −1). PASS. |
| Touch listeners on desktop (no touch hardware) — overlay still hidden? | Yes: `#touchOverlay { display: none; }` is the default, only `.touch-mode` overrides. Body never gets `.touch-mode` class on a desktop boot path (`IS_TOUCH_DEVICE` false). PASS. |

---

## Verdict

**GREENLIGHT**

Step 8 delivered exactly what brief 08 specified:
- Touch + responsive UI layer atop the Step-7-tuned single-file game.
- Desktop path **proven byte-equivalent**: MD5 of post JS body with Step-8 blocks stripped equals MD5 of pre-Step-8 JS body (`d64857726e8bb74b0f3f5c5bd6770621`). Zero silent refactors. Pat's hard constraint satisfied.
- All six domain invariants HELD (164 sim tests / 0 failures).
- Step-7 90-constant tuning table unchanged in shape, magnitude, naming.
- `__sim` strict superset: 62 pre-Step-8 entries preserved verbatim, 11 new touch-helper entries added.
- Touch event mapping produces game-state deltas bit-identical to desktop equivalents (every tool / button / canvas tap verified).
- Coord transform correct to <1px tolerance at half-scale and letterbox configurations.
- Viewport meta tag, aspect-preserving CSS, portrait warning overlay all in place.
- INV6 form-pass deferral maintained: no fonts, palette, audio, video, images, animations, or transitions added.
- `node --check` clean. Single file. Backup md5-verified.

### Open potholes worth flagging (for Pat to ratify post-playtest — non-blocking)

These are NOT FIX REQUIRED — they're observations Pat may want to address in a separate UI-tuning pass after physical-device playtest:

1. **Touch listeners bound unconditionally.** The `wireTouchHandlers()` IIFE binds joystick / button / canvas touchstart listeners regardless of `IS_TOUCH_DEVICE`. On a non-touch desktop this is functionally inert (touch events don't fire and the overlay is `display:none` so clicks can't reach buttons), but if Pat wants belt-and-suspenders he can gate the entire wiring block on `IS_TOUCH_DEVICE`. The build-agent's stated rationale is `__sim` testability; preserving that is reasonable.
2. **Build-agent's `click` listener on action buttons.** Used as a devtools-testing fallback; preventDefault on touchstart prevents double-fire on real touch devices. If Pat sees buttons firing twice on his phone, drop the `click` registration (build-agent flagged this in handoff §"Open potholes for Pat" #2).
3. **Portrait warning is text-only.** Per INV6 — deliberate. If Pat wants a rotation icon, that's a form-pass concern.
4. **`?` button is a no-op placeholder.** Handler wired but `refreshHelpOverlay()` is intentionally empty (INV6). Form pass.
5. **Step-7 OPEN POTHOLE 1 (active-aggression-vaporize ordering) is inherited unchanged.** Step 8 didn't touch any game logic — this surfaces in playtest, not in audit.

### If FIX REQUIRED — N/A
### If PAT INTERVENTION — N/A

---

## Receipt

- Audit complete: YES
- Verdict: **GREENLIGHT**
- Orchestrator action: **HALT FOR PAT (per brief 08 — this is the last build step; orchestrator writes `ORCHESTRATOR_COMPLETE_STEP8.md` and hands back for mobile playtest).**

---

*AI-DESIGNED. Auditor: dreamy-awesome-fermat (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context). Authority: `SIRENS_SONG_SPEC.md` > `agent.md` > `briefs/AUDITOR_BRIEF.md` > `briefs/08_mobile_controls.md` > `handoffs/08_HANDOFF_FROM_STEP8.md` > current code. Audit verifies, does not modify. After this verdict the orchestrator writes the wrap-up and surfaces to Pat for mobile playtest.*
