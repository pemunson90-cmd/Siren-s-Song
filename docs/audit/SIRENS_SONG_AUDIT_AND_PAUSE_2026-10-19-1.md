# GAUNTLET PAUSE: INDEPENDENT AUDIT RECEIVED

**From the user. This instruction takes effect immediately.**

Stop all development now. Do not dispatch, merge or push any gameplay work until steps 1 to 4 are done.

1. **Checkpoint.** Every active worker pushes its current work to a published feature branch, so nothing lives only in a local worktree. Record each branch name and SHA. Do not merge any of it.
2. **Read.** The root orchestrator reads the audit below, beginning to end. The audit was frozen at production `56ef1f07dbdce72dd22aa32296a72cc6a8e36146`. Then commit this whole file unchanged to a new branch, `archive/claude-audit-2026-10-19`. Do not put it on `gauntlet/production`.
3. **Respond.** For each finding F1 to F7, write ACCEPT or DISPUTE.
   - A dispute must cite file:line or runtime evidence. Disagreement without evidence counts as acceptance.
   - The audit is not an answer key. Where it is wrong, prove it.
   - Commit your response next to this file on the archive branch.
4. **Re-plan.** Rewrite `docs/CONTINUATION.md` and `docs/WORKBENCH.md` around the audit's three passes: Stakes, then One real operation, then Instruments over caveats.
   - If you have a stronger direction, state it with evidence.
   - Keep each file under 40 lines. No SHAs or test counts beyond the current base.
   - Shelve observed-task automation, the TASK/NONE planner and new chapter IDs. Keep their branches.
5. **Resume.** Dispatch Pass 1 immediately. Integrate features through pull requests so the existing game-smoke CI actually gates them.

**Operating rule from the user: the Gauntlet runs until the user ends it.**
- Finishing a task, a review, a plan or this pause is not a stopping point.
- Do not end your turn with a summary that waits for my reply.
- Do not ask me routine questions.
- After every completion, start the next highest-value task in the same turn.
- Stop only when platform usage is actually exhausted. Then write PAUSED, RESUME REQUIRED, with the exact next command.

Every hour of sim tuning, layout or encounter work should outweigh an hour of documentation.

**The user tests only after he stops the Gauntlet.**
- No agent decides the game is at spec, finished, or ready for the user. The spec is a direction to keep closing on, with no finish line attached. The loop runs until the user says stop. Then he plays it and gives concrete feedback, and that feedback becomes the next round's input.
- While the loop runs, do not ask the user to play builds, judge feel, or confirm quality.
- Critics stand in for players, as in the original Gauntlet Loop:
  - Fresh context, with no builder history or explanation.
  - They inspect the actual running game, never a summary written by the builder.
  - They play full operations in Godot through real input: injected touch on actual cover and inner views, not button callbacks or scripted controllers.
  - Each takes a different strategy: cautious, aggressive, drone-heavy, Quietus-only.
- The bar is external. Critics run blind side-by-side comparisons against real footage of the reference games, one dimension each: Door Kickers for route planning and touch command, Mark of the Ninja for detection readability, Barotrauma for sonar and acoustic tension, Duskers for drone tools and scarcity. They pick the better result without being told which is which. The bar does not need to be reachable; it exists so no one stops at "good for an AI build."
- Critics report what they actually did: routes taken, times, losses, where they got confused, which choices they never used.
- Keep WORKBENCH a short, phone-readable progress page, so the user can check in without interrupting the loop.
- Limits stay honest. Agent play does not certify human enjoyment, headphone audio or physical Fold7 ergonomics, so do not claim those.

---

# Siren's Song Independent Audit · production 56ef1f0

Audit date: 2026-10-19. Read-only audit by Claude (Opus 5.5), independent of the Gauntlet team.

## Verdict

The tunnel-vision charge mostly holds. Confidence is high on direction and low on human enjoyment, which no one has measured.

The tutorial arc (missions 0 to 5) is the strongest content in the game, and the simulation underneath it is fair and well built. Missions 6 to 13 repeat one verb, "reach a marker, hold N seconds, return," on rectangle maps that are often mirror-symmetric, guarded only by patrollers. The newest systems (sampler, correlator, sluice, chosen-origin transmit) add labels and save state faster than they add decisions.

Two root causes make those decisions toothless. Time and endurance carry almost no cost. The interface explains uncertainty in prose instead of showing it as instruments.

