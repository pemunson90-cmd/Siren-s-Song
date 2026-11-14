extends Control
const HullBand=preload("res://src/presentation/route_clearance/hull_band.gd")
const EarnedChart=preload("res://src/presentation/earned_chart_view.gd")
signal point_chosen(point:Vector2)
signal view_changed
var sim
var selected_goal=0
var chart_camera=preload("res://src/presentation/chart_camera.gd").new()
var map_gesture=preload("res://src/input/map_gesture.gd").new()
var navigation_buttons:Array=[]
var touch_height=48.0
var navigation_font_size=14
var view_report_pending=false
# Presentation navigation intent, independent of layout-driven camera changes.
var navigation_revision=0
# WP-52: a point that waits for its second tap because its leg crosses charted rock (null when none waits).
var pending_point=null
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const ContactFeedback=preload("res://src/presentation/contact_feedback.gd")
const SightRange=preload("res://src/simulation/parity_rules/sight_range.gd")
# WP-110: where the waiting point's leg first meets rock (null when none), and the same for the programmed route.
var pending_rock=null
var _rock_key=[]
var _rock_marks:Array=[]
func leg_crosses_rock(a:Vector2,b:Vector2) -> bool:
 return leg_rock_point(a,b)!=null
func leg_rock_point(a:Vector2,b:Vector2):
 if sim==null or not HandPilot.release(sim):return null
 sim._use_band(sim.units[sim.selected].band)
 return HandPilot.rock_point(sim,a,b)
# Points on the programmed route where a leg first meets charted rock; HandPilot.warnings is the call the dive chart's
# red leg uses, so both screens mark the same rock. Recomputed only when the route or craft moves.
func rock_marks() -> Array:
 if sim==null or not HandPilot.release(sim):return []
 var u=sim.units[sim.selected]
 var key=[sim.selected,u.pos,u.route.map(func(node):return node.pos)]
 if key!=_rock_key:
  _rock_key=key;_rock_marks=[];_rock_legs=[]
  for w in HandPilot.warnings(sim,sim.selected):
   if w.reason==HandPilot.ROCK_REASON and w.has("at"):_rock_marks.append(w.at);_rock_legs.append([w.from,w.to])
 return _rock_marks
# WP-117: the legs the dive chart draws red (the same HandPilot.warnings), so this screen draws them red too, not just a mark.
var _rock_legs:Array=[]
func rock_legs() -> Array:
 rock_marks()
 return _rock_legs
# The Sirens the player knows about, drawn as the dive chart shows them: last-seen position (dashed ring), name tag
# and the sight ring of a photographed type. Only sim.contacts and the sight rule's public rows; never the live roster.
func known_sirens() -> Array:
 return ContactFeedback.entries(sim.contacts,sim.elapsed,sim.units,sim.line_clear,sim.contact_target,sim.lock_seconds()) if sim!=null else []
func _draw_known_sirens(scale:float) -> void:
 var entries=known_sirens()
 draw_set_transform(chart_camera.offset,0,Vector2.ONE*scale)
 for row in SightRange.rows(sim):
  var ink:Color=Palette.chart_color("warning",Color("ffb18b"));ink.a=.55
  draw_arc(row.pos,row.radius,0,TAU,72,ink,1.2/scale)
 for entry in entries:
  var ink:Color=Palette.chart_color("threat",Color("ed8e79") if entry.fresh else Color("b09a94"))
  draw_arc(entry.pos,48,0,TAU,48,Color("07131b"),4./scale)
  Palette.ring(self,entry.pos,48,ink,2./scale,"threat")
  draw_circle(entry.pos,5./scale,ink)
 draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
 for entry in entries:
  var anchor=chart_camera.to_screen(entry.pos)+Vector2(12,-18)
  var width=ThemeDB.fallback_font.get_string_size(entry.name,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size).x
  draw_rect(Rect2(anchor-Vector2(3,navigation_font_size),Vector2(width+6,navigation_font_size+5)),Color(0.025,0.06,0.075,0.94))
  draw_string(ThemeDB.fallback_font,anchor,entry.name,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,Color("ed8e79") if entry.fresh else Color("b09a94"))
# A red cross and the word ROCK where a leg meets rock (screen space).
func _draw_rock_mark(world:Vector2) -> void:
 var at=chart_camera.to_screen(world);var ink=UiStyle.DANGER_RED
 draw_arc(at,12,0,TAU,24,Color("07131b"),5.);draw_arc(at,12,0,TAU,24,ink,2.5)
 draw_line(at+Vector2(-7,-7),at+Vector2(7,7),ink,2.5);draw_line(at+Vector2(-7,7),at+Vector2(7,-7),ink,2.5)
 draw_string(ThemeDB.fallback_font,at+Vector2(16,5),Words.PROGRAM_ROCK,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,UiStyle.DANGER_SOFT)
