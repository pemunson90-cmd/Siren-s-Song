# Handoff: the next steps, started the moment Pat types /siren-s-start-opus

Status: LIVE (rewritten 16 Nov 2026; Pat, 15 Nov: "the handoff is your next steps that are going to be initiated immediately upon me entering that start command, as well as pointing you to the exact documents and parts of the code that you need to work on for that next section". Do not reread the repository to get your bearings.)

Done so far: `.fable/PROGRESS.md`. Open problems: `.fable/ISSUES.md` (top: "This round's goal" and "Playthrough findings"). Head and what was running: `.fable/NOW.md`. Helper brief rules: `.fable/HELPER_RULES.md`. Pat's words: `docs/USER_DIRECTIVES.md` (last three sections, 16 Nov) and `CLAUDE.md` (Pat's 16 Nov directive from PR 263, verbatim at the top).

## Rules of this round (Pat, 16 Nov; they win over older text)

- **Definition of done (verbatim):** "Finished for this round is an APK where I can play through the entire game. Polish, new features, number tweaking, story updates etc are all for the next round of the gauntlet." Fix only what stops a full playthrough: crash, stuck dive or screen, unreachable or dead control, broken save, an operation that cannot be completed by fair play, a campaign that does not continue. Everything else goes in `.fable/ISSUES.md` for next round.
- **Testing (CLAUDE.md, 16 Nov directive):** excessive testing is a failure. Run only the suites a change touches, plus Core when `game/src/simulation`, `campaign` or `photo_rules` changed. No routine batch retests and no full sweep unless a concrete risk calls for it. Playthroughs of the real game are the evidence.
- **No bookkeeping, but the game must not play itself** (Pat 16 Nov, `docs/USER_DIRECTIVES.md`).
- **Helpers:** sonnet implementers and testers, haiku for documentation, at most 3 at once, 45 minutes each. Brief starts "First read `.fable/HELPER_RULES.md`", names branch and base SHA, ends "REPORT ONCE, then STOP". Critic kits live outside the repo in `C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\_fable\critic-kits\<name>`; helpers report in their final reply and root saves it.
- **Playthrough testers:** headless via the play API (`scripts/critic/OPERATE.md`): speeds 1/2/4 only; jobs (DECODE/SAMPLE/LINK) are `order operate`; Route Map and region card are readable; ping SONAR and wait for the echo before routing (sonar charts rock, `advanced_sonar.gd:55-75`); answer SEND ANYWAY on depth warnings; "HEARD: machinery pulse" = Warden. A tester covers about 5 operations in 45 minutes. `jump N` (catalog id; shown number is id+1) starts an operation but marks the profile DEV, so its wins prove completability, not campaign progress. Ids 12/13 need the debug `fact confluence_route concealed|overt`.
- **Phone build:** `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\build-apk.ps1`; APK at `%USERPROFILE%\.cache\sirens-song-toolchain\apk-local\sirens-song-debug.apk` (about 77 MB, give Pat the path). No emulator.
- **No GitHub Actions**, `[skip ci]` on every push, pushes only under `fable/`. Nothing deleted: move to `_scrap-20261111/` or `_scrap-20261116/`.

## Steps, in order

1. **Collect the running work** (named in `.fable/NOW.md`): WP-172 (a closed recovery mouth says why, `simulation.gd` `departure_context`), region testers R3 (ids 8, 9, 10, 12, 13) and R4 (Glass Reach 14 to 21). Check each report's claims, merge fixes, record in PROGRESS/ISSUES.
1a. **State at the 16 Nov evening checkpoint:** all 42 operations proven winnable by fair play (`.fable/ISSUES.md` "Playthrough findings"); real campaign progress proven 01 → 07 → 09 by a clean run. Running: WP-181 (the "New terrain" chart-stop card that loops after CONTINUE COURSE / REPLAN, `chart_stop_choice.gd`) and WP-182 (op 13 pickup LISTEN labelled "RECIPIENT CONTROLS"; `operate` refuses there). After both merge: one full sweep (many simulation changes today), then the APK (step 5).
2. **(Done 16 Nov) Finish completability coverage.** Won by fair play so far: ids 0-7, 11, 14-17, 22-36 (28 of 42; `.fable/ISSUES.md` "Playthrough findings" has each winning approach). Left: 8, 9, 10, 12, 13 (tester R13 running), 18-21 (R14), 37-41 (R15). Fixed this round: WP-169 to WP-176 (PROGRESS). Testers drive with `order control` for wheel jobs and the lock card's `decoy_point`. One region tester per region, at most 3 at once (brief pattern: the R3/R4 briefs, `jump` only to start).
3. **Fix every blocker found**, one package per blocker on disjoint files; near-blockers only if they can lose a dive with no fair way out (like WP-161, WP-169, WP-171, WP-172).
4. **One clean run across the campaign's real progress:** a fresh profile, no debug, from 01 through the Divergence into the next region, checking the result screen and Campaign screen open the next operation after each win (testers A and C covered 01-05 this way).
5. **Phone build for Pat** once no blocker is open; tell him the path, the signer line and the head SHA, and ask what he hit first.
6. **Next round list:** polish, new features, number changes and story found by testers stay in `.fable/ISSUES.md` (e.g. the Warden needs a tell, op 7 air is tight, rock-blocked pauses do not name the waypoint). Do not build them this round.

## At the next pause

Append to `.fable/PROGRESS.md` and `.fable/ISSUES.md`, rewrite this page's steps so the next session starts at once, update `.fable/NOW.md` and `RUN_STATE.json` (`python scripts/repo/run_state.py --status PAUSED --next "..." --now "..." --log "PAUSED: RESUME REQUIRED ..."`), push with `[skip ci]`, and say the resume command is `/siren-s-start-opus`.
