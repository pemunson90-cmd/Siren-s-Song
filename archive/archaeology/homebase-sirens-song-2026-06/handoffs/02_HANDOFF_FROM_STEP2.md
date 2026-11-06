# Step 02 handoff — suspicion_patroller

## What I built

On top of step 1's substrate (sub / sonar / terrain / hull / oxygen):

- **Suspicion scalar** (0..100), single chokepoint API `applySuspicion(amount, sourceTag)` for additive sources; inline dt-scaled decay in `update()`. The `sourceTag` is a deliberate logging seam for future analytics (`active_ping` is the only source wired this step).
- **Active ping suspicion cost wired (+25):** the step-1 `// STEP 2 HOOK` comment is replaced with a live `applySuspicion(25, "active_ping")` call at the ping trigger site (spec §3, §6).
- **Suspicion decay** at -5/sec when not currently inside an active ping window (spec §6, §11). Active-ping window pauses decay so the +25 lands cleanly without being immediately eroded — once the ping fades (3.0s), decay resumes. Per-tick clamp at [0,100].
- **Four threshold states** derived from the scalar via pure function `suspicionState(s)`:
  - `CURIOUS` (0–33), `ALERT` (34–74), `WARNING` (75–100).
  - The Hostile (75–99) and Warning-cue (75+) bands collapse to a single `WARNING` label per spec §6 ("at 75+ an escalation cue fires"). The 100-sustained-≥4s instakill is a consequence inside that band, not a separate state.
- **Fairness valve** (INV5 + spec §6):
  - `instakillTimer` accumulates dt while `suspicion >= 100`, resets to 0 the instant `suspicion < 100`.
  - `loseReason = "vaporized"` fires when timer reaches `INSTAKILL_SUSTAIN_SEC` (4.0s).
  - **Critical ordering note:** instakill check runs BEFORE decay each tick. If decay ran first, suspicion would drop to 99.75 within any tick that included even one decay frame, the timer would never accumulate, and instakill could never fire. By checking the entering-tick value first, "sustained 100" means "100 at the start of ≥4s of consecutive ticks," matching the brief's test ("force to 100, hold for 4.1s → dies"). The natural game loop produces this when the player adds suspicion faster than decay (more pings, etc.). Stop the gain → decay drops below 100 → timer resets → player lives. That IS the fairness valve.
- **Warning overlay** in the canvas (red "WARNING" text at top center) when `suspicion >= 75`. When at 100, an additional yellow "instakill imminent — break contact (N.Ns)" line shows the remaining sustain window. Placeholder text only (INV6).
- **HUD additions:** second line shows `suspicion`, derived `state`, instakill remaining (when active), and patroller `(x,y) mode`.
- **ONE Patroller Siren** (spec §7, §11):
  - Hand-authored 10-waypoint loop, predictable; verified clear of all terrain rects with 14px body radius (0 clip-points across 200 samples per segment).
  - Speed: 40 px/sec at Curious; ×1.6 (= 64 px/sec) at Alert+. "Faster" per spec §7.
  - Mode `"patrolling"`: follows the route, advances on waypoint arrival, loops.
  - Mode `"deviating"`: Alert+ ONLY, with a valid `lastPing`. Heads toward the last-known ping origin. On arrival (within `PATROL_DEVIATION_REACH_PX = 60`), clears `lastPing.valid`, resumes patrol from the nearest waypoint. Below Alert, never deviates regardless of ping memory (spec §7: "Deviates only at Alert+").
  - **No HP**, no `kill()`, no `damage()` API on the patroller. INV1 held trivially — no surface exists to break it.
  - Behavior keys off `suspicionState()` (pure function of the scalar), no hardcoded aggression timer, no RNG. INV2 held.
