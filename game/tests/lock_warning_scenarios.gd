extends RefCounted
const Warning=preload("res://src/presentation/lock_warning.gd")
const Sim=preload("res://src/simulation/simulation.gd")
static func run(t):
 var sim=Sim.new();sim.start(0);sim.elapsed=10.
 var c={"pos":sim.units[0].pos+Vector2(80,0),"time":10.,"mode":"LOCKING","lock":.01,"target":0}
 sim.contacts={0:c}
 var w=Warning.new()
 w.update_state(sim,true)
 t.check(w.visible and w.locks[0].remaining>3.9,"first lock observation starts the countdown")
 c.lock=3.9;w.update_state(sim,true)
 t.check(w.locks[0].remaining<.11 and w.episodes==1,"countdown advances without consuming extra hint episodes")
 for target in [-1,1,2]:
  c.target=target;t.check(Warning.frames(sim).is_empty(),"only a lock on Quietus starts the lethal warning")
 c.target=0;c.mode="BEAM"
 t.check(Warning.frames(sim).is_empty(),"firing stops the lock countdown")
 c.mode="LOCKING";c.time=9.
 t.check(Warning.frames(sim).is_empty(),"old observations do not supply a live lock countdown")
 c.time=10.;c.lock=0.
 t.check(Warning.frames(sim).is_empty(),"broken locks stop the warning")
 c.lock=1.;w.update_state(sim,false)
 t.check(not w.visible,"warning is hidden outside the dive")
 w.free()
