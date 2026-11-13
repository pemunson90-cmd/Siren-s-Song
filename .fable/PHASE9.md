# Phase 9: UI and UX repair

Status: LIVE PLAN (rewritten 2026-11-13 for the pause Pat asked for; root updates it as items finish). This file plus `.fable/RUN_STATE.json` and `.fable/NOW.md` is enough to continue. You do not need to reread the repository.

## What Pat asked for (verbatim, 12 and 13 November 2026)

- "I want to perform another comprehensive audit and repair of the UI and ux"
- On the audit's yes or no list: "Yes to all by your judgement. Youre here to fix the game. I can personalize it later"
- "actually look at how it looks compare it to professional Android games and similar top-down games and make some evaluations and judgment calls"
- On drones: "I prefer the idea that wants deployed they had to stay out. They are torpedo deployed deep sea drones, I don't really think a recovery Bay makes sense on an experimental stealth sub."
- On photographs after a lost dive: "On easy mode you keep them, everything higher you don't.."
- On GitHub: "This is why we need to trim the tests and why we need to test local right now. I'm literally out" and "do the rest of the work yourself because we don't have another choice"
- "Good job Keel, keep up the good work. Fable the fuck out of this game. Make codex jealous."

So: every item in `.fable/UX_AUDIT.md` (Part A defects, Part B B1 to B19, Part C C1 to C10) is approved by Claude's judgement. Claude decides layout, plain wording and names, builds, and lists every changed text in `.fable/FINAL_REPORT.md` so Pat can personalize it later. Story, game rules and prototype mechanics stay Pat's.

## How the work is done (the loop that has been working)

1. Root designs the package and writes a brief for ONE Sonnet `implementer` agent per package (`isolation: worktree`), at most three at once, on disjoint files named in the brief. Briefs that worked are in the session transcripts; the fixed parts are: branch from `origin/fable/overhaul-20261111` (worktrees start at `main`), the files it owns and must not touch, no deletions, no amend, no push, no GitHub runs, private temp folder, Edit tool for anything with backslashes, the exact local test commands, one report when nothing is still running.
2. When it reports: root reads the diff (`git diff <base> <branch> -- game/src`), judges it (reject what is wrong: so far a 6 second timeout on status messages, removal of the top TITLE button Pat asked for, a button height boost that broke a layout), merges with `git merge --no-ff --no-edit <branch>`, reverts a bad commit with `git revert --no-edit <sha>`.
3. Root runs the touched suites locally (commands below) and core if `game/src/simulation` changed.
4. **Root looks at it in the real game before calling it done.** Build a kit from the head and capture the changed screens on the cover screen (and the inner screen for menu work). Layout suites did not catch the one bad break so far; a capture did.
5. Root sends Pat the captures (SendUserFile), adds behavior rows to `.fable/FINAL_REPORT.md` naming every changed text, a row in `docs/MODULES.md` for a new module, updates state with `python scripts/repo/run_state.py`, commits and pushes with `[skip ci]`.

### Commands

```
cd "C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\_fable\Siren-s-Song"     (every shell command starts here)
$env:ARTIFACT_DIR="$env:USERPROFILE\.cache\sirens-song-toolchain\artifacts\fable-root"
scripts\toolchain\win\headless.ps1 -Action Import -Isolate
scripts\toolchain\win\headless.ps1 -Action Core                                  (856 checks, about 100 s)
scripts\toolchain\win\headless.ps1 -Action Script -Script <suite> -Prefix "<PREFIX>"
scripts\toolchain\win\test-suite.ps1 -Suite a,b,c -SkipCore                      (several suites; it SKIPS render-flagged ones: run those with headless.ps1)
scripts\toolchain\win\test-suite.ps1 -All -Profile local                         (the everyday set, 39 suites, about 20 min)
python scripts/toolchain/select-suites.py --minimum --changed <paths>
```

