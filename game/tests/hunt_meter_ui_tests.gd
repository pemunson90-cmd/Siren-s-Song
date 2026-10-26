extends "res://tests/status_text_ui_tests.gd"
# Focused Hunt presentation tests. Recon.action below is a labeled display fixture;
# every touch/refresh assertion compares the valid simulation snapshot afterward.
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const HuntTable=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
const Meter=preload("res://src/presentation/hunt_meter.gd")
const MeterTable=preload("res://src/presentation/hunt_meter/meter_table.gd")
const SHAPES=[Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]
func pulse_contract():
 var view={"active":true,"index":4,"stage":"LOCKDOWN","scale":1.3}
 var title=Meter.label(view)
 var t0:Color=Meter.tone(view,0.0)
 var t25:Color=Meter.tone(view,0.25)
 var t50:Color=Meter.tone(view,0.50)
 var t75:Color=Meter.tone(view,0.75)
 var t100:Color=Meter.tone(view,1.0)
 check(is_equal_approx(t0.a,t100.a) and t25.a>t0.a and t0.a>t75.a and is_equal_approx(t0.a,t50.a),"LOCKDOWN color follows one full period per second")
 check(t75.a>=MeterTable.PULSE_MIN_ALPHA and t25.a<=1.0 and t75.a<t25.a,"LOCKDOWN alpha stays readable within its table bounds")
 for index in 4:
  var other=view.duplicate();other.index=index
  check(Meter.tone(other,0.25)==MeterTable.TONES[index] and Meter.tone(other,0.75)==MeterTable.TONES[index],"non-LOCKDOWN stage %d keeps its exact tone"%index)
 check(Meter.tone(view,0.75,0.0)==MeterTable.TONES[4],"zero hertz disables the pulse")
 var off=view.duplicate();off.active=false
 check(Meter.tone(off,0.75)==MeterTable.TONES[4],"inactive Hunt does not pulse")
 check(Meter.label(view)==title and title.contains("LOCKDOWN") and title.count("●")==5,"pulse never changes LOCKDOWN wording or five pips")
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
func swipe_help(hud):
 var box=hud.sheet_scroll.get_global_rect()
 var start=box.position+Vector2(box.size.x*.5,box.size.y*.8)
 var was_touch=Input.is_emulating_touch_from_mouse();Input.set_emulate_touch_from_mouse(true)
 var touch_down=InputEventScreenTouch.new();touch_down.index=0;touch_down.position=start;touch_down.pressed=true;root.push_input(touch_down,true)
 var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=start;mouse.global_position=start;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=true;root.push_input(mouse,true);await process_frame
 for n in 20:
  var at=start-Vector2(0,(n+1)*10)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=at;drag.relative=Vector2(0,-10);root.push_input(drag,true)
  var motion=InputEventMouseMotion.new();motion.device=InputEvent.DEVICE_ID_EMULATION;motion.position=at;motion.global_position=at;motion.relative=Vector2(0,-10);motion.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(motion,true);await process_frame
 touch_down.position=start-Vector2(0,200);touch_down.pressed=false;root.push_input(touch_down,true)
 mouse.position=touch_down.position;mouse.global_position=touch_down.position;mouse.pressed=false;root.push_input(mouse,true);await settle();Input.set_emulate_touch_from_mouse(was_touch)
