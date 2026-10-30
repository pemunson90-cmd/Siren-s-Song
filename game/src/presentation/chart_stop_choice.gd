extends Control
# Audit 091 F4: one direct decision at a chart stop. Presentation and input only.
# When the selected craft holds at a chart stop with retained course intent, this panel
# names the stop, marks terrain faces measured since the craft's previous decision, and
# offers CONTINUE (reissue the same retained goals, exactly what a manual replot of the
# same destination does: the ordinary order path compiles through charted water and the
# simulation stops again at any further unknown edge) or REPLAN (the course editor).
# It never issues an order by itself and never travels through unknown water.
# Revert: remove the install/refresh lines in mission_hud.gd and this file.
const NEW_EDGE=Color("ffcf6e")
const NEAR_METRES=700.0
var host
var panel:PanelContainer
var prompt:Label
var continue_button:Button
var replan_button:Button
# unit -> {"keys": {segment key: true}} faces already known when that craft last decided.
var decided:Dictionary={}
var stopped:Dictionary={}
var mission_ref:Dictionary={}
var fresh:Array=[]
func setup(owner)->void:
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 panel=PanelContainer.new();panel.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(panel)
 var box=VBoxContainer.new();box.add_theme_constant_override("separation",6);panel.add_child(box)
 prompt=Label.new();prompt.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;prompt.mouse_filter=Control.MOUSE_FILTER_IGNORE;box.add_child(prompt)
 var row=HFlowContainer.new();row.add_theme_constant_override("h_separation",8);row.add_theme_constant_override("v_separation",8);box.add_child(row)
 continue_button=_button(row,"CONTINUE COURSE",continue_course,"chart_continue")
 replan_button=_button(row,"REPLAN",replan,"chart_replan")
 var chip=StyleBoxFlat.new();chip.bg_color=Color(.018,.055,.075,.94);chip.border_color=NEW_EDGE;chip.set_border_width_all(1);chip.set_corner_radius_all(6)
 chip.content_margin_left=12;chip.content_margin_right=12;chip.content_margin_top=8;chip.content_margin_bottom=8
 panel.add_theme_stylebox_override("panel",chip)
 panel.hide()
func _button(parent:Node,text:String,action:Callable,id:String)->Button:
 var b=Button.new();b.text=text;b.focus_mode=Control.FOCUS_NONE;b.autowrap_mode=TextServer.AUTOWRAP_WORD
 b.pressed.connect(action,CONNECT_DEFERRED);b.set_meta("action",id);b.set_meta("ui_action",id);parent.add_child(b);return b
static func key(face)->String:
 return "%d,%d,%d,%d"%[roundi(face[0].x),roundi(face[0].y),roundi(face[1].x),roundi(face[1].y)]
func _faces()->Array:
 var sim=host.sim
 return sim.public_chart().get("surface_segments",[]) if sim.has_method("public_chart") else []
func _known_keys()->Dictionary:
 var result={}
 for face in _faces():
  if face.size()==2:result[key(face)]=true
 return result
# The retained intent this panel offers to continue; empty when there is nothing to keep.
func retained_goals()->Array:
 var sim=host.sim;var u=sim.units[sim.selected]
 if not u.alive or not u.has("chart_stop") or not sim.outcome.is_empty():return []
 return sim.route_goals().duplicate(true)
func active()->bool:
 return host!=null and host.sim!=null and not host.advanced_orders and not retained_goals().is_empty()
func continue_course()->void:
 var goals=retained_goals()
 if goals.is_empty():return
 var sim=host.sim;var id:int=sim.selected;var u=sim.units[id]
 decided[id]={"keys":_known_keys()}
 # Same retained goals and hold through the ordinary order path; compiling uses only charted water.
 host._order("order_undo",{"goals":goals,"hold":u.hold})
 if not sim.units[id].has("chart_stop"):sim.message="%s · continuing to the retained destination through charted water"%u.name
 host._refresh()
func replan()->void:
 if retained_goals().is_empty():return
 decided[host.sim.selected]={"keys":_known_keys()}
 host._order("program")
# Faces measured near the stopped craft since its previous decision at a chart stop.
func new_faces()->Array:
 var sim=host.sim;var id:int=sim.selected
 var known:Dictionary=decided.get(id,{}).get("keys",{})
 var pos:Vector2=sim.units[id].pos;var result=[]
 for face in _faces():
  if face.size()!=2 or known.has(key(face)):continue
  if Geometry2D.get_closest_point_to_segment(pos,face[0],face[1]).distance_to(pos)<=NEAR_METRES:result.append(face)
 return result
