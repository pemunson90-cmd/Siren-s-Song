extends SceneTree
const MODULE="res://src/campaign/blind_passage_mission.gd"
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize()->void:
 check(ResourceLoader.exists(MODULE),"Blind Passage authored geometry exists")
 if failures:finish();return
 var content=load(MODULE)
 var history={"thread":"deep","completed":[12],"facts":{"confluence_route":"concealed","resolution":"concealed_recovery"}}
 # Static geometry fixture only. Production registry/delivery/chart hooks are
 # not installed here and no earned-chart/extraction claim is made.
 var s=Sim.new();s.start(0);s.mission=content.make(14,history);s.sirens=s.mission.sirens.duplicate(true);s._build_navigation()
 var seed:Rect2=s.mission.launch_seed
 var seed_clear=true
 for y in range(int(seed.position.y),int(seed.end.y),40):
  for x in range(int(seed.position.x),int(seed.end.x),40):
   if s.blocked(Vector2(x+20,y+20),sqrt(800.)+24):seed_clear=false
 check(seed_clear,"every launch seed cell plus conservative craft clearance is physically empty water")
 for offset in [Vector2.ZERO,Vector2(0,-100),Vector2(140,0)]:
  var p=s.mission.start+offset
  check(seed.encloses(Rect2(p-Vector2.ONE*24,Vector2.ONE*48)) and not s.blocked(p,24),"each actual deployed craft fits inside the clear chart seed")
 check(not s.blocked(s.mission.handoff_pos,65),"handoff has sufficient clear water for settled physical arrival")
 check(not s.line_clear(Vector2(500,1860),Vector2(500,1000)),"tempting northern inlet contains real unknown cover rather than an instruction flag")
 var routes={"western":[Vector2(140,2100),Vector2(140,1120),Vector2(140,280),s.mission.handoff_pos],"crossing":[Vector2(500,1860),Vector2(600,1680),Vector2(1480,1680),Vector2(1480,620),s.mission.handoff_pos],"eastern":[Vector2(2260,2700),Vector2(2260,1840),Vector2(2260,1120),Vector2(1480,1120),Vector2(1480,620),s.mission.handoff_pos]}
 var lengths={}
 for name in routes:
  var origin:Vector2=s.mission.start;var distance=0.;var clear=true
  for point in routes[name]:
   if not s.segment_safe(origin,point,24):clear=false
   var path=s.path(origin,point)
   if path.is_empty():clear=false
   for node in path:distance+=origin.distance_to(node.pos);origin=node.pos
  lengths[name]=distance
  check(clear,"authored %s route has continuous genuine hull clearance"%name)
 check(lengths.western-lengths.crossing>500 and lengths.eastern-lengths.crossing>500,"offset passage is a substantial real traversal choice against two longer alternatives")
 for p in [Vector2(140,1400),Vector2(1480,1660),Vector2(1480,1120),Vector2(2260,1640)]:
  check(not s.blocked(p,80),"key passages offer broad braking/turning water beyond chart cell clearance")
 for siren in s.sirens:
  check(not s.blocked(siren.pos,24) and siren.patrol_points.all(func(p):return not s.blocked(p,24)),"ordinary patrol points stay in real traversable water")
 print("PHYSICAL CHART-KNOWN ROUTE LENGTHS ",lengths," (static full-geometry fixture; not earned-chart behavior)")
 finish()
func finish()->void:
 print("BLIND PASSAGE GEOMETRY CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
