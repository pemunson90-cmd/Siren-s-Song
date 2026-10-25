extends SceneTree
# Counterweight Grave: take the slide score from water above the toppled block.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(27,"slide_mark")
 if h.depth(2) and h.go(Vector2(750,2050)) and h.go(Vector2(750,900)) and h.depth(1) and h.go(Vector2(1170,935)) and h.focus():
  h.study(Vector2.INF,Vector2(750,900),2)
 h.finish(self,"PHOTO ROW SLIDE MARK JOURNEY")
