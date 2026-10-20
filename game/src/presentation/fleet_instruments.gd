extends Control
const Operations=preload("res://src/presentation/operation_instruments.gd")
const Recovery=preload("res://src/presentation/module_recovery_view.gd")
const WarningChain=preload("res://src/presentation/warning_chain_view.gd")
const Delivery=preload("res://src/presentation/blackwater_delivery_view.gd")
const Ring=preload("res://src/presentation/fleet_ring.gd")
# Craft-anchored status; only offscreen craft acquire bounded edge handles.
var host
var buttons:Array=[]
var telemetry:Array=[]
var readouts:Array=[]
var progress_layer:Control
var gesture=preload("res://src/input/map_gesture.gd").new()
var pressed_unit=-1
var pressed_units:Array=[]
var last_selected=-1
var detail_until=0.
var was_visible=false
func setup(owner):
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 for id in 3:
  var unit=id
  var button=host._button(self,"",func():_activate(unit),"fleet_"+["q","a","b"][id])
  button.autowrap_mode=TextServer.AUTOWRAP_OFF;button.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
  button.mouse_filter=Control.MOUSE_FILTER_IGNORE
  button.alignment=HORIZONTAL_ALIGNMENT_LEFT;buttons.append(button)
  var reading=Label.new();reading.mouse_filter=Control.MOUSE_FILTER_IGNORE
  reading.autowrap_mode=TextServer.AUTOWRAP_OFF;reading.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
  add_child(reading);telemetry.append(reading)
 progress_layer=Control.new();progress_layer.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(progress_layer);progress_layer.draw.connect(_draw_progress)
func handle_input(event)->bool:
 if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return false
 var kind="";var index=-1;var point=Vector2.ZERO
 if event is InputEventScreenTouch:
  if event.canceled:
   var owned=gesture.active();gesture.cancel();pressed_unit=-1;return owned
  kind="press" if event.pressed else "release";index=event.index;point=event.position
 elif event is InputEventScreenDrag:kind="move";index=event.index;point=event.position
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:kind="press" if event.pressed else "release";point=event.position
 elif event is InputEventMouseMotion:kind="move";point=event.position
 if kind.is_empty():return false
 if not gesture.active():
  if kind!="press" or not is_visible_in_tree():return false
  for control in host.mission_hud.action_controls().values():
   if control not in buttons and control.get_global_rect().has_point(point):return false
  pressed_units.clear()
  for id in buttons.size():
   if buttons[id].is_visible_in_tree() and buttons[id].get_global_rect().has_point(point):pressed_units.append(id)
  if pressed_units.is_empty():return false
  pressed_unit=pressed_units[0]
  # A water finger that was already down belongs to this whole gesture too.
  # Preserve its multi-touch history before transferring ownership from map.
  for pointer in host.map_gesture.touches:
   gesture.feed("press",pointer,host.map_gesture.touches[pointer])
  host.map_gesture.cancel();host.knock_press.clear()
 var action=gesture.feed(kind,index,point)
 if action.has("zoom"):host.ocean.zoom_at(action.zoom,action.anchor-host.ocean.global_position)
 if action.has("pan"):host.ocean.pan_chart(action.pan)
 if action.get("navigation",false):host._view_changed()
 if action.has("pan") or action.has("zoom"):host._refresh()
 if action.has("tap") and pressed_unit>=0 and buttons[pressed_unit].get_global_rect().has_point(point):
  var local=point-host.ocean.global_position;var site=host.ocean.objective_context(local,host.ui_touch_height)
  var site_closer=not readouts.any(func(r):return r.unit==pressed_unit and r.offscreen) and site.get("kind","")=="objective" and pressed_units.all(func(id):return local.distance_to(host.ocean.screen_position(site.pos))<local.distance_to(host.ocean.screen_position(host.sim.units[id].pos)))
  if site_closer:host.mission_hud.open("object",site)
  elif pressed_units.size()>1:host.mission_hud.open("fleet",{"kind":"fleet","pos":host.ocean.map_position(point-host.ocean.global_position)})
  else:_activate(pressed_unit)
 if not gesture.active():pressed_unit=-1
 return true
func _activate(id:int):
 if not host.sim.units[id].alive:return
 var offscreen=readouts.any(func(r):return r.unit==id and r.offscreen)
 if not offscreen or (host.sim.selected==id and host.ocean.chart_camera.mode=="follow"):
  if host.sim.selected!=id:host._order("select",{"unit":id})
  host.mission_hud.open("craft",{"kind":"craft","unit":id,"pos":host.sim.units[id].pos})
 else:
  if host.sim.selected!=id:host._order("select",{"unit":id})
  host._focus_craft()
