extends RefCounted
# One level up for Android Back. Main._android_back asks this first for the screens whose
# visible BACK button does not lead to Operations; everything else keeps Main's own rule
# (back to Operations). A dive is never ended or quit from here: Back closes what is open, else acts as MENU.
# The exit confirm (back_exit_confirm.gd) stays Operations-only, plus the title shown at launch.
const BRIEFING_META="onboard2_fit_index"  # set by every briefing; the field manual and launch costs return to it
const DOSSIER_FROM_META="siren_dossier_from"  # "archive" when the dossier was opened from the archive

# True when Back was handled here.
static func up(host)->bool:
	match host.screen:
		"mission":
			dive(host);return true
		"program":
			host.route_editor.close();return true
		"reference","launch_guard":
			host._briefing(int(host.get_meta(BRIEFING_META,0)));return true
		"expedition_menu":
			if host.active_started:return false
			host._return();return true  # the pre-dive page's own BACK TO EXPEDITIONS
		"intel":
			host._evidence_gallery(0);return true
		"siren_dossier":
			return preload("res://src/presentation/siren_dossier/siren_dossier.gd").back(host)
	return false

# The front-end title at app launch has nothing above it, so Back asks to exit like Operations does.
static func at_launch_title(host)->bool:
	var front=host.get_node_or_null("Frontend")
	return front!=null and front.screen=="title" and front.operations_entry.is_empty()

# Closes the innermost open thing; with nothing open it does what the dive's MENU button does in this mode (the
# Campaign shows Operations with RESUME; a challenge or Expedition shows its own menu). The dive is kept either way.
static func dive(host)->void:
	var hud=host.mission_hud
	if hud!=null and hud.guard!=null and not hud.guard.pending.is_empty():hud.guard.cancel();return
	if host.knock_armed or host.decoy_armed:host._primary_action();return
	if host.advanced_orders:hud._back();return
	if hud!=null and hud.contact_card!=null and hud.contact_card.is_open():hud.contact_card.close();return
	host.sim.paused=true
	var menu=host.order_buttons.get("menu") if host.get("order_buttons") is Dictionary else null
	if menu is Button and menu.is_visible_in_tree() and not menu.disabled:menu.pressed.emit()
	else:host._show_campaign()
