# Siren's Song — Claude.ai Inbox Comparison Analysis

**Authored:** 2026-06-05 by Cowork research agent (Keel, Claude Opus 4.7-1M).
**Source folder:** `C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\Inbox_from_Claude.ai\Siren's Song claude web\`
**Purpose:** Compare Pat's parallel claude.ai prototype build against the Cowork daisy-chain build (`code/sirens_song.html`, Steps 1-8) to surface convergence (good signal — spec held), divergence (interesting — design space was wide), pull-in candidates, and hold-out flags.
**Treat numbers as observed from disk. Treat design framings as Keel synthesis tagged where it matters.**

---

## 1. Inventory

Five files landed in the inbox folder on 2026-06-05 21:39 UTC. Per Pat's brief, they represent the parallel claude.ai-web track of Siren's Song development that ran alongside the Cowork chain.

| Filename | Size | Type | First-pass categorization |
|---|---|---|---|
| `SIRENS_SONG_functional_spec.md` | 16,947 B | Markdown | Spec **v0.3** — supersedes Cowork's v0.2 spec; adds noise/silent-running, drones flesh-out, knockdown torpedo, audio promotion, photo scoring, factory escalation, search memory, narrative fragments, currents/thermals. 15 sections. |
| `SIRENS_SONG_dev_notes.md` | 7,753 B | Markdown | Process record + playtest findings from the claude.ai prototype iteration. Four feedback rounds. Tagged provenance ([PAT] / [CONFIRMED] / [KEEL] / [KEEL-FLAG]). Most useful single document for understanding what claude.ai iterated through. |
| `SIRENS_SONG_pressure_design.md` | 8,836 B | Markdown | Standalone design proposal: "**THE HUNT**" — a global pressure meter on top of suspicion, five staged escalation states (Dormant/Stirring/Searching/Hunting/Lockdown), graze damage to replace binary instakill. Marked DESIGN PROPOSAL by Keel, not ratified at the time of file capture. |
| `sirens_song_prototype.html` | 44,721 B / 580 lines | Single-file HTML+JS+Canvas | Earlier prototype iteration. Implements: blind sub piloting, passive + active sonar with shadow-cone occlusion, suspicion with 4 states, oxygen clock, circular rock obstacles, 4 Sirens (2 patroller / 1 sentinel / 1 hunter), EMP + decoy + recon + drones + sub fallback cam, 4 photo objectives including factory, 2 log fragments, extraction at south edge. |
| `sirens_song_prototype_v7.html` | 47,365 B / 607 lines | Single-file HTML+JS+Canvas | Later prototype iteration. Inherits everything in prototype.html, **adds the HUNT meter + 5 escalation stages + graze damage** from `pressure_design.md`. Adds knockdown action wired in. Hull (HP-bar style) for graze damage. Per filename suffix, treat as the more current claude.ai build. |

Total inbox payload: ~125 KB across 5 files, two of which are working HTML builds and three of which are design documentation.

---

## 2. Per-file analysis

### 2.1 SIRENS_SONG_functional_spec.md (v0.3)

This is the **v0.3 functional spec** authored 2026-06-03 in the claude.ai track. Our chain's `SIRENS_SONG_SPEC.md` is the **v0.2** spec from the same date.

**Section structure:** 15 sections vs. our 11. The five new sections are roughly:

- §6 **Suspicion** restructured around a new "KILL RULE" — vaporize only fires while at least one un-stunned Siren has detection (proximity + LOS) on the sub. Stunned + cover = kill is suspended even at sustained max.
- §9 **Factory activity** — escalation-on-capture; each photo raises global Siren alertness a notch.
- §10 **Audio** — promoted from polish to a build pillar. Iron Lung framing made explicit.
- §11 **Narrative layer** — briefing line, 2-3 log fragments, ending stingers.
- §12 **Environmental texture** — currents, thermal layers, marine snow (mostly form-pass).

**Build-leash divergence:** v0.2 has 7 build steps in §11 (sub/sonar/terrain -> suspicion/Patroller -> drones -> other Sirens -> tools -> recon -> tuning). v0.3 has 9 build steps in §15: **EMP/kill-rule fix -> speed-as-noise + silent running -> drones -> knockdown torpedo -> audio -> photo scoring + factory escalation -> siren search memory + silhouettes -> narrative fragments -> currents/thermal + form polish.**

The v0.3 build leash is a **post-prototype refactor leash** — the claude.ai prototype already exists, so the build order assumes the substrate from prototype.html and patches forward. Our chain's v0.2 leash is a **from-zero build order** — it assumes no substrate and adds systems in dependency order.

**Six invariants** (v0.3 wrapper): same six as our v0.2 spec verbatim. Domain canon held across both spec versions. The invariants are the most stable surface of the project.

**Decision log surfaces this explicitly:**

> v0.3 — 2026-06-03 — [PAT] raised the EMP problem — "Emp'd enemies shouldn't continue to increase your detection... it's not a good self-defense tool if you can still die from it." [PAT] then directed "do it all with a spec first," ratifying the full feature set and spec-first sequencing.

That ratification is the seam that produced v0.3 in the claude.ai track. The Cowork chain never received this ratification — we built against v0.2 throughout. The kill-rule and silent-running mechanics in v0.3 are **not present in our build**, but the invariants both versions reference are.

### 2.2 SIRENS_SONG_dev_notes.md

Iterative playtest log from the claude.ai prototype. Four rounds, each documenting Pat's findings and Keel's implementation response. The most useful document in the inbox for understanding the claude.ai trajectory.

**Round 1 ([PAT] feedback):**
- "felt the dread!" — core loop landed on first play
- "sub and enemies are way too fast. Doesn't feel like underwater."
- "Lack of environmental obstacles loses some of the fun."
- "EMP is quite strong, I almost never needed decoys."
- "Wouldn't mind a larger map with edge scroll."

**Round 2:**
- "Suspicion drains too fast, doesn't really do much."
- "Obstacles are visible from start instead of being revealed like the sirens."
- "The factory should probably be a camera target too, otherwise it's just a random hazard zone."

**Round 3:**
- "EMP should be area of effect, auto targeting only one closest enemy isn't really realistic."
- "The sub needs to handle more like a sub."
- "Ping should make enemies investigate you."
- "blocked by obstacles with a vision cone showing what you don't see."

**Round 4:**
- "Ping LOS blocker isn't working at all, it's definitely harder now."
- (After fix): "Much better and it looks cool as fuck now!"

**Keel diagnoses in the dev notes:**
- "**Occlusion must be visible, not just logical.** Correct gating the player cannot see reads as a bug."
- "**Momentum is load-bearing for 'underwater.'**"
- "**Sticky suspicion makes the spine work.**"
- "**Ping-as-bait is the see=be-seen tension made behavioral.**"

**Final tuning state recorded:**
- Movement: maxSpeed 96, accel 2.2, turnRate 2.0, arriveR 110
- Perception: passiveR 130, pingMax 520, pingHear 680, investigateT 6.5
- Tools: EMP area-blast 150 / 3.2 s stun; decoy pull 320 / x4; recon x2
- Suspicion: decay 3/s, decayDelay 1.8 s, alert 34, hostile 75, instakill at 100 held 3.5 s
- Oxygen: ~220 s
- Content: 4 Sirens (2 Patroller, 1 Sentinel, 1 Hunter), 9 obstacles, 4 photo objectives (factory is the 4th)

**Open threads called out in dev notes:**
- [KEEL-FLAG] difficulty target undecided
- [KEEL-FLAG] vision-cone interpretation (sonar shadows vs. flashlight cones)
- [KEEL] drones unbuilt in claude.ai prototype (sub cam stands in)
- [KEEL] terrain & cover not yet in the spec at v0.2 — landed in v0.3 implicitly

### 2.3 SIRENS_SONG_pressure_design.md

A standalone designer-hat document, dated implicitly post-prototype. Diagnoses the prototype's flat-floor-plus-lethal-ceiling pattern and proposes **THE HUNT** as the fix.

**Diagnosis (Keel, committed, no hedging):**

> Nothing in the run escalates. The patrols are static, the oxygen drain is flat and linear, the space is uniform, and failure is a single binary instakill. There is no curve.
> Flat floor + lethal ceiling, nothing connecting them. Fix the connection — build a rising slope — and all three resolve together.

The three symptoms it attributes to the same root cause:
- "It feels flat / missing something" -> no arc, one tension level all the way
- "Too easy" -> baseline is a calm coast
- "Too hard" -> all difficulty crammed into one binary instakill

**The proposal — THE HUNT:**

A global 0-100 pressure meter representing "the base waking up to you." Independent from suspicion.

| Source | Rate |
|---|---|
| Time inside | +0.6/sec |
| Taking a photo | +8 each |
| Active ping | +5 each |
| EMP/knockdown fired | +4 each |
| Siren acquiring you | +6 each |

Decays -1/sec after 6 s of no detection AND no actions, but **never drops below a progress floor** = `photosTaken × 8`. So the run trends upward and can never reset.

**The escalation ladder (replaces ad-hoc `baseAlert × 0.04` from prototype.html):**

| Stage | Hunt | Sirens | Factory | Audio |
|---|---|---|---|---|
| 0 Dormant | 0-20 | lazy patrols, base detection | quiet | calm ambient |
| 1 Stirring | 20-45 | detection x1.15, +10% patrol speed | first low pulse | a heartbeat begins |
| 2 Searching | 45-70 | x1.3, leave stations to sweep, longer investigates | factory lights shift | rising bed |
| 3 Hunting | 70-90 | x1.5, hunter actively pursues | factory powers up (visible) | tense, driving |
| 4 Lockdown | 90-100 | x1.7, everything converges on extraction | full alert | alarm |

**Graduated failure (kill the binary):**

> **Graze.** At Hostile suspicion (>=75) with a Siren detecting you for >1.5 s, you take a warning hit — hull damage (-20), not death — and a Hunt spike (+6), then a short cooldown.

Death is still suspicion 100 + active detector sustained for the kill-hold. But the graze adds a "wounded but alive" middle state the prototype lacks.

**Open decisions raised at the end of the doc:**
1. Hunt climb rate (methodical-leaning ~0.6/s vs. urgent)
2. Oxygen — keep as backstop or fold into Hunt
3. Graze damage — does the warning-hit middle state feel right
4. Does the Hunt ever fully cool, or is it pure one-way ratchet

These are open at the time of the file. The fact that v7 implements the HUNT system suggests at least decisions 1 and 3 were ratified post-doc. Decisions 2 and 4 may be implicit in v7 as well (v7 keeps oxygen, and the progress floor means the HUNT never cools below floor — i.e., partial ratchet).

### 2.4 sirens_song_prototype.html (the earlier build)

**Substrate:** Single-file HTML + JS + Canvas. 580 lines. World 1200x1800 (portrait orientation), view 900 px tall, follow-camera. Procedural Web Audio for sonar/EMP/knockdown/decoy/drone/capture/boom/surface/beat/ambient.

**Code organization (single-file, single namespace):**
- HTML head + 64-line CSS at top
- Single `<script>` block, ~440 lines of JS, top-level `const CFG` block at line 102 with ~30 tuning numbers
- Global mutable state at line 119: `let screen, T, mode, paused, sub, suspicion, oxygen, atMax, noiseT, baseAlert, pings, decoys, drones, recon, sirens, objectives, obstacles, currents, logs, extraction, tools, pingCD, last, bubbles, snow, fx, bubT, beatT`
- `AU` audio module at line 122 (procedural Web Audio, fail-safe try/catch)
- `genRock()` for procedural rock shapes with lumps
- `init()` that builds the world from scratch each run
- Single `step()` / `render()` loop driven by `requestAnimationFrame`

**Mechanics present:**
- **Sub:** face-and-thrust handling, `maxSpeed:96 accel:2.2 turnRate:2.0 arriveR:110`, momentum/drag, **silent running** field (`sub.silent`)
- **Passive sonar:** `passiveR:130` radius, LOS-occluded via `shadowPoly` rendered as visible shadow wedges
- **Active ping:** `pingMax:520` radius, `pingLife:3.2` fade, `pingHear:680` enemy-investigate trigger, `pingCost:18` suspicion
- **Recon:** large sector reveal, `reconLife:3.2`, `reconR:560`, `reconCost:9`
- **EMP:** **area blast** `empRange:150`, `empStun:3.2`, `empCost:24`
- **Knockdown torpedo:** `knockRange:150`, `knockStun:8.0`, `knockCost:20` (mechanically present but no button in this build)
- **Decoy:** `decoyLife:7.0`, `decoyCost:5`, `decoyPull:320`
- **Drones:** `droneSpeed:135`, `droneVisionR:155`, `droneKillR:16` — present in `tools` and CFG but the drone flow is the early version
- **Photo:** `photoCost:14`, `captureR:72`
- **Sirens:** 4 total — 2 Patroller (4-waypoint loop), 1 Sentinel (orbit around power core, tether 190), 1 Hunter (dormant at 0.06xWORLD)
- **Thermal:** `thermalY0:0.40`, `thermalY1:0.455`, `thermalMul:0.5` — implemented as a hiding zone that reduces detection
- **Obstacles:** circular rocks with `shadowPoly` cone-rendering — visible shadow wedges behind rocks during ping
- **Logs:** 2 narrative fragments at hardcoded positions ("This was never reconnaissance...")
- **Suspicion math:** decay 3/s, decay delay 1.8 s, alert 34, hostile 75, instakill at 100 held 3.5 s, baseAlert ratchet from progress
- **State labels in HUD:** "SILENT RUNNING" / "CURIOUS" / "ALERT" / "HOSTILE — BREAK CONTACT"
- **Audio:** procedural — ping tone (880 Hz slide), EMP noise + 130 Hz square, knockdown 90 Hz, decoy 560 Hz triangle, drone 700 Hz square, capture 1500/2200 Hz click, boom noise + 60 Hz sine, surface 380 Hz, ambient 44 Hz drone

**Code quality observations (not judgment, observation):**
- Single namespace, no modules — everything global. Trades organization for single-file simplicity.
- Heavy use of one-letter / two-letter variable names (`T`, `r`, `R`, `ctx`, `t`, `dt`, `d`, `rr`, `sp`). Reads like demoscene / production-canvas code, not the verbose-citation style of our chain.
- No comments past the CFG block. The code is dense; behavior is in the math, not the prose.
- No `__sim` harness or sim test surface. Iteration was browser-playtest-driven, not headless.

### 2.5 sirens_song_prototype_v7.html (the later build)

**Substrate:** Single-file HTML + JS + Canvas. 607 lines. Same world dimensions (1200x1800 portrait, view 900). Inherits prototype.html's architecture wholesale.

**Net delta from prototype.html (~27 lines of additions; ~50 modifications):**

- **HUNT meter wired live.** Stage compute via `huntStage()` returning 0-4; multiplier via `huntMult()` returning `[1.0, 1.15, 1.3, 1.5, 1.7][stage]`. `effDetect(s)` now multiplies a Siren's detection by `huntMult()`.
- **New CFG values for HUNT:** `huntTime:0.2 huntPhoto:8 huntPing:5 huntTool:4 huntDetect:6 huntGraze:6 huntDecay:1.0 huntDelay:6`. Note: `huntTime:0.2` is LOWER than the pressure_design.md proposal of 0.6 — claude.ai apparently dialed it down. Possibly Pat ratification, possibly Keel-self-correction in play.
- **New CFG values for graze:** `grazeDmg:20 grazeDelay:1.5 grazeCool:3.0`. Match pressure_design.md exactly.
- **New state vars:** `hunt, hull, grazeCD, grazeT, huntT, wasDetected`.
- **HUD added second meter:** stage name DORMANT / STIRRING / SEARCHING / HUNTING / LOCKDOWN with color escalation (cyan -> cyan -> amber -> amber -> red) and blink at lockdown.
- **Knockdown is now wired to a button + key.** prototype.html had `knock` in CFG but no flow; v7 has working knockdown ("Pinned to the floor" toast).
- **Drone flow corrected:** v7 now re-uses a downed drone or launches a new one ("Tap to send drone" vs. "Tap to launch drone"). prototype.html always launched new.
- **arriveR bumped 110->220.** Sub now coasts further toward click target before settling.
- **droneVisionR dropped 155->120.** Tighter local reveal.
- **OXYGEN extended 230s->300s.** Per pressure_design.md decision 2: "stretch to ~300s as a generous hard backstop so the Hunt, not the air, is the star."
- **Factory frame turns red** at Hunt stage >=3 (visible factory-powers-up cue).
- **Ambient drone gain scales** with Hunt stage: `0.10 + huntStage()*0.02`.

**Everything else preserved:** same shadowPoly LOS, same circular rocks, same 4 Sirens with same waypoints, same logs, same audio module, same thermal band, same recon disc, same EMP area-blast, same decoy pull radius.

**The kill rule from spec v0.3 §6 — vaporize only fires while at least one un-stunned LOS detector has the sub.** Searching v7 for this rule: the prototype `step()` function checks `if(suspicion>=100 && atMax>=CFG.killHold)` to trigger end. There is no explicit "any un-stunned detector currently has LOS" gate. So the v3 spec kill-rule is **not yet implemented in v7** — only the HUNT + graze additions. The rest of v0.3's deltas (silent running mechanic, search memory, distinct Siren silhouettes, narrative ending stingers) are also not implemented in v7. v7 is a partial v0.3 implementation focused on the HUNT system.

---

## 3. How our chain's build relates

For grounding the comparison, the Cowork chain build at `code/sirens_song.html`:

- **135,266 bytes / 3,196 lines.** ~3x the line count of v7, ~5x the byte count.
- **Single-file HTML + JS + Canvas + touch overlay.** Same general substrate.
- **Canvas 960x640 landscape**, internal resolution fixed. Step 8 added responsive CSS scaling + touch overlay; pre-step-8 was fixed-pixel.
- **TUNING block** at lines 94-380, 90 named constants. Verbose `INV` citations next to suspicion math, AI state transitions, and fairness valve seams.
- **`__sim` harness** with 73 entries — extracted for headless sim work in audits.
- **Six invariants** quoted verbatim from `agent.md` §2 at the top of relevant code regions.
- **3 Sirens** — Patroller (10-waypoint loop), Sentinel (40 px orbit around power_core), Hunter (dormant at (200, 60)). Compare to claude.ai's 4 (2 patrollers).
- **4 photo objectives:** silhouette, bays, power_core, factory (factory as 4th objective per Round 2 dev-notes finding — convergent).
- **Tools:** Jam (key 1), EMP (key 2 then click), Knockdown (key 3 then click), Recon (key 4 then click), Drone (left-click + right-click cycle + TAB + F + B + G).
- **No HUNT meter.** Our suspicion 0-100 + 4 states is the only pressure meter. baseAlert from v0.3 / HUNT from v7 is not present.
- **No graze damage.** Pure binary at sustained max suspicion for 4.0 s.
- **No silent running.** Sub speed is constant 80 px/s cap; no noise-from-speed term, no `silent` mode.
- **No shadow-cone rendering.** LOS is enforced by raycast (`isLineOfSightClear`) against axis-aligned terrain rectangles — the data is correct, but unlike claude.ai we do not render the shadow wedges behind rocks. Per the dev notes diagnosis ("Occlusion must be visible, not just logical"), this is **the most visible UX gap** our build has vs. claude.ai.
- **No procedural audio.** INV6 deferred; no AU module, no sound at all currently.
- **No narrative log fragments.** Spec v0.3 §11 not implemented.
- **No thermal layer, no currents.** Spec v0.3 §12 not implemented.
- **No silhouette differentiation.** All Sirens render as plain rectangles + text labels. Form pass deferred per INV6.

---

## 4. Convergent design choices (good signal — spec was clear)

These are places where Pat's claude.ai build and our Cowork chain made the same mechanical call independently. Convergence is a signal the spec carried correctly across substrates.

1. **Suspicion-as-spine, 0-100, four threshold states.** Both builds. Both use 34 / 75 thresholds (`THRESH_ALERT:34` / `THRESH_HOSTILE:75` here; `alert:34, hostile:75` in v7). Both end at sustained 100. claude.ai has a delayed decay (1.8 s); ours uses a different decay strategy (pause during ping window).
2. **No Siren HP, no kill-path.** Both builds. INV1 held across both substrates. Neither tracks Siren health, neither offers a kill verb.
3. **EMP and Knockdown stun for time, do not damage.** Both builds. EMP 3.2 s claude / 5.0 s ours; KD 8.0 s claude / 12.0 s ours.
4. **Active ping LOS-occluded.** Both builds. v0.3 spec §3 + dev-notes Round 4 + v7 implements via shadowPoly; our fix-pass implements via raycast. Same intent, different render.
5. **Factory as a 4th photo objective.** Both. Pat's Round 2 finding "the factory should probably be a camera target" landed in both tracks. Convergence here is partly because the same Pat ratification reached both substrates (v0.3 spec mentions 4 photos with factory; our brief 03 has 4 objectives including factory).
6. **Sub face-and-thrust handling with momentum.** Both. claude.ai Round 1+3 fix; our Step 1 fix-pass. Both landed within ~24 hours of each other.
7. **Drones as primary safe camera + decoy.** Both. Spec §4 architecture preserved across both.
8. **Sub-cam as desperate fallback.** Both.
9. **Recon plane as consumable wide-reveal.** Both. claude.ai `reconCost:9`; ours +8. Close.
10. **Single hand-authored site, no proc-gen.** Both. Hardcoded waypoints, hardcoded objective positions, hardcoded Hunter dormant position. INV-respect across both substrates.
11. **Win = all photos + extraction.** Both.
12. **Lose conditions: vaporized / hull-sunk / oxygen-depleted.** Both. (Caveat: v7 adds a *hull breach* lose path via accumulated graze damage that ours does not have. Same condition family, but the trigger surface is different.)

---

## 5. Divergent design choices (interesting — spec was loose or design space was wide)

| Dimension | claude.ai (v7) | Cowork chain (Step 8) | Likely why |
|---|---|---|---|
| World orientation | Portrait 1200x1800, follow-camera | Landscape 960x640, static | claude.ai Round 1 "larger map with edge scroll" — Pat explicitly asked for this on the claude.ai track. Our chain never received that brief; we held to single-screen. |
| Number of Sirens | 4 (2 Patroller, 1 Sentinel, 1 Hunter) | 3 (1 Patroller, 1 Sentinel, 1 Hunter) | claude.ai Round 1 "EMP almost never needed decoys" — Pat asked for one more enemy to make decoys earn their place. Our chain has 3 because spec §7 says three. |
| Obstacle geometry | Circular rocks with shadowPoly cone-render | Axis-aligned rectangles with raycast | Implementation choice. claude.ai picked circles + shadows for visual feedback; we picked rects because raycast-vs-rect is simpler to verify in sim tests. |
| Occlusion VISUAL | Shadow wedges rendered behind rocks during ping (dev-notes Round 4 fix) | LOS-correct but **not rendered as shadows** | This is the dev-notes' main UX lesson and our biggest visible gap. See §10 pull-in #1. |
| Audio | Procedural Web Audio live throughout | No audio — INV6 deferred | Spec v0.3 §10 promoted audio to core pillar; our chain built against v0.2 where audio is form-pass. |
| HUNT meter (global pressure) | Yes — v7 fully implements | No | claude.ai ratified the pressure_design.md proposal mid-chain. We never received this ratification. |
| Graze damage | Yes — 20 hull on detector >1.5 s at Hostile, 3 s cooldown | No | Same root — pressure_design.md not seen by Cowork chain. |
| Silent running | Spec v0.3 §2; v7 has `sub.silent` state field but flow not fully wired (UI button doesn't appear in HUD readouts) | No | v0.3-only. |
| Noise from throttle | Spec v0.3 §6 mechanic; v7 has `noiseGain:13` and `noiseHearMax:360` in CFG but the bind point to per-Siren detection is partial | No noise-from-speed term | v0.3-only. |
| Knockdown torpedo button | Bound to a key + tray in v7 | Bound to key 3 + click in ours | Both work. claude.ai placement is in the action tray on the right (HUD chrome); ours is keyboard-only modal-arm. |
| Recon | 460 px disc, NOT LOS-gated, 8 s duration, 2 charges (our chain); 520 px / 3.2 s / 2 charges (claude.ai) | (see left) | Numeric tuning; both NOT LOS-gated. |
| EMP | claude.ai: area blast 150 px, 3.2 s stun, 2 charges. Ours: 5.0 s stun, 3 charges, range gated by target click + LOS | (see left) | Charge count + duration divergence. claude.ai is faster + scarcer; ours is longer + plentiful. |
| Decoy | Drone-as-decoy via decoy pull radius 320 px; passive parked decoy | Same model — passive parked drone draws + active "B" toggle for stronger draw | Both. |
| Hull | Number, decremented by hull breach (graze damage) | Number, decremented by ram contact at Alert+ | Same data; different inputs feed it. |
| Oxygen | 300 s (v7); 230 s (early prototype) | 210 s (Step 7 tuned, down from 240 default) | claude.ai went LONGER (300 s makes oxygen a "generous backstop" per pressure_design.md); we went SHORTER (210 to tighten camping). Opposite tuning directions. |
| Suspicion decay | 3/s with 1.8 s delay | 5/s with no delay (pause during ping window) | claude.ai's stickier decay vs. ours. Step 2 audit (our chain) chose spec-literal "decay immediately when below max"; claude.ai's Round 2 fix introduced the delay. Both legal readings of spec §6. |
| Instakill sustain | 3.5 s | 4.0 s | Numeric only. Both inside spec §6 "sustained" framing. |
| Patroller Alert+ speed mult | x1.6 implicit via cycling speed 22 -> 44 | x1.6 (explicit `PATROL_ALERT_SPEED_MULT:1.6`) | Same intent. |
| Sentinel orbit | Tether 190 around power core | 40 px orbit around power core | claude.ai gives Sentinel a much larger orbit ring (~190 px tether range); ours is a tight 40 px ring. Look-and-feel choice. |
| Hunter pursue speed | `chase:64` | `HUNTER_PURSUE_SPEED:75` (Step 7 tuned, was 90) | Close. claude.ai 64; ours 75. Step 7 audit flagged a related issue: at 75, literal-stationary-sub aggression hull-sinks at t~=8.4 s rather than vaporizing at 4.0 s. Tuning is the lever; either value is spec-legal. |
| Sub speed | maxSpeed 96 | 80 (terminal cap under inertia) | Numeric. |
| Drone speed | 135 | 110 | Numeric. |
| Photo cost | 14 | 15 | Numeric, within rounding of spec default. |
| Ping cost | 18 | 25 | Numeric. claude.ai's lower ping cost makes active reveals cheaper; ours follows spec §11 default. |
| Narrative fragments | 2 log dropdowns at hardcoded positions | None | v0.3-only. |
| Thermal layer | `thermalY0:0.40 thermalY1:0.455` band where detection x0.5 | None | v0.3 / v0.2 difference. |
| Touch / mobile | None — desktop-only | Step 8 layered touch overlay + responsive layout | Step 8 was our chain's post-spec extension. claude.ai prototype has no touch path. |

---

## 6. Mechanics claude.ai has that we don't

In rough priority order based on spec invariant alignment + implementation cost + UX leverage:

1. **Visible LOS shadow wedges during ping reveal.** `shadowPoly` rendered per obstacle, casting a dark cone behind each rock. Per dev-notes Round 4, this was the single change Pat called "looks cool as fuck" — the geometry was already correct, the rendering made it readable. (~30 lines of canvas drawing code.)
2. **Procedural Web Audio sonar/ping/EMP/knockdown/capture/boom/ambient.** ~25 lines for the AU module + ~10 lines of `AU.x()` calls scattered through the event seams. Spec v0.3 §10 promoted to core pillar.
3. **THE HUNT global pressure meter** + 5-stage escalation + factory-powers-up visual cue. ~40 lines for the math, ~5 lines for the HUD readout, ~3 lines for the factory color swap. Independent from suspicion.
4. **Graze damage at Hostile.** Survivable middle state — graze hits hull (-20) at sustained Hostile + detector for >1.5 s, 3 s cooldown. Replaces the binary instakill with a slope. ~10 lines.
5. **Silent running toggle** (state field present, flow partial in v7). Speed-as-noise + silent-mode zeroes the noise term. Pat ratified this in v0.3 decision log.
6. **Marine snow particles + bubble trail.** Cosmetic but it sells "underwater" — neither was prohibited by INV6 in our chain, but our chain treated all visual flourish as form-pass.
7. **2 narrative log fragments** at hardcoded world positions, picked up and shown in a modal. Spec v0.3 §11 cheap+high-meaning per Iron Lung. ~20 lines.
8. **Thermal band** — Y-stripe in the world where detection x0.5. Tactical hiding zone. ~5 lines.
9. **Currents** — soft directional push on the sub. Mentioned in v0.3 §12; partly implemented in v7 (the `currents` global is declared but its update loop appears to be a small acceleration nudge). Navigation texture.
10. **2 Patrollers instead of 1.** Crowd-control content. Resolves Round 1 "EMP almost never needed decoys."
11. **Knockdown live in tray.** Ours has the key flow; claude.ai's UI surface is more discoverable.
12. **HUD second meter / stage readout** — explicit Hunt stage name color-coded.

---

## 7. Mechanics our chain has that claude.ai doesn't

1. **`__sim` harness for headless verification.** 73 entries. claude.ai is browser-playtest-only; our chain can be re-audited deterministically by Node.js. This is a process win, not a mechanic win, but it preserves replayability across sub-agents.
2. **Verbose INV citations at code seams.** Comments like `// INV5 fairness valve` next to suspicion math. claude.ai's prototype is comment-light. Our chain's overhead is higher; our auditability is also higher.
3. **Step 8 mobile / touch layer.** Joystick + 13-button action tray + responsive CSS scaling + touch-event coord transform. claude.ai prototype has no touch path. Both builds open in a desktop browser; only ours opens reasonably on a phone.
4. **Jam tool as separate disruption (key 1).** Spec §5 lists 3 disruption tools (jam / EMP / knockdown). claude.ai's CFG has decoy as a separate tool slot; ours has jam as a separate tool slot. Different decompositions of the same "buy time + cost heat" axis.
5. **Auditor brief + audit reports per step.** 8 audit files at `audits/`, each one running 50-150 sim tests independently to verify the build-agent's receipt. claude.ai's iteration is build-then-Pat-plays; ours is build-then-audit-then-Pat-plays.
6. **Backup ladder.** 7 dated `.bak` files in `code/` capturing pre-step state for rollback. claude.ai's prototype-to-v7 retains only the two builds.
7. **Right-click drone redirect + TAB cycle.** Mouse/keyboard depth for managing the drone fleet. claude.ai uses tap-target-to-deploy and re-uses a downed drone.
8. **Charge counter UI per tool.** Our HUD shows `jam: 3/3 | emp: 3/3 | kd: 2/2 | recon: 2/2 | drones: 5/5` etc. Discoverable resource state.
9. **Hull i-frame cooldown** (0.6 s) preventing multi-Siren stacking on the sub from multi-draining hull. INV5 hardening. claude.ai's hull is graze-only (one impact = 20 with 3 s cooldown); ours is contact-based with shared cooldown.

