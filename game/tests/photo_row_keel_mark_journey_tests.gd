extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(18,"keel_mark")
 var travelled=h.depth(2)
 for point in [Vector2(2350,1750),Vector2(2550,1450),Vector2(2350,1350),Vector2(2050,1350),Vector2(1750,1250),Vector2(1670,1220)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(1) and h.depth(0):
  if h.focus():h.study(Vector2.INF,Vector2(1550,1350),1)
 h.finish(self,"PHOTO ROW KEEL MARK JOURNEY")