- **Patroller-sub contact at Alert+** (spec §6 "ram sub"):
  - Reach = sub radius + patroller radius (22px); on overlap, hull -= 1.
  - Reuses the step-1 `HULL_HIT_COOLDOWN_SEC = 0.6` so one contact event doesn't drain all hull instantly (INV5 fairness).
  - At Curious (below Alert), zero damage even on overlap.
  - Hull→0 from Patroller still produces `loseReason = "sunk"` (not "vaporized") — the rule is "the proximate cause names the death."
- **`lastPing` memory:** captured on every `tryActivePing()` call. Patroller detection input per spec §7 ("active pings (heard)... no hidden detection"). Cleared when the Patroller satisfies the deviation.
- **New lose state:** `loseReason = "vaporized"` (spec §8 "sub vaporized"). Render shows "you lost (vaporized — Siren strike)" with the standard "press R to restart" prompt.
- **Patroller rendering:** placeholder blob (14px circle) with text label `PATROLLER`. Visible only when within the passive sonar radius OR within the active ping reveal. Color hint (green at Curious, red at Alert+) is a legibility aid for testing per the brief — not a form decision. Step 7 form pass owns final visuals.
- **`__sim` harness extended** with: `applySuspicion`, `suspicionState`, `isAlertPlus`, `updatePatroller`, `nearestWaypointIdx`, `PATROL_ROUTE`. Step 1's harness surface preserved verbatim.

## State of the file

- File: `code/sirens_song.html`
- Size: 23,523 bytes / 633 lines
- Lines added: ~210 (suspicion API + threshold logic + valve + Patroller + render/HUD additions + comments)
- Lines modified: ~15 (state init, ping handler, lose-state copy, harness surface)
- Lines removed: ~10 (placeholder comments / hooks now satisfied)

## Spec sections implemented

- **§3 Perception system row 2** — active ping +25 suspicion now live (was a step-1 hook).
- **§6 Suspicion system (the spine)** — scalar 0–100, +25 active-ping source, −5/sec decay (the "not pinging" predicate; other terms deferred), four threshold states, fairness valve, instakill at sustained 100 ≥4s. INV2 + INV5 wired.
- **§7 Sirens (Patroller paragraph only)** — fixed looping route, predictable, deviates at Alert+ toward last-known contact, no HP. INV1 trivially held. Sentinel and Hunter are step 4.
- **§8 Lose conditions** — "vaporized (suspicion max)" now implemented alongside step 1's "sunk" and "suffocated."
- **§10 Fairness principles 1, 2, 4** — death traceable to player decision (ping spam = vaporized; ram during Alert = sunk); no enemy HP; recoverable mistakes via decay + valve.
- **§11 step 2** — fully covered. No drones / cam / objectives (step 3). No Sentinel / Hunter / curiosity (step 4). No jam / EMP / knockdown (step 5). No recon (step 6).

## Tuning values used (with spec citation)

Step 1 values preserved verbatim and continue to apply (HULL_MAX, OXYGEN_MAX_SECONDS, SUB_SPEED_PX_PER_SEC, SUB_TURN_RATE_RAD_PER_SEC, PING_DURATION_SEC, PING_RADIUS_PX, PASSIVE_RADIUS_PX, HULL_HIT_COOLDOWN_SEC, SUB_RADIUS_PX). Step 2 additions:

| Name | Value | Source |
|---|---|---|
| `SUSP_MIN` | 0 | spec §6 |
| `SUSP_MAX` | 100 | spec §6 |
| `SUSP_PING_COST` | 25 | spec §3 / §6 / §11 |
| `SUSP_DECAY_PER_SEC` | 5 | spec §6 / §11 |
| `THRESH_ALERT` | 34 | spec §6 / §11 ("0–33 Curious") boundary |
| `THRESH_HOSTILE` | 75 | spec §6 / §11 |
| `WARNING_THRESHOLD` | 75 | spec §6 "at 75+ an escalation cue fires" |
| `INSTAKILL_SUSTAIN_SEC` | 4.0 | spec §6 / §11 ("100 sustained ≥4s") |
| `PATROL_SPEED_PX_PER_SEC` | 40 | spec §7 ("slow"); roughly half sub speed. **FLAG step 7.** |
| `PATROL_ALERT_SPEED_MULT` | 1.6 | spec §7 ("faster" at Alert+); chosen as noticeable but not unfair. **FLAG step 7.** |
| `PATROL_RADIUS_PX` | 14 | placeholder body (INV6). |
| `PATROL_RAM_HULL_DMG` | 1 | brief §"Tuning values for this step" default. **FLAG step 7.** |
| `PATROL_DEVIATION_REACH_PX` | 60 | wider "satisfied" radius for deviation so a stale ping doesn't stall the Patroller indefinitely. **FLAG step 7 — no spec default.** |
| `PATROL_WAYPOINT_TOLERANCE_PX` | 6 | unused at present (kept for step-7 tuning). Could prune. |

PATROL_ROUTE waypoints (10 of them) are tuning data; they are hand-authored to clear terrain with the 14px patroller body. Adjustments are step-7 concerns.

## Sim tests run

Methodology: extracted `<script>` block to `/tmp/sirens_step2.js`, stubbed `document` / `window` / `performance` / `requestAnimationFrame`, loaded via `new Function(...)`, drove `window.__sim` API directly.

### Main test pass (35 tests, all PASS)

- TUNING sanity (5): SUSP_PING_COST=25, SUSP_DECAY_PER_SEC=5, THRESH_ALERT=34, THRESH_HOSTILE=75, INSTAKILL_SUSTAIN_SEC=4.0.
- Threshold boundaries (7): suspicionState() returns CURIOUS at 0/33, ALERT at 34/74, WARNING at 75/99/100.
- Decay (2): 50→~45 after 1s; 50→0 after 10s (clamp at 0).
- Ping cost (3): single ping → 25; three pings stacked → 75; state at 75 = WARNING.
- Threshold transitions (3): 25→CURIOUS, 50→ALERT, 75→WARNING.
- Fairness valve (2): sustain 100 for 3.9s then drop → NOT vaporized; sustain 100 for 4.1s → vaporized.
- Patroller loop (2): returns near start after one full cycle below Alert; mode stays "patrolling" the whole cycle.
- Patroller deviation (3): switches to "deviating" at Alert+ with valid lastPing; eventually clears lastPing on arrival; resumes patrolling mode after deviation resolved.
- Patroller-sub contact (2): hull drops by PATROL_RAM_HULL_DMG at Alert+ overlap; NO damage at Curious overlap.
- Vaporized lose state (1): instakill produces loseReason="vaporized".
- Lose-state freeze (1): update is no-op while loseReason set.
- INV1 / INV2 / scope (4): no kill/damage/hp/attack API; no Math.random; no drone identifier; no Sentinel/Hunter/EMP/knockdown/jam/recon code paths.

### Adversarial pass (11 tests, all PASS)

- Suspicion clamps at SUSP_MIN (negative apply) and SUSP_MAX (positive apply).
- Mid-valve drop resets instakillTimer; re-spike to 100 after reset starts fresh (player survives).
- Update no-op while loseReason set (even with overlapping patroller).
- Ping no-op while dead.
- lastPing.valid initially false; true after first ping.
- Curious + valid lastPing → patroller stays in "patrolling" mode (spec §7 "Deviates only at Alert+").
- Alert+ patroller moves faster than Curious patroller over identical interval.
- Patroller-killed via hull = "sunk" loseReason (not "vaporized") — proximate cause names the death.

### Terrain-clearance verification (separate sim)

- PATROL_ROUTE waypoints checked against TERRAIN (point-in-rect): 0 hits.
- Route segments sampled at 200 points each, checked against TERRAIN (circle-rect with 14px body): 0 hits.
- Total route length: 1819 px; cycle time at base 40 px/sec: ~45 s.

## Open potholes for the next step