---

## 8. Code quality / approach observations (no judgment)

**Both builds are single-file HTML+JS+Canvas with one global namespace.** That's a deliberate substrate choice for the "playable in any browser, no toolchain" constraint.

**claude.ai prototype style:**
- Dense, minified-leaning JavaScript. `let T=0, mode='move'`, one-letter variables in hot loops.
- ~440 lines of JS in v7; tight.
- Hand-written canvas calls; no helper abstractions.
- Audio module is a single `AU` const with method jambox; gesture-initialized, fail-safe try/catches.
- Inline `ctx.translate / ctx.rotate / ctx.fillStyle` blocks for every Siren render — repeated but legible.

**Our chain style:**
- Verbose, citation-heavy. `// TUNING(default per spec §11)` comments, `// INVx` markers at seams.
- ~2,900 lines of JS in Step 8; significantly more code per mechanic.
- Helper abstractions: `applySuspicion(amount, sourceTag)` chokepoint, `isLineOfSightClear(...)` predicate, `suspicionState()` returning a label.
- `__sim` harness surface for sandbox-side verification.
- Step-by-step backups + dated handoffs + audit reports.

**Trade observed:**
- claude.ai's tight code reaches playable-feel fast. Pat iterated four rounds in one session and the dev notes show the substrate handled rapid mechanic swaps without restructuring.
- Our chain's verbose code reaches verifiable-on-disk state. Each step has a self-contained handoff + audit; a cold instance can pick up the build at any step boundary without grepping for state.

