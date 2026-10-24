extends "res://tests/fix2_menu_ui_tests.gd"
# Controlled campaign fixtures, real touch, no operation finishability claim.
const Prefs=preload("res://src/presentation/frontend/frontend_settings.gd")
const HomeTable=preload("res://src/presentation/ops_home/ops_home_table.gd")
var case_label=""
func check(ok,label):super.check(ok,label+" "+case_label)
func home_case(shape, recovered, scale):
 case_label=str([shape,recovered,scale])
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate()
 # Fold7 uses recorded Android density; 960x432 is the desktop fallback.
 if shape.x!=960:game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 var prefs=Prefs.SettingsStore.DEFAULTS.duplicate();prefs.text_scale=scale;Prefs.apply(prefs,game);await settle()
 game.completed=range(mini(recovered,6));game.unlocked=mini(recovered,5);game.active_started=false
 if recovered>=6:game.expedition={"version":1,"route":"deep","routes":["deep"],"facts":{},"completed":range(6,recovered)}
 var before=[game.completed.duplicate(),game.expedition.duplicate(true),game.sim.snapshot()]
 game._show_campaign();await settle()
 var next=button(game,"next_operation")
 check(next!=null,"next operation exists "+str([shape,recovered]))
 if next!=null:
  check(game.scroll.get_global_rect().encloses(next.get_global_rect()),"next operation requires no scrolling")
  check(next.size.y>=game.ui_touch_height,"next operation touch height")
 for id in ["route_map","fittings"]:
  var b=button(game,id)
  check(b!=null and game.scroll.get_global_rect().encloses(b.get_global_rect()),id+" fits the first screen")
 var capture=OS.get_environment("SIRENS_038_CAPTURE_DIR")
 if recovered in [0,16,32] and scale==1.5 and not capture.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  check(root.get_texture().get_image().save_png(capture+"/home-%02d-%dx%d.png"%[recovered,shape.x,shape.y])==OK,"native large-text home captured")
 check(button(game,"new_campaign")==null,"erase is absent from Operations")
 var fold=button(game,"recovered_fold")
 var shown_recovered=mini(recovered,6)
 for id in game.ExpeditionCampaign.available(game.completed,game.expedition):
  if id in game.expedition.get("completed",[]):shown_recovered+=1
 check(fold!=null and "(%d)"%shown_recovered in fold.text,"recovered fold counts the launchable recovered rows")
 var row=button(game,"mission0")
 check((row!=null)==(recovered<3),"recovered default visibility follows threshold")
 if fold!=null and recovered>0:
  await press(game,"recovered_fold")
  check((button(game,"mission0")!=null)==(recovered>=3),"touch toggles recovered rows")
  await press(game,"recovered_fold")
  check([game.completed,game.expedition,game.sim.snapshot()]==before,"fold never changes progress or simulation")
 game.scroll.scroll_vertical=0;await settle()
 var anchor=button(game,"fittings").get_global_rect().position
 game.active_started=true;game._show_campaign();await settle()
 check(button(game,"resume")!=null,"active dive offers resume")
 if not button(game,"fittings").get_global_rect().position.is_equal_approx(anchor):
  print("HOME_RESUME_DIAG ",case_label," before=",anchor," after=",button(game,"fittings").get_global_rect()," scroll=",game.scroll.scroll_vertical," panel=",game.panel_box.size," bar=",game.scroll.get_v_scroll_bar().visible)
 check(button(game,"fittings").get_global_rect().position.is_equal_approx(anchor),"resume preserves row positions")
 if recovered==32 and shape==Vector2i(2520,1080):check(game.panel_box.size.y/game.scroll.size.y<3.,"all recovered home is under three screens")
 if recovered==0:
  await press(game,"next_operation");check(game.screen=="briefing" and game.get_meta("onboard2_fit_index",-1)==0,"next opens first available briefing by touch")
 elif recovered==32:check(button(game,"next_operation").disabled,"fully recovered campaign offers no invented next operation")
 else:
  var expected=-1
  for id in range(6)+game.ExpeditionCampaign.available(game.completed,game.expedition):
   if id not in game._campaign_completed() and (id>=6 or id<=game.unlocked):expected=id;break
  await press(game,"next_operation")
  check(game.screen=="briefing" and game.get_meta("onboard2_fit_index",-1)==expected,"next opens first existing AVAILABLE row")
 game._show_campaign();await settle()
 for id in ["route_map","fittings"]:
  await press(game,id)
  check(game.screen==id,"home shortcut opens "+id)
  await android_back();check(game.screen=="menu","Android Back returns from "+id)
 game._settings_menu();await settle()
 if recovered>0:
  check(button(game,"new_campaign")!=null,"Settings retains erase entry")
  await press(game,"new_campaign");check(game.screen=="new_campaign","Settings erase keeps confirmation")
  await android_back();check(game.screen=="menu","Back keeps progress at erase confirmation")
 HomeTable.enabled=false;game._show_campaign();await settle()
 check(button(game,"next_operation")==null and button(game,"mission0")!=null,"off switch restores original operation rows")
 check((button(game,"new_campaign")!=null)==(recovered>0),"off switch restores original erase placement")
 HomeTable.enabled=true
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]:
  for scale in [1.,1.5]:
   for count in [0,2,3,16,32]:await home_case(shape,count,scale)
 print("OPS HOME UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
