## 28 October 2026: late campaign decides the ending (handoff 088)

[PAT, quoted in Claude S5 handoff 088] Claude asked: "Should what you do in arcs 4 to 6 be able to change which ending you get? Today the ending is locked at ops 12/13 ... I'd queue a follow-up that moves the decision to op 34." Pat answered: "Sure that's fine".

[KEEL / AI-DESIGNED, pending Pat ratification] The thread remains fixed. At op 34, Glass service/sever, Choir bypass/isolate and Choir plant reconnect/dismantle vote overt/concealed respectively. Two matching votes with a strict majority select that channel; ties, sparse and empty records retain Confluence. Expedition resolution and save fields stay unchanged.

## 28 October 2026 (later): efficiency baseline

Pat: Claude is the sole Claude orchestrator (Opus 5.5, medium effort) with autonomous responsibility for planning, architecture, research direction, Codex delegation, integration oversight, documentation, GitHub coordination and release readiness. Claude launches no Claude subagents, agent teams, forks or nested workflows. Parallel implementation, debugging, testing, code review and bounded research go to Codex, which may use its own parallelism within clear, non-conflicting boundaries (orchestrator Sol6.1 medium, weakest capable workers, independent Sol6.1-high reviewer, never Astra). Read the ledger, docs and GitHub state before planning; reuse findings; inspect only relevant files; delegate long-running commands and full test runs to Codex; investigate failures before retrying. Keep a persistent task queue (BOARD.md), a lightweight execution ledger (docs/codex/LEDGER.md) and a restart handoff (docs/codex/HANDOFF.md) current; on restart reconcile real GitHub and Codex state before issuing work and never repeat work because a conversation restarted. Goal: maximize verified, finished software per unit of Claude usage, without reducing scope or quality. The 28 Oct independent-review rule stays in force.

## 28 October 2026: bounded delegation and independent review

Pat directs root to stay in control, stop idle worker loops, and re-task bounded workers as needed. A separate high-confidence independent reviewer checks changes before new commits and merges. This supersedes earlier entries dropping per-feature review. Implementation workers prepare patches without self-committing; root verifies review approval matches the frozen patch/head before committing and requires current passing checks before merge. Reuse valid review for unchanged code; review substantive fixes and conflict resolutions.

Codex may use subagents while Claude is cooling down: Sol6.1 medium orchestrator, weakest capable implementation model/effort, no Astra. Factual questions require checking current internal docs or targeted official research first. Surface only necessary owner questions; subjective/design intent is Pat's unless already documented. Existing protected design, no-APK and source/save preservation rules remain.
## 27 October 2026 Eastern: resume

