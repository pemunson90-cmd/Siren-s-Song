extends Control
const Equipment=preload("res://src/presentation/equipment_context.gd")
const Expedition=preload("res://src/presentation/expedition_view.gd")
# A tap opens an object-owned projection. A separate tap chooses an action.
var host
var blocker:Control
var close_button:Button
var focus_button:Button
var instrument_button:Button
var instrument_info:Label
var intent:Label
var alarm:Label
var measurement_style:StyleBoxFlat
var sheet_body:VBoxContainer
var sheet_fit_pending=false
var sheet_scroll:ScrollContainer
var details_return="water"
var sheet_pointers:Dictionary={}
var sheet:PanelContainer
var page="craft"
var subject:Dictionary={}
var center=Vector2.ZERO
var anchor=Vector2.ZERO
var ring_radius=150.
var ring_buttons:Array=[]
var extra:Dictionary={}
var instruments_open=false
var owned_touches:Dictionary={}
var draining_popup=false
var sector_press:Button
var popup_gesture=preload("res://src/input/map_gesture.gd").new()
var touch_height=48.
func setup(owner):
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 blocker=Control.new();blocker.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(blocker);blocker.gui_input.connect(_outside)
 for key in host.order_buttons:
  var b=host.order_buttons[key];b.reparent(self);b.set_meta("action",key)
 for i in host.unit_buttons.size():
  var b=host.unit_buttons[i];b.reparent(self);b.set_meta("action",["sub","droneA","droneB"][i]);b.pressed.connect(_selected_craft,CONNECT_DEFERRED)
 host.pause_button.reparent(self);host.pause_button.set_meta("action","pause")
 host.advanced_button.reparent(self);host.advanced_button.set_meta("action","more_orders")
 host.advanced_button.pressed.disconnect(host._toggle_advanced);host.advanced_button.pressed.connect(func():open("fleet"),CONNECT_DEFERRED)
 focus_button=host._button(self,"FOCUS",host._focus_craft,"focus")
 close_button=host._button(self,"BACK",_back,"radial_back")
 for entry in [["tools_menu","TOOLS"],["route_menu","ROUTE"],["guard_menu","GUARD"],["inspect","STATUS"],["route_here","ROUTE HERE"],["arrivals","ARRIVALS"]]:
  var key=entry[0];extra[key]=host._button(self,entry[1],func():_extra(key),key)
 instrument_button=extra.inspect
 sheet=PanelContainer.new();add_child(sheet)
 var style=StyleBoxFlat.new();style.bg_color=Color(.018,.055,.075,.94);style.border_color=Color("477b80");style.set_border_width_all(1);style.content_margin_left=18;style.content_margin_right=18;style.content_margin_top=16;style.content_margin_bottom=16;sheet.add_theme_stylebox_override("panel",style)
 measurement_style=StyleBoxFlat.new();measurement_style.bg_color=Color(.018,.055,.075,.92);measurement_style.border_color=Color("477b80");measurement_style.set_border_width_all(1);measurement_style.set_corner_radius_all(8)
 sheet_scroll=ScrollContainer.new();sheet_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;sheet.add_child(sheet_scroll)
 sheet_body=VBoxContainer.new();var body=sheet_body;body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_theme_constant_override("separation",8);sheet_scroll.add_child(body);body.minimum_size_changed.connect(_schedule_sheet_fit)
 host.title_label.reparent(body);host.title_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 host.detail_label.reparent(body);host.detail_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 instrument_info=host._label(body,"",18);instrument_info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 alarm=host._label(self,"",18);alarm.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;alarm.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var alert_style=StyleBoxFlat.new();alert_style.bg_color=Color(.12,.025,.015,.94);alert_style.border_color=Color("b26b52");alert_style.set_border_width_all(1);alert_style.content_margin_left=10;alert_style.content_margin_right=10;alarm.add_theme_stylebox_override("normal",alert_style)
 intent=host._label(self,"",18);intent.mouse_filter=Control.MOUSE_FILTER_IGNORE;intent.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
func _selected_craft():
 if host.advanced_orders:open("craft",{"kind":"craft","unit":host.sim.selected,"pos":host.sim.units[host.sim.selected].pos})