func blocks(point:Vector2)->bool:
 return panel.visible and panel.get_global_rect().has_point(point)
func refresh(bounds:Vector2,h:float,font:int,floor_y:float,clear:bool)->void:
 var sim=host.sim
 if not is_same(mission_ref,sim.mission):mission_ref=sim.mission;decided.clear();stopped.clear()
 # A craft's baseline is the chart when it last left a stop (any order the player gave,
 # including a manual replot) or when it was first seen, so the opening chart is not all "new".
 for id in sim.units.size():
  var held=sim.units[id].has("chart_stop")
  if not held and (not decided.has(id) or stopped.get(id,false)):decided[id]={"keys":_known_keys()}
  stopped[id]=held
 panel.visible=clear and active()
 fresh=new_faces() if panel.visible else []
 if panel.visible:
  var u=sim.units[sim.selected];var goals=retained_goals()
  var reason=str(u.chart_stop)
  var edge="%d new amber edges"%fresh.size() if not fresh.is_empty() else "no new edge"
  prompt.text="%s · %s · %s\nRetained destination: %dm · %d stop%s"%[u.name,reason.to_upper(),edge,roundi(u.pos.distance_to(goals.back().pos)),goals.size(),"" if goals.size()==1 else "s"]
  for c in [prompt,continue_button,replan_button]:c.add_theme_font_size_override("font_size",font)
  for b in [continue_button,replan_button]:
   var widest=0.0
   widest=b.get_theme_font("font").get_string_size(b.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x
   b.custom_minimum_size=Vector2(maxf(h*1.55,widest+b.get_theme_stylebox("normal").get_minimum_size().x+2),h)
  var width=minf(bounds.x-24,maxf(720.0,bounds.x*.62))
  # An autowrapped label needs its own width inside the panel or it wraps per glyph.
  var inner=width-panel.get_theme_stylebox("panel").get_minimum_size().x
  prompt.custom_minimum_size=Vector2(inner,0);prompt.size=Vector2(inner,0)
  for b in [continue_button,replan_button]:b.size=b.custom_minimum_size
  panel.custom_minimum_size=Vector2(width,0);panel.reset_size()
  _place(bounds,h,floor_y)
  # Wrapped text settles its height after layout; place again once it has.
  call_deferred("_place",bounds,h,floor_y)
 queue_redraw()
func _place(bounds:Vector2,h:float,floor_y:float)->void:
 if not panel.visible:return
 panel.reset_size()
 var top=minf(h+8,bounds.y-panel.size.y-4)
 var bottom=maxf(top,minf(floor_y,bounds.y)-panel.size.y-10)
 var craft:Vector2=host.ocean.screen_position(host.sim.units[host.sim.selected].pos)
 var best=Vector2(12,top);var best_score=INF
 for point in [Vector2(12,top),Vector2(bounds.x-panel.size.x-12,top),Vector2(12,bottom),Vector2(bounds.x-panel.size.x-12,bottom)]:
  var rect=Rect2(point,panel.size);var score=0.0
  if rect.has_point(craft):score+=10000.
  score+=maxf(0.,h-craft.distance_to(craft.clamp(rect.position,rect.end)))
  for face in fresh:
   var a:Vector2=host.ocean.screen_position(face[0]);var b:Vector2=host.ocean.screen_position(face[1])
   if rect.has_point(a) or rect.has_point(b) or Geometry2D.segment_intersects_segment(a,b,rect.position,rect.end)!=null:score+=1.
  if score<best_score:best_score=score;best=point
 panel.position=best
func _process(_dt:float)->void:
 if panel!=null and panel.visible and not fresh.is_empty():queue_redraw()
func _draw()->void:
 if host==null or not panel.visible or fresh.is_empty():return
 var pulse=.65+.35*sin(Time.get_ticks_msec()/260.0)
 for face in fresh:
  var a:Vector2=host.ocean.screen_position(face[0]);var b:Vector2=host.ocean.screen_position(face[1])
  draw_line(a,b,Color(0,0,0,.7),9.0)
  draw_line(a,b,Color(NEW_EDGE,pulse),4.0)
  draw_circle(a,4.0,NEW_EDGE);draw_circle(b,4.0,NEW_EDGE)
