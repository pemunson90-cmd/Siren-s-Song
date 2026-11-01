# Item 143: Dive-end polish: honest END DIVE, stats on every recovery screen

Goal (player): (1) In the recovery manifest, CONFIRM only reads END DIVE when it ends the dive; with the Quietus away from every recovery mouth the manifest says so and offers only HOLD (the reason in plain words, for example QUIETUS IS 400 m FROM RECOVERY). (2) The Confluence arc recovery card and the finale first-recovery screen show the same Dive time / Hull / Life support line as other dive ends.
Why now: review notes on 133 (recovery_manifest.gd:54-64, CONFIRM END DIVE replays the old route press and the dive continues; Pat 30 Oct truthful-commands ruling) and on 140 (disclosed gap: arc_card.recovered and finale first recovery show no stats line).
Class: ui
Areas: hud.recovery, arcs.ui, campaign.endings
Files: game/src/presentation/recovery_manifest.gd, game/src/presentation/arcs/arc_card.gd (recovered() stats line only), game/src/presentation/finale/finale.gd (first-recovery stats line only), game/tests/dive_end_polish_ui_tests.gd
Serial zones touched: none
Depends on: 133, 140
Protected rules touched: none

## Acceptance test (fails before, passes after)
dive_end_polish_ui_tests: manifest with Quietus away from every mouth has no END DIVE control and shows the distance reason; at a mouth CONFIRM END DIVE ends the dive. A Confluence recovery and a finale first recovery each show exactly one stats line with the sim values. Fails today on all three.

## Do not
Change recovery reach, loss rules, outcomes or ending text beyond the added line.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: control lists, test counts.

## Builder notes
Branch item/143-dive-end-polish from origin/claude/integration after 133 and 140 merge. Preferred provider: claude:sonnet then codex.
Checks before push: the minimum (RULINGS.md speed rule).
