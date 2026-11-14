extends RefCounted
# Public, sight-only Hunt display. Revert with HuntTable.enabled=false; the HUD
# seam calls sync once per refresh, and inactive/legacy missions retain old UI.
# Presentation tunables and copy live in hunt_meter/meter_table.gd.
const Pressure=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const StatusView=preload("res://src/presentation/status_text/status_view.gd")
const Table=preload("res://src/presentation/hunt_meter/meter_table.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Text=preload("res://src/campaign/onboarding_text.gd")
const CHIP="hunt_meter_button"
const INTRO="hunt_meter_intro"
const PENDING="hunt_meter_fit_pending"
const HELP_HOOK="hunt_meter_help_resize_hook"
static func label(view:Dictionary,compact:bool=false,tight:bool=false)->String:
 var pips=""
 for index in Table.PIP_COUNT:pips+="●" if index<=int(view.index) else "○"
 if tight:return Table.TEXT.tight%[float(view.scale),str(view.stage),pips]
 if compact:
  var word=str(view.stage);var middle=ceili(word.length()/2.0)
  return Table.TEXT.compact%[word.substr(0,middle),word.substr(middle),float(view.scale),pips.substr(0,Table.COMPACT_PIP_SPLIT),pips.substr(Table.COMPACT_PIP_SPLIT)]
 return Table.TEXT.standard%[str(view.stage),float(view.scale),pips]
static func tone(view:Dictionary,elapsed:float,hz:float=Table.PULSE_HZ)->Color:
 var index=clampi(int(view.index),0,Table.TONES.size()-1)
 var color:Color=Palette.chart_color("threat",Table.TONES[index])
 if index!=4 or not view.get("active",false) or hz<=0 or Settings.reduced_motion():return color
 var wave=0.5+0.5*sin(TAU*elapsed*hz)
 color.a=lerpf(Table.PULSE_MIN_ALPHA,1.0,wave)
 return color
static func explanation(view:Dictionary)->String:
 var last=str(view.get("cause","")).replace("_"," ").strip_edges()
 if last.is_empty():last=Table.TEXT.no_rise
 return Table.TEXT.help%[str(view.stage),float(view.scale),float(view.cap),last,float(view.floor)]+Palette.legend()
static func _open(hud)->void:
 var view=Pressure.view(hud.host.sim)
 if not view.active:return
 hud.host.sim.paused=true
 hud.help_return=hud.page if hud.host.advanced_orders else "water"
 hud.help_text=explanation(view)
 _retire_intro(hud)
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
  if hud.has_meta(INTRO) and is_instance_valid(hud.get_meta(INTRO)):hud.get_meta(INTRO).hide()
  return
 if hud.page=="order_help":
  button.hide()
  if hud.has_meta(INTRO) and is_instance_valid(hud.get_meta(INTRO)):hud.get_meta(INTRO).hide()
  if own_help(hud) and hud.touch_height>Table.COMPACT_TOUCH_HEIGHT:
   hook_help(hud)
   fit_help(hud)
   schedule_fit(hud)
  return
 var compact=hud.touch_height>Table.COMPACT_TOUCH_HEIGHT
 button.text=label(view,compact,compact and hud.size.y<hud.touch_height*4.0)
 button.tooltip_text=explanation(view)
 button.add_theme_color_override("font_color",tone(view,float(hud.host.sim.elapsed)))
 var stretch_y=float(hud.get_window().size.y)/maxf(1.0,float(hud.get_viewport_rect().size.y))
 var readable_font=ceili(Table.MIN_READABLE_DP*float(hud.host.ui_density_dpi())/Table.BASE_DPI/stretch_y)
 var font=maxi(maxi(Table.MIN_FONT_SIZE,readable_font),roundi(hud.touch_height*(Table.COMPACT_FONT_FACTOR if compact else Table.STANDARD_FONT_FACTOR)*hud.text_scale))
 button.add_theme_font_size_override("font_size",font)
 button.autowrap_mode=TextServer.AUTOWRAP_OFF
 var glyph=button.get_theme_font("font")
 var lines=button.text.split("\n")
 var width=0.0
 for line in lines:width=maxf(width,glyph.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x)
 var min_touch=Table.TOUCH_TARGET_DP*float(hud.host.ui_density_dpi())/Table.BASE_DPI*minf(float(hud.get_viewport_rect().size.x)/maxf(1,hud.get_window().size.x),float(hud.get_viewport_rect().size.y)/maxf(1,hud.get_window().size.y))
 # Each authored line is measured at the actual font size. Keep those explicit
 # breaks; automatic wrapping can retain an extra line after a text-scale change.
 var padding=button.get_theme_stylebox("normal").get_minimum_size()
 var body=Vector2(ceil(width+maxf(Table.WIDTH_PADDING,padding.x)+2.),ceil(maxf(min_touch,maxf(hud.touch_height,float(lines.size())*glyph.get_height(font)+maxf(Table.HEIGHT_PADDING,padding.y)))))
 button.custom_minimum_size=body
 button.size=body
 button.show()
 if not hud.host.advanced_orders and hud.alarm.visible and hud.alarm.text.begins_with("OP PRESSURE"):hud.alarm.hide()
 fit(hud)
 schedule_fit(hud)
 intro(hud,button)
# The one-line meaning beside the chip the first time it is shown in a profile (critic 14 Nov: three players never understood it).
# The flag is kept with the profile's other first-use flags; a mode session keeps it on its campaign.
static func _flags_owner(hud):
 var campaign=hud.host.get("campaign_host")
 return campaign if campaign!=null and is_instance_valid(campaign) else hud.host
static func _intro_label(hud)->Label:
 var existing=hud.get_meta(INTRO) if hud.has_meta(INTRO) else null
 if is_instance_valid(existing):return existing
 var label=Label.new()
 label.name="HuntMeterIntro";label.mouse_filter=Control.MOUSE_FILTER_IGNORE;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.text=Table.TEXT.intro;label.z_index=1;label.hide()
 var style=StyleBoxFlat.new();style.bg_color=Color(.018,.055,.075,.95);style.border_color=Color("e9cb8c");style.set_border_width_all(1);style.set_corner_radius_all(6)
 style.content_margin_left=10;style.content_margin_right=10;style.content_margin_top=6;style.content_margin_bottom=6
 label.add_theme_stylebox_override("normal",style)
 hud.add_child(label);hud.set_meta(INTRO,label)
 return label
static func _retire_intro(hud)->void:
 hud.set_meta("hunt_meter_intro_done",true)
 var label=hud.get_meta(INTRO) if hud.has_meta(INTRO) else null
 if is_instance_valid(label):label.hide()
 var flags=_flags_owner(hud).hints_seen
 if not Text.HUNT_METER_HINT in flags:flags.append(Text.HUNT_METER_HINT)
static func intro(hud,button:Button)->void:
 if hud.get_meta("hunt_meter_intro_done",false):return
 var flags=_flags_owner(hud).hints_seen
 var now=float(hud.host.sim.elapsed)
 if not hud.has_meta("hunt_meter_intro_since"):
  # Shown in an earlier dive of this profile: nothing more to say. Otherwise count running seconds from now.
  if Text.HUNT_METER_HINT in flags:hud.set_meta("hunt_meter_intro_done",true);return
  hud.set_meta("hunt_meter_intro_since",now)
  flags.append(Text.HUNT_METER_HINT)
 var label=_intro_label(hud)
 if now-float(hud.get_meta("hunt_meter_intro_since"))>Table.INTRO_SECONDS:_retire_intro(hud);return
 if not button.visible:label.hide();return
 var area=Rect2(Vector2.ZERO,StatusView.content_bounds(hud,hud.size))
 var width=minf(area.size.x-Table.MARGIN*2.0,Table.INTRO_MAX_WIDTH)
 label.add_theme_font_size_override("font_size",roundi(float(button.get_theme_font_size("font_size"))*Table.INTRO_FONT_FACTOR))
 label.custom_minimum_size=Vector2(width,0);label.size=Vector2(width,0)
 label.size=Vector2(width,label.get_combined_minimum_size().y)
 # Below the chip, else above it; with no clear place it waits hidden, so it never covers a lock card, a prompt or a control.
 var obstacles=_obstacles(hud,button,false)
 var x=clampf(button.position.x+(button.size.x-width)/2.0,Table.MARGIN,maxf(Table.MARGIN,area.end.x-width-Table.MARGIN))
 for y in [button.position.y+button.size.y+Table.INTRO_GAP,button.position.y-label.size.y-Table.INTRO_GAP]:
  var rect=Rect2(Vector2(x,y),label.size)
  if area.encloses(rect) and not obstacles.any(func(other):return rect.intersects(other)):
   label.position=rect.position;label.show();return
 label.hide()
static func own_help(hud)->bool:
 return Pressure.view(hud.host.sim).active and hud.page=="order_help" and hud.help_text.begins_with("HUNT ·")
static func help_rects(hud)->Array:
 var area=Rect2(Vector2.ZERO,StatusView.content_bounds(hud,hud.size))
 var back=hud.close_button.size
 var top=maxf(hud.threat_floor(),maxf(hud.host.pause_button.get_rect().end.y+Table.HELP_PAUSE_GAP,hud.touch_height+Table.MARGIN))
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
static func _craft_touch_rects(hud)->Array:
 var result=[]
 var ocean=hud.host.ocean
 var offset=ocean.global_position-hud.global_position
 var touch=hud.touch_height
 for id in hud.host.sim.units.size():
  var unit=hud.host.sim.units[id]
  if not unit.alive:continue
  var half=(Vector2(66,18) if id==0 else Vector2(18,8))*ocean.world_scale+Vector2.ONE*touch*.32
  var center=offset+ocean.screen_position(unit.pos)
  var bounds=Rect2(center-Vector2.ONE*touch*.5,Vector2.ONE*touch)
  for corner in [Vector2(-half.x,-half.y),Vector2(half.x,-half.y),Vector2(half.x,half.y),Vector2(-half.x,half.y)]:
   var at=center+corner.rotated(unit.angle)
   bounds=bounds.expand(at)
  result.append(bounds)
 return result
static func _obstacles(hud,button:Button,craft:bool=true)->Array:
 var result=[]
 var area=Rect2(Vector2.ZERO,StatusView.content_bounds(hud,hud.size))
 for other in hud.action_controls().values():
  if other!=button and other.is_visible_in_tree():result.append(Rect2(other.global_position-hud.global_position,other.size))
 if hud.alarm.visible:result.append(hud.alarm.get_rect())
 result.append_array(hud.threat_rects())
 var warning=hud.host.lock_warning
 if warning!=null and warning.visible and warning.banner.has_area():result.append(Rect2(warning.global_position-hud.global_position+warning.banner.position,warning.banner.size))
 if hud.sheet.visible:result.append(hud.sheet.get_rect())
 if hud.order_dock.visible:result.append(hud.order_dock.get_rect())
 var optics=hud.host.ocean.optical_feed
 if optics.is_visible_in_tree():result.append(Rect2(optics.global_position-hud.global_position,optics.size))
 if hud.intent.visible and area.encloses(hud.intent.get_rect()):result.append(hud.intent.get_rect())
 # WP-11 (I2): the first-notice chip and note, and a mode banner (Expedition), are not controls but must stay readable.
 var cue=hud.host.hud.get_node_or_null("FirstSirenCue") if hud.host.get("hud")!=null else null
 if cue!=null and cue.is_visible_in_tree():
  for r in [cue.marker_rect,cue.note_rect]:
   if r.has_area():result.append(Rect2(cue.global_position-hud.global_position+r.position,r.size))
 # WP-69: the onboarding tip card is read once at the top left; the chip seats elsewhere while it is up.
 var tip=hud.get("hints")
 if tip!=null and tip.panel.is_visible_in_tree():result.append(Rect2(tip.panel.global_position-hud.global_position,tip.panel.size))
 var banner=hud.host.get("status_label")
 if banner is Control and banner.is_visible_in_tree():result.append(Rect2(banner.global_position-hud.global_position,banner.size))
 if hud.fleet!=null and hud.fleet.is_visible_in_tree():
  for reading in hud.fleet.readouts:result.append(Rect2(hud.fleet.position+reading.rect.position,reading.rect.size))
 if craft:result.append_array(_craft_touch_rects(hud))
 return result
static func fit(hud)->void:
 var button=hud.get_meta(CHIP) if hud.has_meta(CHIP) else null
 if not is_instance_valid(button) or hud.host.screen!="mission" or hud.page=="order_help" or not Pressure.view(hud.host.sim).active:return
 # A provisional no-slot result may precede deferred dock placement. Retry
 # that seat at the final geometry rather than making hidden state permanent.
 button.show()
 var area=Rect2(Vector2.ZERO,StatusView.content_bounds(hud,hud.size))
 var body=button.size
 var obstacles=_obstacles(hud,button)
 var covered_craft=hud.fleet!=null and hud.fleet.visible and _craft_touch_rects(hud).any(func(rect):return rect.intersects(button.get_rect()))
 var old_position=button.position
 var right=area.end.x-body.x-Table.MARGIN
 var bottom=area.end.y-body.y-Table.MARGIN
 var near_top=hud.touch_height+Table.MARGIN
 var middle=maxf(Table.MARGIN,(area.size.x-body.x)/2)
 # WP-11 (I2): hold the chip where it is while the layout is the same and its seat
 # stays clear, so it moves for a resize, mirroring, text scale or a panel, not per frame.
 var signature=str([area.size,hud.touch_height,hud.text_scale,Settings.current.get("mirrored_hud",false),hud.host.advanced_orders,hud.page,hud.order_dock.visible])
 if Table.STICKY and button.get_meta("hunt_meter_fitted",false) and button.get_meta("hunt_meter_signature","")==signature:
  var held=Rect2(old_position,body)
  if area.encloses(held) and not obstacles.any(func(other):return held.intersects(other)):return
 button.set_meta("hunt_meter_signature",signature)
 var candidates=[Vector2(right,near_top),Vector2(Table.MARGIN,near_top),Vector2(right,Table.MARGIN),Vector2(middle,Table.MARGIN),Vector2(Table.MARGIN,Table.MARGIN),Vector2(right,bottom),Vector2(middle,bottom),Vector2(Table.MARGIN,bottom)]
 # Try exact obstacle edges before the coarse scan: a full touch target can fit
 # between the header and a craft even when the scan step skips that gap.
 for obstacle in obstacles:
  for y_edge in [obstacle.end.y+4.,obstacle.position.y-body.y-4.]:
   for x_edge in [Table.MARGIN,right,obstacle.end.x+4.,obstacle.position.x-body.x-4.]:candidates.append(Vector2(x_edge,y_edge))
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
  if covered_craft and old_position.distance_to(point)>.5:hud.host.call_deferred("_refresh")
  return
 # With the Fleet dock open, craft actions live in its full-size scrolling
 # rows and physical-body badges are inactive. Reserve Hunt before those
 # inactive bodies when they are the only reason no seat remains. All active
 # controls, dock, Pause/Back and received threats still exclude the seat.
 if hud.order_dock.visible and not hud.fleet.visible:
  var required=_obstacles(hud,button,false)
  for point in candidates:
   var rect=Rect2(point,body)
   if area.encloses(rect) and not required.any(func(other):return rect.intersects(other)):
    button.position=point
    button.set_meta("hunt_meter_fitted",true)
    return
 # Never paint over a received threat when a crowded viewport has no slot.
 button.hide()
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
