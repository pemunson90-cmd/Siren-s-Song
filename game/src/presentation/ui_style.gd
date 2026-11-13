extends RefCounted
# [AI-DESIGNED] UI review C1 (Pat approved 2026-11-12)
# One place for the game's button look. Every screen should have one obvious main
# action, so buttons get a role: MAIN (the forward action, filled with the accent
# colour), NORMAL (the old look), QUIET (leaving, cancelling, going back) and
# DANGER (throwing away a dive, a run or progress). All colours and sizes live here.
# main.gd _button and frontend.gd _button call apply_for; the base theme is theme().
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const MAIN="MAIN"
const NORMAL="NORMAL"
const QUIET="QUIET"
const DANGER="DANGER"
# Colour tokens. The first group is the original base theme from main.gd.
const BUTTON_FILL=Color("102831")
const BUTTON_BORDER=Color("36545d")
const HOVER_FILL=Color("20444c")
const HOVER_BORDER=Color("6bd5cb")
const PRESSED_FILL=Color("37605e")
const TEXT=Color("d0e0df")
const TEXT_HOVER=Color("ffffff")
const LABEL_TEXT=Color("c3d5d6")
const PANEL_FILL=Color("0a1b25")
const PANEL_BORDER=Color("47636a")
const ACCENT=Color("80d9cf")	# the heading colour used by frontend.gd
const WARNING=Color("efc28d")	# the warning text colour used by frontend.gd
const DANGER_RED=Color("e26a50")	# the threat red drawn on the chart (ocean_view.gd)
# Role colours derived for the new looks.
const ON_ACCENT=Color("06141b")
const ACCENT_HOVER=Color("a6ece4")
const ACCENT_PRESSED=Color("5fb9b0")
const QUIET_TEXT=Color("a3b8b9")
const DANGER_SOFT=Color("ffb4a3")
const DISABLED_FILL=Color("0d1f27")
const DISABLED_BORDER=Color("1c333a")
const DISABLED_TEXT=Color("6d8486")
# High contrast: brighter fills, whiter text, thicker borders.
const HC_ACCENT=Color("b8fff6")
const HC_ACCENT_HOVER=Color("d9fffa")
const HC_ON_ACCENT=Color("000000")
const HC_QUIET_TEXT=Color("e6f2f2")
const HC_QUIET_BORDER=Color("8fb0b3")
const HC_DANGER_TEXT=Color("ffb4a3")
const HC_BORDER=Color("ffffff")
# Sizes.
# Action id -> role. Anything missing is NORMAL. ids shared by two screens are not listed
# here but decided in apply_for (retry, next_operation, continuations).
const ROLES={
	# MAIN: the forward action of a screen.
	"frontend_new_campaign":"MAIN","frontend_continue":"MAIN","resume":"MAIN","begin":"MAIN","next_dive":"MAIN","expedition6":"MAIN",
	"arc_continue":"MAIN","career_resume":"MAIN","career_begin":"MAIN","career_new":"MAIN","career_continue":"MAIN",
	"run_resume":"MAIN","run_begin":"MAIN","run_next":"MAIN","run_continue":"MAIN","run_seed_start":"MAIN",
	"challenge_start":"MAIN","order_go":"MAIN","challenge_resume":"MAIN","continue_choir":"MAIN","continue_glass":"MAIN","next_expedition":"MAIN",
	# QUIET: back, cancel, close, keep, return, title.
	"frontend_back":"QUIET","back":"QUIET","profiles_back":"QUIET","profiles_cancel":"QUIET","save2_back":"QUIET","save2_cancel":"QUIET",
	"career_return":"QUIET","career_keep":"QUIET","launch_guard_keep":"QUIET","run_keep":"QUIET","run_dive_keep":"QUIET","challenge_attempt_keep":"QUIET","run_return":"QUIET",
	"challenge_back":"QUIET","challenge_return":"QUIET","route_map_back":"QUIET","siren_dossier_back":"QUIET","ops_title":"QUIET",
	"menu_title":"QUIET","dev_return":"QUIET","keep_recovering":"QUIET","hint_dismiss":"QUIET","contact_close":"QUIET","order_cancel":"QUIET","ack_archive_warning":"QUIET",
	# DANGER: throwing away a dive, a run or progress, and their confirm buttons.
	"career_abandon":"DANGER","career_confirm_abandon":"DANGER","run_abandon":"DANGER","run_end":"DANGER","run_confirm_end":"DANGER",
	"challenge_abandon":"DANGER","run_dive_confirm_end":"DANGER","challenge_attempt_confirm_end":"DANGER","new_campaign":"DANGER","confirm_new_campaign":"DANGER","launch_guard_abandon":"DANGER",
	"abandon_modules":"DANGER","profile_clear":"DANGER","profiles_confirm":"DANGER","save2_confirm":"DANGER",
}
# Forward actions that can appear together on one result screen: if two are present, neither is MAIN.
const FORWARD=["next_dive","expedition6","next_expedition","continue_choir","continue_glass"]
static func role_for(action_id:String)->String:
	return ROLES.get(action_id,NORMAL)
