extends SceneTree
# Briefing economy: balances, preset choice, repair, refit charging at launch,
# and the never-soft-locked bare launch, through the real button callbacks.
var game
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 6:await process_frame
func action(id:String):
 for control in game.panel_box.get_children()+game.menu_footer.get_children():
  if control is Button and control.get_meta("action","")==id:return control
 return null
func press(id:String):
 var button=action(id)
 if button==null or button.disabled:return false
 button.pressed.emit();await settle();return true
func texts()->String:
 var all=""
 for control in game.panel_box.get_children():
  if control is Label or control is Button:all+=control.text+"\n"
 return all
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(2520,1080);await settle()
 game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="economy-ui-fixture"
 game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition={"version":1,"route":"deep","routes":["deep","shelf"],"facts":{"deep":"known","shelf":"known"},"completed":[6,7,8]}
 game._start_mission(6);game._briefing(6);await settle()
 var text=texts()
 check("BALANCE" in text and "SCRAP 6" in text and "CELLS 6" in text,"briefing shows the resource balance")
 check("PRESET · STANDARD" in text and "NEXT LAUNCH REFIT · FREE" in text,"briefing shows the preset and the free bare launch")
 check(action("begin")!=null and not action("begin").disabled,"bare launch is enabled from the first briefing")
 check(await press("eco_preset") and game.economy.preset=="accessible","preset choice cycles to accessible from the operations screen")
 game._show_campaign();await settle();check(action("eco_preset")!=null and "BALANCE" in texts(),"operations screen shows balance and preset choice")
 await press("eco_preset");await press("eco_preset");check(game.economy.preset=="standard","preset cycles back to standard")
 game._briefing(6);await settle()
 game._choose_equipment("drone_a","drone_deep_cells",6);await settle()
 check("NEXT LAUNCH REFIT · 1 CELLS" in texts(),"a new fitting shows its refit cost before launch")
 check(await press("begin") and game.screen=="mission","paying launch enters the water")
 check(game.economy.stock.cells==5 and game.economy.last_fit.drone_a=="drone_deep_cells","refit cost is spent at launch and remembered")
 check(game.sim.hull==100.0 and game.sim.paused,"launch starts paused")
 game._briefing(6);await settle()
 check("NEXT LAUNCH REFIT · FREE" in texts(),"the same fitting on retry is free")
 game.economy.cond.quietus=60;game.economy.cond.drone_b=60;game._briefing(6);await settle()
 check(action("eco_repair_quietus")!=null and "2 CELLS" in action("eco_repair_quietus").text,"worn hull offers a priced repair")
 check(await press("eco_repair_quietus") and game.economy.cond.quietus==100 and game.economy.stock.cells==3,"repair spends cells and restores the hull")
 game.economy.cond.quietus=60
 check(await press("begin") and game.sim.hull==60.0 and game.sim.units[2].battery==60.0,"an unrepaired craft launches in its recorded condition")
 game._briefing(6);await settle()
 game.economy.stock.cells=0;game.economy.last_fit=preload("res://src/equipment/equipment_catalog.gd").default_loadout()
 game._briefing(6);await settle()
 check(action("begin").disabled and "NEED" in action("begin").text,"an unaffordable refit disables launch and says what is missing")
 check(await press("eco_bare") and not action("begin").disabled,"stripping to bare is free and always launches")
 check(await press("begin") and game.screen=="mission","a bare Quietus with no supplies still launches")
 var store=preload("res://src/persistence/save_store.gd").new()
 check(store.valid(game._archive()) and game._archive().economy.preset=="standard","archive carries a valid economy field")
 game.queue_free();await settle()
 print("ECONOMY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
