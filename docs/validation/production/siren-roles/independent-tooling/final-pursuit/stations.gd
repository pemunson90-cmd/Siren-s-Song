extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String,data:Dictionary={}):
 checks+=1
 if not ok:failures+=1
 print("STATION ",JSON.stringify({"ok":ok,"label":label,"data":data}))
func run_case(mission:int,index:int):
 var q=Simulation.new();q.start(mission)
 var s=q.sirens[index];q.sirens=[s]
 q.units[1].alive=false;q.units[2].alive=false
 var point=Vector2.ZERO
 for radius in [300.0,260.0,340.0]:
  for n in 16:
   var candidate=s.home+Vector2.from_angle(n*TAU/16)*radius
   if q.blocked(candidate,24) or candidate.distance_to(q.units[0].pos)<450:continue
   if not q.path(s.home,candidate).is_empty():point=candidate;break
  if point!=Vector2.ZERO:break
 check(point!=Vector2.ZERO,"authored terrain has reachable stimulus approach",{"mission":mission,"siren":index,"home":str(s.home),"point":str(point)})
 if point==Vector2.ZERO:return
 q._noise(point,2000,"INDEPENDENT LURE",8.0 if s.type=="sentinel" else 0.25)
 q.paused=false
 var modes={};var travel=0.0;var max_home=0.0;var searched=false;var returned=false;var outside_live=false;var blocked_samples=0;var detected=0;var return_time=-1.0;var last_mode="";var last=s.pos
 for tick in 4800:
  q.advance(Simulation.STEP)
  travel+=s.pos.distance_to(last);last=s.pos
  max_home=maxf(max_home,s.pos.distance_to(s.home))
  modes[s.mode]=float(modes.get(s.mode,0))+Simulation.STEP
  if s.mode!=last_mode:
   print("TRANSITION ",JSON.stringify({"mission":mission,"siren":index,"time":q.elapsed,"mode":s.mode,"pos":str(s.pos),"goal":str(s.goal),"attention":s.attention_time,"noise_count":q.noises.size()}));last_mode=s.mode
  if s.mode=="SEARCH":searched=true
  if s.pos.distance_to(s.home)>190 and not q.noises.is_empty():outside_live=true
  if s.target>=0:detected+=1
  if q.blocked(s.pos,24):blocked_samples+=1
  if q.elapsed>10 and s.mode=="DORMANT" and not returned:
   returned=true;return_time=q.elapsed
 check(travel>100,"stimulated station role physically travels",{"mission":mission,"siren":index,"travel":travel})
 check(returned and s.pos.distance_to(s.home)<15,"station role physically returns and becomes dormant within 80 seconds",{"mission":mission,"siren":index,"return_time":return_time,"home_error":s.pos.distance_to(s.home),"modes":modes,"max_home":max_home})
 check(detected==0 and q.hull==100,"noise investigation does not invent visual target or damage",{"detected_ticks":detected,"hull":q.hull})
 check(blocked_samples==0,"physical response remains outside blocked clearance",{"blocked_samples":blocked_samples})
 if s.type=="hunter":check(searched,"hunter reaches remembered area and performs bounded local search")
 else:check(outside_live,"live lure can draw sentinel beyond conditional tether",{"max_home":max_home})
func _initialize():
 run_case(4,1)
 run_case(3,0)
 run_case(3,1)
 print("STATION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