1. **Factory proximity suspicion term is deferred.** Spec §6 lists "factory proximity +1 to +3/sec (scales with closeness)." The decay block in `update()` already has a comment marker: `// factory proximity → step 3 hook`. Step 3 implements the factory entity and adds the proximity term. The cleanest seam: add a new function `applyContinuousSuspicion(dt)` called inside the existing decay block, OR fold the proximity term directly into the decay branch as a subtraction modifier (so net = -5 + 1..3 = -4 to -2 when near factory). The first option is cleaner; the second is more compact.
2. **Siren-near-sub scaling suspicion term is deferred.** Spec §6: "Siren-near-sub +scaling/sec (closer = faster)." This only matters when more Sirens exist (step 4). Same hook point as #1. Suggestion: iterate all Sirens in a list and accumulate the term per-Siren, scaled by distance.
3. **Suspicion decay is paused during the active-ping window** (3.0s). This is a step-2 implementation choice — spec §6 just says "decay when passive (no pinging…)." Pausing decay during the ping makes "the +25 lands" obvious in the UI. An alternative is to not pause (so a ping spikes to 25, then immediately decays 5/sec). Both are spec-legal. Logged for Pat's step-7 ratification.
4. **Patroller speed (40 base, 1.6× at Alert+) is a vibe pick.** Spec §7 qualitative only. Step 7 tunes against the full Patroller-vs-sub feel once drones and objectives exist.
5. **Patroller contact damage = 1 hull per ram event with 0.6s cooldown.** This means a sustained pin against a moving patroller drains hull at 0.6s intervals → 1.8s to lose all 3 hull from full. Brief's default; flag for step 7 — could be too punishing if the player can't always disengage in 0.6s.
6. **Patroller does NOT collide with terrain.** Spec doesn't require Sirens to respect terrain (they're supernatural-tech). I authored the route to thread terrain so visually the Patroller never appears to clip through rocks (verified by sim). But if Alert+ deviation sends it toward a `lastPing` on the far side of terrain, it WILL pathing-cut through. This is a known limitation — adding Siren pathfinding is scope creep for step 2. Note for step 4 (when Sentinel/Hunter join, they'll have the same property) — Pat may want to keep "Sirens cross terrain" as a design feature (creepier; you can't hide behind a rock from one) or flag pathfinding as a step-7 polish item.
7. **Patroller visibility model** mirrors step 1's: visible only inside passive-sonar radius (always) or inside the active-ping reveal (transient). Outside both, the Patroller is invisible — same as terrain. This matches the spec §3 Iron Lung visibility model. A step-7 form decision could add a "sound cue" or "directional hint" when an off-screen Patroller is near, but that's polish.
8. **Warning overlay text** is plain `WARNING` red text + `instakill imminent` countdown — placeholder per INV6. Step 7 form pass owns audio/visual escalation.
9. **State distinction "WARNING" covers both Hostile (75–99) and the 100-sustained band.** The brief says "if suspicion drops below 75 within the ~4s window, instakill does not fire" — but the instakillTimer only counts while at exactly 100. Dropping from 100→99 is enough to reset; you don't need to drop below 75. This matches the spec verbatim ("100 sustained ≥4s") but the brief's wording is slightly looser. Flag for Pat — current implementation is strict (per spec), which is the conservative reading. If the design intent is "drop below 75 to be safe," the timer reset condition needs to change to `< THRESH_HOSTILE` instead of `< SUSP_MAX`.
10. **`PATROL_WAYPOINT_TOLERANCE_PX = 6`** is currently unused. The arrival check uses `dist <= step` (per-tick step size) instead. Kept the tunable for step 7; safe to prune if not wanted.

## Design improvement notes (NOT implemented, for Pat)