# role_for plus the few decisions that depend on what else is on the screen.
static func role_of(button:Button,action_id:String)->String:
	var role:String=role_for(action_id)
	var parent:=button.get_parent()
	if parent==null:return role
	var siblings:Array=[]
	for node in parent.get_children():
		if node!=button and node is Button and node.has_meta("ui_action"):siblings.append(node)
	if action_id in FORWARD:
		for node in siblings:
			if str(node.get_meta("ui_action")) in FORWARD:
				if node.get_meta("ui_role",NORMAL)==MAIN:apply(node,NORMAL)
				return NORMAL
	# A lost screen has no forward button, so retrying is its main action.
	if action_id=="retry":
		for node in siblings:
			if str(node.get_meta("ui_action")) in FORWARD:return NORMAL
		return MAIN
	# The hub's NEXT OPERATION is the main action unless a dive can be resumed.
	if action_id=="next_operation":
		for node in siblings:
			if str(node.get_meta("ui_action"))=="resume":return NORMAL
		return MAIN
	return role
static func apply_for(button:Button,action_id:String)->void:
	apply(button,role_of(button,action_id))
static func theme()->Theme:
	var t:=Theme.new();t.default_font_size=17
	var normal:=_box(BUTTON_FILL,BUTTON_BORDER,1);normal.content_margin_left=12;normal.content_margin_right=12;normal.content_margin_top=10;normal.content_margin_bottom=10
	var hover:=normal.duplicate();hover.bg_color=HOVER_FILL;hover.border_color=HOVER_BORDER
	var pressed:=normal.duplicate();pressed.bg_color=PRESSED_FILL
	t.set_stylebox("normal","Button",normal);t.set_stylebox("hover","Button",hover);t.set_stylebox("pressed","Button",pressed);t.set_stylebox("focus","Button",hover)
	t.set_color("font_color","Button",TEXT);t.set_color("font_hover_color","Button",TEXT_HOVER);t.set_color("font_color","Label",LABEL_TEXT)
	var p:=StyleBoxFlat.new();p.bg_color=PANEL_FILL;p.border_color=PANEL_BORDER;p.set_border_width_all(1);p.content_margin_left=28;p.content_margin_right=28;p.content_margin_top=22;p.content_margin_bottom=22
	t.set_stylebox("panel","PanelContainer",p)
	return t
static func _box(fill:Color,border:Color,width:int)->StyleBoxFlat:
	var s:=StyleBoxFlat.new();s.bg_color=fill;s.border_color=border;s.set_border_width_all(width);s.set_corner_radius_all(5)
	s.content_margin_left=12;s.content_margin_right=12;s.content_margin_top=10;s.content_margin_bottom=10
	return s
