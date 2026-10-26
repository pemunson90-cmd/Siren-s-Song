extends "res://tests/status_text_ui_tests.gd"
# Focused Hunt presentation tests. Recon.action below is a labeled display fixture;
# every touch/refresh assertion compares the valid simulation snapshot afterward.
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const HuntTable=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
const Meter=preload("res://src/presentation/hunt_meter.gd")
const SHAPES=[Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]
func chip(hud)->Button:
 return hud.find_child("HuntMeterButton",true,false) as Button
func visible_chip(game,label:String):
 var hud=game.mission_hud
 var button=chip(hud)
 check(button!=null and button.is_visible_in_tree(),label+" Hunt chip is visible")
 if button==null:return null
 var state=Hunt.view(game.sim)
 check(state.active and button.text.replace("\n","").contains(state.stage) and button.text.contains("×%.2f"%state.scale),label+" word and capped factor match public Hunt view")
 check(button.text.count("●")+button.text.count("○")==5 and button.text.contains("HUNT"),label+" Hunt has five visible pips and a word")
 var rect=button.get_global_rect()
 var safe=Rect2(game.global_position,game.size)
 var dp_scale=160.0/420.0*float(root.size.x)/root.get_visible_rect().size.x
 check(safe.encloses(rect),label+" Hunt chip fits the safe viewport")
 check(rect.size.x*dp_scale>=48.0 and rect.size.y*dp_scale>=48.0,label+" Hunt touch target retains 48dp")
 for other in hud.action_controls().values():
  if other==button or not other.is_visible_in_tree():continue
  check(not rect.intersects(other.get_global_rect()),label+" Hunt stays clear of "+str(other.get_meta("action","control")))
 if hud.alarm.visible:check(not rect.intersects(hud.alarm.get_global_rect()),label+" Hunt stays clear of genuine warning")
 if hud.page=="fleet" and hud.extra.arrivals.is_visible_in_tree():check(not rect.intersects(hud.extra.arrivals.get_global_rect()),label+" Hunt stays clear of ARRIVALS")
 return button
func same_dive_except_pause(before:Dictionary,after:Dictionary,label:String):
 check(Sim.valid_snapshot(after),label+" snapshot remains valid")
 var expected=before.duplicate(true);expected.paused=after.paused
 check(after==expected,label+" touch changes no dive state beyond explicit pause")
func touch_shape(shape:Vector2i):
 var game=await make_game(6,shape)
 var label="op6 "+str(shape)
 var hud=game.mission_hud
 var view=Hunt.view(game.sim)
 check(view.active and view.index==0 and view.scale<=view.cap,label+" authored Hunt starts active at stage zero")
 var before=game.sim.snapshot()
 var button=visible_chip(game,label+" basic")
 await picture("hunt-%d-basic"%shape.x)
 if button!=null:await tap(button.get_global_rect().get_center())
 check(hud.page=="order_help" and game.advanced_orders and game.sim.paused,label+" actual basic Hunt touch opens paused explanation")
 check(not chip(hud).is_visible_in_tree(),label+" explanation sheet is clear of its opener")
 check(hud.instrument_info.is_visible_in_tree() and "sight" in hud.instrument_info.text.to_lower() and "hearing" in hud.instrument_info.text.to_lower() and "local" in hud.instrument_info.text.to_lower(),label+" visible explanation identifies sight-only global factor and local alert")
 await picture("hunt-%d-help"%shape.x)
 same_dive_except_pause(before,game.sim.snapshot(),label+" basic help")
 await android_back()
 check(not game.advanced_orders and game.screen=="mission",label+" Android Back returns basic water HUD")
 await tap(game.advanced_button.get_global_rect().get_center())
 check(hud.page=="fleet",label+" real touch opens advanced Fleet")
 button=visible_chip(game,label+" advanced")
 await picture("hunt-%d-advanced"%shape.x)
 if button!=null:await tap(button.get_global_rect().get_center())
 check(hud.page=="order_help" and hud.help_return=="fleet",label+" actual advanced Hunt touch remembers Fleet")
 check(not chip(hud).is_visible_in_tree(),label+" advanced explanation sheet is clear of its opener")
 await android_back()
 check(hud.page=="fleet" and game.advanced_orders,label+" Android Back restores Fleet")
 same_dive_except_pause(before,game.sim.snapshot(),label+" advanced help")
 game.queue_free();await settle()
func presentation_fixture():
 var game=await make_game(6,Vector2i(2184,1968))
 var hud=game.mission_hud
 # Explicit source action fixture: enough public operational pressure for stage 2.
 Recon.action(game.sim.mission,50.0)
 var before=game.sim.snapshot();check(Sim.valid_snapshot(before),"stage fixture remains a valid save")
 game._refresh();await settle()
 var state=Hunt.view(game.sim)
 check(state.index==2 and state.scale<=state.cap,"stage fixture displays capped SEARCHING factor")
 visible_chip(game,"stage fixture")
 await picture("hunt-2184-searching")
 # Presentation-only warning fixture: a real warning label must survive sync.
 hud.alarm.text="HEARD PATROLLER · 040°";hud.alarm.show()
 Meter.sync(hud)
 check(hud.alarm.visible and hud.alarm.text.begins_with("HEARD") and not chip(hud).get_global_rect().intersects(hud.alarm.get_global_rect()),"Hunt preserves and clears a genuine warning")
 await tap(game.advanced_button.get_global_rect().get_center())
 hud.alarm.text="HEARD PATROLLER · 040°";hud.alarm.show()
 Meter.sync(hud)
 check(hud.page=="fleet" and hud.alarm.visible and hud.alarm.text.begins_with("HEARD") and not chip(hud).get_global_rect().intersects(hud.alarm.get_global_rect()),"advanced Hunt preserves and clears a genuine warning")
 await picture("hunt-2184-warning")
 await tap(hud.close_button.get_global_rect().get_center())
 check(game.sim.snapshot()==before,"warning display sync leaves the dive unchanged")
 HuntTable.enabled=false;game._refresh();await settle()
 check(not chip(hud).is_visible_in_tree() and hud.alarm.visible and hud.alarm.text.begins_with("OP PRESSURE"),"flag off restores old basic pressure display")
 check(game.sim.snapshot()==before,"flag off display leaves the dive unchanged")
 HuntTable.enabled=true
 # Legacy fixture uses a validated old-save snapshot with the optional field absent.
 var legacy=before.duplicate(true);legacy.mission.erase("hunt_pressure")
 check(Sim.valid_snapshot(legacy) and game.sim.restore(legacy),"legacy snapshot without Hunt field restores")
 game._refresh();await settle()
 check(not Hunt.view(game.sim).active and not chip(hud).is_visible_in_tree(),"legacy mission keeps the old HUD")
 game.queue_free();await settle()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 if not capture_dir.is_empty():DirAccess.make_dir_recursive_absolute(capture_dir)
 HuntTable.enabled=true
 await presentation_fixture()
 for shape in SHAPES:await touch_shape(shape)
 HuntTable.enabled=true;Settings.apply(Store.DEFAULTS)
 print("HUNT METER UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
