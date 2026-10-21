extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func tick(s,seconds):
 s.paused=false
 for i in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
var checks=0
var failures=0
func _initialize():
 for example in [{"op":22,"role":"interceptor","from":0,"to":1,"pos":Vector2(1550,2200)},{"op":23,"role":"warden","from":1,"to":2,"pos":Vector2(2400,1200)}]:
  for transitioning in [false,true]:
   var s=Sim.new();s.start(example.op);s.sirens=s.sirens.filter(func(e):return e.type==example.role)
   s.units[1].alive=false;s.units[2].alive=false;s.units[0].pos=example.pos;s.units[0].band=example.from if transitioning else example.to
   s.command("select",{"unit":0})
   if transitioning:print("DEPTH accepted=",s.command("depth",{"band":example.to}))
   print("BEFORE role=",example.role," transition=",transitioning," targetoccupied=",s.Depth.occupied(s.units[0])," sight=",s.Depth.sight(s,s.sirens[0],s.units[0])," enemyband=",s.sirens[0].band)
   tick(s,.5)
   print("RESULT role=",example.role," transition=",transitioning," phase=",s.sirens[0].industry.phase," remaining=",s.sirens[0].industry.remaining," hull=",s.hull," valid=",Sim.valid_snapshot(s.snapshot()))
   checks+=1
   if s.sirens[0].industry.phase!="windup":failures+=1
 print("INDEPENDENT OCCUPIED ACQUISITION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
