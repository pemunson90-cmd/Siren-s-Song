extends SceneTree
# Pressure Stair: study the shutter lamps from the first lower landing.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(23,"shutter_order")
 if h.go(Vector2(570,1940)) and h.focus():
  h.tick(10.0)
  h.study(Vector2.INF,Vector2(440,2050),2)
 h.finish(self,"PHOTO ROW SHUTTER ORDER JOURNEY")
