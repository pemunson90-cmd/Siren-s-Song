extends SceneTree
const Economy=preload("res://src/campaign/economy.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Fleet=preload("res://src/campaign/fleet_inventory.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func facts(outcome:String,first:bool,hull:float=100.0,alive:Array=[true,true],recovered:int=0,artifact:bool=false,key:String="a")->Dictionary:
 return {"outcome":outcome,"hull":hull,"alive":alive,"first":first,"recovered":recovered,"artifact":artifact,"key":key}
func _initialize():
 var e=Economy.new_state()
 check(Economy.valid(e),"fresh economy is a valid save field")
 check(Economy.refit_cost(e,Catalog.default_loadout()).is_empty(),"bare standard launch is free")
 var fit=Catalog.default_loadout();fit.drone_a="drone_deep_cells";fit.quietus="quietus_baffles"
 check(Economy.refit_cost(e,fit).get("cells",0)==2,"two power-light fittings cost two cells: %s"%str(Economy.refit_cost(e,fit)))
 fit.quietus="quietus_vector_drive"
 check(Economy.refit_cost(e,fit).get("cells",0)==3,"power-2 fitting costs an extra cell")
 var poor=Economy.new_state();poor.stock.cells=0
 check(not Economy.charge_launch(poor,fit) and poor.last_fit==Catalog.default_loadout(),"unaffordable refit is refused and spends nothing")
 check(Economy.charge_launch(poor,Catalog.default_loadout()),"a bare launch always succeeds with an empty purse")
 check(Economy.charge_launch(e,fit) and e.stock.cells==3,"refit pays cells and records the launch fit")
 check(Economy.refit_cost(e,fit).is_empty(),"same fitting next launch is free")
 var iron=Economy.new_state();iron.ironman=true;Economy.charge_launch(iron,fit)
 check(not Economy.refit_cost(iron,fit).is_empty(),"ironman charges the same fit again on retry")
 var hurt=Economy.new_state()
 Economy.settle(hurt,facts("lost",false,0.0,[false,true]))
 check(hurt.cond.quietus==60 and hurt.cond.drone_a==60 and hurt.cond.drone_b==100,"standard floors a lost dive so a launch stays possible")
 var cells=hurt.stock.cells
 check(Economy.repair(hurt,"quietus") and hurt.cond.quietus==100 and hurt.stock.cells==cells-2,"repair restores hull for cells")
 hurt.stock.cells=0;hurt.stock.scrap=0
 check(not Economy.repair(hurt,"drone_a") and hurt.cond.drone_a==60,"unaffordable repair refused")
 Economy.settle(hurt,facts("lost",false,0.0,[false,true]))
 check(hurt.stock.cells==0,"same dive settles once")
 Economy.settle(hurt,facts("lost",false,0.0,[false,true],0,false,"b"))
 check(hurt.stock.cells==1 and hurt.cond.quietus>=60,"a loss still salvages a cell and never drops under the floor")
 var win=Economy.new_state()
 Economy.settle(win,facts("won",true,90.0,[true,true],2,true))
 check(win.stock.scrap==6+3+4 and win.stock.cells==6+2 and win.stock.alloy==3,"first win with salvage and artifact pays scrap, cells and alloy")
 check(win.cond.quietus==90,"hull wear persists")
 var surv=Economy.new_state("survival");Economy.settle(surv,facts("won",true))
 var std=Economy.new_state();Economy.settle(std,facts("won",true))
 check(surv.stock.scrap<std.stock.scrap and Economy.item_cost("drone_deep_cells",surv).scrap>Economy.item_cost("drone_deep_cells",std).scrap,"survival has leaner income and dearer parts")
 var easy=Economy.new_state("accessible");easy.stock.cells=0;easy.cond.quietus=40
 Economy.settle(easy,facts("lost",false,0.0,[false,false]))
 check(easy.stock.cells>=Economy.REFILL.cells and easy.cond.quietus==100 and easy.cond.drone_a==100,"accessible replenishes supplies and mends craft between operations")
 var locked=Economy.new_state();Economy.cycle_preset(locked);Economy.set_ironman(locked)
 check(locked.preset=="accessible" and not Economy.cycle_preset(locked) and Economy.valid(locked),"ironman locks the preset")
 var m=Economy.new_state()
 var fleet={"outcomes":{7:{"recovered":[],"lost":["drone_deep_cells"]}}}
 check(Economy.lost_items(fleet)==["drone_deep_cells"],"lost fitting is listed")
 var before=m.stock.scrap
 fleet=Economy.rebuild(m,fleet,"drone_deep_cells")
 check(Economy.lost_items(fleet).is_empty() and m.stock.scrap==before-Economy.item_cost("drone_deep_cells",m).scrap,"rebuilding a lost fitting costs scrap and returns it")
 check(Fleet.available(["drone_deep_cells"],fleet)==["drone_deep_cells"],"rebuilt fitting is available again")
 check(Economy.build_spare(m,"drone_survey_array") and not Economy.build_spare(m,"drone_survey_array") and m.spares.size()==1,"one spare per fitting, paid once")
 var after={"outcomes":{9:{"recovered":[],"lost":["drone_survey_array"]}}}
 var healed=Economy.absorb_losses(m,{},after)
 check(Economy.lost_items(healed).is_empty() and m.spares.is_empty() and Fleet.valid(healed,["drone_survey_array"],[9]),"a spare replaces a fitting lost in the next dive and the fleet stays valid")
 var broke=Economy.new_state();broke.stock.scrap=0
 check(Economy.rebuild(broke,{"outcomes":{7:{"recovered":[],"lost":["drone_deep_cells"]}}},"drone_deep_cells").outcomes[7].lost.size()==1,"rebuild refused without scrap")
 var p={"version":1,"route":"deep","routes":[],"facts":{"choir_22":"x"},"completed":[26],"entitlements":[],"research":{"materials":["pressure_spindle"],"spent":[],"projects":[]}}
 check(Research.pending(p)==["pressure_spindle"],"recovered material awaits research")
 var poor_r=Economy.new_state()
 var spent=Research.start(p,"pressure_spindle")
 check(spent.research.projects==["quietus_pressure_sleeve"] and "quietus_pressure_sleeve" in spent.entitlements,"deliberate research unlocks the fitting")
 var held=Economy.after_recover(poor_r,p,spent)
 check(held.research.projects.is_empty() and held.research.spent.is_empty() and held.research.materials==["pressure_spindle"] and held.entitlements.is_empty(),"unaffordable research is held, material kept")
 poor_r.stock.alloy=2
 var paid=Economy.after_recover(poor_r,p,spent)
 check(paid.research.projects.size()==1 and poor_r.stock.alloy==0,"affordable research is charged")
 var store=Store.new()
 var data={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","economy":Economy.new_state()}
 check(store.valid(data),"save with economy validates")
 data.economy.stock.scrap=-1
 check(not store.valid(data),"corrupt economy rejected")
 data.economy=Economy.new_state();data.economy.preset="bogus"
 check(not store.valid(data),"unknown preset rejected")
 data.erase("economy")
 check(store.valid(data),"save without economy field still loads")
 print("ECONOMY CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
