# Step 01 handoff — sub_sonar_terrain

## What I built

- `code/sirens_song.html` — single-file HTML + JS + Canvas substrate for the daisy-chain.
- Bounded 960×640 top-down play area with **11 hand-authored terrain rectangles** (rocks / interior cover / channel bottlenecks). One site, no proc-gen per spec §11.
- Player sub: position + heading + velocity; **WASD / arrows** drive it; "moves slowly" per spec §2 (80 px/sec linear, 1.8 rad/sec turn).
- **Passive sonar:** always-on dim 90 px reveal ring around the sub (rough nearby blips per spec §3 table; free per invariant 3).
- **Active ping:** SPACE-triggered wide ring (360 px) that radiates from the firing position and fades over **3.0 s** (spec §3 table). Has a commented hook for the step-2 +25 suspicion cost.
- **Terrain collision:** circle-vs-AABB; axis-separated slide so the sub doesn't get stuck against rectangles; decrements hull on contact with edge or terrain, with a 0.6 s i-frame cooldown so a single bump can't drain all hull on continuous contact.
- **Hull integrity** = 3 (spec §11 default); 0 → `loseReason = "sunk"`.
- **Oxygen drain:** continuous 1 s/sec; starts at 240 s; 0 → `loseReason = "suffocated"`.
- Text HUD: position, heading, hull, oxygen %, ping status, elapsed time. Plain monospace per spec §11 + invariant 6.
- Lose overlay: "you lost (sunk)" or "you lost (suffocated)" centered, with "press R to restart" prompt.
- **R** restarts state via `newState()`.
- `window.__sim` exposes `TUNING`, `TERRAIN`, `newState`, `update`, `setState`, `getState`, `tryActivePing`, `circleRectOverlap` so step-2+ agents and the auditor can drive headless sim tests without spawning a browser.

## State of the file

- File: `code/sirens_song.html`
- File size: 16,230 bytes / 425 lines
- JS script block: 15,157 bytes
- Lines added: ~425 (file created this step)
- Lines modified: 0 (new file)
- Lines removed: 0

## Spec sections implemented

- **§1 Core fantasy / central knot** — frame only; the fragile slow sub is in place.
- **§2 Player vessel** — position+heading, slow movement, hull=3, oxygen drain → suffocate lose. Sub fallback cam and "doesn't directly engage" are wrapper notes; mechanics land in step 3 (cam) / step 5 (tools).
- **§3 Perception system, rows 1 & 2** — passive sonar (always-on, free, near-blind 90 px ring) and active ping (~3 s fade reveal, +25 suspicion hook). Rows 3 (recon) and 4 (drone cam) are deferred to steps 6 and 3 respectively.
- **§8 Win/lose, lose conditions only** — "sub sunk (hull depleted)" and "oxygen depleted" both implemented and traceable to player decision. Win condition (photos + extraction) and "sub vaporized (suspicion max)" deferred to step 3 and step 2.
- **§10 Fairness principles 1, 2, 5** — both lose conditions traceable to a decision (ran into terrain, ran out of air); no enemy HP exists yet (trivially holds); no instant restart from a single bump (hull buffer + cooldown).
- **§11 build leash, step 1** — fully covered. No proc-gen, single site, no menus beyond start/restart, placeholder shapes only.

## Tuning values used (with spec citation)

| Name | Value | Source |
|---|---|---|
| `HULL_MAX` | 3 | spec §2 + §11 default |
| `OXYGEN_MAX_SECONDS` | 240 (~4 min) | spec §11 says "≈ enough for one unhurried full run" — picked within qualitative bound. **FLAG for step 7 tuning pass.** |
| `SUB_SPEED_PX_PER_SEC` | 80 | spec §2 says "moves slowly" — picked deliberately slow for a 960 px playfield. **FLAG for step 7.** |
| `SUB_TURN_RATE_RAD_PER_SEC` | 1.8 | not in spec — picked to feel responsive but not agile. **FLAG for step 7.** |
| `PING_DURATION_SEC` | 3.0 | spec §3 table "fades in ~3 s" |
| `PING_RADIUS_PX` | 360 | spec §3 says "wide" reveal — picked roughly 4× passive radius. **FLAG for step 7.** |
| `PASSIVE_RADIUS_PX` | 90 | spec §3 says "rough nearby blips" — picked small. **FLAG for step 7.** |
| `HULL_HIT_COOLDOWN_SEC` | 0.6 | not in spec — required to prevent a single bump from instantly draining all 3 hull on continuous contact; serves §10 fairness ("one mistake ≠ instant restart"). **FLAG for step 7.** |
| `SUB_RADIUS_PX` | 8 | placeholder geometry (invariant 6). |

