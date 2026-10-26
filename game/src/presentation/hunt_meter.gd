extends RefCounted
# Public, sight-only Hunt display. Revert with HuntTable.enabled=false; the HUD
# seam calls sync once per refresh, and inactive/legacy missions retain old UI.
# Presentation tunables and copy live in hunt_meter/meter_table.gd.
const Pressure=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const StatusView=preload("res://src/presentation/status_text/status_view.gd")
const Table=preload("res://src/presentation/hunt_meter/meter_table.gd")
const CHIP="hunt_meter_button"
const PENDING="hunt_meter_fit_pending"
const HELP_HOOK="hunt_meter_help_resize_hook"
static func label(view:Dictionary,compact:bool=false)->String:
 var pips=""
 for index in Table.PIP_COUNT:pips+="●" if index<=int(view.index) else "○"
 if compact:
  var word=str(view.stage);var middle=ceili(word.length()/2.0)
  return Table.TEXT.compact%[word.substr(0,middle),word.substr(middle),float(view.scale),pips.substr(0,Table.COMPACT_PIP_SPLIT),pips.substr(Table.COMPACT_PIP_SPLIT)]
 return Table.TEXT.standard%[str(view.stage),float(view.scale),pips]
static func explanation(view:Dictionary)->String:
 var last=str(view.get("cause","")).replace("_"," ").strip_edges()
 if last.is_empty():last=Table.TEXT.no_rise
 return Table.TEXT.help%[str(view.stage),float(view.scale),last,float(view.floor),float(view.cap)]
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
  if own_help(hud) and hud.touch_height>Table.COMPACT_TOUCH_HEIGHT:
   hook_help(hud)
   fit_help(hud)
   schedule_fit(hud)
  return
 var compact=hud.touch_height>Table.COMPACT_TOUCH_HEIGHT
 button.text=label(view,compact)
 button.tooltip_text=explanation(view)
 button.add_theme_color_override("font_color",Table.TONES[clampi(int(view.index),0,4)])
 var font=maxi(Table.MIN_FONT_SIZE,roundi(hud.touch_height*(Table.COMPACT_FONT_FACTOR if compact else Table.STANDARD_FONT_FACTOR)*hud.text_scale))
 button.add_theme_font_size_override("font_size",font)
 button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var glyph=button.get_theme_font("font")
 var lines=button.text.split("\n")
 var width=0.0
 for line in lines:width=maxf(width,glyph.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x)
 var min_touch=Table.TOUCH_TARGET_DP*float(hud.host.ui_density_dpi())/Table.BASE_DPI*minf(float(hud.get_viewport_rect().size.x)/maxf(1,hud.get_window().size.x),float(hud.get_viewport_rect().size.y)/maxf(1,hud.get_window().size.y))
 var body=Vector2(ceil(width+Table.WIDTH_PADDING),ceil(maxf(min_touch,maxf(hud.touch_height,float(lines.size())*glyph.get_height(font)+Table.HEIGHT_PADDING))))
 button.custom_minimum_size=body
 button.size=body
 button.show()
 if not hud.host.advanced_orders and hud.alarm.visible and hud.alarm.text.begins_with("OP PRESSURE"):hud.alarm.hide()
 fit(hud)
 schedule_fit(hud)
static func own_help(hud)->bool:
 return Pressure.view(hud.host.sim).active and hud.page=="order_help" and hud.help_text.begins_with("HUNT ·")
static func help_rects(hud)->Array:
 var area=Rect2(Vector2.ZERO,StatusView.content_bounds(hud,hud.size))
 var back=hud.close_button.size
 var top=maxf(hud.host.pause_button.get_rect().end.y+Table.HELP_PAUSE_GAP,hud.touch_height+Table.MARGIN)
 var width=area.size.x-back.x-Table.MARGIN*Table.HELP_WIDTH_MARGIN_COUNT
 var height=area.end.y-top-Table.MARGIN
 if width<=0 or height<=0:return []
 return [Rect2(Vector2(Table.MARGIN,top),Vector2(width,height)),Rect2(Vector2(area.end.x-back.x-Table.MARGIN,area.end.y-back.y-Table.MARGIN),back)]
static func help_needs_fit(hud)->bool:
 var rects=help_rects(hud)
 if rects.is_empty():return false
 return hud.sheet.position.distance_to(rects[0].position)>.5 or hud.sheet.size.distance_to(rects[0].size)>.5 or hud.close_button.position.distance_to(rects[1].position)>.5
static func hook_help(hud)->void:
 if hud.get_meta(HELP_HOOK,false):return
 hud.set_meta(HELP_HOOK,true)
 var reference=weakref(hud)
 hud.sheet.resized.connect(func():
  var current=reference.get_ref()
  if current!=null and own_help(current) and current.touch_height>Table.COMPACT_TOUCH_HEIGHT and help_needs_fit(current):schedule_fit(current)
 ,CONNECT_DEFERRED)
static func fit_help(hud)->void:
 if not own_help(hud) or not hud.sheet.visible:return
 var rects=help_rects(hud)
 if rects.is_empty() or not help_needs_fit(hud):return
 hud.sheet.position=rects[0].position
 hud.sheet.size=rects[0].size
 hud.close_button.position=rects[1].position
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
 var right=area.end.x-body.x-Table.MARGIN
 var bottom=area.end.y-body.y-Table.MARGIN
 var near_top=hud.touch_height+Table.MARGIN
 var middle=maxf(Table.MARGIN,(area.size.x-body.x)/2)
 var candidates=[Vector2(right,near_top),Vector2(Table.MARGIN,near_top),Vector2(right,Table.MARGIN),Vector2(middle,Table.MARGIN),Vector2(Table.MARGIN,Table.MARGIN),Vector2(right,bottom),Vector2(middle,bottom),Vector2(Table.MARGIN,bottom)]
 var step=maxf(Table.SCAN_MIN_STEP,hud.touch_height*Table.SCAN_TOUCH_FACTOR)
 var y=near_top
 while y<=bottom:
  candidates.append(Vector2(right,y));candidates.append(Vector2(Table.MARGIN,y))
  y+=step
 for point in candidates:
  var rect=Rect2(point,body)
  if not area.encloses(rect):continue
  if obstacles.any(func(other):return rect.intersects(other)):continue
  button.position=point
  button.set_meta("hunt_meter_fitted",true)
  return
 button.position=Vector2(Table.MARGIN,near_top)
 button.set_meta("hunt_meter_fitted",false)
static func schedule_fit(hud)->void:
 if hud.get_meta(PENDING,false):return
 hud.set_meta(PENDING,true)
 var reference=weakref(hud)
 (func():
  var current=reference.get_ref()
  if current==null:return
  current.remove_meta(PENDING)
  if own_help(current):fit_help(current)
  else:fit(current)
 ).call_deferred()
