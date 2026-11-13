> **How to read this file.** This is the one home for Pat's rulings, verbatim and dated. Entries are never rewritten; a later ruling overrides an earlier one. The sections below are not in date order: the 29 October entries come first, older entries follow under "Current user directives", and everything from 29 October to today is appended at the end under "Rulings copied from codex/handoffs" and "Rulings recorded by the overhaul run". Lines tagged [KEEL], [AI-DESIGNED] or "Operating effect" are agent notes, not Pat's words. Where an old entry forbids APK builds, sends promotions to `gauntlet/production`, forbids Claude builders or drops per-feature review, the later rulings at the end govern; `docs/GOVERNANCE_MIGRATION.md` lists each such case. [Note added by the overhaul run, 2026-11-12, AI-written.]

## 29 October 2026: interruptible local Siren radio (handoffs 104/116)

[PAT, verbatim ruling recorded in PAT_RULINGS_2026-10-29.md, item 6] "On ops with 2+ patrolling Sirens, should they radio each other with a visible charge-up you can interrupt? (Protected, your call.)" = "Yes, 2+ patrollers (Recommended)"

[KEEL / AI-DESIGNED implementation] New multi-patroller operations enable a 3s, local acoustic report carrying a coarse last-seen point and observed depth. Breaking sight, Disrupt or a received distraction cancels the charge. Fresh local evidence stays authoritative. Existing revision-one dives retain their original behavior. Final Marks31 and Calder Gallery33 relocate existing watches to make recovery approaches expose the report choice; small physical screens offer a quiet break. Other protected rules retain their existing behavior. Phase B owns fleet measurements and the PR intent table.

## 29 October 2026: one-band thermal acoustic cover (handoffs 105/115)

[PAT, verbatim ruling recorded in PAT_RULINGS_2026-10-29.md, item 7] "Should the thermal layer cover only one depth band, so picking a depth decides who can hear you? (Protected, your call.)" = "Yes (Recommended)"

[KEEL / AI-DESIGNED implementation] Each authored thermal front masks only its named band, with emitter and listener settled in that band. Transitions retain an exposed path. Briefing and chart name the band. Foundry uses MIDDLE; the optional shelf exhaust's narrow MIDDLE strip and relocated existing deep watch make a louder flash-photo return favor MIDDLE over DEEP. The flash policy is one legal route, not proof of globally optimal depth. Other protected rules retain their existing behavior.

## 29 October 2026: tool cargo in Career and Expedition (handoff 117)

[PAT, verbatim ruling recorded in handoff 117, chat ~17:50 ET] Claude asked "Should extra tools cost cargo in Career and Expedition too (today campaign only)? I recommend yes, so the loadout choice matters everywhere." Pat: "Yes to all".

[KEEL / implementation scope] Career and Expedition launches use the shared per-craft tool lockers and cargo overflow rule with their own supplies. Cargo weights, locker sizes and extra-charge prices remain AI-DESIGNED. Existing active dives retain their stored stock and capacity rules.

## 29 October 2026: optional tactical pause aids and mirrored HUD (handoff 111)

11. "Add tactical aids such as auto-pause when a Siren first notices you, as an Accessible option off by default?" = "Yes (Recommended)" (11)
18. "Add a mirrored HUD option for one-handed play?" = "Yes (Recommended)" (21)

[PAT, verbatim selections recorded in PAT_RULINGS_2026-10-29.md, Claude S6] Both options are authorized.

[KEEL / implementation] Device settings offer separate first-notice and received-lock pause toggles plus mirrored HUD, all off by default and available on any preset. First notice uses the existing any-craft acquisition signal, once per Siren during the dive; a fresh received lock episode on any living craft also pauses when enabled. Brief gaps for the same Siren/craft pair coalesce until two continuous clear simulation seconds (AI-DESIGNED UI rearm); a different Siren or target pauses immediately. Optional presentation history survives active-dive restores, including Expedition and Career, so an ongoing notice or warning does not replay on resume. Older saves prime live craft acquisitions and received warnings. Pause is unlimited and resumes through the ordinary control. Mirroring swaps pause/fleet sides and radial side actions with matching touch wedges. Warning timing, sensing, beams, collision, hull and damage retain their existing rules. No phone acceptance is claimed.

## 29 October 2026: presentation placeholders (handoff 113)

[PAT, verbatim selections recorded in PAT_RULINGS_2026-10-29.md, Claude S6]

15. "Give each hull and chassis a distinct silhouette so you can tell them apart at a glance? (Art, your call.)" = "Yes (Recommended)" (17)
16. "Give each Siren role its own sound, heard only once sonar has earned it?" = "Yes (Recommended)" (20)
17. "Add a little ambient sea life, in colours that never look like contacts and never on sonar? (Art, your call.)" = "Yes, limited (Recommended)" (19)
19. "Use a placeholder title art, icon and splash built from the Quietus silhouette until you supply art?" = "Yes, placeholder (Recommended)" (18, 22)

[KEEL / implementation scope] Silhouettes, synthesized role cues, limited visual sea life and replaceable Quietus key art are AI-DESIGNED placeholders consistent with the existing palette. Exact role sounds share the earned identification boundary from handoff 106. Sea life is decorative, excluded from sonar and chart, and disabled in battery saver. Simulation and campaign rules retain their existing behavior.

## 29 October 2026: second story fork in arc 5 (handoff 108)

2. "Add one more story fork in arc 5, so earlier play picks which later ops you get?" = "Yes, one fork (Recommended)" (2)

[PAT, verbatim ruling recorded in PAT_RULINGS_2026-10-29.md, Claude S6] The named arc-five fork is authorized.

[KEEL / AI-DESIGNED implementation] The recovered Confluence channel selects the recovery route for Pressure Stair and Choir Cut. Concealed and missing legacy facts retain southern recovery; overt uses existing northern/eastern water. Physical work, thread commitment and ending votes retain their existing rules. Active dives retain their stored mission and corridor.

