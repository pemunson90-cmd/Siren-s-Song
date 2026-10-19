extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var s=Sim.new();s.start(4,"disruption");assert(s.command("silent"));assert(s.command("route",{"point":Vector2(820,520)}));s.paused=false
 for n in 69:s.advance(0.1)
 var f=FileAccess.open("/workspace/Siren-s-Song-gauntlet/work/navigation-emergency-experience/clip-initial.bin",FileAccess.WRITE);f.store_var(s.snapshot());f.close()
 print("CLIP_START time=",s.elapsed," pos=",s.units[0].pos," vel=",s.units[0].vel," contacts=",s.contacts," hull=",s.hull," tools=",s.tools)
 for n in 10:s.advance(0.1)
 print("EMERGENCY_MOMENT time=",s.elapsed," pos=",s.units[0].pos," vel=",s.units[0].vel," contacts=",s.contacts)
 quit()
