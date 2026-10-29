extends RefCounted
# RESEARCH / ARCHIVE entry and shared screen header. Presentation only; no saved fields.
# Seams: one inserted entry line each in ops_home.gd (arrange) and fittings_menu.gd (show).
# Android Back from either view returns to Operations through Main's ordinary rule.
const Table=preload("res://src/presentation/archive/archive_table.gd")
# Views are loaded lazily: both views preload this header, so a preload here would be circular.
const RESEARCH_VIEW="res://src/presentation/research/research_view.gd"
const ARCHIVE_VIEW="res://src/presentation/archive/archive_view.gd"
# One full-width touch row below the host's current shortcut row.
static func entry(host,at:int=-1)->void:
	var button=host._button(host.panel_box,Table.TEXT.entry,func():load(ARCHIVE_VIEW).show(host),"archive")
	if at>=0:host.panel_box.move_child(button,mini(at,host.panel_box.get_child_count()-1))
# Back button and the two view tabs.
static func header(host,current:String)->void:
	host._button(host.panel_box,"BACK TO OPERATIONS",host._show_campaign,"back")
	var row=HBoxContainer.new();row.add_theme_constant_override("separation",Table.GAP);host.panel_box.add_child(row)
	var tabs=[["research","RESEARCH",func():load(RESEARCH_VIEW).show(host)],["archive","ARCHIVE",func():load(ARCHIVE_VIEW).show(host)]]
	for tab in tabs:
		var button=host._button(row,tab[1],tab[2],"archive_tab_"+tab[0])
		button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button.disabled=tab[0]==current
		button.custom_minimum_size.x=maxf(button.custom_minimum_size.x,host.ui_touch_height)