## 29 October 2026: coarse sonar identification (handoff 106)

3. "Should sonar only show a rough Siren type until you see or photograph it? (Changes Siren sense display, your call.)" = "Yes (Recommended)" (9)

[PAT, verbatim ruling recorded in PAT_RULINGS_2026-10-29.md, Claude S6] The named sensing presentation change is authorized.

[KEEL / implementation scope] Sonar presents a coarse class until any craft sees the Siren or photographs identify it. Identification lasts for that Siren through the dive; recovered photographed dossier roles can pre-identify. Chart, contact list and audio use the same knowledge boundary. Class labels are AI-DESIGNED. Sensing, sight ranges, lock, beam, collision, damage and hull rules retain their existing behavior.

## 29 October 2026: expedition Siren starts and patrol timing (handoff 109)

8. "Should expedition seeds also shuffle Siren start positions and patrol timing (never their senses)?" = "Yes (Recommended)" (12)

[PAT, verbatim selection recorded in PAT_RULINGS_2026-10-29.md, Claude S6] This authorizes deterministic Expedition-only start placement and patrol phase along authored safe paths. Campaign and Career retain authored starts. Placement bounds and phase values are AI-DESIGNED; Siren senses, role, lock, beam, collision, damage and hull rules retain their existing behavior.

## 29 October 2026: Sorley pilotage charts (handoff 112)

[PAT, verbatim selections recorded in PAT_RULINGS_2026-10-29.md, items 12 and 13]

12. "Change the Sorley rescue reward from supplies to pilotage charts?" = "Yes, charts (Recommended)"
13. "Should the Sorley rescue count as one vote toward which ending you get?" = "No, keep it separate (Recommended)"

[KEEL / implementation] Rescue grants lasting MIDDLE-water pilotage passages in Needle Strait and Furnace Drift through earned-chart certification. Both rescue tiers grant charts; old rescue facts qualify automatically and earlier supplies remain. Charts disclose terrain clearance, never Sirens. Passage extents are AI-DESIGNED. The rescue epilogue stays separate from ending votes.

## 29 October 2026: distinct hunter and sentinel senses (handoff 103)

5. "Should hunter and sentinel Sirens each get their own hearing, search and attention, so each type needs a different plan? (Siren senses, your call.)" = "Yes (Recommended)" (6)

[PAT, verbatim ruling recorded in PAT_RULINGS_2026-10-29.md, Claude S6] This authorizes the named role differences. Silent sight 180 m, cruise sight 290 m, the four-second interruptible lock warning, beam, collision, damage and hull rules retain their existing behavior. New profile values are AI-DESIGNED and provisional.

## 29 October 2026: advanced economy and easier presets (handoff 110)

[PAT, verbatim selections recorded in PAT_RULINGS_2026-10-29.md, items 9 and 10]

9. "Add a small set of custom economy values (repair cost, income, starting stock) behind an ADVANCED toggle?" = "Yes, small set (Recommended)" (15)
10. "Allow switching to an easier preset mid-campaign (not in Ironman), marked in the ledger?" = "Yes (Recommended)" (16)

[KEEL / implementation scope] Advanced starts off. Custom settings are identified in campaign records. Easier preset changes outside Ironman take effect at the next dock and remain in ledger history. Numerical bounds and implementation details are AI-DESIGNED.

## 29 October 2026: Ironman permanent losses (handoff 107)

[PAT, verbatim selection recorded in PAT_RULINGS_2026-10-29.md, item 1] "In Ironman mode, should a drone or module lost in a dive be gone for good?" = "Yes, Ironman only (Recommended)" (QUESTIONS_FOR_PAT 14)

[KEEL / operating effect] Existing dive loss and non-recovery rules remove the lost drone or fitted module from the Ironman profile. Replacements cost manufacturing resources. Quietus remains available and an empty drone bay can launch, preserving the bare floor on ACCESSIBLE and STANDARD. Other modes retain their existing recovery behaviour. Replacement prices and implementation details are AI-DESIGNED.

## 29 October 2026: carried survivors slow ascent (handoff 102)

[PAT, verbatim as recorded in handoff 102, ~08:10 ET] Asked "Should carrying survivors slow how fast the sub can change depth? I recommend yes." Pat: "For now* Yes*". This ruling is provisional, "for now".

[KEEL / AI-DESIGNED provisional timing] Upward band changes with one survivor take 8 seconds, with multiple survivors 12 seconds, followed by 6 seconds at the new band before another ascent. Values stay together in survivor_ascent.gd for retuning. Existing carry permissions and tow restrictions remain authoritative; descent keeps its existing timing.

## 28 October 2026: hidden rescue of Sorley's boy (handoff 092)

[PAT, quoted in Claude S5 handoff 092, ~11:50 ET] "Experiment with a hidden rescue mission that requires either found logs off the beaten path, or certain photos. So its an option side quest with at least one game reward and ending changes."

[KEEL / AI-DESIGNED, pending Pat ratification] The experiment uses the existing op 37 boy photograph or two of three optional Sorley logs as discovery keys. Physical rescue uses the existing witness pod rules. The rescue adds an epilogue and ledger outcome; it does not vote on the ending family or change the thread.
## 28 October 2026: carrying tools costs cargo

Claude's question (QUESTIONS_FOR_PAT 13, verbatim): "today every loadout gets a fixed free bundle of tools. Should carrying tools cost module slots or cargo space, so a tool-heavy loadout means giving up a module? I recommend yes, because it turns the loadout into a real planning choice."

Pat (verbatim, ~14:13 ET): "Yes to your open question."

Operating effect: finite charges share each carrying craft's cargo with modules and winch work. ENDURANCE, DISRUPTION and SURVEY are editable starting templates; empty racks remain launchable. Handoff098 implements this through optional per-profile racks, old-loadout migration and owner-aware deployment. Specific cargo weights, allocation and extra-charge prices are AI-DESIGNED provisional choices, not Pat-ratified numbers. Existing tool effects stay unchanged; Torpedo and Hull patch retain their demonstrated Quietus-only guards. Other tools already deploy from the selected craft and now require its own stock.

