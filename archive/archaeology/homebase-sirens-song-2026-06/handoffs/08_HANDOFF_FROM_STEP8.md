# Step 08 handoff -- mobile_controls

**Build session:** dreamy-awesome-fermat (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context)
**Built atop:** Step 7 GREENLIGHT (`audits/07_AUDIT_STEP_07.md`); inherits Steps 1+1-fixpass+2+3+4+5+6+7.
**Backup of pre-step-8 state:** `code/sirens_song.html.bak_pre_step8` (112,450 bytes; md5 `be02fa806581e0608938c27cb9978223`).
**Resulting code state:** `code/sirens_song.html` 135,266 bytes / 3,196 lines. JS body 128,551 bytes. Passes `node --check`.

**Step 8 is an EXTENSION beyond the spec's 7-step build-leash**, ratified by Pat post-Step-7 GREENLIGHT. It adds a mobile / responsive UI LAYER only. No game logic, no AI behavior, no tuning, no suspicion math, no win/lose conditions, no new mechanics were modified. The desktop path is byte-equivalent in behavior.

---

## What I built

A touch + responsive UI layer on top of the existing single-file game:

- **Viewport meta tag** in `<head>`: `name="viewport" content="width=device-width, initial-scale=1, user-scalable=no"`.
- **Responsive canvas scaling.** New `#canvasFrame` wrapper using `aspect-ratio`-equivalent CSS (`width: min(100vw, calc(100vh * 3 / 2))`, `height: min(100vh, calc(100vw * 2 / 3))`). The canvas `width="960" height="640"` ATTRIBUTES are unchanged; only CSS-displayed size scales. Letterbox automatic when viewport ratio differs from 3:2.
- **Boot-time touch detection.** `const IS_TOUCH_DEVICE = ("ontouchstart" in window) || (navigator.maxTouchPoints > 0)`. Sets `document.body.classList.add("touch-mode")` when true. On desktop, no class added; overlay stays `display:none`.
- **Virtual joystick** (HTML element, bottom-left of canvas). Sized in `vmin` for adaptive sizing; placeholder circle + thumb (INV6: no styled chrome). Touch handlers (`touchstart`/`touchmove`/`touchend`/`touchcancel`) compute `(vx, vy, magnitude)` from center, then write synthesized `KeyW`/`KeyA`/`KeyS`/`KeyD` codes into the **same `keys` Set** the existing keyboard handler populates. Deadzone 0.22; axis threshold 0.35 of magnitude admits diagonals.
- **Action button tray** (HTML elements, right side). 13 buttons: PING, DEPLOY, REDIR, JAM, EMP, KD, RECON, PHOTO-F, PHOTO-G, DECOY-B, CYCLE, ?, RESTART. Each is a plain `<button class="tbtn">` labeled rectangle. Tap-handlers call the existing game functions directly (`tryActivePing()`, `fireJam()`, etc.) or set `state.armedTool` with the same string values the desktop keydown handler uses (`"emp"`, `"knockdown"`, `"recon"`, `"deploy"`, `"redirect"`). Armed-state shown via `.armed` class on the button.
- **Canvas touchstart handler** for map-taps. Coord transform: `(touchClientX - canvasRect.left) * (canvas.width / canvasRect.width)` and likewise for Y, using `canvas.getBoundingClientRect()` per tap. Dispatches through the same armed-tool switch as the desktop mousedown handler.
- **Portrait warning overlay** (`#portraitWarning`). Cosmetic placeholder text "Please rotate to landscape." Visible when `body.portrait` class set (toggled by `updateOrientationClass()` on boot, `resize`, and `orientationchange`).
- **Restart button visibility** keyed off `body.gameover` class, toggled by `refreshTouchArmedUI()` after each state-affecting tap.
- **`__sim` surface additions** for headless sim testing (11 new entries; all 62 pre-Step-8 entries preserved verbatim).

All additions are ADDITIVE. No existing function body was modified. No existing event listener was wrapped or replaced. Existing CSS rules for `html, body, #wrap, #hud, canvas, #help` are intact (only new selectors added).

---

## State of the file

- File: `code/sirens_song.html`
- Size: **135,266 bytes / 3,196 lines** (was 112,450 / 2,648 -- delta +22,816 bytes / +548 lines)
- JS script block: 128,551 bytes
- `node --check`: **CLEAN**
- Backups preserved:
  - `code/sirens_song.html.bak_pre_step8` (112,450 bytes; md5 `be02fa806581e0608938c27cb9978223` -- byte-identical to pre-edit Step-7 file)
  - `code/sirens_song.html.bak.pre-step7-20260604` (110,327 bytes; Step 6 -> Step 7 backup, preserved)
  - All earlier dated backups preserved

