extends SceneTree
# Names in the Bell: use the western S passage to inspect the berth plate.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(28,"bell_name")
 if h.go(Vector2(800,2050)) and h.go(Vector2(765,1500)) and h.go(Vector2(765,1190)) and h.go(Vector2(1035,1140)) and h.focus():
  h.study(Vector2.INF,Vector2(765,1190),2)
 h.finish(self,"PHOTO ROW BELL NAME JOURNEY")
