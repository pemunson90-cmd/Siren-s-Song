# Decisions for Pat: overhaul-20261111

Status: LIVE LOG (entries are appended; Pat answers by number and letter)

Each item keeps the current behavior in place until Pat rules. Answer by number and letter, for example "D-03 B, D-07 A". Items can be answered in any order and at any time; the run never waits on them.

<!-- Format (FABLE_RUN.md section 9.3):
## D-NN <short title>
Status: OPEN
Raised: <date>, phase <n>, WP-NN
What: <one or two sentences, plain>
Options: (A) ... (B) ... (C) ...
Recommendation: <letter> because <one sentence>
Current state kept: <what stays in place until Pat rules>
-->

## D-01 Run continues without the command-text guard
Status: OPEN
Raised: 2026-11-11, phase 0
What: This session started in the other clone, so the run clone's PreToolUse guard, post-command restore check and stop gate never loaded. The git-level hooks work and were tested. Pat said "Just fix it snd go"; a guarded session could not be started from Remote Control, so the run continues here with the guard rules applied by hand.
Options: (A) Keep going in this session. (B) Pat opens the run clone in the desktop app and runs `/siren-s-start-fable`; the run resumes there from RUN_STATE.json with all hooks loaded.
Recommendation: B when Pat is next at the desktop, because it restores the enforced layer at no cost to progress; A until then.
Current state kept: the run continues in this session; nothing outside `fable/` can be pushed and no ref can be removed (git-level hooks).

## D-02 Documents whose staleness is uncertain
Status: OPEN
Raised: 2026-11-11, phase 1
What: Four documents may be finished with, but nothing proves it, so they stay where they are: `docs/design/AUTHORED_ENDING_125.md` (ending placeholder copy table), `docs/design/STEALTH_AI_ROADMAP.md` (Siren AI roadmap, partly built), `docs/design/HUMAN_TEST_READINESS.md` (unratified gate before phone testing), `reports/2026-11-01-sirens-song-full-project-overview.md` (progress overview).
Options: (A) Move HUMAN_TEST_READINESS and AUTHORED_ENDING_125 to scrap; keep the roadmap and the report. (B) Keep all four. (C) Move all four to scrap.
Recommendation: A because the readiness gate was never ratified and your 1 Nov APK ruling overtook it, the ending copy lives in the game source, the roadmap still feeds the backlog, and the report reads as one you asked for.
Current state kept: all four stay in place, unedited.

## D-03 Contradictions in the story draft and the sweeper patrol note
Status: OPEN
Raised: 2026-11-11, phase 1
What: `docs/STORY_BIBLE_DRAFT.md` disagrees with your later rulings in three places (line 3 says the diver ascent rule is deferred, you ruled "For now* Yes*"; line 33 calls Calder Trench unbuilt, it is built; line 64 says the Sorley rescue rewards supplies, you ruled pilotage charts). Separately, the old board calls authored sweeper patrol points "against the PR70 invariant" while the game ships `campaign/sweeper_patrols.gd`. The run writes no narrative text, so the draft is untouched.
Options: (A) You correct the story draft yourself when you next write narrative; sweeper patrols stay as built. (B) The run adds a dated correction note under each of the three lines, quoting your rulings, without changing the draft's own text. (C) Remove authored sweeper patrols (changes a shipped behavior).
Recommendation: B because the corrections are your own words and stop a later agent from building on the stale lines; sweeper patrols stay as built either way.
Current state kept: the story draft is unedited; sweeper patrols behave as on the base.

## D-04 Retire the `codex/handoffs` coordination branch
Status: OPEN
Raised: 2026-11-11, phase 1
What: Status, queue and your recent rulings live on `codex/handoffs`, a different branch from the game. This run copies the rulings verbatim into `docs/USER_DIRECTIVES.md` and the status into `docs/STATUS.md` on the run branch. The branch itself is untouched.
Options: (A) After this PR merges, treat `codex/handoffs` as frozen history (kept, like `gauntlet/production`), and keep status and rulings beside the game from then on. (B) Keep using `codex/handoffs` as the live coordination branch.
Recommendation: A because two homes for status and rulings is what produced the pointer chains this run is removing.
Current state kept: `codex/handoffs` is unchanged and nothing on the run branch claims it is retired.

