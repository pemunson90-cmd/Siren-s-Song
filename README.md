# Siren's Song

Original Android-first 2D tactical submarine stealth and reconnaissance game. One pilot commands USS Quietus and two drones through alien industrial water, acoustic exposure, incomplete information and superior Siren threats. Photographic reconnaissance is the core pillar. Built with Godot 4.6.3, GDScript and the Compatibility renderer. The game project is in `game/`.

Current status, active work and the next action are in [docs/STATUS.md](docs/STATUS.md). That is the only status file.

## Build, run and test

Windows (native PowerShell, no WSL needed; details in [scripts/toolchain/win/README.md](scripts/toolchain/win/README.md)):

```
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\install-godot.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Core -Isolate
```

Linux:

```
scripts/toolchain/install-godot.sh
scripts/toolchain/headless.sh --editor --import --quit
scripts/toolchain/headless.sh --script res://tests/run_tests.gd
scripts/toolchain/test.sh --profile ci --suite runtime_tests
```

To play on a desktop, open `game/project.godot` in the Godot 4.6.3 editor and run the main scene. To get a debug Android package of any branch, run `gh workflow run android-validation.yml --ref <branch>` and download the `sirens-song-debug-apk` artifact; see [docs/PLAYTEST_ANDROID.md](docs/PLAYTEST_ANDROID.md).

Test rules, the suite registry and what runs in CI are in [docs/TESTING.md](docs/TESTING.md).

## Where the documents are

| Document | What it is |
| --- | --- |
| [AGENTS.md](AGENTS.md) | The single governing file for every agent, with Pat's standing directives |
| [docs/STATUS.md](docs/STATUS.md) | Current integrated base, active work, top weaknesses, blockers, next action |
| [docs/USER_DIRECTIVES.md](docs/USER_DIRECTIVES.md) | Pat's rulings, verbatim and dated |
| [docs/CURRENT_GAME_SPEC.md](docs/CURRENT_GAME_SPEC.md) | The intended game |
| [design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md](design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md) | Design bible |
| [docs/SOURCE_AUTHORITY.md](docs/SOURCE_AUTHORITY.md), [docs/V7_TO_GODOT_PARITY.md](docs/V7_TO_GODOT_PARITY.md) | Authority order, and the ledger of differences from the playable v7 prototype |
| [docs/WORKFLOW.md](docs/WORKFLOW.md) | Branch model, commit format, review and merge rules, CI gating |
| [docs/MODULES.md](docs/MODULES.md), [docs/CONVENTIONS.md](docs/CONVENTIONS.md) | Module seams and code conventions |
| [docs/REPOSITORY_MAP.md](docs/REPOSITORY_MAP.md) | Folder map and branch roles |
| [references/package/START_HERE.md](references/package/START_HERE.md), [references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md](references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md) | Accepted visual direction |
| [CHANGELOG.md](CHANGELOG.md) | What changed, by run |

## Branches

`claude/integration` is the development integration branch. `main` is the protected accepted baseline and the only promotion target; Pat authorizes promotion. `gauntlet/production` is a frozen earlier baseline. `archive/*` branches hold preserved evidence.
