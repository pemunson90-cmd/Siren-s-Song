extends "res://tests/fix2_menu_ui_tests.gd"
func text_of(game)->String:
 var parts=[]
 for label in game.panel_box.find_children("*","Label",true,false):parts.append(label.text)
 return "\n".join(parts)
func shape_case(shape):
 root.size=shape;await settle()
 var path="user://early-reward-%d.save"%shape.x
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test";game.store.path=path
 root.add_child(game);await settle();game.set_process(false)
 check(game.get("early_reward") is Dictionary,"early reward integrated in the actual campaign")
 if not game.get("early_reward") is Dictionary:game.queue_free();await settle();return
 var Table=load("res://src/campaign/early_reward/reward_table.gd")
 game.completed=[0];game.unlocked=1;game._start_mission(1);game.sim.outcome="lost";game._debrief()
 check(game.early_reward.is_empty(),"failed operation never grants the reward")
 game._start_mission(1);var active_fit=game.sim.mission.launch_equipment.duplicate(true);game.sim.outcome="won";game._debrief();await settle()
 check("NEW FITTING · Tele lens" in text_of(game),"successful op1 debrief shows plain NEW FITTING line")
 check(Table.GRANT.module in game._equipment_entitlements(),"reward is owned after op1")
 check(game.sim.mission.launch_equipment==active_fit and not Catalog.has(game.fitted_equipment,0,Table.GRANT.module),"reward never auto-equips or alters the active dive")
 var granted=game.early_reward.duplicate(true);game._debrief()
 check(game.early_reward==granted and not "NEW FITTING" in text_of(game),"repeated debrief never grants or announces twice")
 game._show_campaign();await settle()
 if await press(game,"fittings"):
  check(Table.GRANT.explanation in text_of(game),"Fittings gives the one-line photographic trade")
  var fit=button(game,"fit_quietus")
  check(fit!=null and not fit.disabled and fit.size.y>=game.ui_touch_height,"lens is ready to equip with an Android touch target")
  if await press(game,"fit_quietus"):
   check(Catalog.has(game.fitted_equipment,0,Table.GRANT.module),"real touch equips the free lens")
   check(game.sim.mission.launch_equipment==active_fit,"fitting affects the next launch only")
  await android_back();check(game.screen=="menu","Android Back leaves Fittings")
 check(game.store.save(game._archive()),"earned and fitted module saves")
 game.queue_free();await settle()
 var restored=load("res://scenes/main.tscn").instantiate();restored.set_script(load("res://tests/density_main.gd"));restored.capture_scenario="runtime-test";restored.store.path=path
 root.add_child(restored);await settle();restored.set_process(false);restored._load_archive()
 check(restored.early_reward==granted and Catalog.has(restored.fitted_equipment,0,Table.GRANT.module),"save/reload preserves once-only grant and chosen fitting")
 var bad=restored._archive();bad.early_reward={"granted":true,"module":"unknown"}
 check(not restored.store.valid(bad),"archive validation rejects corrupted reward")
 Table.enabled=false
 check(Table.GRANT.module in restored._equipment_entitlements(),"off switch retains saved ownership")
 restored._new_campaign();restored.completed=[0];restored.unlocked=1;restored._start_mission(1);restored.sim.outcome="won";restored._debrief()
 check(restored.early_reward.is_empty() and Table.GRANT.module not in restored._equipment_entitlements(),"off switch gives the original early campaign behavior")
 var legacy=restored._archive();legacy.erase("early_reward");check(restored.store.valid(legacy),"older save without reward field remains valid")
 Table.enabled=true;restored._new_campaign()
 check(restored.early_reward.is_empty() and restored._equipment_entitlements().is_empty(),"new campaign resets the once-only grant")
 restored.queue_free();await settle()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("EARLY REWARD UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
