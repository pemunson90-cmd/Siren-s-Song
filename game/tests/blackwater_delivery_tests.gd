extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Observed=preload("res://tests/fixtures/blackwater_first_extract.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func tick(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func finish()->void:
 print("BLACKWATER DELIVERY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=Observed.make()
 check(s.has_method("blackwater_delivery_status"),"Blackwater exposes physically carried exchange delivery separately from locally retained records")
 if not s.has_method("blackwater_delivery_status"):finish();return
 # Replay the observed first-extraction condition with the measured records
 # still on A/B. This is a source-known reconstruction, not player input replay.
 s.mission.blackwater_delivery.carriers=[[],[0],[1]]
 tick(s,Sim.STEP)
 check(s.outcome.is_empty() and not s.all_records() and not s.departure_context().available,"actual15.633s record flags plus home Quietus cannot auto-win with distant buffers")
 check(s.mission.objectives.all(func(o):return o.captured) and s.blackwater_delivery_status().packets.all(func(p):return p.recorded and not p.aboard),"local field evidence survives while physical mission delivery remains incomplete")
 check(not s.command("blackwater_handoff",{"carrier":1}),"remote archive knowledge cannot transfer a physical buffer across the sector")
 var before=s.snapshot();s.blackwater_delivery_status();s.blackwater_handoff_context(1);s.salvage_sites()
 check(s.snapshot()==before,"delivery and salvage feedback are read-only")
 s.units[1].pos=s.units[0].pos+Vector2(30,0);s.units[1].vel=Vector2.ZERO;s.command("select",{"unit":1})
 check(s.command("blackwater_handoff",{"carrier":1}) and s.blackwater_delivery_status().packets[0].aboard and not s.blackwater_delivery_status().complete,"one actual local transfer puts only that carried packet aboard Quietus")
 s.units[2].pos=s.units[0].pos+Vector2(0,-30);s.units[2].vel=Vector2.ZERO;s.command("select",{"unit":2})
 var routes=s.units.map(func(u):return u.route.duplicate(true));var holds=s.units.map(func(u):return u.hold)
 check(s.command("blackwater_handoff",{"carrier":2}) and s.blackwater_delivery_status().complete and s.units.map(func(u):return u.route)==routes and s.units.map(func(u):return u.hold)==holds,"explicit local transfer finishes delivery without rewriting routes or holds")
 tick(s,Sim.STEP)
 check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"normal recovery completes only after actual exchange reaches home Quietus with valid current state")
 var solo=Sim.new();solo.start(2);solo.sirens=[];solo.units[1].alive=false;solo.units[2].alive=false
 for site in [0,1]:
  solo.units[0].pos=solo.mission.objectives[site].pos+Vector2(0,130);solo.units[0].vel=Vector2.ZERO
  check(solo.command("camera"),"Quietus-only actual fixed receiver SAMPLE remains available")
  tick(solo,2.1)
 check(solo.blackwater_delivery_status().complete and solo.all_records() and solo.mission.courier_launch>=0,"Quietus directly carries both genuine samples and REQUEST still launches the accepted glider")
 finish()
