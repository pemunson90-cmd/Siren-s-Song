extends SceneTree
const Sim=preload("res://tests/iron_choir_pressure_sim.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
var fleet_plans={}
var fleet_ready=false
var defense_until={}
var pressured_ops={}
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):
  support(s);s.advance(Sim.STEP)
 s.paused=true
func go(s,point)->bool:
 if not s.outcome.is_empty():return s.outcome=="won" and s.units[0].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 24000:
  support(s);s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 s.paused=true
 return s.units[0].alive and s.hull>0 and s.units[0].pos.distance_to(point)<(65 if s.outcome=="won" else 25)
# Permanent reviewer counterexample: ordinary launch SILENT stays on at crossings.
# A useful quiet route must meet patrols without an avoidable cruise command.
func crossing(s,point:Vector2,via:Array=[])->bool:
 return course(s,via+[point])
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
# Source-known controller: all work uses the ordinary commands and physical craft.
# Plans progress from arrival/readiness, never teleporting or editing live state.
func support(s):
 if not fleet_plans.has(s.get_instance_id()) or not s.outcome.is_empty():return
 var old=s.selected
 for id in fleet_plans[s.get_instance_id()]:
  var plan=fleet_plans[s.get_instance_id()][id]
  if plan.is_empty() or not s.units[id].alive:continue
  s.command("select",{"unit":id});var step=plan[0];var u=s.units[id]
  if step.has("wait"):
   if s.Choir.Rules.site(s.mission.iron_choir,step.wait).get("done",false):plan.pop_front()
  elif step.has("receipt"):
   if s.mission.iron_choir.receipt:plan.pop_front()
  elif step.has("ready"):
   if fleet_ready:plan.pop_front()
  elif step.has("point"):
   if u.pos.distance_to(step.point)<35 and u.vel.length()<2:plan.pop_front()
   elif u.route.is_empty():s.command("route",{"point":step.point})
  elif step.has("band"):
   if u.band==step.band and u.transition.is_empty():plan.pop_front()
   elif u.transition.is_empty():s.command("depth",{"band":step.band})
  elif step.has("action"):
   if step.get("started",false):
    if not s.Choir.busy(s,id):
     var done=s.mission.iron_choir.artifact.get("carrier",-1)==id if step.action=="recover" else s.Choir.Rules.site(s.mission.iron_choir,step.action).get("done",false)
     if done:plan.pop_front()
     else:step.erase("started")
   elif s.command("choir_action",{"action":step.action}):
    if step.action in ["attach","release"]:plan.pop_front()
    else:step.started=true
 # Act on fresh received windup information, spending the ordinary finite EMP stock.
 for contact_id in s.contacts:
  var c=s.contacts[contact_id]
  if s.elapsed<defense_until.get(s.get_instance_id(),0.) or s.elapsed-float(c.time)>.3 or c.get("mode","") not in ["BURST WINDUP","PRESSURE CHARGE","LOCKING"]:continue
  if s.units[0].alive and not s.Choir.busy(s,0) and s.units[0].pos.distance_to(c.pos)<150 and s.tools.knock>0:
   s.command("select",{"unit":0})
   if s.command("knock",{"target":contact_id}):defense_until[s.get_instance_id()]=s.elapsed+1.;continue
  for id in 3:
   if s.units[id].alive and not s.Choir.busy(s,id) and s.units[id].pos.distance_to(c.pos)<330 and s.tools.emp>0:
    s.command("select",{"unit":id})
    if s.command("emp"):
     defense_until[s.get_instance_id()]=s.elapsed+1.
     break
 s.command("select",{"unit":old})
func points(route:Array)->Array:
 var result=[]
 for p in route:
  if p==Vector2(300,2350):result.append_array([{"point":Vector2(300,2250)},{"point":Vector2(250,2350)}])
  else:result.append({"point":p})
 return result
func wait_for(s,test:Callable,limit=500.):
 for n in ceili(limit*60):
  if test.call() or not s.outcome.is_empty():break
  tick(s,Sim.STEP)