No tuning numbers were fabricated outside spec bounds. Every picked number is flagged.

## Sim tests run

Drove the JS via Node by extracting `<script>` content, stubbing `document`/`window`/`performance`/`requestAnimationFrame`, and calling `window.__sim` methods directly.

| Test | Check | Result |
|---|---|---|
| 1a | No input → no movement | PASS |
| 1a | Oxygen drains exactly 1.0 s per 1.0 s update | PASS (239.00 after 1s) |
| 1b | Movement math: `cos(0) * 80 * 1.0 == 80 px` forward in 1 s | PASS |
| 2 | Forcing sub past left edge decrements hull by 1 | PASS (3→2) |
| 3 | Cooldown blocks instant second hit | PASS |
| 4 | Hull reaching 0 sets `loseReason = "sunk"` | PASS |
| 5a | Oxygen reaching 0 sets `loseReason = "suffocated"` | PASS |
| 5b | Oxygen clamps at 0 (no negative values) | PASS |
| 6a | `tryActivePing()` sets `state.ping.tStart` | PASS |
| 6b | Ping still active at t=1.5 s after fire | PASS |
| 6c | Ping expired at t=3.2 s after fire | PASS |
| 7 | Lose state freezes the update loop (oxygen does not drain post-lose) | PASS |
| 8a-c | `newState()` returns hull=3, oxygen=240, loseReason=null | PASS |
| 9a-b | `circleRectOverlap` correctly detects sub-inside / sub-far cases | PASS |
| 10 | Full oxygen-budget run depletes at exactly `OXYGEN_MAX_SECONDS` | PASS (loseReason=suffocated, oxygen=0) |

All 10 tests pass headlessly in Node v22+ with no DOM.

## Open potholes for the next step

1. **Active-ping suspicion hook for step 2.** In `tryActivePing()` there is a commented placeholder:
   ```js
   // STEP 2 HOOK — suspicion +25 on active ping (spec §3 / §6).
   // Replace this comment with: applySuspicion(+25, "active_ping");
   ```
   Step 2 just needs to add `applySuspicion(+25, "active_ping")` (or whatever the suspicion API ends up being) at that exact site. No other step-1 code needs to change to wire it.

2. **Hull-hit cooldown is a step-1 invention.** Picked 0.6 s to prevent instant-drain on continuous edge contact (serves invariant 5 fairness). Step 7 should validate it actually feels right during playtest — too short and the sub still drains fast against a wall; too long and a player can grind against a rock with no consequence.

3. **`OXYGEN_MAX_SECONDS = 240` is a guess.** Spec says "≈ enough for one unhurried full run." Until the full route exists (post-step-3 photo objectives + extraction), there is no way to know if 240 s is right. Step 7 tunes this against a real route.

4. **Sub speed (80 px/s) and turn rate (1.8 rad/s)** picked to feel deliberate on a 960 px playfield. Without Sirens / drones / objectives yet, "feels slow but reachable" is a vibe call. Step 7 problem.

5. **Passive radius (90 px) vs. ping radius (360 px) ratio = 4×.** Spec describes passive as "rough nearby blips" and ping as "wide." Picked the ratio that makes ping feel meaningfully wider. Step 7 tuning may want to change either.

