extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(8,"relay_blink")
 var travelled=h.depth(2)
 for point in [Vector2(2050,650),Vector2(1750,950),Vector2(1750,1150),Vector2(1550,1350),Vector2(1250,1650),Vector2(1190,1680)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(1):
  if h.focus():h.study(Vector2.INF,Vector2(1060,1810),2)
 h.finish(self,"PHOTO ROW RELAY BLINK JOURNEY")
