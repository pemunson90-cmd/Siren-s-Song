extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(14,"buoy_blind")
 var travelled=h.depth(2)
 for point in [Vector2(650,1650),Vector2(850,1450),Vector2(1150,1450),Vector2(1350,1250),Vector2(1550,1050)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(1):
  if h.focus():h.study(Vector2.INF,Vector2(1380,1120),2)
 h.finish(self,"PHOTO ROW BUOY BLIND JOURNEY")
