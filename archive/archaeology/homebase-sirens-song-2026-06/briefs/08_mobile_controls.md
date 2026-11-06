# Brief — Step 8: Mobile Controls + Responsive Layout

**Your step:** Step 8 — an **extension beyond the spec's 7-step build-leash**. Pat ratified this extension after Step 7 closed GREENLIGHT (ORCHESTRATOR_COMPLETE.md, 2026-06-04 14:58 UTC). Steps 1–7 produced a function-complete prototype; Step 8 makes it playable on Pat's phone in landscape.

**You inherit from Steps 1–7 (all GREENLIT).** Read `handoffs/07_HANDOFF_FROM_STEP7.md` and `audits/07_AUDIT_STEP_07.md` before you start. The game logic, AI behavior, suspicion math, tuning values, and the 60+ `__sim` surface are **closed**. You may NOT change them.

**You are the last build step.** After you, the build hands back to Pat for mobile playtest on his phone. STOP at the end.

---

## What you produce

A **UI / input layer** on top of the existing single-file `code/sirens_song.html` that:

1. Adds responsive viewport sizing so the 960×640 canvas scales to fit a phone screen with aspect preserved (letterbox is acceptable).
2. Detects touch capability and, when present, renders a touch control overlay (virtual joystick + action buttons) over the canvas.
3. Maps touch events to the existing keyboard/mouse input handlers using a coord transform that maps CSS pixels → canvas-internal (0..960, 0..640) coords.
4. Preserves the desktop input path **byte-equivalent in behavior** — keyboard + mouse + right-click on a non-touch device must function exactly as in Step 7.
5. Exposes a `__sim` test surface for touch event simulation so the auditor can verify mapping correctness without a physical device.

Mobile is a **UI LAYER**, not a redesign. No game logic change, no tuning value change, no AI behavior change.

---

## Architectural decisions (pre-made by Pat — do NOT re-litigate)

- **Single file, no fork.** Touch + desktop coexist in `code/sirens_song.html`. Detect touch capability; render touch overlay only when present.
- **Landscape orientation.** Submarine top-down + sonar sweep requires a horizontal map. Either lock orientation (CSS `orientation:landscape`) or at minimum optimize for landscape and warn portrait users with an overlay message.
- **Aspect-preserving canvas scaling.** Maintain 960:640 (3:2). Letterbox if needed. Touch coords transform back to canvas-internal coords using the same scale factor.
- **Desktop path byte-equivalent.** Keyboard + mouse + right-click must work EXACTLY as Step 7. The audit verifies this with full INV1–INV6 regression.

## Touch control mapping (commit to these — no creative reinterpretation)

| Desktop verb | Touch replacement |
|---|---|
| WASD / arrows (sub drive) | Virtual analog joystick in bottom-left thumb zone. Joystick vector → synthesized keys: angle/magnitude resolves to the same set of `keys` the existing keydown/keyup handlers populate (i.e., set `keys` for `KeyW`/`KeyA`/`KeyS`/`KeyD` based on joystick stick direction). |
| SPACE (active ping) | Large button, bottom-right thumb zone. Tap → fires the same code path as `tryActivePing()` (or whatever the SPACE handler calls today). |
| Left-click (deploy drone) | Tray button "Deploy" → arms drone-deploy mode → tap on map area to place. The tap-after-arm primitive matches the desktop arm-then-click flow already used for tools. |
| Right-click (redirect drone) | Tray button "Redirect" → arms drone-redirect mode → tap on map area for new target. |
| `2` / `3` / `4` (arm EMP / KD / recon) | Three tray buttons. Tap arms the tool; tap on map area fires (same semantic as desktop "press key to arm, click to fire"). |
| `1` (jam) | Tray button. Jam is self-targeted; tap fires immediately. |
| `F` (drone photo) / `G` (sub-cam photo) | Tray buttons. Match desktop semantics. |
| `B` (toggle decoy mode on selected drone) | Tray button. Match desktop semantics. |
| `TAB` (cycle drone) | Tray button. Match desktop semantics. |
| `R` (restart from lose state) | Tray button visible when lose overlay is active. |
| `?` / help overlay toggle | Tray button. |

**The arm-then-tap-map primitive is the unifying pattern.** It already exists for desktop tools (key arms, click fires). Touch reuses it: button-tap arms, map-tap fires. This minimizes new code paths.

You may choose: HTML elements absolutely-positioned over the canvas, OR canvas-rendered overlay with hit-testing. The brief does not mandate which. Choose the one that survives the audit's coord-transform tests most cleanly. Most likely HTML elements — easier to position, less coord-transform math, separable from game rendering.

---

## Sections you re-read before writing code (mandatory)

