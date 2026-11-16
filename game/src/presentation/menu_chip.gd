extends RefCounted
# WP-158 (round 11 critic): the only way out of a dive was FLEET > MENU; tapping the pause plate only froze time. While
# the dive is paused this small MENU plate shows in the header lane, on the inner side of the AIR chip (the speed
# control when no air chip shows), and does what FLEET > MENU does: it presses the same order button, so a campaign dive
# shows Operations with RESUME and a challenge or Expedition shows its own menu; the dive is kept. Hidden while time
# runs and while the FLEET panel is open (the panel has its own MENU). Its slot is reserved in the header lane even
# while hidden, so the alarm lane never moves when time stops. Presentation only: no rule or saved value is touched.
# Seam: MissionHud.setup() calls make(); layout() calls place(); refresh() calls sync().
# Revert: set ENABLED=false.
const ENABLED=true
const NAME="MenuChip"
const GAP=8.
const AirChip=preload("res://src/presentation/air_chip.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Words=preload("res://src/presentation/hud_words.gd")
static func make(hud)->Button:
 var button=Button.new();button.name=NAME;button.focus_mode=Control.FOCUS_NONE
 button.autowrap_mode=TextServer.AUTOWRAP_OFF;button.text=Words.TEXT.menu_chip;button.hide()
 button.pressed.connect(func():press(hud))
 hud.add_child(button);return button
static func node(hud)->Button:
 return hud.get_node_or_null(NAME)
static func shown(hud)->bool:
 return ENABLED and hud.host.screen=="mission" and hud.host.sim.paused and not hud.host.advanced_orders
# The same press FLEET > MENU takes (Android Back takes it too, once nothing else is open).
static func press(hud)->void:
 var menu=hud.host.order_buttons.get("menu")
 if menu is Button and not menu.disabled:menu.pressed.emit()
# The slot after the air chip (or the speed control), on the side facing the screen's middle; the plate's height.
static func place(hud,font:int,bh:float,speed_width:float)->void:
 var button=node(hud)
 if button==null:return
 button.add_theme_font_size_override("font_size",font)
 var face=button.get_theme_font("font")
 var width=maxf(hud.touch_height,ceilf(face.get_string_size(Words.TEXT.menu_chip,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x+24.))
 button.custom_minimum_size=Vector2(width,bh);button.size=Vector2(width,bh)
 var speed:Button=hud.host.speed_button
 var left:bool=speed.position.x<hud.size.x/2.
 var edge=speed.position.x+(speed_width if left else 0.)
 var air=AirChip.node(hud)
 if air!=null and AirChip.shown(hud):edge=air.position.x+(air.size.x if left else 0.)
 button.position=Vector2(edge+GAP if left else edge-GAP-width,12.)
# The slot's rectangle (reserved while the plate is hidden), for the alarm lane.
static func slot(hud)->Rect2:
 var button=node(hud)
 return Rect2(button.position,button.size) if ENABLED and button!=null else Rect2()
static func rect(hud)->Rect2:
 var button=node(hud)
 return Rect2(button.position,button.size) if button!=null and button.visible else Rect2()
static func sync(hud)->void:
 var button=node(hud)
 if button==null:return
 button.visible=shown(hud)
 if not button.visible:return
 button.text=Words.TEXT.menu_chip
 hud.plate(button,UiStyle.NORMAL)
 button.move_to_front()