Looking at the game (Windows, needs the GPU; opens a game window on Pat's PC):

```
K=%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-criticNN-<date>
python scripts/critic/kit.py new --ref HEAD --out K           (build from a commit; commit first)
python scripts/critic/kit.py launch --kit K --slot a --view cover --session root-look     (inner = 2184x1968)
python scripts/critic/kit.py send --kit K --slot a '<json>'   (click, wait, screenshot, labels, batch; see scripts/critic/OPERATE.md)
python scripts/critic/kit.py quit --kit K --slot a            (always quit)
```

Coordinates are native pixels (cover 2520x1080). A screenshot saved at scale 0.5 must be doubled. Path to a dive on a fresh profile, cover screen, as of 12 November (use the `labels` command to find rectangles if these move): START GAME (1260,531), CAMPAIGN (1260,283), operation 01 card (593,196), CONTINUE TO BRIEFING (1260,1002), ENTER WATER (976,960), Quietus on the chart (230,790), wheel BACK (272,538), pause control (100,60).

## Done in phase 9 (all merged and pushed; behavior rows 57 to 70 in `.fable/FINAL_REPORT.md`)

| Package | What | Audit items |
|---|---|---|
| WP-31, WP-32 | Plain defects: wheel centre no longer truncates, "MORE TOOLS" title, SONOBUOY whole, route dialog counts stops ahead, chart labels clamp when zoomed, Expedition lost screen and Supplies page truthful, archive tabs | A1 to A5, A7, A9 |
| WP-33 | Button roles in `game/src/presentation/ui_style.gd` (MAIN filled, NORMAL, QUIET, DANGER), chosen by action id; colours only, sizes stay with the layout | C1 |
| WP-34 | Lost screen lists photographs; lost-dive photographs kept only on the Accessible preset (`photo_review.gd` `keeps_photos_after_loss`); confirms on Expedition END DIVE and Challenge END ATTEMPT | B3, B4 |
| WP-35 | DEPLOY DRONE on the wheel (order "deploy" through `Simulation.command`), deployed drone becomes selected, RECALL on the first wheel page, "deploy" wording, route dialog placed off the craft and marker | B2, B5 |
| WP-36 | Pause and FLEET drawn as buttons in their old rectangles, life support reading and gauge bar while paused too, status lines cleared at the next order, wheel centre fits the disc, wheel edge margin | C2, C3, A6 |
| WP-37 | Campaign hub as Continue, Operations cards with lock reasons, Prepare and review grid, Difficulty; two columns on wide screens; briefing with one LOADOUT entry; plain labels (`ops_home/`, `flow/campaign_flow.gd`, `layout_metrics.gd` `hub_wide`) | C5, C6, B14 |
| WP-38 | Tapping a contact opens a card of observed facts (`presentation/contact_card.gd`) and sets no route; chart labels on backing plates in priority order | B6, C10 |
| WP-39 | Plain wording for jargon, "BACK TO ..." labels, Android Back on Naval Career, credits filtered of engineering notes | B7, B9, B15 |

Already in the game, no work needed (the critics missed them): B1, B10, B11, B12, B18. Not a defect: A10, the DEVELOPER button (debug builds only). A8 left: the top TITLE button is Pat's request.

## In flight at the pause

**Since the resume of 13 November: WP-40 (B8, B13), WP-41 (C7) and WP-42 (C4) are with implementers on branches `wp-40`, `wp-41`, `wp-42`; `.fable/NOW.md` has the table.** At the pause itself nothing was in flight: WP-37 (hub and briefing), WP-38 (contact card, label plates) and WP-39 (plain wording, back pattern, credits) are all merged, looked at in the kit and pushed: behavior rows 65 to 70. No helper, game or test is running. `.fable/NOW.md` records the result of the last everyday set.

Seen in the kit and not yet fixed (small; fold into the next dive-screen or menu package):

- On the cover screen the goal chip at the top ("SEARCH · 511m") can sit over the objective label "UNKNOWN SIGNAL SOURCE · AREA · BRG ..." when the chart scrolls.
- The first-dive PAUSE tip card shows again while paused.
- The contact card has not been seen in a capture yet (no Siren came into view in the minute root played). Look at it the next time a kit is open: operation 1, near the spire.
- On the hub the right column on the cover screen still scrolls on a fresh campaign because the difficulty picker with its Ironman note is long; the six operation cards fit.
- In the operation 1 briefing "HIDE LOADOUT DETAILS" shows with nothing under it (the fold is open and empty).
- Two slash-built headings remain: "HULL AND DRONE FRAMES / NEXT LAUNCH" (`presentation/equipment_context.gd`) and "RECOVERED FITTINGS / NEXT LAUNCH" (`presentation/fit_surface/`): fix with C7.
- The contact card bearing is a compass bearing; the "BRG" on lead areas uses another convention: make them one.

Added 13 November after the resume:

- The fitting cards and true-scale bars of WP-41 have NOT been seen in a capture: a new campaign shows no frames or fittings until operation 1 is recovered. Look at them on a profile that has recovered operation 1 (play it in the kit, or find a test fixture save).
- The Fittings screen ends with two slash buttons, "SUPPLIES / COSTS" and "RESEARCH / ARCHIVE / FIELD LOG"; the Career heading reads "CAREER / SHELF SIGNAL"; the Career balance row is raw ("BALANCE · SCRAP 8 · CELLS 10 · ALLOY 0"); the rider line ("OPTIONAL RIDER · ... Bonus +1 CLIENT STANDING. Failure forfeits only this bonus.") is built in `campaign/career/riders.gd`.
- The Expedition operation menu (GOAL, DANGER, rules) has not been captured: starting a seed returns to the Expeditions list; tap CONTINUE EXPEDITION there.
- The empty LOADOUT fold in the operation 1 briefing: cause is `presentation/flow/campaign_flow.gd` lines 130 to 150 (the fold is made whenever any node follows `fit_start`, and the FIT SUMMARY toggle is always added). Fix: make the fold only when a visible content node follows.
- The status line after the switch reads "Queued waypoints STOP before continuing" (a simulation message): plain words wanted.
- Kit: a finger `drag` does not scroll menus on this PC (Godot scrolls by finger only where a touchscreen exists). Use the new `wheel` command. Whether menus drag on the phone is still B19 for Pat.
- `loadout_frames_tests` failed on the head before WP-41 (its helpers looked only at direct children of the panel); WP-41 fixed the helpers.

## Queue, in order

Done since the resume (rows 71 to 74): item 1 (WP-40), item 2 cards and bars (WP-41), item 3 (WP-42, redrawn by root), item 4 (WP-43), B17 ("signal spire" everywhere the player reads it). In flight: WP-44, the tool racks part of the Fittings screen (`tool_racks_view.gd`, `mode_racks_view.gd`) on branch `wp-44`. Then items 5 to 7 below.

1. **B8 and B13**: Career and Expedition briefings in the Campaign's GOAL and DANGER format (`presentation/career/career_board.gd`, `presentation/runs/`); results and fittings screens say what changed in words, not rows of raw numbers. Claude writes the plain lines; list them for Pat.
2. **C7**: fittings as cards (name, what it changes, a chosen mark, a lock with its price; `presentation/equipment_context.gd`, `fittings_menu.gd`); the NOISE and ENDURANCE bars drawn to their true scale with the baseline marked.
3. **C4**: title screen backdrop from the game's own chart art (rock, water, a drifting Quietus) behind the wordmark and menu (`presentation/frontend/frontend.gd`).
4. **C8**: on the route dialog, REPLACE ROUTE as the MAIN button and the new-points switch drawn as a switch (`order_guard.gd`; in-dive buttons are not in the role table yet).
5. **C9**: sentence case for descriptions and messages on the screens touched. **B17**: one name for the first mission's target ("signal spire" is the Campaign's; Career says "listening spire/station", the region card says "Corran Bank"): choose and list.
6. **A fresh blind critic round** on the result: three critics through the kit as in `.fable/COLD_REVIEW_6.md` and the first UI round (briefs are `scripts/critic/CRITIC_BRIEF.md` and `OPERATE.md`; dispatch text must tell them to use native coordinates and to double anything read from a half-size screenshot). Rank what is still weak and continue the loop.
7. Then the everyday set once, refresh the pull request 262 body from `.fable/FINAL_REPORT.md` (`gh pr edit 262 --body-file .fable/FINAL_REPORT.md`; editing the body starts no workflow), and update `docs/STATUS.md`.

