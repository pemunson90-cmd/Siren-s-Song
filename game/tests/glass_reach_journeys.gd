extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Endings=preload("res://src/campaign/endings.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func go(s,point)->bool:
 if s.outcome=="won":return s.units[0].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 s.paused=true
 return (s.outcome=="won" or s.units[0].pos.distance_to(point)<25) and s.units[0].alive
func outside(s,point)->bool:
 # The longer east/south perimeter is the briefed bare-fleet alternative.
 if s.units[0].pos.x<600 and point.x<600:return go(s,Vector2(250,point.y)) and go(s,point)
 if s.units[0].pos.x<600:
  if not go(s,Vector2(250,2250)) or not go(s,Vector2(2200,2250)):return false
 elif s.units[0].pos.x<1900:
  if not go(s,Vector2(2200,s.units[0].pos.y)):return false
 if point.x<600:return go(s,Vector2(2200,2250)) and go(s,Vector2(250,2250)) and go(s,point)
 return go(s,Vector2(2200,point.y)) and go(s,point)
func progress(route="concealed"):
 return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12 if route=="concealed" else 13],"facts":{"deep":"received carrier","confluence_route":route,"resolution":"concealed_recovery" if route=="concealed" else "overt_warning"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func journey(id:int,p:Dictionary):
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p)})
 # Explicit source-known Quietus-only access, no earned-campaign/profile claim.
 s.units[1].alive=false;s.units[2].alive=false
 var tools=s.tools.duplicate()
 if id in [15,18]:
  check(outside(s,s.mission.glass_reach.work_pos+Vector2(0,35)),"bare course reaches local machinery "+str(id))
  check(s.command("glass_action",{"action":"vane" if id==15 else "service"}),"bare local machine accepts real work "+str(id));tick(s,8.2)
 if not s.mission.objectives[0].captured:
  check(outside(s,s.mission.objectives[0].pos+Vector2(0,80)),"bare course reaches received account "+str(id))
  check(s.command("camera"),"real local account acquisition starts "+str(id));tick(s,s.mission.objectives[0].duration+.2)
 if id in [17,20,21]:
  check(outside(s,s.mission.glass_reach.work_pos+Vector2(0,35)),"actual material approach "+str(id))
  check(s.command("glass_action",{"action":"recover"}),"actual physical material winch "+str(id));tick(s,4.2)
 check(outside(s,s.mission.extraction),"bare return reaches named recovery mouth "+str(id))
 check(s.outcome=="won" and s.hull>0 and s.tools==tools and s.mission.launch_equipment.values().all(func(v):return v==""),"baseline Quietus finishes without finite tools or advanced fitting "+str(id))
 check(Sim.valid_snapshot(s.snapshot()),"finished region dive restores current state "+str(id))
 print("GLASS JOURNEY id=",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," message=",s.message)
 return s
func _initialize():
 var p=progress();var original=Endings.resolve(p).id
 check(Campaign.valid(p) and 14 in Campaign.available([0,1,2,3,4,5],p),"normal concealed outcome unlocks Glass Reach")
 check(Campaign.valid(progress("overt")) and 14 in Campaign.available([0,1,2,3,4,5],progress("overt")),"normal public outcome also unlocks Glass Reach")
 for id in [14,15,16,20,17,21,18,19]:
  check(id in Campaign.available([0,1,2,3,4,5],p),"ordinary recovered prerequisites offer "+str(id))
  var s=journey(id,p);p=Campaign.recover(p,s.mission)
  check(id in p.completed and Campaign.valid(p),"real recovered result advances valid regional campaign "+str(id))
  if failures>0:break
 var store=load("res://src/persistence/save_store.gd").new();store.path="user://glass-complete-campaign.save"
 var envelope={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":p,"active":null}
 check(store.save(envelope) and store.load_game()==envelope,"actual accumulated region progression/research roundtrips checksummed campaign save")
 check(Endings.resolve(p).id==original,"new region preserves committed earlier outcome family")
 check(p.get("research",{}).get("spent",[]).size()==2 and "quietus_prism" in p.entitlements and "quietus_decoder" in p.entitlements,"both actual optional material returns produce useful research entitlements")
 if "quietus_decoder" in p.entitlements:
  var s=Sim.new();s.start(19,"endurance",{"context":Sim.Consequences.context(p),"fitted":{"quietus":"quietus_decoder","drone_a":"","drone_b":""}});s.sirens=[]
  s.mission.glass_reach.gate_open=false;s.mission.structures=[s.mission.glass_reach.gate];s._build_navigation();s.units[0].pos=s.mission.glass_reach.work_pos+Vector2(0,-100)
  check(s.command("glass_action",{"action":"gate"}),"actual recovered decoder opens local gate beyond bare60m reach")
  tick(s,2.1);check(s.mission.structures.is_empty() and s.mission.glass_reach.gate_open,"decoder research changes real later-region water")
 var service=Sim.Missions.make(19,{"facts":{"glass_choice":"service"}});var sever=Sim.Missions.make(19,{"facts":{"glass_choice":"sever"}})
 check(service.structures.is_empty() and not sever.structures.is_empty() and service.sirens.size()>sever.sirens.size(),"recovered anchorage choice changes finale physical access and relay topology")
 print("GLASS JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
