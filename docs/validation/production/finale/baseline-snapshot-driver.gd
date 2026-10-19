extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
func _initialize():
 var s=Simulation.new(); s.start(5,"disruption")
 s.command("select",{"unit":1}); s.command("route",{"point":Vector2(1160,450)})
 s.paused=false
 for n in 40: s.advance(0.1)
 var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4],"upgrade":"disruption","settings":{"music":0.3,"effects":0.8},"evidence":{"furnace":{"name":"FURNACE VENT","caption":"Original baseline evidence.","optical":"furnace"}},"active":s.snapshot()}
 var f=FileAccess.open("/tmp/sirens-accepted-baseline.var",FileAccess.WRITE); f.store_var(data); f.close()
 var store=SaveStore.new(); store.path="/tmp/sirens-accepted-baseline.save"; print("BASELINE_SAVE ",store.save(data)," objectives=",s.mission.objectives," time=",s.elapsed)
 quit()
