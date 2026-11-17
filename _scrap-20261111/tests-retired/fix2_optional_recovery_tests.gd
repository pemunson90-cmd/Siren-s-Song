extends "res://tests/shelf_habitat_journey_tests.gd"
# A real bare-Quietus recovery, then an untouched optional photo in that save.
func _initialize()->void:
 var common=run_method(true)
 check(Sim.valid_snapshot(common.snapshot()),"the ordinary recovered shelter snapshot validates")
 common.mission.objectives.append({"pos":Vector2(1350,1680),"name":"OPTIONAL RELAY FRAME","captured":false,"optional":true,"kind":"","subject":preload("res://src/simulation/photo_capture.gd").default_subject()})
 check(Sim.valid_snapshot(common.snapshot()),"a recovered dive remains savable with an unphotographed optional subject")
 var previous={"version":1,"route":"shelf","routes":["shelf"],"facts":{"shelf":"carrier"},"completed":[6]}
 var p=Campaign.recover(previous,common.mission)
 check(8 in p.completed and 10 in Campaign.available([0,1,2,3,4,5],p) and "drone_sampler" in p.get("entitlements",[]),"an optional frame never erases the earned sampler or next operation")
 var malformed=common.mission.duplicate(true);malformed.objectives[0].captured=false
 check(not common.SignalField.valid(malformed,common.elapsed),"an incomplete mandatory shelter record still rejects recovered state")
 var rejected=Campaign.recover(previous,malformed)
 check(8 not in rejected.completed and "drone_sampler" not in rejected.get("entitlements",[]),"an unfinished mandatory job grants neither progression nor reward")
 print("FIX2 OPTIONAL RECOVERY CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
