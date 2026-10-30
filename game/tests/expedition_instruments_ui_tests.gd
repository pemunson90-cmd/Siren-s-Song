extends SceneTree
const Presentation=preload("res://src/presentation/expedition_view.gd")
var presentation=Presentation.new()
class PublicSignals:
 extends RefCounted
 var selected=1
 var mission={"id":6,"expedition_revision":1,"extraction":Vector2(400,2300)}
 var units=[{"name":"QUIETUS","pos":Vector2.ZERO},{"name":"DRONE A","pos":Vector2.ONE},{"name":"DRONE B","pos":Vector2.ONE*2}]
 var readings=[{"receiver":1,"origin":Vector2(100,200),"direction":Vector2.UP,"uncertainty":.65,"age":4.,"label":"CARRIER","time":3.},{"receiver":0,"origin":Vector2(300,400),"direction":Vector2.LEFT,"uncertainty":.18,"age":1.,"label":"OTHER","time":6.}]
 func signal_readings():return readings.duplicate(true)
 func observable_sites():return []
 func extraction_corridors():return []
class DrawingLog:
 extends RefCounted
 var world_scale=1.
 var feedback_font_size=25
 var calls=[]
 func screen_position(point):return point
 func draw_arc(origin,radius,start,end,segments,color,width):calls.append(["arc",origin,radius,start,end,segments,color,width])
 func draw_line(a,b,color,width):calls.append(["line",a,b,color,width])
 func draw_circle(origin,radius,color,filled,width):calls.append(["circle",origin,radius,color,filled,width])
 func _label(point,text,color,font_size):calls.append(["label",point,text,color,font_size])
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func click(button):
 var point=button.get_global_rect().get_center()
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.button_mask=MOUSE_BUTTON_MASK_LEFT if down else 0;e.pressed=down;root.push_input(e,true);await process_frame
 await settle()
func tap(point):
 for down in [true,false]:
  var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
 await settle()
