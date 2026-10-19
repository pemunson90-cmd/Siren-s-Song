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
 print("DRONE DRIVE EXPERIMENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