func compact_help(game,label:String):
 var hud=game.mission_hud
 var safe=Rect2(game.global_position,game.size)
 var sheet=hud.sheet.get_global_rect();var back=hud.close_button.get_global_rect()
 var font=hud.instrument_info.get_theme_font("font")
 var row=font.get_height(hud.instrument_info.get_theme_font_size("font_size"))
 var scroll=hud.sheet_scroll.get_global_rect()
 check(safe.encloses(sheet) and safe.encloses(back) and not sheet.intersects(back),label+" Hunt help sheet and full Back fit side by side")
 check(scroll.size.y>=row*2,label+" Hunt help initially exposes at least two complete text rows")
 var dp_scale=160.0/420.0*float(root.size.x)/root.get_visible_rect().size.x
 check(back.size.x*dp_scale>=48 and back.size.y*dp_scale>=48,label+" Hunt help Back retains 48dp")
 var before=game.sim.snapshot();var offset=hud.sheet_scroll.scroll_vertical
 for n in 6:
  await swipe_help(hud)
  if hud.instrument_info.get_global_rect().end.y<=hud.sheet_scroll.get_global_rect().end.y+2:break
 check(hud.sheet_scroll.scroll_vertical>offset,label+" real touch scroll exposes later Hunt explanation")
 check(hud.instrument_info.get_global_rect().end.y<=hud.sheet_scroll.get_global_rect().end.y+2,label+" real touch scroll reaches the final Hunt explanation line")
 check(game.sim.snapshot()==before,label+" help scrolling leaves the dive unchanged")
 await picture("hunt-960-help-scrolled")
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
 if shape.x==960:await compact_help(game,label)
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
func lockdown_fixture():
 var game=await make_game(6,Vector2i(2184,1968))
 # Explicit source action fixture for the presentation-only LOCKDOWN stage.
 Recon.action(game.sim.mission,95.0)
 var before=game.sim.snapshot();game._refresh();await settle()
 var view=Hunt.view(game.sim);var button=visible_chip(game,"LOCKDOWN fixture")
 check(view.index==4 and button.get_theme_color("font_color").a>=MeterTable.PULSE_MIN_ALPHA,"visible LOCKDOWN chip keeps the bounded alpha")
 var color=button.get_theme_color("font_color");game._refresh();await settle()
 check(button.get_theme_color("font_color")==color and game.sim.snapshot()==before,"paused simulation clock holds the LOCKDOWN pulse without dive writes")
 await picture("hunt-2184-lockdown")
 game.queue_free();await settle()
func observed_lock_fixture(shape:Vector2i):
 var game=await make_game(0,shape)
 var sim=game.sim;var warning=game.lock_warning;var hud=game.mission_hud
 # The established lock_warning_ui_tests observed-contact fixture, at 150% text.
 sim.elapsed=10.0
 sim.contacts={0:{"pos":sim.units[0].pos+Vector2(80,0),"time":10.0,"mode":"LOCKING","lock":2.0,"target":0,"type":"patroller","source":"optical","angle":0.0,"band":1}}
 var before=sim.snapshot();game._refresh();await settle()
 var label="observed lock "+str(shape)
 var banner=Rect2(warning.global_position+warning.banner.position,warning.banner.size)
 var button=visible_chip(game,label+" basic")
 check(warning.visible and warning.locks.size()==1 and warning.show_hint,label+" earned countdown and break-sight hint are visible")
 check(Rect2(game.global_position,game.size).encloses(banner) and banner.has_area(),label+" lock banner fits the safe viewport")
 check(button!=null and not button.get_global_rect().intersects(banner),label+" Hunt chip clears the live lock banner")
 check(not banner.intersects(game.pause_button.get_global_rect()),label+" lock banner preserves Pause")
 await picture("hunt-lock-%d-basic"%shape.x)
 await tap(game.advanced_button.get_global_rect().get_center())
 button=visible_chip(game,label+" advanced")
 banner=Rect2(warning.global_position+warning.banner.position,warning.banner.size)
 check(hud.page=="fleet" and warning.visible and not button.get_global_rect().intersects(banner),label+" Fleet Hunt chip clears the live lock banner")
 check(Rect2(game.global_position,game.size).encloses(hud.close_button.get_global_rect()) and not banner.intersects(hud.close_button.get_global_rect()),label+" full Back remains accessible beside lock warning")
 await picture("hunt-lock-%d-advanced"%shape.x)
 await tap(hud.close_button.get_global_rect().get_center())
 check(not game.advanced_orders and sim.snapshot()==before,label+" Back returns to water without changing the observed lock")
 game.queue_free();await settle()
func route_touch(point:Vector2,down:bool,id:int=0):
 var event=InputEventScreenTouch.new();event.index=id;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
func route_move(point:Vector2,delta:Vector2,id:int=0):
 var event=InputEventScreenDrag.new();event.index=id;event.position=point;event.relative=delta;root.push_input(event,true);await process_frame