func run():
 var permitted=PublicSignals.new();var drawing=DrawingLog.new()
 Presentation.draw(drawing,permitted)
 check(drawing.calls.filter(func(call):return call[0]=="arc").size()==1,"only selected receiver public arrival is drawn without raw source fields")
 var logged=drawing.calls.duplicate(true);permitted.units[1].pos=Vector2(9000,9000);permitted.mission["signal_sources"]=[{"pos":Vector2(99999,99999),"path":[Vector2.INF]}];drawing.calls=[];Presentation.draw(drawing,permitted)
 check(drawing.calls==logged,"current craft displacement and hidden source/path changes cannot alter historical arrival geometry")
 check(Presentation.pick(drawing,permitted,Vector2(100,50),98).is_empty(),"drawn arrival strokes carry no invisible route-stealing hit region")
 permitted.readings[0].direction=Vector2.ZERO;drawing.calls=[];Presentation.draw(drawing,permitted)
 check(drawing.calls.is_empty() and "unresolved" in Presentation.detail(permitted,1),"directionless reception cannot invent a directional pointer")
 check(presentation.has_method("measurements"),"expedition presentation exposes a public-observation-only selected receiver view")
 if failures:quit(1);return
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="expedition-instrument-ui"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(6);await settle()
  var h=g.mission_hud
  check(g.order_buttons.home.text=="WITHDRAW" and g.sim.observable_sites().is_empty(),"entry recovery says WITHDRAW without inventing source fixes")
  check(h.extra.has("arrivals"),"earned measurement details use the existing contextual HUD")
  # Owned receiver geometry fixture; received data still comes from real sensing.
  g.sim.units[1].pos=Vector2(650,1470);g.sim.command("select",{"unit":1});g.sim.paused=false;g.sim.advance(.1);g.sim.paused=true;g.ocean.focus_craft();g._layout();await settle()
  var readings=presentation.measurements(g.sim,1)
  check(not readings.is_empty() and readings.all(func(r):return r.receiver==1),"chart instrument uses only selected receiver public measurements")
  var before=g.sim.snapshot();var old=readings.duplicate(true);g.sim.advance(10)
  check(presentation.measurements(g.sim,1)==old and g.sim.snapshot()==before,"tactical pause freezes received age and earns no new observation")
  if not readings.is_empty():
   var position=readings[0].origin;g.sim.units[1].pos+=Vector2(25,0)
   check(presentation.measurements(g.sim,1)[0].origin==position,"old measurement stays at historical receiver origin after physical displacement")
   g.sim.units[1].pos-=Vector2(25,0)
  if h.extra.has("arrivals"):
   var badge=h.extra.arrivals;var scale=Vector2(dimensions)/root.get_visible_rect().size
   check(badge.visible and badge.size.x*scale.x>=126 and badge.size.y*scale.y>=126,"measurement badge has an explicit visible48dp target")
   await click(badge)
   check(g.advanced_orders and h.page=="signals" and g.sim.snapshot()==before,"separate measurement tap opens detail without route or tool spend")
   check("ARRIVAL" in h.instrument_info.text and "may bend" in h.instrument_info.text and "source fix" in h.instrument_info.text,"measurement detail attributes received uncertainty without exact-source promise")
   check(h.sheet.size.y<minf(g.size.y*.5,h.touch_height*3.2),"one measurement card sizes to content instead of filling the viewport")
   await click(h.close_button);check(not g.advanced_orders,"measurement BACK returns directly to the originating water view")
  var target=Vector2.INF
  if not readings.is_empty():
   for reach in [100,150,200,250]:
    var candidate=readings[0].origin+readings[0].direction*reach
    var local=g.ocean.screen_position(candidate);var global=g.ocean.global_position+local
    if Rect2(Vector2.ZERO,g.ocean.size).has_point(local) and not h.blocks(global) and not g.sim.blocked(candidate,25) and g.ocean.pick_context(local,g.ui_touch_height).is_empty():target=candidate;break
  check(target.is_finite(),"received fan leaves a visible clear-water planning point")
  if target.is_finite():
   await tap(g.ocean.global_position+g.ocean.screen_position(target))
   check(not g.advanced_orders and not g.sim.route_goals().is_empty() and g.sim.route_goals()[0].pos.distance_to(target)<.1,"ordinary tap along a received fan plots water instead of stealing input for details")
  # Portable scroll fixture: six public-shaped owned measurements; no source facts.
  var actual=g.sim.mission.signal_observations.duplicate(true)
  if not actual.is_empty():
   g.sim.mission.signal_observations=[]
   for receiver in 3:
    for n in 2:
     var sample=actual[0].duplicate(true);sample.receiver=receiver;sample.label="RECEIVED CARRIER %d"%n;g.sim.mission.signal_observations.append(sample)
  h.open("fleet");await settle()
  check(h.extra.arrivals.visible,"FLEET offers on-demand measurements from other owned receivers")
  await click(h.extra.arrivals)
  check(h.page=="signals" and h.subject.get("receiver",0)==-1,"fleet measurement view does not require changing selected craft")
  check(g.get_global_rect().encloses(h.sheet.get_global_rect()) and not h.sheet.get_global_rect().intersects(g.pause_button.get_global_rect()),"measurement sheet stays bounded below PAUSE with full-sized text")
  before=g.sim.snapshot();var point=h.sheet_scroll.get_global_rect().get_center()
  # Engine touchscreen fixture, matching the established density-scroll test:
  # Android delivers real touch plus the GUI's emulated mouse drag path.
  var was_touch=Input.is_emulating_touch_from_mouse();Input.set_emulate_touch_from_mouse(true)
  var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=true;root.push_input(e,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=true;root.push_input(mouse,true);await process_frame
  for n in 20:
   var at=point-Vector2(0,(n+1)*10)
   var drag=InputEventScreenDrag.new();drag.index=0;drag.position=at;drag.relative=Vector2(0,-10);root.push_input(drag,true)
   var motion=InputEventMouseMotion.new();motion.device=InputEvent.DEVICE_ID_EMULATION;motion.position=at;motion.global_position=at;motion.relative=Vector2(0,-10);motion.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(motion,true);await process_frame
  e=e.duplicate();e.position=point-Vector2(0,200);e.pressed=false;root.push_input(e,true)
  mouse=mouse.duplicate();mouse.position=e.position;mouse.global_position=e.position;mouse.pressed=false;root.push_input(mouse,true);await settle();Input.set_emulate_touch_from_mouse(was_touch)
  check(g.advanced_orders and h.page=="signals" and g.sim.snapshot()==before,"detail-panel touch scrolling preserves observation and tactical state")
  check(h.sheet_scroll.get_v_scroll_bar().max_value<=h.sheet_scroll.size.y or h.sheet_scroll.scroll_vertical>0,"overflowing measurement details are reachable by actual touch scroll")
  g.sim.mission.signal_observations=actual;h.dismiss();g.ocean.fit_chart();g._refresh();await settle()
  # Suspended root: child chart reservation settles before its hit map refresh.
  g._refresh();await settle();before=g.sim.snapshot()
  var corridor=g.sim.extraction_corridors().filter(func(c):return c.route=="shelf")[0]
  check(not h.blocks(g.ocean.global_position+g.ocean.screen_position(corridor.pos)),"arrival badge leaves the charted corridor target accessible")
  await tap(g.ocean.global_position+g.ocean.screen_position(corridor.pos))
  check(g.advanced_orders and h.subject.get("subkind","")=="corridor" and g.sim.snapshot()==before,"charted corridor tap opens observational context without choosing a branch")
  check(not g.order_buttons.camera.visible and "PLOT" in h.extra.route_here.text,"corridor offers explicit route planning rather than remote recording")
  check(g._ui_metrics().context_subject_kind=="corridor","native metrics distinguish charted corridor from ordinary camera-recordable site")
  h.dismiss();g._start_mission(0);await settle();check(g.order_buttons.home.text=="EXTRACT" and not h.extra.arrivals.visible,"tutorial craft and extraction controls remain unchanged")
  g.queue_free();await settle()
 print("EXPEDITION INSTRUMENT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
