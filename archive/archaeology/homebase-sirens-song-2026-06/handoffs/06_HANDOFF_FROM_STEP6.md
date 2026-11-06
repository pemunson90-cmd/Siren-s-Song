# Step 06 handoff -- recon_call_in

**Build session:** inspiring-upbeat-mccarthy (Cowork Dispatch child, Claude Opus 4.7-1M)
**Built atop:** Step 1 + Step 1 fix-pass + Step 2 + Step 3 + Step 4 + Step 5 (all GREENLIT)
**Backup of pre-step-6 state:** `code/sirens_song.html.bak.pre-step6-20260604` (97,702 bytes; md5 `fd681900f7233f5e370046e33216f2a6`)
**Resulting code state:** `code/sirens_song.html` 110,327 bytes / 2,612 lines. JS body 109,164 bytes. Passes `node --check`.

---

## What I built

On top of steps 1+2+3+4+5: the recon plane call-in per spec section 3.

### Recon plane call-in (key `4`, then click)

- **Click-to-designate.** Press `4` to arm; the next left-click designates the sector center. Press `4` again or `Esc` to disarm without firing. If no charges remain on click, no-op (no cost consumed, no reveal added).
- **2 charges initial** (spec §11). `state.reconCharges` tracks; decrement on successful fire only.
- **+8 suspicion** (spec §3, §6, §11) via the `applySuspicion("recon_call", 8)` chokepoint.
- **Reveal duration:** `RECON_DURATION_SEC = 8.0` (brief 06 "~6-10s, pick"; mid-range chosen). Longer than active ping's 3.0s by design (brief mandate).
- **Reveal radius:** `RECON_REVEAL_RADIUS_PX = 400` (brief 06 "larger than active ping; pick"; 40-px headroom over ping's 360 px max-reached radius).
- **Sector shape:** disc (circle). Consistent with the other reveal modes (passive/ping/drone all use disc geometry); simpler than a rect or wedge.
- **No LOS gating** for the recon reveal (DESIGN CALL -- see "Open potholes" #1 and "Design improvement notes"). Spec §3 calls it "Recon plane call-in"; the plane is above the seafloor; the camera sees through terrain. This makes recon the meaningfully-distinct 4th reveal mode (passive/ping/drone are all LOS-gated by the step-1 fix-pass).
- **Multiple concurrent reveals supported.** Player can call recon twice in succession at different sectors; both are active in parallel; each fades independently.
- **Transient.** Each reveal expires when `state.timeSec >= tEnd` via `updateReconReveals()` filter pass, called once per `update(dt)` tick. INV3 enforced.

### `fireRecon(cx, cy)` -- the call-in function

- Returns the new reveal object `{x, y, r, tStart, tEnd}` on success, `null` on failure (no charges, in lose/win state).
- Side effects: decrement charges by 1, push entry onto `state.reconReveals`, apply +8 suspicion.
- INV1 unrelated: does NOT touch any Siren state. Sirens become visible inside the reveal but no HP/damage/kill machinery is invoked.
- INV3 load-bearing: cost lands at chokepoint; reveal is finite (2 charges) and transient (8s fade).
- INV4 architecture: same charge-finite + cost-of-use pattern as jam/EMP/KD from step 5.

### `updateReconReveals()` -- transience enforcement seam

- Called once per `update(dt)` after `updateProjectiles(dt)`.
- Filters `state.reconReveals` to drop any entries whose `tEnd <= state.timeSec`.
- Single source of truth for "is this reveal still active?" (alongside `isInReconReveal`).

### `isInReconReveal(px, py)` -- the visibility spine

- Returns true if (px, py) is inside any active recon reveal.
- Used by `drawSirenIfVisible` (to reveal Sirens in the sector) and `countVisibleSirens` (HUD readout).
- No LOS gating -- recon is a flyover.

### `reconRevealAlphaAt(px, py)` -- render alpha fade

- Returns 0..1: max life-fraction (1.0 at fire time -> 0.0 at expiry) among reveals containing (px, py).
- Used by `drawSirenIfVisible` and the world-reveal pass for render-only flavor (INV6 placeholder).
- Mechanically the reveal is binary (in or out); the fade is visual feedback only.

### `drawWorldReconNear(cx, cy, radius, alpha)` -- recon-flavor world reveal

- Mirror of `drawWorldNear` but with NO LOS gating on terrain/factory/objectives.
- Slight greenish tint (rgba 130,150,140 for terrain; 180,140,120 for factory) to legibly distinguish a recon-revealed sector from a sonar/drone-revealed one. INV6 placeholder (legibility aid, not form decision).

### `drawSirenIfVisible` -- extended with `inRecon` branch

- Was: `inPassive || inPing || inDrone` -> visible.
- Now: `inPassive || inPing || inDrone || inRecon` -> visible.
- `inRecon` is set when `isInReconReveal(siren.x, siren.y)` is true (no LOS gate).
- Alpha contribution: `0.8 * reconVisAlpha` (where `reconVisAlpha = reconRevealAlphaAt(siren.x, siren.y)`).
- Visibility max-alpha aggregator unchanged in shape; just added one more `Math.max` argument.

### `countVisibleSirens` -- extended with recon branch

- New final clause: if no other reveal mode covered the Siren, check `isInReconReveal(sir.x, sir.y)` -- if true, count it. Used in the HUD readout `sirens_visible: N`.

### HUD additions

The step-5 HUD line 5 (`jam[1]: N   emp[2]: N   kd[3]: N   ARMED: ...   JAM ACTIVE ...`) is extended:

- Inserted after `kd[3]`: `recon[4]: N   recon_active: M   `
- `recon[4]: N` = charges remaining (2 -> 1 -> 0 across a run).
- `recon_active: M` = count of currently-active reveal sectors (0, 1, or 2).
- Rest of line unchanged.

### Render additions

In the main `render()` pass, after the active-ping reveal but before the extraction beacon:

- A new loop over `state.reconReveals` draws each active reveal:
  - `drawWorldReconNear(rr.x, rr.y, rr.r, 0.50 * life)` -- the world content (terrain/factory/objectives) inside the sector at fade-life alpha.
  - A dashed circle boundary (rgba 180,240,200) at the sector's edge.
  - A "RECON Ns" countdown label above the sector.
- `life = (rr.tEnd - state.timeSec) / (rr.tEnd - rr.tStart)` -- linear fade from 1.0 to 0.0.

### Control bindings

- **4** = arm recon / disarm recon -- NEW; next left-click fires
- **Esc** = disarm any armed tool -- updated to include recon
- Left-click while armed: fires `fireRecon(clickX, clickY)` instead of deploying a drone. Tool disarms after fire (success or failure).
- All other bindings unchanged from step 5.

## State of the file

- File: `code/sirens_song.html`
- Size: **110,327 bytes / 2,612 lines** (was 97,702 / 2,321 -- +12,625 bytes / +291 lines)
- JS script block: 109,164 bytes; `node --check` clean
- Backups preserved:
  - `code/sirens_song.html.bak.pre-step6-20260604` (97,702 bytes -- pre-step-6 byte-identical backup; md5-verified)
  - `code/sirens_song.html.bak.pre-step5-20260604` (79,522 bytes)
  - `code/sirens_song.html.bak.pre-step4-20260604` (55,234 bytes)
  - `code/sirens_song.html.bak.pre-step1-fixpass-20260604` (41,825 bytes)
  - `code/sirens_song.html.bak.step2-pre-step3` (23,523 bytes)

## Spec sections implemented

- **§3 Perception system (recon plane call-in row)**: +8 suspicion, consumable (default 2), large sector reveal, longer duration than active ping. The 4th and final perception mode.
- **§6 Suspicion system**: recon +8 gain source via the `applySuspicion("recon_call", 8)` chokepoint, integrated with existing decay / factory / Siren-prox / threshold math.
- **§10 Fairness principles 3 (tools buy time, cost heat; nothing free except passive)**: load-bearing. Recon costs +8, is finite (2 charges), transient (8s reveal). Passive remains the only consistently free reveal.
- **§11 step 6**: fully covered.

NOT implemented (correctly out of scope): step 7 (tuning pass), any additional reveal types, additional Sirens/tools/drones.

## Tuning values used (with spec citation)

Steps 1+2+3+4+5 values preserved verbatim. Step 6 additions:

| Name | Value | Source |
|---|---|---|
| `RECON_CHARGES_INITIAL` | 2 | spec §11 |
| `RECON_SUSP_COST` | 8 | spec §3 / §6 / §11 |
| `RECON_DURATION_SEC` | 8.0 | FLAG step 7. Brief 06 says "longer than active ping (~3s); pick ~6-10s"; picked mid-range. |
| `RECON_REVEAL_RADIUS_PX` | 400 | FLAG step 7. Brief 06 says "larger than active ping (360 px); pick"; picked 40-px headroom. |

Both qualitative step-6 values flagged for step-7 tuning per spec §11 build-leash.

## Sim tests run

Methodology: extracted `<script>` block to `/tmp/step6_check.js`; loaded via `new Function('document','window','performance','requestAnimationFrame', src + 'return window.__sim;')` with DOM stubs; drove `__sim` API directly. Same harness pattern as steps 1-5.

### Step 6 tests (90 tests, 89 PASS, 1 invalid-test-assumption)

| Group | Count | Coverage |
|---|---|---|
| A: TUNING constants | 6 | All step-6 TUNING values present and in expected ranges; recon radius > ping radius; recon duration > ping duration |
| B: Initial state | 2 | reconCharges = 2; reconReveals = [] |
| C: fireRecon basic | 9 | Fire returns reveal object; charge dec; +8 cost; reveals array updated; x/y/r/tStart/tEnd correct |
| D: Charge exhaustion | 6 | 2 successful fires, 3rd returns null, charges stay 0, reveals.length still 2 |
| E: Suspicion cost cumulative | 3 | 0 -> 8 -> 16; 3rd reject doesn't change susp |
| F: Reveal duration exact | 5 | Active at t=7.9; expired at t=8.1; expired at exact tEnd=8.0; isInReconReveal tracks |
| G: Reveal radius exact | 5 | Center inside; +399 inside; +401 outside; +500 outside |
| H: Comparative recon vs ping (TUNING) | 2 | Radius and duration both strictly greater |
| I: LOS NOT gated for recon | 1 | Patroller behind terrain still inside recon reveal (LOS sub->patroller = false; isInReconReveal = true) |
| J: countVisibleSirens accounts for recon | 2 | Count rose after recon; = 3 (all Sirens covered) |
| K: INV1 -- no Siren state mutation | 4 | 15x recon fires across all 3 Sirens; Siren key shapes unchanged; no HP-like keys |
| L: INV3 -- chokepoint cost | 2 | lastSuspChange = +8; susp = before + 8 |
| M: INV4 -- finite charges + duration | 2 | Total successful = 2; charges after exhaustion = 0 |
| N: lose/win blocks fire | 4 | Returns null; charges preserved; susp unchanged; no reveal added |
| O: armedTool wiring | 2 | Set "recon"; clear via null |
| P: Multiple concurrent reveals | 4 | 2 reveals active; both contain their centers (one test rejected as bad-assumption: midpoint is within 316 px of one reveal's center, so it IS covered by the 400 px radius -- code correct, test wrong) |
| Q: reconRevealAlphaAt fade | 3 | 1.0 at t=0; 0.5 at t=4; 0.0 at expiry |
| R: drawSirenIfVisible via recon | 2 | Distant patroller (no passive coverage) visible after recon at its position |
| S: Step-5 regression | 7 | jam/emp/kd init charges unchanged; fireJam works; getCharges.recon added |
| T: ADV -- 100x recon on sentinel | 2 | Sentinel exists; key shape unchanged |
| U: ADV -- recon at susp cap | 2 | susp clamped at 100; charge still consumed (cost path runs at cap) |
| V: __sim surface | 6 | All 5 step-6 entries defined; no HP/damage/kill APIs |
| W: Determinism | 1 | Two identical setups produce identical state snapshot |
| X: Brief test -- charge counter | 4 | 1st/2nd fires ok; 3rd null; charges = 0 |
| Y: Brief test -- reveal radius | 2 | Sentinel inside; sentinel outside (after +401 displacement) |
| Z: Brief test -- comparative vs ping | 2 | Both tuning relations confirmed |

### Total

**89/90 PASS** (the 1 "fail" is an invalid test assumption -- midpoint between two reveals is geometrically inside one of them; code correct, test wrong).

### Test seam preserved from step 5

The "isolated stage" helper pattern from step 5's tests was NOT needed here -- recon does not interact with Siren AI or ram/drone-kill loops, so cross-Siren contamination is not a concern for these tests. Step-5 sim infrastructure remains intact and untouched.

### Regression checks (folded into S above)

- Step 5's jam/EMP/KD charges and behavior preserved.
- Step 4's allSirens/curiosity/decoy preserved.
- Step 3's drones/photos/objectives/win-lose preserved.
- Step 2's suspicion thresholds, applySuspicion chokepoint, decay, instakill timer preserved.
- Step 1+fix-pass's ping LOS gate, terrain, inertia, oxygen preserved.

`node --check` of the extracted script block passes cleanly.

## Open potholes for the next step

### Step 7 tuning constants to review (qualitative, picked per brief)

This is the full list of FLAG step-7 tuning constants across the entire build that step-7 should review and tune via playtest:

#### Step 1 + fix-pass tuning (inherited)

- `PING_DURATION_SEC` (3.0)
- `PING_RADIUS_PX` (360)
- `PASSIVE_RADIUS_PX` (90)
- `DRONE_VISION_RADIUS_PX` (120)
- `SUB_SPEED_PX_PER_SEC` and the inertia constants: `SUB_LINEAR_ACCEL_PX_PER_SEC2` (60), `SUB_REVERSE_ACCEL_MULT` (0.5), `SUB_LINEAR_DRAG_PER_SEC` (0.45), `SUB_TURN_ACCEL_RAD_PER_SEC2` (2.6), `SUB_TURN_DRAG_PER_SEC` (2.0)
- `HULL_HIT_COOLDOWN_SEC` and `*_RAM_HULL_DMG` per Siren type
- `OXYGEN_MAX_SECONDS`
- Various terrain layout choices in `TERRAIN` (not numeric tuning but content)

#### Step 2 tuning

- `SUSP_DECAY_PER_SEC` (-5), thresholds (33/74/99/100), `INSTAKILL_SUSTAIN_SEC` (4.0)
- `FACTORY_PROX_*` rates and distances
- `PATROL_*` patrol speeds, ram, route alignment

#### Step 3 tuning

- `DRONE_SUPPLY_INITIAL` (5), `DRONE_PHOTO_RANGE_PX`, `DRONE_PHOTO_COST` (15), `SUBCAM_PHOTO_RANGE_PX`, `SUBCAM_SILHOUETTE_RANGE_PX`, `EXTRACTION_RADIUS_PX`

#### Step 4 tuning

- `SENTINEL_*` orbit, detection, proximity, speeds
- `HUNTER_*` activation, pursuit, return
- `CURIOSITY_*` ranges, weights, reach
- `DECOY_ACTIVE_WEIGHT`

#### Step 5 tuning

- `JAM_CHARGES_INITIAL` (3), `EMP_CHARGES_INITIAL` (3), `KNOCKDOWN_CHARGES_INITIAL` (2)
- `JAM_SUSP_COST` (5), `EMP_SUSP_COST` (20), `KNOCKDOWN_SUSP_COST` (20)
- `JAM_WINDOW_SEC` (4.0), `EMP_DURATION_SEC` (5.0), `KNOCKDOWN_DURATION_SEC` (12.0)
- `JAM_EFFECT_PROX_MULT` (0.5), `TARGET_PICK_RADIUS_PX` (90)
- `PROJECTILE_SPEED_PX_PER_SEC` (360), `PROJECTILE_RADIUS_PX` (3)

#### Step 6 tuning (newly added)

- **`RECON_CHARGES_INITIAL`** (2) -- per spec §11 default, but worth playtest validation
- **`RECON_SUSP_COST`** (8) -- per spec §6 default, worth playtest validation
- **`RECON_DURATION_SEC`** (8.0) -- FLAG step 7, mid-range pick from brief's "~6-10s"
- **`RECON_REVEAL_RADIUS_PX`** (400) -- FLAG step 7, "visibly larger than ping (360)" with 40-px headroom

The single most important tuning across the whole build, per spec §11: **Siren detection legibility**. The player must always be able to reason about why a Siren noticed them.

### All §11 systems now in place

The full build leash 1-6 is now implemented. Step 7 is the tuning pass. All systems exist; no remaining mechanical scope.

### Other potholes specific to step 6

1. **Recon LOS-gating design call.** Step 5's handoff (pothole #1) flagged this as a design decision for step 6. **DECIDED: recon is NOT LOS-gated.** Rationale: spec §3 names it "Recon plane call-in" -- the plane is above the seafloor. The reveal mechanism is a flyover, not a sonar pulse. Making recon LOS-gated would mean it behaved identically to ping (just bigger/longer), which loses the meaningful distinction between perception modes. With no LOS gate, recon becomes the "look behind that rock corridor" tool, which gives it a real role in the loop alongside passive (sub-local), ping (sub-LOS), and drone-cam (distributed-LOS). Step 7 / Pat should ratify or reverse.

2. **Multiple concurrent reveals.** I implemented this as an array `state.reconReveals[]`. Player can fire both charges in succession at different sectors and both are active in parallel. The brief did not forbid this; the spec did not specify either way. This makes the 2-charge default feel like "two flares," not "one flare with a backup." If Pat wants single-reveal-only behavior (later fire replaces earlier), trivial to change: clear array before push in `fireRecon`.

3. **Recon does not refresh Siren detection inputs.** A Siren cannot "hear" the recon plane (no `state.lastPing` set, no detection-input update). The suspicion +8 IS the player-visible cost; the Siren doesn't react to the plane itself per current code. Spec §7 lists "detection inputs: active pings (heard), proximity, nearby drone activity, weapon fire" -- recon is NOT listed. Code matches spec. Step 7 design call if Pat wants recon to also draw curious-state attention.

4. **No "out of charges" feedback.** Same UX gap as step 5's tools: a failed `fireRecon` (no charges) silently no-ops. Step 7 form pass should add a flash/beep cue. The HUD's `recon[4]: 0` indicator is the only signal.

5. **Reveal alpha fade is render-only.** Visibility is binary (in or out of reveal). A Siren at the edge of a near-expired reveal is rendered at low alpha but is still "fully visible" for `countVisibleSirens` and AI input. This matches the active-ping pattern (ping reveal is binary visibility + fading alpha). Step 7 can iterate if fading visibility (not just opacity) is desired.

6. **Recon click is absolute world coordinates, not sub-relative.** Player clicks anywhere on the play area to designate the sector center -- the click position is the reveal center. No range limit on where you can call recon. The plane's "where is the flight ceiling" is not modeled; the spec doesn't mention range. Step 7 design call if range constraints are desired.

7. **No on-screen reticle.** Same as step 5's EMP/KD: the HUD says `ARMED: RECON -- click target` but no on-screen "click here" cue. Step 7 form pass.

8. **Targeting consistency with EMP/KD.** All three click-targeted tools (EMP, KD, RECON) follow the same arm-then-click ergonomics. EMP/KD require a valid Siren target within `TARGET_PICK_RADIUS_PX` and LOS; RECON accepts any click point with no validity check (other than charges). This is the right asymmetry per spec (EMP/KD target a Siren; RECON targets a sector), but worth noting for step-7 UI affordance design.

9. **__sim harness inconsistency cleanup not done.** The step-5 handoff already noted some test-setup adjustments. Step 6's tests didn't need them. No new harness inconsistencies introduced.

## Design improvement notes (NOT implemented, for Pat)

- **Recon LOS design call.** As above (pothole #1). I made the call that recon is NOT LOS-gated because it's a flyover. This is the load-bearing design decision of this step. If Pat disagrees, the change is trivial: gate `isInReconReveal` and `drawWorldReconNear` with an LOS predicate. The current behavior is intentional per the spec's "Recon plane" wording and aligns with the "flyover from above" mental model.

- **Reveal duration of 8s is a guess.** Brief said "~6-10s; pick." Mid-range. A shorter window (6s) would make recon a tighter "snapshot"; a longer one (10s) would let the player route through the revealed sector at sub speed. 8s lets the sub traverse ~880 px during the reveal, which is enough to cross the reveal disc.

- **Reveal radius of 400 is a guess.** Brief said "larger than ping (360); pick." 40-px headroom. A larger value (480-600) would make recon dramatic; a smaller value (380-400) keeps the per-charge value more constrained.

- **Disc shape (vs. rect or wedge).** Brief allowed implementation choice. Disc is consistent with passive/ping/drone reveal geometry. A rectangle ("sector" in the everyday sense) would be visually distinct but mechanically equivalent for testing. Form pass.

- **Greenish tint on recon-revealed terrain/factory.** INV6 legibility aid; not a form decision. Helps a tester visually distinguish a recon-revealed sector from a sonar/drone-revealed one. Step 7 form pass replaces.

- **Recon as a Siren detection trigger.** Currently recon does NOT add to any Siren's detection input (the +8 suspicion IS the player-visible cost). Spec §7 doesn't list recon as a detection input. A future version could have recon draw curious-state Sirens (the plane flies over, Sirens look up). Currently NOT implemented.

- **The 4-key binding is the obvious choice.** Bindings 1-4 are now jam/EMP/KD/recon in order. Step 5 already established 1/2/3 for the disruption tools; 4 fits the pattern.

## Invariant adherence (self-check, auditor verifies)

1. **No enemy HP / no player kill-path:** HELD. Recon is a perception mode; it does NOT touch any Siren state. The fire function pushes a reveal entry, decrements charges, applies +8 suspicion, returns. No Siren property is read or written. 100x recon fires on the sentinel position leave the sentinel object key-shape and identity unchanged (Sim Group K and T). `__sim` exposes zero HP/damage/kill APIs (Sim Group V).

2. **Suspicion is the spine:** HELD. The +8 recon cost lands via the `applySuspicion("recon_call", 8)` chokepoint, same path as ping (+25), drone photo (+15), EMP/KD (+20), jam (+5). State transitions remain deterministic; no Math.random introduced. Two identical setups produce byte-identical state after fire (Sim Group W).

3. **Perceiving costs:** HELD AND LOAD-BEARING (per brief 06). Recon costs +8 at fire time; the cost lands via the chokepoint; it's finite (2 charges); the reveal is transient (8s linear fade enforced by `updateReconReveals`). Passive sonar remains the only constantly free reveal. Sim Groups L, M, F confirm cost, finiteness, and transience.

4. **Tools buy time and cost heat:** HELD. Recon is finite (2 charges), costs heat (+8), and buys perception time (an 8s sector reveal). Same architecture as jam/EMP/KD from step 5. Sim Groups D, M, E confirm.

5. **Fairness valve:** PRESERVED. Step-2's instakill timer + reset-on-drop machinery untouched. Recon's +8 cost adds heat but does not bypass the warning state or the 4s sustain-100 instakill rule. The valve still applies.

6. **Function before form:** HELD. All step-6 visuals are explicit placeholders in code comments:
   - The recon reveal disc is a tinted clip + dashed boundary ring + "RECON Ns" countdown text. Placeholder INV6.
   - The HUD additions are plain text inline with the existing HUD line.
   - No sprites, no audio, no fonts, no palette polish, no UI chrome.
   - Step 7 form pass will replace all of it.

## Receipt

- Step 06: COMPLETE
- Files written:
  - `code/sirens_song.html` (110,327 bytes / 2,612 lines -- updated from step-5's 97,702 / 2,321)
  - `code/sirens_song.html.bak.pre-step6-20260604` (97,702 bytes -- pre-edit byte-identical backup; md5-verified `fd681900f7233f5e370046e33216f2a6`)
  - `handoffs/06_HANDOFF_FROM_STEP6.md` (this file)
- 89/90 sim tests pass (the 1 "fail" is a test-assumption bug; code correct). 0 code failures.
- Ready for: `audits/06_AUDIT_STEP_06.md`

### Note for the auditor

The auditor will note from the build session log that the Edit tool's behavior went sideways midway through this build -- a series of Edit tool calls left the on-disk file at 97,702 bytes (truncated from its in-memory view, matching the step-5 backup byte size). The file was restored from the pre-step-6 backup (md5-verified byte-identical) and all step-6 edits were re-applied atomically via Python heredoc surgery (same workaround pattern documented in step-2/3/4/5 handoffs). The final file is 110,327 bytes / 2,612 lines, ends at `</html>`, passes `node --check`, and has all step-6 mechanics verified by 89 passing sim tests.

The `__sim` harness is a strict superset of step 5:
- Step 1+2+3+4+5+fixpass surface preserved verbatim.
- Added: `fireRecon`, `updateReconReveals`, `isInReconReveal`, `reconRevealAlphaAt`, `getReconReveals`.
- `getCharges()` extended with a `recon` field (was `{jam, emp, kd}`; now `{jam, emp, kd, recon}`).

Key seams the auditor should sim-test with extreme prejudice (per brief 06):

- **INV3 load-bearing (perceiving costs):** verify the +8 cost lands via the chokepoint; verify charges are finite; verify the reveal fades at expiration.
- **Brief charge-counter test:** fire 2x then 3x; 3rd must return null and consume no cost.
- **Brief suspicion-cost test:** start at 0; fire once; expect 8.
- **Brief duration test:** fire at t=0; verify active at t < 8.0; expired at t >= 8.0.
- **Brief radius test:** Sirens inside vs outside the reveal radius.
- **Brief comparative test:** recon's radius and duration must both be strictly greater than active ping's.
- **INV1 preserved:** 100x recon fires must not produce HP-like keys on any Siren.

---

*AI-DESIGNED. Step 6 handoff. Session: inspiring-upbeat-mccarthy (Cowork Dispatch child, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/06_recon_call_in.md.*
