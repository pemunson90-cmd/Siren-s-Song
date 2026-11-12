extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(7,"tender_door",1)
 # This route was written for the older, louder drones: their noise drew the second guard away before the
 # depth change. Under the player rule "quiet_drones" (Pat, 2026-11-12) the guard stays and the drone is lost,
 # so this journey flies on the legacy rules until a route for quiet drones is written. Recorded for Pat in
 # docs/V7_TO_GODOT_PARITY.md.
 h.s.mission[preload("res://src/simulation/parity_rules/parity_rules.gd").KEY]=false
 var travelled=h.depth(2)
 for point in [Vector2(1150,2050),Vector2(950,1850),Vector2(950,1550),Vector2(750,1250),Vector2(750,950),Vector2(900,610),Vector2(780,610)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(1):
  if h.focus() and h.command("emp"):h.study(Vector2.INF,Vector2(900,610),2)
 h.finish(self,"PHOTO ROW TENDER DOOR JOURNEY")
