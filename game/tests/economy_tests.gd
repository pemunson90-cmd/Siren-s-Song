extends SceneTree
const Economy=preload("res://src/campaign/economy.gd")
const Table=preload("res://src/campaign/economy_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Fleet=preload("res://src/campaign/fleet_inventory.gd")
const Research=preload("res://src/campaign/glass_research.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func facts(outcome:String,first:bool,hull:float=100.0,alive:Array=[true,true],recovered:int=0,artifact:bool=false,key:String="a")->Dictionary:
 return {"outcome":outcome,"hull":hull,"alive":alive,"first":first,"recovered":recovered,"artifact":artifact,"key":key}
func _initialize():
 var e=Economy.new_state()
 check(Economy.valid(e) and Economy.valid_archive({"economy":e}) and Economy.valid_archive({}),"fresh economy and absent field are valid")
 check(Economy.refit_cost(e,Catalog.default_loadout()).is_empty(),"bare standard launch is free")
 var fit=Catalog.default_loadout();fit.drone_a="drone_deep_cells";fit.quietus="quietus_baffles"
 check(Economy.refit_cost(e,fit).get("cells",0)==2,"two light fittings cost two cells")
 fit.quietus="quietus_vector_drive"
 check(Economy.refit_cost(e,fit).get("cells",0)==3,"a power-2 fitting costs an extra cell")
 var poor=Economy.new_state();poor.stock.cells=0
 check(not Economy.charge_launch(poor,fit) and poor.last_fit==Catalog.default_loadout(),"unaffordable refit is refused and spends nothing")
 check(Economy.charge_launch(poor,Catalog.default_loadout()),"never soft-locks: a bare launch succeeds with an empty purse")
 for preset in Table.ORDER:
  var zero=Economy.new_state(preset);zero.stock={"scrap":0,"cells":0,"alloy":0}
  check(Economy.charge_launch(zero,Catalog.default_loadout()),"%s: empty purse still launches bare"%preset)
  zero.last_fit=Catalog.canonical({"hull":"fast","chassis_a":"heavy","chassis_b":"scout"})
  zero.ironman=true
  check(Economy.charge_launch(zero,Catalog.default_loadout()),"%s: stripping paid frames stays free with no resources, including ironman"%preset)
 var paid=Economy.new_state();var before=paid.stock.cells
 check(Economy.charge_launch(paid,fit) and paid.stock.cells==before-3 and Economy.refit_cost(paid,fit).is_empty(),"refit pays once, the same fit is free next launch")
 var iron=Economy.new_state("standard",true);Economy.charge_launch(iron,fit)
 check(not Economy.refit_cost(iron,fit).is_empty(),"ironman charges the same fit again on retry")
 var hurt=Economy.new_state()
 Economy.settle(hurt,facts("lost",false,0.0,[false,true]))
 check(hurt.cond.quietus==60 and hurt.cond.drone_a==60 and hurt.cond.drone_b==100,"standard floors a lost dive so a launch stays possible")
 var cells=hurt.stock.cells
 check(Economy.repair(hurt,"quietus") and hurt.cond.quietus==100 and hurt.stock.cells==cells-2,"repair restores hull for cells")
 hurt.stock.cells=0;hurt.stock.scrap=0
 check(not Economy.repair(hurt,"drone_a") and hurt.cond.drone_a==60,"unaffordable repair refused")
 var once=hurt.stock.cells
 Economy.settle(hurt,facts("lost",false,0.0,[false,true]))
 check(hurt.stock.cells==once,"the same dive settles once")
 Economy.settle(hurt,facts("lost",false,0.0,[false,true],0,false,"b"))
 check(hurt.stock.cells==once+1 and hurt.cond.quietus>=60,"a loss still salvages a cell and never drops under the floor")
 check(Economy.charge_launch(hurt,Catalog.default_loadout()),"retry can launch bare after settlement")
 Economy.settle(hurt,facts("lost",false,0.0,[false,true],0,false,"b"))
 check(hurt.stock.cells==once+2,"a fresh retry settles even with the same mission/time key")
 Economy.settle(hurt,facts("lost",false,0.0,[false,true],0,false,"b"))
 check(hurt.stock.cells==once+2,"repeating that retry's debrief still settles only once")
 var win=Economy.new_state()
 var exchange=Economy.new_state();var direct=Economy.new_state()
 var exchange_facts=facts("won",true);exchange_facts.blackwater_handoff=true
 Economy.settle(exchange,exchange_facts);Economy.settle(direct,facts("won",true))
 check(exchange.stock.cells==direct.stock.cells+2,"first locally transferred Blackwater exchange pays two extra Standard cells")
 var paid_cells=exchange.stock.cells;Economy.settle(exchange,exchange_facts)
 check(exchange.stock.cells==paid_cells,"repeating the transfer debrief cannot pay twice")
 for result in ["won","lost"]:
  var repeated=Economy.new_state();var baseline=Economy.new_state();var receipt=facts(result,false);receipt.blackwater_handoff=true
  Economy.settle(repeated,receipt);Economy.settle(baseline,facts(result,false))
  check(repeated.stock==baseline.stock,"transfer premium requires first successful recovery "+result)
 Economy.settle(win,facts("won",true,90.0,[true,true],2,true))
 check(win.stock.scrap==8+3+4 and win.stock.cells==10+2 and win.stock.alloy==0+3 and win.cond.quietus==90,"first win with salvage pays all three resources and keeps hull wear")
 var surv=Economy.new_state("survival");Economy.settle(surv,facts("won",true))
 var std=Economy.new_state();Economy.settle(std,facts("won",true))
 check(surv.stock.scrap<std.stock.scrap and Economy.item_cost("drone_deep_cells",surv).scrap>Economy.item_cost("drone_deep_cells",std).scrap,"survival has leaner income and dearer parts")
 var easy=Economy.new_state("accessible");easy.stock.cells=0;easy.cond.quietus=40
 Economy.settle(easy,facts("lost",false,0.0,[false,false]))
 check(easy.stock.cells>=Table.REFILL.cells and easy.cond.quietus==100 and easy.cond.drone_a==100,"accessible replenishes supplies and mends craft")
 var locked=Economy.new_state();Economy.cycle_preset(locked);Economy.settle(locked,facts("won",true));Economy.set_ironman(locked)
 check(locked.preset=="accessible" and not Economy.cycle_preset(locked) and Economy.valid(locked),"ironman locks the preset")
 var m=Economy.new_state()
 var fleet={"outcomes":{7:{"recovered":[],"lost":["drone_deep_cells"]}}}
 var scrap=m.stock.scrap
 fleet=Economy.rebuild(m,fleet,"drone_deep_cells")
 check(Economy.lost_items(fleet).is_empty() and m.stock.scrap==scrap-Economy.item_cost("drone_deep_cells",Economy.new_state()).scrap,"rebuilding a lost module costs scrap and returns it")
 check(Fleet.available(["drone_deep_cells"],fleet)==["drone_deep_cells"] and Fleet.valid(fleet,["drone_deep_cells"],[7]),"rebuilt module is available and the fleet stays valid")
 check(Economy.build_spare(m,"drone_survey_array") and not Economy.build_spare(m,"drone_survey_array") and not Economy.build_spare(m,"quietus_prism"),"one drone spare, paid once")
 var healed=Economy.absorb_losses(m,{},{"outcomes":{9:{"recovered":[],"lost":["drone_survey_array"]}}})
 check(Economy.lost_items(healed).is_empty() and m.spares.is_empty() and Fleet.valid(healed,["drone_survey_array"],[9]),"a spare replaces a module lost in the next dive")
 var broke=Economy.new_state();broke.stock.scrap=0
 check(Economy.rebuild(broke,{"outcomes":{7:{"recovered":[],"lost":["drone_deep_cells"]}}},"drone_deep_cells").outcomes[7].lost.size()==1,"rebuild refused without scrap")
 var refiner=Economy.new_state()
 check(Economy.refine(refiner) and refiner.stock.alloy==1 and refiner.stock.scrap==2 and not Economy.refine(broke),"scrap refines into alloy")
 # Frame unlocks: bought with alloy or granted by a research target; no artifact is required.
 var u=Economy.new_state();var none={}
 check(Economy.frame_locked(u,none,0,"quiet") and not Economy.frame_locked(u,none,0,"standard") and Economy.frame_locked(u,none,1,"scout"),"quiet hull and non-standard chassis start locked")
 check(not Economy.buy_unlock(u,"hull:quiet"),"unlock refused without alloy")
 u.stock.alloy=4
 check(Economy.buy_unlock(u,"hull:quiet") and u.stock.alloy==0 and not Economy.frame_locked(u,none,0,"quiet") and Economy.valid(u),"alloy buys a hull unlock and the state stays valid")
 var fast_fit=Catalog.canonical({"hull":"fast","quietus_2":"quietus_vector_drive"})
 var reset_fit=Economy.lock_frames(Economy.new_state(),none,fast_fit)
 check(reset_fit.hull=="standard" and Catalog.valid_fitting(reset_fit),"locked fast hull reads as standard with a legal fit")
 var old=Economy.legacy_state(fast_fit)
 check(old.unlocks==["hull:fast"] and not Economy.frame_locked(old,none,0,"fast"),"an old archive keeps the frames it flew with")
 # Research: pending until paid; a hull target unlocks a frame and grants no fitting entitlement.
 var p={"version":1,"route":"deep","routes":[],"facts":{"choir_22":"x"},"completed":[26],"entitlements":[],"research":{"materials":["pressure_spindle"],"spent":[],"projects":[]}}
 check(Research.pending(p)==["pressure_spindle"],"recovered material awaits research")
 var spent=Research.start(p,"pressure_spindle")
 check(spent.research.projects==["quietus_pressure_sleeve"] and "quietus_pressure_sleeve" in spent.entitlements and Research.valid(spent),"deliberate research unlocks the fitting")
 var rich=Economy.new_state()
 var held=Economy.after_recover(rich,p,spent)
 check(held.research.projects.is_empty() and held.research.materials==["pressure_spindle"] and held.entitlements.is_empty() and Research.valid(held),"automatic research is held as pending")
 check(Economy.research(rich,held,"pressure_spindle")==held,"research refused without alloy")
 rich.stock.alloy=2
 var done=Economy.research(rich,held,"pressure_spindle")
 check(done.research.projects.size()==1 and rich.stock.alloy==0 and Research.valid(done),"research pays alloy on the player's choice")
 var hull_p={"facts":{"x":"y"},"completed":[3],"entitlements":[],"research":{"materials":["deep_keel_plate"],"spent":["deep_keel_plate"],"projects":["hull:quiet"]}}
 check(Research.grants_fitting("quietus_prism") and not Research.grants_fitting("hull:quiet"),"research targets distinguish fittings from frame unlocks")
 check(Economy.is_unlocked(Economy.new_state(),hull_p,"hull:quiet"),"a researched hull target unlocks the frame")
 check(Economy.target_name("hull:quiet")=="Low noise hull" and Economy.target_name("quietus_prism")=="Reach directional prism","research targets have names")
 for material in ["trench_seal_core","choir_reed","deep_keel_plate","trawler_screw"]:
  var recipe=Research.RECIPES[material]
  var candidate={"facts":{recipe.evidence:"received"},"completed":[recipe.operation],"entitlements":[],"research":{"materials":[material],"spent":[],"projects":[]}}
  var supplies=Economy.new_state();supplies.stock.alloy=2
  var result=Economy.research(supplies,candidate,material)
  if Research.grants_fitting(recipe.item) and not Catalog.ITEMS.has(recipe.item):
   check(result==candidate and supplies.stock.alloy==2 and Research.valid(result),"unimplemented recipe retains material and alloy: "+material)
   var mission={"recovered":true,"glass_reach":{"retrieved":true,"artifact":{"id":material,"state":"recovered"}}}
   check(Research.recovered(candidate,mission)==candidate,"automatic recovery also retains unavailable material: "+material)
  else:
   check(result.research.projects==[recipe.item] and supplies.stock.alloy==0 and Research.valid(result),"implemented recipe researches with a valid state: "+material)
   if not Research.grants_fitting(recipe.item):
    check(result.entitlements.is_empty() and Economy.is_unlocked(supplies,result,recipe.item),"frame research grants only a usable frame unlock: "+material)
  if Research.grants_fitting(recipe.item):check(Economy.item_cost(recipe.item,Economy.new_state()).get("alloy",0)==1,"alien recipe manufacturing requires alloy: "+material)
 Table.enabled=false
 var off=Economy.new_state()
 check(Economy.refit_cost(off,fit).is_empty() and not Economy.frame_locked(off,none,0,"fast") and Economy.after_recover(rich,p,spent)==spent,"enabled=false restores today's behavior")
 Table.enabled=true
 check(load("res://src/presentation/economy_panel.gd")!=null and load("res://src/presentation/flow/campaign_flow.gd")!=null,"panel and flow scripts compile")
 print("ECONOMY CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