## Open for Pat (do not decide these)

- **For his play:** PLAN ROUTE leaves the wheel's first page while DEPLOY or RECALL shows (it stays under ROUTE). The field records gallery opened during a dive no longer shows that dive's own frames until the dive ends. Whether Credits, the hub and the briefing scroll by finger drag on the phone (B19).
- **From his rules** (`docs/V7_TO_GODOT_PARITY.md`, "Tests that still fly on the older rules"): the tender door photo with quiet drones, the scout-ahead opening, operations 17 and 30 on discovered charts.
- **A phone build** needs GitHub Actions. Do not start one. If he asks, tell him it costs minutes and ask whether to wait for the monthly reset.
- N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9, and his playtest feedback. When he says his rulings are done: mark pull request 262 ready (that starts a check run: ask first) and set status DONE.

## Leftovers from the code audit (after the UI work, or when they block it)

One `DroneBay` question for "in the water, aboard or lost" in place of about 30 direct reads of `alive`; state moved out of `main.gd` (about 765 lines) for its helper modules; drawing cost (A1) needs a real screen; autosave interval to 15 s only if Pat sees a stutter; branch `wp-28` holds one unmerged commit (screenshots and target report) left out on purpose.

## Rules that changed this week (the start command has the full list)

No GitHub Actions run of any kind; every push carries `[skip ci]`. Local tests only. Nothing is deleted: scrap is `_scrap-20261111/`. Retired tests live in `_scrap-20261111/tests-retired/`. Decide where Pat delegated; ask one yes or no line only for game design, story, or spending. Never write backslashes or `\n` escapes through a shell heredoc or inline Python: use the Edit or Write tool.
