extends SceneTree
func _initialize():
 var Sim=load("res://src/simulation/simulation.gd")
 for mission in [0,3,4,5]:
  var start=Time.get_ticks_usec();var s=Sim.new();s.start(mission);var build=Time.get_ticks_usec()-start
  s.command("silent");s.command("route",{"point":Vector2(1350,800)});s.command("decoy",{"point":Vector2(900,500)});s.command("ping");s.command("recon");s.paused=false
  start=Time.get_ticks_usec();var largest=0
  for n in 1200:
   var begin=Time.get_ticks_usec();s.advance(Sim.STEP);largest=maxi(largest,Time.get_ticks_usec()-begin)
  var total=Time.get_ticks_usec()-start
  print(JSON.stringify({"mission":mission,"build_ms":build/1000.0,"mean_tick_ms":total/1200000.0,"max_tick_ms":largest/1000.0,"sim_seconds":s.elapsed,"hull":s.hull,"sirens":s.sirens.size()}))
 quit()