## 28 October 2026: fleet, tools and bare-launch finishability

Pat's ruling (verbatim, ~12:25 ET):
"I'm worried that the goal is to make sure everything is finishable with just the sub, that makes sense for the easy and normal difficulties for now, but if there's no progression skill and planning and usage of the tools and drones etc, then we don't really have a game we kind of just have a waypoint simulator"

Pat follow-up (verbatim, 28 Oct 2026 ~12:30 ET): "I mean I guess a skilled player should be able to do it, but I still you know walk the game to feel like a game and not just a walking simulator in a submarine"

**Operating effect, Claude's reading of both quotes; Pat may correct it:**
- **Bare finish is a skill feat, not the easy path.** A skilled player should be able to finish required ops with a bare launch (no finite tools), but it should be demanding: tighter timing, more exposure, close calls, worse results. On ACCESSIBLE and STANDARD it is also the anti-soft-lock floor. On SURVIVAL it may be very hard, but should stay possible for an expert.
- **Design target, every preset:** planning, drones, tools and progression must change the outcome. The bare minimum finish should be clearly worse than a planned, equipped finish (fewer people out, worse photos, lower pay, more Hunt, harsher ledger or ending lines, missed side objectives).
- The spec already says "viable baseline fleet solution" (Quietus plus bare drones). Handoffs that say "bare Quietus alone" were stricter than the spec, and that wording is superseded.

## 28 October 2026: late campaign decides the ending (handoff 088)

[PAT, quoted in Claude S5 handoff 088] Claude asked: "Should what you do in arcs 4 to 6 be able to change which ending you get? Today the ending is locked at ops 12/13 ... I'd queue a follow-up that moves the decision to op 34." Pat answered: "Sure that's fine".

[PAT, accepted provisionally 28 Oct 2026 ~15:45 ET; quoted in codex/handoffs BOARD] "Keep the vote rule as is for now".

[AI-DESIGNED rule, now Pat-accepted provisionally] The thread remains fixed. At op 34, Glass service/sever, Choir bypass/isolate and Choir plant reconnect/dismantle vote overt/concealed respectively. Two matching votes with a strict majority select that channel; ties, sparse and empty records retain Confluence. Expedition resolution and save fields stay unchanged.

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

**PAUSED: ORCHESTRATION HANDED TO CLAUDE.** The user's direct pause handoff overrides conflicting autonomous-continuation and worker-orientation instructions below and in other governing documents. Finish or park only the already in-flight Iron Choir work, publish the requested pause checkpoint, then stop. No follow-on task, cycle or worker. See [pause checkpoint](../_scrap-20261111/docs/PAUSE_CHECKPOINT_2026-10-21.md).

- **Story ruling:** the Siren-evacuation / human-fleet-threat arc is rejected as unratified AI fabrication and will be stripped. Rescue subjects are **human survivors from both deep-sea drilling/oil-rig operations and military installations**. Sirens strike those sites because drilling and military activity register as potential threats. Quietus must reach the survivors while avoiding becoming a threat itself; noisy rescue work attracts Siren attention. Sirens remain superior aliens who kill perceived threats; tools protect the player but never permanently disable a Siren. **Do not author new narrative text.** Claude orchestrates the rewrite; the user approves characters, site sequence and ending conditions before they land.
- **No cleanup now:** preserve branches and governing documents apart from these explicitly requested pause additions. Do not start a branch-retirement or documentation-reconciliation pass.
- **Permanent worker scoping:** each worker receives a tightly bounded task brief and reads only that brief, the short guidance it names, and directly relevant source files. No whole-codebase or full-governance orientation. If context is missing, fix the brief.
- **After the checkpoint:** Claude is root orchestrator; Codex works only in Claude-assigned review, criticism or nonoverlapping implementation lanes. Production is frozen at the published pause-checkpoint tip, with no direct pushes. Claude creates `claude/integration` from that tip; lanes publish file ownership, branch from it and return by PR. The user approves coherent promotions to production. Keep Godot 4.6.3/Compatibility, physical movement, fair information, finite tools, unlimited pause, green CI before merges, original v7 and existing branches. No automatic APKs.

# Current user directives — read before accepting work

## 30 October 2026: authored closure and late evidence (125)

Claude asked: "Should Codex add an authored campaign ending plus more varied late-campaign evidence (F7/F8/F14), with story lines as 1-2 line AI-designed placeholders you can replace? I recommend yes."
Pat: "Yes". Ending conditions remain protected. Task125 adds read-only consequence lines and evidence interpretations, plus factual action wording; the branch structure and physical rules stay as accepted.

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

## Photo record art direction (handoff 121)

Ruling (Pat, 2026-10-29T18:48:40-0400, widget): "Can Codex draw new photo images that clearly show each subject (the people, the bore, the damage) in the game's current art style, without changing how exposure or photo grades work? This touches art direction, which is your call." = "Yes (Recommended)".
Compositions are AI-DESIGNED placeholders Pat can replace.

# Rulings copied from codex/handoffs (29 October to 1 November 2026)

Copied unchanged on 2026-11-12 from `docs/state/RULINGS.md` on `codex/handoffs` at commit `99e52d2d93c5d7a3ae879f336aca9b9832e170a4`, so that every ruling lives beside the game. Everything between the two rules below is that file, byte for byte, including its own headings and its draft intent card, which is UNRATIFIED until Pat answers the open question about it. [Framing sentence AI-written.]

---

# RULINGS (Pat's words only, verbatim and dated; append-only)

Workflow v2 single source for rulings. Newest at the bottom of section 2. Rulings before 29 Oct 2026 remain in docs/USER_DIRECTIVES.md on claude/integration (verbatim, dated) until migration step 10 copies them here.

