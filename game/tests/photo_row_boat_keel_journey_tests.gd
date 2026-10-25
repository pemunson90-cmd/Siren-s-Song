extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(19,"boat_keel")
 if h.depth(2) and h.go(Vector2(2030,2080)) and h.depth(1):
  if h.focus():h.study(Vector2.INF,Vector2(1880,2200),2)
 h.finish(self,"PHOTO ROW BOAT KEEL JOURNEY")
