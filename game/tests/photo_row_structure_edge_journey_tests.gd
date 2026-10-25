extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(11,"structure_edge")
 var travelled=h.depth(2)
 for point in [Vector2(550,3750),Vector2(750,3350),Vector2(750,2850),Vector2(650,2450),Vector2(650,2050),Vector2(1050,1650),Vector2(1050,1450),Vector2(1450,1050),Vector2(1850,950),Vector2(2050,1150),Vector2(2150,1450),Vector2(2450,1750),Vector2(2550,2050),Vector2(2550,2350),Vector2(3000,2810)]:
  if travelled:travelled=h.go(point)
 if travelled:
  if h.focus():h.study(Vector2.INF,Vector2(2860,2920),1)
 h.finish(self,"PHOTO ROW STRUCTURE EDGE JOURNEY")
