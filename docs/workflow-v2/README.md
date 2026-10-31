# Workflow v2: a redesign of how Siren's Song gets made

Status: **DRAFT, not live.** Written 2026-10-30 by Claude (Fable 5.1) on branch `claude/workflow-v2` off `codex/handoffs`. Nothing here changes the game, the queue or any live rule until Pat approves and MIGRATION.md runs. Pat reviews first.

## Six lines for Pat

1. Biggest change: one intent card says how the game is meant to be played, and every gate, critic and nightly metric is measured against it instead of against the game's own menus.
2. What it fixes: autopilot passing every check, 47-minute CI rounds on every push, status spread over six drifting files, and all building stopping when Codex runs out.
3. What it costs: a few days of agent time to migrate (no Pat time beyond five yes/no answers), a one-time CI workflow PR, and Claude builder sessions when Codex is out.
4. What stays: Codex as the default builder, your intent check on every PR, the phase machine, the reference ratchet, the protected rules and nevers, the lean-git rule.
5. Branch: `claude/workflow-v2`, folder `docs/workflow-v2/`.
6. First question: let Claude build game items directly when Codex is out or slower, one bounded session per item, two at most, no fan-outs? I recommend yes.

## Reading order (phone-sized first)

| File | What it is | Length |
|---|---|---|
| QUESTIONS_FOR_PAT.md | five yes/no lines, recommendation first | short |
| DIAGNOSIS.md | eight root causes with evidence and cost; what the brief missed | one page |
| PROCESS.md | the complete target process: roles and models, items, branches, testing, evidence, evaluation, state, Pat's interface, failure handling | the long one |
| MIGRATION.md | 14 ordered steps, each marked Pat or Agent, each with a revert | one page |
| DECISIONS.md | D11 to D22, the calls made here that Pat can revert | short |
| AGENTS.md | the replacement root operating file (draft) | one page |
| STATE_TEMPLATE.md | the single restart file, with tonight filled in | short |
| ITEM_TEMPLATE.md | the 40-line work item, with 127 and a text item as examples | short |
| QUEUE_RUNNER.md | runner2.py design, queue.json, provider table, phase C as a script, diff against auto.py | medium |
| CI_CHANGES.md | draft-skip, affected selection, merge-candidate full matrix, duration shards, nightly | medium |
| RULING_TESTS.md | R1 to R5: the tests that encode Pat's rulings, including hand-pilot finishability | medium |
| CRITIC_HARNESS.md | kit v4 fix and the evaluation contract (intent card, DECIDED/WATCHED/LOST, coverage, blind reference pairs) | medium |
| RULINGS_SEED.md | the format of the rulings file and the 10-line intent card draft Pat is asked to ratify | short |
| REVIEW_CHECKLIST.md | the 10-line reviewer checklist and the 5-line intent check | short |
| DIGEST_TEMPLATE.md | the 12-line daily digest and the milestone card | short |
| areas.example.json | ownership areas and serial zones the runner enforces | short |

## What was verified before writing

Live branches (`main`, `gauntlet/production`, `claude/integration`, `codex/handoffs`), the queue folder (`auto.py`, `runner.py`, `runner-state.json`, notes, logs), the critic kits and verdicts for audit 123, the evidence base, the Astra report, Cold Reviews 4 and 5, PR 238 with its comments and CI runs, the last 60 CI runs, all 238 PRs' metadata, `gauntlet-pr-checks.yml`, `test.sh`, the finishability harnesses, the route order and pathfinder, the spec, Claude's memory files, and the repo's visibility (public) and tooling (Codex CLI 0.164, Claude Code 2.1.310, Godot 4.6.3 win64, WSL Ubuntu). Numbers in DIAGNOSIS.md come from those sources; where a figure is rough it says so.
