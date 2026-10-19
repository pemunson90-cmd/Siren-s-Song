# Isolated equipment comprehension challenger

Experimental, released for independent review; not integrated or native-validated. Sole product delta: `game/src/main.gd`, supplied in `loadout-clarity.patch`. Shared game source was not edited. No stock, effect, option, control, archive, or simulation change.

## Inspect actual evidence first

- `challenger-cover/operations-survey.png` and `challenger-inner/operations-survey.png`: selected next-dive stock, all three alternatives, common equipment, durations, cycle and Settings fit together after scrolling.
- The matching `baseline-*/operations-survey.png` images show the previous name-only selection.
- `challenger-*/briefing-survey.png`: selected stock confirmation above the existing sticky ENTER WATER / BACK actions. Inner confirmation wraps onto three lines without clipping.
- `challenger-*/settings-reached.png`: actual existing Settings button click reaches Settings; Settings itself is unchanged. Cover Settings scrolls normally.
- `motion/{baseline,challenger}/menu-sequence.mp4`: matched 16.000s, 240-frame, 15fps, 2520×1080 cover-window sequences. Decode samples are `decoded-1fps-contact.png`; six full source frames and per-second chronology accompany each clip. Both encoded sequences were decoded and visually inspected. These are paused menu/briefing sequences, not dynamic-world idle or physical touch evidence.

Both movies use the same controller and initial paused Endurance dive. Mouse-down/up events cycle at frames29/30 and59/60; programmatic scrolling returns to the selector at34/64. Mission01 is clicked98/99, briefing scrolled104, ENTER WATER179/180. The cycle callback's inherited reset-to-top is visible briefly between click and subsequent scroll. Before frame180, active equipment remains Endurance120/2/2; after BEGIN, the actual new Survey dive has100/2/3. Controllers inject genuine Godot mouse input; scrolling and density/safe-area fixtures are scripted, not Android OS gestures.

## What changed and why

Operations now labels the pending selection NEXT DIVE / RETRY, compares starting O₂ / DISRUPT / SURVEY stock for all three choices, and states the common three decoys/two drones. It names each disruption's12s and each survey's8s audible effect. A short explanation beside RESUME says resuming preserves the active dive's equipment. Prelaunch briefing confirms the pending stock.

| Choice | Starting O₂ | Disrupt charges | Survey charges |
|---|---:|---:|---:|
| Endurance | 120% | 2 | 2 |
| Disruption | 100% | 3 | 2 |
| Survey | 100% | 2 | 3 |

The small presentation helper duplicates three fixed existing options; focused checks compare it with actual ordinary `Simulation.start` values. It does not introduce a new loadout manager. The existing v7 prototype had fixed stock rather than this production selector; its fixed equipment is not a basis for a new economy.

The generic tactical-pause hint moved before the equipment block, and the resume explanation sits beside RESUME, so the meaningful selector content fits the shorter layout without smaller typography or controls. Existing cycle behavior and option order are unchanged.

## Focused RED → GREEN

`verify_loadout.gd` instantiates the real scene. It compares advertised stocks against ordinary starts for every choice; executes actual disruption/survey commands to verify12s/8s plus survey emission; spends paused active-dive equipment and sets a route before genuine engine cycle clicks; checks snapshots through cycles and RESUME; confirms briefing stock and actual BEGIN selection. The final eight layout assertions check full selected label/comparison/cycle/Settings rectangles at both420dpi layouts.

- `red.log`: 30 checks,21 expected failures on the unchanged baseline, zero engine errors.
- `selector-visibility-red.log`: 38 checks,2 failures after initial copy implementation—cover selected stock and comparison did not fit at bottom.
- `initial-challenger-cover/` plus `initial-layout.patch`/`initial-layout-source.json` retain that weak layout.
- `partial-challenger-{cover,inner}/` and `partial-layout.patch` retain the intermediate helper-move layout: comparison fit but cover selected heading still crossed the viewport top by21 logical pixels. No claim of a durable intermediate raw38/1 log; it was overwritten during refinement.
- `green.log`: final38 checks,0 failures, zero SCRIPT ERROR / ERROR. Final source hash is the same source used for final captures and both movies. No broad unchanged suite was rerun, as explicitly scoped.
- `red-harness-scroll-error.log` retains a fixture mistake that attempted ScrollContainer.ensure_control_visible on a sticky-footer button outside its ancestry. The harness was corrected before the definitive RED/GREEN. `green-first.log` is preliminary and contains that fixture error; it is not final passing evidence.

