extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(7,"tender_door",1)
 var travelled=h.depth(2)
 for point in [Vector2(1150,2050),Vector2(950,1850),Vector2(950,1550),Vector2(750,1250),Vector2(750,950),Vector2(900,610),Vector2(780,610)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(1):
  if h.focus() and h.command("emp"):h.study(Vector2.INF,Vector2(900,610),2)
 h.finish(self,"PHOTO ROW TENDER DOOR JOURNEY")
