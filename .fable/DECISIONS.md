# Decisions for Pat: overhaul-20261111

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
