# Step 03 handoff -- drones_camera_objectives

## What I built

On top of steps 1+2 (sub / sonar / terrain / hull / oxygen / suspicion / Patroller):

### Factory + objectives
- **FACTORY** rectangle hand-authored at (730, 240, 180w x 200h). Placeholder rect with "FACTORY" label (INV6). Treated as terrain for sub collision (hugging the wall takes hull damage just like rock).
- **3 required photo objectives** (`OBJECTIVES`):
  - `silhouette` at (820, 340) — sub-cammable from distance (320 px range); drone-cammable too.
  - `bays` at (800, 260) — near factory top.
  - `power_core` at (855, 410) — deep interior, the hardest objective.
- **Bonus objective** (`BONUS_OBJECTIVE`): `siren_closeup` — captured by a drone within 100 px of the Patroller. Bonus is NOT required for the win per spec §8.

### Factory proximity suspicion (the deferred §6 term)
- New function `factoryProximityGainPerSec(x, y)` returns rate based on distance to the **nearest edge** of the factory rect:
  - ≤140 px → **+3/s** (NEAR)
  - ≤260 px → **+2/s** (MID)
  - ≤420 px → **+1/s** (FAR)
  - else → 0
- Integrated into the decay block as a `netRate` term. Ping window pauses decay (preserved from step 2) but factory proximity gain still applies during the ping — factory-hugging-while-pinging is the worst-case combo, which feels right.
- Sim-verified: 0/100/200/350/500 px from factory return 3/3/2/1/0 respectively.

