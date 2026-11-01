extends RefCounted
const HandLegs=preload("res://tests/hand_legs.gd") # 127: journeys place their own straight legs.
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Store=preload("res://src/persistence/save_store.gd")
static func travel(sim,point:Vector2)->bool:
 if not HandLegs.route(sim,point):return false
 sim.paused=false
 for n in 12000:
  sim.advance(Sim.STEP)
  if not sim.outcome.is_empty():return sim.outcome=="won"
  if sim.units[0].pos.distance_to(point)<35 and sim.units[0].vel.length()<2:return true
 return false
static func run(t):
 var d=Catalog.definition(10);d.id=50;d.prerequisites=[7];d.route="deep"
 d.factory="res://src/campaign/plant_operation.gd"
 d.config={"source_id":10,"history":true,"title":"ISOLATED TEST PLANT","brief":"Different chart and physical stations.","world_size":Vector2(2400,2400),"start":Vector2(400,2100),"extraction":Vector2(300,450),"rocks":[Rect2(1100,850,160,200),Rect2(1100,1250,160,400)],"plant":{"inlet":Vector2(750,1150),"panel":Vector2(1550,1150),"mast":Vector2(1800,600),"shutter":Rect2(1100,1050,160,200),"recovery":Vector2(400,1150)}}
 t.check(Catalog.register_definition(d),"authored geography/configuration registers without chapter branches")
 if Catalog.definition(50).is_empty():return
 var sim=Sim.new();sim.start(50)
 t.check(sim.mission.title==d.config.title and sim.mission.brief==d.config.brief and sim.mission.rocks==d.config.rocks and sim.mission.world_size==d.config.world_size and sim.mission.start==d.config.start and sim.mission.extraction==d.config.extraction,"registered authored configuration changes actual world content")
 t.check(sim.mission.objectives[0].pos==d.config.plant.inlet and sim.warning_chain_context().stations[1].pos==d.config.plant.panel,"physical objectives and public stations use authored layout")
 t.check(Sim.valid_snapshot(sim.snapshot()),"new geography has a valid normal active save")
 t.check(travel(sim,d.config.plant.inlet) and sim.command("chain_power",{"mode":"backup"}),"normal travel reaches different inlet and powers it locally")
 var active=sim.snapshot();var restore=Sim.new()
 t.check(restore.restore(active),"authored powered plant restores without reverting geography")
 sim=restore
 t.check(travel(sim,d.config.plant.panel) and sim.command("chain_route",{"output":"service"}) and sim.command("chain_send"),"different terrain and panel earn real acoustic receipt")
 t.check(sim.mission.warning_chain.result.get("origin")==d.config.plant.panel and not sim.blocked(d.config.plant.shutter.get_center()),"real emitter and collision use authored positions")
 t.check(travel(sim,d.config.plant.recovery) and sim.outcome=="won" and Sim.valid_snapshot(sim.snapshot()),"routed physical recovery completes changed-world operation")
 var progress={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6,7],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":""}
 progress=Campaign.recover(progress,sim.mission)
 var store=Store.new();store.path="user://authored-plant-test.save"
 var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress,"active":sim.snapshot()}
 t.check(50 in progress.completed and Campaign.valid(progress) and store.save(data) and store.load_game()==data,"authored operation recovery and current save roundtrip end to end")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 var bad=d.duplicate(true);bad.id=51;bad.config.plant.inlet=Vector2(-100,0)
 t.check(not Catalog.register_definition(bad),"out-of-world physical configuration rejects")
 bad=d.duplicate(true);bad.id=51;bad.config["unsupported"]=true
 t.check(not Catalog.register_definition(bad),"unsupported authored override rejects")
 bad=d.duplicate(true);bad.id=51;bad.config.rocks=["invalid"]
 t.check(not Catalog.register_definition(bad),"malformed authored geometry rejects")
 bad=d.duplicate(true);bad.id=51;bad.config.start=Vector2(2320,2100)
 t.check(not Catalog.register_definition(bad),"authored layout cannot spawn a drone beyond world bounds")
 bad=d.duplicate(true);bad.id=52;bad.config.extraction=d.config.plant.shutter.get_center()
 t.check(not Catalog.register_definition(bad),"authored extraction cannot lie inside the closed physical shutter")
 for dimensions in [Vector2(2401,2400),Vector2(6040,2400)]:
  bad=d.duplicate(true);bad.id=330;bad.config.world_size=dimensions
  t.check(not Catalog.register_definition(bad),"authored dimensions share runtime grid and maximum bounds "+str(dimensions))