Both choices are correct for their substrate. claude.ai's substrate is conversational + browser-driven. Our substrate is dispatch + sandbox-headless + post-hoc Pat playtest. The code style reflects the audit gate.

**One concrete code-quality artifact our chain has:** the 105 INV/spec citations at critical seams. A cold instance reading our build knows which line implements INV5 (fairness valve) and can verify by reading the comment. claude.ai's build requires reading the dev notes or the spec alongside the code to map mechanic -> spec section.

---

## 9. Synthesis — convergence vs. divergence

**Convergence points (the spec was clear, both substrates landed in the same place):**

- The six invariants are the most stable surface of the project. Both v0.2 and v0.3 specs carry them verbatim. Both builds respect them.
- Suspicion meter shape (0-100, 4 states, 34/75 thresholds, vaporize at sustained max) is identical across builds, modulo small numeric differences (3.5 s vs 4.0 s sustain).
- Sub face-and-thrust with momentum landed in both within 24 hours of each other (Round 1+3 dev-notes / Step 1 fix-pass).
- Drones-as-safe-camera, sub-cam-as-fallback, recon-as-wide-reveal — same architecture.
- 4 photo objectives including factory.
- Hand-authored single site, no proc-gen.

This is the v0.2 spec working as intended. Pat's design canon is portable across substrates.

