extends SceneTree
const Inventory=preload("res://src/campaign/fleet_inventory.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func run():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="module-inventory-main-fixture";root.add_child(game);await settle();game.set_process(false)
 check(game.get_property_list().any(func(p):return p.name=="fleet"),"Main owns the campaign fleet ledger separately from historical entitlements")
 if not game.get_property_list().any(func(p):return p.name=="fleet"):game.queue_free();await settle();finish();return
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.fitted_equipment.drone_a="drone_deep_cells";game._start_mission(6);await settle()
 var s=game.sim;s.sirens=[]
 check(s.mission.get("fleet_commit",false),"first expedition launch freezes genuine first-completion inventory commitment")
 # Explicit local-source fixture using actual sensing; real module loss and
 # departure follow. This is not an earned campaign journey.
 var source=s.mission.signal_sources.filter(func(item):return item.id=="shelf")[0]
 s.units[0].pos=source.pos;s.units[0].vel=Vector2.ZERO;s.paused=false;s.advance(.2);s.paused=true
 check(s.mission.expedition_facts.has("shelf"),"close receiver fixture earns a consistent source/objective snapshot through actual sensing")
 s.units[1].battery=0;s.paused=false;s.advance(1./60.);s.paused=true
 var mouth=s.extraction_corridors().filter(func(c):return c.route=="shelf")[0]
 s.units[0].pos=mouth.pos;s.units[0].vel=Vector2.ZERO
 check(s.command("depart",{"confirm":true}),"real first successful departure records the launched module left behind")
 var launch_fit=s.mission.launch_equipment.duplicate(true);game._debrief();await settle()
 check(game.fleet.get("outcomes",{}).get(6,{}).get("lost",[])==["drone_deep_cells"],"debrief commits first expedition loss before campaign completion changes")
 check("drone_deep_cells" in game._equipment_entitlements() and "drone_deep_cells" not in game._equipment_context().available,"historical discovery remains earned while physical lost stock is unavailable")
 check(game.fitted_equipment.drone_a.is_empty() and s.mission.launch_equipment==launch_fit,"next fit becomes bare without rewriting the launched equipment snapshot")
 check(game._archive().get("fleet",{})==game.fleet,"ordinary Main archive includes the exact helper-owned fleet ledger")
 var store=preload("res://src/persistence/save_store.gd").new();store.path="user://module-inventory-main-fixture.save"
 check(store.save(game._archive()),"actual Main archive with committed loss and immutable launch fitting saves successfully")
 var restored=load("res://scenes/main.tscn").instantiate();restored.capture_scenario="module-inventory-restore-fixture";root.add_child(restored);await settle();restored.set_process(false);restored.store=store;restored._load_archive();await settle()
 check(restored.fleet==game.fleet and restored.fitted_equipment.drone_a.is_empty() and restored.sim.mission.launch_equipment==launch_fit,"Main reload restores future stock separately from the finished dive's launch equipment")
 restored.queue_free();await settle()
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(store.path+suffix):DirAccess.remove_absolute(store.path+suffix)
 var labels=game.panel_box.find_children("*","Label",true,false).map(func(l):return l.text)
 check(labels.any(func(t):return "DRONE A" in t and "LOST" in t) and labels.any(func(t):return "LEFT BEHIND" in t and "DEEP CELLS" in t),"successful debrief acknowledges actual craft loss and future module consequence")
 var committed=game.fleet.duplicate(true);game._debrief();await settle()
 check(game.fleet==committed,"repeat debrief cannot spend the same module again")
 game._start_mission(6);await settle()
 check(not game.sim.mission.get("fleet_commit",true) and game.sim.mission.launch_equipment.drone_a.is_empty(),"completed replay is noncommitting and reconciles live unavailable hardware before launch")
 game.sim.outcome="lost";game._debrief();await settle();check(game.fleet==committed,"failed replay preserves committed stock")
 game.fleet={};game.expedition={};game.fitted_equipment.drone_a="drone_deep_cells";game._start_mission(6);await settle();game.sim.outcome="lost";game._debrief();await settle()
 check(game.fleet.is_empty(),"failed first-attempt fixture does not spend permanent launch stock")
 game._new_campaign();await settle();check(game.fleet.is_empty(),"new campaign clears the physical stock ledger")
 game.sim.units[1].alive=false;game.sim.units[2].alive=false;game.sim.outcome="won";game._debrief();await settle()
 check(game.panel_box.find_children("*","Label",true,false).any(func(l):return "DRONE A" in l.text and "DRONE B" in l.text and "LOST" in l.text),"bare-drone success still truthfully acknowledges both sortie losses")
 # Public ending-view fixture: an old ending can be opened after another dive.
 game.expedition={"route":"shelf","completed":[12],"facts":{"confluence_route":"concealed"}};game._show_ending();await settle()
 check(not game.panel_box.find_children("*","Label",true,false).any(func(l):return "FLEET RECOVERY" in l.text),"archive ending does not attribute an unrelated current sortie's craft losses to that historical ending")
 game.queue_free();await settle();finish()
func finish():
 print("MODULE INVENTORY MAIN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
