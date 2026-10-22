# Handoff 012: read-only report: what V7 does that the Godot game lost or changed

Status: DONE
Claimed at: 2026-10-22 17:32:32 UTC
Claimed by: codex
Finished at: 2026-10-22 17:35:31 UTC

Precondition: handoff 011 must be DONE or BLOCKED.
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): PHOTO1 and ONBOARD1 are merged. Claude's PHOTO2 builder (branch claude/photo2-images) owns the camera, viewfinder, archive viewer, photo save paths, recon_consequences.gd, camera_feed.gd and evidence_catalog.gd. Claude's SWEEP1 builder (branch claude/lane-t2-sweeper) owns the sweeper code and its warning text, plus a first-warning tutorial pause in onboarding_hints.gd. Do not edit those files; write what you need in your Completion section instead.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add. Briefings and story text stay short placeholders.

## Task (plain language)
Read-only study; edit no game files. Pat treats the playable V7 prototype (reference/original-prototype/sirens_song_prototype_v7.html and the spec files beside it) as the reference for the original design. Compare it with the current game and report, in plain language Pat can read in five minutes: (1) mechanics V7 had that are missing in the Godot game; (2) mechanics that changed, with whether the change is better or worse for the original feel; (3) things the Godot game added that V7 never had (list them; Pat is deciding which to keep, example: the Siren active-sonar sweeper); (4) the five differences that most change how the game feels to play, ranked. Cover detection (sight, hearing, noise), suspicion and Hunt, tools (ping, recon, EMP, knockdown, decoy, drones), oxygen, extraction, currents, thermal, graze and kill rules. Use file and line anchors for V7 and for the Godot code. Do not propose fixes beyond one line each. Do not edit docs/V7_TO_GODOT_PARITY.md; Claude reconciles it.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-v7-parity-gap-report

## Files you may edit
Only the Completion section of this handoff file (put the whole report there).

## Files you must not touch
Everything in the game repo.

## What done looks like
The report is in the Completion section, readable by a non-developer, with anchors, and clearly separates verified-in-code from inferred. No PR needed; mark DONE.

## Return
Open a PR into claude/integration, wait for guidance and game-smoke, merge when green, then write the Completion section and push to codex/handoffs.

## Completion

**Read-only comparison, 22 October 2026.** Verified against executable V7 and integration `44c90a8`, including PHOTO2 and handoff 011. Linked rules are **verified in code**. “Better”, “worse”, and the ranking below are **inferences about feel**, not playtest results. Nothing in the game or parity ledger was edited. No PR or new test run was needed for this report.

### What V7 had that is absent or replaced

- **One shared suspicion meter governed danger.** Factory proximity, seeing Quietus, noise and tools raised it; waiting quietly reduced it. Godot has local guard suspicion and individual locks, not that common “how much trouble am I in?” budget. The automatic factory-proximity tax is absent from that replacement. [V7 pressure] / [Godot locks].
- **Universal progress escalation is gone.** V7's Hunt made every Siren's detection radius grow as photos accumulated. Godot retains the Hunt estimate and photo floor, but guard readiness grows through local received evidence. Better information fairness; weaker automatic “the whole base is waking up” pressure. [V7 pressure] / [Godot Hunt].
- **Graze before death is gone.** V7 could remove 20 hull after 1.5 seconds at hostile suspicion, then vaporize after sustained maximum suspicion. Godot's ordinary beam kills after its four-second lock; hull loss instead includes speed-based collisions. This is Pat's newer decision, not an accidental missing feature. [V7 death] / [Godot locks] / [Godot collision].
- **Engine-cut SILENT and disposable replacement scouts changed.** These are present in different forms below. Jamming was in old prose, but has no executable V7 tool, so it is not a lost V7 mechanic. Older notes also call drones and knockdown unbuilt, although V7 implements both. [V7 movement] / [V7 tools] / [V7 drones].

### Changed mechanics and likely effect on the original feel