**Divergence points (the design space was wide or the spec was loose):**

- **Pressure / escalation.** Our chain's suspicion does not include a global pressure meter; claude.ai's v7 implements THE HUNT. Both are spec-legal — v0.2 §10 says "difficulty rises from scarcity + escalating suspicion." How that escalation happens is design space. claude.ai filled it; we left it ambient.
- **Visualization of LOS.** The geometry is the same; the rendering is opposite. claude.ai shows shadow cones; ours leaves the visible blockage implicit. Same mechanic, different feedback.
- **Audio.** v0.3 promoted to core pillar; v0.2 left as form-pass. Our chain held v0.2; claude.ai went v0.3. This is the single largest spec-version-induced divergence.
- **Map shape.** Portrait + scroll vs. landscape + static. Round 1 dev-notes had Pat ask for "larger map with edge scroll"; that brief never reached our chain.
- **Decay sticky vs. spec-literal.** claude.ai stickier (3/s with 1.8 s delay); ours faster (5/s with no delay). Both readings of spec §6.
- **Oxygen direction.** claude.ai LONGER (300 s "generous backstop"); ours SHORTER (210 s "camping squeeze"). Opposite philosophies of what oxygen is for. Both valid per spec.
- **Suspicion costs.** Numeric drift across all six cost sources. None violate spec, but each implementation chose slightly different magnitudes.

