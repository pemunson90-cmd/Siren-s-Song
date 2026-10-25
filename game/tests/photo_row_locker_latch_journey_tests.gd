extends SceneTree
# Range Locker: approach the shallow service latch from the northern water.
const J=preload("res://tests/photo_row_journey_support.gd")
func _initialize():
 var h=J.new(21,"locker_latch")
 if h.depth(2) and h.go(Vector2(350,1500)) and h.go(Vector2(950,850)) and h.go(Vector2(950,1040)) and h.depth(1):
  h.check(h.s.camera_context().get("target",-1)==1 and h.s.camera_context().get("ready",false),"service door is the real current local work")
  if h.command("camera"):
   h.tick(8.5)
   if h.check(h.s.mission.objectives[1].captured,"real service work opens the cache door") and h.go(Vector2(1110,1170)) and h.go(Vector2(1230,1150)) and h.depth(0) and h.focus():
    h.study(Vector2.INF,Vector2(1110,1170),1)
 h.finish(self,"PHOTO ROW LOCKER LATCH JOURNEY")
