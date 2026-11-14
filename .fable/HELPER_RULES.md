# Helper rules (read before any work; your brief overrides only where it says so)

Run `overhaul-20261111`, game Siren's Song (Godot 4.6.3, GDScript, game in `game/`). Run clone: `C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\_fable\Siren-s-Song`, branch `fable/overhaul-20261111`. Pat's rulings: `docs/USER_DIRECTIVES.md` (last sections first). His order of goals (14 Nov): efficiency, then accurate and complete work, then the letter of instructions.

## Where you work
- Your first command creates your worktree from the run clone: `cd "<run clone>" && git worktree add .claude/worktrees/<branch> -b <branch> <base SHA from the brief>`. Work and commit only there.
- Never touch the other clone `repos\Siren-s-Song`, the run clone's own files, or `.claude/worktrees/sweep` (full test sweeps run there).
- Commit on your branch with `git commit -m` only. Do not push, merge, or open or close pull requests. Root merges.

## Never
- Delete anything, temporary files included: move unwanted files to `_scrap-20261111/`. No `rm`, `rm -f`, `git rm`, `git clean`, `git reset --hard`, `git stash`, amend, force push, history rewrite, `--no-verify`.
- Start a GitHub Actions run. Testing is local.
- Write files through a shell heredoc, `printf`, `sed` or Python: use the Edit or Write tool (backslashes and line endings get damaged otherwise).
- Change a game rule (numbers, timings, damage, payouts, auto-pauses in `game/src/trial_rules.gd`) unless your brief quotes Pat's ruling for it. If a rule looks wrong, say so in your report.
- Add a one-tap travel order: release play is piloted by hand; travel shortcuts are debug-only.
- Leave helper scripts in `/tmp`, the system temp folder or the working folder: keep them in your worktree under `_scrap-20261111/`.

## Code standard
- Names and numbers defined once: dive words in `game/src/presentation/hud_words.gd`, sizes and colours in `ui_style.gd`, names in `names.gd`, Pat's trial switches in `trial_rules.gd`, other words in the table that already owns them. Append new words at the end of a table (other packages edit the same tables).
- No unneeded systems; reuse what exists. Mark changed code with a short `# WP-NNN:` comment saying why.
- A new module gets a row in `docs/MODULES.md`.
- Check what you build on both screens: cover (window 2520x1080, canvas 1680x720) and inner (window 2184x1968, canvas about 1280x1153), at 100%, 130% and 150% text.

## Tests (Windows PowerShell, from your worktree)
- First `$env:ARTIFACT_DIR` = a fresh folder `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-<branch>-<time>`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import` once; `-Action Core` (856 checks) when you touch `game/src/simulation/`, `game/src/campaign/` or `game/src/photo_rules/`.
- Non-render suites: `scripts\toolchain\win\test-suite.ps1 -Suite a,b -SkipCore` (registry `game/tests/suites.txt`, format `name|PREFIX|rank|ci-rank[|render]`).
- Render suites (marked `render`; test-suite.ps1 skips them): `scripts\toolchain\win\headless.ps1 -Action Script -Script <suite> -Prefix "<PREFIX from suites.txt>" -TimeoutSec 1700`.
- One Godot process at a time in your worktree. Register a new suite at the end of `suites.txt`.
- Name every suite and its CHECKS/FAILURES in your report. Never report green on a red suite.

## Report: once, then stop
Branch and commit SHA; files changed; per item what you found and what you changed; every player-visible text added or changed (old → new); suites run with counts; anything you could not do or that needs Pat's ruling. Then stop: do not wait for or start further work.