The divergence points are mostly about **what role each pressure source plays** (oxygen as backstop vs. squeeze; suspicion as sticky vs. clean; pressure as global meter vs. local meter). The spec describes the verbs; the substrates landed on different relationships between them.

---

## 10. Recommended pull-ins (claude.ai -> our chain)

Ranked by spec-invariant alignment + implementation cost + UX leverage:

### Pull-in #1 (HIGH): Shadow-cone LOS rendering

**Why:** Dev-notes Round 4 is unambiguous — the LOS gating geometry was already correct in claude.ai's prototype; rendering the shadows was the change that made the mechanic readable, and Pat's reaction was "Much better and it looks cool as fuck now!" Our chain has the LOS geometry correct (via raycast against rect terrain); we do not render the shadows. This is the single highest-leverage UX gap.

**Implementation cost:** ~30 lines of canvas drawing. Compute the shadow polygon from each terrain corner relative to the ping origin; fill it dark inside the ping disc. Code shape is in `shadowPoly()` (claude.ai) lines 207-220 — translated for rectangular terrain it becomes "find the two edges of the rect facing away from origin, extend their corners to ping radius, fill quad."

**Invariant pressure:** INV6 says "function before form... build systems before art." But this is **legibility rendering**, not aesthetic polish — Klei's Mark of the Ninja established this as a Function affordance, not Form. Recommend implementing as a debug overlay first (matching INV6); make it final-ship-quality during form pass.