func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP;clip_contents=true
 for i in 3:
  var b=Button.new();b.text=["−","+","FIT"][i];b.set_meta("action",["planner_zoom_out","planner_zoom_in","planner_fit"][i]);b.focus_mode=Control.FOCUS_NONE;add_child(b);navigation_buttons.append(b)
 navigation_buttons[0].pressed.connect(func():zoom_at(1./1.5,size/2))
 navigation_buttons[1].pressed.connect(func():zoom_at(1.5,size/2))
 navigation_buttons[2].pressed.connect(fit_chart)
 resized.connect(func():map_gesture.cancel();configure_navigation(touch_height,navigation_font_size))
 visibility_changed.connect(func():
  if not is_visible_in_tree():map_gesture.cancel())
 configure_navigation(touch_height,navigation_font_size)
func configure_navigation(h:float,font_size:int):
 touch_height=h;navigation_font_size=font_size
 for i in navigation_buttons.size():
  var b=navigation_buttons[i];b.custom_minimum_size=Vector2.ONE*h;b.size=Vector2.ONE*h
  b.position=Vector2(size.x-8-(3-i)*h-(2-i)*6,8);b.add_theme_font_size_override("font_size",font_size)
 chart_camera.configure(size,world_size());_view_changed()
func _view_changed():
 queue_redraw()
 if view_report_pending:return
 view_report_pending=true;call_deferred("_emit_view_changed")
func _emit_view_changed():
 view_report_pending=false
 if is_visible_in_tree():view_changed.emit()
func world_size() -> Vector2:
 return sim.world_size() if sim!=null and sim.has_method("world_size") else Vector2(1600,960)
func chart_rect() -> Rect2:
 chart_camera.configure(size,world_size());return Rect2(chart_camera.offset,world_size()*chart_camera.scale)
func map_position(point:Vector2) -> Vector2:
 chart_camera.configure(size,world_size());return chart_camera.to_world(point)
func screen_position(world:Vector2) -> Vector2:
 chart_camera.configure(size,world_size());return chart_camera.to_screen(world)
func zoom_at(factor:float,anchor:Vector2):
 navigation_revision+=1;map_gesture.cancel();chart_camera.configure(size,world_size());chart_camera.zoom_at(factor,anchor);_view_changed()
func pan_chart(delta:Vector2):
 navigation_revision+=1;chart_camera.configure(size,world_size());chart_camera.pan(delta);_view_changed()
func fit_chart():
 navigation_revision+=1;map_gesture.cancel();chart_camera.configure(size,world_size());chart_camera.fit();_view_changed()
func _input(event):
 if not is_visible_in_tree() or not map_gesture.active():return
 if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:map_gesture.cancel();return
 var pressed=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed)
 if pressed and (not get_global_rect().has_point(event.position) or navigation_buttons.any(func(b):return b.get_global_rect().has_point(event.position))):map_gesture.cancel();return
 if _pointer_event(event,false):get_viewport().set_input_as_handled()
func _gui_input(event):
 if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
  zoom_at(1.5 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 1./1.5,event.position);accept_event();return
 var pressed=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT)
 if pressed and _pointer_event(event,true):accept_event()
func _pointer_event(event,local:bool) -> bool:
 if event.device==InputEvent.DEVICE_ID_EMULATION:return false
 if event is InputEventScreenTouch and event.canceled:map_gesture.cancel();return true
 var kind="";var key=-1;var point=Vector2.ZERO
 if event is InputEventScreenTouch:key=event.index;point=event.position;kind="press" if event.pressed else "release"
 elif event is InputEventScreenDrag:key=event.index;point=event.position;kind="move"
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:point=event.position;kind="press" if event.pressed else "release"
 elif event is InputEventMouseMotion:point=event.position;kind="move"
 if kind.is_empty():return false
 if not local:point-=global_position
 var action=map_gesture.feed(kind,key,point)
 chart_camera.configure(size,world_size())
 if action.has("zoom"):chart_camera.zoom_at(action.zoom,action.anchor)
 if action.has("pan"):chart_camera.pan(action.pan)
 if action.has("zoom") or action.has("pan"):navigation_revision+=1;_view_changed()
 if action.has("tap") and Rect2(Vector2.ZERO,size).has_point(action.tap):
  var world=chart_camera.to_world(action.tap)
  if Rect2(Vector2.ZERO,world_size()).has_point(world):point_chosen.emit(world.clamp(Vector2.ONE*24,world_size()-Vector2.ONE*24))
 queue_redraw();return true
