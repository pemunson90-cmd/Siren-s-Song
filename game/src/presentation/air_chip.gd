extends RefCounted
# WP-149 (round 11 critic): air is a clock the player must see all dive long. The pause plate carries the reading only
# when it fits (WP-106 keeps the state word first), so under a short plate the time left was visible only in the craft
# readout. This chip sits in the header lane beside the speed control, on the pause plate's row, and always reads the
# time left on air: "AIR" over "~3:36". Amber under half the tank, red and "AIR LOW" under a quarter (LifeChip's own
# gauge thresholds). Presentation only: it reads OxygenReading (sim.oxygen and the base drain) and changes no rule.
# Seam: MissionHud.layout() calls place(); MissionHud.refresh() calls sync(). It takes no tap.
# Revert: set ENABLED=false.
const ENABLED=true
const NAME="AirChip"
const LifeChip=preload("res://src/presentation/life_support_chip.gd")
const OxygenReading=preload("res://src/presentation/oxygen_reading.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const GAP=8.
static func make(hud)->Label:
 var label=Label.new();label.name=NAME;label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 label.autowrap_mode=TextServer.AUTOWRAP_OFF;label.hide()
 hud.add_child(label);return label
static func node(hud)->Label:
 return hud.get_node_or_null(NAME)
static func shown(hud)->bool:
 return ENABLED and not hud.host.advanced_orders and LifeChip.active(hud)
# The one place the words come from, so the layout can size the chip for the widest of them.
static func lines(sim)->String:
 var low=float(sim.oxygen)<LifeChip.CRITICAL
 return Words.TEXT.air_low+"\n"+OxygenReading.time_left(sim) if low else Words.TEXT.air+"\n"+OxygenReading.time_left(sim)
# Sits on the inner side of the speed control (the pause plate's row), the plate's height. The edge is where the
# speed control ends on the side facing the screen's middle.
static func place(hud,font:int,bh:float,speed_width:float)->void:
 var label=node(hud)
 if label==null:return
 label.add_theme_font_size_override("font_size",font)
 var face=label.get_theme_font("font")
 var wide=0.
 for text in [Words.TEXT.air_low,Words.TEXT.air,"~99:59"]:wide=maxf(wide,face.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x)
 var width=ceilf(wide+24.)
 label.size=Vector2(width,bh);label.custom_minimum_size=label.size
 var speed:Button=hud.host.speed_button
 var edge=speed.position.x+(speed_width+GAP if speed.position.x<hud.size.x/2. else -GAP-width)
 label.position=Vector2(edge,12.)
static func rect(hud)->Rect2:
 var label=node(hud)
 return Rect2(label.position,label.size) if label!=null and label.visible else Rect2()
static func sync(hud)->void:
 var label=node(hud)
 if label==null:return
 var on=shown(hud)
 label.visible=on
 if not on:return
 var sim=hud.host.sim
 var f=LifeChip.fraction(sim)
 label.text=lines(sim)
 var hc=Palette.high_contrast()
 var danger=f<.25;var warn=f<.5
 var ink=UiStyle.DANGER_SOFT if danger else UiStyle.WARNING if warn else (UiStyle.HC_QUIET_TEXT if hc else UiStyle.TEXT)
 var border=UiStyle.DANGER_RED if danger else UiStyle.WARNING if warn else (UiStyle.HC_QUIET_BORDER if hc else UiStyle.BUTTON_BORDER)
 var box=UiStyle._box(Color(.2,.04,.03,.94) if danger else UiStyle.BUTTON_FILL,border,3 if danger else 2 if (warn or hc) else 1)
 box.content_margin_top=2;box.content_margin_bottom=2;box.content_margin_left=6;box.content_margin_right=6
 label.add_theme_stylebox_override("normal",box)
 label.add_theme_color_override("font_color",ink)
 label.add_theme_color_override("font_outline_color",Color("041019"));label.add_theme_constant_override("outline_size",3)