---

## Tuning values used

**The Step 7 table of 90 numeric constants is UNCHANGED in shape, magnitude, and naming.** Step 8 added zero tuning constants. The only "values" introduced by Step 8 are layout / input-handling constants embedded inside the touch input block, all of which are UI placeholders per INV6 and have no effect on game logic, AI, suspicion math, or any spec-§11 default:

| Constant (Step 8 ONLY -- UI placeholders) | Value | Rationale |
|---|---|---|
| `touchInput.joystick.deadzone` | 0.22 | Standard joystick deadzone; below this thumb-jitter doesn't synthesize keys. |
| Joystick axis threshold (in `joystickVectorToKeys`) | 0.35 | Of magnitude; admits diagonals (UP-RIGHT writes both KeyW and KeyD). |
| Joystick CSS size | 22vmin (96px..180px) | Sized to thumb-comfort range across phone widths. |
| Button tray CSS size | 22vmin (84px..160px) | Same. |

None of these affect game state. They are tunable in playtest if Pat wants different thumb ergonomics; that's a UI tuning question, distinct from game tuning.

The full Step 7 90-constant tuning table is preserved verbatim and re-verified at runtime by the sim tests:

- `OXYGEN_MAX_SECONDS = 210` (Step 7 tuned)
- `HUNTER_PURSUE_SPEED_PX_PER_SEC = 75` (Step 7 tuned)
- `RECON_REVEAL_RADIUS_PX = 460` (Step 7 tuned)
- `THRESH_ALERT = 34`, `THRESH_HOSTILE = 75`, `WARNING_THRESHOLD = 75`, `SUSP_MAX = 100`, `INSTAKILL_SUSTAIN_SEC = 4.0`
- All charges + costs at spec defaults: ping +25, drone-photo +15, EMP +20, KD +20, jam +5, recon +8, decay 5/s
- Hull 3, drones 5, jam 3, EMP 3, KD 2, recon 2
- All Patroller / Sentinel / Hunter / curiosity / decoy values UNCHANGED

---

## Sim tests run

Methodology: extracted the `<script>` block via Python regex, loaded via `new Function(...)` harness with DOM/window/canvas/navigator stubs (same pattern Steps 2-7 used). The harness exposes `IS_TOUCH_DEVICE` independent of the host Node environment so both touch and non-touch paths can be tested in the same process.

**53 sim tests run -- 53 PASS / 0 FAIL.** Tail of the run captured for the auditor:

### Touch detection
| Test | Expected | Result |
|---|---|---|
| `IS_TOUCH_DEVICE` true when `navigator.maxTouchPoints > 0` | true | PASS |
| `isTouchOverlayVisible()` true when touch device | true | PASS |
| `IS_TOUCH_DEVICE` FALSE when no touch capability + no ontouchstart | false | PASS |
| `body.touch-mode` class set when touch device | set | PASS |
| `body.touch-mode` class NOT set on desktop | not set | PASS |

### Joystick vector -> keys mapping
| Test | Expected | Result |
|---|---|---|
| UP-RIGHT (pi/4, mag=1.0) | `KeyW` AND `KeyD` (no S, no A) | PASS |
| UP (pi/2, mag=1.0) | only `KeyW` | PASS |
| LEFT (pi, mag=1.0) | only `KeyA` | PASS |
| DOWN (-pi/2, mag=1.0) | only `KeyS` | PASS |
| DOWN-LEFT (-3pi/4, mag=1.0) | `KeyS` AND `KeyA` | PASS |
| Null (magnitude 0) | empty keys | PASS |
| Deadzone (magnitude 0.1 < 0.22 deadzone) | empty keys | PASS |
| Joystick keys land in live `keys` Set | true | PASS |
| Joystick release clears synthesized keys | cleared | PASS |
| `simulateTouchEvent` joystickStart/Move/End sequence | drives keys correctly | PASS |

### Button taps -> game actions
| Test | Expected | Result |
|---|---|---|
| Tap PING -> susp += 25 (matches SPACE) | +25 | PASS |
| Tap EMP -> `armedTool='emp'` | armed | PASS |
| Tap EMP twice -> arms then disarms (toggle) | null | PASS |
| Tap EMP + canvas tap on Siren -> stunned, +20 susp, charges-1 | all 3 | PASS |
| Tap DEPLOY + canvas tap on safe coord -> drone placed, supply-1 | supply-1 | PASS |
| Canvas tap with NO armed tool -> deploys drone (matches desktop) | drone placed | PASS |
| Tap RECON + canvas tap -> reveal at coord, charges-1, susp+8 | all 3 | PASS |
| Tap JAM -> fires immediately (self-targeted) | charges-1 | PASS |
| Tap REDIR + canvas tap -> redirects nearest drone | target updated | PASS |
| Tap CYCLE -> `cycleSelectedDrone` runs | no error | PASS |
| Tap RESTART when game over -> resets state | loseReason=null | PASS |
| Tap RESTART when game alive -> no effect (safety) | no change | PASS |

