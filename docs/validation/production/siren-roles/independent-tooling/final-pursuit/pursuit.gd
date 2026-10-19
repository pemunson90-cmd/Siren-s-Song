extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String,data:Dictionary={}):
 checks+=1
 if not ok:failures+=1
 print("PURSUIT ",JSON.stringify({"ok":ok,"label":label,"data":data}))
func run_case(m:int,i:int):
 var q=Simulation.new();q.start(m);var s=q.sirens[i];q.sirens=[s];q.units[1].alive=false;q.units[2].alive=false
 var hidden=q.units[0].pos;var target=Vector2.ZERO
 for n in 32:
  var p=s.home+Vector2.from_angle(n*TAU/32)*260.0
  var approach=p+p.direction_to(s.home)*180
  if not q.blocked(p,24) and q.line_clear(s.home,p) and not q.path(s.home,approach).is_empty():target=p;break
 check(target!=Vector2.ZERO,"visible reachable authored-terrain fixture",{"mission":m,"siren":i,"target":str(target)})
 if target==Vector2.ZERO:return
 q.units[0].pos=target;q.units[0].silent=false;q.paused=false
 var origin=s.pos;var travel=0.0;var last=s.pos;var blocked=0;var minimum=INF
 # A slowly moving visible target: precise fixture input, not player-path evidence.
 for tick in 210:
  q.units[0].pos=target+Vector2(0,sin(tick/60.0)*8)
  q.advance(Simulation.STEP);travel+=last.distance_to(s.pos);last=s.pos
  minimum=minf(minimum,s.pos.distance_to(q.units[0].pos))
  if q.blocked(s.pos,12):blocked+=1
 check(travel>25 and s.pos.distance_to(origin)>20,"station role physically pursues moving visible target",{"mission":m,"siren":i,"travel":travel,"displacement":s.pos.distance_to(origin),"distance":s.pos.distance_to(q.units[0].pos)})
 check(s.target==0 and s.lock>3.4 and q.hull==100,"current sight preserves fresh four-second warning",{"lock":s.lock,"hull":q.hull})
 check(minimum>150 and s.pos.distance_to(q.units[0].pos)<225 and blocked==0,"pursuit brakes at standoff without body collision",{"minimum_distance":minimum,"blocked12_samples":blocked})
 var seen=q.units[0].pos;q.units[0].pos=hidden;q.units[0].silent=true;q.advance(Simulation.STEP)
 check(s.target==-1 and s.last_known.distance_to(seen)<0.1 and s.goal.distance_to(hidden)>100,"lost current sight follows last-known evidence, not hidden pilot",{"goal":str(s.goal),"last_known":str(s.last_known),"hidden":str(hidden)})
 var returned=false
 for tick in 4800:
  q.advance(Simulation.STEP)
  if s.mode=="DORMANT" and s.pos.distance_to(s.home)<15:returned=true;break
 check(returned,"visible pursuit eventually physically returns home",{"elapsed":q.elapsed,"home_error":s.pos.distance_to(s.home),"mode":s.mode})
 # Independent canonical EMP and fresh-lock scenario on same authored terrain.
 q=Simulation.new();q.start(m);s=q.sirens[i];q.sirens=[s];q.units[1].alive=false;q.units[2].alive=false;q.units[0].pos=target;q.units[0].silent=false;q.paused=false
 for tick in 120:q.advance(Simulation.STEP)
 var applied=q.command("emp");var stopped=s.pos
 for tick in 120:q.advance(Simulation.STEP)
 check(applied and s.pos==stopped and s.lock==0 and q.hull==100,"canonical disruption freezes pursuit and clears lock")
 while s.stun>0:q.advance(Simulation.STEP)
 for tick in 180:q.advance(Simulation.STEP)
 check(s.target==0 and s.lock<3.1 and s.lock>2.8 and q.hull==100,"post-disruption visible reacquisition gets fresh warning",{"lock":s.lock,"hull":q.hull})
func _initialize():
 run_case(4,1);run_case(3,0);run_case(3,1)
 print("PURSUIT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
