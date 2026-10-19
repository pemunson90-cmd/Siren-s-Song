# SIREN'S SONG — Build Handoff Manifest

Packaged 2026-10-18 for a Claude Code + Codex build run. This manifest is the index and the gap map. Every file in this zip is a byte-faithful copy from disk or a verbatim recovery from the chat. Nothing was rewritten, summarized, reconciled, or cleaned up. Game code and spec content were not touched.

---

## 0. Packaging environment note (read first)

The build transcript named in the session summary (`/mnt/transcripts/2026-06-04-18-32-06-sirens-song-game-build.txt`) is **not mounted** in this packaging environment, so it could not be used as a recovery source. Off-disk recovery was done instead by reading this conversation's own earlier turns directly. One artifact was recovered that way: the "Deep Contact" origin spec (chat turn 11). Anything that was never written to disk and exists only as in-place edit states or ephemeral temp files could not be recovered in full, and is listed under section 2 (MISSING). Nothing was reconstructed from memory.

---

## 1. File inventory

| Path | Version | Source | Bytes | md5 | What it is |
|---|---|---|---|---|---|
| `sirens_song_prototype_v7.html` | v7 | disk | 47365 | e142ae3c5fcc8a6c5758d6b8bae4d614 | Current playable build. Adds the Hunt system, graze/hull, the menu-chrome hide and the resize-ordering fix on top of v6. |
| `SIRENS_SONG_functional_spec.md` | v0.3 | disk | 16947 | 2c377c8e4cf4c6aa512913c038adc154 | Canonical design spec, §1–15. **Also contains** the Cowork Project Instructions wrapper (line 249) and the full Decision Log (line 306, entries v0.1/v0.2/v0.3). |
| `SIRENS_SONG_dev_notes.md` | 2026-06-03 | disk | 7753 | 4cfcc7e6ae3ea9826e84b66e7c1f9352 | Provenance-tagged playtest record, the FINAL TUNING STATE table, and OPEN THREADS. The tuning table is v6-era (pre-Hunt). |
| `SIRENS_SONG_pressure_design.md` | proposal v0.1 | disk | 8836 | b541814988b796dd7af6f2a76d35efde | "THE HUNT" design proposal. **The Hunt is documented here, not in the functional spec.** |
| `history/sirens_song_prototype.html` | v6 | disk | 44721 | becaefe38af0627288254644c4e6e4cc | Previous full build, the rollback anchor. Verified to contain no Hunt/graze/hull mechanics (the only "hunt" hits are the Hunter siren type). |
| `history/DEEP_CONTACT_original_spec.md` | origin | recovered (chat turn 11) | 2202 | 163880a718cd9e79268feb6ab31b3047 | The original one-shot pitch titled "Deep Contact": the sonar-classification concept that later evolved into Siren's Song. It was an inline chat code block, **never a saved file**. Reproduced verbatim (its em dashes and spacing are the artifact's own, not this packaging run's). |

### Item mapping to your request
- **(1) current build** -> `sirens_song_prototype_v7.html` (root). Present.
- **(2) v1–v6 in /history** -> only **v6** exists as a file (`history/sirens_song_prototype.html`). v1–v5 never existed as discrete files (see section 2).
- **(3) latest spec** -> `SIRENS_SONG_functional_spec.md`, newest version is **v0.3**. There is no v0.4 (see section 2).
- **(4) Cowork wrapper + Decision Log** -> **not separate files**; both are embedded inside the functional spec (lines 249 and 306), shipped unaltered.
- **(5) dev notes / smoke tests / tuning tables / DEEP_CONTACT / other** -> dev notes present; tuning table is inside dev notes; DEEP_CONTACT recovered to `/history`; smoke-test scripts not recoverable (section 2).

---

## 2. MISSING / not recoverable (not reconstructed)

- **Prototype versions v1–v5 as discrete files — never existed.** The build iterated in place on a single file. Only the pre-v7 cumulative build (v6) and v7 were ever saved as distinct files. The labels v1–v5 refer to in-session edit iterations (dev_notes Rounds 1–4), not saved snapshots. They survive only as edit fragments inside the conversation, not as full files, so they are not included and were not rebuilt from diffs.
- **Spec v0.4 — does not exist.** Newest spec is v0.3. The spec is behind the build; see the gap list in section 4. No v0.4 reconciliation was ever written, and this run did not write one.
- **Smoke-test / headless-verification scripts — gone.** Produced during the session in the system temp directory, ephemeral, never on persistent disk. The harness pattern is described in the session record (stub `document`/`canvas`/`window`, exercise `init`/`update`/`render`) but no script file survives to copy.
- **User-uploaded screenshots (`16402.jpg`, `16443.jpg`) — left out.** These are Pat's bug-evidence screenshots (menu-chrome overlap; wide-screen squish), uploaded to the chat, not build artifacts produced by the work. They exist in the conversation if wanted; say the word and they go in.

---

## 3. Version lineage (context only — the only recoverable full builds are v6 and v7)