### Coord transform
| Test | Expected | Result |
|---|---|---|
| 480x320 displayed (half scale), CSS (240,160) -> game (480,320) | (480, 320) | PASS |
| 600x400 letterbox @ left=100, CSS (400,200) -> game (480,320) | (480, 320) | PASS |
| Top-left displayed -> game (0,0) | (0, 0) | PASS |
| Bottom-right displayed -> game (960,640) | (960, 640) | PASS |
| Center displayed -> game (480, 320) | (480, 320) | PASS |

### Desktop regression (INV1-INV6)
| Test | Expected | Result |
|---|---|---|
| INV1: 50 chained EMP+KD fires -> all 3 Sirens still present, no HP-like keys | held | PASS |
| INV2: suspicionState bands (CURIOUS/ALERT/HOSTILE) match spec | held | PASS |
| INV3: ping cost = +25, PASSIVE_RADIUS (90) < PING_RADIUS (360) | held | PASS |
| INV4: all charges + costs at spec defaults | held | PASS |
| INV5: 4.1s sustained @ 100 -> vaporized | vaporized | PASS |
| INV5: 3.0s sustained @ 100 + drop -> survives | null | PASS |
| INV5: HUNTER_PURSUE_SPEED=75 preserved | 75 | PASS |
| INV6: viewport meta tag present | present | PASS |
| INV6: Step 7 tuning preserved (OXY=210, RECON_R=460, etc.) | all match | PASS |

### Desktop path preserved (byte-equivalent behavior)
| Test | Expected | Result |
|---|---|---|
| Desktop `tryActivePing()` callable | +25 susp | PASS |
| Desktop `deployDrone(x,y)` callable | drone placed | PASS |
| Desktop `redirectNearestDrone(x,y)` callable | no error | PASS |
| Desktop `tryDronePhoto()` callable | no error | PASS |
| Desktop `trySubCamPhoto()` callable | no error | PASS |

### Cross-step regression
| Test | Expected | Result |
|---|---|---|
| Factory proximity returns numeric rate | number | PASS |
| Recon radius preserved at 460 | 460 | PASS |
| Determinism: identical inputs -> identical suspicion | exact match | PASS |
| `__sim` strict superset of Step 7's 62 entries | 62 present | PASS |

### Orientation
| Test | Expected | Result |
|---|---|---|
| `body.portrait` class set when height > width | set | PASS |
| Landscape: no portrait class | not set | PASS |

---

## `__sim` surface delta

**Pre-step-8: 62 entries. Post-step-8: 62 + 11 = 73 entries.** Strict superset confirmed: the sim test "`__sim` is strict superset of Step 7's 62 entries" enumerates all 62 expected keys and verifies each is present and callable.

New Step 8 entries on `window.__sim`:

| Entry | Purpose |
|---|---|
| `IS_TOUCH_DEVICE` | Boot-time touch detection result. |
| `getTouchInputState()` | Returns the full touchInput object (joystick state + overlay flags). |
| `getJoystickState()` | Returns `{active, vx, vy, magnitude, syntheticKeys}`. |
| `setJoystickVector(angleRad, magnitude)` | Drives joystick programmatically. Player-intuitive convention: angle 0 = right, pi/2 = UP, -pi/2 = DOWN. Magnitude clamped 0..1. Returns the resulting `{vx, vy, magnitude, keys}`. |
| `simulateTouchEvent(type, payload)` | Programmatic touch dispatch. Types: `joystickStart`/`joystickMove`/`joystickEnd` (payload `{clientX, clientY, identifier}` or `{touches: [...]}`); `buttonTap` (payload `{id}`); `canvasTap` (payload `{clientX, clientY}`). |
| `touchCssToGameCoord(clientX, clientY)` | Exposes the coord transform directly. |
| `isTouchOverlayVisible()` | Returns `body.touch-mode` class status. |
| `setTouchModeForTesting(on)` | Programmatically toggle the touch-mode class. |
| `TOUCH_ACTIONS` | The full button-id -> handler map (so tests can enumerate). |
| `joystickVectorToKeys(vx, vy, magnitude)` | Vector-to-key mapper exposed for isolated testing. |
| `getKeysSet()` | Returns the live `keys` Set as an Array for deep-compare. |