## 1. Intent card (DRAFT, UNRATIFIED until Pat answers question 3)

```
INTENT CARD (what the player does, what must stay hard)
1. The player pilots by hand: places legs while paused, changes depth, works what is in reach, recalls drones, chooses when to be loud.
2. There is no one-press travel in release play. Shortcuts exist only behind the dev state for tests.
3. Crashing is possible and costs hull. A light edge assist stops grinding; it never plans a path for you.
4. Noise and exposure draw the Sirens. Being seen or heard has a cost you can read on screen.
5. The bare fleet can finish required ops on ACCESSIBLE and STANDARD, but as a skill feat with worse results, not as the easy path.
6. Planning, drones, tools and fittings change outcomes on every preset. An op that plays the same either way is a defect.
7. The game tells the truth: every action says what it does, every grey action says why, every exit is named for what exists.
8. The board does not move under your finger. A tap does one predictable thing.
9. Photography and recovered evidence are the point of going down there; they must be worth seeing and interpreting.
10. Story is 1 to 2 line placeholders, no em dashes, until Pat writes it; branching matters, prose does not.
```

## 2. Rulings

- 2026-10-31 00:00 ET (chat) [workflow]: Q "Let Claude build game items directly when Codex is out or slower, one bounded session per item, two sessions alive at most, no fan-outs? I recommend yes." A "Yes to question 1, start the migration".
- 2026-10-31 15:06 ET (chat) [branches]: Q "Make main the only promotion target, tagged at each milestone, and freeze gauntlet/production (kept, never deleted)? I recommend yes." A "Yes and then ill reset and restart".
- 2026-11-01 ~16:25 ET (chat) [ownership]: Q "Should I hand the stable-board work (#239) to a Claude builder now instead of waiting for Codex until about 3 November? I recommend yes." A "#239 yes. There is no codex until nov3/4".
- 2026-11-01 ~16:30 ET (chat) [android]: unprompted. "If it would be easier to test on, you can build the apk. Just ve smart about the debug signing. We dont need release signing yet." Effect: APK builds allowed when they help testing; sign only with the tracked development key scripts/toolchain/signing/sirens-song-debug.keystore (certificate SHA256 32bcb228...dc3c), never a regenerated key; no release signing.

## 3. Rulings 29 to 30 Oct 2026 (copied unchanged from docs/codex/PAT_RULINGS_2026-10-29.md)


Claude asked each question in a multiple-choice widget with its recommendation listed first. Pat's selections, verbatim as chosen (question text, then answer):

1. "In Ironman mode, should a drone or module lost in a dive be gone for good?" = "Yes, Ironman only (Recommended)" (QUESTIONS_FOR_PAT 14)
2. "Add one more story fork in arc 5, so earlier play picks which later ops you get?" = "Yes, one fork (Recommended)" (2)
3. "Should sonar only show a rough Siren type until you see or photograph it? (Changes Siren sense display, your call.)" = "Yes (Recommended)" (9)
4. "Show each Siren's wariness level as a mark on the chart?" = "Later" (8, deferred)
5. "Should hunter and sentinel Sirens each get their own hearing, search and attention, so each type needs a different plan? (Siren senses, your call.)" = "Yes (Recommended)" (6)
6. "On ops with 2+ patrolling Sirens, should they radio each other with a visible charge-up you can interrupt? (Protected, your call.)" = "Yes, 2+ patrollers (Recommended)" (7)
7. "Should the thermal layer cover only one depth band, so picking a depth decides who can hear you? (Protected, your call.)" = "Yes (Recommended)" (10)
8. "Should expedition seeds also shuffle Siren start positions and patrol timing (never their senses)?" = "Yes (Recommended)" (12)
9. "Add a small set of custom economy values (repair cost, income, starting stock) behind an ADVANCED toggle?" = "Yes, small set (Recommended)" (15)
10. "Allow switching to an easier preset mid-campaign (not in Ironman), marked in the ledger?" = "Yes (Recommended)" (16)
11. "Add tactical aids such as auto-pause when a Siren first notices you, as an Accessible option off by default?" = "Yes (Recommended)" (11)
12. "Change the Sorley rescue reward from supplies to pilotage charts?" = "Yes, charts (Recommended)"
13. "Should the Sorley rescue count as one vote toward which ending you get?" = "No, keep it separate (Recommended)"
14. "On SURVIVAL, add extra pressure inside dives (for example a harsher oxygen or Hunt pace)?" = "Later, after audit (Recommended)"
15. "Give each hull and chassis a distinct silhouette so you can tell them apart at a glance? (Art, your call.)" = "Yes (Recommended)" (17)
16. "Give each Siren role its own sound, heard only once sonar has earned it?" = "Yes (Recommended)" (20)
17. "Add a little ambient sea life, in colours that never look like contacts and never on sonar? (Art, your call.)" = "Yes, limited (Recommended)" (19)
18. "Add a mirrored HUD option for one-handed play?" = "Yes (Recommended)" (21)
19. "Use a placeholder title art, icon and splash built from the Quietus silhouette until you supply art?" = "Yes, placeholder (Recommended)" (18, 22)
20. "The spec says 28 core ops but the game has 29. Keep 29?" = "Yes, keep 29 (Recommended)" (23)

Earlier the same morning (~08:10 ET): diver ascent "For now* Yes*" (handoff 102, done), then "Survivor depth change is fine."

Operating effect: items 3, 5, 6 and 7 are Pat-authorized changes to protected Siren senses and sensing presentation. Only the change named is authorized; silent sight 180 m, cruise sight 290 m, the lock warning and the beam stay as they are unless a handoff says otherwise. Every exact number in the handoffs is AI-DESIGNED for Pat to ratify. Each implementing PR copies its ruling line verbatim into docs/USER_DIRECTIVES.md on integration and marks the QUESTIONS_FOR_PAT item ruled.