- **Patroller route could "patrol AROUND the factory" once step 3 adds the factory.** Right now the route is a generic terrain-threading loop. Step 3 could re-author the route to make the Patroller a meaningful guardian of an objective. Step-3 agent decision.
- **Patroller "lost interest" timer.** When the Patroller deviates at Alert+, it heads to lastPing. If the player has long moved away, the Patroller still goes to the empty spot, then resumes route. That's fine. A future iteration could have the Patroller actively search a small area before giving up — but that's pathfinding scope and step-7 polish.
- **Suspicion-decay rate flex.** Spec says "-5/sec when passive." A design alternative would be variable decay: faster when far from all Sirens, slower when one is near. The brief says the Siren-near-sub term is the spec's mechanism for this. Just noting that "constant -5" is the literal spec; design space exists.
- **HUD line 2 is information-dense.** At step 7 form pass, the suspicion bar + state label + instakill countdown could be repositioned and visualized (a meter bar, a flashing indicator). Plain text works for testing — function before form.

## Invariant adherence (self-check, auditor verifies)

1. **No enemy HP / no player kill-path:** HELD. Patroller has no HP field, no `damage()` API, no killable state. No player weapon exists. `applySuspicion(amount, sourceTag)` is the only suspicion-write API and nothing in code uses it to damage the patroller. Code review confirms zero entries in `__sim` matching `/kill|damage|hp|attack/i`. Adversarial sim "No kill/damage/hp/attack methods exposed" passes.
2. **Suspicion is the spine:** HELD AND NEWLY WIRED. Patroller's mode (`patrolling` vs `deviating`) and speed (`baseSpeed` vs `× alert mult`) both derive from `suspicionState(state.suspicion)`. No hardcoded aggression timer. No RNG anywhere (sim: no `Math.random` in source). All transitions are dt-deterministic. Sub-cam / drones / tools are out of scope for step 2 but will use the same `applySuspicion` chokepoint when they land.
3. **Perceiving costs:** HELD. Passive sonar = free 90px ring (step-1 substrate). Active ping = +25 suspicion (now live; previously a hook). Drone cam / recon land later. There is no third reveal path.
4. **Tools buy time and cost heat:** n/a yet — no tools (step 5).
5. **Fairness valve:** IMPLEMENTED. Decay -5/sec when not pinging. Instakill only when suspicion = 100 sustained ≥4.0s. Drop below 100 → timer resets. Sim tests verify 3.9s-then-drop survives and 4.1s-sustain dies. Patroller contact damage uses the existing 0.6s hull cooldown (one ram event ≠ hull wipe). The WARNING overlay fires at 75+ as the spec's "escalation cue."
6. **Function before form:** HELD. Patroller is a labeled placeholder blob (circle + text). HUD remains plain monospace. Warning text is plain red `WARNING`. Sub triangle, terrain rectangles, ping ring — all unchanged from step 1. No sprites, no palette decisions, no fonts, no sound.

## Receipt

- Step 02: COMPLETE
- Files written:
  - `code/sirens_song.html` (23,523 bytes / 633 lines — updated from step 1's 16,230 / 425)
  - `handoffs/02_HANDOFF_FROM_STEP2.md` (this file)
  - `claude_index.md` (updated per CGI §G.4)
- Files moved to `_scrap-20260604/`:
  - 2 test-write artifacts from sandbox capability verification (`test_write.txt`, `_scrap_big_test_to_clean.txt`) — created when investigating a Write-tool truncation issue, moved aside per CGI no-delete rule.
- Ready for: `audits/02_AUDIT_STEP_02.md`

### Note for the auditor

During the build I hit a Write-tool truncation issue where the in-app Write returned success but the filesystem only persisted up to 16,230 bytes (the previous step's file size). Resolved by writing the file via bash heredoc, which lands the full 23,523 bytes correctly. The audit can verify the file is complete by checking the final `</html>` is present and the JS block parses with `node --check`. Sim-test harness on the audit side should work identically to step 1 — the `__sim` surface is a strict superset of step 1's.

---

*AI-DESIGNED. Step 2 handoff. Session: admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/02_suspicion_patroller.md.*
