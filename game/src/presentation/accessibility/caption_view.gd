extends Label
# Passive text placed in free chart space. Existing warnings retain ownership
# and are excluded from placement; captions never intercept Android gestures.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Layout=preload("res://src/presentation/accessibility/cue_table.gd").LAYOUT
var occupied:Array=[]
var last_font=0
func _init()->void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var panel=StyleBoxFlat.new();panel.bg_color=Color("07131b");panel.border_color=Color("ffffff");panel.set_border_width_all(1);panel.set_content_margin_all(8)
 add_theme_stylebox_override("normal",panel);add_theme_color_override("font_color",Color.WHITE)
func refresh(host)->void:
 hide();occupied=[];set_meta("status_fallback",false)
 if host.screen!="mission" or not Settings.current.get("audio_captions",false):return
 var caption=host.sound.accessibility.text()
 if caption.is_empty():return
 var fs=maxi(Layout.font_min,roundi(host.ui_touch_height*Layout.font_touch*Settings.text_scale()))
 add_theme_font_size_override("font_size",fs)
 occupied=host.mission_hud.occupied_rects()
 for control in [host.title_label,host.detail_label,host.mission_hud.guard.panel,host.mission_hud.hints.panel,host.ocean.optical_feed]:
  if control.is_visible_in_tree():occupied.append(control.get_global_rect())
 if host.lock_warning.visible:occupied.append(Rect2(host.global_position+host.lock_warning.banner.position,host.lock_warning.banner.size))
 var first=host.hud.get_node_or_null("FirstSirenCue")
 if first!=null and first.visible:occupied.append(Rect2(host.global_position+first.marker_rect.position,first.marker_rect.size))
 var previous=get_global_rect()
 if text==caption and last_font==fs and Rect2(host.global_position,host.size).encloses(previous) and not occupied.any(func(r):return previous.grow(Layout.gap).intersects(r)):
  show();return
 last_font=fs
 # Try broad then compact columns before the existing status fallback.
 for width_touch in Layout.widths:
  var wide=minf(host.size.x-Layout.edge*2,host.ui_touch_height*width_touch)
  text="";size=Vector2(wide,0);text=caption
  var high=ceil(ThemeDB.fallback_font.get_multiline_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,wide-16,fs).y)+16
  var ys=[host.ui_touch_height+Layout.top];var xs=[Layout.edge,host.size.x-wide-Layout.edge,(host.size.x-wide)/2.]
  for rect in occupied:
   ys.append(rect.end.y-host.global_position.y+Layout.gap+1.)
   xs.append(rect.end.x-host.global_position.x+Layout.gap+1.)
  ys.sort()
  set_meta("placement_height",high)
  for y in ys:
   for x in xs:
    if x<Layout.edge or y<host.ui_touch_height+Layout.top or x+wide>host.size.x-Layout.edge or y+high>host.size.y-Layout.edge:continue
    var candidate=Rect2(host.global_position+Vector2(x,y),Vector2(wide,high))
    if occupied.any(func(r):return candidate.grow(Layout.gap).intersects(r)):continue
    position=Vector2(x,y);size=Vector2(wide,high);show();return
 # Exceptionally crowded chart: retain the text in the existing readable status
 # channel, without covering another warning with a floating overlay.
 var status=host.mission_hud.instrument_info if host.advanced_orders else host.mission_hud.intent
 status.text=caption+"\n"+status.text
 if not host.advanced_orders:
  host.mission_hud._fit_intent()
  var height=ceil(status.get_theme_font("font").get_multiline_string_size(status.text,HORIZONTAL_ALIGNMENT_LEFT,status.size.x,fs).y)+8
  status.custom_minimum_size.y=height;status.size.y=height;status.position.y=host.size.y-height-14
 set_meta("status_fallback",true)
