# SIREN'S SONG — Prototype Dev Notes

**Session date:** 2026-06-03
**Produced by:** Keel (Claude)
**Status:** Process record + build input. Findings are real; tuning numbers are first-pass.
**Companion to:** SIRENS_SONG_functional_spec.md

## ATTRIBUTION KEY

Every substantive claim in this document is tagged:

- **[PAT]** — Pat's direct words or explicit decisions, quoted or closely paraphrased from session
- **[CONFIRMED]** — Keel framing Pat explicitly ratified in session
- **[KEEL]** — Keel synthesis, implementation, or analysis Pat did not generate
- **[KEEL-FLAG]** — Keel-raised concern not resolved by Pat. Requires review.

Trust [PAT] and [CONFIRMED] as directional. Treat [KEEL] as context requiring Pat confirmation before building on it. Treat [KEEL-FLAG] as open questions only.

---

## WHAT THE PROTOTYPE IS

[KEEL] A single-file HTML/canvas playable slice built to feel-check the core loop while Cowork handles the real build. It implements: blind sub piloting, passive sonar + active ping, the suspicion meter and its four states, oxygen clock, obstacles with line-of-sight cover, multiple Sirens, recon/EMP/decoy tools, photo objectives, and the extraction win.

[KEEL] Deliberately out of scope in the prototype: drones (the sub's fallback cam stands in), terrain ramming damage, and any art/sound polish. The drone layer is the biggest spec system the prototype does not yet exercise.

---

## PLAYTEST FINDINGS (feedback → change)

The loop was iterated across four play rounds. Each finding is Pat's from playing it; each change is Keel's implementation in response.

### Round 1 — core loop
- [PAT] "felt the dread!" — the core loop landed emotionally on first play.
- [PAT] "sub and enemies are way too fast. Doesn't feel like underwater."
- [PAT] "Lack of environmental obstacles loses some of the fun."
- [PAT] "EMP is quite strong, I almost never needed decoys."
- [PAT] "Wouldn't mind a larger map with edge scroll."
- [KEEL] Changes: added velocity/drag momentum and dropped all speeds; doubled the world to 1200×1800 with a clamped follow camera; added rock obstacles that block movement and line-of-sight; rebalanced EMP down / decoy up; added a 4th Siren so decoy's crowd-control earns its place.

### Round 2 — economy and reveal consistency
- [PAT] "Suspicion drains too fast, doesn't really do much."
- [PAT] "Obstacles are visible from start instead of being revealed like the sirens."
- [PAT] "The factory should probably be a camera target too, otherwise it's just a random hazard zone."
- [KEEL] Changes: decay 7→3/s with a ~1.8s delay before it starts (suspicion is now a managed resource, not a transient); obstacles hidden until sonar/proximity reveals them, with a contact-flash so a bumped wall briefly shows; the factory became a 4th capture objective (PHOTOS x/4) sitting in the hot proximity zone, so the zone is a prize rather than a hazard.

### Round 3 — realism and handling
- [PAT] "EMP should be area of effect, auto targeting only one closest enemy isn't really realistic."
- [PAT] "The sub needs to handle more like a sub."
- [PAT] "Ping should make enemies investigate you."
- [PAT] "blocked by obstacles with a vision cone showing what you don't see."
- [KEEL] Changes: EMP became an area blast (stuns everything in radius); the sub got face-and-thrust handling (turns toward target at a limited rate and drives along its heading, no more strafing); pinging now writes an investigate point into every Siren in earshot so they converge on where you pinged; passive and ping reveal both became line-of-sight gated, with shadow wedges rendered to show blind spots.

### Round 4 — occlusion visibility
- [PAT] "Ping LOS blocker isn't working at all, it's definitely harder now."
- [KEEL] Diagnosis: the reveal logic was gating correctly (entities behind rock did stay hidden) — but the ping had no visual occlusion, so the blocking was invisible and read as broken. Fix: the ping now renders as a lit reveal disc with dark shadow cones carved behind rock.
- [PAT] "Much better and it looks cool as fuck now!"

---

## DESIGN INSIGHTS THAT EMERGED

- [KEEL] **Occlusion must be visible, not just logical.** Correct gating the player cannot see reads as a bug. This was the single clearest lesson — Round 4 was a rendering fix, not a logic fix.
- [KEEL] **The mechanic and the look converged.** The shadow cones let the player read their blind spots instantly instead of parsing a number; [PAT] confirmed with "looks cool as fuck now."
- [KEEL] **Ping-as-bait is the see=be-seen tension made behavioral.** Pat asked for ping to summon investigators; turning that into "ping reveals the map AND draws hunters to your old position" is what makes active sonar a real commitment rather than a free look.
- [KEEL] **Momentum is load-bearing for "underwater."** Instant velocity-to-cursor killed the feel; face-and-thrust with drag fixed it. Handling is a feel pillar, not a detail.
- [KEEL] **Sticky suspicion makes the spine work.** At fast decay the meter did nothing; low decay + a delay turned it into the resource the whole game is about.

---

## BUGS CAUGHT

- [KEEL] **Boot-order crash** (caught Round after first build): the render loop started at boot and read game state before `init()` had created it, throwing a TypeError on the menu. [PAT] reported the error. Fix: run `init()` at boot so state exists behind the menu. Lesson for the real build: any always-on render loop must have valid state from frame one.
- [KEEL] **Invisible ping occlusion** (Round 4, above): logic correct, feedback absent.
- [KEEL] **Dead EMP tap** (Round 1→2): EMP with no target in range did nothing with no feedback; fixed with a toast. Resolved.

---

## FINAL TUNING STATE (first-pass; all in the CFG block)

[KEEL] These are the values the prototype landed on. They are implementation choices, not ratified balance — tunable.

- Movement: maxSpeed 96, accel 2.2, turnRate 2.0, arriveR 110
- Perception: passiveR 130, pingMax 520, pingHear 680, investigateT 6.5
- Tools: EMP area-blast range 150 / stun 3.2s / x2; decoy pull 320 / x4; recon x2
- Suspicion: decay 3/s, decayDelay 1.8s, alert 34, hostile 75, instakill at 100 held 3.5s
- Oxygen: ~220s of air
- Content: 4 Sirens (2 Patroller, 1 Sentinel, 1 Hunter), 9 obstacles, 4 photo objectives incl. the factory

---

## OPEN THREADS

- [KEEL-FLAG] **Difficulty target undecided.** [PAT] noted "it's definitely harder now" but did not say whether current difficulty is the goal or wants easing. Levers offered, no decision: `pingHear`, `decay`/`decayDelay`, `investigateT`.
- [KEEL-FLAG] **"Vision cone" interpretation.** Keel built it as sonar occlusion shadows. Pat's approval ("looks cool as fuck") suggests this satisfied the ask, but a forward-facing flashlight-cone alternative was never explicitly ruled out.
- [KEEL] **Drones unbuilt.** The deploy/scout/expendable layer — half the identity per the spec — is not in the prototype. The biggest untested system.
- [KEEL] **Terrain & Cover not yet in the spec.** Obstacles, LOS cover, and sonar occlusion proved out in the prototype but the functional spec has no terrain section. Pending.

---

## WHAT THIS MEANS FOR THE REAL BUILD

[KEEL] Read of the implications — not Pat decisions:

- The core loop is validated as fun. Pat's "dread" on first play and "cool as fuck" on the occlusion are the green light on the central design.
- Occlusion visibility and movement handling should be treated as first-class requirements in the Cowork build, not late polish — both were the difference between "broken/flat" and "it clicked" in this process.
- Drones are the next thing to prototype, because they're load-bearing in the spec and entirely unproven in play.