The auditor can run any Step 1-7 sim against this file unchanged. All 62 prior entries respond identically because no game logic / state / function was modified.

---

## Open potholes for Pat (mobile playtest considerations)

1. **Cannot playtest on a physical device in the sandbox.** All touch behavior is verified by synthesized `simulateTouchEvent` calls + DOM stubs. The math is correct; ergonomic feel (button size, joystick sensitivity, deadzone, axis threshold) needs Pat's eyes on a real phone. Adjustments are CSS-only or single-constant tweaks (`touchInput.joystick.deadzone` at line ~796; axis threshold 0.35 in `joystickVectorToKeys` at line ~847).

2. **Button-tap event uses both `touchstart` AND `click` listeners** to support testing in browser devtools without a touch device. Each handler calls `e.preventDefault()` to suppress double-firing. If Pat sees buttons firing twice on a real device, drop the `click` listener or add a debounce.

3. **Orientation strategy: warning overlay, not lock.** I chose a portrait-warning overlay (`Please rotate to landscape.`) rather than `screen.orientation.lock("landscape")` because lock requires fullscreen + user gesture and silently fails on iOS Safari. The overlay is purely cosmetic placeholder text per INV6; if Pat wants true lock, that's a form-pass concern.

4. **Action tray uses 2-column grid; PING spans both columns; RESTART is the last row, displayed only when game over.** On very small phones (~320px viewport width) the tray width is `22vmin` which clamps to a min-width of 84px. Buttons may feel cramped in landscape on a phone with thick bezels. Consider scaling up `min-width` post-playtest.

5. **No right-click semantic on touch.** Desktop right-click maps to "redirect nearest drone." Touch exposes the same via the REDIR button (arms `redirect`, then map tap selects the new destination). This is the cleanest mapping — no two-finger gesture nonsense — but it does require an extra tap vs. desktop. Note for playtest.

6. **`?` (help) button is wired but does nothing.** The handler stores `touchInput.helpVisible` and calls `refreshHelpOverlay()` which is a no-op placeholder per INV6 (no help-screen chrome). If Pat wants a help overlay it goes in the form pass; the hook is already in place.

7. **Touch overlay is positioned over the canvas via absolute children of `#canvasFrame`.** The action tray spans `top: 4%` to `bottom: 4%` and is `right: 1%` from the canvas edge. On very-tall-aspect phones (e.g., 19.5:9) the canvas letterboxes top+bottom and the tray edges sit inside the black bars at the screen edges. This is intentional (the tray follows the canvas, not the viewport). Pat may want to anchor the tray to the viewport instead — design call deferred to form pass.

8. **Canvas `touch-action: none` suppresses pinch-zoom and swipe-scroll on the canvas only.** If Pat scrolls his finger off the canvas onto the action tray (rare), behavior may be inconsistent. The joystick and buttons have their own `touch-action: none` so this is contained.

9. **The Step 7 OPEN POTHOLE 1 (literal-stationary aggression hull-sinks before vaporize) is inherited unchanged.** Step 8 did not touch any game logic. Pat's playtest will reveal whether the active-aggression read holds on a real device.

---

## Design improvement notes (NOT implemented, for Pat)

1. **Multi-touch joystick + concurrent tap.** Currently the joystick tracks a single touch by `identifier`. If Pat keeps a finger on the joystick AND taps a button with the other thumb, it works (different elements, different touch lists). If he tries to tap the canvas (map-tap) while the joystick is held, both touches route to their respective elements correctly. Tested cleanly in sims; needs real-device confirmation.

2. **Tap-and-hold ping repeat.** Desktop SPACE-spam fires one ping per press. Touch PING button taps fire one ping per tap. Holding the button does NOT auto-repeat. If Pat wants press-and-hold to ping repeatedly that's a form-pass enhancement (add an interval on touchstart, clear on touchend).

3. **No visual feedback on disarm.** When `armedTool` clears after a fire (because the tool fired), the `.armed` class is removed but there's no flash / glow indicating the fire happened. INV6 deferred. Form pass.

4. **No on-canvas crosshair for armed-tool aim.** Desktop has the mouse cursor as a free aim indicator. Touch has no aim indicator at all — the player taps where they want the EMP / KD / Recon to land, and the result is what shows. A small reticle following the last touch-move could help. Form pass.

5. **Restart button placement.** Currently restart appears in the action tray when game-over (overlay-rendered). On a real device, after a vaporize-end the player's eyes are probably center-screen on the lose text; a centered restart overlay would be more legible. Form pass.

