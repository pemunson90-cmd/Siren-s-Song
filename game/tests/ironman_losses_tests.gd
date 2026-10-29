extends SceneTree
const Economy=preload("res://src/campaign/economy.gd")
const Losses=preload("res://src/campaign/ironman_losses.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Fleet=preload("res://src/campaign/fleet_inventory.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Ledger=preload("res://src/campaign/ledger/ledger.gd")
const EconomyPanel=preload("res://src/presentation/economy_panel.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Silent=preload("res://tests/calder_silent_journey_tests.gd")
const Course=preload("res://tests/calder_trench_journey_tests.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
var checks=0
var failures=0
class LaunchHost extends RefCounted:
 var economy=Economy.new_state("standard",true)
 var expedition={}
 var fitted_equipment=Catalog.default_loadout()
 var tool_racks=Racks.empty()
 var upgrade="endurance"
 var sim=Sim.new()
 var screen="menu"
 var active_started=false
 var saves=0
 func _start_mission(id):
  sim.start(id,"endurance",{"fitted":fitted_equipment,"tool_racks":Losses.racks(economy,tool_racks)})
  screen="mission";active_started=true
 func _save_archive():saves+=1
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func facts(result="lost",fit=Catalog.default_loadout(),receipt={},alive=[false,true],key="lost")->Dictionary:
 return {"key":key,"outcome":result,"hull":0.,"alive":alive,"first":false,"recovered":0,"artifact":false,"mission":{"launch_equipment":fit,"module_recovery":{"result":receipt}}}
func _initialize():call_deferred("run")
func run():
 loss_rules();replacement();persistence();launch();voyages();await main_surface()
 print("IRONMAN LOSSES CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func loss_rules():
 var fit=Catalog.default_loadout();fit.drone_a="drone_deep_cells";fit.drone_b="drone_survey_array";fit.quietus="quietus_baffles"
 var e=Economy.new_state("standard",true);Economy.charge_launch(e,fit)
 Economy.settle(e,facts("lost",fit))
 check(Losses.state(e).drones==[1,2],"failed dive: dead and surviving unrecovered drones permanently missing")
 check(Losses.state(e).modules==["drone_deep_cells","drone_survey_array"],"failed dive loses both fitted drone modules")
 check("quietus_baffles" not in Losses.state(e).modules and e.cond.quietus>=60,"Quietus and its fittings retain existing recovery immunity")
 var before=e.duplicate(true);Economy.settle(e,facts("lost",fit))
 check(e==before,"repeated debrief is exactly idempotent")
 check(e.report.contains("PERMANENT LOSS: DRONE A") and e.report.contains("Drone deep cells"),"report names permanent drone and module losses")
 var rows=Ledger.build({}, {},e)
 check(str(rows).contains("PERMANENT LOSS: DRONE A") and str(rows).contains("Drone deep cells"),"ledger forwards saved named permanent losses")
 for iron in [false,true]:
  var recovered=Economy.new_state("standard",iron)
  var receipt={"recovered":["drone_deep_cells"],"lost":["drone_survey_array"],"recovered_drones":[1]}
  Economy.settle(recovered,facts("won",fit,receipt,[true,true]))
  check(Losses.missing(recovered,2)==iron and not Losses.missing(recovered,1),"live drone outside mouth permanently lost only in Ironman")
  check(("drone_survey_array" in Losses.state(recovered).modules)==iron and "drone_deep_cells" not in Losses.state(recovered).modules,"successful replay honors exact recovered module partition")
 var cargo=Economy.new_state("standard",true)
 Economy.settle(cargo,facts("won",fit,{"recovered":["drone_deep_cells","drone_survey_array"],"lost":[],"recovered_drones":[2]},[false,true]))
 check(Losses.missing(cargo,1) and Losses.state(cargo).modules.is_empty(),"salvaged fitting comes home despite destroyed original carrier")
 var ordinary=Economy.new_state();Economy.settle(ordinary,facts("lost",fit))
 check(Losses.state(ordinary)==Losses.fresh(),"ordinary failure keeps stock behavior unchanged")
func replacement():
 var fit=Catalog.default_loadout();fit.drone_a="drone_deep_cells"
 var e=Economy.new_state("accessible",true);Economy.settle(e,facts("lost",fit))
 Economy.refill(e)
 check(Losses.missing(e,1) and not Economy.repair(e,"drone_a"),"Accessible refill and repair cannot resurrect a missing drone")
 check(Economy.Options.choices(e).is_empty(),"Ironman preset remains locked")
 e.stock={"scrap":0,"cells":0,"alloy":0}
 check(not Economy.rebuild_drone(e,1) and Losses.missing(e,1),"unaffordable drone manufacturing refused")
 var fleet={"outcomes":{0:{"recovered":[],"lost":["drone_deep_cells"]}}}
 check(Economy.rebuild(e,fleet,"drone_deep_cells")==fleet and "drone_deep_cells" in Losses.state(e).modules,"unaffordable module manufacturing refused")
 e.stock={"scrap":50,"cells":50,"alloy":10}
 var stock=e.stock.duplicate();var cost=Economy.drone_cost(e)
 check(Economy.rebuild_drone(e,1) and not Losses.missing(e,1) and Losses.missing(e,2),"paid manufacture restores only selected bay")
 check(e.stock.scrap==stock.scrap-cost.scrap and e.stock.cells==stock.cells-cost.cells,"drone replacement charges centralized normal manufacturing price")
 stock=e.stock.duplicate();cost=Economy.item_cost("drone_deep_cells",e)
 fleet=Economy.rebuild(e,fleet,"drone_deep_cells")
 check(Losses.state(e).modules.is_empty() and Fleet.lost(fleet).is_empty() and e.stock.scrap==stock.scrap-cost.scrap,"module replacement charges normal item price and clears both ledgers")
 check(Fleet.available(["drone_deep_cells"],fleet,e)==["drone_deep_cells"],"replacement returns fitting availability")
 check(Losses.state(e).counts.drone_a==1 and Losses.state(e).counts.drone_deep_cells==1,"manufacturing preserves historical loss names")
 Economy.charge_launch(e,fit);Economy.settle(e,facts("lost",fit,{},[false,false]))
 check(Losses.state(e).counts.drone_a==2 and Losses.state(e).counts.drone_deep_cells==2,"fresh retry with same terminal key counts new copies once")
 var spare=Economy.new_state("standard",true);spare.spares={"drone_deep_cells":1}
 Economy.settle(spare,facts("lost",fit))
 check(spare.spares.is_empty() and Losses.state(spare).modules.is_empty() and Losses.state(spare).counts.drone_deep_cells==1,"paid spare replaces lost copy once while retaining permanent-loss history")
func persistence():
 var old=Economy.new_state("standard",true);old.erase("permanent_losses")
 check(Economy.valid(old),"pre-107 economy block still validates")
 var migrated=Losses.migrated(old)
 check(Economy.valid(migrated) and Losses.state(migrated)==Losses.fresh(),"old Ironman save migration grants no retrospective losses")
 var e=Economy.new_state("standard",true);Economy.settle(e,facts())
 var s=Sim.new();s.start(0,"endurance",{"tool_racks":Racks.empty()});Economy.apply_launch(e,s)
 var data={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","economy":e,"active":s.snapshot()}
 var store=Store.new();store.path="user://ironman_107.save"
 check(store.valid(data) and store.save(data),"profile writes permanent losses alongside an active missing-bay dive")
 var restored=store.load_game();var resumed=Sim.new()
 check(restored.get("economy",{})==e and resumed.restore(restored.get("active",{})) and not resumed.units[1].alive and not resumed.units[2].alive,"profile and active resume retain both missing bays")
 var keep=restored.economy.duplicate(true);Economy.settle(restored.economy,facts())
 check(restored.economy==keep,"restore followed by same debrief cannot double-charge losses")
 for corrupt in [{"drones":[0]}, {"modules":["quietus_baffles"]}, {"counts":{"drone_a":0}}, {"last":["unknown"]}]:
  var bad=e.duplicate(true)
  for key in corrupt:bad.permanent_losses[key]=corrupt[key]
  check(not Economy.valid(bad),"reject malformed optional permanent-loss block "+str(corrupt.keys()))
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
func launch():
 var host=LaunchHost.new();Economy.settle(host.economy,facts())
 host.economy.stock={"scrap":0,"cells":0,"alloy":0}
 host.tool_racks={"quietus":{},"drone_a":{"emp":2},"drone_b":{"recon":2}}
 check(EconomyPanel.can_begin(host) and EconomyPanel.launch_cost(host).is_empty(),"both bays empty and no funds remain launchable")
 EconomyPanel.begin(host,30)
 check(host.active_started and host.sim.units[0].alive and not host.sim.units[1].alive and not host.sim.units[2].alive,"ordinary launch keeps Quietus and leaves missing bays empty")
 check(host.sim.tools.emp==0 and host.sim.tools.recon==0 and host.saves==1,"absent-drone tool racks do not supply Quietus and applied loss state is saved")
 check(EconomyPanel.briefing_line(host).contains("EMPTY DRONE BAYS: A, B"),"briefing explicitly names empty bays")
 check(load("res://src/main.gd")!=null and load("res://src/presentation/module_recovery_view.gd")!=null,"main and recovery UI compile")
func voyages():
 for preset in ["accessible","standard"]:
  var e=Economy.new_state(preset,true);Economy.settle(e,facts())
  e.stock={"scrap":0,"cells":0,"alloy":0}
  var s=Silent.SilentRun.new();s.start(30,"endurance",{"tool_racks":Racks.empty()});Economy.apply_launch(e,s)
  check(Course.run_core(s,30) and s.outcome=="won" and s.mission.recovered,"bare missing-bay SILENT physical recovery "+preset)
  check(s.stayed_silent and s.ordinary_only and s.selected==0 and s.tools.values().all(func(n):return n==0),"no finite tools, modules or drones used "+preset)
  check(not s.units[1].alive and not s.units[2].alive and Sim.valid_snapshot(s.snapshot()),"empty bays remain absent and current-save valid "+preset)
  print("IRONMAN BARE ",preset," op=30 outcome=",s.outcome," seconds=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," Hunt=",s.hunt_peak," locks=",s.locks," SILENT=",s.stayed_silent)

func settle_ui():
 for n in 6:await process_frame
func main_surface():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="ironman-107-fixture";root.add_child(game);await settle_ui();game.set_process(false)
 game.economy=Economy.new_state("standard",true);Economy.settle(game.economy,facts())
 game.economy.stock={"scrap":0,"cells":0,"alloy":0}
 game.tool_racks={"quietus":{},"drone_a":{"emp":9},"drone_b":{"recon":9}}
 EconomyPanel.begin(game,0);await settle_ui()
 check(game.screen=="mission" and game.active_started and not game.sim.units[1].alive and not game.sim.units[2].alive,"actual Main launches with missing bays despite unused overfull drone racks")
 check(game.sim.tools.emp==0 and game.sim.tools.recon==0 and Sim.valid_snapshot(game.sim.snapshot()),"actual Main prunes absent tool racks before validated launch")
 var store=Store.new();store.path="user://ironman_107_main.save"
 check(store.save(game._archive()),"actual Main missing-bay active archive saves")
 var ordinary={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","economy":Economy.new_state()}
 var iron=store.load_game()
 game.store=store;game._load_archive();await settle_ui()
 check(Losses.missing(game.economy,1) and not game.sim.units[1].alive,"actual Main restores missing bay and active state")
 store.save(ordinary);game._load_archive();await settle_ui()
 check(not Losses.active(game.economy) and Losses.state(game.economy)==Losses.fresh(),"switching to ordinary profile cannot inherit previous Ironman loss state")
 game.economy=iron.economy;game._show_economy();await settle_ui()
 var button=game.panel_box.find_children("*","Button",true,false).filter(func(b):return b.get_meta("action","")=="eco_drone_1")[0]
 check(button.disabled,"actual Supplies disables unaffordable drone manufacture")
 game.economy.stock={"scrap":50,"cells":50,"alloy":0};game._show_economy();await settle_ui()
 var before=game.economy.stock.duplicate();var price=Economy.drone_cost(game.economy)
 button=game.panel_box.find_children("*","Button",true,false).filter(func(b):return b.get_meta("action","")=="eco_drone_1")[0]
 button.pressed.emit();await settle_ui()
 check(not Losses.missing(game.economy,1) and Losses.missing(game.economy,2) and game.economy.stock.scrap==before.scrap-price.scrap and game.economy.stock.cells==before.cells-price.cells,"actual Supplies action manufactures only A for displayed normal price")
 game.queue_free();await settle_ui()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
