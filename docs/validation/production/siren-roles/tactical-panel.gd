extends SceneTree
func report(label,s):
 print(label," outcome=",s.outcome," time=",snappedf(s.elapsed,0.1)," hull=",snappedf(s.hull,0.1)," tools=",s.tools," drones=",s.units[1].alive,",",s.units[2].alive," records=",s.mission.objectives.filter(func(o):return o.captured).size())
func _initialize():
 for withdrawal in ["exposed","diagonal","queued"]:report("FOUNDRY withdrawal="+withdrawal,preload("res://tests/foundry_command_plan.gd").play(true,"complete",true,withdrawal))
 for diversion in [false,true]:
  for cruise in [false,true]:report("WELL diversion="+str(diversion)+" cruise="+str(cruise),preload("res://tests/listening_well_command_plan.gd").play(diversion,cruise))
 for coordinated in [false,true]:
  for protected in [false,true]:report("FINALE coordinated="+str(coordinated)+" protection="+str(protected),preload("res://tests/finale_command_plan.gd").play(coordinated,"complete",protected))
 quit()
