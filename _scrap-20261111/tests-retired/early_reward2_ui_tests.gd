extends "res://tests/early_reward_ui_tests.gd"
const Table2=preload("res://src/campaign/early_reward/reward_table.gd")
func fit_row(game,item:String):
 for b in game.panel_box.find_children("*","Button",true,false):
  if b.get_meta("ui_action",b.get_meta("action",""))=="fit_quietus" and item in b.text and b.is_visible_in_tree():return b
 return null
func touch_row(game,item:String)->bool:
 var b=fit_row(game,item)
 check(b!=null and not b.disabled,"fit row ready: "+item)
 if b==null or b.disabled:return false
 var parent=b.get_parent()
 while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
 if parent!=null:parent.ensure_control_visible(b);await settle()
 check(b.size.y>=game.ui_touch_height,"android touch target: "+item)
 await tap(b.get_global_rect().get_center());return true
func shape_case(shape):
 root.size=shape;await settle()
 var path="user://early-reward2-%d.save"%shape.x
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test";game.store.path=path
 root.add_child(game);await settle();game.set_process(false)
 var announced=[]
 var expected=[["Tele lens",1],["Quietus acoustic baffles",3],["Low-light film back",5]]
 for row in expected:
  var op=row[1]
  game.completed=range(op);game.unlocked=mini(5,op)
  game._start_mission(op);game.sim.outcome="won";game._debrief();await settle()
  check(("NEW FITTING · "+row[0]) in text_of(game),"debrief announces NEW FITTING "+row[0])
  var before=game.early_reward.duplicate(true);game._debrief();await settle()
  check(game.early_reward==before and not "NEW FITTING" in text_of(game),"second debrief grants nothing: "+row[0])
 check(game.early_reward.get("modules",[])==Table2.modules(),"all three granted exactly once")
 check(Table2.modules().all(func(m):return m in game._equipment_entitlements()),"all three owned")
 game._show_campaign();await settle()
 if await press(game,"fittings"):
  var text=text_of(game)
  for g in Table2.GRANTS:check(g.explanation in text,"Fittings explains "+g.module)
  for row in expected:check(fit_row(game,row[0]) !=null,"Fittings lists "+row[0])
  if await touch_row(game,"Low-light film back"):
   check(Catalog.has(game.fitted_equipment,0,"low_light_back"),"real touch equips low-light back")
  if await touch_row(game,"Tele lens"):
   check(Catalog.has(game.fitted_equipment,0,"quietus_tele_lens") and not Catalog.has(game.fitted_equipment,0,"low_light_back"),"tele lens replaces low-light back, never both")
  if await touch_row(game,"Quietus acoustic baffles"):
   check(Catalog.has(game.fitted_equipment,0,"quietus_baffles") and Catalog.valid_fitting(game.fitted_equipment),"real touch equips baffles in a legal fit")
  await android_back();check(game.screen=="menu","Android Back leaves Fittings")
 var granted=game.early_reward.duplicate(true)
 check(game.store.save(game._archive()),"three grants save")
 game.queue_free();await settle()
 var restored=load("res://scenes/main.tscn").instantiate();restored.set_script(load("res://tests/density_main.gd"));restored.capture_scenario="runtime-test";restored.store.path=path
 root.add_child(restored);await settle();restored.set_process(false);restored._load_archive()
 check(restored.early_reward==granted and Table2.modules().all(func(m):return m in restored._equipment_entitlements()),"reload keeps all three grants")
 restored.completed=[0,1,2,3,4,5];restored._start_mission(5);restored.sim.outcome="won";restored._debrief()
 check(restored.early_reward==granted,"replaying after reload grants nothing")
 var legacy=restored._archive();legacy.early_reward={"granted":true,"module":"quietus_tele_lens"};legacy.completed=[0,1];legacy.unlocked=2;legacy.erase("equipment");legacy.erase("fleet");legacy.erase("expedition");legacy.erase("intel");legacy.erase("active");legacy.erase("evidence")
 check(restored.store.valid(legacy),"existing single-grant save stays valid")
 var bad=restored._archive();bad.early_reward={"granted":true,"modules":["unknown"]}
 check(not restored.store.valid(bad),"archive rejects corrupted list")
 Table2.enabled=false
 restored._new_campaign();restored.completed=[0,2,4];restored.unlocked=5
 for op in [1,3,5]:restored._start_mission(op);restored.sim.outcome="won";restored._debrief()
 check(restored.early_reward.is_empty() and Table2.modules().all(func(m):return m not in restored._equipment_entitlements()),"flag off gives today's behavior")
 Table2.enabled=true;restored.queue_free();await settle()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("EARLY REWARD2 UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
