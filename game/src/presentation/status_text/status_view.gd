extends RefCounted
# 048 HUD registration: copy, viewport fit, radial drawing and matching hit map.
# Revert Table.enabled=false; retain files/tests. No simulation writes/save fields.
const Copy=preload("res://src/presentation/status_text/status_text.gd")
const Table=preload("res://src/presentation/status_text/status_table.gd")
const Layout=preload("res://src/presentation/status_text/status_layout.gd")
const Expedition=preload("res://src/presentation/expedition_view.gd")
const AXES="status_radial_axes"
const HINT="status_arrivals_hint"
const PENDING="status_fit_pending"
static func content_bounds(hud,bounds:Vector2)->Vector2:
 if not Table.enabled or not Layout.enabled:return bounds
 var end:Vector2=hud.get_viewport_rect().end-hud.global_position
 return Vector2(maxf(1,minf(bounds.x,end.x)),maxf(1,minf(bounds.y,end.y)))
static func apply(hud)->void:
 if not Table.enabled:
  if hud.has_meta(HINT):hud.remove_meta(HINT)
  hud.extra.arrivals.tooltip_text=""
  if hud.has_meta(AXES):hud.remove_meta(AXES)
  return
 var sim=hud.host.sim
 for label in [hud.host.detail_label,hud.intent,hud.instrument_info]:label.text=Copy.present(sim,label.text)
 if Expedition.active(sim):
  var receiver=-1 if hud.host.advanced_orders else sim.selected
  var count=Expedition.measurements(sim,receiver).size()
  var hint=Copy.arrivals_hint(count)
  hud.extra.arrivals.text=Copy.arrivals_label(count);hud.extra.arrivals.tooltip_text=hint
  hud.set_meta(HINT,hint)
  if hud.page=="signals":hud.instrument_info.text=hint+"\n\n"+hud.instrument_info.text
 else:
  if hud.has_meta(HINT):hud.remove_meta(HINT)
 fit(hud)
 schedule_fit(hud)
static func schedule_fit(hud)->void:
 if not Table.enabled or not Layout.enabled or not hud.host.advanced_orders or hud.get_meta(PENDING,false):return
 hud.set_meta(PENDING,true)
 var reference=weakref(hud)
 (func():
  var current=reference.get_ref()
  if current==null:return
  current.remove_meta(PENDING)
  fit(current);current.queue_redraw()
 ).call_deferred()
static func captions(hud,lines:Array)->Array:
 if Table.enabled and hud.page=="fleet" and hud.has_meta(HINT) and hud.extra.arrivals.is_visible_in_tree():
  var result=lines.duplicate();result.append(hud.get_meta(HINT));return result
 return lines
static func _intersects(rects:Array)->bool:
 for i in rects.size():
  for j in range(i+1,rects.size()):
   if rects[i].intersects(rects[j]):return true
 return false
static func _rects(buttons:Array,center:Vector2,axes:Vector2)->Array:
 var result=[]
 for i in buttons.size():
  var a=-PI/2+TAU*i/buttons.size()
  result.append(Rect2(center+Vector2(cos(a)*axes.x,sin(a)*axes.y)-buttons[i].size/2,buttons[i].size))
 return result
static func _area(hud)->Rect2:
 return Rect2(Vector2.ZERO,content_bounds(hud,hud.size))
static func _free_back(hud,area:Rect2,rects:Array)->Rect2:
 var body:Vector2=hud.close_button.size;var m=Layout.MARGIN
 var candidates=[area.end-body-Vector2.ONE*m,Vector2(area.position.x+m,area.end.y-body.y-m),Vector2(area.end.x-body.x-m,area.position.y+m),area.position+Vector2.ONE*m]
 for point in candidates:
  var rect=Rect2(point,body)
  if not area.encloses(rect) or rects.any(func(r):return r.intersects(rect)):continue
  if hud.host.pause_button.is_visible_in_tree() and rect.intersects(Rect2(hud.host.pause_button.global_position-hud.global_position,hud.host.pause_button.size)):continue
  if hud.alarm.visible and rect.intersects(hud.alarm.get_rect()):continue
  return rect
 return Rect2()
