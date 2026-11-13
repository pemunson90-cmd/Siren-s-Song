extends SceneTree
const Fleet=preload("res://tests/calder_fleet_controller.gd")
const Course=preload("res://tests/calder_trench_journey_tests.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 # Scripted route through authored water, not a discovery test: known-charts developer switch (the player rules leave this water uncharted).
 var charts_before=PlayerDive.known_water(true)
 for id in [30,31,32,33,34,35,36]:
  var s=Fleet.new();s.fleet_policy=true;s.start(id,"endurance",{"drones_aboard":false}) # the fleet controller gives drone depth orders inside start(), before a drone could be launched: drones start in the water (legacy bay opt-out)
  check(Course.run_core(s,id),"equipped physical recovery "+str(id))
  var k=("final_photo_%d"%id if id in [30,31] else "glass_record_%d"%id)+"_bonus"
  var bonus=Course.obj(s,k)
  check(bonus.captured and bonus.get("photo_craft","")=="DRONE A","drone brought the optional film home "+str(id))
  check(s.units.all(func(u):return u.alive),"whole fleet survives "+str(id))
  var result=s.mission.module_recovery.result
  check(result.get("lost",["missing"]).is_empty() and result.get("recovered_drones",[]).size()==2,"all hardware and both drones recovered "+str(id))
  if id in [32,33,35]:check(s.mission.glass_reach.retrieved,"physical material aboard departure "+str(id))
  if id in [35,36]:check(Course.obj(s,"calder_35_lift" if id==35 else "calder_36_breaker").captured,"equipped return uses local shortcut "+str(id))
  check(Fleet.valid_snapshot(s.snapshot()),"equipped final snapshot valid "+str(id))
  print("CALDER FLEET ",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," records=",s.Recon.grade(s.mission.objectives))
 PlayerDive.known_water(charts_before)
 print("CALDER FLEET JOURNEY CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
