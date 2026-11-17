extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(8,"relay_blink",0,"disruption")
 var travelled=h.depth(2)
 for point in [Vector2(2050,650),Vector2(1950,750),Vector2(1750,850),Vector2(1750,1050),Vector2(1750,1150),Vector2(1550,1350),Vector2(1250,1650),Vector2(1190,1680)]:
  if travelled:travelled=h.go(point)
 # Let the hunter lose the deep approach before exposing Quietus in MIDDLE.
 if travelled:h.tick(14.0)
 if travelled and h.depth(1):
  if h.focus():
   h.study_supported(Vector2(900,1700),[{"at":7.0,"action":"emp"},{"at":17.5,"action":"emp"},{"at":28.5,"action":"emp"}])
 h.finish(self,"PHOTO ROW RELAY BLINK JOURNEY")
