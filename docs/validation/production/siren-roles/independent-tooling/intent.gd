extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String,data:Dictionary={}):
 checks+=1
 if not ok: failures+=1
 print("INTENT ",JSON.stringify({"ok":ok,"label":label,"data":data}))
func _initialize():
 var q=Simulation.new();q.start(0);q.units[1].alive=false;q.units[2].alive=false
 var a=Vector2.ZERO;var b=Vector2.ZERO
 for y in range(100,701,20):
  for x in range(350,1151,20):
   var p=Vector2(x,y)
   if q.blocked(p,24):continue
   for dy in range(-140,141,20):
    for dx in range(-140,141,20):
     var v=p+Vector2(dx,dy)
     if p.distance_to(v)<130 or p.distance_to(v)>160 or q.blocked(v,24) or q.line_clear(p,v):continue
     a=p;b=v;break
    if a!=Vector2.ZERO:break
   if a!=Vector2.ZERO:break
  if a!=Vector2.ZERO:break
 check(a!=Vector2.ZERO,"found legal cover-separated pair",{"a":str(a),"b":str(b),"distance":a.distance_to(b)})
 q.sirens[0].pos=a;q.sirens[0].home=a;q.sirens[0].goal=a;q.units[0].pos=b;q.paused=false;q.advance(0.1)
 check(q.sirens[0].target==-1 and q.sirens[0].lock==0,"cover prevents lock inside silent visual radius")
 q._noise(b,300,"AUDIT OCCLUDED",1);q.advance(0.1)
 check(q.sirens[0].mode!="INVESTIGATE","occluded noise below attenuated hearing threshold is not heard")
 q.noises.clear();q._noise(b,600,"AUDIT HEARD",1);q.advance(0.1)
 var s=q.sirens[0]
 check(s.mode=="INVESTIGATE" and s.target==-1 and s.goal.distance_to(b)<0.1,"audible occluded noise preserves heard-point intent without visual lock",{"goal":str(s.goal),"route":s.route.size()})
 q=Simulation.new();q.start(0);q.units[1].alive=false;q.units[2].alive=false;q.units[0].pos=Vector2(700,130);q.paused=false
 for n in 10:q.advance(0.1)
 s=q.sirens[0]
 check(s.target==0 and s.mode=="LOCKING" and s.lock>0.9 and q.hull==100,"visible player gets telegraphed lock before damage",{"lock":s.lock,"hull":q.hull})
 var seen=s.goal;q.units[0].pos=Vector2(140,800);q.advance(0.1)
 check(s.target==-1 and s.goal==seen,"lost sight retains last seen point rather than new hidden player position",{"goal":str(s.goal),"hidden":str(q.units[0].pos)})
 var searched=false
 for n in 100:
  q.advance(0.1)
  if s.mode=="SEARCH":searched=true
 check(searched,"lost-sight response enters SEARCH near remembered area")
 q=Simulation.new();q.start(0);q.units[0].pos=Vector2(905,300);q.command("ping");q.paused=false;q.advance(0.1);s=q.sirens[0]
 check(s.mode=="INVESTIGATE" and not s.route.is_empty() and not q.blocked(s.route.back().pos,24),"heard point beside clearance margin gets navigable local approach",{"goal":str(s.goal),"route_end":str(s.route.back().pos) if not s.route.is_empty() else "none"})
 print("INTENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
