extends "res://tests/opening_depth_policy_ui_tests.gd"
# CI execution partition: inherit every operation, touch order and assertion.
# Both display groups retain the original 480-second suite timeout.
func display_shapes():return [Vector2i(2520,1080)]
# Openings 3 to 5 fly authored water the player rules leave uncharted; these journeys are about the touch input, not discovery, so they use the developer known-charts switch.
func run():
 var charts_before=PlayerDive.known_water(true)
 await super.run()
 PlayerDive.known_water(charts_before)
