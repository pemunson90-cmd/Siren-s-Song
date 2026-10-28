extends "res://tests/fix2_menu_ui_tests.gd"
const Rows029=preload("res://src/campaign/onboarding2/briefing_rows.gd")
const Ops029=preload("res://src/campaign/operation_catalog.gd")
const Prefs029=preload("res://src/presentation/frontend/frontend_settings.gd")
class Orders029 extends RefCounted:
 var expedition={}
 var texts=[]
 func _menu_text(text,_size):texts.append(text)
func progress029(id):
 var route=Ops029.definition(id).get("route","")
 if route.is_empty():route="deep"
 return {"version":2,"route":route,"routes":[route],"facts":{route:"Recovered branch account","confluence_route":"overt" if id==13 else "concealed"},"completed":[6,7 if route=="deep" else 8,9 if route=="deep" else 10,11,13 if id==13 else 12]+range(14,32 if id==32 else 30),"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":route}
func texts029(game):return "\n\n".join(game.panel_box.find_children("*","Label",true,false).map(func(label):return label.text))
func within029(control,area):
 if control==null:return false
 var rect=control.get_global_rect();var box=area.get_global_rect()
 return rect.position.x>=box.position.x-1 and rect.end.x<=box.end.x+1 and rect.position.y>=box.position.y-1 and rect.end.y<=box.end.y+1
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/onboard2_fixture_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 game.economy.unlocks=["hull:quiet","hull:fast","chassis:scout","chassis:heavy","chassis:endurance"];game.completed=[0,1,2,3,4,5];game.unlocked=5;game.active_started=false
 var prefs=preload("res://src/persistence/settings_store.gd").DEFAULTS.duplicate();prefs.text_scale=1.5;Prefs029.apply(prefs,game);await settle()
 check(is_equal_approx(Prefs029.text_scale(),1.5),"maximum real text setting active")
 for id in range(3,30)+[32]:
  game.expedition=progress029(id)
  check(game.ExpeditionCampaign.valid(game.expedition),"valid source-known briefing context "+str(id))
  game._briefing(id);await settle()
  var goal=Rows029.goal(id,game.OnboardingText.goal(id));var labels=game.panel_box.find_children("*","Label",true,false)
  var matching=labels.filter(func(label):return label.text==goal)
  if id in [3,6,32]:print("ONBOARD2_GEOMETRY ",JSON.stringify({"id":id,"shape":str(shape),"host":str(game.size),"scroll":str(game.scroll.get_global_rect()),"labels":labels.map(func(label):return {"text":label.text,"rect":str(label.get_global_rect()),"font":label.get_theme_font_size("font_size")}),"footer":game.menu_footer.get_children().map(func(c):return {"action":c.get_meta("ui_action",""),"rect":str(c.get_global_rect()),"minimum":str(c.custom_minimum_size)})}))
  check(matching.size()==1 and within029(matching[0],game.scroll),"all three facts above fold at150% "+str(id))
  var photo=preload("res://src/simulation/photo_pricing/photo_pricing_briefing.gd").line(id,game.fitted_equipment)
  if not photo.is_empty():
   var line=labels.filter(func(label):return label.text==photo)
   check(line.size()==1 and within029(line[0],game.scroll),"unchanged photo problems above fold "+str(id))
  check(within029(button(game,"manual"),game.menu_footer),"manual pinned above fold "+str(id))
  var fold=button(game,"fit_fold")
  check(fold!=null and "SHOW" in fold.text,"preparation initially folded "+str(id))
  for action in ["begin","manual","back","fit_fold"]:
   var b=button(game,action)
   check(b!=null and b.size.x>=game.ui_touch_height and b.size.y>=game.ui_touch_height and within029(b,game) and within029(b,game.menu_footer),"visible48dp action %s op%d"%[action,id])
  var capture=OS.get_environment("SIRENS_029_CAPTURE_DIR")
  if id in [6,12,25,32] and not capture.is_empty() and DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   check(root.get_texture().get_image().save_png(capture+"/brief-%02d-%dx%d.png"%[id,shape.x,shape.y])==OK,"native large-text briefing captured")
  var original=game.Simulation.Missions.make(id,game._launch_context(id))
  var orders=Orders029.new();orders.expedition=game.expedition
  game.ExpeditionOperations.briefing(orders,id)
  if await press(game,"manual"):
   check(game.screen=="reference" and original.brief in texts029(game),"full original contextual brief retained "+str(id))
   for text in orders.texts:check(text in texts029(game),"all original local-order instructions retained "+str(id))
   if await press(game,"back"):check(game.screen=="briefing","real manual Back returns to briefing")
 game.expedition=progress029(6);game._briefing(6);await settle()
 var before=game.sim.snapshot()
 if await press(game,"fit_fold"):
  if await press(game,"frame_quietus_quiet"):
   check(game.fitted_equipment.hull=="quiet" and "HIDE" in button(game,"fit_fold").text,"equipment rebuild preserves selection and expanded fittings")
   check(game.sim.snapshot()==before,"choosing next fitting does not alter active dive")
   if await press(game,"manual"):
    if await press(game,"back"):check("HIDE" in button(game,"fit_fold").text,"manual return retains expanded preparation")
   root.size=Vector2i(2184,1968) if shape==Vector2i(2520,1080) else Vector2i(2520,1080);await settle()
   check("HIDE" in button(game,"fit_fold").text and within029(button(game,"begin"),game.menu_footer),"folding the display retains expanded preparation and visible navigation")
   root.size=shape;await settle()
   check(within029(button(game,"back"),game.menu_footer),"returning display shape restores safe footer layout")
 game._show_campaign();game._briefing(6);await settle()
 check("SHOW" in button(game,"fit_fold").text,"fresh visit starts folded again")
 if await press(game,"begin"):check(game.screen=="mission" and game.sim.mission.id==6 and game.sim.paused,"real touch launches the selected dive paused")
 game._show_campaign();game._briefing(6);await settle();await android_back()
 check(game.screen=="menu","Android Back returns to operations")
 Rows029.enabled=false;game._briefing(6);await settle()
 check(game.Simulation.Missions.make(6,game._launch_context(6)).brief in texts029(game) and "HIDE" in button(game,"fit_fold").text,"off switch restores full legacy briefing and expanded preparation")
 Rows029.enabled=true
 for id in [0,1,2]:
  game._briefing(id);await settle()
  check(game.OnboardingText.goal(id) in texts029(game) and not "NEW THIS DIVE:" in texts029(game),"first three briefings retain existing text")
 game.queue_free();await settle()
func run():
 var previous=Prefs029.current.duplicate(true)
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 Prefs029.apply(previous)
 print("ONBOARD2 UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
