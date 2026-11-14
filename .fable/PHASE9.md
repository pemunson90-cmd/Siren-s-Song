# Phase 9: UI and UX repair

Status: LIVE PLAN (resumed on Opus 13 Nov evening; updated 19:00 after the third critic round and WP-56 to WP-60). This file plus `.fable/RUN_STATE.json` and `.fable/NOW.md` is enough to continue. You do not need to reread the repository or the session transcript.

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

Coordinates are native pixels (cover 2520x1080). A screenshot saved at scale 0.5 must be doubled. Menus do not scroll by finger `drag` on this PC (Godot scrolls by finger only where a touchscreen exists): use `wheel` (`{"command":"wheel","x":..,"y":..,"notches":9}`). Each kit session name and view has its own fresh profile; `labels` can list labels of a screen underneath: trust the screenshot. Path to a dive on a fresh profile, cover (after WP-62's wide menus, 13 Nov evening): START GAME (1260,295), CAMPAIGN card (645,304), NEXT OPERATION (1850,216), CONTINUE TO BRIEFING (1260,969), ENTER WATER (664,960), Quietus on the chart (230,790), pause plate (83,60), FLEET (2436,60). On a wide screen BACK is a full-width bar at the top, so a tap at the plate's spot on a menu goes BACK. The camera panel's SHUTTER moves with the threat cards above it: read its place from a screenshot. Run critics one at a time or each with its own kit, and give each its command-file path inside its own audit folder.

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
| WP-56 | Lock card names the counter-moves ("Or: GO SILENT · DECOY ×3 · EMP ×2"); a lost craft gets a card; Quietus chip says SILENT or LOUD | 86 |
| WP-57 | Career result gives cause, time, hull, repair; rider lines name their contract; damage record names causes | 87 |
| WP-58 | Route prompt in fixed places, switch on its own row; rock checked from the route's end; "set route" | 88 |
| WP-59 (root) | HELD plate while a menu holds time; 150% briefing footer; Hunt help in plain words; Career banner below the threat lines (`mode_banner.gd`); hub slips; PHOTO GALLERY; kit `--slot` required | 89 |
| WP-60 | Opening journeys answer chart stops (test only; all five openings won on both screens) | none |

Two blind critic rounds on 13 November (kits `fable-critic26-20261113` and `fable-critic33-20261113`; journals and captures under `<kit>/audit/critic-a|b|c/` and `<kit>/evidence/critic-a|b|c/`). In the first, critic A lost operation 1 three times; in the second, critic A finished it.

Third round (kit `fable-critic37-20261113`, head 62a2877f): A (campaign, cover) lost dive 1 to a far, loud, 13% photograph and won dive 2 with a drone decoy; B (menus, inner) found the 150% briefing footer and the narrow front-end screens; C (Expedition and Career, loud) found chained self-pauses, a drone loss shown only as a log line, Career's bare result and rider placement. A's "the pause let go by itself" was its own blind tap on the plate (request log), but it showed that PAUSED was shown while only the wheel held time: now HELD. B's two foreign screenshots came from leaving `--slot` off (kit default was slot a): now required.

Second sweep (13 Nov, read on resume): every one of the 245 registered suites has a log; failures were four stale suites after the trial rules and the PLAN ROUTE move (terminal_tick, field_tools, depth_policy, opening_depth_policy), all fixed. `cold_review_archive_tests` and `art_render_measurements` cannot run here.

## In flight

- WP-75 to WP-92 merged (rows 104 to 122). Sweeps 6 (91702f14) and 7 (150b9fa9) were green on every registered suite except the two this PC cannot run (`cold_review_archive_tests`, `art_render_measurements`); `opening_depth_policy_ui_tests` runs alone (its summary prefix is "OPENING POLICY UI", 571 checks). Core 856/0 on 150b9fa9.
- WP-88 to WP-92 merged on top of 150b9fa9 at about 06:50 on 14 Nov, with their touched suites run; not yet pushed and not yet in a full sweep (the eighth sweep is the next step).
- No helper running. Fifth critic round done and ranked (below); its findings are fixed except the items marked Pat's and the Route Map's cramped SHELF column at the overview zoom (minor).
- Next: push, eighth full sweep, a sixth blind critic round on the merged head (one kit per critic), then rank again.

The resume command for an Opus session is `/siren-s-start-opus`; `/siren-s-start-fable` is the same run on the Fable model.

## Incident (13 November): the other clone was touched

The WP-55 helper was created in `repos\Siren-s-Song` (the clone that must not be touched) because the session's working directory had fallen back to it before the dispatch. That clone gained a worktree folder under its `.claude\worktrees\` and a local branch `wp-55`; its own files and checked-out branch are unchanged. Root fetched the branch from it read-only and removed nothing. Pat was told and has not asked for the leftovers to be moved. Guard: item 2 of the loop.

## Not yet seen by root in a capture

- The lock card with its counter-moves line (WP-56) and the lost-craft card: no lock or loss provoked in root's looks. Critic captures of the lock card from kit 37 (`critic-a/024_lock_full.png`, `critic-c/032_lockon_quietus_full.png`) are from before WP-56.
- The Career result screen's new lines, the board's rider lines (WP-57), the Career banner placement in a dive (WP-59).
- The Siren warning after WP-51 is now seen in kit 37 (critic A 024 and 025): one card, tip card in its fixed place.
- FITTINGS in two columns on the inner screen (seen on cover in kit 35).
- The fitting cards and scale bars of WP-41: a new campaign has none until operation 1 is recovered.
- Trial rules 2 to 6 in play (rule 1 seen in kit 36); the widened pause plate at large text.
- The Career board, the Expedition operation menu, the damaged-start briefing line, the "short by" lines on Supplies.
- Seen on 14 Nov (kits 75 and 91, cover screen): the chart preview on the region card and briefing, the two-line UNDO chip (normal text only), the archive's "STILL TO PHOTOGRAPH" rows and the honest new-campaign ledger, the Route Map's region name and tags, the new wheel centre, Back in a dive (wheel closes, then Operations with RESUME DIVE). Not seen: any of these on the inner screen or at 150% text; the CHOOSE TARGET list for overlapping craft; WHICH CRAFT?; the chart labels near the camera panel.

## Queue, in order

**Fifth critic round (14 Nov, kits 48 to 50 on preview c59617f6 = 91702f14 + WP-82 + WP-83), ranked.** A (Campaign 01 to 02, cover), B (menus, inner, 150% text), C (Career, Expedition, Challenges, cover). In helpers: WP-84 (large text keeps two columns on the inner screen, B F1), WP-85 (a stuck craft says so and trial rule 5 fires, A S1; lock-card moves show whether they land in time, C F2; the strip's message never goes stale, A/B), WP-86 (result screens: "began at Hull 86%" bug in `damage_log.gd` `sample()`, A S2; Career loss "a cause the game does not record" and "came home at 0%", C F1; the Expedition's Hunt stage numbers, B F10/C F4; tools vanishing between Expedition screens, C F5; spent/earned/kept block, C F3). Next, small: hard-edged lighter water blocks (B F6, A 063; likely `art/region_renderer.gd` per-cell washes), locked challenges name the Campaign and explain on tap (C F7, B F13), the Hunt chip explains itself on first display (A S11, C F11, older rounds too), Career board Back matches its button (B F7), the pause tip before the first run (A S5, B F5), the route prompt on every added point (A S4: three taps per leg). Pat's: long waits on the return leg (A S9, C F9: route legs about 450 m; a speed-up control or a route-home order touches his travel rules), seeded modes reuse Campaign maps (C F8), challenges locked behind the Campaign (C F7), mission jargon ("crown", "wakes", "lee", B F10). Found fine: Back on sub-screens, the photo panel's forecast (praised by A and C), mode explainers, Fittings honesty.

**State on 14 Nov, 03:00 (read this before the older lists below).** Done since those lists were written: B F3 region names and tags (row 107), B F5 chart preview (104), B F14 UNDO and craft chip (105), map labels clipped ("HUTTER REACH") and overlapping craft opening FLEET (108), B F8 Back consistency (109). Found already done: locked challenges show their rule (102), the Expedition Hunt worded as a ceiling (99), the lost-drone photo line (97), "not ready" reasons (98). In helpers now: WP-82, WP-83. Still open and small: the order wheel's tether ring is drawn under segment labels; Escape in a dive (desktop) still goes straight to Operations (`dive_input.gd`; make it call `back_levels.dive`); a Career dive's Back goes to the Career board (resumable; `career_tests` pins it). Next big step: the fifth blind critic round, then rank again.

1. **Merge WP-61 and WP-62** (one at a time; radial hud and HUD words after each), look at both in a kit (cover and inner), rows 90 and 91, then the **full sweep** (`scripts\toolchain\win\full-sweep.ps1`; check no other sweep is running first: two ran at once on 13 Nov).
2. **Fourth blind critic round** (running 13 Nov evening: A on kit 42, B on kit 43, C on kit 44). **One kit per critic, each on slot a**: in the first attempt critic B sent 33 commands to slot c (critic C's game) despite `--slot` being required; B's and C's results were discarded and both rerun on their own kits. Ask for captures of everything under "Not yet seen".
3. **Fourth round (A kit 42, C kit 45; B not yet rerun cleanly) ranked:** built or building: lock auto-pause repeating (fixed, row 94), one-tap moves on the lock card (WP-67), shutter honest under a lock / stop exposure / unclipped camera panel (WP-66), result screens telling one story: cause from the event not the last message, beam named in the damage record, the 60% floor explained, every tool used listed (WP-68). Left: the run record says "Hunt started at stage 2" while operation 1 starts at its cap (stage 1), and the meter then decays to its floor (wording, `run_summary_view.gd`); a drone lost with a photograph under way never says the photo went with it, and a craft loss does not pause (the loss pause is an accessibility setting, rules are Pat's); a tap on water with no craft selected does nothing silently; "LISTEN … NOT READY" never says what is missing; the Career briefing never lists the tools carried; map labels overlap and clip ("HUTTER REACH"); tapping overlapping craft opens FLEET; critic B's large-screen menu pass must be rerun alone (kit per critic, command file in its own folder). **Critic B solo (kit 47) ranked:** the hub, briefings, archive and arc story card are still one ~1260 px column on the inner screen (F1, F2: two panes: operations left, the chosen operation's briefing and a chart preview right); the Route Map has no region names or reward/risk tags (F3); the briefing has no chart preview (F5); hull and drone unlocks in SUPPLIES give a cost but no effect (F7); STRIP ALL, MAKE IT EASIER and IRONMAN sit among routine purchases (F8); DEVELOPER visible in Settings and ERASE PROGRESS one tap from content (F12); at 150% the UNDO chip wraps to four lines and the craft readout truncates (F14); a stray clipped "LE" at the right edge of the Expedition briefing (F15); the Field Log promises "twenty minutes of air" while the HUD shows O₂ ~3:36 (F18; story text, Pat's); locked challenges show no rule text (F20). Its "route ended, no pause" (F16) was trial rule 3 never firing at real frame rates: fixed (row 100).
4. **Left from the third round:** C F12 Expedition briefing says "Supplies: scarce" without what is short; C F11 Expedition tools list repeats "None left in expedition stock"; B F6 the message log takes 3 to 4 lines at 150%; B F8 Back and exit consistency (several Backs can leave the app); A F10 no tool taught in operation 1 beyond the lock card's new counter-moves line; C F2/A F2 a loud, open approach is fatal within seconds (rules: Pat's).
4. **Left from the second round's ranking:** a line after a photograph saying what a better frame would add (C G3, F11); the Route Map reads as a developer tool ("UNKNOWN / LOCKED", raw numbers, node 39); Naval Career says "separate resources" and shows the Campaign's balance, and does not say how standing is gained; SUPPLIES AND COSTS is still one column; long unattended legs; no FIT button in the dive; Hunt meter moves with no explanation, and its help text still says the lock is 4 s (`presentation/meter_table.gd`); the mode picker and the other front-end screens are plain black behind a narrow column on the inner screen.
4. **Loose ends from the packages:** "first dive" for trial rule 2 is recognised as the plain Campaign simulation running operation 01 (a mode flag would be sturdier); `onboarding_hints.gd` still sets `sim.paused` itself (outside the one auto-pause path); a route pending because of rock is not re-checked when the player presses ADD TO ROUTE; mission-context wheel extras still shift segment angles; Career's pending-save reason text; `tap_ownership_ui_tests`, `hud_words_ui_tests` and `trial_rules_tests` are registered but not in the local everyday profile: add them when the profile is next edited; the career report is rewritten from saved text by regular expressions (`mode_result_text.gd`): plain text at the source would be sturdier.
5. Then the everyday set and a full sweep, refresh the pull request 262 body from `.fable/FINAL_REPORT.md` (`gh pr edit 262 --body-file .fable/FINAL_REPORT.md`; editing the body starts no workflow), and update `docs/STATUS.md`.

## Open for Pat (do not decide these)

- **The six trial rules** ("Yes for testing", verbatim in `docs/USER_DIRECTIVES.md`): ask him again after he has played; each switches back in `game/src/trial_rules.gd`. Evidence from the third critic round: critic A (cautious) met 4 self-pauses in about 3 minutes and found each useful; critic C (loud, drones out) needed five resumes in one danger moment (a lock, then "QUIETUS finished its route", then "DRONE A finished its route" a second apart) and asked for pauses to be merged or made settings. A possible middle (Claude's suggestion, not built): route-end pauses that fall within a second or two of another pause fold into it. Rule 2 changed the protected record of the 4 second lock (SIREN-010) so that it pins the standard length as a constant: he was told; confirm he is content.
- **The leftovers in the other clone** (a worktree folder and a branch `wp-55`): move to scrap only if he asks.
- **For his play:** whether menus scroll by finger drag on the phone (B19: cannot be checked on this PC); PLAN ROUTE sits under ROUTE while a deploy or recall segment shows; the field records gallery during a dive does not show that dive's frames until it ends.
- **From his rules** (`docs/V7_TO_GODOT_PARITY.md`, "Tests that still fly on the older rules"): the tender door photo with quiet drones, the scout-ahead opening, operations 17 and 30 on discovered charts. Which operation an Expedition starts on (a critic met the Campaign's finale as operation 1 of a seed).
- **A phone build** needs GitHub Actions. Do not start one. If he asks, tell him it costs minutes and ask whether to wait for the monthly reset.
- N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9, and his playtest feedback. When he says his rulings are done: mark pull request 262 ready (that starts a check run: ask first) and set status DONE.

## Leftovers from the code audit (after the UI work, or when they block it)

One `DroneBay` question for "in the water, aboard or lost" in place of about 30 direct reads of `alive`; state moved out of `main.gd` for its helper modules; drawing cost (A1) needs a real screen; autosave interval to 15 s only if Pat sees a stutter; branch `wp-28` holds one unmerged commit (screenshots and target report) left out on purpose.

## Rules that changed this week (the start command has the full list)

No GitHub Actions run of any kind; every push carries `[skip ci]`. Local tests only, and the whole registry after a batch of merges. Nothing is deleted: scrap is `_scrap-20261111/`. Retired tests live in `_scrap-20261111/tests-retired/`. Decide where Pat delegated; ask one yes or no line only for game design, story, or spending, and record qualifiers such as "for testing". Never write backslashes or `\n` escapes through a shell heredoc or inline Python: use the Edit or Write tool.