## Efficiency rulings (Claude S7 widget, ~17:30 ET)
Context: Codex sessions have a 475k-token window; today about 1.84B input tokens: the 091 critic session 413M (365k context), the AI queue runner 98M (polling), fresh per-handoff sessions 35-55M each.
1. "Split each Codex task into short sessions (build, then test and PR, then merge) that hand off through notes?" = "Yes (Recommended)"
2. "Ask Codex root to checkpoint the whole-game critic and continue it in fresh sessions, region by region?" = "Yes (Recommended)"
3. "Replace the AI queue runner with a plain script, with Claude doing the PR checks?" = "Yes (Recommended)"

## Follow-up (Claude S7 chat, ~17:50 ET)
Claude proposed: lower reasoning for the measuring phase; compact test output; and asked "Should extra tools cost cargo in Career and Expedition too (today campaign only)? I recommend yes." Pat: "Yes to all, and then tell me clearly when you're ready to be cleared and reset with siren start".

## 2026-10-29T18:48:40-0400 (Claude S8, widget, after the 091 audit)

Q: "Can Codex draw new photo images that clearly show each subject (the people, the bore, the damage) in the game's current art style, without changing how exposure or photo grades work? This touches art direction, which is your call."
Pat: "Yes (Recommended)" (option text: "Fixes the audit's top finding. Same style and palette, same photo rules; the images become placeholders you can replace later.")

## 2026-10-29T20:35:53-0400 (Claude S8, widget)

Q: "Start the next gauntlet loop (Promotion 4, then a fresh blind critic) after the five audit fixes (116, 118-121) land, about 4 hours, rather than now?"
Pat: "After the fixes (Recommended)". Pat had said: "it seems like we're slowing down and getting close to being ready to launch the next gauntlet loop on the game".

## 2026-10-30T12:09:01-04:00 (Claude S10, chat)

Q: "Should Codex add an authored campaign ending plus more varied late-campaign evidence (F7/F8/F14), with story lines as 1-2 line AI-designed placeholders you can replace? I recommend yes."
Pat: "Yes". Queued as 125 (BOARD row 122). Ending conditions stay protected.

## 2026-10-30T12:53:27-04:00 (Claude S10, chat)

Pat asked for a real gauntlet stop: evaluate the whole game, find every weak point, one comprehensive plan, then fan out. Claude asked: "Should I freeze new building after 125 merges and ask root to run the remaining critic regions in parallel (late arcs with the ending, and side modes)? The full verdict would land today, then I'd write one complete improvement plan and run it across both lanes. I recommend yes."
Pat: "Yes, freeze and run the critic in parallel".

## 2026-10-30T12:57:49-04:00 (Claude S10, chat): gauntlet priorities

Pat: "The storyline is the least important besides how it affects branching paths. The main point of the gauntlet loop right now is gameplay, graphics, ux, ui, bugs, features. The whole point is that we have a complete game. We review it, figure out where it's lacking especially in comparison to other AAA releases, and then we plan out the upgrades, and then we execute."

## 2026-10-30T13:04:53-04:00 (Claude S10, chat): reference-judged plan and workflow gauntlet

Q: "Should I build the improvement plan this way: each piece judged blind against named reference games, keeping only changes that win? I recommend yes. You can swap any of those references for games you'd rather we match." (Pieces: chart and touch controls, HUD and UI, graphics, audio, Siren combat, mission variety, progression and fittings, side modes. Proposed references: Cold Waters, FTL, Into the Breach, Highfleet, Barotrauma, Mini Motorways.)
Pat: "Approved. At every major milestone you should stop and evaluate our progress, find areas where we can tighten up our workflow or improve, find our weakest areas, and essentially run a mini gauntlet loop against our own workflow".

## 2026-10-30T19:18:37-04:00 (Claude S11, chat): controls are autopilot; travel shortcuts test-only

Pat: "I honestly just don't like the controls. It basically means you can complete almost every mission while half of your maneuvering is just clicking a button and watching autopilot. That defeats the whole purpose of the entire waypoint mode and the pause planning selection stuff. There should be controls for depth, interacting with nearby interactable objects, movement controls and recover drones."
Q: "Should I drop the one-press travel shortcuts and make planned waypoints plus an in-reach job menu the way you move? I recommend yes, and stripping the route-target part out of 126 before it merges."
Pat: "They are fine for testing but they will absolutely have to be stripped for release play".
Applied: 126 merges with its shortcuts (testing); 127 RELEASE CONTROLS gates every one-press travel order behind dev state and adds in-reach jobs, depth pair, recall.

## 2026-10-30T19:21:49-04:00 (Claude S11, chat): movement risk and edge assist

Pat on D9 (straight legs instead of auto-path): "You should still be able to crash. But there should be moderate autopilot for edges and stuff so you're not just getting stuck grinding on things if you fuck up. I don't know figure it out it still got to be a game like there still has to be some challenge and risk to it."
Applied in 127: straight legs, rock legs allowed with warning, crash damage unchanged, edge slide/hold assist.

## 2026-10-31T21:27:54-04:00 (Claude S12, chat): minimum tests, fastest path

Pat: "From now on you should always and this needs to be hard locked either in your claude.md or any of the startup instructions etc wherever it's useful without being redundant, you should always be using the absolute minimum number of required tests and you should always be aiming to get them as quickly done as possible. This doesn't mean take shortcuts, this doesn't mean modify CI to pass on a red, this means taking the most efficient and shortest pass on every single task. We should be working at the speed of professional game Dev with compute, not tired intern half-assing the next task to say they did it"
Applied (D36): builders run locally only import, core, the suites their diff touches or adds, the canaries and check-suites; the full matrix runs once, in parallel, in CI (which lists every failure in one run since 136), never in local lanes. No suite already green on the same head is rerun. The PR goes ready as soon as phase A is done so CI runs while evidence and review happen. Never loosen, skip or delete a test, and never edit CI to pass on red.