**RESUMED, 27 Oct 2026 ~19:17 ET:** Pat told Claude "Resume". This lifts the 27 Oct documentation-only pause (ruling 7). Rulings 1 to 6 stand as design direction. Work order for Codex: 055 (repair PR150's hosted fitting/touch regression, green CI, merge), 056, 057, 058, then 059 (challenge pars and per-route bests from rulings 2 and 3). Same rules as ORCHESTRATION_2026-10-26.md. The 26 October finish-the-game entry below governs.

## 26 October 2026 Eastern: finish the game

Pat: the goal is to finish the game. Prioritize completing content; tests only when absolutely necessary; audit everything at the end. Claude is root orchestrator and delegates lanes to Codex; Claude and Codex each orchestrate their own subagents and stay out of each other's files. Every task ends by cleaning up its claim, recording completion and correcting stale docs it touched.

- **Supersedes** the per-feature independent nonauthor review and evidence-archive requirements in the 25 October entry and older text. Merge on green guidance + game-smoke for the exact head (merge commit). One whole-game cold audit follows content completion.
- **Minimum tests:** import + core; new suites only for new save fields, new core operations (one bare-Quietus finishability journey) and outcome-deciding math. Never skip, loosen or delete a test.
- **Promotion:** Pat chose milestone promotions (option A). Claude opens a PR from claude/integration to gauntlet/production at each big milestone; Pat merges it.
- **Plan and ownership:** `docs/codex/ORCHESTRATION_2026-10-26.md` on `codex/handoffs` (Codex stream 050-053; Claude stream C1-C6: economy, equipment/tools, modes/expeditions, naval career, settings gaps, doc sweep).
- Unchanged: protected combat/sensing rules, sight-only Hunt boundary, placeholder story within the provisional bible, no APK, no force push, no branch deletion.

## 25 October 2026 Eastern: local continuation and reversible work

Pat continued the authorized queue, asked Codex to follow guidance and reconcile stale owned documentation while working, and approved Codex taking over unfinished 048 HUD and 050 after its existing tasks. The live board on `codex/handoffs` owns order, claims and completion; Claude's absence does not block ordinary authorized implementation, independent review or green integration merges.

Pat accepted sight-only Hunt first for 050. Global Hunt may increase sight notice range; hearing, movement speed and lock timing stay unchanged. The earlier proposal to scale hearing through shared readiness is superseded. Other proposal numbers/caps remain tunable defaults for testing, not claimed human acceptance. No hearing scaling is implicitly authorized later.

Make ordinary choices reversible through narrow modules, data tables, off switches and documented reverts; ask concise questions where needed and keep independent work moving while responses are pending. This does not authorize irreversible promotion, new story/art direction, SIREN TELL or unapproved protected combat/sensing changes. Phone/human testing stays deferred until feature complete and tuned. Existing no-APK, save/evidence preservation and exact-head merge gates remain.

Pat's later 25 October instruction: keep documentation clear, reconcile stale owned text without erasing history, and report verified task completions. Before implementation changes, use focused official web research and check existing project/library solutions. Prefer established approaches and reuse; keep research, delegation and test repetition proportionate to reduce token and compute overhead. This does not replace required independent review or final-head checks.

## Historical 23 October 2026 cloud stop and Windows handover (superseded by local resumption)

Pat requested: finish the current task, leave the last actions in the repository, update stale documentation and prepare the move from cloud to desktop with notes for Pat, future Codex sessions and Claude Code. Pat explicitly selected **finish PR96 only, preserve the remaining handoff023 steps, then hand over and stop**. The desktop is Windows.

Do not continue game implementation after PR96 in this cloud session. Preserve the prepared photo-review branch and the partial023 claim; metrics and the shared feature contract remain unstarted. Publish the requested documentation and recovery notes, then stop. Resume only when Pat asks on desktop. This is an execution boundary, not a declaration that the project is finished. Standing design, merge, no-APK and frozen-branch rules below remain in force. Current source/claim facts: RESUME.md and the codex/handoffs board. Windows setup and role-specific notes: DESKTOP_HANDOFF.md.

## 23 October 2026 (later): decisions after full cold review 2 (all YES, each revertible)

Pat answered "yes to everything" and asked for each to be marked so he can revert. Each item below is a self-contained module with an off switch in its data table and a revert note in its header. To revert one, set its switch off (or revert its PR) and strike its line here.
- D1 FIRST-SIREN CUE (ops 1 to 3 only): a warning cue (sound plus bearing mark, no rule change) when a Siren first notices any craft BEFORE the 4 s lock begins. Does not change Siren sight or hearing, lock timing, or beam. Handoff 036. Switch: `first_siren_cue` enabled flag. Reverts to: lock banner is the first signal.
- D2 EARLY MODULE REWARD (historical one-grant version, superseded by045's three grants): one free fitting module granted after op 1 (or op 2 if op 1 data forbids), chosen from existing modules, so Fittings is not empty through ops 1 to 3. Handoff 037. Switch: `early_reward` enabled flag. Reverts to: no grant. Stored saves keep the module; revert only stops new grants.
- D3 PHOTO GRADE AT RECORD SECURED: show the quality percent and grade letter when "Record secured" appears, not only in the debrief. UI only. Claude builds it. Switch: `grade_on_secure` flag.
- D4 DEBRIEF CAUSE LINE and the rest of FIX2 (handoff 035) approved as written.
- D5 PHONE TESTING: Pat tests on a real phone only after the game is feature complete and bug free; then he reviews and a new Gauntlet run starts on top. No APKs and no device-test requests before then.
## 23 October 2026: development RESUMED by Pat

Pat has resumed development. The organization pass below is complete; Codex has claimed handoff 019 (PR81). Claude is root orchestrator again under the standing delegation. The pause described below is superseded and kept as dated history.

## 22 October 2026 (night): development paused for repository organization (SUPERSEDED 23 Oct by resumption)

Pat reports that all development is paused, Codex finished its current task, and Claude has not restarted. Organize and reconcile the repository first. This organization pass is authorized; gameplay implementation, next-handoff dispatch and autonomous continuation remain paused until Pat resumes development. The earlier continuation instructions below remain the standing workflow for that later resumption. Preserve completed work, queued tasks, parked work, saves, signing identity and historical sources.

## 22 October 2026 (evening): guidance reconciliation

Pat authorized correcting the audit's guidance findings while preserving current work. Prepare the changes on an isolated branch; reconcile at the existing integration boundary. Existing claims, ownership, handoff order, gameplay decisions and promotion permissions continue. The earlier 21 October temporary ban on documentation reconciliation is superseded for this authorized pass; its other preservation rules remain.

Development integration is `claude/integration`; `gauntlet/production` remains the frozen promotion baseline and `main` the protected accepted baseline. Pat authorizes promotion. RESUME owns the operational snapshot and links live refs/PRs; the board on `codex/handoffs` owns Codex assignments and claims. Stable rules, intended behavior, dated history and current status retain distinct homes. Earlier milestone/next-action wording below records its dated phase; consult RESUME for actual work. Preserve original directives as provenance.

## 22 October 2026 (afternoon): decisions and a standing engineering rule

**Decisions (user, "yes to everything"):** Priced Shots design approved: finite film (Quietus 8, drone 4; unusable or interrupted exposures cost film), light and distance trades, timing windows, fittings that open or reprice routes (sleeve, thermal imager and tele lens gate optional bonus features only; core jobs stay finishable bare), tele lens cannot hide the 520 m shutter noise, ops 0 and 3 oxygen unchanged, Disrupt stays 12 s and 2 charges. Photo depth-band choice approved (shallow and deep as clarity and risk trade-offs). Studying a subject may make small, readable rule shifts (for example a sentinel's patrol timing); both of these touch depth or detection, so a design is shown to Pat before building. Order taps keep the confirm-on-busy-craft rule. First Siren warning in ops 1 to 3 pauses once. Claude builds handoff 009 (sweeper).

**Depth-band photos and findings (user answers, 22 Oct):** design at the scratchpad file DESIGN_DEPTH_FINDINGS.md approved with: deep photo oxygen charge 0.075/s yes; the craft's own shutter noise ring varies by band (louder shallow, quieter deep) yes; Sirens may NOT be studied from a band other than their own; author two patrol loops on ops 1 and 2 yes; the SIREN TELL idea waits until after the sweeper rebuild. Build order: PRICED1 merges first, then DEPTH1 (modules photo_depth and photo_rules, self-contained, numbers in one table, optional band field on each shot).

**Campaign and ending answers (user, 22 Oct):** the true ending moves to after op 25 with a final pair of operations after Iron Choir's core (the existing four endings and the op 12 and 13 fork stay as the story fork; ops 12 and 13 remain the fork); "person" photo findings are human survivors shown as marks only (no new story text); the ending is built as an annotated wall of the player's best film first (a scene variant may follow). Film never gates a route; Siren studies shift timing on core ops only small and readable. Text for the final pair and the ending stays 1 to 2 line placeholders until Pat supplies narrative.

**INPUT PRIORITY (user, 22 Oct):** the primary release target is Android, so every feature is touch-first: on-screen controls at least 48 dp, tap, hold, drag and pinch, the Android back gesture/button as the Escape equivalent, no hover, no keyboard-only paths, nothing that needs a physical keyboard. Keyboard stays a working fallback (desktop testing, accessibility) but is never the design target. New UI is verified with the real-touch test harness at the Fold7 cover and inner shapes, not only keyboard events.

**STANDING DELEGATION (user, 22 Oct afternoon):** Pat approves building the game to spec on Claude's understanding of the plan. Every recommendation Claude has put to him so far is approved, including: a true ALL-STOP for Quietus (engines off, coasts to rest, zero throttle noise, at a cost of oxygen and time; own module, touches noise rules, approved); ARCH1 behavior-preserving cleanup; one optional band-guarded photo subject so the pressure sleeve earns its place (fold into DEPTH1); Well op 4 hunter data fix; sweeper lane-walking deferred; tutorial first-warning pause; order-confirm rule kept. Condition: everything must be documentable and revertible (self-contained modules, numbers in data tables, optional validated save fields, a revert note in each module header) and must stay on the plan, not wander. Claude decides ordinary implementation and sequencing itself and asks Pat only at specific decision points: changes to combat, beam, collision, damage, hull or Siren sight/hearing rules not already approved here, story/characters/endings, new design pillars, and anything irreversible. If the plan is unclear on something, ask.

**STANDING ENGINEERING RULE (applies to every builder, Claude and Codex):** keep each feature as self-contained as possible so it can be changed or reverted without breaking much else. Code must be modular, scalable, upgradeable, consistent and easy to work on, without sacrificing fidelity or competency. In practice: new systems go in their own files or folders with one narrow, documented seam into existing code (a registration point, not scattered edits); tunable numbers live in data tables, not buried in conditionals; saves gain optional, validated fields so removing a feature does not corrupt saves; tests live beside the feature; follow the naming, structure and comment density of the surrounding code; prefer extending a clean seam to patching a large file; no duplicated logic. Report any place where the existing structure makes this hard instead of working around it silently.

## 22 October 2026 — PHOTOGRAPHIC RECONNAISSANCE IS A CORE PILLAR (user design correction)

**Ratified premise (user, not proposal):** Siren's Song is primarily a military photographic reconnaissance game, with Iron Lung an important mechanical and atmospheric influence. Quietus is a vulnerable military recon submarine sent to investigate the Sirens, their structures, behavior and danger, using sonar, hydrophones, stealth, cameras and drones. Photography is a central, recurring, consequential activity, not an interaction that completes an objective. Rescue, towing, salvage, industrial work and fleet management are valuable expansions that support this; they must not displace it. The Sirens were here first, built the factory/base and are becoming dangerous. Rescue becomes relevant as Siren consequences become apparent.

**Intended outcomes (design freedom on implementation):** viewpoint, distance, orientation, visibility and conditions change the image; images carry genuinely observed information shaped by player choices; photos reveal things that change planning, research, opportunities and later encounters; better images cost risk, exposure or time; subs and drones photograph differently; camera gear, interpretation, archive and research progress with the equipment systems; capturing and examining photos is atmospheric, readable and central. Fair information and physical simulation stay: no omniscient photo rewards, no generic objective confirmations dressed as reconnaissance. Not every operation needs the same photo task.

**Orchestration:** one substantial integrated PHOTO1 milestone (camera, viewpoint, evidence, discovery, progression, with representative playable ops), reusable architecture, no camera-button tweaks, cosmetic galleries or micro-PRs. Existing workers, branches and milestones continue. The comprehensive cold review runs after PHOTO1 and must judge whether photography is compelling and central, by playing, including comparison with Iron Lung. Capabilities, gaps and drift: docs/PHOTO_RECON.md.

## 21 October 2026 — user pause, story rulings and orchestration handoff

**PAUSED: ORCHESTRATION HANDED TO CLAUDE.** The user's direct pause handoff overrides conflicting autonomous-continuation and worker-orientation instructions below and in other governing documents. Finish or park only the already in-flight Iron Choir work, publish the requested pause checkpoint, then stop. No follow-on task, cycle or worker. See [pause checkpoint](PAUSE_CHECKPOINT_2026-10-21.md).

- **Story ruling:** the Siren-evacuation / human-fleet-threat arc is rejected as unratified AI fabrication and will be stripped. Rescue subjects are **human survivors from both deep-sea drilling/oil-rig operations and military installations**. Sirens strike those sites because drilling and military activity register as potential threats. Quietus must reach the survivors while avoiding becoming a threat itself; noisy rescue work attracts Siren attention. Sirens remain superior aliens who kill perceived threats; tools protect the player but never permanently disable a Siren. **Do not author new narrative text.** Claude orchestrates the rewrite; the user approves characters, site sequence and ending conditions before they land.
- **No cleanup now:** preserve branches and governing documents apart from these explicitly requested pause additions. Do not start a branch-retirement or documentation-reconciliation pass.
- **Permanent worker scoping:** each worker receives a tightly bounded task brief and reads only that brief, the short guidance it names, and directly relevant source files. No whole-codebase or full-governance orientation. If context is missing, fix the brief.
- **After the checkpoint:** Claude is root orchestrator; Codex works only in Claude-assigned review, criticism or nonoverlapping implementation lanes. Production is frozen at the published pause-checkpoint tip, with no direct pushes. Claude creates `claude/integration` from that tip; lanes publish file ownership, branch from it and return by PR. The user approves coherent promotions to production. Keep Godot 4.6.3/Compatibility, physical movement, fair information, finite tools, unlimited pause, green CI before merges, original v7 and existing branches. No automatic APKs.

# Current user directives — read before accepting work

## Latest priority — substantial playable content
Prioritize substantial new playable content; concentrate regression, bug hunting and refinement at meaningful integration boundaries or when continuing would become prohibitively difficult or expensive. Preserve current-milestone independent approval, final-head CI, physical rules and fair information.

## Current content batch — Iron Choir
Glass Reach14–21 landed via PR49/production16b1a505 after independent approval and mandatory CI39515575589. Continue the approved program with four core22–25 and four optional26–29: moving industrial freight/people, pressure locks, interceptor/warden roles, two physical artifact rewards and tangible local infrastructure choices. Same sole builder/branch through internal checkpoints; review/CI/PR only for the complete accumulated batch. Opening depth/sonar PR48 remains preserved.

## Prior execution correction — completed six-operation milestone
First milestone: integrated depth, sonar and stealth across opening operations0–5. One builder continues on the same milestone branch after each internal task/checkpoint. Author distinct encounters through shared systems, preserve baseline-fleet completion and existing physical evidence/cargo/recovery. Use focused checks during tasks; accumulate broad regression, performance and adversarial checks at the complete milestone boundary. Review the accumulated branch with the same independent reviewer, fix/re-review there, then mandatory final-head game-smoke CI and a normal PR. Do not integrate isolated subtasks or move to fleet/economy before this milestone. This supersedes older per-feature merge wording; the full-release program below remains authorized.

## Approved order — full-release execution
Implement the approved full-release expansion in docs/CURRENT_GAME_SPEC.md. The user approved campaign/replay first, then roguelite expeditions and naval career, three tactical depth bands, persistent recoverable costs by default with refill/heavy-attrition settings, and24–30 core operations (production target28) plus12 optional operations. This order supersedes prior rough-only/one-operation scope limits and authorizes new campaign content and substantive release polish. Preserve accepted Pass0/V7 work and all saved evidence.

Use Sol6.1 Medium with one implementation worker and one integration reviewer, short task-specific context, coherent feature batches, affected checks and required final-head CI. Wider impartial reviewers run sequentially at substantive complete-game boundaries. No new governance framework, routine APK cycle or further design-approval gate. Preserve native risk validation, canonical signer, branches, saves and fair information. Human playtesting never gates development; only the user ends the Gauntlet.

## Prior rough-recovery order — retained provenance
**Finish Pass 0 and the V7 full-game directive first. Then Stakes → One real operation → Instruments over caveats.**
The later [order correction](directives/2026-10-20-order-correction.md) governs the earlier [audit reaffirmation](directives/2026-10-20-audit-reaffirmation.md). Both are recorded verbatim.
The user decides when to playtest. User play, approval, and an agent readiness rating never gate ongoing development.
Only the user ends the Gauntlet; complete tasks automatically dispatch the next authorized work.

## Historical accepted baseline and prior phase scope
These paragraphs record earlier decisions and implementation provenance. Their rough-only limits, placeholder acceptance and chapter shelving are superseded by the approved full-release order above; technical preservation rules still apply.
The prior phase built the fixed [Pass 0 campaign](https://github.com/pemunson90-cmd/Siren-s-Song/blob/archive/docs-pre-sweep-20261027/docs/PASS0_CAMPAIGN_PLAN.md) and functional V7 recovery under [the living game specification](CURRENT_GAME_SPEC.md) and [parity ledger](V7_TO_GODOT_PARITY.md).
The rough campaign nodes, four endings, general craft upgrades and mixed enemy rosters are implemented. Full branch touch journeys remain unfinished.
The integrated V7 recovery builds currents, sensor-earned terrain, an evidence-driven local pressure floor, threat heartbeat/vignette and photographic grading. The PR gate passed; evaluate the whole game and develop the audit quality passes; preserve accepted Godot adaptations and fair information.
The prior phase accepted placeholder art/text/audio and rough balance. Drop legacy-save compatibility and reject incompatible saves cleanly.
One blocker-focused reviewer per merge: crashes, softlocks, unfinishable branches and corruption of current saves. Features use PRs with game-smoke passing.
No routine label/layout polish, save-validation expansion, evidence packets or governance tooling during Pass 0.
Stakes, the authored Confluence and practical fleet instruments are integrated.
Earned-course continuity and physical module recovery are integrated; optional kit now has a lasting fleet consequence.
The physical Deep Rendezvous tender is integrated with its quiet fallback.
Route-first fleet interaction and Blackwater packet delivery are integrated. Collected raw buffers now require local delivery to Quietus.
Warning Chain now integrates positional power, physical outputs and withdrawal choices; continue genuine and explicitly staged first-exposure evaluation.
Craft-anchored rings now replace detached cards, preserving critical reserves, work/cargo/power and full touch targets. Named recovery choices retain drive/profile and ordinary route intent. Concealed Record now requires physical witness cargo, local landing and Quietus recovery; evaluate its return journey while preserving genuine campaign continuity.
Open Warning now requires a vulnerable recipient's physical transit and received arrival before Quietus recovers. Earned service proof can operate its gate; bare Quietus has a manual fallback. Evaluate the actual course tradeoff and narrative payoff rather than treating technical finishability as compelling play.
Genuine full-game journeys continue; focused Confluence play uses explicitly staged access. The cumulative adversarial inventory is published on gauntlet/checkpoint/execute-2026-10-20 under tools/checkpoint/execute-2026-10-20/fullspec/INVENTORY.md; all remaining findings stay open. Shelf Return now contains occupied galleries, actual warning/reply choices and a masking front. Concealed Record now gives the rescued navigator or harbour keeper distinct environmental work and received local consequences. Evaluate actual choices and payoff on both routes, including full cover-operation play; retain remaining campaign, enemy, growth, presentation and audio expansion rather than treating technical completion as compelling play.
The user’s camera-control tweak is implemented: FOCUS/FIT/zoom live under FLEET → VIEW; direct drag/pinch remain.
Old experimental branches remain preserved. Observed-task automation and TASK/NONE remain shelved; new full-release chapters are authorized through the operation catalog.

## Worker inheritance and continuity
Root reads this file and current production guidance before every dispatch/review/merge and includes this path plus the fetched governing revision in each brief.
Workers read the current directive before the living spec and their task. Report conflicts and reconcile against the latest user instruction; preserve completed work.
Use the existing task-boundary refresh procedure. No new orchestration framework is needed.
Current user directions outrank historical workflow prose. Preserve older directives as provenance instead of silently rewriting their text.

## Audit and checkpoints
The user's current adversarial mandate requires a cumulative, whole-game deficiency inventory against a commercially competitive Android release before selecting the next improvement. Inspect the specification, campaign, running game, progression, endings, controls, visuals, audio and technical behavior; keep genuine campaigns and substantive implementation running in parallel.
For each material finding retain evidence, player consequence, severity, expected quality, substantive remedy and whether it blocks progress, needs expansion or is later polish. Distinguish implemented, observed, untested, incomplete and aspirational. Independent domain critics may disagree; investigate evidence and preserve unresolved findings rather than reducing the audit to the selected repair.
Compare actual gameplay with strong shipped references and disclose comparison limits. Challenge optimistic completeness claims, unearned outcomes, shallow choices/progression and functioning features without compelling play. This expands quality investigation, not the one-reviewer integration gate, and creates no additional governance machinery.
The unchanged Claude audit, audited source, F1–F7 response and checkpoint refs are on archive/claude-audit-2026-10-19 under docs/audit/.
Genuine critic saves and raw input are published on gauntlet/checkpoint/touch-play-2026-10-20; source and session provenance remain explicit.
Agent play and software renders support game development; human enjoyment, headphone audio and physical Fold7 ergonomics require their own evidence.
