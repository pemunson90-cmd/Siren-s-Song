# Brief — Step 3: Drones + Sub Fallback Cam + Photo Objectives + Win/Lose

**Your step in §11:** *"3. Drones (deploy / move / cam / photograph) + sub fallback cam + photo objectives + win/lose."*
**You inherit from steps 1–2.** Read `handoffs/02_suspicion_patroller.md` and `audits/02_AUDIT_STEP_02.md` before you start.

---

## What you produce

On top of steps 1–2, add:

- **Drones:** finite supply (default 5). Launched from sub via torpedo tube to a clicked destination. Point-and-click control (no CLI per §4 spec ruling).
  - Functions implemented at this step: **Scout** (provide drone-cam vision at their location) and **Photograph** (capture full-detail shots of any objective at low risk). Decoy is step 4.
  - Drones are expendable but finite. Destroyed drones are gone. Losing all drones does NOT hard-stall (sub fallback cam takes over).
  - Drone photo suspicion cost: +15.
- **Sub fallback camera:** grainy long-range cam mounted on the sub. Can capture any objective. Has no flat photo cost — the cost is the proximity it demands (close = suspicion ticks via the proximity terms).
- **Factory site:** hand-authored placement of the alien deep-sea factory in the play area. Factory proximity contributes +1 to +3/sec suspicion (scales with closeness). This is the suspicion hook step 2 deferred — land it here.
- **Photo objectives:** 3 required + 1 bonus per §8 + §11.
  - Required photos: factory silhouette · construction bays · power core.
  - Bonus photo: a Siren at close range.
- **Two ways to take any shot:** drone or sub fallback cam. Silhouette is comfortably sub-cammable from distance; bays / power core / Siren close-up favor a drone (sub close range = near-suicidal but possible).
- **Extraction point:** hand-authored location in the play area.
- **Win condition:** all required photos captured AND sub reaches extraction.
- **Lose conditions** remain from prior steps (sunk, suffocated, vaporized).
- HUD now shows: drone supply, photos captured (X / 3 required + bonus), extraction status.

You're not building Sentinel, Hunter, curiosity/decoy, weapons, or recon plane.

---

## Spec sections to re-read (verbatim before you code)

- §2 (sub fallback camera).
- §3 (drone-cam row in the perception table).
- §4 Drones (the full section — scout, photograph, deploy mechanics, finite supply).
- §6 Suspicion system (factory proximity term; drone photo +15; sub-cam shot proximity exposure).
- §8 Objectives & win/lose (the full section).
- §11 step 3 line, tunable defaults.

---

## Inherited state

- `code/sirens_song.html` has: everything from steps 1+2.
- Read step 2's handoff for the factory-proximity hook location and Siren-near-sub deferral.
- Active ping +25, drone photo +15, decay −5/sec, thresholds 33/74/99, instakill at 100 sustained ≥4s.

---

## Scope boundary (the seam where you stop)

You stop after:

- The factory exists in the play area at a hand-authored position.
- Factory proximity contributes +1 to +3/sec to suspicion, scaling with closeness (spec is explicit on the range).
- Drones can be deployed (point-and-click to destination); drone count decrements on deploy.
- Drones can be moved to a new clicked location.
- Drones reveal local vision around themselves (drone-cam).
- Drones can take photos when at a valid range from a photo objective; photo costs +15 suspicion.
- Sub fallback cam can take photos when sub is at close enough range (your call on "close enough" — document); no flat cost.
- Photos are tracked: X of 3 required captured; bonus tracked separately.
- Extraction point exists; reaching it after all 3 required photos = win.
- Win state renders ("EXTRACTED — RUN COMPLETE" or similar plain text).
- Drone destruction handled (collision with terrain, contact with Patroller at Alert+, or both — your call, document).

You do NOT build:
- Sentinel or Hunter Siren types (step 4).
- Decoy drone behavior (step 4 — Sirens don't curiosity-react yet).
- Jamming, EMP, Knockdown (step 5).
- Recon plane (step 6).
- The Siren-near-sub scaling suspicion term (defer to step 4 when there are more Sirens).

---

## Tuning values for this step

| Value | Default (from spec) | Notes |
|---|---|---|
| Drone supply | 5 | §4, §11 |
| Drone photo cost | +15 suspicion | §3, §6, §11 |
| Sub-cam photo cost | 0 flat (proximity drives via §6) | §6 |
| Factory proximity suspicion | +1 to +3/sec scales with closeness | §6, §11 |
| Required photos | 3 (silhouette, bays, power core) | §8, §11 |
| Bonus photo | 1 (Siren close range) | §8, §11 |
| Drone vision radius | local, your call | Document |
| Drone speed | your call, document | |
| Sub-cam range | your call, document | Spec says silhouette is comfortably sub-cammable from distance; close objectives force exposure |

---

## Sim tests to consider

- **Drone deploy/move test:** click to deploy drone at (x,y); assert drone exists at that position and supply decremented. Click new destination; assert drone moves.
- **Drone photo test:** drone within range of factory silhouette objective; trigger photo; assert objective captured and suspicion +15.
- **Sub-cam photo test:** sub within close range of power core; trigger sub-cam; assert objective captured and suspicion did NOT add a flat +15. Verify proximity terms were the cost.
- **Factory proximity test:** sub at far distance from factory, no other inputs, suspicion stable (only decay). Sub at close distance to factory, suspicion gains +3/sec; mid distance ≈ +2/sec; etc.
- **Win condition test:** capture all 3 required photos, drive sub to extraction; assert win state fires.
- **No-win test:** capture 2 of 3 required, drive sub to extraction; assert NOT win.
- **Drone-depletion-not-stall test:** lose all 5 drones; verify sub-cam can still complete remaining objectives.

---

## Audit gates (what the auditor will check)

- **Invariant 1:** no Siren HP added, no kill-path. Photos do not "damage" anything.
- **Invariant 2:** photo suspicion costs land per spec; factory proximity term lands per spec; no scripted aggression added.
- **Invariant 3:** drone-cam is a vision tool, free at deploy/move per §3, photographs cost +15. Sub-cam's proximity cost holds. Passive sonar still the only consistently free reveal.
- **Invariant 4:** drones aren't tools that buy time in the §5 sense — they're perception platforms. Still, finite supply enforces scarcity.
- **Invariant 5:** factory proximity escalates suspicion as designed. Warning valve from step 2 still works (sim test it).
- **Invariant 6:** factory and objectives are placeholder rectangles/labels. No art polish.
- **Step scope:** auditor confirms no Sentinel/Hunter/decoys/weapons/recon were added.

---

## Handoff format

End your turn by writing `handoffs/03_drones_camera_objectives.md` per §5.2 of `agent.md`. Include in §"Open potholes for the next step":

- The Siren-near-sub scaling suspicion term still deferred — hook for step 4.
- Tuning numbers for drone vision radius, drone speed, sub-cam range, drone destruction behavior.
- The bonus Siren close-range photo objective — confirm it can be captured against the Patroller now and won't break when Sentinel/Hunter exist.

Receipt format at end of handoff: `Step 03: COMPLETE / BLOCKED / PARTIAL`.

---

*AI-DESIGNED. Brief for daisy-chain step 3.*