**Pat ratify?** Yes, before we build.

### Pull-in #2 (HIGH): Spec v0.3 EMP kill-rule fix

**Why:** Pat ratified this in the v0.3 decision log: *"Emp'd enemies shouldn't continue to increase your detection... it's not a good self-defense tool if you can still die from it."* This is the canonical fix to a real prototype-found problem. Our chain inherits the v0.2 instakill rule (sustained 100 for 4 s vaporizes regardless of detector state). Implementing v0.3 §6 kill rule changes that to "vaporize only fires while at least one un-stunned LOS detector currently has the sub."

**Implementation cost:** ~20 lines. Add a `hasActiveDetector()` predicate that returns true iff at least one Siren (a) is not stunned, (b) is within detection radius, (c) has LOS to the sub. Gate the instakill trigger on this predicate. Note this is **not yet present in v7 either** — claude.ai also has not implemented the v0.3 kill rule in code at the time of file capture.

**Invariant pressure:** Strengthens INV5 (fairness valve) — EMP becomes a real survival tool. No invariant collision.

**Pat ratify?** Yes — Pat already ratified the design in v0.3; the implementation pull-in is just executing.

### Pull-in #3 (MEDIUM): Procedural audio module

**Why:** v0.3 §10 promotes audio to core pillar with Iron Lung explicitly cited. Our chain held v0.2 (audio = form pass). Audio is cheap-to-implement (~25 lines for the AU module + ~10 lines of `AU.x()` calls); Web Audio is browser-native, no asset pipeline. Iron Lung benchmark is the strongest single comparable in our genre, and Iron Lung's whole gut-punch was sound.

