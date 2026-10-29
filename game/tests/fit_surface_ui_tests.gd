extends "res://tests/fix2_menu_ui_tests.gd"
# Fit surface: grouping data test, then a touch journey on both Fold7 shapes and 960x432 at 150% text.
const Model=preload("res://src/presentation/fit_surface/fit_surface.gd")
const Table=preload("res://src/presentation/fit_surface/fit_surface_table.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
func fit_for(game,slot:String,item:String):
 for control in game.panel_box.get_children():
  if control is Button and control.get_meta("action","")=="fit_"+slot and control.get_meta("fitting_id","")==item:return control
 return null
func tap_control(game,control):
 game.scroll.ensure_control_visible(control);await settle()
 await tap(control.get_global_rect().get_center())
func data_checks():
 var items=[]
 for id in Catalog.ITEMS:items.append(Catalog.ITEMS[id].duplicate(true))
 var context={"slots":Catalog.default_loadout(),"available":Catalog.ITEMS.keys(),"catalog":items}
 for slot in Catalog.SLOTS:
  var seen=[];var wrong=0
  for group in Model.sections(context,slot):
   for row in group.rows:
    seen.append(row.id)
    if Model.section_of(row)!=group.mount:wrong+=1
  var expected=Catalog.ITEMS.keys().filter(func(id):return slot in Catalog.ITEMS[id].compatible_slots)
  seen.sort();expected.sort()
  check(seen==expected and wrong==0,"every catalog item appears once under its own mount for "+slot)
 var deltas=0
 for group in Model.sections(context,"quietus"):
  for row in group.rows:
   var after=Model.after_budget(context,row)
   if not after.is_empty() and Model.delta_text(context,row).begins_with("POWER %d→%d"%[0,after.power]):deltas+=1
 check(deltas>0,"fit delta names the resulting power budget")
func shape_case(shape):
 root.size=shape;await settle()
 Settings.apply({"text_scale":1.5})
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition={"version":1,"route":"deep","routes":["deep","shelf"],"facts":{"deep":"known","shelf":"known"},"completed":[6,7,8]}
 game._show_campaign();await settle()
 var label=str(shape.x)
 if await press(game,"fittings"):
  check(button(game,"fit_tab_quietus")!=null and button(game,"fit_tab_drone_a")!=null and button(game,"fit_tab_drone_b")!=null,"three craft tabs "+label)
  check(button(game,"fit_tab_quietus").disabled and button(game,"fit_tab_drone_a").size.y>=game.ui_touch_height-0.5,"shown tab is marked and tabs keep touch height "+label)
  check(fit_for(game,"drone_a","drone_deep_cells")==null,"other craft rows are not listed on the Quietus tab "+label)
  var quiet=game.panel_box.get_children().filter(func(c):return c is Button and c.get_meta("action","")=="fit_quietus")
  check(not quiet.is_empty() and quiet.all(func(b):return b.size.y>=game.ui_touch_height-0.5),"Quietus rows are 48 dp touch targets "+label)
  var before=game.fitted_equipment.duplicate(true)
  if await press(game,"fit_tab_drone_a"):
   var row=fit_for(game,"drone_a","drone_deep_cells")
   check(row!=null and not row.disabled and game.fitted_equipment==before,"switching tab shows the drone rows and saves nothing "+label)
   check("POWER" in row.text and "BARE → FIT" in row.text,"row shows the legacy action and its budget change "+label)
   if row!=null:
    await tap_control(game,row)
    check(game.fitted_equipment.drone_a=="drone_deep_cells" or "drone_deep_cells" in game.fitted_equipment.values(),"one tap fits the module "+label)
    row=fit_for(game,"drone_a","drone_deep_cells")
    check(row!=null and "→ BARE" in row.text and button(game,"fit_tab_drone_a").disabled,"fit keeps the same craft tab and offers BARE "+label)
    if row!=null:
     await tap_control(game,row)
     check(not "drone_deep_cells" in game.fitted_equipment.values(),"one tap unfits the module "+label)
  await android_back();check(game.screen=="menu","Android Back leaves Fittings "+label)
 game._briefing(0);await settle()
 if game.get_node_or_null("ArcCard")!=null:await press(game,"arc_continue")
 var texts=game.panel_box.find_children("*","Label",true,false).map(func(l):return l.text)
 check(button(game,"fit_summary")!=null and not texts.any(func(t):return "FITTED" in t and "POWER" in t),"opening briefing keeps fit summary optional "+label)
 if await press(game,"fit_summary"):
  texts=game.panel_box.find_children("*","Label",true,false).map(func(l):return l.text)
  check(texts.any(func(t):return "FITTED" in t and "POWER" in t),"fit summary help reveals current craft details "+label)
 check(texts.any(func(t):return "DECOYS" in t and "TORPEDOES" in t),"briefing supplies line comes from the tool table "+label)
 game.queue_free();await settle()
 Settings.apply({})
func run():
 data_checks()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]:await shape_case(shape)
 print("FIT SURFACE UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