The whole production history is 488 commits between Oct 18 04:50 and Oct 19 23:09. Output velocity is enormous; direction is what needs correcting.

**Baseline.** `gauntlet/production` tip equals the prepared baseline 56ef1f07, so there was no intervening diff. The visual packet came from `archive/claude-current-audit-2026-10-19` at 3adf4be.

## Status matrix

The auditor ran or rendered only the items marked so in the Verified column; everything else was read from code.

| Area | Implemented (code) | Verified by auditor | Active / unmerged | Planned | Missing |
| --- | --- | --- | --- | --- | --- |
| Tutorial 0 to 5 | Yes; varied roles (sentinels 3, hunter 4, thermal and departure 3, reports 5, glider 2) | Ran 0, 1, 3, 5 headless; rendered 0 and 4 | | | |
| Expedition 6 to 13 | 8 entries; registry and unlocks real | Code-read; fixture-rendered 11 | | | Distinct encounters, varied enemies |
| Branching | Exit fork at 6, thread at 9/10, exit fork at 11 | Code-read | | Long branch graph | Branches with downstream effect (F2) |
| Endings | `facts.resolution` written | Code-read | | Multiple endings | Any ending sequence |
| Upgrades | 2 items: correlator, sampler | Code-read | | Economy | General capability upgrades |
| Physical torpedo | LOS launch, steering, terrain miss, impact snare | Code-read only (simulation.gd:244-253, 652-678) | | | |
| Planner per-leg propulsion | Yes | Rendered (F4) | Task/NONE controls | | Terrain and objectives in planner |
| Observed-task withdrawal | | | Local worktree, no published ref | | Unverified WIP |
| Currents, Hunt floor, reflections, earned terrain | No / finale only / no / no | Code-read | | Ledgered | Yes |
| Save | Atomic write, backup, validation | Code-read | | Profiles | New game or reset |
| Audio | About 15 synthesized cues | Code-read, not heard | | | Tension layer, Siren voice |

## Strongest real gains

Five things are genuinely good and should be protected through any redirect.

- **Fair perception architecture.** Sirens hear through a water-path graph with diffraction and never query hidden player state (simulation.gd:744-757, acoustic_paths.gd). Contacts go stale. Simulation runs on a fixed 60 Hz step.
- **Physical torpedo.** It follows the user's direction: LOS required at launch, it can strike terrain, it snares only on impact, and it persists in saves.
- **Robust save path.** Checksum, verify-then-rename, backup fallback (save_store.gd:29-63).
- **Differentiated tutorial.** Naive straight-line play fails in missions 1, 3, 5 and in a Confluence fixture, so stealth has real bite. Mission 0 is the only one a naive controller wins.
- **Readable craft art.** The Quietus and ray-Siren sprites match the concept direction.

## Ranked findings

Ordered by player impact. Each finding gives evidence, consequence, direction, and whether it is inherited or new.

### F1. Post-tutorial content is serial and thin

New direction · confidence high.

- **Evidence.** Missions 6 to 13 use 5 to 8 axis-aligned `Rect2` rocks each (divergence_missions.gd:93,102,112; onward_missions.gd:67,75; resolution_missions.gd:43,54,69).
- **Mirror maps.** Missions 9 and 10 are exact mirror images around x=1000; for example `Rect2(100,1020,420,220)` pairs with `Rect2(1480,1020,420,220)` in a 2000-wide world.
- **One enemy type.** Every Siren in 6 to 13 is a `"patroller"` (onward_missions.gd:72-82, resolution_missions.gd:88). Sentinels, hunters, thermal fronts and departures exist only in the tutorial.
- **One verb.** Every objective kind (photo, receiver, uplink, transmitter, actuator) is the same hold-at-point loop. Confluence at FIT on the inner screen reads as a plus-sign of slabs, nothing like the C01/C02 references.
- **Consequence.** Adding chapters adds briefing text, not new play.
- **Direction.** Stop adding chapter IDs. Build fewer, larger operations.

### F2. Branches and endings are mostly bookkeeping

New · confidence high.

