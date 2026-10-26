extends RefCounted
# Public, sight-only Hunt display. Revert with HuntTable.enabled=false; the HUD
# seam calls sync once per refresh, and inactive/legacy missions retain old UI.
const Pressure=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const StatusView=preload("res://src/presentation/status_text/status_view.gd")
const CHIP="hunt_meter_button"
const PENDING="hunt_meter_fit_pending"
const MARGIN=12.0
const TONES=[Color("91d3d5"),Color("91d3d5"),Color("e5c282"),Color("e5a66d"),Color("e78477")]
static func label(view:Dictionary,compact:bool=false)->String:
 var pips=""
 for index in 5:pips+="●" if index<=int(view.index) else "○"
 if compact:
  var word=str(view.stage);var middle=ceili(word.length()/2.0)
  return "HUNT\n%s\n%s\n×%.2f\n%s\n%s"%[word.substr(0,middle),word.substr(middle),float(view.scale),pips.substr(0,3),pips.substr(3)]
 return "HUNT · %s ×%.2f\n%s"%[str(view.stage),float(view.scale),pips]
static func explanation(view:Dictionary)->String:
 var last=str(view.get("cause","")).replace("_"," ").strip_edges()
 if last.is_empty():last="no rise recorded"
 return "HUNT · %s · ×%.2f\nLast rise: %s · floor %.0f / 100.\nSight notice range for eligible Sirens, capped at ×%.2f.\nLocal alert may be higher. Hearing, speed and 4 s lock stay unchanged."%[str(view.stage),float(view.scale),last,float(view.floor),float(view.cap)]
static func _open(hud)->void:
 var view=Pressure.view(hud.host.sim)
 if not view.active:return
 hud.host.sim.paused=true
 hud.help_return=hud.page if hud.host.advanced_orders else "water"
 hud.help_text=explanation(view)
 hud.open("order_help")
static func _button(hud)->Button:
 var existing=hud.get_meta(CHIP) if hud.has_meta(CHIP) else null
 if is_instance_valid(existing):return existing
 var button=hud.host._button(hud,"",func():_open(hud),"hunt_meter")
 button.name="HuntMeterButton"
 button.mouse_filter=Control.MOUSE_FILTER_STOP
 button.focus_mode=Control.FOCUS_NONE
 button.z_index=1
 hud.set_meta(CHIP,button)
 return button
static func sync(hud)->void:
 var view=Pressure.view(hud.host.sim)
 var button=_button(hud) if view.active else (hud.get_meta(CHIP) if hud.has_meta(CHIP) else null)
 if not view.active or hud.host.screen!="mission":
  if is_instance_valid(button):button.hide()
  return
 if hud.page=="order_help":
  button.hide()
  return
 var compact=hud.touch_height>180
 button.text=label(view,compact)
 button.tooltip_text=explanation(view)
 button.add_theme_color_override("font_color",TONES[clampi(int(view.index),0,4)])
 var font=maxi(14,roundi(hud.touch_height*(.17 if compact else .22)*hud.text_scale))
 button.add_theme_font_size_override("font_size",font)
 button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var glyph=button.get_theme_font("font")
 var lines=button.text.split("\n")
 var width=0.0
 for line in lines:width=maxf(width,glyph.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x)
 var min_touch=48.0*float(hud.host.ui_density_dpi())/160.0*minf(float(hud.get_viewport_rect().size.x)/maxf(1,hud.get_window().size.x),float(hud.get_viewport_rect().size.y)/maxf(1,hud.get_window().size.y))
 var body=Vector2(ceil(width+24),ceil(maxf(min_touch,maxf(hud.touch_height,float(lines.size())*glyph.get_height(font)+16))))
 button.custom_minimum_size=body
 button.size=body
 button.show()
 if not hud.host.advanced_orders and hud.alarm.visible and hud.alarm.text.begins_with("OP PRESSURE"):hud.alarm.hide()
 fit(hud)
 schedule_fit(hud)
static func _obstacles(hud,button:Button)->Array:
 var result=[]
 var area=Rect2(Vector2.ZERO,StatusView.content_bounds(hud,hud.size))
 for other in hud.action_controls().values():
  if other!=button and other.is_visible_in_tree():result.append(Rect2(other.global_position-hud.global_position,other.size))
 if hud.alarm.visible:result.append(hud.alarm.get_rect())
 if hud.sheet.visible:result.append(hud.sheet.get_rect())
 if hud.intent.visible and area.encloses(hud.intent.get_rect()):result.append(hud.intent.get_rect())
 if hud.fleet!=null and hud.fleet.is_visible_in_tree():
  for reading in hud.fleet.readouts:result.append(Rect2(hud.fleet.position+reading.rect.position,reading.rect.size))
 return result
static func fit(hud)->void:
 var button=hud.get_meta(CHIP) if hud.has_meta(CHIP) else null
 if not is_instance_valid(button) or not button.is_visible_in_tree():return
 var area=Rect2(Vector2.ZERO,StatusView.content_bounds(hud,hud.size))
 var body=button.size
 var obstacles=_obstacles(hud,button)
 var right=area.end.x-body.x-MARGIN
 var bottom=area.end.y-body.y-MARGIN
 var near_top=hud.touch_height+MARGIN
 var middle=maxf(MARGIN,(area.size.x-body.x)/2)
 var candidates=[Vector2(right,near_top),Vector2(MARGIN,near_top),Vector2(right,MARGIN),Vector2(middle,MARGIN),Vector2(MARGIN,MARGIN),Vector2(right,bottom),Vector2(middle,bottom),Vector2(MARGIN,bottom)]
 var step=maxf(12,hud.touch_height*.5)
 var y=near_top
 while y<=bottom:
  candidates.append(Vector2(right,y));candidates.append(Vector2(MARGIN,y))
  y+=step
 for point in candidates:
  var rect=Rect2(point,body)
  if not area.encloses(rect):continue
  if obstacles.any(func(other):return rect.intersects(other)):continue
  button.position=point
  button.set_meta("hunt_meter_fitted",true)
  return
 button.position=Vector2(MARGIN,near_top)
 button.set_meta("hunt_meter_fitted",false)
static func schedule_fit(hud)->void:
 if hud.get_meta(PENDING,false):return
 hud.set_meta(PENDING,true)
 var reference=weakref(hud)
 (func():
  var current=reference.get_ref()
  if current==null:return
  current.remove_meta(PENDING)
  fit(current)
 ).call_deferred()
