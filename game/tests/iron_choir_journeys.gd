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
func escort(s,dest:Vector2):
 # Keep Quietus just ahead of the sled; the sled only advances while a craft is near.
 for n in 4000:
  var l=s.mission.iron_choir.load
  if s.mission.iron_choir.receipt or not s.outcome.is_empty():break
  s.command("route",{"point":l.pos+(dest-l.pos).limit_length(120)});tick(s,.5)
func progress():return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17,18,19],"facts":{"deep":"received carrier","confluence_route":"concealed","resolution":"concealed_recovery"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func journey(id:int,p:Dictionary,variant:String=""):
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p)})
 # Explicit source-known staged access; actual physics/live threats/no profile edits.
 s.units[1].alive=false;s.units[2].alive=false;var tools=s.tools.duplicate()
 match id:
  22:
   check(course(s,[Vector2(750,2050)]),"bare reaches physical release");check(s.command("choir_action",{"action":"west"}),"deliberate west course released")
   check(course(s,[Vector2(750,600),Vector2(750,300),Vector2(1800,390)]),"bare outruns the sled to its west lane gate");check(s.mission.iron_choir.load.pos.distance_to(Vector2(1800,390))>150,"sled is still on its way when the gate is reached")
   check(work(s,"lock_a"),"bare opens the lane gate ahead of the sled")
   check(course(s,[Vector2(2500,450)]),"bare reaches the refuge")
   for n in 24000:
    if s.mission.iron_choir.receipt or not s.outcome.is_empty():break
    tick(s,Sim.STEP)
   check(s.mission.iron_choir.receipt and s.mission.iron_choir.load.hull>=100.,"actual locally observed undamaged arrival")
   check(course(s,[Vector2(350,300),Vector2(300,2350)]),"bare returns after actual arrival")
  25:
   if not s.mission.iron_choir.sites[1].done:
    check(course(s,[Vector2(350,600),Vector2(750,600)]),"bare reaches service berth");check(work(s,"service"),"bare manual service")
   check(course(s,[Vector2(750,2050)]),"bare reaches physical release");check(s.command("choir_action",{"action":"west"}),"deliberate west voyage")
   escort(s,Vector2(750,300))
   check(s.mission.iron_choir.receipt and s.mission.iron_choir.load.hull>0.,"escorted sled actually arrives and is observed")
   check(course(s,[Vector2(350,300),Vector2(300,2350)]),"bare returns after actual arrival")
  23:
   var st=s.mission.iron_choir.sites
   check(go(s,st[0].pos+Vector2(0,35)),"bare reaches lock_a below first bulkhead");check(work(s,"lock_a"),"bare cycles lock_a at middle depth")
   check(course(s,[Vector2(650,1785),Vector2(1250,1385)]),"bare climbs through opened bulkhead to the shallow valve")
   check(s.command("depth",{"band":0}),"bare rises to shallow");tick(s,4.2);check(work(s,"lock_b"),"bare cycles lock_b from shallow")
   check(course(s,[Vector2(1430,1195),Vector2(2400,800)]),"bare passes second bulkhead in shallow water")
   check(s.command("depth",{"band":1}),"bare drops to middle");tick(s,4.2);check(s.command("depth",{"band":2}),"bare drops to deep");tick(s,4.2)
   check(go(s,Vector2(2400,690)),"bare reaches deep valve");check(work(s,"lock_c"),"bare cycles lock_c from deep")
   check(s.command("depth",{"band":1}),"bare surfaces to middle");tick(s,4.2)
   check(course(s,[Vector2(1430,1195),Vector2(1430,1500),Vector2(650,1785),Vector2(650,2000),Vector2(300,2350)]),"bare returns down the opened stair")
  24:
   check(go(s,Vector2(750,2140)) and s.command("choir_action",{"action":"attach"}),"bare attaches ballast without gear")
   check(course(s,[Vector2(750,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]),"bare moves actual broad ballast by outside water")
   check(work(s,"bypass"),"actual ballast socket chooses bypass")
   check(course(s,[Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]),"bare ballast recovery return")
  26:
   check(course(s,[Vector2(350,1000)]) and s.command("depth",{"band":2}),"bare dives outside the sump");tick(s,4.2)
   check(course(s,[Vector2(350,425),Vector2(1100,425),Vector2(1450,470)]),"bare reaches spindle by the deep west opening")
   check(work(s,"recover",4.2),"actual deep spindle winch")
   check(course(s,[Vector2(1100,425),Vector2(700,425)]) and s.command("depth",{"band":1}),"carrier leaves the basin before surfacing");tick(s,4.2)
   check(course(s,[Vector2(350,350),Vector2(300,2350)]),"physical material returns to recovery")
  27:
   check(go(s,Vector2(750,1790)) and s.command("choir_action",{"action":"attach"}),"actual counterweight attach")
   check(course(s,[Vector2(750,1250)]) and work(s,"lock_a"),"counterweight chocked on the ledge")
   check(course(s,[Vector2(750,700),Vector2(1250,700)]),"actual counterweight transport")
   check(work(s,"cradle"),"counterweight physically exposes core");check(work(s,"recover",4.2),"actual traction core winch")
   check(course(s,[Vector2(750,700),Vector2(350,700),Vector2(300,2350)]),"actual traction return")
  28:
   check(go(s,Vector2(750,2140)) and s.command("choir_action",{"action":"attach"}),"occupied bell attaches physically")
   check(course(s,[Vector2(880,1980),Vector2(900,1500),Vector2(650,1250)]) and work(s,"lock_a"),"first decompression stop")
   check(course(s,[Vector2(650,1100),Vector2(900,1050),Vector2(900,850)]) and work(s,"lock_b"),"second decompression stop")
   check(course(s,[Vector2(700,760),Vector2(700,500)]) and work(s,"land"),"occupied people physically land through the S gallery")
   check(course(s,[Vector2(450,500),Vector2(450,1500),Vector2(300,2350)]),"crew landing account returns")
  29:
   if variant=="dismantle":
    check(course(s,[Vector2(500,2000),Vector2(850,1500),Vector2(700,1285)]),"bare reaches the western feed room")
    check(work(s,"dismantle") and s.mission.iron_choir.choice=="dismantle","feed room dismantle commits")
    check(course(s,[Vector2(850,1500),Vector2(500,2000),Vector2(300,2350)]),"dismantle account recovers")
   else:
    check(course(s,[Vector2(700,2250)]) and work(s,"lock_c"),"far breaker thrown")
    check(course(s,[Vector2(300,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]),"actual plant approach inside the window")
    check(work(s,"reconnect"),"real plant reconnection")
    check(course(s,[Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]),"plant account recovers")
 check(s.outcome=="won" and s.hull>0 and s.tools==tools and s.mission.launch_equipment.values().all(func(v):return v==""),"actual baseline no-tool/no-fitting industrial finish "+str(id))
 check(Sim.valid_snapshot(s.snapshot()),"finished industrial state save valid "+str(id))
 print("IRON JOURNEY id=",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," message=",s.message)
 return s
func _initialize():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--only="):
   var p=progress();p.completed.append_array([22,23,24]);p.facts.choir_choice="isolate";journey(int(arg.trim_prefix("--only=")),p);print("ONLY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0);return
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
 var plant_cut=journey(29,progress(),"dismantle")
 check(plant_cut.mission.iron_choir.choice=="dismantle" and plant_cut.outcome=="won","29 splits into a distinct bare dismantle route")
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
 var envelope={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":p,"active":null}
 check(store.save(envelope) and store.load_game()==envelope,"actual accumulated industrial campaign/material/people choices roundtrip checksummed save")
 print("IRON JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
