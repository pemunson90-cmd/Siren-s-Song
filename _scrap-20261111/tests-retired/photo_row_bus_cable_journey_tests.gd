extends SceneTree
# Choir Cut: use deep water below the ballast reef, then rise at its east side.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(24,"bus_cable")
 if h.depth(2) and h.go(Vector2(300,2450)) and h.go(Vector2(2700,2450)) and h.go(Vector2(2700,950)) and h.go(Vector2(2280,1045)) and h.depth(1) and h.focus():
  h.study(Vector2.INF,Vector2(2690,950),2)
 h.finish(self,"PHOTO ROW BUS CABLE JOURNEY")