**Implementation cost:** ~40 lines. Translate claude.ai's `AU` const verbatim and wire `AU.ping()`, `AU.emp()`, `AU.knock()`, `AU.cap()`, `AU.boom()`, `AU.surface()`, `AU.beat()`, `AU.startAmb()` into our existing event seams (`tryActivePing`, `fireEMP`, `fireKnockdown`, `tryDronePhoto`, end-vaporized, end-extract, suspicion-state-transitions, init).

**Invariant pressure:** v0.2's INV6 says "no... sound... until systems are built and tuned." Our chain is past tuning (Step 7 GREENLIGHT). Adding audio now is consistent with INV6 read as a sequencing constraint, not a permanent prohibition. v0.3's INV6 explicitly carves audio out as a build pillar.

**Pat ratify?** Yes — this is a spec-version swap (v0.2 -> v0.3). Pat to ratify the spec swap before we touch the build.

### Pull-in #4 (MEDIUM): Speed-as-noise + silent running

**Why:** Spec v0.3 §6 — throttle generates a noise signature heard by Sirens. Silent-running toggle zeroes noise. Adds depth-without-buttons (silent running is one bind). Solves "moving is being heard" (Knot B from v0.3 §1).

**Implementation cost:** ~15 lines. Compute a noise-emitter radius `noiseR = sub.speed × noiseGain`; any Siren within `noiseR` gets an investigate-here event. Silent-running toggle zeroes `sub.speed` (and skips drag, so the sub freezes). Costs: oxygen still ticks during silent.

**Invariant pressure:** New mechanic; falls under spec v0.3. Doesn't violate any v0.2 invariant.

**Pat ratify?** Yes — spec v0.3 ratification covers this.

### Pull-in #5 (LOW-MEDIUM): Narrative log fragments

**Why:** Spec v0.3 §11. "Cheap, high meaning-payoff (Iron Lung's whole gut-punch was one letter)." 2-3 logs at hardcoded world positions. Read picks up on proximity, modal display.

**Implementation cost:** ~20 lines. Pat-authored text in 2-3 strings; `logs[]` array; proximity check in update; existing modal-overlay code adapted.

**Invariant pressure:** Touches narrative/lore. INV6 (function before form) is the relevant tension; logs are a soft-form addition. Defensible if Pat ratifies as part of v0.3 swap.

**Pat ratify?** Yes — needs the actual log text from Pat.

---

## 11. Recommended hold-outs (claude.ai ideas to NOT pull)

### Hold-out #1: THE HUNT global pressure meter (in current shape)

**Why hold:** The pressure_design.md proposal is mechanically interesting and v7 implements it. But it lives in tension with v0.2 INV2 ("Suspicion is the spine. Threat escalation runs through the suspicion meter and its four states — not through scripted aggression or RNG"). A second global meter is **not scripted aggression**, but it is a second axis competing with suspicion for the "this is the difficulty engine" role.

The pressure_design.md itself surfaces 4 open decisions for Pat that we don't have ratifications on:
1. Hunt climb rate (methodical vs. urgent)
2. Oxygen — keep as backstop or fold into Hunt
3. Graze damage feel
4. Pure ratchet vs. partial decay

**Recommendation:** Don't pull THE HUNT until Pat playtests v7 and either (a) ratifies its current shape into v0.4 or (b) folds the escalation-on-capture into suspicion's existing baseAlert ratchet. The v7 implementation also drifts from the pressure_design.md numbers (`huntTime:0.2` in v7 vs. proposed 0.6 in the doc) suggesting in-claude.ai tuning; the ratification surface is unstable.