## D-05 Perpetual Gauntlet or bounded runs
Status: OPEN
Raised: 2026-11-11, phase 1
What: The governing files say the Gauntlet never ends unless you end it. This run is bounded by a charter with a stop point. The new `AGENTS.md` keeps the Gauntlet loop as the policy for Gauntlet runs and adds that a run with its own charter stops where its charter says.
Options: (A) Future work runs as bounded, chartered runs like this one, each ending in a PR you review. (B) Future work returns to the perpetual Gauntlet loop. (C) Both stay available and you choose per session.
Recommendation: C because the new wording already supports both and commits you to nothing.
Current state kept: both policies are written down; neither is removed.

## D-06 Open workflow questions this run does not answer
Status: OPEN
Raised: 2026-11-11, phase 1
What: Three of your open questions from `claude/workflow-v2` affect documents this run touches. Q3: amend the specification line that says "safe pathfinding" to your 30 Oct movement ruling (straight legs, crashing possible, light edge assist) and ratify the ten-line intent card. Q4: one daily digest. Q5: model cap for the orchestrator.
Options: (A) Yes to Q3 only (the specification then matches the game you ruled on; Q4 and Q5 wait). (B) Yes to all three. (C) Leave all three open.
Recommendation: A because the game already plays by your 30 Oct ruling while the specification still describes the autopilot you rejected, and critics judge against the specification.
Current state kept: specification line 73 is unchanged; the intent card is carried as a draft marked unratified.

## D-07 The run's guard files travel with the pull request
Status: OPEN
Raised: 2026-11-11, phase 1
What: The bootstrap committed `.claude/` (guard, hooks, agent files) and `.fable/` to the run branch, and on 2026-11-11 you asked for the stop gate, the session-start hook and the start command to be tracked too. When the final PR merges into `claude/integration`, every later Claude session in any clone of that branch inherits them: pushes allowed only under `fable/`, no deletions, and a stop gate that reads `.fable/RUN_STATE.json` (it lets a session stop once status is DONE).
Options: (A) Keep them in the PR as the standing safety layer for future runs; a future run only needs a new charter. (B) Before the PR is marked ready, move `.claude/` and `.fable/` run files to scrap on the run branch so the merge carries only the game and its documents. (C) Keep the hooks but have the run loosen the push rule to the normal branch model at closeout (needs your explicit go-ahead, because a run may not loosen its own guard).
Recommendation: A because the guard only restricts destructive commands and pushes outside `fable/`, which matches how you want agents to work, and option C can follow later if it gets in the way.
Current state kept: `.claude/` and `.fable/` stay tracked on the run branch.

## D-08 Photo pay: should quality outweigh distance and tools
Status: OPEN
Raised: 2026-11-12, phase 2, WP-10
What: Blind critics saw a photo grade and never saw what it paid; the 1 Nov plan already noted that pay favors distance and tools over photo quality. This run adds a line that shows what each photograph paid. Changing the pay numbers themselves is a game-rule tuning question.
Options: (A) After this run, retune the pay table so a sharper, better-framed photo pays clearly more than a distant safe one, with numbers shown to you first. (B) Keep the pay table as it is; showing the pay is enough. (C) Retune inside this run without showing numbers first.
Recommendation: A because the risk dial on the camera is the game's best idea and it needs a reward on the other side, while the numbers are yours to see before they land.
Current state kept: photo pricing, exposure and grading are unchanged; only the display of what was paid is added.

## D-09 Drone pace and something to buy early
Status: OPEN
Raised: 2026-11-12, phase 2
What: A new player's drones carry no tools, the only early purchase costs alloy the player does not have, and a drone leg of 900 to 1800 m is mostly waiting. Fixing this means design changes: a player-controlled time step while no Siren is aware, and an affordable first purchase or a starter drone tool.
Options: (A) Both: a 2x and 4x time step that drops to normal the moment any Siren notices a craft, and one starter drone tool after operation 1. (B) Time step only. (C) Starter tool only. (D) Neither for now.
Recommendation: A because the three-craft premise is not felt in the opening without it, and both are additions that remove nothing.
Current state kept: drone speed, tool stock and prices are unchanged.

## D-10 Route graph and late-operation variety
Status: OPEN
Raised: 2026-11-12, phase 4, WP-12
What: From operation 14 to 34 every player flies the same core operations; forks change approaches inside operations. `docs/proposals/2026-11-ROUTE_AND_VARIETY_OPTIONS.md` lays out options with costs. It contains no story text and nothing in it is built.
Options: Part 1 (which operations you get): (A) alternates built from existing optional operations, (B) exit forks with two new arc-opening operations, (C) same operations with different encounters, (D) A now, B later. Part 2 (difficulty cliff): (P) a Siren on the approach of every optional operation, (Q) fleet-required side objectives, (R) both.
Recommendation: D and R because A gives real branches from content that is already built and tested, and an optional operation standing in a core slot needs P anyway.
Current state kept: the route graph, operation order and all encounters are unchanged.

