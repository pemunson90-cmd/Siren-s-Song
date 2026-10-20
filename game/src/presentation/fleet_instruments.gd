extends Control
const Operations=preload("res://src/presentation/operation_instruments.gd")
# Own telemetry only. These chart projections are controls, never craft sprites.
var host
var buttons:Array=[]
var readouts:Array=[]
var progress_layer:Control
var gesture=preload("res://src/input/map_gesture.gd").new()
var pressed_unit=-1
func setup(owner):
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 for id in 3:
  var unit=id
  var button=host._button(self,"",func():_activate(unit),"fleet_"+["q","a","b"][id])
  button.autowrap_mode=TextServer.AUTOWRAP_OFF;button.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
  button.mouse_filter=Control.MOUSE_FILTER_IGNORE
  button.alignment=HORIZONTAL_ALIGNMENT_LEFT;buttons.append(button)
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
  pressed_unit=-1
  for id in buttons.size():
   if buttons[id].is_visible_in_tree() and buttons[id].get_global_rect().has_point(point):pressed_unit=id;break
  if pressed_unit<0:return false
  host.map_gesture.cancel();host.knock_press.clear()
 var action=gesture.feed(kind,index,point)
 if action.has("tap") and pressed_unit>=0 and buttons[pressed_unit].get_global_rect().has_point(point):_activate(pressed_unit)
 if not gesture.active():pressed_unit=-1
 return true
func _activate(id:int):
 if not host.sim.units[id].alive:return
 if host.sim.selected==id and host.ocean.chart_camera.mode=="follow":
  host.mission_hud.open("craft",{"kind":"craft","unit":id,"pos":host.sim.units[id].pos})
 else:
  if host.sim.selected!=id:host._order("select",{"unit":id})
  host._focus_craft()
func task(id:int)->String:
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
 var safe=Rect2(Vector2(12,h+24),Vector2(maxf(1,size.x-24),maxf(h,size.y-h*2-54)))
 var occupied=blocked.duplicate()
 # Keep physical hulls distinct from the projected instruments.
 for id in sim.units.size():
  var u=sim.units[id]
  if u.alive:
   var half=Vector2(76,40) if id==0 else Vector2(28,20)
   occupied.append(Rect2(ocean.screen_position(u.pos)-half*ocean.world_scale,half*2*ocean.world_scale).grow(6))
 var order=[0,1,2];var viewport=Rect2(Vector2.ZERO,size)
 var positions=sim.units.map(func(u):return ocean.screen_position(u.pos))
 # Edge instruments have only one placement axis. Reserve them first, then
 # place the flexible tethers, so two remote tasks never occlude each other.
 order.sort_custom(func(a,b):return a<b if viewport.has_point(positions[a])==viewport.has_point(positions[b]) else not viewport.has_point(positions[a]))
 for id in order:
  var b=buttons[id];var u=sim.units[id];b.visible=visible and u.alive
  if not b.visible:continue
  var at=ocean.screen_position(u.pos);var offscreen=not Rect2(Vector2.ZERO,size).has_point(at)
  var bearing=(at-safe.get_center()).normalized()
  var direction=["→","↘","↓","↙","←","↖","↑","↗"][posmod(roundi(bearing.angle()/(PI/4)),8)] if offscreen else ""
  var reserve="HULL %d · O₂ %d"%[roundi(sim.hull),roundi(sim.oxygen)] if id==0 else "BAT %d%%"%roundi(u.battery)
  var title=["Q","A","B"][id]+(" "+direction if offscreen else "")+" · "+reserve
  var detail=task(id)
  var active=sim.capture_feedback(id).unit>=0 or sim.scout_context(id).state=="stopped" or u.has("chart_stop")
  # Idle peers remain short, spatial identifiers; work expands in place.
  var compact=id!=sim.selected and not active
  if compact:
   title+=" · "+("GUARD" if not u.hold.is_empty() else "ROUTE" if not u.route.is_empty() else "READY")
   detail=""
  b.text=title+("\n"+detail if not detail.is_empty() else "")
  var width=clampf(maxf(font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x,font.get_string_size(detail,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)+24,h*2.7,h*4.7)
  var extent=Vector2(minf(width,safe.size.x),h)
  var desired=at+Vector2(-extent.x/2,-h-28*ocean.world_scale)
  if offscreen:
   var reach=minf((safe.size.x-extent.x)/2/maxf(.001,absf(bearing.x)),(safe.size.y-extent.y)/2/maxf(.001,absf(bearing.y)))
   desired=safe.get_center()+bearing*reach-extent/2
  var box=Rect2(desired.clamp(safe.position,safe.end-extent),extent)
  var candidates=[box]
  var offsets=[Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0),Vector2(0,2),Vector2(0,-2),Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1)]
  if offscreen:
   var horizontal=box.position.y<=safe.position.y+.1 or box.end.y>=safe.end.y-.1
   for step in range(1,ceili((safe.size.x if horizontal else safe.size.y)/(h*.5))):
    for side in [-1,1]:
     var delta=(Vector2.RIGHT if horizontal else Vector2.DOWN)*step*side*h*.5
     candidates.append(Rect2((box.position+delta).clamp(safe.position,safe.end-extent),extent))
   offsets=[]
  for offset in offsets:
   candidates.append(Rect2((box.position+offset*(extent+Vector2(10,10))).clamp(safe.position,safe.end-extent),extent))
  for candidate in candidates:
   if not occupied.any(func(r):return r.intersects(candidate.grow(4))):box=candidate;break
  b.position=box.position;b.custom_minimum_size=Vector2.ZERO;b.size=box.size;b.add_theme_font_size_override("font_size",font_size)
  var style=StyleBoxFlat.new();style.bg_color=Color(.015,.045,.06,.9);style.border_color=Color("81b7b6") if id==sim.selected else Color("3f6d76");style.set_border_width_all(1);style.set_corner_radius_all(5);style.set_content_margin_all(10)
  if sim.scout_context(id).state=="stopped":style.border_color=Color("deb075")
  b.add_theme_stylebox_override("normal",style);b.add_theme_stylebox_override("hover",style);b.add_theme_stylebox_override("pressed",style)
  b.add_theme_color_override("font_color",Color("c4e2df") if id==sim.selected else Color("99c2c5"))
  readouts.append({"unit":id,"rect":box,"anchor":at,"offscreen":offscreen,"direction":bearing,"progress":sim.capture_feedback(id)})
  occupied.append(box.grow(5))
 queue_redraw();progress_layer.queue_redraw()
func _draw():
 for reading in readouts:
  var box:Rect2=reading.rect
  if not reading.offscreen:
   var tether:Vector2=reading.anchor.clamp(box.position,box.end)
   draw_line(tether,reading.anchor,Color(.4,.75,.76,.45),1)
func _draw_progress():
 for reading in readouts:
  var box:Rect2=reading.rect;var progress=reading.progress
  if progress.unit>=0:
   var fraction=clampf(progress.elapsed/maxf(.01,progress.duration),0,1)
   progress_layer.draw_line(box.position+Vector2(3,box.size.y-3),box.position+Vector2(3+(box.size.x-6)*fraction,box.size.y-3),Color("8acbc0"),3)
