extends SceneTree
# Spare Lung: round the north of the powered block to photograph the feed room.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(29,"feed_room")
 if h.go(Vector2(900,1800)) and h.go(Vector2(900,350)) and h.go(Vector2(1700,350)) and h.go(Vector2(2100,650)) and h.focus() and h.command("emp"):
  h.study(Vector2.INF,Vector2(1900,400),2)
 h.finish(self,"PHOTO ROW FEED ROOM JOURNEY")
