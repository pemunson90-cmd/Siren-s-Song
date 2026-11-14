extends RefCounted
# Read-only dossier. Only roles already noticed or identified in recovered film are listed.
# The visible BACK button and Android Back go to the same place: the Archive when it was opened from there, else Operations.
const Table=preload("res://src/presentation/siren_dossier/dossier_table.gd")
const Archive=preload("res://src/presentation/archive/archive_view.gd")
const BACK_TO_ARCHIVE="BACK TO ARCHIVE"
const BACK_TO_OPERATIONS="BACK TO OPERATIONS"
static func show(host,from_archive:=false)->void:
	host.screen="siren_dossier";host.sim.paused=true;host._clear_menu()
	host.set_meta("siren_dossier_from","archive" if from_archive else "operations")
	host._button(host.panel_box,BACK_TO_ARCHIVE if from_archive else BACK_TO_OPERATIONS,func():back(host),"siren_dossier_back")
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
# Returns to the screen the dossier was opened from.
static func back(host)->bool:
	if host.get_meta("siren_dossier_from","operations")=="archive":Archive.show(host)
	else:host._show_campaign()
	return true
