# Siren's Song — Project Context (cold-instance pickup briefing)

**Last updated:** 2026-06-05 by Cowork research agent (Keel, Claude Opus 4.7-1M).
**Purpose:** Single-document orientation for any cold instance picking up this project. Read this first. Then read the spec. Then ask Pat.
**Project root:** `C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\`
**Canonical authority:** `SIRENS_SONG_SPEC.md` (v0.2) is the on-disk source of truth. A v0.3 spec exists in `Inbox_from_Claude.ai/` from a parallel claude.ai track; Pat-decision pending on which is canonical going forward (see §8).

---

## 1. What Siren's Song is

A 2D top-down stealth game where the player pilots a fragile, slow, zero-kill experimental US submarine into an alien deep-sea factory, photographs it, and exfiltrates. The enemies — "Sirens" — are unkillable by design; the player's only survival is staying low enough on the suspicion meter that the Sirens read the sub as curious intruder rather than confirmed threat. Cross the threshold and they vaporize the sub on the spot.

**Genre tag:** *top-down stealth* — per `research/GENRE_AND_MONETIZATION_RESEARCH.md` §1, this is the discoverability-correct positioning. Not "submarine simulator" (wrong audience expectations — UBOAT / Cold Waters audience wants torpedo solutions and crew management; this is neither). Closest single-anchor reference is **Iron Lung** (Szymanski, 2022): one shift, one objective, the camera is the only way to see, every observation costs something.

**One-line pitch:** *Mark of the Ninja underwater, with unkillable enemies.*

**Player vessel:** experimental US stealth sub. Slow, fragile, hull pool of 3. Carries a sub-fallback camera (grainy, long-range, must close range to capture), torpedo-launched drones (point-and-click eyes + photography + decoy), and three disruption tools (jam, EMP, knockdown). No weapons that kill.

**Antagonists:** three Siren types — Patroller (predictable loop), Sentinel (orbit guarding power core), Hunter (dormant until Alert, then fast pursuit on last-known position). No HP, never killable. Tools stun them; they do not damage them.

**Core verbs:** see (passive sonar = free + near-blind; active ping = wide but loud; recon plane = expensive sector reveal; drone cam = local distributed eyes), move (face-and-thrust with momentum), deploy (drone → scout / photo / decoy), shoot (EMP / knockdown / jam — buy time, never kill), photograph (drone clean / sub-cam desperate), extract.

---

## 2. The six invariants (verbatim from `agent.md` §2)

These are the project canon. Any build, edit, or improvement that violates one is wrong by definition, even if it seems like a better game:

> 1. **No enemy HP. No player kill-path.** Sirens are never defeatable. Tools disrupt; they never deal lethal damage. A build that adds a Siren health bar has failed the brief.
> 2. **Suspicion is the spine.** Threat escalation runs through the suspicion meter and its four states — not through scripted aggression or RNG.
> 3. **Perceiving costs.** Every way of seeing carries a suspicion or scarcity cost. Nothing reveals the world for free except passive sonar.
> 4. **Tools buy time and cost heat.** No tool is consequence-free.
> 5. **Fairness valve is mandatory.** Suspicion decays; instakill only on sustained max with a warning window. One mistake must never be an un-survivable instant restart.
> 6. **Function before form.** No art, sound, palette, or UI-chrome work until the systems are built and tuned. Form is always a later, separate pass.

If a code change conflicts with one of these, the invariant wins. Always.

---

## 3. Mechanical inventory

The current build at `code/sirens_song.html` (Steps 1-8 GREENLIGHT) implements:

### Sub physics
Continuous 2D top-down. Heading + position. Face-and-thrust handling: WASD/arrows turn-toward-cursor at a capped angular rate and drive along the nose. Inertial: velocity accumulates against an acceleration cap; terminal max 80 px/s under sustained thrust. Wall bumps zero the velocity (fairness — one bad press = one hull tick, not ongoing drain). Hull pool of 3; depletion = sunk lose. Oxygen drain at `OXYGEN_MAX_SECONDS = 210` (Step 7 tuned — clean run ~90-120 s, dithering runs out).

### Sonar (passive + active, both LOS-occluded)
Passive sonar always-on, 90 px ring around the sub, free. Active ping (SPACE / PING button) 360 px wide reveal, 3.0 s fade, +25 suspicion, also writes an investigate-here point into every Siren in earshot. Both modes raycast against axis-aligned terrain rectangles via `isLineOfSightClear()` — entities behind rock do not show up. Drone cam (per drone) is also LOS-occluded.

Recon plane call-in (key 4 then click) — 460 px disc reveal, 8.0 s duration, +8 suspicion. **Not LOS-gated** by design (recon is a flyover from above; that's the meaningful distinction between recon and the three local reveal modes).

### Hunter AI (last-known-position search)
Hunter is dormant at (200, 60) until suspicion reaches Alert; then pursues at 75 px/s (Step 7 tuned, was 90). Modes: `dormant | investigating | pursuing | returning`. When the player active-pings, the Hunter writes the ping origin as its investigate target and converges on it. If the Hunter reaches the target without finding the player, it returns toward dormant position.

### Suspicion system (CURIOUS / ALERT / HOSTILE states + fairness valve)
Scalar 0-100. Sources: active ping +25, drone photo +15, EMP +20, knockdown +20, jam +5, recon +8, factory proximity +3/+2/+1/0 at ≤140/≤260/≤420/else, Siren-proximity scaled by distance, ram contact at Alert+. Decay −5/s when below max, paused during the active ping window (decay also netted against factory-proximity gain — folded into a `netRate` block).

Three threshold bands: **CURIOUS** (0-33) / **ALERT** (34-74) / **HOSTILE** (75+). Step 7 audit relabeled the third state from "WARNING" to "HOSTILE" for legibility (the WARNING red banner overlay remains separately as the valve-cue at suspicion ≥ 75).

**Fairness valve (INV5, the most critical seam):** instakill timer accumulates only while suspicion ≥ 100. Reset the instant suspicion drops below 100. Vaporize fires at sustained 100 for 4.0 s. A 3.0 s spike survives; a 4.1 s spike kills. The valve was sim-verified in Step 7 audit: `step7.valve.3s-spike-survives` PASS / `step7.valve.4.1s-spike-vaporizes` PASS.

### Drones (5 supply initial)
Torpedo-launched at left-click. Drone speed 110 px/s. Drone-cam reveal radius per drone is its local vision. F key takes a drone photo at any objective within 90 px (suspicion +15). Right-click redirects the nearest drone to a new target. TAB cycles selected drone. B toggles decoy mode on the selected drone (per Pat 2026-06-03 ruling: passive parked drones draw Curious-state Sirens via 180 px range; toggled-active decoy mode draws at 320 px). Drones destroyed by Sirens at Alert+ contact. No drones left? The sub-fallback cam still works — 320 px silhouette range from the sub directly. Sub-cam-only is possible but risky (forces the sub into the hot zones).

### Suspicion → Siren behavior + curiosity
Every Siren has a `state` derived from the global suspicion band PLUS local proximity:
- **Curious** Sirens (including Patroller, Sentinel, Hunter) will move to investigate a decoy or a recent ping — slow, non-lethal approach.
- **Alert+** Sirens destroy drones, ram the sub (1 hull on contact, shared 0.6 s i-frame cooldown), and pursue at type-specific speeds.

### Disruption tools
- **Jam (key 1):** sub-centric, no target, 3 charges initial, +5 suspicion, 4.0 s window. Halves each Siren's proximity contribution + clears `lastPing.valid` (scrambles localization).
- **EMP (key 2 then click):** 3 charges initial, +20 suspicion, 5.0 s stun. Hits any Siren within EMP range at click point. Routes through `isSirenStunned()` predicate — stunned Sirens skip their update entirely.
- **Knockdown (key 3 then click):** 2 charges initial, +20 suspicion, 12.0 s stun (longer window than EMP, rarer charges). Same stun chokepoint.

All three fire paths route suspicion through the `applySuspicion(amount, sourceTag)` chokepoint. Tools work cleanly when desktop or touch — same code paths.

### Recon plane call-in
Key 4 arms, left-click designates sector center. 2 charges initial. 460 px reveal disc, 8.0 s duration, +8 suspicion. Multiple concurrent reveals supported (can fire both charges and have both active in parallel). Does NOT refresh Siren detection inputs (recon is not listed in spec §7 detection inputs).

### Mobile controls layer (Step 8 extension)
Touch detection at boot via `'ontouchstart' in window || navigator.maxTouchPoints > 0`. When true, `body.touch-mode` class added. Joystick (bottom-left ~22vmin pad, deadzone 0.22) synthesizes KeyW/A/S/D into the same `keys` Set the keyboard handler uses. 13-button action tray (bottom-right): PING / DEPLOY / REDIR / JAM / EMP / KD / RECON / PHOTO-F / PHOTO-G / DECOY-B / CYCLE / ? / RESTART. Each button calls the existing game function or sets `state.armedTool`. Canvas tap-coord transform: `gameX = (touchClientX − canvasRect.left) × (canvas.width / canvasRect.width)`, verified to <1px tolerance across 8 test points / 3 rect configurations. Responsive canvas via CSS `aspect-ratio: 3/2` wrapper; internal resolution preserved at 960×640. Portrait warning overlay shown when not landscape.

Per Pat's hard constraint (received between build + audit on 2026-06-04): *"it should be playable with touch or keyboard and mouse because I don't want you undoing all the work that actually works already just to make it mobile playable."* Auditor proved byte-equivalent JS body via MD5 strip-check of the additive Step 8 blocks.

---

## 4. Pat-ratified canon

These are explicit Pat ratifications mined from handoffs / audits / orchestrator close-out docs. Verbatim where impactful. Pat-canon ≠ Keel-synthesis; treat these as load-bearing.

- **2026-06-03** Pat ratified the daisy-chain orchestration approach for the build. Spec is canonical; agent.md is the operating doc; each step gets a brief; each step-agent writes a handoff; each step gets an audit; chain stops at Step 7 per §11.
- **2026-06-03 (Pat-injected diagnostic notes for brief 01, post-Step-1 GREENLIGHT):**
  > "passive sonar through rock is wrong. Make sure terrain raycasts block both detection paths — the player should not be able to see a Patroller silhouette through a wall via passive radius, and the active ping should also be terrain-occluded."
  >
  > "the submarine needs to feel like a submarine. Subs have inertia, slow turn radius, depth-change momentum, no snappy arcade controls. Build player vessel handling with weight. If it feels like 2D top-down ship arcade, it's wrong."
- **2026-06-03** Pat ruling on decoy mode: passive (any parked drone draws Curious Sirens) AND active (toggle B on a drone for stronger draw via larger effective radius). Both behaviors implemented in Step 3 / Step 4.
- **2026-06-04** Pat ratified Step 8 (mobile controls + responsive layout) as an extension beyond the §11 7-step build leash, post-Step-7 GREENLIGHT.
- **2026-06-04** Pat's hard constraint (received between Step 8 build + audit dispatches):
  > "it should be playable with touch or keyboard and mouse because I don't want you undoing all the work that actually works already just to make it mobile playable."
- **2026-06-05** Pat re-articulated the dispatch architecture for off-chain work:
  > "Dispatch to Claude Code, not just Cowork"
- **2026-06-05** Pat ratification of the project promotion (this document set): "promote sirens-song from loose Dispatch sessions into a proper project space."
- **2026-06-05** Pat correction (re: T:\ vs C:\ paths and what looked like a CGI rule violation that was actually directed work):
  > "I told it to do that... you keep assuming that because it's happening that it's something you did wrong"
- **2026-06-05** Pat reinforcement (re: time-check discipline / mistaken time-of-day reference):
  > "1am has been past for 9 hours"

The six domain invariants in §2 are Pat-ratified canon through the v0.2 spec wrapper.

---

## 5. Two parallel implementations

Siren's Song exists in two implementation tracks. Both single-file HTML+JS+Canvas. Both Pat-driven. The tracks ran in parallel from 2026-06-03 onward and have not been reconciled.

### Cowork chain version
- **Path:** `C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\code\sirens_song.html`
- **Substrate:** Dispatch sub-agent daisy-chain. 8 numbered build steps (1-7 per spec §11, Step 8 as Pat-ratified extension). Each step has a brief, a build receipt (`handoffs/`), and an audit (`audits/`). Verbose code with `// INV` citations at critical seams. `__sim` harness with 73 entries for headless verification.
- **Built against:** `SIRENS_SONG_SPEC.md` v0.2.
- **State (2026-06-05):** 135,266 bytes / 3,196 lines. JS body passes `node --check`. All 8 steps GREENLIGHT, zero FIX REQUIRED loops, zero PAT_INTERVENTION escalations across the chain. Smoke-tested 2026-06-05 via jsdom on both desktop (1280×800) and mobile (375×812) — 0 console errors, 0 uncaught exceptions, rAF firing, 180-frame update drive clean.

