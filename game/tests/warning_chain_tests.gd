extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const WEST=Vector2(480,1000)
const EAST=Vector2(1520,1000)
const GATE=Rect2(880,960,240,120)
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func tick(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func fresh(fitted:Dictionary={"quietus":"","drone_a":"","drone_b":""}):
 var s=Sim.new();s.start(10,"disruption",{"fitted":fitted});s.sirens=[];return s
func at(s,id:int,pos:Vector2)->void:
 s.units[id].pos=pos;s.units[id].vel=Vector2.ZERO;s.command("select",{"unit":id})
func progress()->Dictionary:
 return {"version":2,"route":"shelf","routes":["shelf"],"facts":{"shelf":"Recovered shelf warning"},"completed":[6,8],"notes":{},"references":{},"entitlements":["drone_sampler"],"history":[],"selected_thread":""}
func binary_roundtrip(s)->bool:
 var store=Store.new();store.path="user://warning-chain-tests.save"
 var data={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"disruption","settings":{},"expedition":progress(),"active":s.snapshot()}
 var saved=store.save(data);var loaded=store.load_game() if saved else {};var copy=Sim.new()
 var valid=saved and loaded==data and copy.restore(loaded.active)
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 return valid
func power_and_service()->void:
 var s=fresh();at(s,1,WEST)
 s.command("route",{"point":WEST+Vector2(100,0)});s.command("route_edit",{"index":0,"point":WEST+Vector2(140,0)})
 var program=s.route_goals();var undo=s.units[1].route_undo.duplicate(true)
 check(s.command("chain_power",{"mode":"connect"}) and s.warning_chain_context().power=={"source":"umbilical","unit":1} and s.units[1].hold=="HOLD","explicit own-body connection supplies the distant plant while holding its accepted course")
 check(s.route_goals()==program and s.units[1].route_undo==undo and binary_roundtrip(s),"connected route and undo survive the ordinary checksummed binary archive")
 var before=s.snapshot()
 check(not s.command("route",{"point":GATE.get_center()}) and s.snapshot()==before,"rejected movement preserves the exact live umbilical and accepted program while paused")
 check(not s.command("route_edit",{"index":99}) and s.warning_chain_context().power.source=="umbilical","rejected program edit cannot disconnect shore power")
 at(s,0,EAST);before=s.snapshot();var context=s.warning_chain_context();context.result["fake"]=true;s.warning_chain_context(1)
 check(s.snapshot()==before,"plant status and per-craft readiness are read-only copies")
 check(s.command("chain_route",{"output":"service"}) and not s.blocked(GATE.get_center()) and s.segment_safe(Vector2(780,1020),Vector2(1220,1020),24),"local powered selector opens actual crosslink collision, sight and navigable water")
 check(s.command("chain_send") and s.warning_chain_context().result.proof=="local_receipt" and s.all_records(),"actual east-to-west acoustic reception commissions the local service warning")
 check(s.mission.record.begins_with("SERVICE RECEIPT"),"ordinary debrief names the actual verified local outcome rather than both possible branches")
 check(s.noises.any(func(n):return n.label=="SERVICE WARNING" and n.pos==EAST and n.radius==1400),"service warning uses its own finite physical emitter instead of changing remote enemy intent")
 before=s.snapshot()
 check(not s.command("chain_send") and not s.command("chain_route",{"output":"mast"}) and s.snapshot()==before,"successful plant output cannot be retriggered or rewritten as an unlimited lure")
 check(binary_roundtrip(s),"opened shutter and same-time verified receipt survive binary save and restore")
 s.command("select",{"unit":1});check(s.command("route",{"point":WEST+Vector2(-100,0)}) and s.warning_chain_context().power.source=="off" and s.all_records(),"accepted power-craft movement disconnects immediately without erasing commissioned output")
 at(s,0,Vector2(180,1000));tick(s,Sim.STEP)
 check(s.outcome=="won" and binary_roundtrip(s),"physical western service mouth recovers the current mission without all bare frames returning")
 var committed=Campaign.recover(progress(),s.mission)
 check(Campaign.valid(committed) and committed.facts.get("warning_chain","")=="service_local_receipt","first successful campaign recovery records only the local branch's proved reception")
 var mast=fresh();at(mast,0,WEST);mast.command("chain_power",{"mode":"backup"});at(mast,0,EAST);mast.command("chain_route",{"output":"mast"});mast.command("chain_send");at(mast,0,mast.mission.extraction);tick(mast,Sim.STEP)
 check(mast.outcome=="won" and Campaign.recover(committed,mast.mission).facts.warning_chain==committed.facts.warning_chain,"a completed mission replay cannot overwrite the first committed network outcome")
func backup_loss_and_gear()->void:
 var s=fresh();at(s,1,WEST);s.command("chain_power",{"mode":"connect"});at(s,0,EAST);s.units[1].battery=.0001;tick(s,Sim.STEP)
 check(not s.units[1].alive and s.warning_chain_context().power.source=="off" and not s.command("chain_route",{"output":"mast"}),"actual battery loss removes remote power and leaves the unfinished job intact")
 at(s,0,WEST);check(s.command("chain_power",{"mode":"backup"}),"bare Quietus can locally restart the authored backup after losing its power craft")
 check(s.acoustic_feedback().pulses.any(func(p):return p.label=="BACKUP GENERATOR START" and p.pos==WEST and p.radius==900),"public acoustic feedback exposes the actual finite backup start")
 var before=s.snapshot();check(not s.command("chain_power",{"mode":"backup"}) and s.snapshot()==before,"backup start is a once-only finite plant emission")
 at(s,0,EAST);s.command("chain_route",{"output":"mast"});check(s.command("chain_send") and s.warning_chain_context().result.proof=="mast_transmission" and s.blocked(GATE.get_center()),"powered northern hardware proves transmission without inventing external receipt or opening service water")
 check(s.mission.record.begins_with("MAST TRANSMISSION") and "external reception unknown" in s.mission.record,"ordinary mast debrief cannot imply that a distant population acknowledged it")
 check(binary_roundtrip(s),"lost helper, backup supply and mast transmission form a valid current binary save")
 var fit=fresh({"quietus":"","drone_a":"drone_sampler","drone_b":"drone_deep_cells"});at(fit,0,WEST);fit.command("chain_power",{"mode":"backup"})
 at(fit,2,EAST);check(not fit.command("chain_route",{"output":"mast"}),"bare drone cannot configure the specialist field terminal")
 at(fit,1,EAST);check(fit.command("chain_route",{"output":"service"}) and fit.command("chain_send"),"the recovered fitted sampler operates the remote plant while Quietus takes another physical role")
 var busy=fresh({"quietus":"","drone_a":"drone_sampler","drone_b":"drone_deep_cells"});at(busy,1,WEST);busy.command("chain_power",{"mode":"connect"});at(busy,2,WEST+Vector2(30,0));busy.units[2].battery=.0001;tick(busy,Sim.STEP);busy.command("select",{"unit":1})
 check(not busy.salvage_context("drone_deep_cells").ready and not busy.command("salvage",{"item":"drone_deep_cells"}),"a connected power body cannot simultaneously begin a module winch")
func physical_outputs()->void:
 for output in ["service","mast"]:
  var s=Sim.new();s.start(10);at(s,1,WEST);s.command("chain_power",{"mode":"connect"});at(s,0,EAST);s.command("chain_route",{"output":output});s.command("chain_send");tick(s,Sim.STEP)
  var origin=EAST if output=="service" else Vector2(1000,400)
  check(s.acoustic_feedback().pulses.any(func(p):return p.pos==origin and p.label==("SERVICE WARNING" if output=="service" else "NORTH MAST WARNING")),"public %s footprint matches the source actually heard by guards"%output)
  if output=="service":check(s.acoustic_feedback().pulses.any(func(p):return p.label=="SERVICE SHUTTER" and p.pos==GATE.get_center()),"public machinery footprint includes the short physical shutter opening")
  check(s.sirens.all(func(g):return g.target==-1 and g.mode=="INVESTIGATE" and g.goal.distance_to(origin)<80),"actual %s output sends both guards toward heard hardware without a visual target"%output)
 var blocked=fresh();at(blocked,0,WEST);blocked.command("chain_power",{"mode":"backup"});at(blocked,0,EAST);blocked.command("chain_route",{"output":"service"})
 # A mechanical obstructed-receiver fixture, not an authored reachable save.
 blocked.mission.structures=[GATE];blocked._build_navigation()
 check(blocked.command("chain_send") and not blocked.all_records() and blocked.warning_chain_context().result.is_empty(),"an actual obstructed acoustic path cannot manufacture a service receipt")
 blocked.mission.structures=[];blocked._build_navigation();blocked.command("chain_route",{"output":"mast"})
 check(blocked.command("chain_send") and blocked.warning_chain_context().result.proof=="mast_transmission" and binary_roundtrip(blocked),"failed local service still has a complete powered mast fallback without repeating a lure")
 var s=fresh();at(s,0,WEST);var before=s.snapshot()
 check(not s.command("chain_route",{"output":"connect"}) and not s.command("chain_power",{"mode":"send"}) and s.snapshot()==before,"public power and selector commands reject each other's action IDs without side effects")
 s.units[0].vel=Vector2(2,0);check(not s.command("chain_power",{"mode":"connect"}),"shore connection requires settled ground velocity")
 s.units[0].vel=Vector2.ZERO;s.command("chain_power",{"mode":"connect"});check(s.command("hold") and s.warning_chain_context().power.source=="off","ordinary manual release disconnects the exact power body before any physics tick")
 check(s.observable_sites().size()==2 and s.observable_sites()[0].site_id=="chain_west" and s.observable_sites()[1].site_id=="chain_east" and s.warning_chain_context(3).is_empty(),"only two genuine control stations enter public world input; invalid craft projection stays empty")
 for value in [[],{}, {"power":"umbilical","unit":3,"output":"","opened":false,"sends":[],"result":{}}]:
  var bad=s.snapshot();bad.mission.warning_chain=value;check(not Sim.valid_snapshot(bad),"malformed current plant state rejects cleanly")
func movement_release()->void:
 for order in ["queued_route","route_edit","route_insert","route_delete","route_undo"]:
  var s=fresh();at(s,1,WEST);s.command("route",{"point":WEST+Vector2(100,0)});s.command("route_edit",{"index":0,"point":WEST+Vector2(140,0)});s.command("chain_power",{"mode":"connect"})
  var accepted=false
  if order=="queued_route":s.command("queue");accepted=s.command("route",{"point":WEST+Vector2(180,0)})
  else:accepted=s.command(order,{"index":0,"point":WEST+Vector2(180,0)})
  check(accepted and s.warning_chain_context().power.source=="off" and s.units[1].hold=="" and Sim.valid_snapshot(s.snapshot()),"accepted paused %s releases only the supplying craft's connection"%order)
 var s=fresh();at(s,1,WEST);s.command("chain_power",{"mode":"connect"});s.command("select",{"unit":0})
 check(s.command("route",{"point":Vector2(1000,1800)}) and s.warning_chain_context().power.source=="umbilical" and s.units[1].hold=="HOLD","another craft's accepted movement cannot disconnect the actual power body")
func finish()->void:
 print("WARNING CHAIN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=fresh();check(s.has_method("warning_chain_context"),"Warning Chain exposes actual positional plant power and output controls")
 if not s.has_method("warning_chain_context"):finish();return
 check(s.warning_chain_context().power.source=="off" and not s.all_records() and not s.camera_context().ready,"fresh plant begins unpowered and cannot be completed by another generic camera hold")
 for o in s.mission.objectives:o.captured=true
 check(not s.all_records(),"old collection flags cannot substitute for a commissioned physical warning output")
 var other=Sim.new();other.start(9);check(other.warning_chain_context().is_empty(),"the plant's model applies only to the existing Warning Chain chapter")
 power_and_service();backup_loss_and_gear();physical_outputs();movement_release();finish()