func _draw():
 draw_rect(Rect2(Vector2.ZERO,size),Color("06131c"))
 if sim==null:return
 chart_camera.configure(size,world_size());var scale=chart_camera.scale
 var earned=EarnedChart.chart(sim)
 if not earned.is_empty():
  draw_set_transform(chart_camera.offset,0,Vector2.ONE*scale)
  EarnedChart.draw_terrain(self,earned,scale)
  EarnedChart.draw_course(self,EarnedChart.segments(sim,sim.selected),scale,true)
  draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
 else:
  for cell in sim.known:
   var world=Vector2(cell)*40
   draw_rect(Rect2(chart_camera.to_screen(world),Vector2(40,40)*scale),Color("2b3b40") if sim.blocked(world+Vector2(20,20),0) else Color("102c36"))
  # Authored precharted silhouettes already exist on the main chart. Keep
  # them in the planning instrument; earned maps retain measured faces above.
  draw_set_transform(chart_camera.offset,0,Vector2.ONE*scale)
  for rock in sim.mission.rocks:
   var outline=sim.rock_polygon(rock)
   draw_colored_polygon(outline,Color("203b43"))
   var edge=outline.duplicate();edge.append(outline[0]);draw_polyline(edge,Color("78928f"),1./scale)
  for key in ["factory_rect","array_rect"]:
   if sim.mission.has(key):
    draw_rect(sim.mission[key],Color("18333c"));draw_rect(sim.mission[key],Color("78928f"),false,1./scale)
  var plant_view=preload("res://src/presentation/warning_chain_view.gd")
  plant_view.draw_crosslink(self,plant_view.context(sim),scale)
  draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
 draw_set_transform(chart_camera.offset,0,Vector2.ONE*scale)
 HullBand.draw_world(self,sim,sim.selected)
 draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
 var chart_font=ThemeDB.fallback_font
 for site in sim.observable_sites():
  if site.get("own_origin",false) or preload("res://src/presentation/rendezvous_view.gd").replaces_site(sim,site):continue
  var at=chart_camera.to_screen(site.pos);var color=Color("72d9d3") if site.captured else Color("e1b66e")
  draw_circle(at,6,color,false,1.5)
  draw_string(chart_font,at+Vector2(10,navigation_font_size+8),site.name,HORIZONTAL_ALIGNMENT_LEFT,maxf(1,size.x-at.x-18),navigation_font_size,color)
 for mouth in sim.extraction_corridors():
  var at=chart_camera.to_screen(mouth.pos);var color=Color("72d9d3") if mouth.available else Color("718387")
  draw_circle(at,maxf(8,64*scale),color,false,1.5)
  draw_string(chart_font,at+Vector2(10,16),mouth.name,HORIZONTAL_ALIGNMENT_LEFT,maxf(1,size.x-at.x-18),navigation_font_size,color)
 var u=sim.units[sim.selected];var previous=chart_camera.to_screen(u.pos)
 if earned.is_empty():
  for node in u.route:
   var p=chart_camera.to_screen(node.pos);draw_line(previous,p,Color("527f83"),1);previous=p
 var goals=sim.route_goals();var font=ThemeDB.fallback_font
 for n in goals.size():
  var goal=goals[n];var p=chart_camera.to_screen(goal.pos)
  var color=Color("88ded6") if goal.mode!="cruise" else Color("e2c586")
  draw_circle(p,8 if n==selected_goal else 5,color,false,2)
  draw_string(font,p+Vector2(10,0),str(n+1),HORIZONTAL_ALIGNMENT_LEFT,-1,16,color)
 # WP-110: the Sirens the player knows about, as on the dive chart, so a re-route is not planned blind toward one.
 _draw_known_sirens(scale)
 # WP-110: the player's other craft (the selected one is the white dot below).
 for id in sim.units.size():
  var other=sim.units[id]
  if id==sim.selected or not other.alive:continue
  var spot=chart_camera.to_screen(other.pos)
  draw_circle(spot,4,Color("9ecac5"))
  draw_string(font,spot+Vector2(8,-6),str(other.name),HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,Color("9ecac5"))
 draw_circle(chart_camera.to_screen(u.pos),5,Color.WHITE)
 # WP-110: the red mark sits on the rock the leg meets, not on the leg's middle.
 # WP-117: the leg itself turns red (over the teal course line), as on the dive chart, then the mark on the rock.
 for leg in rock_legs():draw_line(chart_camera.to_screen(leg[0]),chart_camera.to_screen(leg[1]),UiStyle.DANGER_RED,3.)
 for rock in rock_marks():_draw_rock_mark(rock)
 if pending_point!=null:
  var marker=chart_camera.to_screen(pending_point);draw_arc(marker,touch_height*.42,0,TAU,40,UiStyle.WARNING,2.5)
  draw_line(marker-Vector2(10,0),marker+Vector2(10,0),UiStyle.WARNING,2.);draw_line(marker-Vector2(0,10),marker+Vector2(0,10),UiStyle.WARNING,2.)
  if pending_rock!=null:_draw_rock_mark(pending_rock)
 draw_rect(chart_rect(),Color("40646b"),false,1)
 var hint="%.1f× · %s"%[chart_camera.zoom,Words.PROGRAM_PAN] # WP-110: plain words, one place
 var width=font.get_string_size(hint,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size).x+16
 draw_rect(Rect2(0,0,minf(width,size.x-3*touch_height-28),navigation_font_size*2+10),Color(0.025,0.06,0.08,.94))
 # Two short lines keep the same full-sized type clear of the three controls.
 draw_string(font,Vector2(8,navigation_font_size+6),"%.1f×"%chart_camera.zoom,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,Color("9ecac5"))
 draw_string(font,Vector2(8,navigation_font_size*2+10),Words.PROGRAM_PAN,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,Color("9ecac5"))

 # This footprint is visual only; it never intercepts chart gestures.
 if not u.route.is_empty():draw_string(font,Vector2(8,size.y-10),HullBand.STYLE.legend,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,Color("9ecac5"))