func open(next:String="craft",context:Dictionary={}):
 for id in host.map_gesture.touches:owned_touches[id]=true
 host.map_gesture.cancel();host.knock_press.clear();popup_gesture.cancel();sheet_pointers.clear();sector_press=null;host.knock_armed=false;host.decoy_armed=false
 if not context.is_empty():subject=context
 elif subject.is_empty() or next=="fleet":subject={"kind":"craft","unit":host.sim.selected,"pos":host.sim.units[host.sim.selected].pos}
 page=next;instruments_open=page in ["inspect","signals"];host.advanced_orders=true;host._layout()
func dismiss():
 draining_popup=not owned_touches.is_empty()
 host.map_gesture.cancel();host.knock_press.clear();popup_gesture.cancel();sheet_pointers.clear();sector_press=null;host.advanced_orders=false;instruments_open=false;host._layout()
func _back():
 if host.knock_armed or host.decoy_armed:host._primary_action();dismiss();return
 if page=="signals":
  if details_return=="water":dismiss()
  else:open(details_return)
 elif page=="craft" or page=="object" or page=="fleet":dismiss()
 else:open("object" if subject.get("kind","")=="objective" else "craft")
func _extra(key:String):
 if key=="arrivals":
  details_return="fleet" if host.advanced_orders else "water"
  open("signals",{"kind":"signals","receiver":-1 if host.advanced_orders else host.sim.selected});return
 if key=="route_here":host._order("route",{"point":subject.pos});return
 open({"tools_menu":"tools","route_menu":"route","guard_menu":"guard","inspect":"inspect"}[key])
func owns_pointer(event) -> bool:
 var draining=draining_popup
 if (host.advanced_orders or draining) and event is InputEventScreenTouch:
  if event.pressed:owned_touches[event.index]=true
  else:owned_touches.erase(event.index)
  if owned_touches.is_empty():draining_popup=false
 if draining and (event is InputEventScreenTouch or event is InputEventScreenDrag or (event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION)):return true
 return false
func sector_at(point:Vector2) -> Button:
 if not host.advanced_orders or page in ["inspect","signals"] or ring_buttons.is_empty():return null
 var local=point-global_position-center;var distance=local.length()
 if distance<ring_radius-touch_height*.65 or distance>ring_radius+touch_height*.6:return null
 var turn=fposmod(local.angle()+PI/2,TAU)
 var index=posmod(roundi(turn/TAU*ring_buttons.size()),ring_buttons.size())
 return ring_buttons[index]
func label_at(point:Vector2) -> bool:
 return action_controls().values().any(func(b):return b.get_global_rect().has_point(point))
func popup_input(event) -> bool:
 if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return false
 var action={};var point=Vector2.ZERO;var pressed=false;var pointer=-1
 if event is InputEventScreenTouch and event.canceled:
  popup_gesture.cancel();sector_press=null;sheet_pointers.erase(event.index);return true
 if event is InputEventScreenTouch:
  point=event.position;pressed=event.pressed;pointer=event.index
  if pressed and popup_gesture.active() and not popup_gesture.touches.has(event.index):dismiss();return true
  action=popup_gesture.feed("press" if pressed else "release",event.index,point)
 elif event is InputEventScreenDrag:
  point=event.position;pointer=event.index;action=popup_gesture.feed("move",event.index,point)
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  point=event.position;pressed=event.pressed;action=popup_gesture.feed("press" if pressed else "release",-1,point)
 elif event is InputEventMouseMotion and popup_gesture.active():
  point=event.position;action=popup_gesture.feed("move",-1,point)
 if pressed:
  sector_press=null if label_at(point) else sector_at(point)
  if sheet.visible and sheet.get_global_rect().has_point(point) and not label_at(point):sheet_pointers[pointer]=true
 if sheet_pointers.has(pointer):
  if event is InputEventScreenTouch and not event.pressed:sheet_pointers.erase(pointer)
  elif event is InputEventMouseButton and not event.pressed:sheet_pointers.erase(pointer)
  return false
 if action.has("pan") or action.has("zoom"):dismiss();return true
 if action.has("tap") and sector_press!=null:
  var chosen=sector_press;sector_press=null
  if chosen==sector_at(point) and not chosen.disabled:chosen.pressed.emit()
  return true
 return false
func _outside(event):
 if event is InputEventScreenTouch or event is InputEventMouseButton:
  var point=event.position+blocker.global_position
  if label_at(point) or sector_at(point)!=null:return
 if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:dismiss();accept_event();return
 if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):dismiss();accept_event()
