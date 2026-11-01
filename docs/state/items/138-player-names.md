# Item 138: No internal ids or codenames on player screens

Goal (player): Run summaries, expedition screens and records name operations, regions and craft the way briefings do; no snake_case ids, codenames or internal headings.
Why now: Critic 123 C47 (run_summary_view.gd:8, run_records.gd:71, expedition_session.gd:76), verified medium; recheck which strings still leak before changing anything.
Class: text
Areas: economy, runs.ui
Files: game/src/presentation/runs/**, game/src/presentation/tool_racks_view.gd (display names only, D34), game/src/campaign/runs/**, game/tests/player_names_tests.gd
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
player_names_tests: render every run summary and expedition label for all ops; none matches an internal id pattern (lowercase with underscores, or a known codename list taken from the source).

## Do not
Rename save keys or ids; only the displayed text changes. Story text stays 1-2 line placeholders, no em dashes.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
text: list of strings changed (before -> after), test counts.

## Builder notes
Branch item/138-player-names from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
