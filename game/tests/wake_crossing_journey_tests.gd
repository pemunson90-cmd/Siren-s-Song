extends SceneTree
# Source-known ordinary-guard controllers, not first-exposure preference tests.
# No guard relocation, finite tools, fitted hardware or compulsory drone work.
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
var distance=0.0
var sight_seconds=0.0
var played=-1.0
var lure_reaction=false
var peer_seconds=0.0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s):
 var previous=s.units[0].pos;s.paused=false;s.advance(1./60.);s.paused=true
 distance+=previous.distance_to(s.units[0].pos)
 if s.sirens.any(func(g):return g.target==0 and g.lock>0):sight_seconds+=1./60.
 if s.sirens.any(func(g):return g.has("report_interest")):peer_seconds+=1./60.
 if played>=0 and s.sirens[1].mode=="INVESTIGATE" and s.sirens[1].goal.distance_to(Vector2(1520,620))<100:lure_reaction=true
func route(s,id:int,points:Array):
 s.command("select",{"unit":id})
 for n in points.size():
  if n==1:s.command("queue")
  check(s.command("route",{"point":points[n]}),"ordinary physical waypoint accepted")
 if points.size()>1:s.command("queue")
func arrived(s,id:int,point:Vector2)->bool:return s.units[id].pos.distance_to(point)<12 and s.units[id].vel.length()<2
func until(s,id:int,point:Vector2):
 for n in 18000:
  if not s.outcome.is_empty() or not s.units[id].alive or arrived(s,id,point):break
  tick(s)
func run_case(name:String,playback:bool,control:bool=false):
 distance=0;sight_seconds=0;played=-1;lure_reaction=false;peer_seconds=0
 var s=Sim.new();s.start(9,"endurance")
 if not playback:s.units[1].alive=false
 s.units[2].alive=false
 if playback:route(s,1,[Vector2(1420,1540),Vector2(1420,1320),Vector2(1940,1320),Vector2(1940,560),Vector2(1520,680)])
 route(s,0,[Vector2(700,1540),Vector2(580,1320),Vector2(60,1320),Vector2(60,620),Vector2(300,620)])
 until(s,0,Vector2(300,620))
 s.command("select",{"unit":0});check(s.command("camera"),"Quietus actually receives western onward packet")
 for n in 250:tick(s)
 check(s.all_records(),"real passive decode earns required packet before crossing")
 var work=s.elapsed;var work_hull=s.hull
 if playback:
  until(s,1,Vector2(1520,680));s.command("select",{"unit":1})
  if not control:check(s.command("wake_playback"),"staged independent bare drone starts its real local remaining loop");played=s.elapsed
  route(s,1,[Vector2(1940,560),Vector2(1940,220),Vector2(1060,160)])
  route(s,0,[Vector2(650,540),Vector2(820,320),Vector2(1100,180)])
  until(s,0,Vector2(1100,180))
  until(s,1,Vector2(1060,160))
  route(s,0,[s.mission.extraction])
 else:route(s,0,[Vector2(60,620),Vector2(60,160),s.mission.extraction])
 for n in 18000:
  if not s.outcome.is_empty():break
  tick(s)
 if not control:check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),name+" completes through ordinary guards and a valid current recovery")
 else:check(sight_seconds>2 or s.hull<100,"matched short-policy control actually encounters the watch without playback")
 check(s.tools=={"emp":2,"decoy":3,"recon":2,"knock":2},name+" spends no mandatory finite tool")
 if not control:
  var p={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Deep branch recovered","rendezvous":"Berth recovered"},"completed":[6,7],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":""}
  var recovered=Campaign.recover(p,s.mission)
  check(recovered.facts.get("wake_crossing","")==("repeater_played" if playback else "repeater_unused"),"actual successful recovery commits exactly the local playback action")
 if playback and not control:check(s.units[1].alive and s.units[1].pos.distance_to(s.mission.extraction)<180 and lure_reaction,"operator returns and the ordinary hunter actually investigated loop water")
 print("WAKE JOURNEY ",name," outcome=",s.outcome," time=",s.elapsed," work_at=",work," return=",s.elapsed-work," hull=",s.hull," work_hull=",work_hull," O2=",s.oxygen," Qmetres=",distance," Qsight_seconds=",sight_seconds," playback=",played," loop_investigation=",lure_reaction," peer_report_seconds=",peer_seconds," Aalive=",s.units[1].alive," Abattery=",s.units[1].battery," Arecovery_distance=",s.units[1].pos.distance_to(s.mission.extraction)," guards=",s.sirens.map(func(g):return {"pos":g.pos,"mode":g.mode,"goal":g.goal}))
func _initialize():
 run_case("quiet-outer-solo",false)
 run_case("distributed-timed-crossing",true)
 run_case("same-short-policy-without-loop",true,true)
 print("WAKE CROSSING JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