| Area | Verified difference | Inferred effect |
|---|---|---|
| Sight, hearing, noise | V7 sight uses proximity/LOS, but motion hearing and ping summons use distance without rock checks. Godot sight also checks depth; hearing follows weakened water paths. Both use squared-speed noise. [V7 pressure] / [V7 tools] / [Godot hearing] / [Godot noise]. | Better physical fairness and acoustic tactics; more rules to learn. |
| SILENT | V7 brakes to rest and immediately reports zero throttle noise. Godot Quietus still travels at a baseline 42 versus 78 cruise; residual thrust remains audible. [V7 movement] / [Godot speed] / [Godot noise]. | Useful quiet travel, but loses the original engines-off breath-holding beat. |
| PING and RECON | V7 ping briefly reveals LOS-gated objects and raises suspicion; RECON reveals a 560-unit area for 3.2s. Godot ping spends oxygen/battery, offers sector/power choices and delayed echoes; finite RECON surveys locally for 8s and emits noise. [V7 tools] / [V7 sensing] / [Godot tools] / [Godot sonar]. | Richer instruments, less immediate comprehension. |
| EMP, knockdown, decoy | V7 EMP: 150 range, 3.2s; knockdown: instant, 8s; four freely placed 7s decoys. Godot EMP: 340 base range, 12s, charge spent even without a hit; torpedo: physical flight, cover can stop it, 8s pin on impact; three decoys, reachable water within 160, 15s audible transmission. [V7 tuning] / [V7 tools] / [Godot tools] / [Godot torpedo]. | EMP is a much larger escape window; torpedoes need anticipation; decoys gain physical limits. World scales differ, so range numbers alone do not prove balance. |
| Drones | V7 supports one live re-taskable scout with four launches; calm Sirens leave it alone until alert/investigation and close contact. Godot starts with two independently commanded, battery-limited drones that can be seen, heard and killed by beams. [V7 drones] / [V7 pressure] / [Godot craft] / [Godot locks] / [Godot endurance]. | More fleet tactics and attention cost; less of V7's comparatively safe camera scout. |
| Oxygen and extraction | V7 has 300s air and wins with all photos inside the extraction radius. Godot uses mission/equipment budgets, pause-free consumption, middle-band settled recovery and physical cargo/people requirements. [V7 tuning] / [V7 death] / [Godot endurance] / [Godot extraction]. | More meaningful return journeys, less pure photographic in-and-out simplicity. |
| Currents and thermal | V7 currents nudge Quietus; its cold strip halves Siren sight range. Godot retains radial current falloff with physical stationkeeping; thermal fronts weaken sound/passive reception across crossings rather than granting that universal sight shield. [V7 movement] / [V7 pressure] / [Godot currents] / [Godot motion] / [Godot thermal]. | Stronger environmental navigation; the original cold-water hiding trick changes substantially. |
| Photography | V7 captures instantly within 72 and scores proximity/craft. Godot uses timed viewpoint-dependent exposures, lit images, discoveries, camera equipment and returned intelligence. [V7 capture] / [Godot photos] / [Godot image] / [Godot photo intel]. | Closer to the photographic recon ambition; potentially slower and more demanding. |

### Godot additions V7 never implemented

- Three tactical depth bands, transitions, pressure costs; passive bearing histories, triangulation and physical echoes. [Godot depth] / [Godot sonar].
- Active-sonar sweepers and delayed area strikes; listening buoys, relays, interceptors and wardens. **The active sweeper is still present at this inspected commit**, including non-lethal hull/battery strikes; Claude's pending replacement is not treated as already landed. [Godot sweeper] / [Godot roles] / [Godot industry threats].
- Thirty registered operations, branching consequences, physical rescue/transport/industrial jobs, research and equipment fitting with different hulls/chassis. These are additions, not a claim the full-release program is complete. [Godot operations] / [Godot frames].
- Queued/programmed routes, fleet controls, retained chart knowledge, save/retry continuity, front end/settings, and the expanded photographic systems above. [Godot routes] / [Godot sonar] / [Godot saves] / [Godot UI].

### Five differences most likely to change the feel, ranked

1. **Individual lethal locks replace shared suspicion and grazes:** sharper immediate danger, less recoverable escalation.
2. **Hunt no longer globally strengthens every guard:** fairer local knowledge, less inevitable late-run pressure.
3. **Two fully vulnerable commandable drones plus moving SILENT:** fleet tactics replace the simple safe-scout/engine-cut contrast.
4. **Real photographic observation replaces instant capture:** stronger recon identity, more time and attention per image.
5. **A branching campaign with physical jobs replaces one factory raid:** much greater variety, with a risk that logistics displace photographic dread.

Recommendation: use these five differences as questions in the planned cold play review; change no design rules on this report alone. No outside-ownership edits were needed. Next: handoff 013.

[V7 pressure]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L332
[V7 tools]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L248
[V7 capture]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L257
[V7 drones]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L231
[V7 death]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L387
[V7 movement]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L295
[V7 sensing]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L400
[V7 setup]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L160
[V7 tuning]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/reference/original-prototype/sirens_song_prototype_v7.html#L104
[Godot locks]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L1217
[Godot tools]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L574
[Godot torpedo]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L1170
[Godot extraction]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L310
[Godot craft]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L104
[Godot motion]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L1026
[Godot hearing]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L1288
[Godot collision]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L224
[Godot Hunt]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/recon_consequences.gd#L5
[Godot noise]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/acoustic_paths.gd#L13
[Godot sonar]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/advanced_sonar.gd#L26
[Godot thermal]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/thermal_front.gd#L43
[Godot endurance]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/operation_endurance.gd#L6
[Godot currents]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/current_field.gd#L3
[Godot photos]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/photo_capture.gd#L147
[Godot image]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/presentation/photo_scene.gd#L1
[Godot camera kit]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/equipment/equipment_catalog.gd#L25
[Godot photo intel]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/campaign/photo_intel.gd#L1
[Godot sweeper]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/sonar_sweeper.gd#L4
[Godot depth]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/depth_bands.gd#L43
[Godot roles]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/acoustic_network.gd#L1
[Godot industry threats]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/industrial_threats.gd#L1
[Godot operations]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/campaign/operation_catalog.gd#L6
[Godot frames]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/equipment/equipment_catalog.gd#L4
[Godot routes]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/route_program.gd#L1
[Godot saves]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/persistence/save_store.gd#L1
[Godot UI]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/presentation/mission_hud.gd#L47
[Godot speed]: https://github.com/pemunson90-cmd/Siren-s-Song/blob/44c90a82ef1525b87c9fdf3d14b85cb58514bfd7/game/src/simulation/simulation.gd#L865
