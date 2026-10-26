extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fresh():
 var s=Sim.new();s.start(0);s.sirens=[];s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s.units[0].angle=0.0
 # This fixture tests propulsion/STOP, not collision impulses from parked hulls.
 # Leave drones alive for their own program cases, clear of the Quietus test lane.
 for id in [1,2]:s.units[id].pos.y=100.
 return s
func _initialize():
 var s=fresh();var u=s.units[0]
 s.command("route",{"point":Vector2(260,800)});s.command("queue");s.command("route",{"point":Vector2(380,800)});s.command("route",{"point":Vector2(540,800)})
 check(u.get("route_plan",[]).size()==3,"operator destinations are retained separately from compiled corners")
 check(s.command("route_edit",{"index":0,"mode":"cruise"}),"first leg can be programmed to cruise")
 check(s.command("route_edit",{"index":1,"mode":"silent","stop":true}),"second leg can be programmed silent with a full stop")
 check(s.command("route_edit",{"index":2,"mode":"cruise"}),"third leg resumes cruise")
 if not s.has_method("route_goals"):
  check(false,"route inspector exposes operator goals");finish();return
 var goals=s.route_goals();check(goals.size()==3 and goals[0].mode=="cruise" and goals[1].stop,"inspector exposes accepted segment intent")
 var snap=s.snapshot();s.advance(10);check(s.snapshot()==snap,"pause freezes program motion resources and time")
 var restored=Sim.new();check(restored.restore(snap) and restored.snapshot()==snap,"program and undo intent survive active snapshot restore")
 s.paused=false;restored.paused=false
 var silent_seen=false;var cruise_seen=false;var lowest=1000.0;var previous_speed=0.0;var physical=true;var first_transition_distance=INF
 for n in 1200:
  s.advance(1.0/60);restored.advance(1.0/60)
  if s.route_goals().size()==2:
   if not silent_seen:first_transition_distance=u.pos.distance_to(Vector2(260,800))
   silent_seen=silent_seen or u.silent
  if s.route_goals().size()==1:cruise_seen=cruise_seen or not u.silent
  if u.pos.x>365 and u.pos.x<390:lowest=minf(lowest,u.vel.length())
  physical=physical and absf(u.vel.length()-previous_speed)<=2.01;previous_speed=u.vel.length()
 check(first_transition_distance<12,"programmed propulsion does not switch at the wide autopath-corner shortcut radius")
 check(silent_seen and cruise_seen,"program executes cruise to silent to cruise without further pilot input")
 check(lowest<=2.01 and physical,"STOP reaches near-zero speed and propulsion transitions retain acceleration")
 check(s.snapshot()==restored.snapshot(),"restored program has an identical future")
 check(u.pos.distance_to(Vector2(540,800))<12 and u.vel.length()<2,"final programmed stop settles physically")
 var e=fresh();e.command("route",{"point":Vector2(300,800)});var first=e.snapshot()
 check(e.command("route_insert",{"index":0,"point":Vector2(220,800),"mode":"cruise","stop":false}),"individual point can be inserted")
 check(e.route_goals().size()==2 and e.route_goals()[0].pos==Vector2(220,800),"insert preserves following destination")
 check(e.command("route_delete",{"index":0}) and e.route_goals().size()==1,"individual point can be deleted")
 check(e.command("route_undo") and e.route_goals().size()==2,"undo restores the deletion")
 check(e.command("route_undo") and e.route_goals().size()==1,"second undo restores pre-insertion plan")
 e.command("route_edit",{"index":0,"stop":true});e.command("queue");e.command("route",{"point":Vector2(400,800)})
 check(e.route_goals()[0].stop,"appending preserves an explicitly programmed STOP regardless of global PASS")
 var before=e.snapshot();check(not e.command("route_edit",{"index":0,"mode":"warp"}) and e.snapshot()==before,"invalid propulsion leaves state untouched")
 e.mission.structures=[Rect2(300,300,200,200)];e._build_navigation();before=e.snapshot()
 check(not e.command("route_edit",{"index":0,"point":Vector2(350,350)}) and e.snapshot()==before,"unsafe edited destination is rejected atomically")
 e.command("hold");e.command("queue");e.command("emergency",{"point":Vector2(550,800)})
 check(e.units[0].hold=="" and not e.queue_mode and not e.units[0].silent and e.route_goals().size()==1 and not e.command("route_undo"),"emergency discards stale program undo and conditional hold")
 var legacy=fresh();legacy.units[0].route=[{"pos":Vector2(220,800),"stop":false},{"pos":Vector2(300,800),"stop":true}];var old=legacy.snapshot();var copy=Sim.new()
 check(copy.restore(old) and copy.snapshot()==old,"legacy active routes restore without adding or rewriting fields")
 check(copy.route_goals().size()==1 and copy.units[0].route==old.units[0].route,"legacy inspector shows final goal without mistaking navigation corners for operator goals")
 var store=Store.new();store.path="user://route-program-test.save"
 var archive={"version":1,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","active":snap}
 check(store.save(archive) and store.load_game()==archive,"actual save store round-trips program and undo without a schema migration")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
 var legacy_queued=Sim.new();legacy_queued.restore(old)
 legacy_queued.units[0].route=[{"pos":Vector2(140,600),"stop":false},{"pos":Vector2(300,600),"stop":false},{"pos":Vector2(300,800),"stop":true}]
 legacy_queued.command("queue");legacy_queued.command("route",{"point":Vector2(400,800)})
 check(legacy_queued.units[0].route.size()==4 and legacy_queued.units[0].route[0].pos==Vector2(140,600) and legacy_queued.units[0].route[1].pos==Vector2(300,600),"appending to a legacy course preserves its existing corners instead of replanning it")
 var old_store=Store.new();old_store.path="res://tests/fixtures/accepted-blackwater.archive";var earned=old_store.load_game();var actual=Sim.new()
 check(earned.is_empty() and not old_store.warning.is_empty(),"Pass0 rejects incompatible old Blackwater route archive")
 var malformed=snap.duplicate(true);malformed.units[0].route_plan[0].mode="warp";check(not Sim.valid_snapshot(malformed),"invalid optional program data is rejected")
 malformed=snap.duplicate(true);malformed.units[0].route_plan.pop_back();check(not Sim.valid_snapshot(malformed),"inconsistent optional goal/corner correspondence is rejected")
 malformed=snap.duplicate(true);malformed.units[0].route_plan[0].pos=Vector2(NAN,0);check(not Sim.valid_snapshot(malformed),"nonfinite optional goal position is rejected")
 var drone=fresh();drone.command("select",{"unit":1});drone.command("route",{"point":Vector2(400,700)});var drone_before=drone.snapshot()
 check(drone.command("route_edit",{"index":0,"mode":"silent"}) and drone.units[1].silent,"drone incoming propulsion program preserves independent visual profile")
 drone.command("silent");check(Sim.valid_snapshot(drone.snapshot()) and drone.route_goals()[0].mode=="silent" and not drone.units[1].silent,"manual visual profile preserves accepted drone propulsion program")
 var bad_drone=drone_before.duplicate(true);bad_drone.units[1].route_plan[0].mode="warp"
 for node in bad_drone.units[1].route:node.mode="warp"
 check(not Sim.valid_snapshot(bad_drone),"malformed explicit drone propulsion programs are rejected")
 var terrain=fresh();terrain.mission.structures=[Rect2(300,600,160,220)];terrain._build_navigation();terrain.command("route",{"point":Vector2(560,800)})
 check(terrain.route_goals().size()==1 and terrain.units[0].route.size()>1,"one operator destination can compile through multiple avoidance corners")
 terrain.command("route_edit",{"index":0,"mode":"cruise"});terrain.paused=false;var safe=true
 for n in 1800:terrain.advance(1.0/60);safe=safe and not terrain.blocked(terrain.units[0].pos,12)
 check(safe and terrain.units[0].pos.distance_to(Vector2(560,800))<20,"programmed terrain path preserves physical collision clearance")
 var conditional=fresh();conditional.command("route",{"point":Vector2(400,800)});conditional.command("route_edit",{"index":0,"mode":"cruise"});conditional.command("wait_drone");conditional.command("select",{"unit":1});conditional.command("route",{"point":Vector2(200,700)});conditional.command("select",{"unit":0});conditional.paused=false;conditional.advance(0.1)
 check(conditional.units[0].pos==Vector2(140,800) and conditional.route_goals().size()==1,"WAIT DRONE retains programmed goal while holding")
 finish()
func finish():
 print("ROUTE PROGRAM CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
