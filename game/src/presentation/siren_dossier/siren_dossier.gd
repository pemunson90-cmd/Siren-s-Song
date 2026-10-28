extends RefCounted
# Read-only dossier. Only roles already noticed or identified in recovered film are listed.
# Android Back follows Main's standard route to Operations; the visible button returns to Archive.
const Table=preload("res://src/presentation/siren_dossier/dossier_table.gd")
const Archive=preload("res://src/presentation/archive/archive_view.gd")
static func show(host)->void:
	host.screen="siren_dossier";host.sim.paused=true;host._clear_menu()
	host._button(host.panel_box,"BACK TO ARCHIVE",func():Archive.show(host),"siren_dossier_back")
	host._menu_text("SIREN DOSSIER",30)
	host._menu_text("Only roles in first-hand notices or recovered Siren photographs are listed. Best recovered photo quality appears when studied.",15)
	var rows=Table.discovered(host)
	if rows.is_empty():
		host._menu_text("No Siren roles recorded yet. First-hand notices and recovered photographs add entries here.",16)
	else:
		for row in rows:
			host._menu_text(row.name,22)
			host._menu_text("ROLE · "+row.does,15)
			host._menu_text("OBSERVABLE TELL · "+row.tell,15)
			host._menu_text("COUNTERPLAY · "+row.counter,15)
			if row.studied:host._menu_text("BEST RECOVERED PHOTO QUALITY · %d%%"%roundi(row.quality*100.0),15)
	host.call_deferred("_layout")