- **The thread has one effect.** The deep/shelf thread only moves Confluence's spawn point (resolution_missions.gd:40-41).
- **The resolution fact is never read.** `facts["resolution"]` is written (campaign_consequences.gd:31) and nothing consumes it.
- **No endings.** Missions 12 and 13 end in the generic "EXPEDITION RECOVERED" text debrief (expedition_operations.gd:25-38).
- **The other branch is locked forever.** `confluence_route` is set once (campaign_consequences.gd:32). There is one save file (save_store.gd:4) and no new game or reset (main.gd:362-389). Short of clearing app data, a player can never play the other branch.
- **Disproportionate state.** About 60 lines of validation guard two items and one binary fork.
- **Direction.** Branches need geography, roster and narrative consequences, a Star Fox-style route map, and replayable routes.

### F3. Time and endurance cost nothing

Inherited tuning that undermines the new choices · confidence high.

- **Endurance.** O2 drains at `dt/18` (simulation.gd:439), about 30 minutes for 100%. Drone battery drains at `dt/14` (simulation.gd:458), about 23 minutes.
- **Mission length.** Missions run 40 to 90 seconds; the auditor's naive mission 0 win took 61.9 s and the team's own model run took 54.97 s.
- **Idle is safe.** Idling 300 s in mission 0 left hull at 100 and O2 at 103/120, with nothing happening.
- **Consequences.** The default ENDURANCE loadout (main.gd:36) buys nothing. "Waiting costs time" in the Foundry brief is false. The sluice shortcut and sampler parallelism save seconds with no value, so any benefit must come from patrol geometry, which no one has measured. East dominating west in mission 13 is consistent with this.
- **Direction.** Retune endurance to mission scale and add escalating attention (Pass 1).

### F4. The interface explains instead of showing

Mixed inherited and new · confidence high.

- **Route planner.** It draws only known cells and a white dot: no rocks outside knowledge, no objectives, contacts, other craft or extraction (route_program_preview.gd:83-98). It shows less than the main chart.
- **Default camera.** Follow mode frames about 1000x430 world units on the cover screen (chart_camera.gd:19). The Quietus sprite is 132 units long (ocean_view.gd:408) against a 12-unit collision radius (simulation.gd:580). Default frames show the sub in empty water with objectives and threats off screen.
- **Briefing length.** Briefs grow from 31 words (mission 0) to 146 words (mission 13), plus three stock instruction blocks (main.gd:398-403; expedition_operations.gd:15-17). The Confluence brief scrolls before the controls block.
- **Caveats as prose.** Packet STATUS reads "historical arrivals, not delivery acknowledgments" and shows raw coordinates "1838, 1087".
- **Colliding text.** The beam warning appears twice (banner plus label). Labels overlap craft and the S2 marker in the packet frames. Briefing screens render the previous mission's live warnings behind the panel.
- **Direction.** Turn uncertainty into instruments (arrival fans, confidence shading) and cut text to one or two lines.

### F5. Alien superiority has eroded and the AI is shallow

Inherited departure from v7 · confidence medium-high.

- **Range inversion.** Silent Quietus passively sees at 240 and drones at 330 (simulation.gd:612). Sirens detect at 180 silent / 290 cruise (simulation.gd:695). In v7, Sirens out-ranged the sub's 130 passive bubble (v7 lines 105, 187-194). Silent players now see first, every time.
- **No escalation** outside the finale.
- **Shallow search.** Patroller "search" just resumes the patrol route (simulation.gd:727-729).
- **Fixed ambiguity.** Ambiguous-branch choice is seeded only by the Siren's index (simulation.gd:750; acoustic_paths.gd:77-85), so each Siren always lands on the same quantile.
- **One sprite.** A single Siren sprite is stretched per role (ocean_view.gd:437-446); the approved serpentine design is unused.
- **Ledger gaps.** The parity ledger omits v7's suspicion heartbeat and hostile vignette (v7:385, 560), and Godot has neither. It also omits the range inversion.

### F6. Art and audio breadth lag the systems work

Confidence medium.

- **Art.** One basalt texture, one Siren sprite, one foundry image.
- **Audio.** About 15 sine and noise cues (soundscape.gd:19-63), with no tension layer and no Siren voice, in a game named for a song. This comes from code only; the auditor did not listen.

### F7. Process overhead

Confidence high on numbers, medium on interpretation.

- **Commit mix.** Of 405 non-merge production commits: 200 are docs-only (49%), 119 touch game/src (29%), and 67 are tooling.
- **Doc churn.** CONTINUATION was rewritten 95 times and WORKBENCH 99 times in about 40 hours.
- **Source focus.** Recent source commit subjects are dominated by "truthful / expose / qualify / reject malformed saved state."
- **The current next task** automates an observed-task withdrawal that the team's own note says "exactly matches" a 54.97 s manual run.