---

# Rulings recorded by the overhaul run (November 2026)

## 2026-11-05: removal rule

[PAT, as written in Pat's working copy of `AGENTS.md`, read 2026-11-12] "**Removal rule (Pat, Nov 5 2026):** nothing is deleted. Move files to a scrap folder (`_scrap-YYYYMMDD/` at the repo root or `Documents\_to_delete\`). No `rm`, `git rm`, `git clean`, or delete-permission requests. Back up before overwriting."

## 2026-11-11: signing keys

[PAT, 2026-11-11, as recorded in `.fable/TARGET.md` section 5; summary, not a quotation] Any private or release key stays out of the repository and is gitignored; Pat provides it when and as needed. Debug packages use only the tracked development keystore.

## 2026-11-11 20:49: continue after the guard self-test failed

[PAT, chat, verbatim] "Just fix it snd go"

[AI note] Context: the overhaul run's command guard was not loaded because the session had started in another folder. The run continued with the guard rules applied by hand; the git-level hooks were verified.

## 2026-11-11 ~21:05: restart-proof run documents

[PAT, chat; summary, the verbatim message was not preserved] Pat asked for restart-proof documentation of the run: a write-ahead note, a resume guide written by one agent and checked by another, finished documents marked finished, and a staleness check after every task.

## 2026-11-11 21:16: save files are minor priority

[PAT, chat, verbatim] "Save files are minor priority because the game isnt even finished yet so saves absolutely will not be able to be carried forward if there is a major refactor or a change in the flow of the game."

[AI note on effect] Save, restore, profiles, export and import stay working on new saves (feature continuity). Carrying existing saves across a refactor is not required as long as incompatible saves are rejected cleanly. Save-file defects rank low.

## 2026-11-11 21:22: hooks tracked

[PAT, chat, verbatim] "I don't want the stop gate and session-start hooks in .claude/settings.local.json, which is on disk only (git-ignored), like the start command. I want it to work every session"

## 2026-11-12: overhaul run launch

[PAT, launch message, verbatim excerpts] "I want a real overhaul: consolidate, restructure and fix what you find, and make the game easier to expand. Every behavior change goes in the final report, small ones included." "Do not start P2 work or further polish."

## 2026-11-12: no deletions without Pat's permission

[PAT, chat, verbatim] "there should be absolutely no deletions ever for any reason without my permission. Anything that is to be deleted needs to go to a scrap folder and if you can't, left alone."

[PAT, same message, verbatim] "I don't know how to open the _fable clone as the project from my phone. If everything else is working just continue"

[AI note on effect] This restates the removal rule of 5 November 2026 and extends it to every kind of deletion (files, folders, branches, tags, caches, scratch output). Where a move to scrap is not possible, the item is left where it is.

## 2026-11-12: no leases or holds bind the overhaul run

[PAT, chat, verbatim] "also in case it wasn't clear before, there are no leases or holds on any files in the repo. That have any relevance to you. You are currently fully in charge because I don't want you to feel held back from touching anything for any reason. Obviously keep working in your isolated branch, but don't feel like anything is off limits. You are here to upgrade and keep the planning on track for this game."

[AI note on effect] No claim, lease or ownership note left by another agent restricts what the overhaul run may edit on its own branch. The run still works only under `fable/`, still deletes nothing (2026-11-12 ruling above), and still records game-rule, narrative and capability-removal questions as decisions for Pat.

[PAT, chat, verbatim, same day, restating the ruling above] "I'm explicitly telling you not to leave other agents leases or claims alone. There is no one currently active in this repo but you and me. Therefore please keep that in mind"

## 2026-11-12: subagent economy

[PAT, chat, verbatim] "Also when using sub agents make sure to use the weakest but most capable sub agent for each task and make sure you don't use too many of them. Trying to make usage still worth it."

## 2026-11-12: effort, tests and GitHub Actions

[PAT, chat, verbatim] "And if you hit any work that would require high effort or anything above medium let me know and I can make the change"

[PAT, chat, verbatim] "You should be focusing on development and efficiency and properly building up the game, not running endless tests for everything you do."

[PAT, chat, verbatim] "Don't waste my GitHub actions unless necessary.
You should be using the absolute bare minimum amount of tests always."

[AI note on effect] Consistent with the 2026-10-31 minimum-tests ruling. Applied in the overhaul run from this point: local checks limited to the suites a fix touches; one full-matrix run to verify the gate fix; one package build; the pull request is left as a draft because marking it ready starts another full run.

## 2026-11-12: hour-long checks, bare minimum testing, drones launch from Quietus

[PAT, chat, verbatim] "We should not be having hour long checks. You need to audit that. That's a problem."

[PAT, chat, verbatim] "Yes I want the literal absolute minimum amount of testing ever for anything ever. Unless we are doing a final or near final release apk, I do not want a massive tests taking up our time and usage. The literal absolute bare minimum test for every single process no exception. Also drones are torpedo launched from the quietus. There should be no issues of throwing starting in any place cuz they do not start on the map."

[AI note on effect] Testing: pull requests no longer run the four-shard matrix; they run core, the minimum selection (`select-suites.py --minimum`) and the canaries. The full matrix is a manual dispatch for a release or near-release package. Drones: this is a design ruling. On the base and in this run's build, both drones begin every dive already in the water at fixed offsets from Quietus; the ruling says they begin aboard and are launched from Quietus. Decision D-11 is answered by it (none of its three options applies). The change is not built yet.

## 2026-11-12: the drone launch was core design, and answers to the repair list

[PAT, chat, verbatim] "That was a core gameplay design even all the way back in the prototype"

[AI note] Confirmed against the sources: in `reference/original-prototype/sirens_song_prototype_v7.html` (lines 231 to 234) a drone does not exist until the player launches it, at the submarine's position, from a stock of four; the design bible (line 55) calls drones "limited, expendable, torpedo-launched units". The Godot game placed both drones in the water at the start of every dive, and `docs/V7_TO_GODOT_PARITY.md` never recorded the difference.

[PAT, chat, verbatim] "Plan out your repairs. Everything you've listed so far that I haven't interacted with. I will give a yes or no answer to everything unless it requires elaboration. Just give me a numbered list."

[PAT, chat, verbatim, in answer to the 23-item list below] "Yes to all your recs. Use yourself on high as needed and weaker bounded agents for smaller tasks."

[AI summary of the list Pat answered; the wording is the agent's, the recommendation in brackets is what Pat accepted]

1. Restore drone launch as in the prototype: drones start aboard Quietus, off the map; ordering one launches it from the submarine; a drone never launched counts as recovered. [yes]
2. First version: launching makes no extra noise beyond the drone's normal movement. [yes]
3. First version: two drones, no spares. [yes]
4. First version: recovery unchanged (bring drones to the recovery point; no re-docking). [yes]
5. Audit the rest of the prototype against the game for other silently dropped mechanics and record every difference in the parity document. [yes]
6. Add a TITLE button to the Operations screen (D-12 A). [yes]
7. One new test package after items 1 to 6. [yes]
8. After the playtest: retune photo pay so a sharp close photo beats a safe distant one, numbers shown to Pat first (D-08 A). [yes]
9. After the playtest: 2x and 4x fast-forward that drops to normal when any Siren notices a craft (D-09). [yes]
10. After the playtest: one starter drone tool after operation 1 (D-09). [yes]
11. After the playtest: late-campaign alternates from existing optional operations now, new arc-opening operations later (D-10 D). [yes]
12. After the playtest: a Siren on the approach of every optional operation, and fleet-required side objectives (D-10 R). [yes]
13. Diagnostic lines stay silent in release builds (D-13 A). [yes]
14. Move HUMAN_TEST_READINESS and AUTHORED_ENDING_125 to scrap; keep the Siren AI roadmap and the 1 November overview (D-02 A). [yes]
15. Dated correction notes under three stale lines of the story draft, quoting Pat's rulings, the draft's text unchanged (D-03 B). [yes]
16. `codex/handoffs` is frozen history from now on (D-04 A). [yes]
17. Bounded runs and the open-ended Gauntlet loop both stay available (D-05 C). [yes]
18. The specification line that says "safe pathfinding" is changed to the 30 October movement ruling (D-06 A; Q4 and Q5 stay open). [yes]
19. The guard files stay in the pull request (D-07 A). [yes]
20. Create archive tags for the 326 old branches (D-14 A). [yes]
21. Remove the archived branch names afterwards. [not yet]
22. Mark the pull request ready once items 1 to 7 are in (D-15, changed by the minimum-testing workflow). [yes]
23. Do not trim the 41 slow suites; they run only for a release build now. [yes]

## 2026-11-12: parity review before the playtest

[PAT, chat, verbatim] "We need to check the parity audit before I play anything I don't want any rude surprises and a game that was not my design unless it's something that was approved. That doesn't mean that everything is automatically garbage it just means I need to know what's going on before I waste time playing"

[AI note] The agent then listed sixteen numbered differences between the v7 prototype and the game (1 to 9: built by earlier agents and recorded, no ruling from Pat found; 10 to 16: never recorded). The numbers in Pat's answer refer to that list: 5 sonar echoes, sectors and pulse cost; 7 tool numbers (Disrupt, decoy, survey); 9 most maps fully charted from the start; 10 objectives shown from the start; 11 Disrupt spends its charge with no Siren in range; 12 the survey is loud; 13 drones attract Sirens by movement noise; 14 factory proximity no longer raises suspicion; 15 a Siren's sight range is not drawn; 16 smaller numbers (extraction distance and speed, top speed).

[PAT, chat, verbatim]
"5. Is that realistic?
7. What is disrupt? Is that emp?
9. That's a complete fail. It's acceptable in maybe the first one to three missions as a tutorial in known waters, but the whole point is it's a recon and survey mission. You have to discover through exploration, sonar, photographs, recon sweeps but are temporary until you map them.

10. Was probably a good choice for testing and should be left as a debug option but not primary for gameplay release.

11. Yeah that's a failure

12. That doesn't really make sense because it's supposed to be a recon plane in universe, we can discuss that.

13. That's fine they should be stealthier than the sub but still able to fuck up and die

14. Huge failure. It's an alien factory with sensors and protection. It should know you're there.

15 explain? You mean like visibly on screen?

16. I'll have to try that for testing."

[AI note on effect] Rulings to build: 9 (charts are discovered; fully charted water only in the first one to three operations; survey sweeps are temporary until a craft maps the water), 10 (objectives shown from the start only as a debug option), 11 (Disrupt must not spend its charge with nothing in range), 14 (the factory senses a craft near it). Open with Pat: 12 (how a recon-plane survey should register with Sirens), 13 (drones are not in fact stealthier than the submarine today; whether to make them so), 15 (whether to draw a detected Siren's sight range). 16 and items 1 to 8 stay as built for the playtest.

## 2026-11-12: sonar cost, the EMP name, drone stealth, sight range, survey

[AI note] The numbers again refer to the sixteen-item list of prototype differences: 5 sonar, 7 tool numbers and the Disrupt tool, 13 drones and Siren attention, 15 drawing a Siren's sight range, 12 the survey.

[PAT, chat, verbatim]
"5. I don't think it should cost oxygen. It's your primary maneuverability and recon ability. It's kind of important. It shouldn't be limited like that. The biggest risk is getting caught. On the drones it costing battery makes sense.

7. It should just say EMP and it's an area of affected package shouldn't required you to Target anything. It should work on any sirens in the range. Knockdown torpedos are the single target. We can spec out more interactive and defensive tools later. Like a scrambled jammer that makes sirens confused or something like that.

13. Give me some options and evaluate how it affects gameplay.

15. It needa a way to be diegetic and make sense.

12. Not sure."

[AI note on effect] Built in WP-16: Quietus's sonar pulse costs no life support on a player dive (a drone's still costs battery); the tool is named EMP in everything the player reads (internal identifiers such as the noise label DISRUPTION and the loadout id `disruption` are unchanged). The EMP was already an area pulse that needs no target; the only refusal is when no Siren at all is inside its radius. Options given to Pat and awaiting his choice: drone stealth (A harder to see, B quieter, C slower lock, D calm Sirens ignore drones as in the prototype; recommended D with B) and a diegetic sight range (A earned by photographing the Siren type, B an estimate that sharpens, C shown only when a Siren looks toward a craft; recommended A). The survey question stays open. Pat's idea for later: more interactive and defensive tools, for example a jammer that confuses Sirens.

## 2026-11-12: drone stealth and Siren sight range chosen

[AI note] The agent had recommended, for drone stealth, option D with B (calm Sirens ignore drones, as in the prototype; drones about 40 percent quieter) and, for a diegetic Siren sight range, option A (drawn once that Siren type has been photographed).

[PAT, chat, verbatim] "Approved your recommendations.
15. A is fine for now even though it doesn't make a ton of sense we can figure out a way to explain it later."

[AI note on effect] Built in WP-16 (`game/src/simulation/parity_rules/drone_stealth.gd`, `sight_range.gd`). The in-world explanation of the sight range is Pat's to supply later. The survey question (item 12) stays open.

## 2026-11-12: loadout rename, code base audit, pause and resume

[PAT, chat, verbatim] "Yes I wanted disruption renamed to emp, the rest I will give feedback after play testing. In the meantime I want you to avoid it the code base and see if it could be made more efficient because it sounds like a tangled mess."

[AI note] "avoid it" is read as "audit". The loadout rename and the audit are phase 8 of the overhaul run (`.fable/PHASE8.md`).

[PAT, chat, verbatim] "I stopped you because you were spending your gears for like 20 minutes with no response so what I'm going to ask you to do instead is make sure that you are ready to pause I don't want to clear and restart because our context is very full. Make sure that the siren start Fable command is properly scoped for the current work including the code base audit I just asked for please. Remember the delegation rules and to always use limited badges of the most capable but cheapest possible agents per task except where your specific intelligence is needed. Orchestrate, update still drafts and documents, and keep working. After the resume."

[PAT, chat, verbatim] "Continue and prepare for clear a d resume"

[AI note on effect] The start command `.claude/commands/siren-s-start-fable.md` was rewritten on this instruction to resume into phase 8 with Pat's standing rules (minimum tests, no unnecessary Actions runs, cheapest capable agents in small batches, plain English, a short update every few minutes). The run is paused for a context clear.


## 2026-11-12: code base audit fixes approved; build a professional code base

[AI note] The agent had listed twelve fixes, A1 to A12, in `.fable/CODE_AUDIT.md` section 3 with a recommendation for each: yes to A1 to A8 and A10 (A7 after A5; A8 after A5 and A6, in small steps; A10's change only if a hitch is measured), A9 later, no to A11 and A12.

[PAT, chat, verbatim] "Yes to all of your recs. We should be building this as a professional video game code base, not a scrapped together prototype anymore. There's enough of a base here that it's worth expanding on and building this game but it needs a foundation that's not going to break every time we change a variable or a name"

[AI note on effect] Fixes A1 to A8 and A10 are approved and are built one work package each (WP-19 onward), starting with A4 (the opening-operation sensing stutter), A3 and A2. A9 waits. A11 and A12 are not done. The standard for new and reworked code from here on is the one Pat states: names and numbers defined once, and changes that do not break distant files.

## 2026-11-12: check the audit work in full, then a UI and UX audit and repair

Pat, verbatim: "Once you're done and your work is checked for not just accuracy, but also necessarity, functionality, complexity, scalability, interoperability, stability, bend overall code-based health; I want to perform another comprehensive audit and repair of the UI and ux, please and thank you"

How it is applied (Claude's reading, not Pat's words): when the approved code audit fixes are built, the whole set is reviewed once by a fresh reviewer against each of those headings (is it correct, was it needed, does it work, is it simpler or more complex than before, will it scale, does it fit with the rest, is it stable, is the code base healthier). Findings are fixed. Then a full UI and UX audit starts: a plain-English list with yes/no recommendations first, repairs after Pat's answers, as with the code audit.

## 2026-11-12: cut the test suites down

Pat asked, verbatim: "Genuinely do we need 856 tests?" Claude answered no: the core suite earns its keep, the roughly 390 suites around it mostly do not, and recommended preparing a keep list (core, save and resume, one journey per mission arc, one suite per screen layout; probably 60 to 90 suites) with the rest moved to the scrap folder, after the UI audit. Pat, verbatim: "Yes"

How it is applied (Claude's reading): after the UI and UX audit list is delivered, prepare the list of suites to keep and to retire, with the reason for each group, for Pat's approval. Nothing is moved before he approves the list. Retired suites go to the scrap folder, never deleted.

## 2026-11-12: GitHub Actions allowance is spent; test locally

Pat sent his GitHub metered usage page (Actions compute $12.00 used of $12.00 included, storage 0.5 GB of 0.5 GB, resets in 18 days; Siren-s-Song $55.84 of $68.99 gross this month) and said, verbatim: "This is why we need to trim the tests and why we need to test local right now. I'm literally out"

How it is applied (Claude's reading): no GitHub Actions run is started by this run until Pat says otherwise: no manual dispatch, and every push carries `[skip ci]` in its head commit message so the pull request checks do not start. All testing is local. Cause found: every push to the pull request branch started a pull request check (49 on 12 November), on top of 6 manual full passes; the frequent state commits were the main drain. The test-suite trim moves ahead of the UI repairs.