The density assertions are geometry guards, supplemented by actual rendered images; neither is a human comprehension study.

## Measured cost and remaining limits

Logical maximum scroll offset (content maximum minus page), derived from each `views.json`:

| Surface | Baseline cover | Challenger cover | Baseline inner | Challenger inner |
|---|---:|---:|---:|---:|
| Operations | 761 | 1142 (+381) | 190 | 529 (+339) |
| Mission01 briefing | 583 | 750 (+167) | 0 | 35 (+35) |

The comparison improves discoverability of the real tradeoffs at the price of longer menu content. The selected label, all alternatives and existing bottom actions remain fully visible together in both inspected layouts. Cycling still rebuilds Operations and resets scrolling to top, inherited from baseline; this candidate does not claim to fix that interaction. The screenshots show the resume explanation only through label/behavior checks because the final selector views are scrolled down; no claim it is simultaneously visible with the bottom selector.

Desktop Godot4.6.3 Compatibility/OpenGL3, Mesa llvmpipe, Dummy audio; actual windows2520×1080 cover and2184×1968 inner. Existing `density_main.gd` supplies420dpi; cover safe-left136 uses the existing recorded-Android fixture. No physical Fold7 comfort, Android/native acceptance, audio quality, full campaign, or novice-learning verdict is claimed. V-Sync-not-supported warnings are backend limitations; final logs contain no engine errors. The movie encoder emitted a harmless single-image filename-pattern warning while writing each contact sheet; both images exist and were inspected.

## Source qualification and reproduction

The copies were taken while HEAD was docs checkpoint5e3d7fd with the chapter game then uncommitted. `published-source-verification.json` independently compares all137 tracked game files to the subsequently published `a178825fc4885f9f3ab191315302925ab0cdac87`; all match. Thus the actual gameplay baseline is a178, not the older5e3 gameplay. `baseline-source-manifest.json` records all159 copied files excluding `.godot`. `changed-files.json` confirms every original file except challenger main.gd is identical, the baseline is unchanged, and records exact hashes. Import caches/generated UID files are not part of the patch.

Exact main SHA256:

- baseline: `9e8e6cca44d0b326245df208f8ca50d5b00426ba768852c963aceacd4d5d1a53`
- challenger: `c2d4c83c300267daeb9e2174298258b902b69393c4e5d5f854d8a7876be5bb03`
- patch: `d371fb4d7599d5b3ae80f892668572ae97472e064771022ee709eb4ca3375d06`

The patch passed read-only `git apply --check` against the shared published-source main. Isolated copies remain under `work/loadout-clarity/{baseline,challenger}/game` with independent import/userdata caches. Root remains sole integration/publication owner.

From repository root, use task-local userdata and toolchain, for example:

```sh
TOOLCHAIN_CACHE="$PWD/work/toolchain" GAME_DIR="$PWD/work/loadout-clarity/challenger/game" XDG_DATA_HOME="$PWD/work/loadout-clarity/reproduce-userdata" scripts/toolchain/headless.sh --script "$PWD/docs/validation/production/loadout-clarity/verify_loadout.gd"
```

For rendered evidence, start a checked unused display with the existing display.sh and keep its owner alive through captures; run the existing Godot binary on the isolated GAME_DIR with `--resolution 2520x1080 --fixed-fps 15 --script` movie.gd and `-- --folder=<scratch-dir>`. Static capture.gd also accepts `--profile=cover|inner`. Use2184x1968 for inner. Controllers and raw engine logs are retained here; no shipped tooling change is required.

Brainstorming, TDD, isolation, systematic-debugging and verification skill principles were applied. User-authorized autonomous execution replaced routine approval pauses; the explicitly prescribed source copies replaced branch/worktree creation. The TDD linked writing-good-tests resource was unavailable at both attempted package paths; this was not represented as read. Actual backend/cost telemetry is unknown.
