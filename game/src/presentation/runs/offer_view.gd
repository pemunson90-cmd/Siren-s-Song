extends RefCounted
# Uses Main's scroll column and 48dp buttons. Escape/Android Back returns through
# the session menu, which redraws these same saved offers. Revert: remove flow seam.
const Offers=preload("res://src/campaign/runs/run_offers.gd")
static func show(host)->void:
	host.sim.paused=true;host.screen="expedition_offers";host._clear_menu()
	host._menu_text("CHOOSE THE NEXT DIVE",26)
	host._menu_text("SEED %d · %d / %d RECOVERED\nChoose 1 of 3. Scroll for all offers. Run-only supplies, capped at 9 each."%[host.run_state.seed,host.run_state.cursor,host.run_state.operations.size()],17)
	var stock:Dictionary=host.run_state.stock
	host._menu_text("CARRIED · %d Disrupt · %d Decoy · %d Hull patch\n%d Sonobuoy · %d Silt screen · %d Relay buoy"%[stock.emp,stock.decoy,stock.hull_patch,stock.sonobuoy,stock.silt_screen,stock.relay_buoy],17)
	for id in host.run_state.offers.pending:
		var row=Offers.describe(host.run_state,id)
		host._menu_text(row.detail,17)
		host._button(host.panel_box,row.title,func():host._pick_offer(id),"run_offer_"+id)
	host._button(host.panel_box,"RETURN TO EXPEDITIONS",host._return,"run_return")
	host.call_deferred("_layout")
