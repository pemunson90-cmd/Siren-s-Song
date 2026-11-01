extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(1./60)
 s.paused=true
func split():
 # 127: this scripted fleet journey drives the dev/test pathfinder route (Pat 2026-10-30).
 var s=Sim.new();s.start(1);s.mission["dev"]=true
 for id in [1,2]:
  s.command("select",{"unit":id});check(s.command("route",{"point":s.mission.objectives[id-1].pos+Vector2(0,180)}),"Split independent relay route")
 s.command("select",{"unit":0});check(s.command("depth",{"band":2}),"Split baseline Quietus dives for underpass");tick(s,4.1)
 check(s.command("route",{"point":Vector2(660,2100)}),"Split plots around the measured western overhang")
 s.command("queue");check(s.command("route",{"point":Vector2(900,1730)}),"Split Quietus takes actual deep approach");s.command("queue")
 var returning=false;var returned={1:false,2:false};var shallow_at_link=false;var ascending_home=false
 s.paused=false
 for n in 13000:
  s.advance(1./60)
  for id in [1,2]:
   var u=s.units[id];var o=s.mission.objectives[id-1]
   if not u.alive:continue
   if not o.captured and s.captures[id].is_empty() and u.pos.distance_to(o.pos)<230:
    s.command("select",{"unit":id});s.command("camera")
   if o.captured and not returned[id]:
    s.command("select",{"unit":id})
    if id==1:
     s.command("route",{"point":Vector2(680,580)});s.command("queue");s.command("route",{"point":Vector2(680,1700)});s.command("route",{"point":Vector2(620,2020)});s.command("route",{"point":s.mission.extraction});s.command("queue")
    else:s.command("route",{"point":s.mission.extraction})
    returned[id]=true
  var q=s.units[0]
  if not returning and q.pos.distance_to(Vector2(900,1730))<20 and q.vel.length()<2:
   s.command("select",{"unit":0})
   if q.band==2 and q.transition.is_empty():s.command("depth",{"band":1});shallow_at_link=true
   elif q.band==1 and q.transition.is_empty() and s.captures[0].is_empty():s.command("camera")
  if s.all_records() and not returning:
   s.command("select",{"unit":0});s.command("depth",{"band":2});s.command("route",{"point":Vector2(660,2100)});s.command("queue");s.command("route",{"point":s.mission.extraction});s.command("queue");returning=true
  if returning and not ascending_home and q.pos.distance_to(s.mission.extraction)<25 and q.vel.length()<2 and q.transition.is_empty():
   s.command("select",{"unit":0});s.command("depth",{"band":1});ascending_home=true
  if not s.outcome.is_empty():break
 check(shallow_at_link and returning and ascending_home,"Split traverses deep both ways and ascends for real work/recovery")
 check(s.outcome=="won" and s.units.all(func(u):return u.alive),"Split baseline fleet completes coordinated depth crossing alive")
 check(s.tools.emp==2 and s.tools.decoy==3 and s.tools.recon==2 and s.tools.knock==2,"Split depth coordination requires no finite tool")
 check(Sim.valid_snapshot(s.snapshot()),"Split completed depth archive remains current-save valid")
 print("OPENING SPLIT depth/coordinated outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," tools=",s.tools)
func travel(s,id,point):
 s.command("select",{"unit":id})
 if not s.command("route",{"point":point}):printerr("ROUTE rejected ",point," ",s.message);return false
 s.paused=false
 for n in 1800:
  s.advance(.1)
  if not s.outcome.is_empty():s.paused=true;return s.outcome=="won"
  if not s.units[id].alive:printerr("CRAFT lost ",id," at ",s.units[id].pos);return false
  if s.units[id].pos.distance_to(point)<18 and s.units[id].vel.length()<2:s.paused=true;print("ARRIVE ",s.mission.id," ",id," ",point," t",s.elapsed," hull",s.hull," band",s.units[id].band);return true
 s.paused=true;printerr("TRAVEL stalled ",id," at ",s.units[id].pos," target ",point," ",s.message);return false
const Patient=preload("res://tests/patient_play.gd")
func lull(s,id,band,target,then=Vector2.INF,at=Vector2.INF):
 for n in 40:
  if Patient.rehearsal_survives(s,id,band,target,then,at):return
  tick(s,2.)
func shift(s,id,band):
 s.command("select",{"unit":id})
 if not s.command("depth",{"band":band}):return false
 tick(s,4.1);print("SHIFT ",s.mission.id," ",id," band",s.units[id].band," t",s.elapsed," hull",s.hull);return s.units[id].band==band
func record(s,id,target):
 s.command("select",{"unit":id})
 if not s.command("camera"):printerr("RECORD rejected ",target," ",s.message);return false
 tick(s,s.mission.objectives[target].get("duration",4.)+.3)
 print("RECORD ",s.mission.id," target",target," retained",s.mission.objectives[target].captured," t",s.elapsed," hull",s.hull," pos",s.units[id].pos);return s.mission.objectives[target].captured
func result(s,label):
 check(s.outcome=="won",label+" physically completes with baseline fleet")
 check(s.tools.emp==2 and s.tools.decoy==3 and s.tools.recon==2 and s.tools.knock==2,label+" needs no finite tool")
 check(Sim.valid_snapshot(s.snapshot()),label+" completed current snapshot validates")
 print("OPENING ",label," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," alive=",s.units.map(func(u):return u.alive)," tools=",s.tools)
func blackwater():
 var fit=preload("res://src/equipment/equipment_catalog.gd").canonical({"drone_a":"drone_deep_cells"})
 var s=Sim.new();s.start(2,"endurance",{"fitted":fit})
 # Source-known ordinary routes; readiness comes from the received context.
 # The west perch must actually be within the quiet receiver's passive reach.
 s.command("select",{"unit":1});s.command("drone_drive",{"mode":"quiet"})
 check(travel(s,1,Vector2(360,200)) and travel(s,1,Vector2(575,200)),"Blackwater request scout reaches its physical western listening perch")
 var request=s.blackwater_context(0,1)
 print("BLACKWATER REQUEST RECEIVED CONTEXT ",request," passive=",s.passive_range(1))
 check(request.ready and request.settled and request.quiet and request.distance<s.passive_range(1) and s.units[1].band==1 and record(s,1,0),"Blackwater quiet drone actually samples REQUEST at passive reach in middle")
 check(shift(s,0,2) and travel(s,0,Vector2(300,800)),"Blackwater Quietus chooses a safe deep rendezvous outside sweep reach")
 s.command("select",{"unit":1});s.command("drone_drive",{"mode":"transit"})
 check(travel(s,1,Vector2(300,200)) and travel(s,1,Vector2(300,800)),"Blackwater loaded drone makes a fast physical return to Quietus")
 check(not s.command("blackwater_handoff",{"carrier":1}) and not s.Delivery.complete(s),"Blackwater mismatched depth cannot remotely deliver raw data")
 check(shift(s,1,2) and s.command("blackwater_handoff",{"carrier":1}),"Blackwater real buffer handoff works at settled deep rendezvous")
 check(travel(s,0,Vector2(720,540)),"Blackwater loaded Quietus actually passes beneath western basalt")
 lull(s,0,1,1);check(shift(s,0,1) and travel(s,0,Vector2(1360,340)) and record(s,0,1),"Blackwater Quietus actually receives eastern fixed REPLY")
 # Bring both independent helpers into the mouth before Quietus departs. The
 # fitted cells stay on their real craft throughout, including the depth return.
 check(shift(s,1,1),"Blackwater loaded helper returns to recovery depth")
 check(travel(s,1,Vector2(300,800)) and travel(s,1,s.mission.extraction+Vector2(0,-45)),"Blackwater request helper physically reaches recovery")
 check(travel(s,2,s.mission.extraction+Vector2(0,45)),"Blackwater second helper physically reaches recovery")
 check(travel(s,0,Vector2(1120,720)) and travel(s,0,Vector2(760,720)) and travel(s,0,s.mission.extraction),"Blackwater returns both physical buffers aboard Quietus in the middle layer, above the deep sweeper")
 result(s,"BLACKWATER custody/depth")
 var recovered=s.module_recovery_status().get("result",{})
 check([1,2].all(func(id):return id in recovered.get("recovered_drones",[])),"Blackwater both helpers return with Quietus")
 check("drone_deep_cells" in recovered.get("recovered",[]) and recovered.get("lost",[]).is_empty(),"Blackwater fitted hardware physically returns on its original helper")
 print("BLACKWATER HARDWARE RECOVERY ",s.mission.get("module_recovery",{}))
func foundry():
 var s=Sim.new();s.start(3)
 check(shift(s,0,2) and travel(s,0,Vector2(960,500)),"Foundry Quietus actually crosses beneath central spine")
 s.command("select",{"unit":1});s.command("drone_drive",{"mode":"quiet"})
 check(travel(s,1,Vector2(1090,580)) and record(s,1,0),"Foundry independent middle drone records furnace while Quietus stays deep")
 s.command("select",{"unit":1});s.command("drone_drive",{"mode":"transit"});s.command("route",{"point":Vector2(1080,820)})
 check(travel(s,0,Vector2(1060,580)) and travel(s,0,Vector2(1060,820)),"Foundry deep transit respects solid machinery and southern spur")
 check(shift(s,0,1) and travel(s,0,Vector2(1110,820)) and record(s,0,1),"Foundry Quietus ascends for ordered cradle observation")
 check(travel(s,0,s.mission.extraction),"Foundry actual middle recovery beyond factory wall")
 result(s,"FOUNDRY industrial/depth")
func well():
 var s=Sim.new();s.start(4)
 check(shift(s,0,0) and travel(s,0,Vector2(360,590)) and travel(s,0,Vector2(800,390)),"Well shallow west crossing reaches northern pattern vantage")
 check(shift(s,0,1) and record(s,0,0),"Well middle receiver physically records unassigned pattern")
 # The northern camera edge keeps the shutter farther from the hunter; all sound and attention timings still apply.
 check(shift(s,0,2) and travel(s,0,Vector2(1150,380)),"Well deep east passage retains uncertain hunter information")
 lull(s,0,1,1,Vector2(1000,650));check(shift(s,0,1) and record(s,0,1),"Well middle aperture image is real without promising moving reference")
 check(shift(s,0,2) and travel(s,0,Vector2(1000,650)) and travel(s,0,Vector2(560,850)),"Well moving deep withdrawal evades stale sweeper returns")
 check(travel(s,0,Vector2(620,835)),"Well deep approach to the southern vantage");lull(s,0,1,2);check(shift(s,0,1) and record(s,0,2),"Well middle southern archive remains reachable across layer choices")
 check(s.mission.well_reference.is_empty() and s.mission.well_observation.is_empty(),"Well quiet policy retains honest unverified signature")
 check(shift(s,0,2) and travel(s,0,s.mission.extraction) and shift(s,0,1),"Well unverified archive physically returns beneath the woken hunter")
 result(s,"WELL uncertain/depth")
func finale():
 var s=Sim.new();s.start(5)
 check(shift(s,0,2) and travel(s,0,Vector2(360,650)) and travel(s,0,Vector2(950,400)) and travel(s,0,Vector2(1180,40)),"Song deep central crossing reaches crown's southern vantage")
 check(shift(s,0,1) and record(s,0,0),"Song crown observation earned in middle")
 check(shift(s,0,0) and travel(s,0,Vector2(1180,400)) and travel(s,0,Vector2(1180,760)) and travel(s,0,Vector2(1250,870)),"Song shallow eastern crossing clears middle basalt")
 check(shift(s,0,1) and record(s,0,1),"Song outbound wake observation earned in middle")
 check(travel(s,0,Vector2(690,780)) and record(s,0,2),"Song Quietus listens six real seconds in middle lee after both images")
 check(travel(s,0,s.mission.extraction),"Song decoded warning physically returns")
 result(s,"SONG convergence/depth")
func _initialize():
 var cases=OS.get_cmdline_user_args()
 if cases.is_empty() or "split" in cases:split()
 if cases.is_empty() or "blackwater" in cases:blackwater()
 if cases.is_empty() or "foundry" in cases:foundry()
 if cases.is_empty() or "well" in cases:well()
 if cases.is_empty() or "finale" in cases:finale()
 print("OPENING JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
