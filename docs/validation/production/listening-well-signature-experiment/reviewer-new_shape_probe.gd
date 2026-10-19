extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var s=Sim.new();s.start(4);s.mission.objectives[0].captured=true
 var data=s.snapshot();data.mission.objectives.resize(2)
 var resumed=Sim.new();print("TRUNCATED_OBJECTIVES accepted=",Sim.valid_snapshot(data)," restored=",resumed.restore(data))
 resumed.units[0].pos=Vector2(1190,450);resumed.units[0].vel=Vector2(65,0);resumed.units[0].silent=false
 resumed.paused=false;resumed.advance(1.0/60);print("POST_ADVANCE reference=",resumed.mission.well_reference)
 quit()