From the session record and dev notes, not from per-version files:
- **v1–v6:** iterative edits across playtest Rounds 1–4 (dev_notes documents the round-by-round feedback and changes) plus the post-spec v0.3 build pass, culminating in the **v6** cumulative build saved as `history/sirens_song_prototype.html`.
- **v7:** the post-compaction session. Drone redesigned into a piloted capture tool, movement retune (arriveR 110 -> 220, squared noise curve), then the Hunt core, then the menu-chrome hide and the resize-ordering fix.

No finer-grained v1=.../v2=... mapping is asserted because none is cleanly sourced; treat intermediate version numbers as edit milestones, not artifacts.

---

## 4. GAP LIST — mechanics in v7 that the v0.3 functional spec does not describe

The missing spec sections are deliberately NOT written here. Each entry names the gap and where it lives in `sirens_song_prototype_v7.html`.

1. **The Hunt system (entire).** Global 0–100 pressure meter, five stages (Dormant / Stirring / Searching / Hunting / Lockdown). Action-driven climb, decay toward a progress floor, stage-based detection multiplier. The spec §9 only describes "escalation on capture raises global Siren alertness a notch" plus an optional factory charge timer. It does not describe the Hunt meter, its stages, the action-driven climb, the decay/floor model, or the stage detection multiplier. *Documented in `SIRENS_SONG_pressure_design.md`, absent from the functional spec.* Lives in: CFG lines 116–118 (`huntTime 0.2, huntPhoto 8, huntPing 5, huntTool 4, huntDetect 6, huntGraze 6, huntDecay 1.0, huntDelay 6`); functions `huntStage()` and `huntMult()` (multipliers `[1.0,1.15,1.3,1.5,1.7]`); the Hunt rise/decay block in `update()` (climb at line 344, floor = `gotCount()*huntPhoto`); `effDetect()` (now multiplies by `huntMult()`, replacing the old `baseAlert*0.04`); the HUD "HUNT: <stage>" readout in `hud()`; and Hunt increments in `doCapture`/`doPing`/`doEmp`/`doKnock`.

2. **Graze / hull bleed (graduated failure).** At Hostile (suspicion >= 75) with a live un-stunned detector for `grazeDelay` 1.5s, the sub takes `grazeDmg` 20 hull damage (plus a Hunt spike) on a `grazeCool` 3.0s cooldown, and a new lose condition **HULL BREACHED** fires at hull 0. The spec §2 mentions a hull pool but only for terrain/contact damage ("sunk"); it has no concept of getting seen bleeding hull, and §6's kill rule is still binary vaporize-at-max. Lives in: CFG line 118; the graze block in `update()` (line 391, `end(false,'HULL BREACHED')`); the Hull HUD bar in `hud()`; state vars `hull`/`grazeCD`/`grazeT`.

3. **Terrain and cover (entire).** Rock obstacles (9), movement blocking, line-of-sight occlusion with rendered sonar shadow cones, cover-cuts-both-ways. The dev notes OPEN THREADS already flag this: "Terrain & Cover not yet in the spec." Lives in: the `obstacles` array, `losClear()`, and the shadow-cone rendering in `render()`.

4. **Drone redesigned as a piloted capture tool.** In v7 the drone is an expendable piloted camera you send into a kill zone to grab objective photos the sub cannot safely reach: re-tasking a live drone is free, launching a fresh one costs a charge, one drone out at a time, `droneVisionR` 120. See also the contradiction in section 7. Lives in: the `drone` branch of the `pointerdown` handler, drone handling in `update()`, CFG `droneVisionR`.

5. **Plan-beat slow-mo and targeting UX.** Sim slows to ~30% while a targeting mode is armed; KNOCKDOWN is tap-to-target with a range ring; DECOY is tap-to-place. The spec §5 names the tools but not this UX or the slow-mo beat. Lives in: the `pointerdown` handler (`mode` branches for `drone`/`decoy`/`knock`), the slow-mo factor in `frame()`.

6. **Log freeze modal.** Stepping on a log pauses the whole game (oxygen, suspicion, Sirens halt) behind a centered "tap to continue" modal. The spec §11 asks for discoverable log fragments but not the freeze-modal delivery. Lives in: `logmodal` handling and the `paused` state.

7. **Oxygen retune.** v7 `oxyDrain` is `100/300` (~300s). Spec says "slow drain"; dev notes say ~220s. Lives in: CFG line 116.

8. **Movement / noise retune.** `arriveR` 220 (dev notes: 110) and a squared noise curve (`Math.pow(spd/maxSpeed,2)`) in both the update and the footprint render. Spec §6 says only "throttle generates noise." Lives in: CFG `arriveR`, the noise computation in `update()` and the footprint ring in `render()`.

9. **Spawn launch buffer + cover rock.** A patroller launch buffer (safe gap at spawn) and a cover rock north of spawn. Not in the spec. Lives in: siren spawn setup and the `obstacles` array in `init()`.

10. **Factory power-up visual.** The factory border glows red at Hunt stage >= 3 (render only, tied to the Hunt, itself ungapped above). Lives in: the factory block in `render()`.

