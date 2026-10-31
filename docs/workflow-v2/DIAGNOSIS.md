# Diagnosis: why the Siren's Song process underdelivers

Written 2026-10-30 23:05 EDT by Claude (Fable 5.1), from the live branches, the queue folder, CI history and PR 238. Every claim below was checked against a file, a log or GitHub. Where I am unsure I say so.

## Symptoms (not causes)

Red CI rounds. 150-line PR bodies for string changes. Critic "game hangs". A queue that stalls on its own rules. Autopilot passing every gate for 2.5 days. Six status files that disagree. All building stopping when one provider runs out.

## Root causes, ranked by what they cost the player

**1. Nobody wrote down what the player is supposed to do with their hands, so every gate measured the wrong thing.**
The spec endorses the autopilot: `docs/CURRENT_GAME_SPEC.md:73` says "Preserve inertia, turning, safe pathfinding". The finishability harness drives craft with the `route` order, which compiles every leg through the pathfinder (`game/tests/glass_fleet_voyage.gd`, `route_program.gd:25`), the same code the HUD shortcuts call (`mission_hud.gd:208/214/244`). The critic brief never mentions controls. Critics therefore used "Route to reach work" as a normal action (G2 verdict, step 731) and praised the tactical core. "Fleet must matter" was measured as Hunt pressure under autopilot, so it passed.
Cost: from Pat's "waypoint simulator" worry on 28 Oct to his screenshot on 30 Oct, about 15 PRs (093 to 117), two blind audits (091 with 29 recoveries, 123 with 5 regions) and two promotions could not see the problem.

**2. The whole 2-hour test matrix runs on every push of every PR, while parallel lanes keep moving the base under each other.**
`.github/workflows/gauntlet-pr-checks.yml` runs core plus 4 runtime shards (20, 23, 37 and 44 minutes on green run 41093784501) on each push and cancels the run in progress. Of the last 60 runs, 18 were green, 13 red and 29 cancelled. PR 229 (item 118) needed 9 phase A relaunches; its notes show the base moving to ac8e7937 under it, a 480 s suite timeout, an engine error and assertions broken by other lanes' merges. PR 238 went red three times (12, 32, 47 minutes). The fix for that, "full suite before every push" (`runner.py:64`), contradicts `FRESH_SESSION_PROMPT.md` and `docs/TESTING.md` ("never the full list locally") and blocked items 126 and 127 at 22:25 tonight.
Cost: roughly 20 runner-hours of red or cancelled CI in two days, and two items frozen by a rule conflict.

**3. Rules and status live in many hand-edited files with no single owner, so they drift and contradict.**
HANDOFF, BOARD (107 KB, 156 rows), LEDGER (50 KB), USER_DIRECTIVES (44 KB), RESUME, CONTINUATION, WORKBENCH, DECISIONS, PAT_RULINGS, QUESTIONS_FOR_PAT, QUEUE_S6, PLAN_DRAFT_1, the notes files, runner-state.json and the phone tracker. 626 commits to `codex/handoffs` in 9 days; 74 of them are the runner's banner refresh. HANDOFF.md was edited 46 times since 26 Oct. CONTINUATION still says "Pat merges promotions" while Codex root merged Promotion 4.
Cost: every restart reads curated excerpts, workers obey stale lines (cause 2), and the orchestrator spends its session relaying state instead of ranking the player's problems.

**4. Evidence is demanded per PR, not per kind of change, so proof is produced to pass a gate rather than to inform a decision.**
PR 238 changed labels and route targets: 650 lines added across 20 files, a 151-line body with 94 table rows, 28 identical-before-and-after voyages, 24 screenshots and two relayed reviews. Nine PRs have bodies over 150 lines. Each phase B session costs 14 to 18 minutes of Codex before anyone reads the result.
Cost: identical tables carry no information for presentation changes, yet they are regenerated, reviewed and read on every revision.

**5. Building capacity is concentrated in one provider by rule, not by design.**
`HANDOFF.md`: "Until Codex returns, Claude work is read-only review, planning and docs." The rule came from two real failures: S2's 45-agent gap scout (about 6.2M subagent tokens) and S3's lanes dying at the CI stage. The lesson drawn was "no Claude subagents" rather than "no unbounded fan-outs". Codex meanwhile consumed about 1.84B input tokens on 29 Oct (one critic session 413M, the polling runner 98M, 35 to 55M per fresh item session) and is now out for about 4 days.
Cost: zero building for 4 days; and the one-day Codex burn would pay for weeks of bounded builder sessions on either provider. Token figures across providers are rough, not a like-for-like price.

**6. The critic harness and the critic contract were never tested as a product.**
All five "hangs" (G1-150, G2-797, T1-683, T2-028, C2-987) were the driver rejecting a command whose JSON failed to parse (`driver.gd:18` in the old kit) and the critic waiting forever, because `OPERATE.txt` told critics that a consumed command is not an acknowledgement but gave them no watchdog. No critic reached END OF LINE in five regional sessions. No critic judged audio. The 091 reference comparison used recognized publisher stills, not blind matched clips.
Cost: about 3 hours of critic play lost, a false P1 (C01) in the plan, the ending unplayed, and no reference verdict at all.

**7. Branch, worktree and artifact sprawl with no retirement policy.**
349 remote branches, 229 registered worktrees, 30 MB of Codex stderr in the queue folder, three long-lived integration lines (`claude/integration`, `gauntlet/production`, `main`). `main` has not moved since 19 Oct while production took four promotions. Critics played production while fixes landed on integration; the Astra assessment had to correct the baseline before it could rank anything.
Cost: ambiguity about which build is "the game", a 16-file guidance linter, and startup time.

**8. Every state transition in the queue needs the orchestrator's hands.**
A red check in phase C requires seven manual steps (HANDOFF "Red CI in phase C"): edit the BOARD row, append a note, edit runner-state.json fields, post a HOLD, re-post a PASS. Phase C itself is a 66-minute model session that mostly waits for CI (125c2). The Monitor expires every 30 minutes.
Cost: S11 spent most of its session on 126's three repairs. Orchestrator attention is the scarcest resource and it goes to plumbing.

## What I found that the brief did not list

- The "fix" that followed PR 238 (D10, full suite before every push) is itself the newest blocker: `runner.py:64` versus `FRESH_SESSION_PROMPT.md` and `docs/TESTING.md`. The rule-drift cause produced a new stall within hours.
- The 4 CI shards are balanced by suite count, not by time (`test.sh`: `[int(shard)-1::4]`), so the slowest shard sets the wall clock at 44 minutes when the mean is 31.
- WIP pushes every 30 minutes (a rule in `README.md` on codex/handoffs) trigger the full matrix and are the main source of the 29 cancelled runs.
- The spec amendment is Pat's call: his 30 Oct rulings on hand piloting contradict spec line 73, and nothing has amended the spec yet.
- Item 126's third repair is committed but unpushed in the Codex worktree (`3cde47e4`, `Siren-s-Song-codex-126`); it is recoverable without Codex.
