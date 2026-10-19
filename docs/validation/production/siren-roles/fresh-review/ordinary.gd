extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func travel(q,point):
 q.command("route",{"point":point}); q.paused=false
 for tick in 1800:
  q.advance(Sim.STEP)
  if q.units[0].route.is_empty() and q.units[0].vel.length()<0.5: return
func _initialize():
 var q=Sim.new();q.start(4);travel(q,Vector2(600,600))
 print("OCCLUDED_SETUP ",JSON.stringify({"elapsed":q.elapsed,"pilot":str(q.units[0].pos),"hull":q.hull,"route":q.units[0].route.size()}))
 q.command("decoy",{"point":Vector2(800,850)})
 var warning=false
 for tick in 960:
  q.advance(Sim.STEP)
  if "Autopilot stopped" in q.message and not warning:
   warning=true;print("WARNING ",JSON.stringify({"elapsed":q.elapsed,"pilot":str(q.units[0].pos),"pilot_route":q.units[0].route.size(),"pilot_speed":q.units[0].vel.length(),"hunter":str(q.sirens[1].pos),"mode":q.sirens[1].mode}))
 print("OCCLUDED_END ",JSON.stringify({"warning":warning,"hull":q.hull,"outcome":q.outcome}))
 q=Sim.new();q.start(4);travel(q,Vector2(640,850));q.command("decoy",{"point":Vector2(800,850)});q.command("route",{"point":Vector2(140,800)})
 var modes=[];var last_mode="";var max_home=0.0;var visual_ticks=0;var before=q.elapsed;var did_save=false;var save_ok=true
 for tick in 3600:
  q.advance(Sim.STEP);var h=q.sirens[1]
  max_home=maxf(max_home,h.pos.distance_to(h.home))
  if h.target>=0:visual_ticks+=1
  if h.mode!=last_mode:
   modes.append(h.mode);last_mode=h.mode;print("SAFE_MODE ",JSON.stringify({"time":q.elapsed-before,"mode":h.mode,"pos":str(h.pos),"home_error":h.pos.distance_to(h.home)}))
  if h.mode=="SEARCH" and not did_save:
   did_save=true;var copy=Sim.new();save_ok=copy.restore(q.snapshot());var frozen=copy.snapshot();copy.advance(1);save_ok=save_ok and frozen==copy.snapshot();copy.paused=false
   var live=Sim.new();live.restore(q.snapshot());live.paused=false
   for n in 120:copy.advance(Sim.STEP);live.advance(Sim.STEP)
   save_ok=save_ok and copy.sirens==live.sirens
  if "RETURN" in modes and h.mode=="DORMANT":break
 print("SAFE_END ",JSON.stringify({"modes":modes,"elapsed":q.elapsed-before,"max_home":max_home,"visual_ticks":visual_ticks,"hull":q.hull,"outcome":q.outcome,"tools":q.tools,"save_exercised":did_save,"save_ok":save_ok}))
 quit()