func task(id:int)->String:
 var recovery=Recovery.task(host.sim,id)
 if recovery.is_empty():recovery=Delivery.task(host.sim,id)
 if recovery.is_empty():recovery=WarningChain.task(host.sim,id)
 var detail=recovery if not recovery.is_empty() else _ordinary_task(id)
 for cargo in [Recovery.cargo(host.sim,id),Delivery.cargo(host.sim,id)]:
  if not cargo.is_empty():detail+="\n"+cargo
 return detail
func status(id:int)->String:
 var sim=host.sim
 var reserve="HULL %d · O₂ %d"%[roundi(sim.hull),roundi(sim.oxygen)] if id==0 else "BAT %d%%"%roundi(sim.units[id].battery)
 return reserve+"\n"+task(id)
func _ordinary_task(id:int)->String:
 var sim=host.sim;var u=sim.units[id];var work=sim.capture_feedback(id)
 if work.unit>=0:
  var site=sim.mission.objectives[work.target]
  var verb={"receiver":"LISTEN","exchange":"SAMPLE","uplink":"LINK","actuator":"OPERATE"}.get(site.get("kind",""),"PHOTO")
  var operation=Operations.operation(sim,work.target)
  if not operation.is_empty():verb=operation.action
  if id>0 and site.get("sampler_compatible",false) and sim.equipment_feedback().get("fitted",{}).get("drone_a" if id==1 else "drone_b","")=="drone_sampler":verb="FIELD SAMPLE"
  return "%s %d%% · %s"%[verb,clampi(floori(work.elapsed/maxf(.01,work.duration)*100),0,100),site.name]
 var scout=sim.scout_context(id)
 if scout.state=="stopped":return "SCOUT STOP · "+("BRAKING" if u.vel.length()>2 else "HOLDING")+" · ROUTE KEPT"
 if scout.state=="armed":return "SCOUT · OWN CONTACT GUARD"
 if u.has("chart_stop"):return "CHART STOP · REPLAN"
 if not u.hold.is_empty():return "FLEET GUARD" if u.hold=="CONTACT" else "HOLD · ROUTE KEPT"
 var state="ROUTE %d"%u.route.size() if not u.route.is_empty() else "BRAKING" if u.vel.length()>2 else "READY"
 if id==0:return state+" · MOTION ~%dm"%roundi(sim.motion_radius(id)) if id==sim.selected else state+" · "+("SILENT" if u.silent else "CRUISE")
 return state+" · "+("LOW" if u.silent else "OPEN")+" · "+("QUIET42" if u.get("drone_drive","")=="quiet" else "TRANSIT96")
