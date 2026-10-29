extends "res://tests/calder_trench_journey_tests.gd"
const S=preload("res://src/campaign/sorley_rescue.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const C=preload("res://src/campaign/expedition_campaign.gd")
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
const Graph=preload("res://src/campaign/route_map/route_graph.gd")
const Endings=preload("res://src/campaign/endings.gd")
const Ledger=preload("res://src/campaign/ledger/ledger.gd")
const Store=preload("res://src/persistence/save_store.gd")
# Evidence only: observes the ordinary simulation step without changing it.
class ObservedSim:
 extends "res://src/simulation/simulation.gd"
 var peak_hunt=0.
 var lock_frames=0
 var max_lock=0.
 func _tick(dt:float)->void:
  super._tick(dt)
  peak_hunt=maxf(peak_hunt,float(mission.get("reconnaissance",{}).get("hunt",0.)))
  for guard in sirens:
   if guard.lock>0:lock_frames+=1;max_lock=maxf(max_lock,guard.lock)
# Wait for the actual authored depth duration, including carried-survivor ascent.
static func dive(s,band)->bool:
 if s.units[0].band==band and s.units[0].transition.is_empty():return true
 if not s.command("depth",{"band":band}):return false
 tick(s,float(s.units[0].transition.remaining)+.2)
 return s.units[0].band==band and s.units[0].transition.is_empty()
func progress()->Dictionary:
 return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch"},"completed":[6],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func run():
 var p=progress()
 check(C.valid(p) and not Catalog.accessible(41,p),"old progress loads with no hidden rescue unlocked")
 check(not Graph.build([0,1,2,3,4,5],p,{},5).nodes.any(func(n):return n.id==41),"route graph has no hidden node")
 p.facts.glass_record_37_bonus="A survivor on recovered film"
 check(Catalog.accessible(41,p),"bonus photograph alone opens the rescue")
 p=progress()
 for id in [9,16]:
  var m=Catalog.make(id);var log=m.objectives.filter(func(o):return o.get("sorley_log",false))
  check(log.size()==1 and log[0].optional and log[0].site_id not in m.required_site_ids,"host log is optional and outside required task ids "+str(id))
  var required=m.objectives.filter(func(o):return not o.get("optional",false)).map(func(o):return o.pos)
  required.append_array(m.signal_sources.map(func(o):return o.pos))
  check(required.all(func(pos):return pos.distance_to(log[0].pos)>300),"log detours from required work "+str(id))
  var bits="100" if id==9 else "001"
  m.expedition_facts={"sorley_boy":bits}
  p=Consequences.retain(p,m)
  check(C.valid(p),"merged local log notes remain valid "+str(id))
  check(Catalog.accessible(41,p)==(id==16),"two logs unlock, one does not "+str(id))
 for id in [9,16,14]:
  var local=Sim.new();local.start(id)
  var log=local.mission.objectives.filter(func(o):return o.get("sorley_log",false))[0]
  var log_index=local.mission.objectives.find(log)
  check(local.camera_context().target!=log_index,"remote locker does not displace primary camera guidance "+str(id))
  var anchors=[local.mission.start,local.mission.extraction]
  anchors.append_array(local.mission.corridors.map(func(c):return c.pos))
  anchors.append_array(local.mission.objectives.filter(func(o):return not o.get("optional",false)).map(func(o):return o.pos))
  anchors.append_array(local.mission.signal_sources.map(func(o):return o.pos))
  check(anchors.all(func(pos):return pos.distance_to(log.pos)>300.),"locker detours away from launch, mandatory work and recovery "+str(id))
  check(not local.path(local.mission.start,log.pos).is_empty() and not local.path(log.pos,local.mission.extraction).is_empty(),"physical navigation connects optional locker and recovery "+str(id))
  if id==14:check(log.pos.distance_to(local.mission.extraction)<600.,"east side pocket is a short recovery-side detour")
  check(local.Depth.clear(local,log.pos,log.pos,1,24.),"locker is navigable settled MIDDLE water "+str(id))
  var old=local.snapshot();old.mission.objectives=old.mission.objectives.filter(func(o):return not o.get("sorley_log",false))
  check(Sim.valid_snapshot(old) and Sim.new().restore(old),"pre-log active host save restores "+str(id))
  # Own-position fixture isolates real six-second local work from the host's full voyage.
  local.units[0].pos=log.pos;local.units[0].vel=Vector2.ZERO
  var context=local.camera_context()
  check(context.target==log_index and context.ready and context.text.contains("SORLEY") and context.text.contains("passive listen 6s"),"nearby locker exposes exact local six-second work guidance "+str(id))
  check(local.command("camera"),"local locker work starts "+str(id))
  tick(local,6.2)
  check(log.captured and local.mission.expedition_facts.get("sorley_boy","") in ["100","010","001"],"settled local work receives its one log bit "+str(id))
  if id==9:
   check(local.mission.signal_sources.all(func(source):return not source.located) and local.extraction_corridors().all(func(c):return not c.available),"optional locker neither acquires required signals nor opens recovery")
   check(local.camera_context().text==preload("res://src/presentation/status_text/status_table.gd").FALLBACK,"collected side log preserves primary no-exact-source camera guidance")
 var last=Catalog.make(14).objectives.filter(func(o):return o.get("sorley_log",false))
 check(last.size()==1 and last[0].optional and last[0].pos.x>3000,"third locker is in the eastern detour")
 var bad=p.duplicate(true);bad.notes.sorley_boy="arbitrary"
 check(not C.valid(bad),"corrupt log encoding rejected")
 bad=p.duplicate(true);bad.notes=[]
 check(not C.valid(bad),"malformed notes rejected without crash")
 var s=ObservedSim.new();s.start(41,"endurance",{"tool_racks":{"quietus":{},"drone_a":{},"drone_b":{}}})
 check(Catalog.valid_definition(Catalog.definition(41)) and Sim.valid_snapshot(s.snapshot()),"rescue definition and initial save validate")
 for preset in ["standard","accessible"]:
  var economy=preload("res://src/campaign/economy.gd").new_state(preset)
  economy.stock={"scrap":0,"cells":0,"alloy":0}
  check(preload("res://src/campaign/economy.gd").charge_launch(economy,preload("res://src/equipment/equipment_catalog.gd").default_loadout()),preset+" empty resources still launches bare")
  preload("res://src/campaign/economy.gd").apply_launch(economy,s)
  check(s.hull==100. and s.units[1].battery==100.,preset+" same physical launch rules preserve the proved bare route")
 var tools=s.tools.duplicate(true)
 # Actual ordinary bare route: long southern contour in DEEP, local SHALLOW winch.
 var ok=dive(s,2) and go(s,Vector2(1600,1500)) and go(s,Vector2(1250,980)) and dive(s,1) and dive(s,0) and go(s,Vector2(1420,980))
 print("SORLEY APPROACH ",ok," ",s.message," time=",s.elapsed," hull=",s.hull)
 if ok:
  check(not s.all_records() and s.mission.witness_evacuation.state=="at_berth","record cannot replace a physical pod winch")
  ok=s.command("salvage",{"item":"witness_capsule"})
  tick(s,1.5)
  var snapshot=s.snapshot();var restored=Sim.new()
  check(Sim.valid_snapshot(snapshot) and restored.restore(snapshot),"partial physical winch saves and restores")
  tick(s,2.6)
  print("BARE LOADED ",s.mission.witness_evacuation," guards=",s.sirens.map(func(g):return [g.pos,g.lock,g.band]))
  ok=ok and s.mission.witness_evacuation.state=="carried"
  check(s.message.contains("south boat lift") and not s.message.contains("southeast"),"loaded rescue HUD names the actual south boat lift")
  check(s._camera_context_base().text.contains("south boat lift") and not s.camera_context().text.contains("sorley_boy"),"carried rescue pod keeps physical landing guidance without a raw campaign fact key")
  check(not s.command("witness_land"),"remote landing rejected")
  ok=ok and go(s,Vector2(1250,980))
  ok=ok and dive(s,1) and dive(s,2) and go(s,Vector2(1600,1600)) and go(s,Vector2(300,1500)) and dive(s,1)
  ok=ok and s.command("witness_land")
  tick(s,.1)
 check(ok and s.outcome=="won" and s.mission.recovered,"bare launch physically carries and lands the boy with authored Sirens")
 check(s.lock_frames>0 and not s.mission.sorley_quiet,"bare skill route actually receives a lock warning while escaping the winch")
 check(s.tools==tools and s.sirens.size()==2 and s.units[0].alive,"bare voyage spends no finite tools and retains live threats")
 print("SORLEY BARE outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," lock_samples=",s.lock_frames," max_lock=",s.max_lock," peak_hunt=",s.peak_hunt," quiet=",s.mission.sorley_quiet," hunt=",s.recon_feedback()," message=",s.message)
 check(Sim.valid_snapshot(s.snapshot()),"completed rescue snapshot validates")
 var recovered=C.recover(p,s.mission)
 check(recovered.facts.get("sorley_boy")=="rescued" and C.valid(recovered),"physical bare arrival commits exactly one rescue fact")
 var e={"stock":{"scrap":0,"cells":0,"alloy":0},"report":""}
 S.credit(e,p,recovered);check(e.stock.scrap==0 and e.stock.cells==0 and e.report.contains("PILOTAGE CHARTS"),"ordinary rescue receives pilotage charts")
 S.credit(e,recovered,recovered);check(e.stock.scrap==0,"replay cannot duplicate reward")
 var fleet=ObservedSim.new();fleet.start(41,"endurance",{"tool_racks":{"quietus":{},"drone_a":{"emp":1},"drone_b":{}}})
 var fleet_tools=fleet.tools.duplicate(true)
 fleet.command("select",{"unit":1})
 # Quiet propulsion limits the approach report; one local Disrupt covers the winch.
 # Return west of the southern shard instead of passing the sentinel after its stun ends.
 fleet.command("drone_drive",{"mode":"quiet"})
 var fleet_ok=unit_dive(fleet,2) and unit_go(fleet,Vector2(1600,1500)) and unit_go(fleet,Vector2(1250,980)) and unit_dive(fleet,1) and unit_dive(fleet,0) and unit_go(fleet,Vector2(1420,980))
 if fleet_ok:
  print("FLEET APPROACH ",fleet.units[1].pos," guards=",fleet.sirens.map(func(g):return [g.pos,g.lock,g.band]))
  fleet.command("emp")
  fleet_ok=fleet.command("salvage",{"item":"witness_capsule"});tick(fleet,4.05)
  print("FLEET LOADED ",fleet.mission.witness_evacuation," guards=",fleet.sirens.map(func(g):return [g.pos,g.lock,g.stun,g.band]))
  fleet_ok=fleet_ok and fleet.mission.witness_evacuation.state=="carried" and unit_go(fleet,Vector2(1250,980)) and unit_go(fleet,Vector2(1100,1100)) and unit_go(fleet,Vector2(1100,1700)) and unit_go(fleet,Vector2(300,1500)) and unit_dive(fleet,1)
  fleet_ok=fleet_ok and fleet.command("witness_land");tick(fleet,.1)
 print("SORLEY FLEET outcome=",fleet.outcome," time=",fleet.elapsed," hull=",fleet.hull," lock_samples=",fleet.lock_frames," max_lock=",fleet.max_lock," peak_hunt=",fleet.peak_hunt," quiet=",fleet.mission.sorley_quiet," hunt=",fleet.recon_feedback()," tools=",fleet.tools," message=",fleet.message)
 check(fleet_ok and fleet.outcome=="won","independent drone physically brings the boy home while Quietus waits at lift")
 var quiet=C.recover(p,fleet.mission)
 check(quiet.facts.get("sorley_boy")=="rescued_quiet" and fleet.tools.emp==fleet_tools.emp-1,"real intact lock-free drone voyage earns quiet tier using one finite Disrupt")
 S.credit(e,p,quiet);check(e.stock.scrap==0 and e.stock.cells==0,"quiet intact drone earns charts without supplies")
 var ending=progress();ending.completed=[6,7,9,11,12];ending.facts.confluence_route="concealed"
 check(Endings.resolve(ending).story.contains(S.LEFT),"unfound boy has different ending placeholder")
 ending.facts.sorley_boy="rescued"
 check(Endings.resolve(ending).story.contains(S.RESCUED) and Endings.resolve(ending).id=="silent_exodus","rescue epilogue preserves ending family and thread")
 check(Ledger.build(ending,{})[0].rows.has(S.RESCUED) and Ledger.build(progress(),{})[0].rows.has(S.LEFT),"ledger distinguishes rescue and no recorded landing")
 var archive={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":recovered,"active":s.snapshot()}
 var store=Store.new();store.path="user://sorley-test.save"
 check(store.save(archive) and store.load_game()==archive,"current binary archive roundtrips logs, rescue and active mission")
 S.enabled=false
 check(not Catalog.accessible(41,p) and not Graph.build([0,1,2,3,4,5],recovered,{},5).nodes.any(func(n):return n.id==41),"flag hides unlocked and recovered rescue everywhere")
 check(not Catalog.make(9).objectives.any(func(o):return o.get("sorley_log",false)) and S.line(recovered).is_empty() and preload("res://src/campaign/voices/voices.gd").row(41,"brief").is_empty(),"flag removes lockers, epilogue and voice additions")
 check(C.valid(recovered),"disabled experiment still accepts existing saved rescue")
 S.enabled=true
 print("SORLEY RESCUE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)

# Ordinary selected-craft movement, no own-position injections for the rescue voyages.
func unit_go(s,point)->bool:
 var body=s.units[s.selected]
 if not s.command("route",{"point":point}):return false
 for n in 18000:
  tick(s,Sim.STEP)
  if not s.outcome.is_empty() or (body.route.is_empty() and body.vel.length()<2.):break
 return body.alive and body.pos.distance_to(point)<25.
func unit_dive(s,band:int)->bool:
 if not s.command("depth",{"band":band}):return false
 tick(s,float(s.units[s.selected].transition.remaining)+.2)
 return s.units[s.selected].band==band and s.units[s.selected].transition.is_empty()