## D-11 Drones parked outside recovery reach, and a first leg that runs through a drone
Status: ANSWERED by Pat, 2026-11-12: "drones are torpedo launched from the quietus ... they do not start on the map." None of the options below applies; drones are to begin aboard Quietus and be launched from it. Not built yet.
Raised: 2026-11-12, phase 4, WP-11
What: Two critic findings turned out to be rules working as built. In 16 operations the launch point is also the recovery mouth and each drone starts 100 m from it, while recovery reach is 65 m, so a drone that never moved is truthfully listed OUTSIDE RECOVERY. And Drone A starts 100 m ahead of Quietus, so a first straight leg north strikes it (13 percent hull at 2.5 s); the leg warning names Drone A, but a new player still takes the hit. Nothing was changed.
Options: (A) Start drones inside recovery reach and astern of the first objective (changes start positions in those operations; needs the journey tests rerun). (B) Keep the positions, and count a drone that never left its start as recovered. (C) Leave both as they are.
Recommendation: A because it removes both surprises with one layout change and touches no rule.
Current state kept: start positions, recovery reach and the OUTSIDE RECOVERY label are unchanged.

## D-12 A way back to the title from the campaign Operations panel
Status: OPEN
Raised: 2026-11-12, phase 4, WP-11
What: On the near-square inner screen a critic found no BACK on the Operations panel, and Android back there starts the double-press exit. TITLE exists in the bottom row but was not seen. The package did not add a control, because a BACK that copies Android back would offer to exit the app.
Options: (A) Pin a TITLE control at the top of the Operations panel on both layouts. (B) Leave it as it is.
Recommendation: A because it is one visible control and changes no behavior of Android back.
Current state kept: the Operations panel and Android back are unchanged.

## D-13 Diagnostic lines are silent in release builds
Status: OPEN
Raised: 2026-11-12, phase 5, WP-06
What: Work package WP-06 made the internal `SS_` diagnostic lines and the Android UI metric records print only in debug builds. Debug packages (the kind you test, and the kind the emulator smoke reads) are unchanged. A release build no longer prints them, which reduces what a maintainer can read from a release build's log. This was merged before it was raised as a decision; restoring it is a one-line change in `game/src/presentation/release_controls.gd` (`debug_print`).
Options: (A) Keep them silent in release builds. (B) Print them in release builds again.
Recommendation: A because a store build should not write internal diagnostics to the device log, and every check that reads them uses a debug package.
Current state kept: silent in release builds, printed in debug builds (the merged state; say B and it is restored).

## D-14 Run the branch archive plan
Status: OPEN
Raised: 2026-11-12, phase 6
What: `.fable/BRANCH_ARCHIVE_PLAN.md` lists 326 old branches (265 already merged, 61 old and unmerged). Archiving means: a tag `archive/branch/<name>` is created at each branch tip and pushed, and only then may the branch ref be removed. Every commit stays reachable through its tag. The run changed no ref.
Options: (A) Add the tags only (`python scripts/repo/archive_branches.py --execute --approved-by-pat`). (B) Add the tags, then remove the archived branch refs (the same, then `--remove-branches --approved-by-pat`). (C) Not now.
Recommendation: A first, because tags cost nothing and make B safe whenever you want the branch list shortened.
Current state kept: all 373 remote branches exist; no archive tag was created.

## D-15 The pull request is left as a draft
Status: OPEN
Raised: 2026-11-12, phase 6
What: The charter says to mark pull request 262 ready at the end. Marking it ready starts another full check run on GitHub (about an hour of Actions time), and every later push to a ready pull request starts one more. You said not to spend Actions unless necessary, and the same code already passed the full matrix by manual dispatch. So the pull request is complete but still marked draft.
Options: (A) Leave it as a draft and merge when you have reviewed it (GitHub lets you mark it ready yourself in one tap; that tap starts the check run). (B) Tell the run to mark it ready now and accept one more full run.
Recommendation: A because the check would repeat a run that already passed on the same code.
Current state kept: pull request 262 is a draft, unmerged, with the final report as its body.