func refresh(blocked:Array):
 size=host.size;readouts.clear()
 if not visible:gesture.cancel();pressed_unit=-1
 var sim=host.sim;var ocean=host.ocean;var h=host.ui_touch_height;var font_size=maxi(14,roundi(h*.26));var font=ThemeDB.fallback_font
 if sim.selected!=last_selected or (visible and not was_visible):detail_until=sim.elapsed+3.;last_selected=sim.selected
 was_visible=visible
 var safe=Rect2(Vector2(12,h+24),Vector2(maxf(h,size.x-24),maxf(h,size.y-h*2-54)))
 var occupied=blocked.duplicate();occupied.append_array(ocean.objective_touch_rects(h))
 var positions=sim.units.map(func(u):return ocean.screen_position(u.pos))
 var viewport=Rect2(Vector2.ZERO,size)
 # Bodies clipped by the viewport or covered by actual controls get an edge
 # handle. Fully exposed craft keep their target exactly on the physical body.
 var on_screen=positions.map(func(at):
  var box=Rect2(at-Vector2.ONE*h/2,Vector2.ONE*h)
  return viewport.encloses(box) and not blocked.any(func(r):return r.intersects(box)))
 for id in 3:
  if sim.units[id].alive and on_screen[id]:occupied.append(Rect2(positions[id]-Vector2.ONE*h/2,Vector2.ONE*h).grow(6))
 var order=[0,1,2];order.sort_custom(func(a,b):return a<b if on_screen[a]==on_screen[b] else not on_screen[a])
 for id in order:
  var b=buttons[id];var reading=telemetry[id];var u=sim.units[id];b.visible=visible and u.alive;reading.hide()
  if not b.visible:continue
  var at:Vector2=positions[id];var offscreen=not on_screen[id];var bearing=(at-safe.get_center()).normalized()
  var box=Ring.edge_rect(at,safe,h,occupied) if offscreen else Rect2(at-Vector2.ONE*h/2,Vector2.ONE*h)
  occupied.append(box.grow(5))
  b.position=box.position;b.custom_minimum_size=Vector2.ONE*h;b.size=Vector2.ONE*h;b.text="";b.add_theme_stylebox_override("normal",StyleBoxEmpty.new());b.add_theme_stylebox_override("hover",StyleBoxEmpty.new());b.add_theme_stylebox_override("pressed",StyleBoxEmpty.new());b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
  var reserves=Ring.reserves(sim,id,ocean.oxygen_capacity)
  reading.text=status(id);b.tooltip_text=u.name+"\n"+reading.text
  var active=sim.capture_feedback(id).unit>=0 or sim.scout_context(id).state=="stopped" or u.has("chart_stop") or Recovery.active(sim,id) or Delivery.active(sim,id) or WarningChain.connected(sim,id)
  var progress=Recovery.work(sim,id)
  if progress.unit<0:progress=Delivery.work(sim,id)
  if progress.unit<0:progress=sim.capture_feedback(id)
  var cues=[]
  if WarningChain.connected(sim,id):cues.append("PWR")
  if not Recovery.cargo(sim,id).is_empty():cues.append("KIT")
  if not Delivery.cargo(sim,id).is_empty():cues.append("DATA")
  if sim.scout_context(id).state=="stopped":cues.append("SCOUT BRAKE" if u.vel.length()>2 else "SCOUT HOLD")
  elif u.has("chart_stop"):cues.append("CHART STOP")
  var captions=cues.map(func(cue):return {"PWR":"SHORE POWER","KIT":"INERT KIT","DATA":"DATA ABOARD" if id==0 else "RAW DATA"}.get(cue,cue))
  var cue_rect=Rect2()
  if not offscreen and not captions.is_empty():
   var width=0.
   for caption in captions:width=maxf(width,font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x+10)
   cue_rect=Rect2(box.get_center()+Vector2(-width/2,h*.78-font_size),Vector2(width,captions.size()*(font_size+3)))
   occupied.append(cue_rect)
  var critical=reserves.any(func(r):return r.critical)
  var show_detail=id==sim.selected and (sim.paused or sim.elapsed<detail_until)
  if show_detail or critical:
   if not show_detail:reading.text=["Q","A","B"][id]+" · "+" · ".join(reserves.filter(func(r):return r.critical).map(func(r):return "%s %d%s"%[r.label,roundi(r.value),"%" if id>0 else ""]))
   var plate=StyleBoxFlat.new();plate.bg_color=Color(.015,.045,.06,.78);plate.set_content_margin_all(8);plate.border_width_bottom=1;plate.border_color=Color("b78565") if critical else Color("4a7779")
   reading.add_theme_stylebox_override("normal",plate);reading.add_theme_font_size_override("font_size",font_size)
   reading.add_theme_color_override("font_color",Color("ffc097") if critical else Color("b6dcd7"))
   var measured=0.
   for line in reading.text.split("\n"):measured=maxf(measured,font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)
   var extent=Vector2(minf(measured+20,h*4.6),reading.get_combined_minimum_size().y)
   var desired=box.position+Vector2(h+10,0)
   var detail_box=Rect2(desired.clamp(safe.position,safe.end-extent),extent)
   var candidates=[detail_box]
   for offset in [Vector2(-extent.x-10,0),Vector2(0,h+10),Vector2(0,-extent.y-10),Vector2(-extent.x-10,h+10)]:
    candidates.append(Rect2((box.position+offset).clamp(safe.position,safe.end-extent),extent))
   var found=false
   for candidate in candidates:
    if not occupied.any(func(r):return r.intersects(candidate.grow(3))):detail_box=candidate;found=true;break
   reading.visible=found or critical;reading.position=detail_box.position;reading.size=extent
   if reading.visible:occupied.append(detail_box.grow(5))
  var bounds=box.merge(cue_rect) if cue_rect.has_area() else box
  if reading.visible:bounds=bounds.merge(reading.get_rect())
  readouts.append({"unit":id,"rect":bounds,"handle_rect":box,"text_rect":reading.get_rect() if reading.visible else Rect2(),"text":reading.text if reading.visible else ["Q","A","B"][id]+" · "+" · ".join(captions),"anchor":at,"offscreen":offscreen,"direction":bearing,"progress":progress,"ring":not offscreen,"reserves":reserves,"cues":cues,"captions":captions,"active":active,"detail_visible":reading.visible})
 for reading in readouts:
  # Near-coincident bodies must not masquerade as whichever badge painted last.
  reading.cluster=[]
  for other in readouts:
   if other.unit==reading.unit or (not reading.offscreen and not other.offscreen and reading.anchor.distance_to(other.anchor)<h*.2):reading.cluster.append(other.unit)
  reading.identity=["Q","A","B"][reading.unit]+(" +%d"%(reading.cluster.size()-1) if reading.cluster.size()>1 else "")
 queue_redraw();progress_layer.queue_redraw()
