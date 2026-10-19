extends SceneTree
func _initialize():
 var Sim=load("res://src/simulation/simulation.gd");var s=Sim.new();s.start(3)
 for p in [Vector2(900,500),Vector2(1050,820),Vector2(1080,350)]:s.command("decoy",{"point":p})
 s.command("ping");s.command("recon");s.command("silent");s.command("route",{"point":Vector2(1400,880)});s.command("select",{"unit":1});s.command("route",{"point":Vector2(1090,360)});s.command("select",{"unit":2});s.command("route",{"point":Vector2(1320,770)});s.paused=false
 var values=[]
 for n in 300:
  var t=Time.get_ticks_usec();s.advance(Sim.STEP);values.append((Time.get_ticks_usec()-t)/1000.0)
 values.sort();var total=0.0
 for v in values:total+=v
 print(JSON.stringify({"scenario":"ordinary Foundry max finite decoys+sonar+survey, all3craft routed, concurrent capture running","mean_tick_ms":total/values.size(),"p95_tick_ms":values[284],"max_tick_ms":values.back(),"remaining_tools":s.tools,"noises":s.noises.size(),"hull":s.hull,"time":s.elapsed}));quit()
