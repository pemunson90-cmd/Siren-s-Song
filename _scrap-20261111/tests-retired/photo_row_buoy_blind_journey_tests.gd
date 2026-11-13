extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(14,"buoy_blind")
 var travelled=h.depth(2)
 for point in [Vector2(650,1650),Vector2(850,1450),Vector2(1150,1450),Vector2(1350,1250),Vector2(1570,1060)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(1):
  # The first carried pulse covers the depth crossing. Spend the second during
  # the real exposure so the buoy stays disrupted through the deep withdrawal.
  if h.focus() and h.command("emp"):h.study_supported(Vector2(1150,1450),[{"at":0.,"action":"emp"}],2)
 h.finish(self,"PHOTO ROW BUOY BLIND JOURNEY")