11. **HUD layout.** Three bars (Suspicion, Hull, Oxygen) plus a meta line (state | HUNT stage | photos), and the menu/results screens now hide the HUD and controls. The spec does not describe the HUD at all. Lives in: the `#hud`/`#controls` markup, `hud()`, `startGame()`, `end()`.

12. **Currents and thermal band (implementation specifics).** Spec §12 lists currents and thermal layers as "mostly form." v7 implements deterministic current streaks that nudge the sub and a thermal band that halves detection (`thermalMul` 0.5, `thermalY0` 0.40 / `thermalY1` 0.455). The concept is in the spec; the concrete implementation is not. Lives in: CFG thermal line, current handling in `update()`, `inThermal()`, `effDetect()`.

---

## 5. Locked build sequence and standing rules (from the session record)

**Locked build sequence, in order, no skips:**
1. Controls
2. Tuning
3. Level design
4. Form (pixel art, real audio)

Plus ongoing spec reconciliation (currently outstanding; see open items).

**Standing rules that governed this project:**
- No code edits or builds without an explicit command ("build / fix / update / do it"). Bug reports, feedback, and "what do you think" get diagnosis plus proposal only, then wait.
- Build fully to spec. No silent reductions, substitutions, or simplifications. If scope needs to shrink, say so, do not do it quietly.
- The §15 spec build order and its DO-NOT list are the scope leash (no proc-gen, no multiple levels, no meta-progression, no menus beyond start/restart).
- Balance numbers are tunable; the domain invariants (section below, and wrapper) are not.
- Interface is turn-based: a duplicate-looking prompt or mid-stream reinjection is a system artifact, not the user.

**Domain invariants (from the wrapper, do not drift):** no enemy HP and no player kill-path; suspicion is the spine with the active-detector kill rule; perceiving costs and moving makes noise; tools buy time and cost heat; fairness valve mandatory; audio and noise are core; function before form.

---

## 6. Open items

- **UNTESTED — Hunt climb-rate feel.** Pat has not yet reported how the Hunt climb feels in play. The key dial is `huntTime` (0.2/s time nudge); the model is action-driven (idle decays to the progress floor). This is the next playtest read, and tuning may follow.
- **DEFERRED — per-stage Siren behaviors.** Faster patrols, hunter waking and prowling, and lockdown convergence toward objectives (explicitly NOT sub-position tracking, to preserve the fair-AI fix) were deliberately staged until the climb rate is confirmed. v7 currently expresses higher Hunt only through wider detection, the red factory, and audio, not through changed Siren movement.
- **Difficulty target undecided** (dev_notes KEEL-FLAG). Levers offered, no decision: `pingHear`, `decay`/`decayDelay`, `investigateT`.
- **Decoy vs active chase.** Currently sight beats lure (a decoy does not pull a Siren that already sees you), a deliberate choice; open whether a decoy should be able to break an active chase.
- **Decoy Hunt cost = 0.** This run set decoy (and recon) to add no Hunt, as the quiet/misdirection tools. Pat invited to confirm or override.
- **Photo-quality threshold** (spec §8 pending). Do low-quality shots still count toward the win, or is there a minimum? Current default: all count, score varies.
- **"Vision cone" interpretation** (dev_notes KEEL-FLAG). Built as sonar occlusion shadows; Pat's approval suggests this satisfied the ask, but a forward-facing flashlight-cone alternative was never explicitly ruled out.
- **Spec reconciliation to v0.4** is pending: the functional spec does not yet reflect any of the section-4 gaps.

---

## 7. Contradictions between spec, wrapper, and code — flagged for your ruling, not resolved

1. **Drone role.** Spec §4 lists **decoy as a drone role**. v7 makes decoy a **separate tap-to-place tool** and the drone a **piloted capture-delivery camera** (free re-task, one out at a time). Spec and code describe different drone designs.
2. **Escalation model.** Spec §9 escalation is **linear per-capture global alertness** (the old `baseAlert`). v7 **removed `baseAlert`** and replaced it with the Hunt meter (photos raise a floor; climb is action-driven and decays). Same design intent, different mechanism; the spec's mechanism is gone from the code.
3. **Kill model vs fairness valve.** Spec §6 kill is binary vaporize-at-sustained-max, survivable by breaking all detection; §14 principle 4 says "you can always survive a max-suspicion moment by disabling every detector." v7 adds the graze/hull path, so the sub can now be sunk by accumulated graze damage. Whether graze-death honors the fairness valve (§14 principles 4 and 5, "one mistake != instant restart") is your call.
4. **Oxygen.** Spec "slow drain" and dev-notes ~220s vs v7 ~300s.
5. **Movement.** dev-notes `arriveR` 110 and (implied) linear noise vs v7 `arriveR` 220 and squared noise.
6. **Governance.** The wrapper states this spec is the single source of truth and "if code and spec disagree, the spec wins unless Pat amends the spec." In practice the **code (v7) has led and the spec has lagged** (it is still v0.3 while the build carries the Hunt, graze, drone redesign, terrain, and more). By the wrapper's own rule the spec currently "wins" over a lot of shipped, approved code. Needs your ruling: keep spec-as-source-of-truth and reconcile the code back to a written v0.4, or acknowledge the code as the lead artifact pending that reconciliation.
