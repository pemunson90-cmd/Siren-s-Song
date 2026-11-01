# Item 142: Launching never replaces an active dive without asking

Goal (player): With a dive in progress, pressing the briefing launch control (BEGIN, or DIVE PAUSED on compact briefings) for any operation first asks: ABANDON the current dive (names it, with time, hull and life support) or KEEP IT. KEEP returns to the briefing with the dive untouched and RESUME DIVE still works; ABANDON ends it exactly as abandoning does today, then launches. With no dive in progress, launch works as today.
Why now: progress-loss risk. Critic C2-027 (after a normal restore, DIVE PAUSED replaced the active dive with no warning) and Critic 123 C30 (retry abandoned an attempt with no summary). Cause: campaign_flow.gd:132-135, the begin button calls EconomyPanel.begin(host,index) with no active-dive check.
Class: ui
Areas: campaign.flow
Files: game/src/presentation/flow/campaign_flow.gd (briefing begin button only), game/tests/launch_guard_ui_tests.gd, launch-guard answers only in existing fixtures: game/tests/campaign_ui_scenarios.gd, game/tests/campaign_instruments_ui_tests.gd, game/tests/loadout_ui_tests.gd, game/tests/save2_ui_tests.gd, game/tests/briefing_scroll_fitting_ui_tests.gd
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
launch_guard_ui_tests: start op A and dive; open op B briefing (and op A briefing) and press the launch control: a confirm appears naming op A; KEEP leaves sim state, elapsed time and RESUME DIVE unchanged; ABANDON then launches B with the same economy and save result as today. Also after a save restore (the C2-027 path). With no active dive, launch starts at once. Fails today (the active dive is replaced).

## Do not
Change economy, costs, saves, retry rules or what abandoning records. Add a confirm when no dive is active.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: control lists for the confirm, test counts.

## Builder notes
Branch item/142-launch-guard from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: the minimum (RULINGS.md speed rule).