### claude.ai parallel version
- **Path:** `C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\Inbox_from_Claude.ai\Siren's Song claude web\`
- **Substrate:** Interactive claude.ai prototype sessions. Iterated through 4 playtest rounds with Pat in-the-loop.
- **Files:** `sirens_song_prototype.html` (44,721 B / 580 lines, earlier) + `sirens_song_prototype_v7.html` (47,365 B / 607 lines, later — includes THE HUNT meter + graze damage).
- **Spec evolution:** `SIRENS_SONG_functional_spec.md` v0.3 (15 sections vs. our 11) in the inbox is the claude.ai canonical spec. Adds noise/silent-running, audio promoted to core, photo scoring, factory escalation, search memory, narrative fragments, currents/thermals.
- **Companion docs:** `SIRENS_SONG_dev_notes.md` (process record, 4 playtest rounds) + `SIRENS_SONG_pressure_design.md` (THE HUNT proposal).

**Pointer:** See `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` for the full convergence/divergence comparison and pull-in recommendations. That document surfaces 12 open Pat-decisions for reconciling the two tracks. Spec version (v0.2 vs. v0.3 canonical) is decision #1 in that queue.

---

## 6. Current state / playable

### Code path
`C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\code\sirens_song.html`

Open in any modern browser. Single file, no toolchain, no external dependencies.

### Backup ladder (rollback-ready)
All in `code/`:
- `sirens_song.html.bak.pre-step1-fixpass-20260604` (41,825 B)
- `sirens_song.html.bak.step2-pre-step3` (23,523 B)
- `sirens_song.html.bak.pre-step4-20260604` (55,234 B)
- `sirens_song.html.bak.pre-step5-20260604` (79,522 B)
- `sirens_song.html.bak.pre-step6-20260604` (97,702 B)
- `sirens_song.html.bak.pre-step7-20260604` (110,327 B)
- `sirens_song.html.bak_pre_step8` (112,450 B, byte-identical to Step 7 close)

### Controls — keyboard + mouse (desktop)
- **WASD / arrows** — move sub (inertial; turn-to-heading + thrust along nose)
- **SPACE** — active ping (+25 suspicion, 360 px reveal, 3.0 s fade)
- **Left-click on world** — deploy drone (consumes 1 drone)
- **Right-click on world** — redirect nearest drone to clicked target
- **TAB** — cycle selected drone
- **F** — drone photo at nearest objective within drone range (+15 suspicion)
- **G** — sub-cam photo at silhouette range (320 px, no flat suspicion cost — exposure does the work)
- **B** — toggle decoy mode on selected drone (active draw 320 px)
- **1** — fire jam (sub-centric, +5 suspicion, 4.0 s window)
- **2 then click** — fire EMP at click point (+20 suspicion, 5.0 s stun in radius)
- **3 then click** — fire knockdown at click point (+20 suspicion, 12.0 s stun, single-target)
- **4 then click** — call in recon at click point (+8 suspicion, 460 px reveal, 8.0 s duration)
- **R** — restart from menu / restart from lose state

### Controls — touch (mobile)
- **Joystick bottom-left** — directional sub thrust (synthesizes WASD)
- **Action tray bottom-right** — PING / DEPLOY / REDIR / JAM / EMP / KD / RECON / PHOTO-F / PHOTO-G / DECOY-B / CYCLE / ? / RESTART buttons
- **Canvas tap** — when armed-tool is set (EMP / KD / RECON / DEPLOY / REDIRECT), tap the world to fire/place
- Portrait warning shows when device is portrait; landscape recommended

### What works (sim-verified across 8 audits, 500+ cumulative sim tests, 0 failures)
- Sub movement + inertia + collision + LOS occlusion (Step 1 + fix-pass)
- Active ping + suspicion +25 + LOS-gated reveal + Siren-investigate-summon (Step 1 + 2)
- Suspicion meter + 3 states + 4 s instakill at sustained 100 + fairness valve (Step 2)
- Patroller 10-waypoint loop + Alert+ ×1.6 speed + ram damage at Alert+ (Step 2)
- Drones deploy / move / redirect / photo / decoy-toggle (Step 3)
- 4 photo objectives (silhouette / bays / power_core / factory) + win condition (Step 3)
- Factory proximity scaling +3/+2/+1/0 by distance band (Step 3)
- Sentinel 40 px orbit + 220 px detect + investigate + return-to-orbit (Step 4)
- Hunter dormant → investigate → pursue → return-to-dormant (Step 4)
- Curiosity-state behavior cross-cutting all three Siren types (Step 4)
- Jam / EMP / Knockdown + universal stun chokepoint + finite charges (Step 5)
- Recon plane call-in + 460 px disc reveal + multi-concurrent + not-LOS-gated (Step 6)
- Step 7 tuning: oxygen 210 / Hunter 75 / recon 460 / HOSTILE label
- Step 8 touch overlay + responsive scaling + portrait warning + viewport meta (Step 8)

### What's verified
- All 6 invariants hold across all 8 steps
- `node --check` clean on the JS body
- jsdom smoke test 2026-06-05: 0 errors, 0 uncaught, both desktop and mobile boot paths
- MD5 byte-equivalence of pre-Step-8 JS body when Step 8 additive blocks are stripped (proves desktop path was not silently refactored)

### What's not yet tuned (playtest-driven dials)
- `OXYGEN_MAX_SECONDS = 210` is a sim-midpoint estimate. If clean runs need >180 s in real playtest, bump back toward 240; if dithering still feels loose, drop to 180.
- `HUNTER_PURSUE_SPEED = 75` may feel under- or over-threatening in real play. Step 7 audit flagged this as one of the tuning levers.
- Jam strength 0.5 is a guess (spec is silent on a number). Lower (0.2) = more dramatic; higher (0.8) = softer.
- `RECON_REVEAL_RADIUS_PX = 460` may want to scale further for legible flyover-distinct-from-ping.

### Known edge cases
- **Literal-stationary-sub aggression hull-sinks at t≈8.4 s** rather than vaporizing at 4.0 s (Step 7 audit). Cause: suspicion oscillates 50-87 when the sub is literally stationary, never saturating; Hunter (at the new 75 px/s) reaches the stationary sub before vaporize. Aggression-active (player using tools while sub moves) DOES vaporize cleanly at t=4.1 s. Build-agent and auditor both read the brief as the active case; the stationary case is degenerate. Pat to rule whether this needs fix (lower Hunter speed further) or hold.
- **Touch listeners bind unconditionally** on desktop (Step 8 audit cosmetic flag). On non-touch desktop the listeners exist but touch events never fire and `display: none` makes button click-targets unreachable. Cosmetic, not functional. Build-agent justified this for `__sim` testability.
- **Sub-cam-only path is possible but risky** (Step 3 audit). Sim captured all 3 photos via sub-cam at point-blank, but those positions sit the sub inside Sentinel detect range + Hunter pursuit range + factory NEAR proximity (+3/s). Spec design intent ("drones are safe path, not only one") confirmed.
- **Patroller curiosity may skip one waypoint** when returning from investigation (Step 4). Spec §7 says "fixed looping route" — currently the route is a loop and the Patroller will re-visit any skipped waypoint within one cycle. Pat call if same-waypoint resume is required.
- **Multi-Siren coordination is "all converge on last-known contact"** (Step 4) — basic version per brief. Spec §6 "coordinated hunt" at Hostile suggests flocking (triangle formation around lastPing). Deliberately deferred.
- **Edge collision = hull loss** (Step 1). Spec doesn't explicitly say edges deal hull. Treated edges as terrain so the sub can't camp the edge. Pat call if edges should be hard walls instead.

---

## 7. Genre + monetization research summary

Distilled from `research/GENRE_AND_MONETIZATION_RESEARCH.md` (5 sections, 25+ cited sources, authored 2026-06-05).

**Genre positioning.** The game does not sit cleanly in any single existing bucket; it sits at the intersection of four — top-down 2D stealth (Mark of the Ninja), submarine-flavored horror (Iron Lung), asymmetric-information stealth (Hunt: Showdown, Splinter Cell), and survival horror with environmental dread (SOMA, Subnautica). The primary tag should be **top-down stealth** for discoverability; the secondary "X-meets-Y" positioning is *"Mark of the Ninja underwater, with unkillable enemies."* Avoid "submarine simulator" tagging — wrong audience expectations (UBOAT/Cold Waters players expect torpedo solutions and crew management, neither of which exist here) — and avoid "horror" tagging because the spec is stealth-tension, not jump-scare; over-promising horror invites the wrong reviewers.

**Iron Lung as realistic earnings anchor.** Iron Lung (Szymanski, 2022, $5 single-developer release) is the closest comparable on every axis except genre word-tags — single objective, single shift, the camera is the only way to see, ~45 min runtime. Pre-spike it sold modestly; the OceanGate Titan incident in June 2023 ~3x'd sales briefly; a film adaptation followed. Treat Iron Lung's PRE-spike trajectory as the realistic earnings band for Siren's Song. Iron Lung's whole gut-punch was sound — a strong signal that audio matters more than visuals at this scale.

**Web portal path (Poki / CrazyGames).** First-game web titles can earn $500-$3,000/month on the major portals if accepted, per [IndieGameBusiness](https://indiegamebusiness.com/web-gaming-for-indie-developers/). Acceptance is curated and not guaranteed — Siren's Song's stealth-tension design is not the typical casual web-portal game (portals favor short loops, hyper-replayability; this is more 30-min experience). Worth submitting as a screening test; free to try.

**Title hedge needed.** "Siren's Song" is heavily used in gaming and adjacent media; no exact-match game-title trademark surfaced in available searches, but the phrase appears in: Sker Ritual: Siren's Song (Wales Interactive DLC), Voiceless: A Siren's Song (Choice of Games WIP), Siren's Song Games (Meghan Cross's tabletop publisher), and tonally near Sony's PS2 Siren series. USPTO search at [tmsearch.uspto.gov](https://tmsearch.uspto.gov/) in Classes 9 and 41 recommended before commercial release. Hedges in order of distinctiveness: Deep Contact (Pat's working title before v0.2) / The Quiet Depth / Below Listening / Aphotic. Pat's call.

**Recommended stack.** itch.io PWYW + Patreon + Ko-fi tip jar + Poki/CrazyGames submission. Ship v1 free or PWYW, see what traction looks like over 3 months, then decide whether Steam (Electron wrap) is worth the prep effort. That stack is ~1 week of total work and preserves the single-file constraint. Steam requires a wishlist base + a month of marketing prep; only worth it once itch proves the loop. Mobile (Capacitor wrap) is deferred until itch surfaces real mobile demand — the App Store $99/yr overhead is real if the game earns $0.

---

## 8. Open Pat-decisions

From `ORCHESTRATOR_COMPLETE.md` §"For-Pat notes" — 19 items accumulated across the 8-step chain. Plus 12 new items surfaced by `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md`. Plus 4 strategic items from `research/GENRE_AND_MONETIZATION_RESEARCH.md`. Total ratification queue: 35.

### From Step 1-8 chain (19 items)
**Design ratifications (build-agent decided; Pat may reverse):**
1. Recon is NOT LOS-gated (Step 6, ratified Step 7). Reversible.
2. Multiple concurrent recon reveals (Step 6). Player can fire both charges and have both active. Reversible.
3. Recon does not refresh Siren detection inputs (Step 6). Not in spec §7 detection inputs.
4. Weapon LOS uses sub-to-target, not drone-to-target (Step 5). Drone-cam reveals don't enable fire-through-rock.
5. Target pick radius 90 px for EMP/KD (Step 5) — forgiving on placeholder canvas.
6. Decay paused during active ping window (Step 2). Both spec-legal readings.
7. State distinction strictness (Step 2). Instakill timer resets on <100, not <75.
8. Heading-locked thrust vs. strafing (Step 1). Forward/back+turn implemented; 8-dir strafe was the alternative.

**Open observations (not blockers, surfaced for playtest):**
9. **Literal-stationary-sub aggression hull-sinks at t≈8.4 s** rather than vaporizing (Step 7 audit).
10. OXYGEN_MAX_SECONDS=210 is a midpoint estimate.
11. Sub-cam-only photo path is possible but risky (Step 3).
12. Patroller curiosity may skip one waypoint when returning from investigation (Step 4).
13. Multi-Siren coordination is "all converge on last-known contact" (Step 4) — flocking deliberately deferred.
14. HOSTILE label (Step 7) — if visually too aggressive, rename trivially.
15. No on-screen reticle / no out-of-charges feedback (Steps 5, 6). Tool failures silently no-op.
16. Sentinel orbit center == power_core position (Step 4). Form pass tweak.
17. Hunter dormant at (200, 60) is upper-left corner — visible from start. Alternative dramatic positions create occlusion gameplay; deliberately not chosen.
18. Jam strength 0.5 is a guess (Step 5). Spec is silent.
19. Edge collision = hull loss (Step 1). Spec doesn't explicitly say.

### From inbox comparison (12 items — see `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` §13)
20. **Spec version ratification.** Promote v0.3 to canonical or hold v0.2?
21. Shadow-cone LOS rendering pull-in (recommend high)
22. Spec v0.3 §6 EMP kill rule pull-in (recommend high)
23. Procedural audio module pull-in (recommend medium-high; INV6 question)
24. Speed-as-noise + silent running pull-in (recommend medium)
25. Narrative log fragments pull-in (needs Pat-authored log text)
26. THE HUNT global pressure meter (hold-out — requires playtest of v7)
27. Graze damage (hold-out — requires playtest of v7)
28. Map shape: 960×640 vs. portrait + scroll (hold-out — re-runs chain)
29. Sirens count: 3 vs. 4 (hold-out — playtest dial)
30. Oxygen direction: 210 s squeeze vs. 300 s backstop philosophy
31. Suspicion decay: sticky (3/s + delay) vs. clean (5/s) philosophy

### From genre/monetization research (4 items)
32. **Title hedge.** "Siren's Song" — keep / change. USPTO search outcome dependent.
33. **Sirens silhouette direction.** Make non-humanoid, non-female-coded for form pass — avoids Borderlands Sirens / Sony Siren / Subnautica Leviathan visual collision.
34. **Distribution stack.** itch.io first, Poki/CrazyGames submission, Patreon + Ko-fi, defer Steam — confirm or revise.
35. **v1 scope confirmation.** Single hand-authored site, no proc-gen, no meta-progression. Iron Lung shape. Confirm or revise.

Pat decides in any order. None are blocking the current playable build.

---

## 9. File map

Every load-bearing file in `sirens-song/`. One-line description per. Paths are project-relative; all are under `C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\`.

### Root-level
- `SIRENS_SONG_SPEC.md` — Canonical functional spec v0.2 (15 KB). 11 sections + wrapper + Decision Log. **Source of truth.**
- `agent.md` — Step-agent operating doc (13 KB). Mandate, 6 invariants, creative-license boundary, read-before-write checklist, write checklist, sim-test capability, constraints, failure modes.
- `ORCHESTRATOR_COMPLETE.md` — Steps 1-7 chain close-out (21 KB). Per-step summary, final code state, tuning values, fix-pass event, for-Pat notes (19 items), bookkeeping.
- `ORCHESTRATOR_COMPLETE_STEP8.md` — Step 8 addendum (10 KB). Mobile controls + responsive layout extension close. Pat's hard constraint proof.
- `ORCHESTRATOR_LOG.md` — One-line-per-event chain log (5 KB). Boot → Step 1 build → Step 1 audit → ... → smoke test.
- `claude_index.md` — Routing index for cold instances (7 KB). Read-first-if-cold pointer table.
- `PROJECT_CONTEXT.md` — This document. Cold-instance pickup briefing.
- `SESSION_NOTES_20260605.md` — Today's Dispatch session log.
- `smoke_test.js` — jsdom-based headless boot/runtime check for the HTML build (19 KB).
- `smoke_test_run_20260605.log` — Smoke test output (3 KB). Verdict: SAFE TO PLAYTEST.
- `package.json` / `package-lock.json` / `node_modules/` — minimal Node deps for the smoke test (jsdom only).

### `code/`
- `sirens_song.html` — The single build artifact (135 KB / 3,196 lines). HTML + JS + Canvas + touch overlay. Open in any modern browser.
- `code/sirens_song.html.bak*` — Seven dated backups for rollback (see §6 backup ladder).

### `briefs/`
- `01_sub_sonar_terrain.md` — Step 1 brief: sub movement + sonar + terrain + hull + oxygen. Includes Pat's late-arriving 2026-06-03 diagnostic notes for the fix-pass.
- `02_suspicion_patroller.md` — Step 2 brief: suspicion meter + Patroller + 4 thresholds + warning valve.
- `03_drones_camera_objectives.md` — Step 3 brief: drones + sub fallback cam + photo objectives + win/lose.
- `04_sentinel_hunter_curiosity.md` — Step 4 brief: Sentinel + Hunter + curiosity/decoy behavior.
- `05_disruption_tools.md` — Step 5 brief: jam / EMP / knockdown.
- `06_recon_call_in.md` — Step 6 brief: recon plane call-in.
- `07_tuning_pass.md` — Step 7 brief: tuning pass + mandatory scenarios.
- `08_mobile_controls.md` — Step 8 brief: mobile controls + responsive layout (extension).
- `AUDITOR_BRIEF.md` — Post-step verification operating doc for the auditor agent.

### `handoffs/`
Build-agent receipts. One per completed step, one for the fix-pass.
- `01_HANDOFF_FROM_STEP1.md` — Step 1 receipt
- `01_FIXPASS_HANDOFF_20260604.md` — Step 1 fix-pass receipt (LOS occlusion + sub inertia per Pat 2026-06-03 diagnostic notes)
- `02_HANDOFF_FROM_STEP2.md` through `08_HANDOFF_FROM_STEP8.md` — Steps 2-8 receipts

### `audits/`
Auditor reports. One per step.
- `01_AUDIT_STEP_01.md` GREENLIGHT through `08_AUDIT_STEP_08.md` GREENLIGHT
- All 8 audits ran 50-200 sim tests apiece, total ~500+ cumulative across the chain, 0 failures

### `research/`
- `GENRE_AND_MONETIZATION_RESEARCH.md` — Genre placement, IP-safe mechanic borrows, title risk, monetization paths, survival check. 5 sections, 25+ sources, 59 KB. Authored 2026-06-05.
- `CLAUDE_AI_INBOX_ANALYSIS_20260605.md` — Convergence/divergence comparison between Cowork chain and claude.ai parallel build. 13 sections. Authored 2026-06-05.

### `Inbox_from_Claude.ai/Siren's Song claude web/`
Parallel claude.ai prototype track. Not active for our chain; read for reference.
- `SIRENS_SONG_functional_spec.md` — Spec v0.3 (17 KB)
- `SIRENS_SONG_dev_notes.md` — Playtest log (8 KB)
- `SIRENS_SONG_pressure_design.md` — THE HUNT proposal (9 KB)
- `sirens_song_prototype.html` — Earlier prototype (44 KB / 580 lines)
- `sirens_song_prototype_v7.html` — Later prototype with HUNT + graze (47 KB / 607 lines)

