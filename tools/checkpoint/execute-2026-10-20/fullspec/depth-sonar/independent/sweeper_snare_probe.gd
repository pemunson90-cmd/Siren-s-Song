extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var s=Sim.new();s.start(4)
 s.units[0].pos=Vector2(1280,820);s.units[0].band=2;s.units[0].angle=0
 s.units[1].alive=false;s.units[2].alive=false
 s.sirens=s.sirens.filter(func(e):return e.type=="sweeper")
 s.command("select",{"unit":0});s.contacts={};s._observe()
 print("target=",s.knockdown_targets()," launch=",s.command("knock",{"target":0}))
 s.paused=false
 for n in 120:s.advance(Sim.STEP)
 s.paused=true
 print("after2s pin=",s.sirens[0].get("pin_time",-1)," stun=",s.sirens[0].stun," mode=",s.sirens[0].mode," valid=",Sim.valid_snapshot(s.snapshot())," projectiles=",s.projectiles.size())
 s.paused=false
 for n in 600:s.advance(Sim.STEP)
 s.paused=true
 print("after12s pin=",s.sirens[0].get("pin_time",-1)," stun=",s.sirens[0].stun," mode=",s.sirens[0].mode," valid=",Sim.valid_snapshot(s.snapshot()))
 quit()
