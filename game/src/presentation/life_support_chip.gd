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
# its "PAUSED / ▶ RESUME" text; the detail plate already shows oxygen then.
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
 return ENABLED and hud.host.screen=="mission" and not hud.host.sim.mission.is_empty() and hud.host.pause_button.visible and not hud.host.sim.paused
static func sync(hud)->void:
 var b:Button=hud.host.pause_button
 var amber=false
 if active(hud):
  var sim=hud.host.sim
  var font=b.get_theme_font("font");var font_size=b.get_theme_font_size("font_size")
  var room=b.size.x-b.get_theme_stylebox("normal").get_minimum_size().x
  var fits=func(line:String)->bool:return font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=room
  for form in forms(sim) if fits.call("Ⅱ PAUSE") else []:
   if fits.call(form):
    b.text="Ⅱ PAUSE\n"+form;amber=float(sim.oxygen)<=CRITICAL;break
 if amber:b.add_theme_color_override("font_color",AMBER);b.set_meta(META,true)
 elif b.has_meta(META):b.remove_theme_color_override("font_color");b.remove_meta(META)
# The reading takes no space of its own, so it reserves none.
static func rect(_hud)->Rect2:
 return Rect2()
