extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var s=Sim.new();s.start(4,"disruption");assert(s.command("silent"));assert(s.command("route",{"point":Vector2(820,520)}));s.paused=false
 for n in 69:s.advance(0.1)
 var f=FileAccess.open("/workspace/Siren-s-Song-knockdown/work/knockdown/initial.bin",FileAccess.WRITE);f.store_var(s.snapshot());f.close()
 print("INITIAL ",s.elapsed," ",s.units[0]," tools=",s.tools," observed=",s.contacts);quit()