### `tmp_audit_step6/`
Scratch directory from Step 6 audit. Non-load-bearing.

---

## 10. How to extend

Per the `agent.md` contract — if you're spawning to add a new mechanic or step, follow this:

### Read-before-write
1. `SIRENS_SONG_SPEC.md` — the spec
2. `agent.md` — your operating envelope
3. `PROJECT_CONTEXT.md` — this file (current state)
4. `briefs/NN_<your step>.md` — your assignment
5. Previous step's handoff at `handoffs/NN-1_<previous slug>.md`
6. Previous step's audit at `audits/NN-1_AUDIT_STEP_NN-1.md`
7. Current code at `code/sirens_song.html`

### Build
- Single file: HTML + JS + Canvas, all in `code/sirens_song.html`. Don't split files.
- Syntax must be valid. `node --check` before declaring done.
- No fabrications. If a tuning number isn't in the spec, use the spec default with a `// TUNING(default per spec §X)` marker.
- No scope creep. Your step is your step.
- Comment the invariants you're touching: `// INV5 fairness valve`, etc.
- Use the `__sim` harness to expose internal state for sim tests.

### Sim test
Use Node.js in the sandbox. Extract the `<script>` block, load via `new Function(...)` harness with DOM stubs, drive the game state through known sequences, assert.