### Drones (spec §3 + §4)
- `state.droneSupply` starts at 5 (spec default).
- **Left-click** anywhere = deploy a new drone (spawns at sub position, walks to clicked destination). Refuses on terrain, factory, or out-of-bounds — and does NOT consume supply on refusal. Each drone gets a sequential `id`.
- **Right-click** = redirect the nearest alive drone to that position. Free per spec §3.
- **TAB** = cycle selected drone (for photo trigger).
- **F** = drone photo with selected drone.
- Drone speed = 110 px/s (faster than sub's 80; FLAG step 7).
- Drone vision radius = 120 px (FLAG step 7); reveals terrain + factory + objectives + Patroller within the radius. Free at deploy/move per spec §3 table.

### Drone destruction
- Drones die instantly on contact with terrain OR factory OR out-of-bounds while moving.
- Drones die on Patroller contact when suspicion ≥ ALERT (34+). At CURIOUS the Patroller does not destroy drones (curiosity/decoy behavior arrives step 4).
- Dead drones stay in the array (frozen position, `alive: false`); not rendered. Supply does NOT refund on death.
- Selected-drone garbage collection: if the selected drone dies, the selection rolls to the first alive drone (or null if none remain).

### Sub fallback cam (spec §2 + §8)
- **G** = sub-cam photo. Tries each uncaptured required objective in iteration order.
- Range:
  - `silhouette` → 320 px (comfortably sub-cammable from distance, per spec §8).
  - `bays` / `power_core` → 70 px (point-blank — "near-suicidal but possible," per spec §8).
- No flat suspicion cost on sub-cam shot. The cost is the factory-proximity exposure required to close that range (spec §6).
- Sub-cam does NOT award the bonus Siren close-up. The bonus is drone-only (spec §8: "Siren at close range" + drone is the photogenic platform). Logged as Pat-decision; alternate interpretation is sub-cam-also-awards-bonus.

### Win / lose
- **Win:** all 3 required photos captured AND sub center within 30 px of EXTRACTION (hand-authored at (70, 70), opposite corner from factory). Renders "EXTRACTED -- RUN COMPLETE" overlay with photo count + bonus flag. **R** restarts.
- **Lose conditions unchanged** from prior steps: sunk / suffocated / vaporized.

### HUD additions
Three lines now. New line 2 + line 3 fields:
- `factory_prox: +N/s` (or `0`)
- `drones: K alive / M supply`
- `selected: dN` (or `(none)`)
- `photos: 1/3 req, bonus: no`
- `extraction: need 2 more required photo(s)` / `ready -- head to EXTRACTION (Npx)` / `EXTRACTED`

## State of the file
- File: `code/sirens_song.html`
- Size: 41,825 bytes / 1,119 lines
- Lines added: ~486 (step 3 vs. step 2's 633)
- Lines modified: ~20 (HUD, render, update integration, input handlers)
- Lines removed: ~0 (step 2 logic preserved verbatim)
- Backup of pre-step-3 state: `code/sirens_song.html.bak.step2-pre-step3` (23,523 bytes / 633 lines).

## Spec sections implemented
- **§2 sub fallback camera** — `trySubCamPhoto()`: silhouette 320 px range; close objectives 70 px range; no flat cost.
- **§3 drone-cam row** — drones deployed by left-click; vision radius local; deploy/move free; photo cost +15.
- **§4 Drones** — Scout (vision) and Photograph implemented. Decoy is step 4. Supply 5; finite; expendable. Sub-cam fallback covers drone depletion (no hard-stall — sim-verified).
- **§6 Suspicion** — drone-photo +15 source wired through `applySuspicion`. Factory proximity +1..+3/s integrated into decay block as `netRate`. Sub-cam shots carry no flat cost (the proximity term is the cost).
- **§8 Objectives & win/lose** — 3 required (silhouette/bays/power_core) + 1 bonus (siren_closeup). Win = all required + extraction. Lose conditions inherited. Two ways to take any shot per spec. Objectives spread across the site so the route generates the gauntlet.
- **§10 Fairness** — preserved from step 2. Factory proximity adds gain but never bypasses the warning window. Drone depletion no longer hard-stalls (spec §4 + §8 explicit ruling).
- **§11 step 3** — fully covered. No Sentinel/Hunter/curiosity (step 4). No tools (step 5). No recon (step 6). No Siren-near-sub scaling term (step 4 once multi-Siren).

## Tuning values used (with spec citation)

Step 1 + 2 values preserved verbatim. Step 3 additions:

| Name | Value | Source |
|---|---|---|
| `DRONE_SUPPLY_INITIAL` | 5 | spec §4 / §11 default |
| `DRONE_PHOTO_COST` | 15 | spec §3 / §6 / §11 |
| `DRONE_SPEED_PX_PER_SEC` | 110 | not in spec; brief says "your call". **FLAG step 7.** |
| `DRONE_VISION_RADIUS_PX` | 120 | not in spec; brief says "your call". **FLAG step 7.** |
| `DRONE_RADIUS_PX` | 5 | placeholder body (INV6) |
| `DRONE_PHOTO_RANGE_PX` | 90 | not in spec; brief says drones favored for bays/power core/Siren close-up. **FLAG step 7.** |
| `DRONE_ARRIVAL_TOLERANCE_PX` | 4 | arrival epsilon |
| `DRONE_SIREN_BONUS_RANGE_PX` | 100 | not in spec ("close range" qualitative). **FLAG step 7.** |
| `SUBCAM_PHOTO_RANGE_PX` | 70 | brief: sub-cam close range is "near-suicidal but possible" for bays/power core. **FLAG step 7.** |
| `SUBCAM_SILHOUETTE_RANGE_PX` | 320 | spec §8: silhouette "comfortably sub-cammable from distance". **FLAG step 7.** |
| `FACTORY_PROX_NEAR_PX` | 140 | spec §6 qualitative "scales with closeness"; +3/s tier. **FLAG step 7.** |
| `FACTORY_PROX_MID_PX` | 260 | same. **FLAG step 7.** |
| `FACTORY_PROX_FAR_PX` | 420 | same. **FLAG step 7.** |
| `FACTORY_PROX_NEAR_RATE` | 3 | spec §6 max |
| `FACTORY_PROX_MID_RATE` | 2 | spec §6 mid |
| `FACTORY_PROX_FAR_RATE` | 1 | spec §6 min |
| `EXTRACTION_RADIUS_PX` | 30 | not in spec; needs to be a clear marker the sub can clearly center on. **FLAG step 7.** |

FACTORY position (730, 240, 180w, 200h), OBJECTIVES positions, EXTRACTION position (70, 70): hand-authored placements per spec §11 "ONE hand-authored site. No proc-gen." Placements chosen to spread objectives across the play area so the player traverses the site (per spec §8 "objectives spread across the site so suspicion escalates across a route, and the return leg is the gauntlet.").

All non-default values FLAG-marked for step 7.

## Sim tests run

Methodology: extracted `<script>` block to `/tmp/sirens_step3.js`, stubbed `document`/`window`/`performance`/`requestAnimationFrame`, loaded via `new Function(...)`, drove `window.__sim` API directly.

### Main pass (64 tests, all PASS)

| Group | Count | Coverage |
|---|---|---|
| TUNING sanity | 5 | DRONE_SUPPLY_INITIAL, DRONE_PHOTO_COST, factory rate tiers |
| Factory proximity function | 7 | center (+3), far (0), inside-rect (+3), 100/200/350/500 px outside |
| newState defaults | 5 | droneSupply, drones[], 3 required objectives, bonus uncaptured, winState false |
| Drone deploy | 6 | success, supply decrement, spawn-at-sub, target set, selected drone, terrain-deny, OOB-deny |
| Drone movement | 2 | walks toward target, reaches target after 5s |
| Drone redirect | 1 | nearest alive drone retargeted |
| Drone cycle | 3 | selection cycles through alive drones |
| Supply exhaustion | 3 | 5 deploys ok; 6th refused; supply=0 holds |
| Drone photo | 6 | captures objective, marks captured, +15 suspicion, out-of-range null, no false capture |
| Sub-cam photo | 4 | silhouette from distance, no flat cost, far-from-everything null, close range captures |
| Factory proximity gain on suspicion | 3 | net rate calc; clamp at 0; gain runs during ping (no decay) |
| Win condition | 2 | all required + at extraction = win; 2/3 + extraction = no win |
| Drone destruction | 4 | Alert+ Patroller kills drone; Curious does not; terrain kills; factory kills |
| Drone-depletion-not-stall | 4 | 5 dead drones + sub-cam runs the rest + extraction = win |
| Bonus photo | 3 | drone near Patroller captures bonus; marked; +15 cost |
| Invariant checks | 4 | no kill/damage/hp/attack API; Patroller has no HP fields; no Math.random; no banned step-4/5/6 symbols |
| Restart | 2 | newState fresh after win |

### Scenario pass (18 tests, all PASS)

| Scenario | Coverage |
|---|---|
| Step 2 regression: Patroller deviation | switches to deviating at Alert+; eventually returns to patrolling |
| Full drone-mission win | 3 drones each get an objective; suspicion decays during transit; sub reaches extraction; win fires |
| Spammy vaporized | 4 stacked pings → 100; re-pinging every 1s sustains; vaporized within ~5s |
| Fairness valve (held 100 for 3.5s, then release) | not vaporized at 3.5s; decay after release prevents vaporized |
| Factory-near pure decay | 50 suspicion + 10s at 50px from factory → 30 (net -2/s) |
| Factory-near + ping | 0 → +25 (ping) → +9 (3s of +3/s during ping window) → 34 |

**Total: 82 sim tests pass headlessly. 0 failures.**

Three initial scenario tests appeared to fail; on inspection two were test-design artifacts (placed sub inside factory rect, collision pushed sub outside, expected proximity-gain math broke) and one was a sub-start-position-was-MID-not-FAR oversight. Re-tested with corrected setup; behavior is correct.

## Open potholes for the next step

1. **Siren-near-sub scaling suspicion term still deferred** (per brief). The decay/gain integration site is `update()` at the `netRate` block. Step 4 should add a `sirenProximityGainPerSec(sub, sirens)` term that accumulates per-Siren scaling-with-closeness rates and folds into `netRate`. Same shape as `factoryProximityGainPerSec`.

2. **Bonus photo currently checks only the Patroller.** When Sentinel and Hunter exist (step 4), `tryDronePhoto`'s bonus check needs to iterate all Siren instances. Easy fix: replace `state.patroller` with `state.sirens.find(sir => closeEnough)`. Currently sim-verified to work against the Patroller; will not break when more Sirens are added but will silently miss the bonus opportunity against a Sentinel/Hunter close-up.

3. **Drone destruction conditions are a step-3 invention.** Brief says "your call, document." Chosen behavior: terrain/factory/OOB always kills; Patroller-contact kills only at Alert+. The Curious-safe rule preserves the spec's "Sirens drift to investigate ... slow; non-lethal approach" — at Curious, a Siren brushing past a drone shouldn't gun it down. Step 4 may want to refine: Curious Sentinel passing a drone should probably still be safe; Hunter at Alert by definition is hostile. Brief's `Sentinel/Hunter` types will inherit the same Alert+ rule unless overridden.

4. **Drone deploy denies on terrain/factory/OOB without consuming supply.** This is a UX call. The brief mentions destruction conditions, not deploy-validation. Alternative reading: deploy on terrain consumes the supply AND instantly destroys the drone. Picked the player-favorable "denial" reading to avoid punitive misclicks. Step 7 ratification: should a misclick on terrain cost a drone?

5. **Tuning values for drone vision / speed / photo range / sub-cam range are all qualitative-bound picks.** Brief says "your call, document":
   - Drone speed 110 (slightly faster than sub 80) — feels right for "deployed asset that can scout ahead."
   - Drone vision 120 — bigger than passive sonar (90) so drones meaningfully extend sight; smaller than ping (360) so drones are tactical not strategic.
   - Drone photo range 90 — wider than sub-cam (70) so drone is the smart play per spec §8.
   - Sub-cam range 70 (close) / 320 (silhouette) — silhouette comfortably-from-distance per spec; close objectives "near-suicidal."
   - Drone-Siren bonus range 100 — close enough to feel "close-range" but achievable.
   - Extraction radius 30 — clear marker, easy to center on.
   All FLAG for step 7 playtest tuning.

6. **Extraction has no win-eligibility lockout.** Currently if the sub enters the extraction zone before capturing all 3 required photos, nothing happens — must capture all 3 THEN enter zone. This is the literal spec reading. Brief was silent on whether entering empty-handed should display a feedback message. Current HUD line says "need N more required photo(s)" — sufficient.

7. **Factory proximity uses nearest-edge distance.** Inside the factory rectangle returns distance 0 (treated as NEAR). This is correct conceptually (you cannot be "more inside" the factory). The sub can't actually be inside the rect because collision pushes it out — but a drone can be inside (per the destroyed-on-entry rule, briefly mid-tick). Side note: factory proximity gain is computed on **sub** position, not drone position — drones do not draw suspicion through proximity. Spec is silent; this matches "factory proximity" reading literally as the sub.

8. **Patroller route does NOT route around the factory.** Step 2 hand-authored the route generically; the factory is on the right side of the play area where waypoints (600,140), (720,200), (780,240), (780,510) are. The Patroller threads near the factory edges but does not "guard" it specifically. Step 4 (when Sentinel arrives as a factory guard) will own this — Sentinel naturally guards a single objective per spec §7.

9. **No Patroller-vs-drone visibility distinction.** A Curious Patroller passing a deployed drone does not react in step 3. Spec §7 curiosity behavior ("any Siren in Curious state will move to investigate a decoy drone") arrives in step 4. The drone destruction rule (Patroller kills drones at Alert+) is the only Patroller-drone interaction in step 3.

10. **The win-state interaction with active ping**: if the sub triggers the win exactly during an active ping, the warning text is suppressed (covered by the win overlay). Lose-state takes precedence over win-state in the keydown handler (both fire R to restart, so functionally identical). Edge case sim-verified clean.

## Design improvement notes (NOT implemented, for Pat)

- **Sub-cam silhouette range = 320 px feels generous.** It makes the silhouette objective close to a freebie — drift within ~300 px of the factory center, hit G, done. Step 7 tuning may want to drop this to 200–250 to force more meaningful approach. Alternative: silhouette captures only when the FULL factory is in frame (sub at ≥250 px AND aligned), requiring a positioning skill check. Current implementation is the simpler "in range = capture" reading.

- **Drone control scheme: left-click deploy, right-click move, TAB cycle, F photo.** Heavy on the keyboard for photo. Alternative: photo-button on the drone (mouseover the drone, click). The current scheme is simpler to test headlessly via `__sim` calls, and matches the spec's "point-and-click" minimum. Step 7 form pass may iterate.

- **Bonus photo: drone-only currently.** Pat could rule that the sub-cam can also award the bonus if it gets close to a Siren (≤ some range). That's a "sub-cam at point-blank to a Siren" act that's narratively a great moment of bravado. Not implemented; flagged.

- **Drone deploy spawning at sub vs. spawning at click.** Currently the drone spawns at the sub (per spec §4: "launched from a torpedo tube") and walks to the click. Alternative: instant-deploy at click (it's a torpedo, not a slow drone — the torpedo carries the drone to position). Current implementation matches the spec phrasing literally; faster-deploy might feel better.

- **No drone recall.** Once deployed, drones stay until destroyed. Spec §4 doesn't mention recall. Step 7 may want a "recall drone to sub" key — but that ratchets up player ops, which may or may not be desired.

## Invariant adherence (self-check, auditor verifies)

1. **No enemy HP / no player kill-path:** HELD. Patroller still has no HP / no `damage()` / no kill state. Drones cannot damage the Patroller (no API exists). Photos don't damage anything — they flip a `captured` flag. Adversarial sim: chain 30 pings, place drone overlapping Patroller for 30 seconds at Curious; Patroller unchanged. Sim filter for kill/damage/hp/attack returns empty.

2. **Suspicion is the spine:** HELD AND EXTENDED. Drone-photo +15 goes through `applySuspicion` (the same chokepoint as ping +25). Factory proximity goes through `netRate` in the existing decay block. No scripted aggression added. No RNG. Patroller behavior unchanged from step 2 (still derives from `suspicionState`).

3. **Perceiving costs:** HELD. Passive sonar still free (only constant per spec). Active ping +25 unchanged. Drone deploy/move free (spec §3 explicit). Drone PHOTO +15 (spec §6). Sub-cam photo no flat cost — proximity terms drive (spec §6). No fourth free reveal path exists.

4. **Tools buy time and cost heat:** N/A YET — drones are perception platforms in step 3, not tools in the spec §5 sense. Step 5 adds jam/EMP/knockdown which will use the same `applySuspicion` chokepoint.

5. **Fairness valve:** PRESERVED. Step 2 instakill-sustain logic unchanged (timer accumulates while suspicion == 100, resets the instant suspicion < 100). Factory proximity only adds gain; the timer interaction is unchanged. Sim verified: held 100 for 3.5s + release = survives; held 100 for >4s = vaporized. Drone depletion does NOT hard-stall (sub-cam covers the route — sim verified end-to-end win with all drones dead).

6. **Function before form:** HELD. Factory = labeled rect. Objectives = labeled 10x10 markers with `[ ]` / `[X]` text indicator. Drones = small circles with `dN` id text. Extraction = labeled circle marker. HUD remains plain monospace, three lines now. No sprites, no palette decisions beyond placeholder color coding (factory pinkish, extraction greenish — testing legibility aids; NOT form decisions).

## Receipt

- Step 03: COMPLETE
- Files written:
  - `code/sirens_song.html` (41,825 bytes / 1,119 lines — updated from step 2's 23,523 / 633)
  - `code/sirens_song.html.bak.step2-pre-step3` (23,523 bytes — pre-edit backup per CGI §M.2 version discipline)
  - `handoffs/03_HANDOFF_FROM_STEP3.md` (this file)
  - `claude_index.md` (updated per CGI §G.4)
- Ready for: `audits/03_AUDIT_STEP_03.md`

### Note for the auditor

The Read tool's display has historically shown phantom content past line 633 for `code/sirens_song.html` (an in-app display artifact, also flagged by the step 2 auditor). The actual file on disk is clean — verify with `wc -c -l` and `node --check` on the extracted `<script>` block. Step 3's file is 41,825 bytes / 1,119 lines, ends at `</html>`, passes `node --check`. Written via bash heredoc (same workaround as step 2) to avoid the Write-tool size-truncation issue.

The `__sim` harness is a strict superset of step 2's. Adds: `FACTORY`, `OBJECTIVES`, `BONUS_OBJECTIVE`, `EXTRACTION`, `factoryProximityGainPerSec`, `distancePointToRect`, `deployDrone`, `redirectNearestDrone`, `cycleSelectedDrone`, `getSelectedDrone`, `tryDronePhoto`, `trySubCamPhoto`. Step 2 + step 1 surface preserved verbatim.

---

*AI-DESIGNED. Step 3 handoff. Session: admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/03_drones_camera_objectives.md.*
