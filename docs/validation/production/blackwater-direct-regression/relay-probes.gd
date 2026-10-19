extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var failures=0
func check(ok,label):
 if not ok:failures+=1
 print("HUNT_CORE ","PASS " if ok else "FAIL ",label)
func tick(s,seconds):
 for n in int(round(seconds*60)):s.advance(1.0/60)
func make(distance=210.0):
 var s=Sim.new();s.start(2)
 # Isolate receiver timing from unrelated enemy motion for archive/geometry probes.
 for enemy in s.sirens:enemy.stun=100
 s.units[0].pos=s.mission.objectives[0].pos+Vector2(0,distance)
 return s
func _initialize():
 var s=make();var resources=s.tools.duplicate()
 check(s.command("ping"),"ordinary initial SONAR accepted")
 var until=s.mission.objectives[0].replay_until
 s.command("camera");s.paused=false;tick(s,0.9);s.paused=true
 var data=s.snapshot();var r=Sim.new();check(r.restore(bytes_to_var(var_to_bytes(data))),"actual binary snapshot restores active standoff reception")
 check(r.paused and r.mission.objectives[0].replay_until==until and is_equal_approx(r.capture_time,s.capture_time),"restore preserves remaining replay and sample progress")
 var before=r.snapshot();r.advance(1000);check(r.snapshot()==before,"long tactical pause consumes no replay/sample/resources")
 r.paused=false;tick(r,1.1);check(r.mission.objectives[0].captured and r.tools==resources,"restored settled2s sample succeeds without tool inventory changes")
 s=make();s.units[0].pos=s.mission.objectives[0].pos+Vector2(0,240)
 s.command("ping");check(s.mission.objectives[0].replay_until==0 and not s.command("camera"),"exact240m boundary cannot replay or passively sample")
 s=make(239.9);s.command("ping");check(s.mission.objectives[0].replay_until==3 and s.command("camera"),"just-inside240m clear local SONAR opens replay")
 s.paused=false;tick(s,0.9);s.units[0].vel=Vector2(20,0);tick(s,0.1);check(s.capture_time==0,"renewed motion discards partial two-second accumulation")
 s=make();s.command("ping");s.paused=false;tick(s,3.1);s.paused=true
 var restored=Sim.new();check(restored.restore(s.snapshot()) and not restored.command("camera"),"expired replay remains expired on restore")
 s=make();s.command("ping");s.mission.rocks.append(Rect2(735,250,60,20));s._build_navigation()
 check(not s.blackwater_context(0).ready and not s.command("camera"),"new current cover cannot reuse previously earned replay")
 s=make();var hidden=s.snapshot();s.blackwater_context(0);s.camera_context();check(s.snapshot()==hidden,"readiness/context queries remain read-only")
 s=make();s.command("ping");s.units[0].alive=false
 check(not s.blackwater_context(0).ready and not s.command("camera"),"dead receiver cannot reuse replay")
 var fixture=Store.new();fixture.path="res://tests/fixtures/accepted-blackwater.archive";var old=fixture.load_game();var legacy=Sim.new()
 check(not old.is_empty() and legacy.restore(old.active),"actual legacy archive loads without new revision")
 legacy.paused=false;tick(legacy,2.05);check(not legacy.mission.objectives[0].captured,"actual legacy1s-progress exposure still needs4s total")
 tick(legacy,1.1);check(legacy.mission.objectives[0].captured and not legacy.mission.has("blackwater_revision"),"actual legacy exposure completes at original rule with no migration")
 print("HUNT_CORE failures=",failures);quit(1 if failures else 0)
