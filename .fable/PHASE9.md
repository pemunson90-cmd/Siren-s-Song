# Phase 9: UI and UX repair

Status: LIVE PLAN (rewritten 2026-11-13 16:40 for a pause: Pat's weekly usage on this model was about to run out and he may continue with another model). This file plus `.fable/RUN_STATE.json` and `.fable/NOW.md` is enough to continue. You do not need to reread the repository or the session transcript.

## What Pat asked for (verbatim, 12 and 13 November 2026)

- "I want to perform another comprehensive audit and repair of the UI and ux"
- On the audit's yes or no list: "Yes to all by your judgement. Youre here to fix the game. I can personalize it later"
- "actually look at how it looks compare it to professional Android games and similar top-down games and make some evaluations and judgment calls"
- On drones: "I prefer the idea that wants deployed they had to stay out. They are torpedo deployed deep sea drones, I don't really think a recovery Bay makes sense on an experimental stealth sub."
- On photographs after a lost dive: "On easy mode you keep them, everything higher you don't.."
- On GitHub: "This is why we need to trim the tests and why we need to test local right now. I'm literally out" and "do the rest of the work yourself because we don't have another choice"
- "Good job Keel, keep up the good work. Fable the fuck out of this game. Make codex jealous."
- On six rule questions from the critics (13 November): "Yes for testing"

So: every interface item is decided by Claude's judgement. Claude decides layout, plain wording and names, builds, and lists every changed text in `.fable/FINAL_REPORT.md` so Pat can personalize it later. Story, game rules and prototype mechanics stay Pat's: ask one yes or no line with a recommendation.

## How the work is done (the loop that has been working)

1. Root designs a package and writes a brief for ONE Sonnet `implementer` agent per package (`isolation: worktree`), at most three at once, on disjoint files named in the brief. Fixed parts of every brief: branch from `origin/fable/overhaul-20261111` (worktrees start at `main`; staged `.claude` files may block the checkout: unstage, never commit them), the files it owns and must not touch, no deletions, no amend, no stash, no push, no GitHub runs, a private `ARTIFACT_DIR`, the Edit or Write tool for anything with backslashes, the exact local test commands, "REPORT ONCE, then STOP".
2. **Before every Agent dispatch run a shell command that starts with `cd` into the run clone.** The session's working directory falls back to the other clone (`repos\Siren-s-Song`), and a helper dispatched then is created THERE (it happened once: see "Incident").
3. **Stop each helper with TaskStop as soon as its first report arrives.** Finished helpers re-send the same report many times and burn usage.
4. Root reads the diff (`git diff <base>...<branch> -- game/src`), judges it, merges with `git merge --no-ff --no-edit <branch>`, reverts a bad commit with `git revert --no-edit <sha>`. Merge one dive-HUD package at a time and rerun `radial_hud_tests` and `hud_words_ui_tests` after each: these packages interact.
5. Root runs the touched suites, Core when `game/src/simulation` or campaign rules changed, and after a batch of merges **every registered suite** (see "Full sweep"): the 39-suite everyday set does not cover the guard suites, and with GitHub off nothing else runs them. Root reported "green" twice on the everyday set alone while eight guard suites were failing.
6. **Root looks at it in the real game** (critic kit, cover screen; inner screen for menus) before calling it done, and says plainly what it has not seen.
7. Root sends Pat the captures (SendUserFile), adds a behavior row to `.fable/FINAL_REPORT.md` naming every changed text, a row in `docs/MODULES.md` for a new module, updates state with `python scripts/repo/run_state.py`, commits and pushes with `[skip ci]`.

### Commands

```
cd "C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\_fable\Siren-s-Song"     (every shell command starts here)
$env:ARTIFACT_DIR="$env:USERPROFILE\.cache\sirens-song-toolchain\artifacts\fable-root"
scripts\toolchain\win\headless.ps1 -Action Import -Isolate
scripts\toolchain\win\headless.ps1 -Action Core                                  (856 checks, about 100 s)
scripts\toolchain\win\headless.ps1 -Action Script -Script <suite> -Prefix "<words before CHECKS>"   (render-flagged suites)
scripts\toolchain\win\test-suite.ps1 -Suite a,b,c -SkipCore                      (it SKIPS render-flagged suites)
scripts\toolchain\win\test-suite.ps1 -All -Profile local                         (the everyday set, 39 suites, about 20 min)
python scripts/toolchain/select-suites.py --minimum --changed <paths>
```

Full sweep (every registered suite, about 85 minutes, run it in the background; do not edit game source in that worktree while it runs):

```
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\full-sweep.ps1 -Repo "<run clone>" -Out "<a result file>"
```

Its result file ends with "FAILURES FROM LOGS": the per-suite logs in `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-root\<suite>.log` are the record (each ends with "... CHECKS n FAILURES m" and lists its "FAIL ..." lines). `cold_review_archive_tests` (cannot start child processes here) and `art_render_measurements` (no summary) do not run on this PC: not findings.

Looking at the game (Windows, needs the GPU; opens a game window on Pat's PC):

```
K=%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-criticNN-<date>
python scripts/critic/kit.py new --ref HEAD --out K           (build from a commit; commit first)
python scripts/critic/kit.py launch --kit K --slot a --view cover --session root-look     (inner = 2184x1968)
python scripts/critic/kit.py send --kit K --slot a '<json>'   (click, hold, drag, wheel, wait, screenshot, labels, back, batch; scripts/critic/OPERATE.md)
python scripts/critic/kit.py quit --kit K --slot a            (always quit; wait 3 s before launching again)
```

Coordinates are native pixels (cover 2520x1080). A screenshot saved at scale 0.5 must be doubled. Menus do not scroll by finger `drag` on this PC (Godot scrolls by finger only where a touchscreen exists): use `wheel` (`{"command":"wheel","x":..,"y":..,"notches":9}`). Each kit session name and view has its own fresh profile; `labels` can list labels of a screen underneath: trust the screenshot. Path to a dive on a fresh profile, cover: START GAME (1260,290), CAMPAIGN (1260,283), NEXT OPERATION (1850,202), CONTINUE TO BRIEFING (1260,1002), ENTER WATER (664,960), Quietus on the chart (230,790), pause plate (83,60), FLEET (2436,60). Hub on cover: FITTINGS (1851,342).

## Done in phase 9 (all merged and pushed; behavior rows 57 to 85 in `.fable/FINAL_REPORT.md`)

Before the pause of 13 November 01:37 (rows 57 to 70): WP-31 to WP-39: plain defects, button roles, lost-dive photographs by preset, DEPLOY and RECALL on the wheel, pause and FLEET as buttons, the Campaign hub as cards, the contact card, plain wording and back labels.

Since the resume of 13 November (rows 71 to 85):

| Package | What | Row |
|---|---|---|
| WP-43 (root) | Route dialog: REPLACE ROUTE as the main button, a real switch | 71 |
| WP-42 (redrawn by root) | Title backdrop from the dive's rock through one shared painter (`art/rock_painter.gd`) | 72 |
| WP-40 | Career and Expedition briefings as GOAL, DANGER, rules; results in sentences | 73 |
| WP-41 | Fittings as cards, bars drawn to scale; B17 "signal spire"; seed and list wording | 74 |
| WP-44 | Tools on Fittings: carry sentences, quick fills, bars, one row per tool | 75 |
| WP-47 | Field Manual as topic cards (`field_manual_view.gd`, `field_manual_table.gd`); primer in the first briefing | 76 |
| WP-45 | A closing tap gives no order; EXTRACTION label and circle send the craft home | 77 |
| WP-46 | First-run menus: named NEXT OPERATION, chosen difficulty, region entry, Route Map header, REWARD wording, seed start, carried damage line | 78 |
| WP-49 | Threat line and wedge, direction in words, where the Siren was on the loss screen, one compass helper | 79 |
| WP-48, WP-50 | PAUSED or RUNNING plate, plain wheel words in `hud_words.gd`, route-end and pause-reason lines; wheel layout under a lock card | 80 |
| WP-51 | One statement of a lock, one tip card in a fixed place that takes its taps, no self-opening viewfinder, labels cleared around the Siren | 81 |
| WP-52 | A segment names its action; silent, profile and ALL STOP take two taps; segments keep their place; a red route needs a second tap | 82 |
| WP-53 | Fittings in two columns on a wide screen (`prep_columns.gd`, `layout_metrics.gd` `prep_wide`); what each tool does; reasons on greyed buttons; currency line | 83 |
| WP-54 | Six trial rules in `game/src/trial_rules.gd`, one auto-pause path `presentation/auto_pause.gd` | 84 |
| WP-55 | Eight guard suites repaired (two source defects, six stale suites) | 85 |

Two blind critic rounds on 13 November (kits `fable-critic26-20261113` and `fable-critic33-20261113`; journals and captures under `<kit>/audit/critic-a|b|c/` and `<kit>/evidence/critic-a|b|c/`). In the first, critic A lost operation 1 three times; in the second, critic A finished it.

## In flight at the pause

**No helper is running.** One background job was started by root at 16:18 on 13 November: the second full sweep, on merge commit 345dfe8e (head bef1876b differs only in `.fable` files). If the session ended before it finished, its logs are still valid up to where it got: read every `*.log` newer than 2026-11-13 16:18 in `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-root\` for its last "CHECKS n FAILURES m" line, and rerun the suites that have no newer log (or simply run the full sweep again).

The first sweep (on b352f808) found eight failing suites; WP-55 fixed all eight and they were rerun green with 18 neighbours. The second sweep is the proof for the whole registry and for WP-54 and WP-55 together: **until it is read, the head is not known to be clean.**

## Incident (13 November): the other clone was touched

The WP-55 helper was created in `repos\Siren-s-Song` (the clone that must not be touched) because the session's working directory had fallen back to it before the dispatch. That clone gained a worktree folder under its `.claude\worktrees\` and a local branch `wp-55`; its own files and checked-out branch are unchanged. Root fetched the branch from it read-only and removed nothing. Pat was told and has not asked for the leftovers to be moved. Guard: item 2 of the loop.

## Not yet seen by root in a capture

- The Siren warning after WP-51 (one card, tips parked, viewfinder closed). The capture Pat has (`fable-critic33-20261113/evidence/critic-a/018.png`) is from before WP-51.
- FITTINGS in two columns on the inner screen (seen on cover in kit 35).
- The fitting cards and scale bars of WP-41: a new campaign has none until operation 1 is recovered.
- Trial rules 2 to 6 in play (rule 1 seen in kit 36); the widened pause plate at large text.
- The Career board, the Expedition operation menu, the damaged-start briefing line, the "short by" lines on Supplies.

## Queue, in order

1. **Read the second full sweep** and fix every failure (see "In flight").
2. **Third blind critic round** on a new kit from the head: three Sonnet critics (`general-purpose`), briefs `scripts/critic/CRITIC_BRIEF.md` and `OPERATE.md`, 70 commands each, "send the report ONCE and stop". Ask for full-scale captures of everything under "Not yet seen", and for play with the trial pauses on: does pausing on every lock and at a route's end feel right or interrupt too much. Rank the findings here and build the top ones.
3. **Left from the second round's ranking:** a line after a photograph saying what a better frame would add (C G3, F11); the Route Map reads as a developer tool ("UNKNOWN / LOCKED", raw numbers, node 39); Naval Career says "separate resources" and shows the Campaign's balance, and does not say how standing is gained; SUPPLIES AND COSTS is still one column; long unattended legs; no FIT button in the dive; Hunt meter moves with no explanation, and its help text still says the lock is 4 s (`presentation/meter_table.gd`); the mode picker and the other front-end screens are plain black behind a narrow column on the inner screen.
4. **Loose ends from the packages:** "first dive" for trial rule 2 is recognised as the plain Campaign simulation running operation 01 (a mode flag would be sturdier); `onboarding_hints.gd` still sets `sim.paused` itself (outside the one auto-pause path); a route pending because of rock is not re-checked when the player presses ADD TO ROUTE; mission-context wheel extras still shift segment angles; Career's pending-save reason text; `tap_ownership_ui_tests`, `hud_words_ui_tests` and `trial_rules_tests` are registered but not in the local everyday profile: add them when the profile is next edited; the career report is rewritten from saved text by regular expressions (`mode_result_text.gd`): plain text at the source would be sturdier.
5. Then the everyday set and a full sweep, refresh the pull request 262 body from `.fable/FINAL_REPORT.md` (`gh pr edit 262 --body-file .fable/FINAL_REPORT.md`; editing the body starts no workflow), and update `docs/STATUS.md`.

## Open for Pat (do not decide these)

- **The six trial rules** ("Yes for testing", verbatim in `docs/USER_DIRECTIVES.md`): ask him again after he has played; each switches back in `game/src/trial_rules.gd`. Rule 2 changed the protected record of the 4 second lock (SIREN-010) so that it pins the standard length as a constant: he was told; confirm he is content.
- **The leftovers in the other clone** (a worktree folder and a branch `wp-55`): move to scrap only if he asks.
- **For his play:** whether menus scroll by finger drag on the phone (B19: cannot be checked on this PC); PLAN ROUTE sits under ROUTE while a deploy or recall segment shows; the field records gallery during a dive does not show that dive's frames until it ends.
- **From his rules** (`docs/V7_TO_GODOT_PARITY.md`, "Tests that still fly on the older rules"): the tender door photo with quiet drones, the scout-ahead opening, operations 17 and 30 on discovered charts. Which operation an Expedition starts on (a critic met the Campaign's finale as operation 1 of a seed).
- **A phone build** needs GitHub Actions. Do not start one. If he asks, tell him it costs minutes and ask whether to wait for the monthly reset.
- N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9, and his playtest feedback. When he says his rulings are done: mark pull request 262 ready (that starts a check run: ask first) and set status DONE.

## Leftovers from the code audit (after the UI work, or when they block it)

One `DroneBay` question for "in the water, aboard or lost" in place of about 30 direct reads of `alive`; state moved out of `main.gd` for its helper modules; drawing cost (A1) needs a real screen; autosave interval to 15 s only if Pat sees a stutter; branch `wp-28` holds one unmerged commit (screenshots and target report) left out on purpose.

## Rules that changed this week (the start command has the full list)

No GitHub Actions run of any kind; every push carries `[skip ci]`. Local tests only, and the whole registry after a batch of merges. Nothing is deleted: scrap is `_scrap-20261111/`. Retired tests live in `_scrap-20261111/tests-retired/`. Decide where Pat delegated; ask one yes or no line only for game design, story, or spending, and record qualifiers such as "for testing". Never write backslashes or `\n` escapes through a shell heredoc or inline Python: use the Edit or Write tool.