# Colours for one role: fill/border/text for normal, hover (also used for focus), pressed and the border width.
static func _look(role:String,hc:bool)->Dictionary:
	var width:=2 if hc else 1
	match role:
		MAIN:
			if hc:return {"fill":HC_ACCENT,"border":HC_BORDER,"text":HC_ON_ACCENT,"hover_fill":HC_ACCENT_HOVER,"hover_border":HC_BORDER,"hover_text":HC_ON_ACCENT,"pressed_fill":ACCENT,"width":width}
			return {"fill":ACCENT,"border":HOVER_BORDER,"text":ON_ACCENT,"hover_fill":ACCENT_HOVER,"hover_border":TEXT_HOVER,"hover_text":ON_ACCENT,"pressed_fill":ACCENT_PRESSED,"width":width}
		QUIET:
			if hc:return {"fill":Color(0,0,0,0),"border":HC_QUIET_BORDER,"text":HC_QUIET_TEXT,"hover_fill":HOVER_FILL,"hover_border":HC_BORDER,"hover_text":TEXT_HOVER,"pressed_fill":PRESSED_FILL,"width":width}
			return {"fill":Color(0,0,0,0),"border":Color(BUTTON_BORDER,.55),"text":QUIET_TEXT,"hover_fill":Color(HOVER_FILL,.6),"hover_border":HOVER_BORDER,"hover_text":TEXT_HOVER,"pressed_fill":PRESSED_FILL,"width":width}
		DANGER:
			if hc:return {"fill":BUTTON_FILL,"border":HC_DANGER_TEXT,"text":HC_DANGER_TEXT,"hover_fill":HOVER_FILL,"hover_border":HC_BORDER,"hover_text":HC_BORDER,"pressed_fill":PRESSED_FILL,"width":width}
			return {"fill":BUTTON_FILL,"border":DANGER_RED,"text":DANGER_RED,"hover_fill":HOVER_FILL,"hover_border":DANGER_SOFT,"hover_text":DANGER_SOFT,"pressed_fill":PRESSED_FILL,"width":width}
	return {}
# A role changes colours only. Heights and font sizes belong to the layout code (touch height, text scale,
# briefing fit); changing them here made the briefing footer fill the panel on the cover screen.
static func apply(button:Button,role:String)->void:
	button.set_meta("ui_role",role)
	for state in ["normal","hover","pressed","focus","disabled"]:button.remove_theme_stylebox_override(state)
	for color in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color","font_hover_pressed_color"]:button.remove_theme_color_override(color)
	var look:=_look(role,Palette.high_contrast())
	if look.is_empty():return
	var width:int=look.width
	var normal:=_box(look.fill,look.border,width)
	var hover:=_box(look.hover_fill,look.hover_border,width)
	var pressed:=_box(look.pressed_fill,look.hover_border,width)
	var focus:=_box(look.hover_fill,TEXT_HOVER if role!=MAIN else look.hover_border,maxi(width,2))
	# Disabled reads as disabled for every role: dark fill, faint border, dim text.
	var disabled:=_box(DISABLED_FILL,DISABLED_BORDER,1)
	button.add_theme_stylebox_override("normal",normal);button.add_theme_stylebox_override("hover",hover);button.add_theme_stylebox_override("pressed",pressed)
	button.add_theme_stylebox_override("focus",focus);button.add_theme_stylebox_override("disabled",disabled)
	button.add_theme_color_override("font_color",look.text);button.add_theme_color_override("font_hover_color",look.hover_text);button.add_theme_color_override("font_pressed_color",look.hover_text)
	button.add_theme_color_override("font_focus_color",look.hover_text);button.add_theme_color_override("font_hover_pressed_color",look.hover_text);button.add_theme_color_override("font_disabled_color",DISABLED_TEXT)
# Title backdrop (C4): water, depth shading, plate behind the menu, sonar ring.
const TITLE_WATER=Color("050f17")
const TITLE_DEEP=Color("020a10")
const TITLE_SCRIM=Color("03090e")
const TITLE_RING=Color("72d9d3")
