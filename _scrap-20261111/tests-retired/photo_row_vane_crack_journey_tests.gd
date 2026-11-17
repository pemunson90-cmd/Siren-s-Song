extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(15,"vane_crack")
 if h.depth(2) and h.go(Vector2(940,2380)) and h.depth(1):
  if h.focus():h.study(Vector2.INF,Vector2(1000,2550),2)
 h.finish(self,"PHOTO ROW VANE CRACK JOURNEY")