func manual_craft_fixture(shape:Vector2i):
 # The route telemetry fixture's public craft positions and manual camera pan.
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="route-telemetry-touch-fixture"
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
 var sim=game.sim;var hud=game.mission_hud;var fleet=hud.fleet
 sim.sirens=[];sim.mission.rocks=[];sim.mission.structures=[];sim.mission.objectives=[];sim._build_navigation()
 sim.units[0].pos=Vector2(450,620);sim.units[1].pos=Vector2(900,720);sim.units[2].pos=Vector2(1460,160)
 game.ocean.fit_chart();game._refresh();await settle()
 var point=fleet.telemetry[0].get_global_rect().get_center()
 await tap(point)
 sim.command("queue");game._refresh();await settle();point=fleet.telemetry[0].get_global_rect().get_center();await tap(point)
 game.mission_hud.guard.reset();game._refresh();await settle()
 point=fleet.telemetry[0].get_global_rect().get_center()
 await route_touch(point,true);await route_move(point+Vector2(90,35),Vector2(90,35));await route_touch(point+Vector2(90,35),false);await settle()
 point=fleet.telemetry[0].get_global_rect().get_center();var start_below=point+Vector2(0,fleet.telemetry[0].size.y+20)
 await route_touch(start_below,true);await route_move(point,point-start_below);await route_touch(point,false);await settle()
 point=fleet.telemetry[0].get_global_rect().get_center()
 await route_touch(point,true);await route_touch(point+Vector2(160,0),true,1);await route_move(point+Vector2(200,20),Vector2(40,20),1);await route_touch(point,false);await route_touch(point+Vector2(200,20),false,1);await settle()
 point=fleet.telemetry[0].get_global_rect().get_center();await route_touch(point,true)
 var cancel=InputEventScreenTouch.new();cancel.index=0;cancel.position=point;cancel.pressed=false;cancel.canceled=true;root.push_input(cancel,true);await process_frame
 await route_touch(point,false);await settle()
 game.ocean.focus_craft();game._refresh();await settle()
 await tap(fleet.buttons[2].get_global_rect().get_center())
 await tap(fleet.buttons[2].get_global_rect().get_center())
 hud.dismiss();await settle()
 point=fleet.telemetry[2].get_global_rect().get_center();hud.open("craft");await settle();await tap(point)
 hud.dismiss();await settle()
 var start=fleet.buttons[1].get_global_rect().get_center();var water=fleet.telemetry[2].get_global_rect().get_center()
 await route_touch(start,true);await route_touch(water,true,1);await route_touch(start,false);await route_touch(water,false,1);await settle()
 start=fleet.buttons[1].get_global_rect().get_center();water=fleet.telemetry[2].get_global_rect().get_center()
 await route_touch(water,true);await route_touch(start,true,1);await route_touch(water,false);await route_touch(start,false,1);await settle()
 game.ocean.pan_chart(Vector2(-140,30));game._refresh();await settle()
 var label="manual craft "+str(shape)
 var projected=game.ocean.global_position+game.ocean.screen_position(sim.units[2].pos)
 var pick=game.ocean.pick_context(projected-game.ocean.global_position,game.ui_touch_height)
 var reading=fleet.readouts.filter(func(r):return r.unit==2)[0]
 var meter=chip(hud)
 var touch_rect=Rect2(projected-Vector2.ONE*game.ui_touch_height*.5,Vector2.ONE*game.ui_touch_height)
 check(pick.get("kind","")=="craft" and pick.get("unit",-1)==2,label+" projected craft is a public interactive target")
 check(not meter.get_global_rect().intersects(touch_rect),label+" Hunt chip clears the full projected craft touch handle")
 check(not reading.offscreen,label+" visible craft keeps its direct handle after manual pan")
 var before=sim.snapshot()
 await tap(fleet.buttons[2].get_global_rect().get_center())
 check(game.advanced_orders and hud.page=="craft" and game.ocean.chart_camera.mode=="free" and sim.snapshot()==before,label+" craft tap opens in place without changing dive or camera")
 await picture("hunt-manual-craft-%d"%shape.x)
 game.queue_free();await settle()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 if not capture_dir.is_empty():DirAccess.make_dir_recursive_absolute(capture_dir)
 HuntTable.enabled=true
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await manual_craft_fixture(shape)
 pulse_contract()
 await presentation_fixture()
 await lockdown_fixture()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await observed_lock_fixture(shape)
 for shape in SHAPES:await touch_shape(shape)
 HuntTable.enabled=true;Settings.apply(Store.DEFAULTS)
 print("HUNT METER UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
