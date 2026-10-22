extends SceneTree
# Source-known voyages use ordinary authored guards and physically moved craft.
# These are builder feasibility/cost probes, not blind preference acceptance.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
var distance=0.
var drag_reaction=false
var tow_clip=false
var reply_heard=false
var reply_investigation=false
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s):
 var previous=s.units[0].pos;s.paused=false;s.advance(Sim.STEP);distance+=previous.distance_to(s.units[0].pos)
 var work=s.mission.concealed_harbour
 if work.phase=="towing" and s.blocked(work.pos,18):tow_clip=true
 for noise in s.noises:
  if noise.label=="BUNKER WATCH REPLY":
   for guard in s.sirens:
    var arrivals=s.acoustic_paths.arrivals(guard.pos,noise.pos,noise.radius)
    if not arrivals.is_empty():
     reply_heard=true
     if guard.mode=="INVESTIGATE" and arrivals.any(func(a):return a.goal.distance_to(guard.goal)<5):reply_investigation=true
  if noise.label!="TOW DRAG":continue
  for guard in s.sirens:
   var heard=s._heard_arrival(guard)
   if guard.mode=="INVESTIGATE" and heard.get("pulse",false) and guard.goal.distance_to(heard.goal)<5:drag_reaction=true
func go(s,point:Vector2,quiet:bool=true)->bool:
 if s.units[0].silent!=quiet:s.command("silent")
 if not s.command("route",{"point":point}):print("REFUSED ",point," ",s.message);return false
 for n in 18000:
  if not s.outcome.is_empty():print("ENDED at ",s.units[0].pos," ",s.message);return false
  if s.units[0].pos.distance_to(point)<25 and s.units[0].vel.length()<2:return true
  # An ordinary chart stop requires a new accepted order after fresh returns.
  if s.units[0].has("chart_stop") and n%30==0:s.command("route",{"point":point})
  tick(s)
 print("STUCK ",point," actual ",s.units[0].pos," ",s.message);return false
func run_case(thread:String,placement:String,north:bool=true):
 var s=Sim.new();s.start(12,"endurance",{"context":{"thread":thread,"completed":[6,7,9,11] if thread=="deep" else [6,8,10,11],"facts":{},"references":{}}})
 s.units[1].alive=false;s.units[2].alive=false
 s.tools={"emp":0,"recon":0,"decoy":0,"knock":0};distance=0;drag_reaction=false;tow_clip=false;reply_heard=false;reply_investigation=false
 var success=true
 var approach=[Vector2(580,1900),Vector2(1380,1940),Vector2(1380,1100),Vector2(1840,800)] if thread=="deep" else [Vector2(580,1900),Vector2(1380,1940),Vector2(1380,1600),Vector2(1800,1200),Vector2(1840,800)]
 for p in approach:
  if not go(s,p):success=false;break
 check(success,"bare Q no-tool approach discovers the witness under ordinary guards "+thread)
 if not success:result(s,thread,placement,north);return
 check(s.command("salvage",{"item":"witness_capsule"}),"ordinary local winch starts "+thread)
 for n in 250:tick(s)
 check(s.witness_status().capsule.get("state","")=="carried" and s.concealed_status().known,"actual living witness contributes the local problem "+thread)
 var hook=Vector2(1840,1010) if thread=="deep" else Vector2(1940,1040)
 check(go(s,hook),"actual Q reaches the revealed tow eye "+thread)
 var attached=s.command("concealed_tow",{"action":"attach"});check(attached,"actual bare Q couples tow "+thread)
 if not attached:print("ATTACH CONTEXT ",s.concealed_status()," own=",s.units[0].pos)
 var work_started=s.elapsed
 if thread=="deep":
  var route=[Vector2(1840,850)] if not north else [Vector2(1840,850),Vector2(1380,850),Vector2(1340,1020)]
  for p in route:
   if not go(s,p,north):success=false;break
 else:
  success=go(s,Vector2(1920,990) if placement=="service" else Vector2(1970,1010))
 check(success and s.command("concealed_tow",{"action":"release" if thread=="deep" else placement}),"actual trail solves the local condition and permits local release/seat "+thread+" "+placement)
 check(not tow_clip,"actual trailing equipment never passes through solid terrain "+thread)
 if not success:result(s,thread,placement,north);return
 # Receive a real reply, and physically inspect the resulting station/refuge.
 if thread=="deep":
  for n in 130:tick(s)
  success=go(s,Vector2(1840,850)) and go(s,Vector2(2180,800))
 else:
  if placement=="baffle":success=go(s,Vector2(2010,1130)) and go(s,Vector2(2300,1130)) and go(s,Vector2(2300,970))
  else:success=go(s,Vector2(2300,970))
 check(success and s.concealed_status().receipt,"changed local station physically/ acoustically acknowledges "+thread+" "+placement)
 if thread=="shelf":
  check(reply_heard==(placement=="service"),"chosen physical mouth changes actual watch reception "+placement)
  if placement=="service":check(reply_investigation,"actual watch investigates the received station reply")
 var work_time=s.elapsed-work_started
 # The shelf return stays silent and crosses below the western patrol turn.
 # Deep approaches retain their existing return; no machinery or finite tools.
 var withdrawal=[Vector2(1840,800),Vector2(1380,850),Vector2(1380,1940),Vector2(580,1900),Vector2(2260,2700)] if thread=="deep" else [Vector2(2300,1130),Vector2(1940,1130),Vector2(1740,1200),Vector2(1380,1940),Vector2(1380,2120),Vector2(580,2120),Vector2(2260,2700)]
 for p in withdrawal:
  if not go(s,p,thread=="shelf"):success=false;break
 check(success and s.command("witness_land"),"occupied witness still physically returns and lands "+thread)
 tick(s)
 check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"bare Q/no-tools final recovery remains finishable "+thread+" "+placement)
 result(s,thread,placement,north,work_time)
func result(s,thread:String,placement:String,north:bool,work_time:float=-1.):
 print("CONCEALED JOURNEY ",thread,"/",placement,"/",("north" if north else "south")," outcome=",s.outcome," elapsed=",s.elapsed," work_seconds=",work_time," metres=",distance," hull=",s.hull," oxygen=",s.oxygen," drag_reaction=",drag_reaction," reply_heard=",reply_heard," reply_investigation=",reply_investigation," tow_clipped=",tow_clip," state=",s.mission.concealed_harbour.phase," receipt=",s.mission.concealed_harbour.receipt)
func run():
 run_case("deep","cast-off",true)
 run_case("deep","cast-off",false)
 run_case("shelf","service")
 run_case("shelf","baffle")
 print("CONCEALED HARBOUR JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
