extends SceneTree
# Source-known technical controllers, not blind play. Craft travel from launch,
# all plant transitions use public commands, and original guards/tools remain.
# Only the loss case injects a near-empty own battery after its real connection.
const Sim=preload("res://src/simulation/simulation.gd")
const WEST=Vector2(480,1000)
const EAST=Vector2(1520,1000)
const WEST_EXIT=Vector2(180,1000)
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func local(s,id:int,pos:Vector2)->bool:
 return s.units[id].alive and s.units[id].pos.distance_to(pos)<60 and s.units[id].vel.length()<2 and s.line_clear(s.units[id].pos,pos)
func route(s,id:int,pos:Vector2)->void:
 s.command("select",{"unit":id});check(s.command("route",{"point":pos}),"physical journey accepts own craft route to known plant water")
 if id==0 and s.units[id].silent:s.command("silent")
func defend(s,last:float)->float:
 if s.elapsed-last<1:return last
 for c in s.contacts.values():
  if s.elapsed-c.time<.3 and c.lock>=2 and c.target>=0 and s.units[c.target].alive:
   s.command("select",{"unit":c.target});var targets=s.knockdown_targets()
   if not targets.is_empty() and s.tools.knock>0 and s.command("knock",{"target":targets[0].key}):return s.elapsed+1
   if s.command("emp"):return s.elapsed
 return last
func run_case(name:String,service:bool,helper:bool,lose:bool)->void:
 var s=Sim.new();s.start(10,"disruption");var stage=0;var last=-10.0;var connected_at=-1.0;var lost_at=-1.0
 if helper:
  route(s,1,Vector2(180,1660));s.command("queue");s.command("route",{"point":Vector2(180,1000)});s.command("route",{"point":WEST});s.command("queue")
  s.command("route_edit",{"index":1,"mode":"silent"});s.command("route_edit",{"index":2,"mode":"silent"})
 else:s.units[1].alive=false;s.units[2].alive=false;route(s,0,WEST)
 s.paused=false
 for n in 15000:
  if not s.outcome.is_empty():break
  last=defend(s,last);s.advance(Sim.STEP)
  if stage==0:
   if helper and local(s,1,WEST):
    s.command("select",{"unit":1});check(s.command("chain_power",{"mode":"connect"}),"arrived real helper connects physical shore supply")
    connected_at=s.elapsed;stage=1
    route(s,0,EAST)
   elif not helper and local(s,0,WEST):
    s.command("select",{"unit":0});check(s.command("chain_power",{"mode":"backup"}),"arrived solo Quietus starts its real backup")
    route(s,0,EAST);stage=2
  elif stage==1 and local(s,0,EAST):
   if lose:
    check(s.units[1].alive and s.warning_chain_context().power.source=="umbilical","loss fixture exhausts a still-living connected battery after the actual quiet approach")
    s.units[1].battery=.0001;stage=5
   else:stage=2
  elif stage==5 and not s.units[1].alive:
   lost_at=s.elapsed;check(s.warning_chain_context().power.source=="off","actual exhausted supply body disconnects before another command")
   route(s,0,WEST);stage=3
  elif stage==3 and local(s,0,WEST):
   s.command("select",{"unit":0});check(s.command("chain_power",{"mode":"backup"}),"Quietus physically returns to restart after loss rather than receiving remote power")
   route(s,0,EAST);stage=2
  elif stage==2 and local(s,0,EAST):
   s.command("select",{"unit":0});check(s.command("chain_route",{"output":"service" if service else "mast"}) and s.command("chain_send"),"real local panel commands configure and commission the physical plant")
   check(s.warning_chain_context().result.get("proof","")==("local_receipt" if service else "mast_transmission"),"journey preserves exact receipt versus transmission evidence")
   route(s,0,WEST_EXIT if service else s.mission.extraction);stage=4
 check(stage==4 and s.outcome=="won" and s.hull>0 and Sim.valid_snapshot(s.snapshot()),"%s finishes through real guard and movement physics with a valid current archive"%name)
 if lose:check(connected_at>=0 and lost_at>connected_at and not s.units[1].alive,"lost-power journey preserves its actual exhausted craft without resurrection")
 elif helper:check(s.units[1].alive,"quiet transit and actual defensive tools can preserve the supplying body through a complete operation")
 print("PLANT JOURNEY ",name," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," EMP=",s.tools.emp," torpedoes=",s.tools.knock," connected=",connected_at," lost=",lost_at," alive=",s.units.map(func(u):return u.alive))
func _initialize():
 run_case("solo-service",true,false,false)
 run_case("solo-mast",false,false,false)
 run_case("dual-service",true,true,false)
 run_case("lost-power-service",true,true,true)
 print("WARNING CHAIN JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