## Next development passes

Run these three in order. Stakes come first because they give the existing branch choices teeth.

### Pass 1: Stakes

- **Endurance.** Scale O2 and battery to mission length so drones become a budget.
- **Attention economy.** Restore v7's evidence-floored Hunt, kept local and knowledge-fair. It should raise patrol density and speed as evidence is taken, so the return leg differs from the approach.
- **Sirens.** Give them hearing that out-ranges a moving player, and patrollers that actually sweep last-known areas.
- **Re-tune** the sluice, sampler and origin choices under that pressure.
- **Success evidence.** End-of-mission O2 and battery spread across roughly 20 to 70%. At least two viable strategies per operation with neither dominating, shown by independent critic agents playing through real input with different strategies.

### Pass 2: One real operation

- Replace the 6 to 13 chain's slabs with one large hand-authored polygon region at C01/C02 composition.
- Give it a mixed roster including the serpentine Siren, earned terrain for that region only (the ledger's unresolved row), currents or thermal, optional discoveries that change the branch, and a real resolution scene.
- **Success evidence.** The FIT frame resembles C02. Playtime is 8 to 15 minutes. Different critic agents take different routes.

### Pass 3: Instruments over caveats

- The planner draws the same chart as play, including other craft's routes.
- Default follow framing shows the threat situation. Hull art is sized to physics, or becomes an icon when zoomed out.
- Briefings shrink to two or three sentences; controls are taught in-mission.
- Add a route map and replayable branches, via a profile slot or branch replay.
- Run the overlap audit on ordinary-play frames, not hero frames.
- **Success evidence.** No briefing scroll. Zero label collisions across sampled live frames. A critic agent plans and executes a two-craft route through injected touch on cover and inner views without opening STATUS.

### Deprioritize

Observed-task automation and the TASK/NONE planner; new chapter IDs; further qualification wording; save-shape expansion; governance tooling; per-merge evidence packets.

## Documentation and orchestration compliance

The docs are honest about what is unfinished; they claim no endings or balance. The machinery around them checks wording, not behavior.

- **Length.** WORKBENCH and CONTINUATION break AGENTS' own "keep short" rule. They read as SHA and test-count ledgers, with spaces stripped before numbers ("Reviewed8c2e6fc").
- **Dispatch.** It looks for a `## Current execution contract` heading that AGENTS.md lacks (gauntlet-boundary.py:79), so every brief carries all 9.5 KB of AGENTS.
- **Linter.** It only checks that files contain words like "stale" (check-gauntlet-guidance.py:75-91).
- **CI never gated a feature.** PR checks fire only on `pull_request` (gauntlet-pr-checks.yml:3-6). The repo has 5 PRs ever, all maintenance or promotion, so the existing game-smoke check never gated a feature merge. Merging through PRs would be a cheaper and more real gate than the hook system.
- **Unverifiable.** Hook installation lives in .git, and live orchestrator behavior is not visible in Git.
- **Restore gap scope.** `sensor_clock` (simulation.gd:462-464) and `pass_through` are not restored (simulation.gd:831-837). Effect: up to one 0.15 s early observation after reload, and PASS/STOP mode reverts. This matters for bit-exact proofs; players will not notice.

## Evidence limits and open questions

Runtime evidence covers the sim and software renders only.

- **Ran.** Pinned Godot 4.6.3 (SHA-512 matched) on an isolated copy. Headless naive controllers on missions 0, 1, 3, 5 and a fixture of 11. A 300 s idle test. A sim cost probe: about 0.8 to 1.1 ms per tick on desktop, without rendering.
- **Rendered.** Software renders at 2520x1080 and 2184x1968, plus the team's 8 packet images. The rendered contact sheet is held by the user and was not committed.
- **Not exercised.** Torpedo, decoy, sluice, transmission, sampler or correlator in motion; save and reload; any listening; Android, Fold7, touch, or device performance.

Open questions:

- Does the sluice ever beat the detour under real patrol phase?
- Has any agent played missions 6 to 13 through real input, rather than scripted controllers?
- What does the fog loop (ocean_view.gd:194-198) cost on device at FIT?
