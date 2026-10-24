extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 for id in [0,2,3,4,5,8]+range(14,30):
  var sim=Sim.new();sim.start(id)
  print("SOURCE_STATE ",JSON.stringify({"op":id,"snapshot":JSON.stringify(sim.snapshot()).sha256_text()}))
 quit()