func command_controls() -> Array:
 match page:
  "tools":return [host.order_buttons.decoy,host.order_buttons.emp,host.order_buttons.recon,host.order_buttons.knock]
  "route":return [host.order_buttons.queue,host.order_buttons.hold,host.order_buttons.waypoint_mode,host.order_buttons.home,host.order_buttons.program]
  "guard":return [host.order_buttons.contact_hold,host.order_buttons.wait_drone,host.order_buttons.hold]
  "fleet":return host.unit_buttons+([extra.arrivals] if Expedition.active(host.sim) else [])+[host.order_buttons.menu]
  "object":return [extra.route_here]+([] if subject.has("subkind") else [host.order_buttons.camera])+[extra.inspect,host.order_buttons.program,host.order_buttons.queue]
  "inspect","signals":return []
 return [host.order_buttons.camera,host.order_buttons.ping,host.order_buttons.silent,host.order_buttons.program,extra.route_menu,extra.tools_menu,extra.guard_menu,extra.inspect]
func layout(bounds:Vector2,h:float):
 position=Vector2.ZERO;size=bounds;touch_height=h
 var font=maxi(14,roundi(h*.26))
 for b in host.order_buttons.values()+host.unit_buttons+extra.values()+[close_button,focus_button,host.pause_button,host.advanced_button]+host.zoom_buttons:
  b.hide();b.custom_minimum_size=Vector2(h*1.55,h);b.size=Vector2(h*1.55,h);b.add_theme_font_size_override("font_size",font)
  b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  var normal=StyleBoxFlat.new();normal.bg_color=Color(0,0,0,0);normal.set_content_margin_all(2)
  var hover=normal.duplicate();hover.bg_color=Color(.2,.62,.65,.14)
  b.add_theme_stylebox_override("normal",normal);b.add_theme_stylebox_override("hover",hover);b.add_theme_stylebox_override("pressed",hover);b.add_theme_stylebox_override("disabled",normal)
  b.add_theme_color_override("font_outline_color",Color("041019"));b.add_theme_constant_override("outline_size",3)
 host.status_label.hide();host.log_label.hide()
 host.pause_button.show();host.pause_button.position=Vector2(12,12);host.pause_button.size=Vector2(h*1.55,h)
 focus_button.visible=not host.advanced_orders;focus_button.position=Vector2(bounds.x-4.45*h-24,12);focus_button.size=Vector2(h*1.55,h)
 var fit=host.zoom_buttons[2];fit.visible=not host.advanced_orders;fit.position=Vector2(bounds.x-2.85*h-18,12);fit.custom_minimum_size=Vector2(h,h);fit.size=Vector2(h,h)
 host.advanced_button.visible=not host.advanced_orders;host.advanced_button.position=Vector2(bounds.x-1.55*h-12,12);host.advanced_button.size=Vector2(h*1.55,h)
 intent.position=Vector2(16,bounds.y-font*2-14);intent.size=Vector2(bounds.x-32,font*2+8);intent.add_theme_font_size_override("font_size",font)
 intent.visible=not host.advanced_orders
 blocker.position=Vector2.ZERO;blocker.size=bounds;blocker.visible=host.advanced_orders
 ring_buttons=command_controls()
 anchor=host.ocean.screen_position(subject.get("pos",host.sim.units[host.sim.selected].pos))
 ring_radius=h*2.25
 var edge=Vector2(h*3.1,h*2.9)
 var minimum=Vector2(edge.x,minf(h*3.85+20,bounds.y-edge.y))
 center=anchor.clamp(minimum,bounds-edge)
 if page in ["inspect","signals"]:center=Vector2(bounds.x*.5,bounds.y*.5)
 if host.advanced_orders:
  for i in ring_buttons.size():
   var b=ring_buttons[i];var a=-PI/2+TAU*i/ring_buttons.size()
   b.position=center+Vector2.from_angle(a)*ring_radius-b.size/2;b.show();b.move_to_front()
  close_button.position=center+Vector2(-h*.775,h*.15);close_button.show();close_button.move_to_front()
 sheet.visible=host.advanced_orders and page in ["inspect","signals"]
 if sheet.visible:
  sheet.position=Vector2(maxf(12,center.x-minf(400,bounds.x*.4)),h+24)
  sheet.size=Vector2(minf(800,bounds.x-24),h*2)
  _schedule_sheet_fit()
  close_button.position=Vector2(center.x-h*.775,minf(bounds.y-h-16,sheet.position.y+sheet.size.y+8));sheet.move_to_front();close_button.move_to_front()
 for label in [host.title_label,host.detail_label,instrument_info]:label.add_theme_font_size_override("font_size",font)
 alarm.position=Vector2(h*1.55+32,12);alarm.size=Vector2(maxf(1,bounds.x-h*6.-64),h);alarm.add_theme_font_size_override("font_size",font)
 host.pause_button.move_to_front();alarm.move_to_front();refresh();queue_redraw()