6. **Spec ambiguity ruled:** spec §2 says "lives in a continuous 2D top-down bounded play area" but doesn't specify size, terrain count, or geometry primitives. I picked 960×640 (canvas default scale), 11 rectangular terrain blocks, and circle-vs-AABB collision because (a) it matches the spec's "ONE hand-authored site" §11 directive and (b) rectangles are the lowest-fidelity placeholder shape that still produces meaningful navigation. The layout is hand-tuned to give bottlenecks (around the 500-x mid-column wall and the central horizontal at y=360) so step 4 Sentinels and step 2 Patrollers will have something to guard / route through. **Step 7 may want to rework the layout** once the full objective set + patrol routes are known — log a note then.

7. **Spec ambiguity ruled:** spec §10.1 says "death is always traceable to a player decision." For hull loss on a low-grazing terrain bump, the trace is "player drove into terrain." For oxygen loss, the trace is "player did not finish in time." Both meet §10.1 literally; whether the player *feels* the trace is a step-7 tuning + step-2+ UX question.

8. **Visibility model.** I implemented a clipping-region reveal where terrain is only drawn within the passive radius (always) and the ping ring (transient). The sub itself is always drawn — spec doesn't require hiding the player ship. If step 7 wants Iron Lung darkness for the sub too, that's a small change but a design call.

## Design improvement notes (NOT implemented, for Pat)

- **Heading-locked thrust vs. strafing.** I implemented forward/backward thrust along heading + turning. An alternative would be 8-direction strafe (no heading). Heading-locked is more sub-like and reinforces "fragile slow vessel" in invariant 2 / spec §2 ("not an agile combatant"), but a player who instinctively reaches for WASD-as-strafe will be confused. Spec is silent. Log for Pat's review at step 7 playtest.
- **Sub-vs-sub-cam separation.** Spec §2 talks about a grainy long-range fallback cam. That's a step-3 feature, not step-1, but if step 3 wants to treat the sub-cam viewport as separate from the world canvas, it'd be cleaner to draw it in a second canvas. Just flagging for the step-3 agent.
- **Edge collision = hull loss is harsh.** Spec doesn't explicitly say play-area edges deal hull damage — only "terrain collisions and Siren contact at alert level." I treated edges as terrain because otherwise the sub can just camp the edge. Step 7 may want a different rule (e.g., edges are walls that stop the sub but don't damage). Flagging for Pat.

## Invariant adherence (self-check, auditor verifies)

1. **No enemy HP / no player kill-path:** trivially held. No enemies exist; the sub has no weapon. Verified by code inspection — no `damage()` / `health` / `kill()` functions, no HP fields on any entity, no entities other than the sub.
2. **Suspicion is the spine:** n/a yet — suspicion lands step 2. The single step-2 hook is at `tryActivePing()` with an explicit `// STEP 2 HOOK` comment. No other code path commits to a non-suspicion threat model.
3. **Perceiving costs:** passive sonar is free per spec (only free reveal). Active ping has a commented +25 hook at the trigger site. Drone cam (free per spec §3 / +15 per photo per §6) and recon (+8 per spec) are step-3 and step-6 features and intentionally absent here.
4. **Tools buy time and cost heat:** n/a yet — no tools (step 5).
5. **Fairness valve:** n/a (no suspicion). The lose conditions that DO exist (hull → sunk, oxygen → suffocated) are §10-traceable: ran into terrain, ran out of air. The 0.6 s hull-hit cooldown is the step-1 fairness gesture — one bump never instakills via hull.
6. **Function before form:** held. Placeholder shapes (rectangles for terrain, triangle for sub, monospace text HUD), default black bg, no palette/sound/sprite/font/layout decisions. No "feel" polish.

## Receipt

- Step 01: COMPLETE
- Files written:
  - `code/sirens_song.html` (16,230 bytes / 425 lines)
  - `handoffs/01_HANDOFF_FROM_STEP1.md` (this file)
  - `claude_index.md` (updated per CGI §G.4)
- Ready for: `audits/01_AUDIT_STEP_01.md`

---

*AI-DESIGNED. Step 1 handoff. Session: admiring-laughing-hamilton. Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/01_sub_sonar_terrain.md.*
