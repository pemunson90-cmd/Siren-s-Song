extends SceneTree
# Cold Hammer: reach the deep sump opening and inspect the spindle collar.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(26,"spindle_wear")
 if h.go(Vector2(950,2200)) and h.go(Vector2(950,950)) and h.depth(2) and h.go(Vector2(1250,865)) and h.focus():
  h.study(Vector2.INF,Vector2(950,950),1)
 h.finish(self,"PHOTO ROW SPINDLE WEAR JOURNEY")
