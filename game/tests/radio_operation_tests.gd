extends SceneTree
const Plan=preload("res://tests/radio_operation_plan.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 for id in [31,33]:
  var before=Plan.play(id,"straight","standard",true)
  var after=Plan.play(id,"straight")
  var bare=Plan.play(id,"interrupt")
  var equipped=Plan.play(id,"equipped")
  check(after.metrics.sent>0 and after.metrics.received_frames>0,"op%d direct plan completes a received report"%id)
  check(after.metrics.quietus_lock_total>before.metrics.quietus_lock_total+1.,"op%d report alone adds a consequential peer lock"%id)
  check(bare.metrics.interrupted and bare.metrics.sent==0,"op%d bare quiet break cancels the observed charge"%id)
  check(bare.metrics.quietus_lock_total<after.metrics.quietus_lock_total,"op%d quiet break reduces lock exposure"%id)
  check(equipped.metrics.interrupted and equipped.metrics.time<bare.metrics.time and equipped.metrics.hull>=bare.metrics.hull,"op%d finite Disrupt saves time with equal or better hull"%id)
  for result in [before,after,bare,equipped]:
   var s=result.sim;var row=result.metrics
   var lethal_return=id==33 and is_same(result,after)
   if lethal_return:
    check(s.outcome=="lost" and s.hull<before.sim.hull,"op33 completed report makes the full return fail")
    check(s.mission.objectives.filter(func(o):return not o.get("optional",false)).all(func(o):return o.captured) and s.mission.glass_reach.artifact.state=="cargo" and s.mission.glass_reach.artifact.carrier==0,"op33 lethal return carries the physically earned film and material")
   else:
    check(row.accepted and s.outcome=="won" and s.mission.recovered,"op%d %s physically recovers required film"%[id,row.policy])
    check(s.all_records() and s.units[0].alive,"op%d %s completes the full return"%[id,row.policy])
   check(row.silent,"op%d %s stays SILENT throughout"%[id,row.policy])
   check(s.orders.all(func(order):return order in ["select","route","depth","camera","frame","emp","glass_action"]),"op%d %s uses ordinary orders"%[id,row.policy])
   check(Sim.valid_snapshot(s.snapshot()),"op%d %s current snapshot validates"%[id,row.policy])
   if row.policy!="equipped":check(s.tools.values().all(func(count):return count==0),"op%d bare has no field tools"%id)
   print("RADIO OP ",JSON.stringify(row))
 print("RADIO OPERATION CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
