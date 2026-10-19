extends Control
# Controls belong to one compact dock and one explicit contextual sheet.
var host
var dock:HBoxContainer
var sheet:PanelContainer
var blocker:Control
var sheet_body:VBoxContainer
var order_grid:GridContainer
var close_button:Button
var focus_button:Button
var instrument_button:Button
var instrument_info:Label
var intent:Label
var instruments_open=false
func setup(owner):
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 blocker=Control.new();blocker.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(blocker);blocker.gui_input.connect(_outside)
 sheet=PanelContainer.new();add_child(sheet)
 var style=StyleBoxFlat.new();style.bg_color=Color("091b23");style.border_color=Color("426d72");style.set_border_width_all(1);style.set_corner_radius_all(6);style.content_margin_left=16;style.content_margin_right=16;style.content_margin_top=12;style.content_margin_bottom=12;sheet.add_theme_stylebox_override("panel",style)
 sheet_body=VBoxContainer.new();sheet_body.add_theme_constant_override("separation",8);sheet.add_child(sheet_body)
 var header=HBoxContainer.new();sheet_body.add_child(header)
 host.title_label.reparent(header);host.title_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;host.title_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 close_button=host._button(header,"BACK",func():host._toggle_advanced(),"orders_close")
 host.detail_label.reparent(sheet_body);host.detail_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 var list=ScrollContainer.new();list.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;list.size_flags_vertical=Control.SIZE_EXPAND_FILL;sheet_body.add_child(list)
 order_grid=GridContainer.new();order_grid.add_theme_constant_override("h_separation",6);order_grid.add_theme_constant_override("v_separation",6);order_grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_child(order_grid)
 for key in host.order_buttons:
  if key not in ["camera","queue"]:host.order_buttons[key].reparent(order_grid);host.order_buttons[key].size_flags_horizontal=Control.SIZE_EXPAND_FILL
 instrument_info=host._label(sheet_body,"",18);instrument_info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 dock=HBoxContainer.new();dock.add_theme_constant_override("separation",6);add_child(dock)
 for b in [host.pause_button]+host.unit_buttons+[host.order_buttons.camera,host.order_buttons.queue,host.advanced_button]:
  b.reparent(dock);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 intent=host._label(self,"",18);intent.mouse_filter=Control.MOUSE_FILTER_IGNORE
 focus_button=host._button(self,"FOCUS",host._focus_craft,"focus")
 instrument_button=host._button(self,"STATUS",func():instruments_open=true;host._toggle_advanced(),"instruments")
func _outside(event):
 if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
  host._toggle_advanced();accept_event()