6. **Joystick / button sizes use `vmin`** which adapts to the smaller of viewport-width and viewport-height. On a landscape phone with a notch, `vmin = height = ~360-400px`, so 22vmin = ~80-88px. That's at the small end of comfortable touch targets (Material guidelines suggest 48dp minimum, typically 90+px). Pat may want 26vmin or hard 96px floor if buttons feel small.

7. **Portrait warning is just text.** Could include a rotation icon, animation, or auto-lock if browser supports. Form pass.

8. **The keyboard `?` toggle for help was not on the desktop already.** I added the `btnHelp` button but its handler is a no-op (`refreshHelpOverlay()`). If Pat wants help on either keyboard or touch, that's the form pass.

9. **The action tray order is somewhat arbitrary** (deploy, redir, jam, emp, kd, recon, photo-f, photo-g, decoy-b, cycle, ?). Pat may want a use-frequency ordering after playtest (e.g., PHOTO-G prominent if sub-cam is the most-used objective tool).

---

## Invariant adherence (self-check, auditor verifies)

1. **No enemy HP / no player kill-path.** HELD. Step 8 added zero Siren state. The 50-chain EMP+KD sim leaves all 3 Sirens present with no `hp/health/damage/life/kill/dead` keys. No new state mutation introduced.

2. **Suspicion is the spine.** HELD. Touch taps route through the same `applySuspicion` chokepoint as desktop. `simulateTouchEvent` with `buttonTap btnPing` adds +25 exactly (verified). EMP tap adds +20, recon adds +8, jam adds +5 — all unchanged. Suspicion bands (CURIOUS/ALERT/HOSTILE) unchanged.

3. **Perceiving costs.** HELD. PING button tap costs +25 (same as SPACE). DRONE photo costs +15. RECON costs +8 and consumes 1 of 2 charges. PASSIVE radius unchanged at 90 (still < PING_RADIUS 360, no free wide reveal). No new perception modes added.

4. **Tools buy time and cost heat.** HELD. All charges (jam 3, EMP 3, KD 2, recon 2, drones 5) unchanged. All durations (jam 4s, EMP 5s, KD 12s, recon 8s) unchanged. Each tool path still funnels through its existing function, which still funnels through `applySuspicion`.

5. **Fairness valve.** HELD. Sim verified: 4.1s sustained @ suspicion=100 -> `loseReason='vaporized'`. 3.0s + drop -> survives. The valve mechanism is untouched. `INSTAKILL_SUSTAIN_SEC = 4.0`, `WARNING_THRESHOLD = 75` — both preserved.

6. **Function before form.** HELD. Step 8 buttons are plain `<button class="tbtn">` labeled rectangles. Joystick is a plain circle with an inner circle. Portrait warning is plain text. **No fonts added** (uses the existing monospace fallback). **No palette** (grayscale `#888`/`#ccc`/`rgba(40,40,40,0.45)` only — placeholder values, not designed colors). **No animations**. **No sound**. **No sprites or icons**. The buttons have an `.armed` state class that swaps the background tint to a yellow-grayscale placeholder so the player can see which tool is armed — this is functional (without it the player can't know what's armed) not aesthetic.

---

## Receipt

- **Step 08: COMPLETE -- READY FOR PAT MOBILE PLAYTEST. ORCHESTRATOR: HALT after audit.**
- Files written:
  - `code/sirens_song.html` (135,266 bytes / 3,196 lines)
  - `code/sirens_song.html.bak_pre_step8` (112,450 bytes; md5 `be02fa806581e0608938c27cb9978223`)
  - `handoffs/08_HANDOFF_FROM_STEP8.md` (this file)
- Sim tests run: **53 PASS / 0 FAIL**
- Tuning values changed: **0** (UI placeholder constants only — joystick deadzone, axis threshold, CSS sizes — none affect game state)
- New mechanics added: **0** (UI / input layer only)
- INV check: all 6 invariants HELD; sim regression battery confirms desktop path byte-equivalent in behavior
- `__sim` surface: 62 -> 73 entries (strict superset; all 62 pre-Step-8 entries preserved)
- `node --check`: **CLEAN**
- Ready for: `audits/08_AUDIT_STEP_08.md` (FINAL audit). After audit, orchestrator writes `ORCHESTRATOR_COMPLETE_STEP8.md` per brief 08.

---

*AI-DESIGNED. Step 8 handoff. Session: dreamy-awesome-fermat (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/08_mobile_controls.md > handoffs/07_HANDOFF_FROM_STEP7.md > audits/07_AUDIT_STEP_07.md > code/sirens_song.html. **LAST EXTENSION STEP. ORCHESTRATOR: HALT after audit.***