func _schedule_sheet_fit():
 if sheet_fit_pending:return
 sheet_fit_pending=true;call_deferred("_fit_sheet")
func _fit_sheet():
 sheet_fit_pending=false
 if sheet==null or not sheet.visible:return
 var margin=sheet.get_theme_stylebox("panel").get_minimum_size().y
 var maximum=maxf(touch_height*1.5,minf(size.y-touch_height*2-56,touch_height*4.7))
 var height=clampf(sheet_body.get_combined_minimum_size().y+margin,touch_height*1.5,maximum)
 var at=Vector2(sheet.position.x,clampf(center.y-height/2,touch_height+24,size.y-height-touch_height-24))
 if absf(sheet.size.y-height)<.1 and sheet.position.distance_to(at)<.1:return
 sheet.size.y=height;sheet.position=at
 close_button.position=Vector2(center.x-touch_height*.775,sheet.position.y+height+8)
 host.call_deferred("_report_targets")
func refresh():
 var sim=host.sim
 host.pause_button.text="PAUSED\n▶ RUN" if sim.paused else "Ⅱ\nPAUSE"
 host.advanced_button.text="FLEET"
 focus_button.text="FOLLOW" if host.ocean.chart_camera.mode=="follow" else "FOCUS"
 intent.text="%s · %s · %s"%[sim.units[sim.selected].name,"QUEUE" if sim.queue_mode else "REPLACE",("DECOY · TAP CLEAR WATER ≤160m · TAP CANCEL" if host.decoy_armed else "TORPEDO · TAP FRESH CONTACT · TAP CANCEL" if host.knock_armed else sim.message)]
 host.title_label.visible=page!="signals";host.detail_label.visible=page!="signals"
 host.order_buttons.home.text="WITHDRAW" if Expedition.entry(sim) else "EXTRACT"
 extra.route_here.text="PLOT ROUTE" if subject.has("subkind") else "ROUTE HERE"
 extra.arrivals.text="ARRIVALS\n%d"%Expedition.measurements(sim).size()
 extra.arrivals.disabled=Expedition.measurements(sim).is_empty()
 var sites=host.ocean.observable_sites();var records=sites.filter(func(o):return o.captured).size()
 var summary="KNOWN SITES %d · RECORDED %d"%[sites.size(),records] if Expedition.active(sim) else "RECORDS %d/%d"%[records,sites.size()]
 instrument_info.text=summary+" · DEPTH %dm\n"%sim.mission.depth+"\n".join(host.ocean.acoustic_rows())+"\n"+sim.message
 if subject.get("kind","")=="objective" and subject.get("index",-1)>=0 and subject.index<host.ocean.observable_sites().size():
  var site=host.ocean.observable_sites()[subject.index]
  instrument_info.text=site.name+" · "+("RECORDED" if site.captured else "NOT RECORDED")+"\n"+site.get("requirement","")+"\n"+site.get("unit_requirement","")+"\n"+instrument_info.text
 if subject.has("subkind"):instrument_info.text=Expedition.context_detail(sim,subject)+"\n\n"+instrument_info.text
 if page=="signals":instrument_info.text=Expedition.detail(sim,subject.get("receiver",-1))
 var fitted=Equipment.status(sim)
 if not fitted.is_empty():instrument_info.text+="\n\n"+fitted
 if page=="inspect" and sim.selected==0:
  var correlation=Equipment.correlation_detail(sim)
  if not correlation.is_empty():instrument_info.text+="\n\n"+correlation
 if not host.advanced_orders:
  extra.arrivals.hide()
  if Expedition.active(sim):
   var blockers=[]
   for button in action_controls().values():
    if button!=extra.arrivals:blockers.append(Rect2(button.global_position-host.ocean.global_position,button.size))
   if intent.visible:blockers.append(Rect2(intent.global_position-host.ocean.global_position,intent.size))
   var badge=Expedition.badge_rect(host.ocean,sim,touch_height,blockers)
   if badge.has_area():
    extra.arrivals.position=badge.position;extra.arrivals.size=badge.size;extra.arrivals.show();extra.arrivals.text="ARRIVALS\n%d"%Expedition.measurements(sim,sim.selected).size()
    if extra.arrivals.get_theme_stylebox("normal")!=measurement_style:extra.arrivals.add_theme_stylebox_override("normal",measurement_style)
 var warnings=[]
 for entry in host.ocean.contact_entries():
  if entry.urgent or (entry.fresh and "REPORT" in entry.text):warnings.append(entry.text)
 alarm.text="\n".join(warnings);alarm.visible=not warnings.is_empty()
 host.ocean.ui_blocked_rects=occupied_rects().map(func(r):return Rect2(r.position-host.ocean.global_position,r.size))
 if host.decoy_armed or host.knock_armed:
  close_button.text="CANCEL";close_button.position=Vector2(size.x/2-touch_height*.775,size.y-touch_height-12);close_button.show()
 else:close_button.text="BACK";close_button.visible=host.advanced_orders
 queue_redraw()
