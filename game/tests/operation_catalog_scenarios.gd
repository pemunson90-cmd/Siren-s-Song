extends RefCounted
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Missions=preload("res://src/campaign/missions.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
const Store=preload("res://src/persistence/save_store.gd")
static func run(t):
 t.check(Missions.make(99).is_empty(),"unknown operation rejects instead of tutorial clamp")
 var live=Sim.new();live.start(0);var before=live.snapshot()
 live.start(999)
 t.check(live.snapshot()==before,"unknown runtime launch preserves the current operation")
 for id in 14:
  var sim=Sim.new();sim.start(id)
  t.check(sim.mission.id==id and Sim.valid_snapshot(sim.snapshot()),"registered existing factory saves: "+str(id))
  var restored=Sim.new();t.check(restored.restore(sim.snapshot()),"existing factory restore: "+str(id))
 var bad=Catalog.definition(10);bad.id=40;bad.behaviors.append("imaginary")
 t.check(not Catalog.register_definition(bad),"unknown behavior definition rejected")
 bad=Catalog.definition(10);bad.id=40;bad.config.source_id=-1
 t.check(not Catalog.register_definition(bad),"malformed builder configuration rejected")
 for source in [2,7,12,13]:
  var definition=Catalog.definition(source);definition.id=100+source
  t.check(Catalog.register_definition(definition),"reuse registered physical configuration "+str(source))
  var sim=Sim.new();sim.start(definition.id)
  t.check(Sim.valid_snapshot(sim.snapshot()),"reused physical configuration saves "+str(source))
  var restored=Sim.new();t.check(restored.restore(sim.snapshot()),"reused physical configuration restores "+str(source))
 for source in [3,4,5,8,9]:
  var alias=Catalog.definition(source);alias.id=200+source
  t.check(not Catalog.register_definition(alias),"identity-bound legacy factory rejects alias "+str(source))
 var invalid=Catalog.definition(10);invalid.id=40;invalid.config.source_id=999
 t.check(not Catalog.register_definition(invalid),"unsupported positive source configuration rejects")
 invalid=Catalog.definition(10);invalid.id=40;invalid.behaviors.erase("warning_plant")
 t.check(not Catalog.register_definition(invalid),"definition cannot omit its physical behavior")
 invalid=Catalog.definition(10);invalid.id=40;invalid.prerequisites=[999]
 t.check(not Catalog.register_definition(invalid),"unknown prerequisite rejects")
 t.check(not Catalog.register_definition(Catalog.definition(10)),"registered identity cannot be overwritten")
 var unknown=Sim.new();unknown.start(0);var archive=unknown.snapshot();archive.mission.id=999
 t.check(not Sim.valid_snapshot(archive),"unknown snapshot identity rejects")
 archive.mission.id="0"
 t.check(not Sim.valid_snapshot(archive),"malformed snapshot identity rejects without runtime error")
 var active=Sim.new();active.start(9);archive=active.snapshot();archive.mission.signal_sources[0].id="unknown_source"
 t.check(not Sim.valid_snapshot(archive),"unknown registered-operation source rejects")
 archive=active.snapshot();archive.mission.expedition_facts["unknown_fact"]="invented"
 t.check(not Sim.valid_snapshot(archive),"unknown active recovered fact rejects")
 var graph=Catalog.definition(10);graph.id=41;graph.prerequisites=[7,8]
 t.check(Catalog.register_definition(graph),"all-prerequisite definition registers")
 t.check(not Catalog.prerequisites_met(41,[7]) and Catalog.prerequisites_met(41,[7,8]),"all prerequisites required by default")
 graph=Catalog.definition(10);graph.id=42;graph.prerequisites=[7,8];graph.prerequisite_mode="any"
 t.check(Catalog.register_definition(graph) and Catalog.prerequisites_met(42,[7]),"explicit any-prerequisite alternative")
 graph=Catalog.definition(10);graph.id=43;graph.prerequisite_mode="invented"
 t.check(not Catalog.register_definition(graph),"unknown prerequisite mode rejects")
 var progress=Consequences.upgrade({"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6,7]})
 for id in range(14,24):
  var d=Catalog.definition(10);d.id=id;d.route="deep";d.prerequisites=[7] if id==14 else [id-1];d.facts.append("synthetic_"+str(id))
  t.check(Catalog.register_definition(d),"isolated authored registry entry accepted: "+str(id))
  var sim=Sim.new();sim.start(id)
  t.check(sim.mission.id==id and Sim.valid_snapshot(sim.snapshot()),"extension normal runtime and snapshot: "+str(id))
  var restored=Sim.new();t.check(restored.restore(sim.snapshot()),"extension restore: "+str(id))
  t.check(not sim.warning_chain_context().is_empty(),"registered plant behavior participates in runtime")
  var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress,"active":sim.snapshot()}
  t.check(Store.new().valid(data),"extension active current-save admission")
  if id==14:
   var store=Store.new();store.path="user://operation-catalog-test.save"
   t.check(store.save(data) and store.load_game()==data,"extension actual checksummed active save roundtrip")
   for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
  var forged=sim.mission.duplicate(true);forged.recovered=true;forged.chosen_route="shelf"
  for site in forged.objectives:site.captured=true
  t.check(id not in Campaign.recover(progress,forged).completed,"captured flags cannot invent physical plant receipt")
  var unearned=Campaign.recover(progress,sim.mission)
  t.check(id not in unearned.completed,"field observation alone cannot complete extension")
  # Controlled positions; actual production commands earn the receipt and recovery.
  sim.sirens=[]
  sim.units[0].pos=Vector2(480,1000);sim.units[0].vel=Vector2.ZERO
  t.check(sim.command("chain_power",{"mode":"backup"}),"extension local backup action")
  sim.units[0].pos=Vector2(1520,1000)
  t.check(sim.command("chain_route",{"output":"service"}) and sim.command("chain_send"),"extension real output and acoustic receipt")
  sim.units[0].pos=Vector2(180,1000);sim.paused=false;sim.advance(Sim.STEP)
  t.check(sim.outcome=="won" and Sim.valid_snapshot(sim.snapshot()),"extension ordinary recovery validates")
  var mission=sim.mission
  progress=Campaign.recover(progress,mission)
  t.check(id in progress.completed and Campaign.valid(progress),"recovered extension progression remains valid: "+str(id))
 for key in Catalog.fact_keys():progress.notes[key]="retained field note"
 t.check(progress.notes.size()>16 and Campaign.valid(progress),"registered note content exceeds old sixteen-note capacity")
 var store=Store.new();store.path="user://operation-catalog-completed.save"
 var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress,"active":null}
 t.check(store.save(data) and store.load_game()==data,"expanded recovered progression survives checksummed save")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 t.check(progress.completed.size()>8 and progress.history.size()>5,"registered content exceeds old completion/history capacities")
 var replay=Missions.make(23)
 for site in replay.objectives:site.captured=true
 replay.recovered=true;replay.chosen_route="shelf";replay.warning_chain.result={"proof":"local_receipt"}
 replay.expedition_facts={"chain_west":"rewritten by replay"}
 var committed=Campaign.recover(progress,replay)
 t.check(committed.history==progress.history and committed.facts==progress.facts,"extension replay preserves first recovered history and facts")
 replay.expedition_facts={"unknown":"invented"}
 t.check(Campaign.recover(progress,replay)==progress,"unknown recovered content rejected without changing progress")
 var malformed=progress.duplicate(true);malformed.completed.append(999)
 t.check(not Campaign.valid(malformed),"unregistered completion rejected")
 malformed=progress.duplicate(true);malformed.notes["unknown_fact"]="invented"
 t.check(not Campaign.valid(malformed),"unknown content note rejected")
 malformed=progress.duplicate(true);malformed.history[0].mission="14"
 t.check(not Campaign.valid(malformed),"malformed history identity rejects without runtime error")
 malformed=progress.duplicate(true);malformed.completed[0]=6.0
 t.check(not Campaign.valid(malformed),"noninteger completion identity rejects")
 malformed=progress.duplicate(true);malformed.completed.erase(14)
 t.check(not Campaign.valid(malformed),"registered prerequisite integrity enforced")
 preload("res://tests/authored_plant_scenarios.gd").run(t)
