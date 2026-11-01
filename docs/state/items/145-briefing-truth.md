# Item 145: Briefing and onboarding text matches the game

Goal (player): What the opening briefing and onboarding tell you is true in play: the PAUSE hint names where PAUSE actually is, and op 0 describes the sweeper the way it actually behaves, so a new player is not taught wrong rules in the first minutes.
Why now: Critic 123 C34 (verified high). onboarding_text.gd:18 says PAUSE is always at top left; the critic found it at top right. shelf_signal_operation.gd:17 describes a locally heard winding tone, a sweep and a delayed strike at the old return; the critic reports this conflicts with the current sweeper role.
Class: text
Areas: campaign.text
Files: game/src/campaign/onboarding_text.gd (strings only), game/src/campaign/shelf_signal_operation.gd (m.brief and m.depth_hint strings only), game/tests/briefing_truth_tests.gd
Serial zones touched: none
Depends on: none
Protected rules touched: none (the sweeper, PR70, is read to describe it and never changed; pause placement is read from layout and never moved)

## Acceptance test (fails before, passes after)
briefing_truth_tests: lay out the mission HUD at both phone shapes and assert the PAUSE hint names the corner the pause button actually occupies; assert each sweeper behaviour the op 0 brief names exists in the sweeper code path (derive the expected words from the sweeper role table, not a copy of the new text). Fails today on the pause corner, and on the sweeper wording if the critic is right; if the sweeper text is already true, say so on the RED BEFORE line and change only what is false.

## Do not
Change the sweeper, pause placement, layout or any rule. Lengthen the briefing; story text stays short, no em dashes.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
text: string diff before -> after with the line of code each new claim rests on; test counts.

## Builder notes
Branch item/145-briefing-truth from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: the minimum (RULINGS.md speed rule).
