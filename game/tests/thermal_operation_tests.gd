extends SceneTree
# Source-known ordinary voyages through authored operations, not blind player tests.
# Foundry uses an unequipped stock fleet;39 uses Quietus with a fitted flash.
# No field tools. This proves a flash-assisted policy, not globally optimal depth.
const Plan=preload("res://tests/thermal_operation_plan.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 for id in [3,39]:
  var layer=Plan.play(id,1);var wrong=Plan.play(id,2)
  var good=layer.sim;var bad=wrong.sim
  check(good.mission.thermal_band==1,"op%d authors MIDDLE layer"%id)
  check(layer.metrics.accepted and good.outcome=="won","op%d ordinary layer-band plan completes"%id)
  check(good.all_records() and good.units[0].alive and good.units[0].pos.distance_to(good.mission.extraction)<65,"op%d film physically reaches recovery"%id)
  if id==39:
   check(good.mission.recovered,"op39 recovery committed")
   var points=good.mission.sirens[1].patrol_points
   check(points.all(func(point):return points.any(func(other):return point.distance_to(other)>70)),"op39 authored circuit never skips every waypoint into procedural fallback")
   for voyage in [good,bad]:
    check(voyage.Photo.flash_left(voyage,0)==3 and voyage.mission.photo.shots.any(func(shot):return shot.key=="glass_record_39" and shot.flash and shot.usable),"op39 legal required flash photograph spends one of four charges")
  check(bad.outcome=="lost" and bad.hull<good.hull and bad.lock_seconds>good.lock_seconds,"op%d wrong band takes worse lock and loses"%id)
  check(bad.heard_frames>0 and bad.heard_by.has(1),"op%d live recovery guard hears player emissions"%id)
  for s in [good,bad]:
   check(s.silent_throughout,"op%d Quietus remains SILENT throughout"%id)
   check(s.orders.all(func(order):return order in ["select","route","depth","drone_drive","camera","frame"]),"op%d voyage uses ordinary physical orders only"%id)
   check(s.tools.values().all(func(count):return count==0),"op%d launches and remains without finite tools"%id)
   check(Sim.valid_snapshot(s.snapshot()),"op%d completed/lost save validates"%id)
  print("THERMAL OP LAYER ",JSON.stringify(layer.metrics))
  print("THERMAL OP WRONG ",JSON.stringify(wrong.metrics))
 for preset in ["standard","accessible"]:
  var bare=Plan.fleet39(preset);var equipped=Plan.fleet39(preset,true)
  var s=bare.sim;var f=equipped.sim
  check(bare.metrics.accepted and s.outcome=="won" and s.mission.recovered,"op39 %s bare physically recovers"%preset)
  check(s.silent_throughout and s.mission.launch_equipment.values().all(func(item):return str(item).is_empty() or str(item)=="standard"),"op39 %s bare stays SILENT with empty fits"%preset)
  check(s.hunt_peak>=20 or s.lock_seconds>0,"op39 %s bare meets the live recovery watch"%preset)
  check(equipped.metrics.accepted and f.outcome=="won" and f.mission.recovered,"op39 %s vector drive physically recovers"%preset)
  check(f.elapsed<s.elapsed*.8 and f.hull>=s.hull,"op39 %s equipped saves substantial time with equal or better hull"%preset)
  check(s.mission.photo.shots.map(func(shot):return [shot.key,shot.q,shot.usable])==f.mission.photo.shots.map(func(shot):return [shot.key,shot.q,shot.usable]),"op39 %s comparison returns the same required and bonus evidence"%preset)
  for voyage in [s,f]:
   check(voyage.tools.values().all(func(count):return count==0),"op39 %s comparison spends no finite tools"%preset)
   check(voyage.orders.all(func(order):return order in ["select","route","depth","camera","frame","silent"]),"op39 %s comparison uses ordinary orders"%preset)
   check(Sim.valid_snapshot(voyage.snapshot()),"op39 %s recovered comparison save validates"%preset)
  print("THERMAL OP FLEET ",JSON.stringify(bare.metrics))
  print("THERMAL OP FLEET ",JSON.stringify(equipped.metrics))
 print("THERMAL OPERATION CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
