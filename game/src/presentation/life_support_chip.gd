extends RefCounted
# WP-11 (cold review 6, G6): Quietus life support stays readable during a dive.
# Before this, the reading lived only in the craft ring gauge and in a detail
# plate shown while paused, for 3 s after selection or below 25 percent, so a
# player under way could lose track of the limit.
#
# The reading is the second line of the running pause control ("Ⅱ PAUSE" over
# "O₂ 87% ~3:10"). The control keeps its two lines, its place and its size, so
# no panel, chip, ring or list moves. A first version drew a separate chip
# under the pause control; that took a strip of the header lane and broke the
# rendezvous, knockdown, sonar history and Hunt help layouts on small screens
# (full matrix run 43229665195), so it was replaced. The paused control keeps
# its place and size while paused too (WP-36, visual review C3): the paused control reads
# "▶ RESUME" over the same reading, and a thin gauge along its inside bottom edge shows the
# life support left (accent, amber below 50 percent, red below 25) so the limit never leaves
# the screen. The gauge is a draw layer inside the pause control, not a panel or chip, so it
# takes no space and no tap.
#
# Presentation only: it reads sim.oxygen and the base drain; it never changes
# oxygen, drain rates or any rule.
# Seam: MissionHud.refresh() calls sync(hud) after it sets the pause text and
# before it fits the pause control.
# Revert: set ENABLED=false (the control reads "Ⅱ / PAUSE" as before).
const Endurance=preload("res://src/simulation/operation_endurance.gd")
const ENABLED=true
const CRITICAL=25.
const AMBER=Color("ffc097")
const META="life_support_amber"
const GAUGE="LifeGauge"
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
# Seconds left at the base life-support rate; SONAR pulses, the deep band and
# ALL STOP spend extra, so the figure is shown as an estimate ("~").
static func seconds_left(sim)->float:
 var per_second:float=Endurance.oxygen_drain(sim.mission,1.0)
 return maxf(0.,float(sim.oxygen))/per_second if per_second>0.0 else INF
static func clock(sim)->String:
 var left=seconds_left(sim)
 return "--:--" if left==INF else "~%d:%02d"%[int(left)/60,int(left)%60]
# Longest first; sync() takes the first that fits on one line of the control.
static func forms(sim)->Array:
 var percent=roundi(float(sim.oxygen))
 return ["O₂ %d%% %s"%[percent,clock(sim)],"O₂ %s"%clock(sim),"O₂ %d%%"%percent]
static func active(hud)->bool:
 return ENABLED and hud.host.screen=="mission" and not hud.host.sim.mission.is_empty() and hud.host.pause_button.visible
static func sync(hud)->void:
 var b:Button=hud.host.pause_button
 var amber=false
 var on=active(hud)
 if on:
  var sim=hud.host.sim
  var first="▶ RESUME" if sim.paused else "Ⅱ PAUSE"
  var font=b.get_theme_font("font");var font_size=b.get_theme_font_size("font_size")
  var room=b.size.x-b.get_theme_stylebox("normal").get_minimum_size().x
  var fits=func(line:String)->bool:return font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=room
  for form in forms(sim) if fits.call(first) else []:
   if fits.call(form):
    # Amber text only on the running plate; the paused plate is accent-filled, where the gauge carries the warning.
    b.text=first+"\n"+form;amber=not sim.paused and float(sim.oxygen)<=CRITICAL;break
 if amber:b.add_theme_color_override("font_color",AMBER);b.set_meta(META,true)
 elif b.has_meta(META):b.remove_theme_color_override("font_color");b.remove_meta(META)
 _gauge(hud,on)
# The gauge: full width is 100 percent of capacity (an endurance loadout above 100 stays full).
static func fraction(sim)->float:
 return clampf(float(sim.oxygen)/100.,0.,1.)
static func gauge_color(f:float)->Color:
 return UiStyle.DANGER_RED if f<.25 else UiStyle.WARNING if f<.5 else UiStyle.HC_ACCENT if Palette.high_contrast() else UiStyle.ACCENT
static func _gauge(hud,on:bool)->void:
 var b:Button=hud.host.pause_button;var g=b.get_node_or_null(GAUGE)
 if g==null:
  if not on:return
  g=Control.new();g.name=GAUGE;g.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);b.add_child(g)
  g.draw.connect(func():_draw_gauge(g,hud))
 g.visible=on
 if on:g.queue_redraw()
static func _draw_gauge(g:Control,hud)->void:
 var inset=3.;var thick=maxf(3.,roundf(hud.touch_height*.04))
 var width=g.size.x-inset*2.
 if width<=0. or not hud.host.pause_button.visible:return
 var area=Rect2(inset,g.size.y-inset-thick,width,thick)
 g.draw_rect(area,Color.BLACK if Palette.high_contrast() else Color(UiStyle.ON_ACCENT,.75))
 var f=fraction(hud.host.sim)
 if f>0.:g.draw_rect(Rect2(area.position,Vector2(area.size.x*f,thick)),gauge_color(f))
# The reading takes no space of its own, so it reserves none.
static func rect(_hud)->Rect2:
 return Rect2()