- `agent.md` §2 (six domain invariants — they bind Step 8 the same as Steps 1–7).
- `agent.md` §3 (creative license boundary — Step 8 has more implementation latitude because there's no spec section for mobile; that means more notes for Pat to ratify, not more game-design changes).
- `agent.md` §7 (constraints — form pass is still deferred; placeholder shapes only for buttons too, no polish).
- `SIRENS_SONG_SPEC.md` §11 last line: *"After **tuning**, hand back for playtest."* Step 8 is an additional UI layer between tuning-complete and Pat playtest — Pat ratified this extension explicitly.

---

## Inherited state

- `code/sirens_song.html`: 112,450 bytes / 2,649 lines. All Steps 1–7 systems present. `node --check` clean. 62-entry `__sim` surface.
- Backups: `code/sirens_song.html.bak.pre-step7-20260604` (pre-tuning state) + all prior step backups preserved.
- Read every prior handoff in `handoffs/` for full context on what each system does and what `__sim` exposes.
- Read every prior audit in `audits/` for which behaviors the auditor verifies against.

---

## Scope boundary (the seam where you stop)

You stop after:

- Viewport meta tag is present.
- Canvas scales responsively, aspect preserved.
- Touch detection runs at boot; overlay HTML/canvas elements render only when touch present.
- All touch control mappings in the table above are wired.
- Coord transform is correct: CSS pixel coords on the canvas → game-world (0..960, 0..640) within 1px tolerance.
- Desktop path is preserved (run `node --check` clean; spot-check that keydown/mousedown handlers still fire on a non-touch path).
- `__sim` surface adds touch-simulation helpers (suggested: `simulateTouchEvent`, `getJoystickState`, `setJoystickVector` — auditor decides exactly which). The pre-Step-8 62 entries remain unchanged in shape.
- Handoff `handoffs/08_HANDOFF_FROM_STEP8.md` is written per `agent.md` §5.2.

You do NOT:

- Change game logic, AI behavior, suspicion math, tuning values, win/lose conditions, or anything from Steps 1–7.
- Add art / sound / palette / "feel" polish (INV6 still holds — buttons are labeled rectangles with plain text, not styled UI chrome).
- Add settings menus, options screens, or anything beyond the start/restart minimum.
- Spawn the next agent — you're the end of the chain. After your handoff, the orchestrator runs the audit.

---

## Mandatory deliverables

1. **Code increment** in `code/sirens_song.html`.
2. **Backup** at `code/sirens_song.html.bak_pre_step8` (md5-verified byte-identical pre-edit).
3. **Handoff README** at `handoffs/08_HANDOFF_FROM_STEP8.md` per `agent.md` §5.2, with:
   - Tuning values table — should be **unchanged from Step 7's 90 constants**. Confirm verbatim.
   - Sim tests run — touch event simulation, joystick vector → key-set mapping, button-tap → tool-arm mapping, coord transform spot-checks.
   - `__sim` surface delta — list any new entries added for touch testing.
   - Open potholes for Pat (likely: orientation lock fallback behavior, button sizing on small devices, any cosmetic decision deferred to form pass).
4. **`claude_index.md` updated** per CGI §G.4 (same task, same agent). Add Step 8 row and reference brief/handoff/audit paths.
5. **`ORCHESTRATOR_LOG.md` patched** with the build-completion line (one line, event format).

---

## Sim tests to run (mandatory at this step)

The auditor will re-run these. Run them yourself first.

### Desktop regression (proves the touch layer didn't break the existing build)

- `INV1`: chain EMP→KD→EMP→KD at a Siren via the existing fire functions; verify Siren state has no `hp/health/dead/killed` field and no death.
- `INV2`: drive suspicion through ping→decay→ping cycles; verify the 33/74/99 transitions and the four-band labels CURIOUS/ALERT/HOSTILE.
- `INV3`: confirm passive sonar is the only free reveal mode; ping +25, drone-photo +15, recon +8 all land via the `applySuspicion` chokepoint unchanged.
- `INV4`: each tool's charges/costs/durations match Step 7's table verbatim.
- `INV5`: sustained 4.1s at suspicion=100 → vaporized; sustained 3s + drop → survives.
- `INV6`: no fonts/palette/audio/sprites added. Buttons are labeled placeholder rectangles. Form pass still deferred.

### Touch event mapping sims

- **Joystick UP-RIGHT vector** at magnitude 1.0 → `keys` set contains `KeyW` AND `KeyD` (the same set that the existing keyboard handler populates when W and D are held simultaneously). Sub heading/velocity should evolve identically to a 1-second WD-held sim.
- **Joystick UP vector** → only `KeyW`. **Joystick LEFT** → only `KeyA`. **Joystick null (center)** → empty `keys`.
- **Tap on ping button** → triggers the same code path as a SPACE keypress. Suspicion increments by exactly +25 (per INV3/INV4).
- **Tap on EMP button, then tap on a Siren** → same effect as desktop `keydown('2')` + `click(SirenX, SirenY)`: Siren enters stun state, +20 suspicion, EMP charges decrement by 1.
- **Tap on Deploy button, then tap on map** → drone deployed at the tapped world coord. Drone supply decrements.
- **Tap on Redirect, then tap on map** → nearest deployed drone redirects to the tapped coord.
- **Coord transform spot-checks**: with the canvas displayed at 480×320 CSS pixels (half of internal 960×640), a touch at CSS (240, 160) → game coord (480, 320). With aspect-preserving letterbox at viewport 800×400 (canvas displayed at 600×400 centered horizontally), a touch at CSS (400, 200) → game coord (480, 320). The math: `(touchCSS - canvasOffsetCSS) * (canvasInternal / canvasDisplayedCSS)`.

### Viewport / scaling sims

- Confirm `<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">` is present.
- Confirm CSS rules sized so canvas fits the viewport with aspect preserved (3:2). The exact CSS technique is your call (`object-fit`-style approach with a wrapper, or `max-width`+`max-height` with `aspect-ratio: 3/2`, or JS-managed resize). Pat doesn't care which works as long as the aspect is preserved.
- Confirm portrait detection fires a "rotate to landscape" overlay (or orientation lock, if you choose the lock approach).

---

## Failure modes (handle as you would Steps 1–7)

| Situation | What to do |
|---|---|
| You find yourself wanting to "improve" a desktop control (e.g., "the WASD scheme could be better") | Stop. Out of scope. Note it in handoff §"Design improvement notes (not implemented, for Pat)." |
| You can't find a clean way to position the joystick / buttons without overlapping the play area | This is the form/UX tension that's deferred to form pass. Pick the simplest layout that works (e.g., joystick in a 120px corner pad, action buttons in a column on the right). Note in handoff. |
| You discover the canvas resize breaks some draw-call coord math elsewhere in the file | This is a regression. Stop. The canvas's `width` and `height` attributes must remain 960×640; only the CSS-displayed size scales. If you find any code that hard-codes pixel coords assuming the canvas display size matches its internal size, that's a flag — note it in handoff but do not change the underlying draw code; instead make sure your CSS scaling doesn't depend on internal canvas size changing. |
| Touch event mapping passes desktop sims but feels wrong on the device | You can't playtest on a device in the sandbox. Document the math, run the sims, hand off; Pat playtests. |
| Edit tool truncates the file (known issue from Steps 2–7) | Use the Python heredoc / atomic-rewrite workaround documented in Step 2–7 handoffs. Verify byte-identical backup before any edit; verify `node --check` after every Edit; if the file gets truncated mid-edit, restore from backup and retry via atomic rewrite. |

---

## Audit gates (what the auditor will check)

- **Lens A: Desktop regression.** Auditor runs the full INV1–INV6 sim battery. Byte-equivalent behavior required.
- **Lens B: Touch event mapping.** Auditor synthesizes touchstart/touchmove/touchend sequences and verifies the resulting game state changes match the desktop equivalent (e.g., joystick UP-RIGHT = W+D held; tap-after-EMP-arm at coord (X,Y) = click-after-EMP-arm at canvas-mapped (X,Y)).
- **Lens C: Coord transform correctness.** Touch at canvas top-left CSS → game (0,0) within tolerance. Touch at canvas bottom-right CSS → game (960, 640).
- **Lens D: Viewport + scaling.** Meta tag present. Canvas scales to fit. Aspect preserved.
- **Step scope:** no game logic change. No tuning change. No new mechanics. No form polish.
- **Code hygiene:** `node --check` clean. Single file. Backups preserved.

---

## Handoff format

Per `agent.md` §5.2, your handoff lands at `handoffs/08_HANDOFF_FROM_STEP8.md`. Sections required:

- **What I built** — bullets, the additions (viewport, responsive CSS, touch detection, joystick, action tray, event wiring, coord transform).
- **State of the file** — bytes/lines, backup md5, `node --check` status.
- **Tuning values used** — confirm the Step 7 table is unchanged (cite the 90 constants by reference; no new tuning constants added unless trivially cosmetic, in which case justify).
- **Sim tests run** — list every sim test with expected/result.
- **`__sim` surface delta** — list new entries (touch simulators), confirm strict superset of Step 7's 62 entries.
- **Open potholes for Pat** — orientation strategy, button-size choice, portrait fallback, anything else.
- **Design improvement notes (NOT implemented, for Pat)** — anything you would have liked to do but didn't.
- **Invariant adherence self-check** — six bullets, INV1–INV6 each held.
- **Receipt** — `Step 08: COMPLETE — READY FOR PAT MOBILE PLAYTEST. ORCHESTRATOR: HALT after audit.`

End your turn with the receipt. The orchestrator reads it and fires the auditor.

---

*AI-DESIGNED. Brief for daisy-chain step 8 (extension beyond spec's 7-step leash, ratified by Pat post-Step-7 GREENLIGHT). Authority: SIRENS_SONG_SPEC.md > agent.md > this brief. LAST STEP. Halt after audit.*
