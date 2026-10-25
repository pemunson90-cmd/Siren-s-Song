extends SceneTree
# Choir Cut: round the east side of the ballast reef for the cable detail.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(24,"bus_cable")
 if h.go(Vector2(800,2300)) and h.go(Vector2(2650,1900)) and h.go(Vector2(2690,950)) and h.go(Vector2(2280,1025)) and h.focus():
  h.study(Vector2.INF,Vector2(2690,950),2)
 h.finish(self,"PHOTO ROW BUS CABLE JOURNEY")