**If Pat does ratify:** the math is ~40 lines and slots in cleanly above our existing suspicion math (Hunt drives a per-Siren detection multiplier; suspicion drives state transitions; both feed the kill rule).

### Hold-out #2: Graze damage (in current shape)

**Why hold:** v0.2 INV1 says "No player kill-path" — graze is NOT a kill-path (it's hull-bleed), so it doesn't violate. But it DOES change the lose surface: in our chain, hull = ram-contact-only; in v7, hull = graze-from-detection-too. That means a sustained Hostile state becomes survivable but hull-leaking, which is a different game shape than ours.

The dev notes Round 1 says "EMP is quite strong" — graze is partly a response to "too easy" by adding a always-on cost at high suspicion. Our chain's tuning (Hunter pursue 75, oxygen 210) is already trying to solve "too easy" via different levers.

**Recommendation:** Hold until Pat playtests both builds back-to-back and rules on whether the graze layer makes the game feel right or just adds chip-damage noise.

### Hold-out #3: Spec v0.3 §12 environmental texture (currents + thermal)

**Why hold:** Pure form / texture additions. v0.3 itself flags them as "mostly form" and puts them last in the v0.3 build order (step 9). v7 partly implements thermal (the `thermalY0/Y1/Mul` band). This is a real form-pass scope; pulling before form pass risks contaminating the tuning surface.

**Recommendation:** Defer to form pass. Note the band rendering pattern from v7 — it's ~5 lines and trivially re-implementable later.

### Hold-out #4: Map portrait + scroll redesign

**Why hold:** Pat ratified this for claude.ai on Round 1 ("Wouldn't mind a larger map with edge scroll"). That ratification did not reach our chain. Our chain is at landscape 960x640 + Step 8 mobile + 8 audited steps of game logic against that geometry. A map-shape change at this point would invalidate Sentinel orbit positions, Hunter dormant position, factory rect, all 10 Patroller waypoints, all hand-authored terrain.

**Recommendation:** Hold. If Pat wants the larger map / scroll, that's a from-spec-rewrite that re-runs the daisy-chain against new geometry, not a patch-in. Better path: ship our 960x640 build, get a playtest read, then decide if scroll is needed.

### Hold-out #5: 4 Sirens instead of 3 (in current shape)

**Why hold:** Spec §7 says three types (Patroller / Sentinel / Hunter). claude.ai's 4 (2 Patrollers) is a content-instance choice, not a type addition. Our chain holds to spec. Adding a second Patroller is trivial (~5 lines + waypoint list) but should be playtest-driven, not Round-1-of-a-prototype-driven.

**Recommendation:** Hold for now. If Pat plays our build and feels EMP-too-strong / decoys-pointless (the Round 1 finding), add a second Patroller as a tuning patch.

---

## 12. What this comparison tells us about the spec

The strongest single finding: **the six invariants are the most reliable part of the project.** Both substrates respect them. Drift happens around numerics (suspicion costs, oxygen length, pursue speed), around visualization (shadow cones vs. raycast-only), around mechanics-not-in-v0.2 (HUNT, graze, audio, silent running), but never around the invariants.

The second strongest finding: **the v0.2 -> v0.3 spec evolution happened in claude.ai-space without reaching our chain.** The mechanics in v7 that our build lacks (HUNT, graze, silent running, audio, narrative logs) are all v0.3 additions. The right path forward is not "import the v7 code" — it's **Pat ratifies v0.2 -> v0.3 swap as a spec event**, then we either run a v0.3 daisy-chain (steps 1-9 per v0.3 §15) against our existing substrate, or we patch the new mechanics in as targeted extensions of the current build.

The third finding: **our chain's process overhead (audits, sims, citations, backups) is real labor.** It bought us auditability and resumability through token deaths and Pat-absence windows. claude.ai's process overhead is lower because Pat is in the conversation continuously. Neither is wrong; they serve different substrates of the same project.

---

## 13. Open Pat-decisions surfaced by this comparison

These are decisions Pat needs to make to consolidate the two tracks. None are blocking the current build; all are pending direction-of-travel calls.

1. **Spec version ratification.** Promote spec v0.3 to canonical for the Cowork chain, supersede the on-disk `SIRENS_SONG_SPEC.md` (v0.2)? Or hold v0.2 as canonical and treat claude.ai's v0.3 work as exploratory?
2. **Shadow-cone LOS rendering.** Pull-in #1 — recommend high. Ratify?
3. **EMP kill rule fix (v0.3 §6).** Pull-in #2 — recommend high. Ratify?
4. **Procedural audio.** Pull-in #3 — recommend medium-high. Ratify?
5. **Speed-as-noise + silent running.** Pull-in #4 — recommend medium. Ratify?
6. **Narrative log fragments.** Pull-in #5 — requires Pat-authored log text. Ratify + author?
7. **THE HUNT.** Hold-out #1 — pulled only if Pat plays v7 and finds it lands. Decision?
8. **Graze damage.** Hold-out #2 — same as above. Decision?
9. **Map shape.** Hold-out #4 — 960x640 vs. portrait + scroll. Decision?
10. **Sirens count.** Hold-out #5 — 3 vs. 4 (second Patroller). Decision?
11. **Oxygen direction.** 210 s squeeze vs. 300 s backstop. Which philosophy?
12. **Suspicion decay.** Sticky (3/s + delay) vs. clean (5/s). Which philosophy?

These accumulate to the next ratification queue. Each is independent — Pat can pull #2 without pulling #7. The pull-ins are scoped to land cleanly on top of our current Step 8 substrate.

---

*AI-DESIGNED. Comparison analysis authored 2026-06-05 by Cowork research agent (Keel, Claude Opus 4.7-1M). Source files in `Inbox_from_Claude.ai/Siren's Song claude web/`. Authority: SIRENS_SONG_SPEC.md (Cowork canonical, v0.2) + the v0.3 spec in inbox (claude.ai canonical) — Pat to reconcile. Pat ratifies nothing in this document; it is read-and-rule input.*