### Write
- Code increment goes to `code/sirens_song.html`
- Backup pre-edit state to `code/sirens_song.html.bak.pre-step-NN-YYYYMMDD`
- Handoff README to `handoffs/NN_<your slug>.md` per `agent.md` §5.2 schema
- Receipt at end of handoff: `Step NN: COMPLETE / BLOCKED / PARTIAL` + `Ready for: audits/NN_AUDIT_STEP_NN.md`

### Stop
Your handoff is the seam; the orchestrator reads it and decides what fires next. You do not spawn the auditor or the next step yourself.

### If extending past Step 8
Step 8 was a Pat-ratified extension beyond the spec §11 7-step build leash. Future steps need the same explicit Pat ratification. If the new mechanic doesn't have a corresponding brief in `briefs/`, surface that and wait for Pat to author one (or write the brief yourself and tag it `AI-DESIGNED — Architect to ratify`).

---

## 11. Open issues / known edge cases

These are unresolved as of 2026-06-05 EOD. None are blocking the current build. All are surfaced for Pat's playtest read.

1. **8.4 s literal-stationary hull-sink** (Step 7 audit detail). Hunter reaches a stationary sub before the 4.0 s vaporize timer accumulates because suspicion oscillates 50-87 without saturating. Aggression-active (player using tools while sub moves) DOES vaporize cleanly at t=4.1 s. The brief's intent was the active case; the stationary case is degenerate. Pat to rule whether this needs a fix (lower Hunter speed further to 60-65, which would also weaken Hunter as a meaningful threat) or hold.
2. **Touch listeners bind unconditionally on desktop** (Step 8 auditor cosmetic flag). Listeners exist on non-touch desktop but events never fire and `display: none` makes button click-targets unreachable. Functionally clean. Cosmetic cleanup opportunity if Pat wants stricter isolation.
3. **No physical-device playtest from sandbox** (Step 8 close-out). All Step 8 verification is sim-based (53 build-side + 164 audit-side = 217 sims, 0 failures). Pat's mobile playtest is the empirical gate.
4. **Spec version uncertainty** (from inbox comparison). v0.2 on disk is canonical for the Cowork chain; v0.3 in the inbox is canonical for the claude.ai track. The two have diverged on noise/silent-running, audio promotion, kill rule, photo scoring, factory escalation, search memory, narrative fragments, currents/thermals. Pat decision pending.
5. **Title trademark risk** (genre research §3). "Siren's Song" surfaces in Sker Ritual DLC + Choice of Games WIP + Meghan Cross's tabletop publisher + adjacent to Sony's PS2 Siren. USPTO search needed before commercial release.
6. **Sub-cam-only path is technically possible** (Step 3 + 6 audits). Sim captured all 3 photos at point-blank, but those positions are inside Sentinel detect + Hunter pursuit + factory NEAR proximity. Spec intent ("drones safe, sub cam desperate") held. Pat to confirm sub-cam should remain functional vs. drone-required.
7. **Patroller waypoint resume after investigation** (Step 4). May skip one waypoint when returning from investigation. Patroller will re-visit any skipped waypoint within one cycle. Pat call if same-waypoint resume is required.
8. **Multi-Siren coordination** (Step 4). Currently "all converge on last-known contact"; spec §6 "coordinated hunt" at Hostile suggests flocking. Deferred.
9. **No on-screen reticle / no out-of-charges feedback** (Steps 5, 6). Tool failures silently no-op; HUD charge counters are the only signal. Form pass scope.
10. **Edge collision = hull loss** (Step 1). Spec doesn't explicitly say play-area edges deal hull. Treated edges as terrain. Pat call.
11. **PROVISIONAL — claude.ai inbox not yet reconciled into the build.** Five new mechanics from v0.3 (shadow-cone rendering, EMP kill rule fix, audio module, speed-as-noise + silent running, narrative log fragments) are recommended pull-ins in the inbox analysis. None are pulled until Pat ratifies.

---

*AI-DESIGNED. Cold-instance pickup briefing authored 2026-06-05 by Cowork research agent (Keel, Claude Opus 4.7-1M). Authority: `SIRENS_SONG_SPEC.md` (v0.2 on disk; v0.3 pending Pat ratification per inbox analysis). All paths reference `C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\`. Pat ratifies nothing in this document; it is orientation, not direction.*
