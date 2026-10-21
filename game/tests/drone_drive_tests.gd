extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func ticks(s,count):
 s.paused=false
 for n in count:s.advance(1.0/60)
func _initialize():
 var s=Sim.new();s.start(0);s.command("select",{"unit":1});s.command("route",{"point":Vector2(400,700)})
 var old=s.snapshot();check(not old.units[1].has("drone_drive"),"ordinary legacy-compatible drone setup adds no drive state")
 var restored=Sim.new();check(restored.restore(old) and restored.snapshot()==old,"ordinary old snapshot stays field-exact")
 check(s.command("route_edit",{"index":0,"mode":"silent"}),"incoming drone goal accepts quiet propulsion")
 var paused=s.snapshot();s.advance(1);check(s.snapshot()==paused,"pause freezes accepted incoming drive")
 ticks(s,180);var u=s.units[1]
 check(u.get("drone_drive","")=="quiet" and u.vel.length()<=42.01 and u.vel.length()>40,"quiet leg uses physically accelerated42m/s thrust")
 check(u.silent,"quiet propulsion leaves LOW PROFILE unchanged")
 s.command("silent");ticks(s,6)
 check(not u.silent and u.vel.length()<=42.01 and u.get("drone_drive","")=="quiet","OPEN PROFILE cannot silently change propulsion")
 s.paused=true;var snap=s.snapshot();var copy=Sim.new();check(copy.restore(snap) and copy.snapshot()==snap,"explicit optional drive and goal survive snapshot restore")
 ticks(s,30);ticks(copy,30);check(s.snapshot()==copy.snapshot(),"restored drive has identical future movement and hearing")
 var before=s.snapshot();check(not s.command("drone_drive",{"mode":"warp"}) and s.snapshot()==before,"invalid drive order is atomic")
 check(s.command("drone_drive",{"mode":"transit"}) and not u.silent and s.route_goals()[0].mode=="cruise","direct drive changes accepted current-leg metadata without changing profile")
 var previous=u.vel.length();ticks(s,1);check(u.vel.length()>previous and u.vel.length()<96,"transit accelerates rather than jumping to96")
 s.command("drone_drive",{"mode":"quiet"});s.command("emergency",{"point":Vector2(400,750)})
 check(u.get("drone_drive","")=="transit","emergency replacement restores full drone thrust")
 var bad=s.snapshot();bad.units[1].drone_drive="warp";check(not Sim.valid_snapshot(bad),"malformed optional drive cannot restore")
 var legacy=Sim.new();legacy.restore(old);ticks(legacy,90)
 check(legacy.units[1].vel.length()>42.01 and not legacy.units[1].has("drone_drive"),"untouched inherited low-profile drone keeps legacy transit thrust without new state")
 var store=load("res://src/persistence/save_store.gd").new();store.path="user://drone-drive-test.save"
 var archive={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","active":s.snapshot()}
 check(store.save(archive) and store.load_game()==archive,"actual atomic save store retains optional drive without schema migration")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
 var p=Sim.new();p.start(0);p.command("select",{"unit":1});p.command("route",{"point":Vector2(300,700)});p.command("queue");p.command("route",{"point":Vector2(700,800)})
 check(p.command("route_edit",{"index":0,"mode":"silent","stop":true}) and p.command("route_edit",{"index":1,"mode":"cruise"}),"queued drone program accepts distinct incoming drives and stop")
 var goals=p.route_goals();p.command("route_edit",{"index":1,"mode":"silent"});p.command("route_undo")
 check(p.route_goals()==goals,"undo preserves both incoming drive intentions")
 p.command("drone_drive",{"mode":"quiet"});check(p.route_goals()[1]==goals[1],"direct current-leg override preserves later incoming drive metadata")
 var quiet_seen=false;var fast_seen=false;var profile_stayed=true;var stopped=false
 p.paused=false
 for n in 1200:
  p.advance(1./60);var own=p.units[1]
  quiet_seen=quiet_seen or own.get("drone_drive","")=="quiet"
  fast_seen=fast_seen or (own.get("drone_drive","")=="transit" and own.vel.length()>42.1)
  stopped=stopped or (own.pos.distance_to(Vector2(300,700))<12 and own.vel.length()<2)
  profile_stayed=profile_stayed and own.silent
 check(quiet_seen and fast_seen and stopped and profile_stayed,"queued quiet stop then fast leg execute physically without changing profile")
 var wall=Sim.new();wall.start(0);wall.mission.rocks=[];wall.mission.structures=[Rect2(300,300,200,200)];wall.sirens=[];wall._build_navigation()
 wall.units[1].pos=Vector2(520,460);wall.units[1].angle=PI;wall.command("select",{"unit":1})
 check(wall.command("route",{"point":Vector2(520,250)}) and wall.command("route_edit",{"index":0,"mode":"silent"}) and wall.units[1].route[0].stop,"quiet drone retains native near-wall recovery STOP")
 var at_wall=wall.snapshot();var restored_wall=Sim.new();check(restored_wall.restore(at_wall) and restored_wall.snapshot()==at_wall,"near-wall programmed drive restores exactly")
 wall.paused=false;restored_wall.paused=false;var clear=true
 for n in 1200:
  wall.advance(1./60);restored_wall.advance(1./60);clear=clear and not wall.blocked(wall.units[1].pos,12)
 check(clear and wall.units[1].pos.distance_to(Vector2(520,250))<12 and wall.snapshot()==restored_wall.snapshot(),"restored quiet near-wall turn retains clearance and identical future")
 print("DRONE DRIVE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
