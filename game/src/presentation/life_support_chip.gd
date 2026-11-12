extends RefCounted
# WP-11 (cold review 6, G6): Quietus life support stays readable during a dive.
# Before this, the reading lived only in the craft ring gauge and in a detail
# plate shown while paused, for 3 s after selection or below 25 percent, so a
# player under way could lose track of the limit. This chip sits directly
# under the pause control (which follows the mirrored HUD), on the header lane,
# and reports itself through MissionHud.threat_rects() so every placed panel,
# chip and badge already clears it. Presentation only: it reads sim.oxygen and
# the base drain; it never changes oxygen, drain rates or any rule.
# Seam: MissionHud.refresh() calls sync(hud); threat_rects() appends rect(hud).
# Revert: set ENABLED=false (the chip hides and lays out nothing), or remove
# the two calls in mission_hud.gd and this file.
const Endurance=preload("res://src/simulation/operation_endurance.gd")
const ENABLED=true
const META="life_support_chip"
const GAP=4.
const CRITICAL=25.
# One compact line keeps the chart's open-water share (playfield_hud_tests).
const FONT_FACTOR=.22
static func chip(hud)->Label:
 var existing=hud.get_meta(META) if hud.has_meta(META) else null
 if is_instance_valid(existing):return existing
 var label=Label.new();label.name="LifeSupportChip"
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 label.autowrap_mode=TextServer.AUTOWRAP_OFF
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var plate=StyleBoxFlat.new();plate.bg_color=Color(.015,.045,.06,.82);plate.set_content_margin_all(4);plate.border_width_bottom=1;plate.border_color=Color("4a7779")
 label.add_theme_stylebox_override("normal",plate)
 label.add_theme_color_override("font_outline_color",Color("041019"));label.add_theme_constant_override("outline_size",3)
 hud.add_child(label);hud.set_meta(META,label)
 return label
# Seconds left at the base life-support rate; SONAR pulses, the deep band and
# ALL STOP spend extra, so the figure is shown as an estimate.
static func seconds_left(sim)->float:
 var per_second:float=Endurance.oxygen_drain(sim.mission,1.0)
 return maxf(0.,float(sim.oxygen))/per_second if per_second>0.0 else INF
static func text(sim)->String:
 var left=seconds_left(sim)
 var clock="--:--" if left==INF else "~%d:%02d"%[int(left)/60,int(left)%60]
 return "LIFE O₂ %d%% %s"%[roundi(float(sim.oxygen)),clock]
static func active(hud)->bool:
 return ENABLED and hud.host.screen=="mission" and not hud.host.sim.mission.is_empty() and hud.host.pause_button.visible
static func sync(hud)->void:
 var label=chip(hud)
 if not active(hud):label.hide();return
 var sim=hud.host.sim
 label.text=text(sim)
 var font=maxi(14,roundi(hud.touch_height*FONT_FACTOR*hud.text_scale))
 label.add_theme_font_size_override("font_size",font)
 label.add_theme_color_override("font_color",Color("ffc097") if float(sim.oxygen)<=CRITICAL else Color("b6dcd7"))
 var pause:Rect2=hud.host.pause_button.get_rect()
 var need=label.get_combined_minimum_size()
 var width=maxf(pause.size.x,need.x)
 # Stay on the pause side of the screen: grow inward, never past the edge.
 var x=pause.position.x if pause.get_center().x<hud.size.x*.5 else pause.end.x-width
 label.position=Vector2(clampf(x,0.,maxf(0.,hud.size.x-width)),pause.end.y+GAP)
 label.size=Vector2(width,need.y)
 label.show()
static func rect(hud)->Rect2:
 var label=hud.get_meta(META) if hud.has_meta(META) else null
 return label.get_rect() if is_instance_valid(label) and label.visible else Rect2()
