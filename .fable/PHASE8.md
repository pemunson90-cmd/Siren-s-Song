# Phase 8: code base audit and Pat's follow-up work

Status: LIVE PLAN (written 2026-11-12 at Pat's request, before a context clear; root updates it as items finish)

Pat, 2026-11-12 (chat, verbatim): "Yes I wanted disruption renamed to emp, the rest I will give feedback after play testing. In the meantime I want you to avoid it the code base and see if it could be made more efficient because it sounds like a tangled mess." ("avoid it" is read as "audit". My reading; confirm if a reply suggests otherwise.)

Pat, 2026-11-12 (chat, verbatim): "make sure that you are ready to pause I don't want to clear and restart because our context is very full. Make sure that the siren start Fable command is properly scoped for the current work including the code base audit I just asked for please. Remember the delegation rules and to always use limited badges of the most capable but cheapest possible agents per task except where your specific intelligence is needed. Orchestrate, update still drafts and documents, and keep working. After the resume."

## Where things stand

- Branch `fable/overhaul-20261111`, everything pushed. Pull request 262 is a draft; its body is `.fable/FINAL_REPORT.md`.
- Debug package for Pat's playtest: workflow run 43265277067 (head `955ac8a1`), SHA-256 `ba20421a...5286f`. It holds every repair and parity restore of 2026-11-12.
- Waiting on Pat after his playtest: survey-plane behavior, which other Siren works sense craft, spare drones, feedback on everything else. Approved for after the playtest: photo pay retune (numbers shown first), fast-forward and a starter drone tool, late-campaign alternates and Siren pressure on optional operations.

## Work, in order

### 8.1 Rename the DISRUPTION loadout to EMP (small; root or one Sonnet implementer)

**DONE 2026-11-12** (`FieldTools.loadout_label`, eight display sites; three stale test files repaired; LOADOUT 40/0, TRUTHFUL COMMANDS 114/0, PLAYER NAMES 2834/0 and the other selected non-render suites pass). The original note follows. Display-only rename is the safe route: the loadout id `disruption` stays in code and saves; every place the player reads the loadout name shows EMP. Display sites found so far: `campaign/runs/run_records.gd` 71, `presentation/flow/campaign_flow.gd` 50 ("CYCLE LOADOUT · endurance / disruption / survey"), `presentation/frontend/challenges_frontend.gd` 38, `presentation/runs/expedition_session.gd` 76, `presentation/runs/seed_entry.gd` 45, `presentation/truthful_commands.gd` 26. Add one helper (for example `FieldTools.loadout_label(id)`) and use it at each site; search again for others (`grep -rn "to_upper()" game/src | grep -i loadout`, and `upgrade.to_upper`). Check: import plus the suites `select-suites.py --minimum` names. Record in CHANGELOG, parity rules comment, final report table.

### 8.2 Code base audit (delegated measurements, root synthesis)

Goal: tell Pat in plain English how tangled and how inefficient the code is, what that costs him (slower changes, more bugs, slower game), and a ranked list of fixes with size and risk, each answerable yes or no. No code changes in the audit itself.

Start from what exists: `.fable/SURVEY.md` (architecture map, defects, section 7 ranked weaknesses), the P2 backlog in `.fable/OVERHAUL_PLAN.md`, `.fable/CI_INVENTORY.md`, `docs/MODULES.md`.

Delegate in at most three bounded, read-only batches (Explore, or general-purpose on Haiku or Sonnet; each returns a table, no file writes; a subagent cannot write report files, so it returns text and root saves it):

1. **Size and shape.** Lines per file under `game/src` (top 30), functions over 80 lines, lines over 300 characters (the code uses very long one-line statements), files with the most `preload` links in and out, and the count of files that reach into `main.gd` or `simulation.gd`.
2. **Duplication and dead code.** Repeated literals and near-copies (tool stock lists, order lists, role names in 30 files, the 301 test files that each define `check`), switches in `docs/MODULES.md` that are permanently on, functions nothing calls, modules nothing preloads.
3. **Run-time cost.** Per-tick work in `Simulation._tick` and its callees (dictionary duplication every tick such as `Recon.state(m).duplicate(true)`, `units.find(u)` inside loops, full snapshots), per-frame work in `ocean_view.gd` and `mission_hud.gd` redraws and layout, and anything the performance suite (`performance_measurements`) already reports.

Root adds what only it knows from this run:

- **Two rule sets.** The drone bay and the parity rules apply to player dives through launch flags (`drones_aboard`, `parity_rules`), while most tests start the simulation without them and so test older behavior. That was the cheap way to restore Pat's rules without breaking hundreds of tests, and it is a real tangle: the tests no longer describe the game Pat plays. Recommend a plan to make the player rules the default and migrate or retire tests.
- **Tests that assert old wording or layouts** (DISRUPT strings, full charts, drones in the water): unknown number now failing in suites that were not rerun; 72 Main-driven test files touch drones.
- **Suite count and cost:** 391 suites, 46 minutes for the full matrix; 41 suites take 61 percent of it.
- **`main.gd` and `simulation.gd`** are the two files everything passes through (1,517 lines of dense simulation; Main holds input, save, lifecycle and menus).

**DONE 2026-11-12:** `.fable/CODE_AUDIT.md` is written (two read-only Sonnet agents plus root measurements); fixes A1 to A12 wait for Pat's yes or no. The original note follows.

Output: `.fable/CODE_AUDIT.md` (plain English first, then the tables), a short version in chat for Pat with a numbered yes or no list, and the items added to the plan below.

### 8.3 Build what Pat approves from the audit

One work package per approved item, smallest safe steps, each behind the existing review and minimum-test rules. Refactors must not change behavior; the protected-rules golden and the parity and drone bay suites are the guard.

### 8.4 After Pat's playtest

Apply his feedback and remaining answers; then the items approved for after the playtest. When he says his rulings are done: mark pull request 262 ready (one minimum check run), set status DONE.

## Rules for this phase

The standing rules in `.claude/commands/siren-s-start-fable.md`. In short: bare-minimum tests, no unnecessary Actions runs, cheapest capable agents in small batches, nothing deleted, plain English to Pat, a one-line update every few minutes.
