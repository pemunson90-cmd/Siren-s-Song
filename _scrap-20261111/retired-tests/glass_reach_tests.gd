extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var shapes=[]
 for id in range(14,22):
  var definition=Catalog.definition(id)
  check(not definition.is_empty(),"authored Glass Reach identity "+str(id))
  if definition.is_empty():continue
  var s=Sim.new();s.start(id)
  check(s.mission.id==id and not s.mission.objectives.is_empty() and s.mission.world_size.x>=2000,"real playable Glass Reach operation "+str(id))
  check(Sim.valid_snapshot(s.snapshot()),"new operation initial depth/network/custody snapshot "+str(id))
  var restored=Sim.new();check(restored.restore(s.snapshot()),"new operation restores "+str(id))
  check(s.sirens.all(func(e):return s.Depth.clear(s,e.pos,e.pos,e.band,16)),"authored network and guards occupy real open water "+str(id))
  shapes.append(var_to_str(s.mission.rocks))
 check(shapes.size()==8 and shapes.count(shapes[0])==1 if not shapes.is_empty() else false,"eight separately authored physical topologies")
 check(Catalog.prerequisites_met(14,[12]) and Catalog.prerequisites_met(14,[13]) and not Catalog.prerequisites_met(14,[11]),"region follows either received old outcome")
 print("GLASS REACH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
