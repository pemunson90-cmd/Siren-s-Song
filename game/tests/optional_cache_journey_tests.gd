extends "res://tests/calder_trench_journey_tests.gd"
# Source-known live-threat voyages. All travel, winching, receipt and film use
# ordinary orders; no staged craft positions, cargo, captured records or threats.
const Cache=preload("res://src/simulation/optional_cache.gd")
const Gear=preload("res://src/equipment/equipment_catalog.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
func run():
 for frame in ["standard","fast","heavy"]:
  var fit=Gear.canonical({"chassis_a":"heavy"} if frame=="heavy" else {"hull":frame})
  # 097: full solo cache circuits use the earned vector drive. The standard
  # hull still has two places; a bare launch's shorter job is the photograph.
  fit.quietus="quietus_vector_drive"
  if frame!="heavy":fit.quietus_2="quietus_scrubber_bed"
  var s=Sim.new();s.start(39,"endurance",{"fitted":fit})
  s.command("silent")
  var stock=s.tools.duplicate(true)
  var carrier=1 if frame=="heavy" else 0
  check(Sim.valid_snapshot(s.snapshot()),frame+" live launch valid")
  # Quietus waits at launch while Heavy independently works in the east.
  if carrier==1:
   s.command("select",{"unit":1})
   check(s.command("drone_drive",{"mode":"quiet"}),"Heavy uses ordinary quiet propulsion instead of audible transit thrust")
   check(s.command("depth",{"band":2}),"Heavy takes a physical DEEP approach below the patrol")
   tick(s,4.2)
   check(s.command("drone_drive",{"mode":"transit"}),"Heavy crosses the patrol water quickly below it")
  else:
   check(dive(s,2),frame+" solo carrier crosses below the live exhaust patrol")
  var reached=travel(s,Vector2(550,820),carrier) and travel(s,Vector2(2450,870),carrier)
  quiet_drive(s,carrier,true)
  #115: round the authored breakwater's north lip, then descend its cache side.
  reached=reached and travel(s,Vector2(2790,1450),carrier) and travel(s,Vector2(2470,1450),carrier) and travel(s,Cache.POS+Vector2(20,0),carrier)
  check(reached,frame+" physical launch-to-cache approach")
  if carrier==1:
   check(s.command("depth",{"band":1}),"Heavy settles back in cache depth")
   tick(s,4.2)
  else:check(dive(s,1),frame+" solo carrier settles at actual cache depth")
  var trips=0
  if reached:
   var next=0
   while next<3 and s.outcome.is_empty():
    var load=mini(3-next,s.ModuleRecovery.capacity(s,carrier))
    for n in load:
     check(s.command("salvage",{"item":Cache.IDS[next]}),frame+" audible pickup "+str(next))
     tick(s,4.2)
     check(Cache.pieces(s)[Cache.IDS[next]].state=="cargo" and Cache.pieces(s)[Cache.IDS[next]].carrier==carrier,frame+" piece physically aboard "+str(next))
     next+=1
    if next==2 and frame=="standard":check(not s.command("salvage",{"item":Cache.IDS[2]}),"two-place craft physically refuses third piece")
    check(travel(s,Vector2(2470,1450),carrier) and travel(s,s.mission.corridors[0].pos,carrier),frame+" loaded return to actual mouth")
    check(s.command("cache_action",{"action":"unload"}),frame+" local receipt before victory")
    trips+=1
    check(s.outcome.is_empty() and not s.mission.objectives[0].captured and Cache.carried(s,carrier)==0,frame+" unloaded craft free to make another trip while photo remains")
    check(Sim.valid_snapshot(s.snapshot()),frame+" received cargo save valid")
    if next<3:check(travel(s,Vector2(2470,1450),carrier) and travel(s,Cache.POS+Vector2(20,0),carrier),frame+" second physical cache approach")
  check(trips==(2 if frame=="standard" else 1),frame+" actual cargo trips")
  check(Cache.pieces(s).values().all(func(p):return p.state=="received") and s.mission.expedition_facts.get(Cache.FACT)==Cache.NOTE,frame+" complete three-piece receipt earns account")
  # Required photographic reconnaissance remains unfinished until the fleet
  # completes the ordinary western approach and masking-front return.
  s.command("select",{"unit":0})
  # Fast clears the mouth quietly; standard uses speed to beat the watch's return.
  quiet_drive(s,0,frame=="fast")
  if carrier==0:
   # Leave the recovery watch's water before settling in the MIDDLE layer.
   reached=travel(s,Vector2(2800,1300),0) and dive(s,1)
   quiet_drive(s,0,false)
   reached=travel(s,Vector2(2450,700),0) and travel(s,Vector2(2250,820),0) and travel(s,Vector2(650,820),0) and reached
  else:
   quiet_drive(s,0,false);reached=travel(s,Vector2(650,450),0)
  check(s.units[0].band==1,frame+" photographic approach stays in MIDDLE beside the DEEP watch")
  check(reached and photo_then_cover(s,s.mission.objectives[0]),frame+" required usable exhaust photograph")
  check(s.units[0].band==1,frame+" loaded film return uses the authored MIDDLE layer")
  check(travel(s,Vector2(650,820),0) and travel(s,Vector2(2250,820),0) and travel(s,Vector2(2450,700),0),frame+" crosses the masking inner gap with required film")
  quiet_drive(s,0,true)
  check(travel(s,Vector2(2800,1300),0) and travel(s,s.mission.corridors[0].pos,0),frame+" return with required film")
  tick(s,1.)
  check(s.outcome=="won" and s.mission.recovered and s.units[0].alive and s.hull>0,frame+" physical photographic mission victory")
  check(s.tools==stock and s.sirens.size()==2,frame+" authored threats and finite tools preserved")
  check(Sim.valid_snapshot(s.snapshot()),frame+" final archive validates")
  var previous=Sim.Consequences.upgrade({"version":1,"route":"shelf","routes":["shelf"],"facts":{"shelf":"received"},"completed":[6,8]})
  previous.entitlements=Gear.all_items(fit)
  var settled=Campaign.recover(previous,s.mission)
  check(Campaign.valid(settled) and settled.facts.get(Cache.FACT)==Cache.NOTE,frame+" receipt enters first-return campaign account")
  var repeated=Campaign.recover(settled,s.mission)
  check(repeated==settled,frame+" repeated debrief duplicates no reward or history")
  print("CACHE VOYAGE ",frame," trips=",trips," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," outcome=",s.outcome," message=",s.message)
 print("OPTIONAL CACHE JOURNEY CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func photo_then_cover(s,o)->bool:
 # Wait north of the joint, then rehearse this actual same-band exposure.
 # The older ascent rehearsal returns early when already in MIDDLE.
 if not travel(s,Vector2(650,450),0) or not travel(s,Vector2(530,450),0):return false
 if not s.command("frame",{"mode":"wide","focus":o.optical}):return false
 tick(s,3.)
 for n in 40:
  var copy=Sim.new()
  if not copy.restore(s.snapshot()):return false
  if shoot_then_cover(copy,copy.mission.objectives[0]) and copy.hull>=s.hull:break
  tick(s,2.)
 return shoot_then_cover(s,o)
func shoot_then_cover(s,o)->bool:
 if not travel(s,Vector2(530,700),0):return false
 if not s.command("camera"):return false
 # Keep the same exposure deadline, and leave as soon as the real record is
 # secured. Northward withdrawal breaks sight before a slow exposed dive.
 for n in ceili((float(o.get("duration",4.))+2.)*60):
  tick(s,Sim.STEP)
  if o.captured:return travel(s,Vector2(530,450),0)
  if not s.outcome.is_empty():return false
 return false
func quiet_drive(s,id:int,quiet:bool):
 s.command("select",{"unit":id})
 if id==0:
  if s.units[0].silent!=quiet:s.command("silent")
 else:s.command("drone_drive",{"mode":"quiet" if quiet else "transit"})
func travel(s,point:Vector2,id:int)->bool:
 if not s.outcome.is_empty():return s.outcome=="won" and s.units[id].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[id].route.is_empty() and s.units[id].vel.length()<2):break
 s.paused=true
 var reached=s.units[id].alive and s.units[id].pos.distance_to(point)<25
 if not reached:print("CACHE LEG FAILED ",id," target=",point," pos=",s.units[id].pos," time=",s.elapsed," outcome=",s.outcome," message=",s.message)
 return reached