func _draw():
 if host==null or not host.advanced_orders:return
 var h=touch_height;var font=ThemeDB.fallback_font;var text_size=maxi(14,roundi(h*.26))
 var tether=anchor.clamp(Vector2.ONE*12,size-Vector2.ONE*12)
 draw_line(tether,center,Color(.3,.8,.8,.32),1.5)
 draw_circle(tether,5,Color("80cbc8"),false,1.5)
 if page in ["inspect","signals"]:return
 draw_circle(center,ring_radius-h*.7,Color(.012,.038,.055,.78))
 for i in ring_buttons.size():
  var points=PackedVector2Array();var from=-PI/2+TAU*(i-.5)/ring_buttons.size()+.012;var until=-PI/2+TAU*(i+.5)/ring_buttons.size()-.012
  for j in 13:points.append(center+Vector2.from_angle(lerpf(from,until,j/12.))*(ring_radius-h*.65))
  for j in 13:points.append(center+Vector2.from_angle(lerpf(until,from,j/12.))*(ring_radius+h*.6))
  draw_colored_polygon(points,Color(.025,.095,.12,.9) if not ring_buttons[i].disabled else Color(.025,.04,.05,.9))
 draw_arc(center,ring_radius-h*.65,0,TAU,96,Color(.3,.72,.74,.45),1.5)
 draw_arc(center,ring_radius+h*.6,0,TAU,96,Color(.3,.72,.74,.6),1.5)
 for i in ring_buttons.size():
  var a=-PI/2+TAU*(i-.5)/ring_buttons.size();var d=Vector2.from_angle(a)
  draw_line(center+d*(ring_radius-h*.65),center+d*(ring_radius+h*.6),Color(.3,.72,.74,.4),1)
 var title=host.sim.units[host.sim.selected].name if subject.get("kind","")!="objective" else subject.get("name","SITE")
 var caption=page.to_upper() if page!="craft" else ("COMMAND · SITES %d"%host.ocean.observable_sites().size() if Expedition.active(host.sim) else "COMMAND · %d/%d"%[host.ocean.observable_sites().filter(func(o):return o.captured).size(),host.ocean.observable_sites().size()])
 for n in 2:
  var text=title if n==0 else caption;var width=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size).x
  draw_string(font,center+Vector2(-width/2,-h*.65+n*(text_size+5)),text,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size,Color("a8d9d5"))
func action_controls() -> Dictionary:
 var result={}
 for c in find_children("*","Button",true,false)+host.zoom_buttons:
  if c.is_visible_in_tree() and c.has_meta("action"):result[c.get_meta("action")]=c
 if host.zoom_buttons[2].is_visible_in_tree():result["fit"]=host.zoom_buttons[2]
 return result
func blocks(point:Vector2) -> bool:
 if host.advanced_orders:return true
 for b in action_controls().values():
  if b.get_global_rect().has_point(point):return true
 return host.ocean.optical_feed!=null and host.ocean.optical_feed.is_visible_in_tree() and host.ocean.optical_feed.get_global_rect().has_point(point)
func occupied_rects() -> Array:
 var result=[]
 for c in action_controls().values():result.append(c.get_global_rect())
 if intent.visible:result.append(intent.get_global_rect())
 if alarm.visible:result.append(alarm.get_global_rect())
 if host.advanced_orders:result.append(Rect2(center-Vector2.ONE*(ring_radius+touch_height*.65),Vector2.ONE*(ring_radius+touch_height*.65)*2))
 return result