func fleet_journey(id:int,p:Dictionary):
 var fitted={"quietus":"quietus_scrubber_bed","quietus_2":"quietus_vector_drive","drone_a":"drone_deep_cells","drone_b":""}
 if id==28:fitted.quietus_2="quietus_reserve_cell"
 if id==23:fitted.drone_b="drone_ballast_pack"
 if id==24:fitted["drone_a_2"]="drone_traction_yoke"
 check(Sim.Equipment.valid_fitting(fitted),"equipped launch uses legal unique modules and frame budgets "+str(id))
 # Explicit carried stock matches the successful public tool spends, rather
 # than the legacy aggregate controller bundle. No uncarried charges are free.
 var racks=Racks.empty()
 match id:
  22,28:racks.quietus={"emp":1,"knock":2};racks.drone_a={"emp":1}
  23:racks.drone_a={"emp":1}
  24,26:racks.drone_a={"emp":2}
  27:racks.drone_b={"emp":2}
 check(Racks.reason(fitted,racks).is_empty(),"equipped carried racks fit real cargo budgets "+str(id))
 if id in [26,27]:check(Racks.winch_capacity({"launch_equipment":fitted,"tool_racks":racks},1)>=1,"artifact carrier retains a whole winch place "+str(id))
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p),"fitted":fitted,"tool_racks":racks})
 if id in [24,26,28]:s.command("select",{"unit":1})
 fleet_plans[s.get_instance_id()]={};fleet_ready=false
 var plans=fleet_plans[s.get_instance_id()];var home=[Vector2(350,300),Vector2(300,2350)]
 match id:
  22:
   plans[1]=points([Vector2(750,600),Vector2(750,300),Vector2(1800,390)])+[{"action":"lock_a"}]+points(home)
   check(go(s,Vector2(750,2050)) and s.command("choir_action",{"action":"west"}),"fleet releases actual freight")
   check(course(s,[Vector2(750,600),Vector2(750,300),Vector2(2500,450)]),"fleet reaches freight arrival")
   wait_for(s,func():return s.mission.iron_choir.receipt)
   check(s.mission.iron_choir.receipt,"fleet observes real freight arrival");check(course(s,home),"fleet freight account returns")
  23:
   plans[1]=points([Vector2(650,2050)])+[{"wait":"lock_a"}]+points([Vector2(650,1785),Vector2(1250,1385)])+[{"band":0},{"action":"lock_b"},{"band":1}]+points([Vector2(1430,1500),Vector2(650,1785),Vector2(650,2000),Vector2(300,2350)])
   plans[2]=points([Vector2(650,2050)])+[{"wait":"lock_b"}]+points([Vector2(650,1785),Vector2(1430,1195),Vector2(2400,800)])+[{"band":2}]+points([Vector2(2400,690)])+[{"action":"lock_c"},{"band":1}]+points([Vector2(1430,1195),Vector2(1430,1500),Vector2(650,1785),Vector2(650,2000),Vector2(300,2400)])
   check(go(s,Vector2(650,1845)) and work(s,"lock_a"),"Quietus opens first equalizer while drones stage")
   check(course(s,[Vector2(300,1935),Vector2(300,2650)]),"Quietus clears the drone staging lane and watched recovery approach")
   wait_for(s,func():return s.Choir.complete(s));check(go(s,Vector2(300,2350)),"Quietus returns lower stair account")
  24:
   plans[1]=points([Vector2(750,2140)])+[{"action":"attach"}]+points([Vector2(750,2450),Vector2(1675,2450),Vector2(1675,1300),Vector2(1675,500),Vector2(2450,500)])+[{"action":"bypass"}]+points(home)
   s.command("select",{"unit":0});check(s.command("depth",{"band":0}),"Quietus parks above the watched service approach");tick(s,4.2)
   wait_for(s,func():return s.Choir.complete(s));check(s.mission.iron_choir.choice=="bypass","yoke drone seats actual ballast through service water")
  25:
   if not s.mission.iron_choir.sites[1].done:
    plans[1]=points([Vector2(350,600),Vector2(750,600)])+[{"action":"service"}]+points([Vector2(350,600),Vector2(300,2350)])
   else:
    # Progressed access stays open; a drone covers the dock approach before returning.
    plans[1]=points([Vector2(350,600),Vector2(750,600)])+[{"receipt":true}]+points([Vector2(350,600),Vector2(300,2350)])
   check(go(s,Vector2(750,2050)),"Quietus reaches release while drone services berth")
   wait_for(s,func():return s.mission.iron_choir.sites[1].done)
   check(s.command("choir_action",{"action":"west"}),"fleet releases occupied sled")
   escort(s,Vector2(750,300));check(s.mission.iron_choir.receipt,"fleet actually lands occupied sled")
   check(course(s,home),"fleet landing account returns")
  26:
   plans[1]=points([Vector2(350,1000)])+[{"band":2}]+points([Vector2(350,425),Vector2(1100,425),Vector2(1450,470)])+[{"action":"recover"}]+points([Vector2(1100,425),Vector2(700,425)])+[{"band":1},{"band":0}]+points([Vector2(350,350),Vector2(300,2250)])+[{"band":1}]+points([Vector2(250,2350)])
   s.command("select",{"unit":0});check(s.command("depth",{"band":0}),"Quietus parks above the recovery patrol");tick(s,4.2)
   wait_for(s,func():return s.mission.iron_choir.artifact.state=="cargo")
  27:
   plans[1]=[{"band":0}]+points([Vector2(900,2550),Vector2(900,500),Vector2(1250,500)])+[{"band":1},{"wait":"cradle"}]+points([Vector2(1250,700)])+[{"action":"recover"},{"band":0}]+points([Vector2(1250,500),Vector2(750,500),Vector2(350,500),Vector2(150,2500)])+[{"band":1},{"point":Vector2(250,2350)}]
   plans[2]=[{"band":0}]+points([Vector2(150,2500)])+[{"wait":"cradle"},{"band":1}]+points([Vector2(250,2500),Vector2(350,2350)])
   check(course(s,[Vector2(750,2550),Vector2(750,1790)]) and s.command("choir_action",{"action":"attach"}),"Quietus attaches actual counterweight by the south bypass")
   check(go(s,Vector2(750,1250)) and work(s,"lock_a"),"Quietus chocks actual load")
   check(course(s,[Vector2(650,1250),Vector2(750,700),Vector2(1250,700)]) and work(s,"cradle"),"Quietus seats weight while drone waits at core")
   check(course(s,[Vector2(750,700),Vector2(350,700),Vector2(300,1900)]) and crossing(s,Vector2(300,2350)),"Quietus clears recovery separately from the core carrier")
  28:
   plans[1]=points([Vector2(880,1980),Vector2(900,1500),Vector2(600,1250)])+[{"action":"lock_a"}]+points([Vector2(650,1100),Vector2(900,1050),Vector2(850,850)])+[{"action":"lock_b"}]+points([Vector2(700,760),Vector2(450,500),Vector2(450,1500),Vector2(300,2350)])
   s.command("select",{"unit":0})
   check(go(s,Vector2(750,2140)) and s.command("choir_action",{"action":"attach"}),"Quietus attaches occupied bell while drone stages")
   check(course(s,[Vector2(880,1980),Vector2(900,1500),Vector2(650,1250)]),"physical bell reaches first drone-operated stop")
   wait_for(s,func():return s.mission.iron_choir.sites[0].done)
   check(course(s,[Vector2(650,1100),Vector2(900,1050),Vector2(900,850)]),"physical bell reaches second drone-operated stop")
   wait_for(s,func():return s.mission.iron_choir.sites[1].done)
   check(course(s,[Vector2(700,760),Vector2(700,500)]) and work(s,"land"),"fleet physically lands same occupied party after both real stops")
   check(course(s,[Vector2(450,500),Vector2(450,1500),Vector2(300,2350)]),"fleet bell account returns")
  29:
   plans[1]=points([Vector2(700,2250)])+[{"ready":true},{"action":"lock_c"}]+points([Vector2(300,2350)])
   check(course(s,[Vector2(300,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]),"Quietus stages reconnect while drone holds far breaker")
   fleet_ready=true;wait_for(s,func():return s.mission.iron_choir.sites[0].done)
   check(work(s,"reconnect"),"independent breaker enables real reconnection")
   check(course(s,[Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]),"fleet plant account returns")
 # All fitted carriers physically return. Never waive the module departure decision.
 wait_for(s,func():return plans.values().all(func(plan):return plan.is_empty()))
 if s.outcome.is_empty():
  s.command("select",{"unit":0})
  if s.units[0].band==0:s.command("depth",{"band":1});tick(s,4.2)
  go(s,Vector2(300,2350));tick(s,.2)
 if s.outcome!="won":print("FLEET STOP ",id," plans=",plans," units=",s.units," message=",s.message)
 check(s.outcome=="won" and s.hull>0,"equipped full operation recovery "+str(id))
 check(s.outcome=="won" and s.mission.module_recovery.result.get("lost",[]).is_empty() and s.mission.module_recovery.result.get("recovered",[]).size()==s.mission.module_recovery.modules.size(),"all fitted modules actually return "+str(id))
 check(Sim.valid_snapshot(s.snapshot()),"equipped industrial current save valid "+str(id))
 fleet_plans.erase(s.get_instance_id());defense_until.erase(s.get_instance_id());return s
func progress():return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17,18,19],"facts":{"deep":"received carrier","confluence_route":"concealed","resolution":"concealed_recovery"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func journey(id:int,p:Dictionary,variant:String=""):
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p),"tool_racks":Racks.empty()})
 # Explicit source-known staged access; actual physics/live threats/no profile edits.
 s.units[1].alive=false;s.units[2].alive=false;s.ordinary_bare=true
 for key in s.tools:s.tools[key]=0
 var tools=s.tools.duplicate()
 match id:
  22:
   check(course(s,[Vector2(750,2050)]),"bare reaches physical release");check(s.command("choir_action",{"action":"west"}),"deliberate west course released")
   check(course(s,[Vector2(750,600),Vector2(750,300),Vector2(1800,390)]),"bare outruns the sled to its west lane gate");check(s.mission.iron_choir.load.pos.distance_to(Vector2(1800,390))>150,"sled is still on its way when the gate is reached")
   check(work(s,"lock_a"),"bare opens the lane gate ahead of the sled")
   check(course(s,[Vector2(2500,450)]),"bare watches the refuge from its northern water")
   for n in 24000:
    if s.mission.iron_choir.receipt or not s.outcome.is_empty():break
    tick(s,Sim.STEP)
   check(s.mission.iron_choir.receipt and s.mission.iron_choir.load.hull>=100.,"actual locally observed undamaged arrival")
   check(course(s,[Vector2(350,300),Vector2(300,1200)]) and crossing(s,Vector2(300,2350)),"bare clears the watched unloaded recovery approach")
  25:
   if not s.mission.iron_choir.sites[1].done:
    check(course(s,[Vector2(350,600),Vector2(750,600)]),"bare reaches service berth");check(work(s,"service"),"bare manual service")
   check(course(s,[Vector2(750,2050)]),"bare reaches physical release");check(s.command("choir_action",{"action":"west"}),"deliberate west voyage")
   escort(s,Vector2(750,300))
   check(s.mission.iron_choir.receipt and s.mission.iron_choir.load.hull>0.,"escorted sled actually arrives and is observed")
   check(course(s,[Vector2(350,300),Vector2(300,2350)]),"bare returns after actual arrival")
  23:
   var st=s.mission.iron_choir.sites
   check(go(s,st[0].pos+Vector2(0,-55)),"bare reaches lock_a below first bulkhead");check(work(s,"lock_a"),"bare cycles lock_a at middle depth")
   check(course(s,[Vector2(500,1850),Vector2(650,1785),Vector2(1250,1385)]),"bare climbs through opened bulkhead to the shallow valve")
   check(s.command("depth",{"band":0}),"bare rises to shallow");tick(s,4.2);check(work(s,"lock_b"),"bare cycles lock_b from shallow")
   check(course(s,[Vector2(1250,1000),Vector2(1550,950)]) and crossing(s,Vector2(2400,800)),"bare skirts the shallow landing patrol before the deep valve")
   check(s.command("depth",{"band":1}),"bare drops to middle");tick(s,4.2);check(s.command("depth",{"band":2}),"bare drops to deep");tick(s,4.2)
   check(go(s,Vector2(2400,690)),"bare reaches deep valve");check(work(s,"lock_c"),"bare cycles lock_c from deep")
   check(s.command("depth",{"band":1}),"bare surfaces to middle");tick(s,4.2)
   check(course(s,[Vector2(1430,1195),Vector2(1430,1500),Vector2(800,1500),Vector2(650,1700),Vector2(650,1785),Vector2(650,2000),Vector2(300,2350)]),"bare returns down the opened stair")
  24:
   check(go(s,Vector2(750,2140)) and s.command("choir_action",{"action":"attach"}),"bare attaches ballast without gear")
   check(course(s,[Vector2(750,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]),"bare moves actual broad ballast by outside water")
   check(work(s,"bypass"),"actual ballast socket chooses bypass")
   check(course(s,[Vector2(2450,300),Vector2(350,300),Vector2(300,1200)]) and crossing(s,Vector2(300,2350)),"bare ballast recovery clears the watched approach")
  26:
   check(go(s,Vector2(350,1500)) and s.command("depth",{"band":2}),"bare dives before the watched sump approach");tick(s,4.2)
   check(course(s,[Vector2(350,425),Vector2(1100,425),Vector2(1450,470)]),"bare reaches the spindle below the approach patrol")
   check(work(s,"recover",4.2),"actual deep spindle winch")
   check(course(s,[Vector2(1100,425),Vector2(700,425)]) and s.command("depth",{"band":1}),"carrier leaves the basin before surfacing");tick(s,4.2)
   check(course(s,[Vector2(150,350),Vector2(200,1000)]) and crossing(s,Vector2(150,2350)) and go(s,Vector2(300,2350)),"physical carrier clears the watched middle return")
  27:
   check(course(s,[Vector2(750,2550),Vector2(750,1790)]) and s.command("choir_action",{"action":"attach"}),"actual counterweight attach by the south bypass")
   check(course(s,[Vector2(750,1250)]) and work(s,"lock_a"),"counterweight chocked on the ledge")
   check(course(s,[Vector2(650,1250),Vector2(750,700),Vector2(1250,700)]),"actual counterweight transport")
   check(work(s,"cradle"),"counterweight physically exposes core");check(work(s,"recover",4.2),"actual traction core winch")
   check(course(s,[Vector2(750,700),Vector2(350,700),Vector2(300,1900)]) and crossing(s,Vector2(300,2350)),"unloaded traction carrier clears the watched recovery approach")
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
    check(course(s,[Vector2(300,2450),Vector2(2750,2450),Vector2(2750,1800)]) and crossing(s,Vector2(2750,1300)) and course(s,[Vector2(2750,500),Vector2(2450,500)]),"bare times the watched east crossing inside the window")
    check(work(s,"reconnect"),"real plant reconnection")
    check(course(s,[Vector2(2950,500),Vector2(2950,2450),Vector2(300,2450),Vector2(300,2350)]),"plant account recovers")
 check(s.continuous_silent and s.ordinary_commands,"permanent reviewer counterexample keeps launch SILENT throughout "+str(id))
 if s.outcome=="won" and s.continuous_silent and (s.received_lock_episodes>=1 or s.hunt_peak>=20.):pressured_ops[id]=true
 print("IRON PRESSURE id=",id," hunt=",s.hunt_peak," received_quietus_lock_episodes=",s.received_lock_episodes," received_lock_transitions=",s.received_locks," continuous_silent=",s.continuous_silent)
 check(s.outcome=="won" and s.hull>0 and s.tools==tools and s.mission.launch_equipment.values().all(func(v):return v==""),"actual baseline no-tool/no-fitting industrial finish "+str(id))
 check(Sim.valid_snapshot(s.snapshot()),"finished industrial state save valid "+str(id))
 print("IRON JOURNEY id=",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," message=",s.message)
 return s
func _initialize():
 if "--fleet" in OS.get_cmdline_user_args():
  for id in range(22,30):
   var history=progress();history.completed.append_array([22,23,24]);history.facts.choir_choice="isolate";fleet_journey(id,history)
  print("IRON JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0);return
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--only="):
   var p=progress();p.completed.append_array([22,23,24]);p.facts.choir_choice="isolate";journey(int(arg.trim_prefix("--only=")),p);print("ONLY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0);return
 var p=progress();check(Campaign.valid(p),"staged received history is a valid campaign")
 for id in [22,26,23,27,28,24,29,25]:
  check(id in Campaign.available([0,1,2,3,4,5],p),"ordinary recovered prerequisite offers "+str(id))
  var s=journey(id,p);p=Campaign.recover(p,s.mission)
  check(id in p.completed and Campaign.valid(p),"physical result advances ordinary campaign "+str(id))
  if failures>0:break
 check(pressured_ops.size()>=6,"six useful continuously SILENT bare operations meet Sirens")
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
