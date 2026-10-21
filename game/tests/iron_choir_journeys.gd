extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
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
 if not s.outcome.is_empty():return s.outcome=="won" and s.units[0].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 24000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 s.paused=true
 return s.units[0].alive and s.hull>0 and s.units[0].pos.distance_to(point)<25
func course(s,points:Array)->bool:
 for p in points:
  if not go(s,p):print("COURSE STOP point=",p," q=",s.units[0].pos," load=",s.mission.iron_choir.load," message=",s.message);return false
 return true
func work(s,action:String,seconds=8.2)->bool:
 var accepted=s.command("choir_action",{"action":action})
 if not accepted:print("WORK REJECT ",action," ",s.message);return false
 tick(s,seconds);return true
func progress():return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17,18,19],"facts":{"deep":"received carrier","confluence_route":"concealed","resolution":"concealed_recovery"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func journey(id:int,p:Dictionary):
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p)})
 # Explicit source-known staged access; actual physics/live threats/no profile edits.
 s.units[1].alive=false;s.units[2].alive=false;var tools=s.tools.duplicate()
 match id:
  22,25:
   if id==25 and not s.mission.iron_choir.sites[1].done:
    check(course(s,[Vector2(350,600),Vector2(750,600)]),"bare reaches service berth "+str(id));check(work(s,"service"),"bare manual service "+str(id))
   check(course(s,[Vector2(750,2050)]),"bare reaches physical release "+str(id));check(s.command("choir_action",{"action":"west"}),"deliberate west voyage "+str(id))
   check(course(s,[Vector2(750,600),Vector2(750,300)]+([Vector2(2500,450)] if id==22 else [])),"bare escorts toward announced refuge "+str(id))
   for n in 24000:
    if s.mission.iron_choir.receipt or not s.outcome.is_empty():break
    tick(s,Sim.STEP)
   check(s.mission.iron_choir.receipt,"actual locally observed living arrival "+str(id))
   check(course(s,[Vector2(350,300),Vector2(300,2350)]),"bare returns after actual arrival "+str(id))
  23:
   for site in s.mission.iron_choir.sites:
    check(go(s,site.pos+Vector2(0,35)),"bare reaches equalizer "+site.id);check(work(s,site.id),"bare physical equalizer "+site.id)
   check(course(s,[Vector2(2750,700),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]),"bare return after lock work")
  24:
   check(go(s,Vector2(750,2140)) and s.command("choir_action",{"action":"attach"}),"bare attaches ballast without gear")
   check(course(s,[Vector2(750,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]),"bare moves actual broad ballast by outside water")
   check(work(s,"bypass"),"actual ballast socket chooses bypass")
   check(course(s,[Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]),"bare ballast recovery return")
  26:
   check(course(s,[Vector2(350,350),Vector2(1450,465)]),"actual spindle approach")
   check(s.command("depth",{"band":2}),"physical spindle depth change");tick(s,4.2)
   check(work(s,"recover",4.2),"actual deep spindle winch")
   check(s.command("depth",{"band":1}),"material carrier returns middle");tick(s,4.2)
   check(course(s,[Vector2(1450,350),Vector2(350,350),Vector2(300,2350)]),"physical material returns to recovery")
  27:
   check(go(s,Vector2(750,1790)) and s.command("choir_action",{"action":"attach"}),"actual counterweight attach")
   check(course(s,[Vector2(750,700),Vector2(1250,700)]),"actual counterweight transport")
   check(work(s,"cradle"),"counterweight physically exposes core");check(work(s,"recover",4.2),"actual traction core winch")
   check(course(s,[Vector2(750,700),Vector2(350,700),Vector2(300,2350)]),"actual traction return")
  28:
   check(go(s,Vector2(750,2140)) and s.command("choir_action",{"action":"attach"}),"occupied bell attaches physically")
   check(course(s,[Vector2(750,550),Vector2(700,500)]) and work(s,"land"),"occupied people physically land")
   check(course(s,[Vector2(350,500),Vector2(300,2350)]),"crew landing account returns")
  29:
   check(course(s,[Vector2(300,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]),"actual plant approach")
   check(work(s,"reconnect"),"real plant reconnection")
   check(course(s,[Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]),"plant account recovers")
 check(s.outcome=="won" and s.hull>0 and s.tools==tools and s.mission.launch_equipment.values().all(func(v):return v==""),"actual baseline no-tool/no-fitting industrial finish "+str(id))
 check(Sim.valid_snapshot(s.snapshot()),"finished industrial state save valid "+str(id))
 print("IRON JOURNEY id=",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," message=",s.message)
 return s
func _initialize():
 var p=progress();check(Campaign.valid(p),"staged received history is a valid campaign")
 for id in [22,26,23,27,28,24,29,25]:
  check(id in Campaign.available([0,1,2,3,4,5],p),"ordinary recovered prerequisite offers "+str(id))
  var s=journey(id,p);p=Campaign.recover(p,s.mission)
  check(id in p.completed and Campaign.valid(p),"physical result advances ordinary campaign "+str(id))
  if failures>0:break
 check("quietus_pressure_sleeve" in p.entitlements and "drone_traction_yoke" in p.entitlements,"actual optional material returns pay both useful fittings")
 var bare_history=progress();bare_history.completed.append_array([22,23,24]);bare_history.facts.choir_choice="isolate"
 var bare_finale=journey(25,bare_history)
 check(bare_finale.outcome=="won" and bare_finale.mission.iron_choir.sites[1].done,"bare finale also finishes with no optional people/plant returns")
 var opposite=Sim.new();opposite.start(24,"endurance",{"context":Sim.Consequences.context(p)});opposite.sirens=[]
 # Stage only the replay's local starting access; perform actual socket work/return.
 opposite.units[1].alive=false;opposite.units[2].alive=false;opposite.units[0].pos=Vector2(2500,1885);opposite.mission.iron_choir.load.pos=Vector2(2500,1850)
 check(opposite.command("choir_action",{"action":"attach"}) and work(opposite,"isolate"),"opposite replay performs actual physical ballast socket work")
 check(course(opposite,[Vector2(2750,1850),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]) and opposite.outcome=="won","opposite replay physically recovers its changed local choice")
 var replay=Campaign.recover(p,opposite.mission)
 check(replay.facts.choir_choice=="bypass" and replay.history==p.history,"opposite real recovered replay cannot rewrite first committed ballast choice/history")
 var service=Sim.Missions.make(25,Sim.Consequences.context(p));var isolated=Sim.Missions.make(25,{"facts":{"choir_choice":"isolate","choir_plant":"dismantle"}})
 check(service.iron_choir.sites[1].done and service.has("currents") and service.sirens.size()>isolated.sirens.size() and not isolated.iron_choir.sites[1].done,"actual people/plant/ballast returns change later berth, current and powered threats")
 var sleeve=Sim.new();sleeve.start(23,"endurance",{"context":Sim.Consequences.context(p),"fitted":{"quietus":"quietus_pressure_sleeve","drone_a":"","drone_b":""}})
 check(sleeve.command("depth",{"band":0}) and sleeve.units[0].transition.remaining==2.5,"actual returned spindle entitlement has later physical pressure-lock use")
 var tow=Sim.new();tow.start(24,"endurance",{"context":Sim.Consequences.context(p),"fitted":{"quietus":"","drone_a":"drone_traction_yoke","drone_b":""}});tow.sirens=[]
 # Controlled later reward-use probe isolates the actual narrow physical envelope.
 tow.units[1].pos=tow.mission.iron_choir.load.pos+Vector2(0,35);tow.command("select",{"unit":1})
 check(tow.command("choir_action",{"action":"attach"}),"actual returned traction material enables later drone tow")
 for point in [Vector2(750,2450),Vector2(1675,2450),Vector2(1675,1300)]:
  var accepted=tow.command("route",{"point":point});tow.command("select",{"unit":0});tow.paused=false
  for n in 18000:
   tow.advance(Sim.STEP)
   if tow.units[1].route.is_empty() and tow.units[1].vel.length()<2:break
  tow.paused=true;check(accepted and tow.units[1].pos.distance_to(point)<25 and tow.mission.iron_choir.load.carrier==1,"actual unselected fitted drone moves real later load through service water "+str(point));tow.command("select",{"unit":1})
 check(tow.mission.iron_choir.load.pos.y<1400 and Sim.valid_snapshot(tow.snapshot()),"actual yoke envelope crosses narrow machinery and current state remains valid")
 var store=load("res://src/persistence/save_store.gd").new();store.path="user://iron-completed-campaign.save"
 var envelope={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":p,"active":null}
 check(store.save(envelope) and store.load_game()==envelope,"actual accumulated industrial campaign/material/people choices roundtrip checksummed save")
 print("IRON JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
