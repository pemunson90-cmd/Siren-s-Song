extends Control
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
 chart_camera.configure(size);_view_changed()
func _view_changed():
 queue_redraw()
 if view_report_pending:return
 view_report_pending=true;call_deferred("_emit_view_changed")
func _emit_view_changed():
 view_report_pending=false
 if is_visible_in_tree():view_changed.emit()
func chart_rect() -> Rect2:
 chart_camera.configure(size);return Rect2(chart_camera.offset,Vector2(1600,960)*chart_camera.scale)
func map_position(point:Vector2) -> Vector2:
 chart_camera.configure(size);return chart_camera.to_world(point)
func screen_position(world:Vector2) -> Vector2:
 chart_camera.configure(size);return chart_camera.to_screen(world)
func zoom_at(factor:float,anchor:Vector2):
 map_gesture.cancel();chart_camera.configure(size);chart_camera.zoom_at(factor,anchor);_view_changed()
func pan_chart(delta:Vector2):
 chart_camera.configure(size);chart_camera.pan(delta);_view_changed()
func fit_chart():
 map_gesture.cancel();chart_camera.configure(size);chart_camera.fit();_view_changed()
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
 chart_camera.configure(size)
 if action.has("zoom"):chart_camera.zoom_at(action.zoom,action.anchor)
 if action.has("pan"):chart_camera.pan(action.pan)
 if action.has("zoom") or action.has("pan"):_view_changed()
 if action.has("tap") and Rect2(Vector2.ZERO,size).has_point(action.tap):
  var world=chart_camera.to_world(action.tap)
  if Rect2(0,0,1600,960).has_point(world):point_chosen.emit(Vector2(clampf(world.x,24,1576),clampf(world.y,24,936)))
 queue_redraw();return true
func _draw():
 draw_rect(Rect2(Vector2.ZERO,size),Color("06131c"))
 if sim==null:return
 chart_camera.configure(size);var scale=chart_camera.scale
 for cell in sim.known:
  var world=Vector2(cell)*40
  draw_rect(Rect2(chart_camera.to_screen(world),Vector2(40,40)*scale),Color("2b3b40") if sim.blocked(world+Vector2(20,20),0) else Color("102c36"))
 var u=sim.units[sim.selected];var previous=chart_camera.to_screen(u.pos)
 for node in u.route:
  var p=chart_camera.to_screen(node.pos);draw_line(previous,p,Color("527f83"),1);previous=p
 var goals=sim.route_goals();var font=ThemeDB.fallback_font
 for n in goals.size():
  var goal=goals[n];var p=chart_camera.to_screen(goal.pos)
  var color=Color("88ded6") if goal.mode!="cruise" else Color("e2c586")
  draw_circle(p,8 if n==selected_goal else 5,color,false,2)
  draw_string(font,p+Vector2(10,0),str(n+1),HORIZONTAL_ALIGNMENT_LEFT,-1,16,color)
 draw_circle(chart_camera.to_screen(u.pos),5,Color.WHITE)
 draw_rect(chart_rect(),Color("40646b"),false,1)
 var hint="%.1f× · DRAG / PINCH"%chart_camera.zoom
 var width=font.get_string_size(hint,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size).x+16
 draw_rect(Rect2(0,0,minf(width,size.x-3*touch_height-28),navigation_font_size*2+10),Color(0.025,0.06,0.08,.94))
 # Two short lines keep the same full-sized type clear of the three controls.
 draw_string(font,Vector2(8,navigation_font_size+6),"%.1f×"%chart_camera.zoom,HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,Color("9ecac5"))
 draw_string(font,Vector2(8,navigation_font_size*2+10),"DRAG / PINCH",HORIZONTAL_ALIGNMENT_LEFT,-1,navigation_font_size,Color("9ecac5"))
