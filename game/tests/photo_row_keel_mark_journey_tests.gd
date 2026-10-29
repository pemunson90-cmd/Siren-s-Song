extends SceneTree
const J=preload("res://tests/glass_fleet_photo_support.gd")
func _initialize():
 var h=J.new(18,"keel_mark")
 var travelled=true
 # Replan through surveyed water and enter the service work lane from the south.
 for point in [Vector2(2650,1900),Vector2(2650,1150),Vector2(1400,1200),Vector2(1345,1100),Vector2(1400,935),Vector2(1400,1300),Vector2(1702,1278)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(1) and h.depth(0):
  if h.focus():h.study(Vector2.INF,Vector2(1550,1350),1)
 h.finish(self,"PHOTO ROW KEEL MARK JOURNEY")