static func fit(hud)->void:
 if not Table.enabled or not Layout.enabled or not hud.host.advanced_orders:return
 var visible=_area(hud)
 if hud.page in ["inspect","signals","recovery","order_help"]:
  if hud.has_meta(AXES):hud.remove_meta(AXES)
  fit_sheet(hud);return
 var buttons:Array=hud.ring_buttons
 if buttons.is_empty():return
 var r:float=hud.ring_radius
 var original=_rects(buttons,hud.center,Vector2.ONE*r)
 var needs=_intersects(original) or original.any(func(rect):return not visible.encloses(rect)) or not visible.encloses(hud.close_button.get_rect())
 if not needs:
  if hud.has_meta(AXES):hud.remove_meta(AXES)
  return
 var m=Layout.MARGIN;var top=hud.touch_height+Layout.HEADER_OFFSET
 var area=Rect2(Vector2(m,top),Vector2(visible.size.x-m*2,maxf(1,visible.size.y-top-m)))
 var body=Vector2.ZERO
 for b in buttons:body=Vector2(maxf(body.x,b.size.x),maxf(body.y,b.size.y))
 var maximum=(area.size-body)/2
 if maximum.x<=0 or maximum.y<=0:return
 var ry=minf(r,maximum.y);var rx=minf(r,maximum.x)
 var chosen=[];var at:Vector2=hud.center;var axes=Vector2.ZERO;var back=Rect2()
 while rx<=maximum.x+.01:
  var radius=Vector2(rx,ry)
  var c:Vector2=hud.anchor.clamp(area.position+radius+body/2,area.end-radius-body/2)
  var rects=_rects(buttons,c,radius)
  if not _intersects(rects) and rects.all(func(rect):return area.encloses(rect)):
   var candidate=_free_back(hud,visible,rects)
   if candidate.has_area():chosen=rects;at=c;axes=radius;back=candidate;break
  rx+=maxf(1,hud.touch_height*Layout.SEARCH_STEP)
 if chosen.is_empty():return
 hud.center=at;hud.set_meta(AXES,axes)
 for i in buttons.size():buttons[i].position=chosen[i].position
 hud.close_button.position=back.position
static func fit_sheet(hud)->void:
 if not Table.enabled or not Layout.enabled or not hud.host.advanced_orders or not hud.sheet.visible:return
 var area=_area(hud);var m=Layout.MARGIN;var top=hud.touch_height+Layout.HEADER_OFFSET
 var back:Vector2=hud.close_button.size
 var maximum=maxf(1,area.size.y-top-m-back.y-m)
 var height=minf(hud.sheet.size.y,maximum)
 var width=minf(hud.sheet.size.x,area.size.x-m*2)
 var y=clampf(hud.center.y-height/2,top,area.end.y-m-back.y-m-height)
 hud.sheet.position=Vector2(clampf(hud.sheet.position.x,m,area.end.x-m-width),y)
 hud.sheet.size=Vector2(width,height)
 hud.close_button.position=Vector2(clampf(hud.center.x-back.x/2,m,area.end.x-m-back.x),hud.sheet.get_rect().end.y+m)
static func radial_point(hud,angle:float,radius:float)->Vector2:
 var point=Vector2.from_angle(angle)*radius
 if hud.has_meta(AXES) and Table.enabled and Layout.enabled:
  point*=hud.get_meta(AXES)/hud.ring_radius
 return point
static func radial_local(hud,point:Vector2)->Vector2:
 if hud.has_meta(AXES) and Table.enabled and Layout.enabled:return point*Vector2.ONE*hud.ring_radius/hud.get_meta(AXES)
 return point
static func draw_disc(hud,radius:float,color:Color)->void:
 if not hud.has_meta(AXES) or not Table.enabled or not Layout.enabled:hud.draw_circle(hud.center,radius,color);return
 var points=PackedVector2Array()
 for i in Layout.DISC_STEPS:points.append(hud.center+radial_point(hud,TAU*i/Layout.DISC_STEPS,radius))
 hud.draw_colored_polygon(points,color)
static func draw_outline(hud,radius:float,color:Color,width:float)->void:
 if not hud.has_meta(AXES) or not Table.enabled or not Layout.enabled:hud.draw_arc(hud.center,radius,0,TAU,Layout.ARC_STEPS,color,width);return
 var points=PackedVector2Array()
 for i in Layout.ARC_STEPS+1:points.append(hud.center+radial_point(hud,TAU*i/Layout.ARC_STEPS,radius))
 hud.draw_polyline(points,color,width,true)
