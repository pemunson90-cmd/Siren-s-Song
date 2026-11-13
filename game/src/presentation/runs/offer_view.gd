extends RefCounted
# Uses Main's scroll column and 48dp buttons. Escape/Android Back returns through
# the session menu, which redraws these same saved offers. Revert: remove flow seam.
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const CARRIED_ORDER=["emp","decoy","hull_patch","sonobuoy","silt_screen","relay_buoy"]
static func show(host)->void:
	host.sim.paused=true;host.screen="expedition_offers";host._clear_menu()
	host._menu_text("CHOOSE THE NEXT DIVE",26)
	host._menu_text("Seed %d: %d of %d operations recovered.\nPick one of three offers. Scroll to see them all. These supplies last for this expedition only, up to 9 of each."%[host.run_state.seed,host.run_state.cursor,host.run_state.operations.size()],17)
	var stock:Dictionary=host.run_state.stock
	var carried:Array=[]
	for key in CARRIED_ORDER:
		if stock[key]>0:carried.append("%d %s"%[stock[key],Tools.spec(key).name])
	host._menu_text("Carrying: %s."%(", ".join(carried) if not carried.is_empty() else "nothing"),17)
	for id in host.run_state.offers.pending:
		var row=Offers.describe(host.run_state,id)
		host._menu_text(row.detail,17)
		host._button(host.panel_box,row.title,func():host._pick_offer(id),"run_offer_"+id)
	host._button(host.panel_box,"BACK TO EXPEDITIONS",host._return,"run_return")
	host.call_deferred("_layout")
