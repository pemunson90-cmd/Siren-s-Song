extends SceneTree
const Racks=preload("res://src/equipment/tool_racks.gd")
const Career=preload("res://src/campaign/career/career_state.gd")
const Run=preload("res://src/campaign/runs/run_state.gd")
const Sim=preload("res://src/campaign/runs/expedition_run.gd")
const Rider=preload("res://src/presentation/career/rider_dive.gd")
const Active=preload("res://src/campaign/mode_active.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var fit=Equipment.default_loadout()
 var heavy=Racks.template("endurance");heavy.quietus.recon=9
 var light=Racks.template("endurance")
 check(Racks.reason(fit,heavy).is_empty(),"heavy tool fixture remains launchable")
 check(Racks.winch_capacity({"launch_equipment":fit,"tool_racks":heavy},0)<Racks.winch_capacity({"launch_equipment":fit,"tool_racks":light},0),"extra charges surrender real winch cargo")
 var career=Career.new_career();career.tool_racks=heavy
 var before=career.economy.stock.duplicate()
 var launched=Career.launch(career,"brannock_watch",false)
 check(launched.in_flight and Career.valid(launched),"career optional racks launch and validate")
 check(launched.economy.stock.scrap<before.scrap and launched.economy.stock.cells<before.cells,"career pays extras from its own supplies")
 var dive=Rider.new();dive.configure({});dive.start(0,"endurance",{"fitted":fit,"tool_racks":launched.tool_racks})
 check(dive.mission.tool_racks==heavy,"career launch carries owner stock")
 var envelope=Active.capture("career",launched,dive)
 check(Active.valid(envelope,launched,"career"),"career racks resume with checked launch budget")
 envelope.simulation.mission.tool_racks.drone_a.emp=1
 check(not Active.valid(envelope,launched,"career"),"injected ownership is refused")
 var legacy=Career.new_career();legacy.active="brannock_watch";legacy.in_flight=true;legacy.serial=1
 dive.start(0,"endurance",{"fitted":fit})
 check(Active.valid(Active.capture("career",legacy,dive),legacy,"career"),"legacy pooled active career remains readable")
 var run_state=Run.new_run(12345)
 var stock=run_state.stock.duplicate()
 run_state.tool_racks=Racks.empty()
 var run_launch=Run.launch(run_state,false)
 var sim=Sim.new();sim.configure(run_launch);sim.start(0)
 check(sim.mission.tool_racks==Racks.empty(),"expedition bare launch does not mint tools")
 check(sim.result().tools==stock,"unloaded expedition supplies stay reserved")
 check(Active.valid(Active.capture("runs",run_launch,sim),run_launch,"runs"),"expedition racks resume with checked budget")
 var old_run=Run.new_run(42);old_run.in_flight=true
 var old_sim=Sim.new();old_sim.configure(old_run);old_sim.start(0)
 check(not old_sim.mission.has("tool_racks") and Active.valid(Active.capture("runs",old_run,old_sim),old_run,"runs"),"legacy pooled active expedition remains readable")
 var malformed=run_launch.duplicate(true);malformed.stock.emp="empty"
 check(not Run.valid(malformed),"malformed finite stock is rejected before allocation arithmetic")
 var piled={}
 for id in Racks.Tools.ids():piled[id]=9
 var auto=Racks.from_stock(piled)
 check(Racks.available(auto,piled) and Racks.reason(fit,auto).is_empty(),"accumulated stock allocates a legal cargo load")
 check(Racks.total(auto,"knock")==2 and Racks.total(auto,"hull_patch")==1,"automatic allocation respects protected tool caps")
 var supplied={}
 for seed in 100:
  supplied=Run.new_run(seed)
  if supplied.scarcity==0:break
 var distributed=Run.launch(supplied,false)
 var concentrated=Racks.empty();concentrated.quietus=supplied.stock.duplicate()
 supplied.tool_racks=concentrated
 var packed=Run.launch(supplied,false)
 sim.configure(packed);sim.start(0)
 check(packed.in_flight and Run.valid(packed),"expedition accepts a finite-stock tool-heavy allocation")
 check(Racks.winch_capacity(sim.mission,0)<Racks.winch_capacity({"launch_equipment":fit,"tool_racks":distributed.tool_racks},0),"expedition concentrating finite stock gives up a real winch place")
 check(sim.result().tools==supplied.stock,"owner redistribution preserves expedition supply totals")
 var full=Run.launch(Run.new_run(12345),false)
 sim.configure(full);sim.start(0)
 var cargo=Racks.winch_capacity(sim.mission,0)
 check(cargo==Racks.winch_capacity({"launch_equipment":fit,"tool_racks":full.tool_racks},0),"expedition uses shared per-owner cargo math")
 full.tool_racks.quietus.recon=9
 check(not Run.valid(full),"expedition cannot load tools beyond finite stock")
 print("MODE TOOL CARGO CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