func layout(bounds:Vector2,h:float):
 position=Vector2.ZERO;size=bounds
 var gap=6.;var font=maxi(14,roundi(h*.26));var dock_width=minf(bounds.x-24,h*11.5)
 dock.position=Vector2((bounds.x-dock_width)/2,bounds.y-h-12);dock.size=Vector2(dock_width,h)
 for b in find_children("*","Button",true,false):
  b.custom_minimum_size=Vector2(h,h);b.add_theme_font_size_override("font_size",font)
 for b in dock.get_children():
  var longest=0.
  for line in b.text.split("\n"):longest=maxf(longest,b.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x)
  b.custom_minimum_size=Vector2(maxf(h*1.25,longest+b.get_theme_stylebox("normal").get_minimum_size().x+4),h)
 dock_width=maxf(dock_width,dock.get_combined_minimum_size().x);dock.position.x=(bounds.x-dock_width)/2;dock.size.x=dock_width
 host.pause_button.size_flags_stretch_ratio=1.25;host.order_buttons.camera.size_flags_stretch_ratio=1.25;host.order_buttons.queue.size_flags_stretch_ratio=1.1
 host.unit_buttons[0].size_flags_stretch_ratio=1.15
 var status_width=maxf(1.,bounds.x-5.5*h-36)
 host.status_label.position=Vector2(16,12);host.status_label.size=Vector2(status_width,2*font+8);host.status_label.hide();host.status_label.add_theme_font_size_override("font_size",font)
 host.status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 instrument_button.position=Vector2(16,12);instrument_button.size=Vector2(minf(h*6.,bounds.x-5.1*h-60),h)
 focus_button.position=Vector2(bounds.x-5.1*h-24,12);focus_button.size=Vector2(h*1.8,h)
 var x=bounds.x-3*h-20
 for b in host.zoom_buttons:
  b.custom_minimum_size=Vector2(h,h);b.position=Vector2(x,12);b.size=Vector2(h,h);b.add_theme_font_size_override("font_size",font);b.visible=host.screen=="mission";x+=h+4
 intent.position=Vector2(dock.position.x,dock.position.y-font-12);intent.size=Vector2(dock_width,font+8);intent.add_theme_font_size_override("font_size",font)
 host.log_label.position=Vector2(16,host.status_label.position.y+host.status_label.size.y+8);host.log_label.size=Vector2(status_width,font*2+8);host.log_label.add_theme_font_size_override("font_size",font);host.log_label.hide()
 focus_button.visible=not host.advanced_orders;instrument_button.visible=not host.advanced_orders;intent.visible=not host.advanced_orders
 for b in host.zoom_buttons:b.visible=host.screen=="mission" and not host.advanced_orders
 blocker.position=Vector2.ZERO;blocker.size=Vector2(bounds.x,dock.position.y-4);blocker.visible=host.advanced_orders
 var width=minf(bounds.x-24,1000.);sheet.position=Vector2(bounds.x-width-12,12);sheet.size=Vector2(width,dock.position.y-24);sheet.visible=host.advanced_orders
 order_grid.columns=5 if bounds.x/bounds.y>1.6 else 4
 for b in order_grid.get_children():b.custom_minimum_size=Vector2(h*1.25,h)
 host.title_label.add_theme_font_size_override("font_size",font);host.detail_label.add_theme_font_size_override("font_size",font);host.detail_label.custom_minimum_size.y=font*2+10
 instrument_info.add_theme_font_size_override("font_size",font);instrument_info.visible=instruments_open
 sheet.move_to_front();dock.move_to_front()
 refresh()
func refresh():
 var sim=host.sim;var own=sim.units[sim.selected]
 host.status_label.text="O₂ %d%%   HULL %d%%   RECORDS %d/%d\n%s · %s"%[int(sim.oxygen),int(sim.hull),sim.mission.objectives.filter(func(o):return o.captured).size(),sim.mission.objectives.size(),"TACTICAL PAUSE" if sim.paused else "REAL TIME",own.name]
 intent.text=("DECOY · TAP CLEAR WATER ≤160m" if host.decoy_armed else "TORPEDO · TAP FRESH CONTACT" if host.knock_armed else ("+ QUEUE · " if sim.queue_mode else "REPLACE · ")+sim.message)
 intent.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
 host.order_buttons.camera.text="CANCEL" if host.decoy_armed or host.knock_armed else ("SAMPLE" if sim.mission.get("blackwater_revision",0)==1 else "LISTEN" if sim.mission.get("finale_revision",0)==1 else "CAMERA")
 instrument_button.text=host.status_label.text
 host.advanced_button.text="ORDERS" if not host.advanced_orders else "BACK"
 focus_button.text="FOLLOW" if host.ocean.chart_camera.mode=="follow" else "FOCUS\n"+("OVERVIEW" if host.ocean.chart_camera.mode=="overview" else "FREE LOOK")
 instrument_info.text="\n".join(host.ocean.acoustic_rows())+"\n"+sim.message
func blocks(point:Vector2) -> bool:
 for control in [dock,focus_button,instrument_button,host.status_label,intent]+host.zoom_buttons:
  if control.is_visible_in_tree() and control.get_global_rect().has_point(point):return true
 return host.advanced_orders or (host.ocean.optical_feed!=null and host.ocean.optical_feed.is_visible_in_tree() and host.ocean.optical_feed.get_global_rect().has_point(point))
func occupied_rects() -> Array:
 var result=[]
 for control in [dock,focus_button,instrument_button,host.status_label,intent]+host.zoom_buttons:
  if control.is_visible_in_tree():result.append(control.get_global_rect())
 if host.advanced_orders:result.append(sheet.get_global_rect())
 return result