func _paint_order()->Array:
 var result=readouts.duplicate();var selected=host.sim.selected
 result.sort_custom(func(a,b):return a.unit<b.unit if (a.unit==selected)==(b.unit==selected) else a.unit!=selected)
 return result
func _draw():
 var h=host.ui_touch_height if host!=null else 48.;var text_size=maxi(14,roundi(h*.26))
 for reading in _paint_order():
  var center:Vector2=reading.handle_rect.get_center();var id:int=reading.unit;var selected=id==host.sim.selected;var ink=Color("c0e8df") if selected else Color("8ec3c2")
  if reading.offscreen:
   draw_style_box(_edge_style(selected),reading.handle_rect)
   var direction=["→","↘","↓","↙","←","↖","↑","↗"][posmod(roundi(reading.direction.angle()/(PI/4)),8)]
   _text(["Q","A","B"][id]+" "+direction,center+Vector2(0,-h*.22 if not reading.cues.is_empty() or reading.progress.unit>=0 else -h*.04),text_size,ink)
  else:
   draw_arc(center,h*.44,0,TAU,64,Color(.01,.045,.055,.7),6,true)
  Ring.draw_gauge(self,center,h*.44,reading.reserves,selected)
  if not reading.offscreen:
   var representative=host.sim.selected if host.sim.selected in reading.cluster else reading.cluster.back()
   if id==representative:
    if reading.cluster.size()>1:
     var small=maxi(14,roundi(h*.2));var at=center+Vector2(0,-h*.23);var width=ThemeDB.fallback_font.get_string_size(reading.identity,HORIZONTAL_ALIGNMENT_LEFT,-1,small).x
     draw_rect(Rect2(at-Vector2(width/2+5,small),Vector2(width+10,small+5)),Color("102e37"));_text(reading.identity,at,small,ink)
    else:
     var badge=center+Vector2(-h*.32,-h*.32);draw_circle(badge,text_size*.7,Color("102e37"));_text(reading.identity,badge+Vector2(0,text_size*.35),text_size,ink)
  for n in reading.cues.size():
   var cue=reading.cues[n] if reading.offscreen else reading.captions[n]
   if reading.offscreen:cue={"DATA":"ABOARD" if id==0 else "RAW","SCOUT BRAKE":"BRAKE","SCOUT HOLD":"SCOUT","CHART STOP":"CHART"}.get(cue,cue)
   _text(cue,center+Vector2(0,h*((.25 if reading.progress.unit>=0 else .06)+n*.19) if reading.offscreen else h*.78+n*(text_size+3)),maxi(14,roundi(h*.2)) if reading.offscreen else text_size,Color("e2bc82"))
  if reading.progress.unit>=0:
   var percent=clampi(floori(reading.progress.elapsed/maxf(.01,reading.progress.duration)*100),0,100)
   _text("%d%%"%percent,center+Vector2(0,h*(.05 if reading.offscreen else .31)),maxi(14,roundi(h*.2)) if reading.offscreen else text_size,ink)
func _text(text:String,at:Vector2,font_size:int,color:Color):
 var font=ThemeDB.fallback_font;var width=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
 draw_string_outline(font,at-Vector2(width/2,0),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,5,Color("061820"));draw_string(font,at-Vector2(width/2,0),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)
func _edge_style(selected:bool)->StyleBoxFlat:
 var style=StyleBoxFlat.new();style.bg_color=Color(.015,.06,.075,.92);style.border_color=Color("83d7ce") if selected else Color("476f79");style.set_border_width_all(1);style.set_corner_radius_all(8);return style
func _draw_progress():
 for reading in _paint_order():
  var progress=reading.progress
  if progress.unit>=0:
   var fraction=clampf(progress.elapsed/maxf(.01,progress.duration),0,1)
   progress_layer.draw_arc(reading.handle_rect.get_center(),host.ui_touch_height*.5,-PI/2,-PI/2+TAU*fraction,64,Color("e9cb8c"),3,true)
