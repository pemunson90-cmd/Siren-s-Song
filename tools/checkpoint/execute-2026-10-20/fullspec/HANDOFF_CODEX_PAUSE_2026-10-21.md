# Siren's Song · User handoff to Codex: audit, rulings, pause, orchestration switch

**From:** Pat (user), with Claude's independent audit
**Date:** 21 October 2026
**Audit source:** `gauntlet/production` at `3578c06` (PR #48 merge). Production may have moved since; reconcile against the live tip.

This is a direct user instruction. It outranks `AGENTS.md`, `docs/USER_DIRECTIVES.md` and every governing doc where they conflict. The user is exercising the right those documents reserve to him: pausing the Gauntlet and changing who orchestrates.

---

## Part 1 · What Codex does now

### 1.1 Report what is in flight
Before anything else, write down what you are working on right now: task, branch, owner, how far along, and whether it is mergeable. The user has not been able to see this while you ran autonomously.

### 1.2 Pause at a clean point
- Finish **only** the task currently in progress. Do not start a new task, cycle or worker.
- If it can reach green CI and its normal review quickly, merge it to `gauntlet/production`. If not, push it to its branch as-is and leave it unmerged.
- Never leave production broken. If the in-flight work would break it, park it on its branch instead.
- Do not dispatch follow-on work. Task completion does **not** trigger the next cycle this time.

### 1.3 Write the pause checkpoint
Create `docs/PAUSE_CHECKPOINT_2026-10-21.md` on production (one commit, docs only) with:
1. Live production SHA after your last merge.
2. Every branch with unmerged work you care about: name, SHA, what it contains, mergeable or not, and whether it should be kept, merged later or abandoned.
3. Known regressions or open bugs on production, if any.
4. Anything half-built that the next orchestrator must not trip over (save schema changes, partially wired systems, renamed identifiers).
5. The exact command or first step to resume your last task, if it was parked.

Also add the rulings in Part 2 to `docs/USER_DIRECTIVES.md` as a short dated entry at the top, so every future worker inherits them.

Then stop. Mark the checkpoint **PAUSED: ORCHESTRATION HANDED TO CLAUDE**.

---

## Part 2 · User rulings

### 2.1 Story: the Siren-evacuation / human-fleet arc is rejected
The current late-campaign framing (Sirens as evacuees, "Siren carriers", "unarmed hulls", "shelter families", a human surface fleet as the threat, Quietus protecting Sirens from humans) is **AI fabrication, not ratified design.** It will be stripped.

- **Replacement premise:** the people being rescued are **human survivors from both deep-sea drilling operations (oil rigs) and military installations.** Across multiple rescue missions, both kinds of site appear.
- **Why they need rescue:** the Sirens react to potential threats. Deep-sea drilling and military operations read to them as threats, so those sites are where the Sirens strike. The humans are fleeing the Sirens' response, not a human fleet.
- **This sharpens Quietus's role:** the player must reach people at sites the Sirens already judge hostile while still looking like something the Sirens need not care about. Rescue work (drilling noise, military hardware, evacuating craft) is exactly the kind of activity that draws attention, which is the tension the missions should be built on.
- **The Sirens stay as ratified:** superior aliens who kill anything they judge a threat. The player researches them and survives by not registering as one. Player tools protect but never permanently disable a Siren.
- **Do not author new narrative text.** The rewrite is executed under Claude's orchestration, with the user approving specifics (characters, site sequence, ending conditions).

### 2.2 Cleanup: not now
Leave the branch count and governing docs as they are. The fix is in how workers are briefed (2.3), not in a cleanup pass.

### 2.3 Worker scoping rule (permanent)
Sub-agents and workers get **tightly bounded roles.** Each one reads:
- its task brief,
- the short guidance documentation it is pointed to,
- only the source files directly relevant to its task.

No worker reads the whole codebase or the full governing doc set to "orient." If a worker needs more context, the brief was wrong; fix the brief.

---

## Part 3 · Audit summary (Claude, read-only, 20 October)

**Method:** read guidance and source; ran official Godot 4.6.3 headless import, `run_tests.gd`, `runtime_tests`, `opening_depth_journeys`, `depth_policy_journeys`, `warning_recipient_journey_tests`, `concealed_harbour_journey_tests`; rendered menu, briefing and Shelf Signal frames with `capture_density.gd`. No human, touch or device play. Journey numbers are source-known scripted runs.

**Technical health is good.** 0 import errors. Core 742/0, runtime 633/0, opening journeys 48/0, depth policy 31/0, recipient 59/0, concealed harbour 43/0. No crash or softlock findings.

### Spec versus source

| Area | Approved | In source |
|---|---|---|
| Operations | 28 core + 12 optional | 14 (ids 0 to 13); 11 per playthrough |
| Branching | Star Fox style | 2 binary forks feeding 4 text endings |
| Hulls / drone chassis | 3 / 4 | 1 / 1 |
| Modules | 24 | 6, one slot per craft |
| Enemy roles | 8 | 4 (patroller, sentinel, hunter, sweeper) |
| Depth bands | 3 | done |
| Artifacts + research | 8 | none |
| Modes | campaign, challenges, roguelite, career | campaign only |
| Economy / presets | recoverable costs, Accessible / Survival / Ironman | none; 3-way loadout cycle |
| Settings | full accessibility set | music, effects, mute |

### Ranked findings
1. **Campaign is short and narrowly branched.** 11 operations per run, operations finish in 34 s to 4 min in scripted runs. Branches come only from two physical-exit choices.
2. **Progression is fixed rewards, not a system.** `craft_upgrades.gd` awards items for finishing specific operations. No mounts, budgets, economy, research or artifacts. Nothing to plan between dives.
3. **Pressure is low; finite tools look optional.** Torpedoes went unused in every logged journey; most runs ended at 100% hull. Lost-contact search is a fixed 8-point ring at 80 m (`_station_intent`). Four enemy roles missing.
4. **Presentation is placeholder grade.** 2 craft sprites, 1 material, 1 structure, Godot fallback font, about 15 synthesized sine/noise audio cues, no score.
5. **Player-facing text reads like the spec.** Briefs run to about 490 characters of thresholds. About 30 strings drop the space before numbers (`within60m`, `below2m/s`, `by45%`, `at112m/s`).
6. **Story pivot.** Resolved by ruling 2.1.
7. **Bespoke-per-operation architecture will not scale to 40 operations.** Each late operation added its own sim module, view and 3 to 5 test suites; `simulation.gd` is 1442 lines; test source (12.6k lines) exceeds game source (10.0k).
8. **Process overhead.** 683 commits in three days, 126 branches, about 14k words of governing docs. "Expedition" means the post-tutorial arc in code and roguelite mode in the spec. Handled by ruling 2.3 for now.
9. **Modes, frontend, settings absent.** Later in the approved delivery order.

---

## Part 4 · After the pause: new orchestration

### 4.1 Roles
- **Claude is root orchestrator,** running in a Claude Code session with sub-agents. Claude assigns lanes, writes bounded briefs, integrates, and decides what Codex works on.
- **Codex works as assigned by Claude:** independent reviewer, fresh-context critic, or owner of specific lanes that do not overlap Claude's files.
- **The user approves promotion** of integrated work back to `gauntlet/production`.

### 4.2 Branch model
- `gauntlet/production` is **frozen** at the pause checkpoint SHA. No direct pushes from anyone during this period.
- Claude creates `claude/integration` from the checkpoint SHA. Every lane, Claude's or Codex's, branches from it and returns to it by PR.
- Each lane has a published file-ownership list. Nobody edits files outside their list without the orchestrator reassigning them.
- Promotion `claude/integration` to `gauntlet/production` happens at coherent milestones, by PR, with the user's go-ahead.

### 4.3 Initial lane plan (orchestrator may adjust)

| Lane | Owner | Scope | Primary files |
|---|---|---|---|
| L1 · Enemy roles | Claude sub-agent | listening buoy, communications relay, interceptor, area-denial warden; terrain/arrival-aware search replacing the 8-point ring | new `simulation/roles/*.gd`; one dispatch hook in `simulation.gd::_threats` |
| L2 · Progression foundation | Claude sub-agent | typed mounts, power/noise/endurance/cargo budgets, recoverable resource economy, artifact and research data; re-home the existing 6 items | `equipment/*`, new `campaign/economy.gd`, fitting UI, save schema |
| L3 · Narrative strip and rewrite | Claude, with the user | remove the rejected Siren-evacuation framing; rewrite to the ruled premise (survivors from oil rigs and military installations the Sirens struck as threats); writing pass on briefs and HUD; fix number spacing | endings, briefs, campaign and HUD strings |
| L4 · Encounter primitives | Claude, after L1 lands | extract carry / escort / deliver / operate plant / tow / listen into reusable primitives so new operations are mostly data | late-op sim modules, `operation_catalog.gd` |
| C1 · Independent review | Codex | one fresh-context review per lane PR into `claude/integration` | read-only |
| C2 · Audio | Codex | replace synthesized cues with a real soundscape and tension layer | `audio/*`, new audio assets |
| C3 · Pressure probes | Codex | cautious, aggressive, drone-heavy and Quietus-only scripted policies measuring hull, tools used and time per operation, as tuning evidence for L1 | new test files only |

L3 can start immediately: stripping the rejected framing, the number-spacing fix, and drafting the new arc. Specifics (named survivors, which sites appear in which arc, ending conditions) go to the user for approval before they land.

The premise also feeds other lanes. L1: drilling and military sites are natural homes for the listening buoy, relay and area-denial warden, since the Sirens would be watching ground they already judged hostile. L4: "evacuate survivors from a struck site" is a reusable encounter primitive (carry or escort a vulnerable craft out of watched water), and the existing witness-pod and recipient-hull systems are the starting point for it.

### 4.4 Rules that carry over
- Godot 4.6.3 / GDScript / Compatibility. Unlimited tactical pause, fair information, finite tools, physical movement.
- Never merge known-broken game or save behavior. Green CI before every merge.
- No automatic APKs.
- Preserve original v7 and existing branches.
- More game than ceremony: each cycle should add more playable content than test and doc lines combined.

---

## Checklist for Codex
- [ ] Report current in-flight work (1.1)
- [ ] Finish or park it; no new tasks (1.2)
- [ ] Write `docs/PAUSE_CHECKPOINT_2026-10-21.md` (1.3)
- [ ] Add rulings 2.1 to 2.3 to the top of `docs/USER_DIRECTIVES.md`
- [ ] Stop, marked **PAUSED: ORCHESTRATION HANDED TO CLAUDE**
