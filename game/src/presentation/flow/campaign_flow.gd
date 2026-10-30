extends RefCounted
const BriefRows029=preload("res://src/campaign/onboarding2/briefing_rows.gd")
const EconomyPanel=preload("res://src/presentation/economy_panel.gd")
const Economy=preload("res://src/campaign/economy.gd")
const FitSurface=preload("res://src/presentation/fit_surface/fit_surface_view.gd")
const FitSurfaceModel=preload("res://src/presentation/fit_surface/fit_surface.gd")
# Campaign/menu flow extracted verbatim from main. Main keeps its existing
# entry points as forwarders; host owns state, callbacks and deferred layout.
# Revert the original extraction to restore bodies in main. 029 display rows
# and width/folding helpers revert with BriefRows029.enabled=false. No saved fields.
static func loadout_stock(host, choice: String) -> Array:
	return {"endurance":[120,2,2],"disruption":[100,3,2],"survey":[100,2,3]}.get(choice,[100,2,2])

static func show_campaign(host) -> void:
	host.screen="menu"; host._clear_menu()
	host._menu_text("SIREN'S SONG",38).add_theme_color_override("font_color",Color("80d9cf"))
	host._menu_text("ONE PILOT. TWO DRONES. AN OCEAN THAT LISTENS.",14)
	host._menu_text("USS QUIETUS  /  OPERATIONS ARCHIVE",18)
	for i in 6:
		var id=i
		var b=host._button(host.panel_box,"%02d   %s   %s"%[i+1,host.Simulation.Missions.TITLES[i],"RECOVERED" if i in host.completed else ("AVAILABLE" if i<=host.unlocked else "LOCKED")],func(): print("SS_MISSION_SELECT ",id); host._briefing(id))
		b.disabled=i>host.unlocked
		b.set_meta("action","mission%d"%i)
	host.ExpeditionOperations.operations(host)
	preload("res://src/presentation/route_map/route_map_view.gd").entry(host)
	if host.active_started and host.sim.outcome.is_empty():
		host._button(host.panel_box,"RESUME DIVE · %02d %s"%[host.mission_index+1,host.sim.mission.title.to_upper()],host._enter_water,"resume")
	# Keep the helper row stable too, so Resume cannot introduce a scrollbar
	# and shift the menu horizontally at large text sizes.
	if not host._campaign_pristine() and (preload("res://src/presentation/ops_home/ops_home_table.gd").enabled or (host.active_started and host.sim.outcome.is_empty())):host._menu_text("Resuming keeps this dive's equipment and its place in time.",14)
	host._button(host.panel_box,"FITTINGS / NEXT LAUNCH",host._show_fittings,"fittings")
	EconomyPanel.entry(host)
	EconomyPanel.pristine_picker(host)
	if not host.Endings.campaign_resolve(host.expedition).is_empty():host._button(host.panel_box,"VIEW CAMPAIGN ENDING",host._show_ending,"ending")
	elif not host.Endings.course_line(host.expedition).is_empty():host._menu_text(host.Endings.course_line(host.expedition),17)
	preload("res://src/presentation/finale/finale.gd").entry(host)
	preload("res://src/persistence/save_states/save2_controller.gd").entry(host)
	if not preload("res://src/presentation/ops_home/ops_home_table.gd").enabled and not host._campaign_pristine():host._button(host.panel_box,"ERASE PROGRESS · NEW CAMPAIGN",host._confirm_new_campaign,"new_campaign")
	if not host.recovered_evidence.is_empty(): host._button(host.panel_box,"REVIEW FIELD RECORDS",func(): host._evidence_gallery(0),"evidence")
	host._menu_text("Field records remain reviewable after loss or abandonment. Only successful extraction advances the campaign.",14)
	var stock=host._loadout_stock(host.upgrade)
	host._menu_text("NEXT DIVE / RETRY · %s\nO₂ %d%% · DISRUPT %d · SURVEY %d"%[host.upgrade.to_upper(),stock[0],preload("res://src/equipment/tool_racks.gd").total(host.tool_racks,"emp"),preload("res://src/equipment/tool_racks.gd").total(host.tool_racks,"recon")],15)
	var rows=["COMPARE: O₂ / DISRUPT / SURVEY"]
	for choice in ["endurance","disruption","survey"]:
		var supplies=host._loadout_stock(choice)
		rows.append("%s · %d%% / %d / %d"%[choice.to_upper(),supplies[0],supplies[1],supplies[2]])
	host._menu_text("\n".join(rows),14)
	host._menu_text("TOOLS: "+FitSurfaceModel.stock_text(host.tool_racks)+"\nDISRUPT: 12s / SURVEY: 8s, audible",14)
	host._button(host.panel_box,"CYCLE LOADOUT · endurance / disruption / survey",host._cycle_loadout,"loadout")
	host._button(host.panel_box,"AUDIO / SETTINGS",host._settings_menu,"settings")
	preload("res://src/presentation/ops_home/ops_home.gd").arrange(host)
	preload("res://src/presentation/arcs/arc_card.gd").group_rows(host,host.panel_box)
	preload("res://src/presentation/frontend/menu_reach.gd").entries(host)
	print("SS_SCREEN operations window=",host.get_window().size," viewport=",host.get_viewport_rect().size," root=",host.size," unlocked=",host.unlocked," active_time=",snappedf(host.sim.elapsed,0.01))
	host.call_deferred("_layout")

static func campaign_pristine(host)->bool:
	return host.completed.is_empty() and host.unlocked==0 and host.expedition.is_empty() and host.recovered_evidence.is_empty() and host.photo_records.is_empty() and host.photo_intel.is_empty()

static func show_fittings(host)->void:
	preload("res://src/presentation/fittings_menu.gd").show(host)

static func cycle_loadout(host)->void:
	var reading_position=host.scroll.scroll_vertical
	host.upgrade=["endurance","disruption","survey"][( ["endurance","disruption","survey"].find(host.upgrade)+1)%3]
	host.tool_racks=preload("res://src/equipment/tool_racks.gd").template(host.upgrade)
	host._save_archive()
	host._show_campaign()
	var heading=host.panel_box.get_child(0)
	(func():
		await host.get_tree().process_frame
		if is_instance_valid(heading) and heading.get_parent()==host.panel_box:host.scroll.scroll_vertical=reading_position
	).call_deferred()

static func orders_text(host, briefing:Dictionary) -> String:
	if briefing.get("blackwater_revision",0)==1:
		return "ORDERS\nTap a craft for its command ring; FLEET chooses a station. Empty water plots its route; a craft that already has orders asks you to confirm. ROUTE → REPLACE / QUEUE changes append intent. PAUSE stays available. Settle and SAMPLE for two seconds. Quietus receives within156m; drones within214.5m. Cover blocks reception. An audible SONAR may prompt a local relay replay; a decoded packet explains its partner's handshake. Drone buffers TRANSFER locally to Quietus: both settled, within60m, clear link. Return with both packets aboard."
	return "ORDERS\nTap a craft for its command ring; FLEET chooses a station. Tap empty water to plot a route; a craft that already has orders asks you to confirm. Craft → ROUTE → REPLACE / QUEUE changes append intent. PAUSE stays available. Drag / pinch inspects freely; FOCUS follows the craft and FIT shows the region. CAMERA works within 240m of a gold record marker. Return Quietus after all records are secured."

static func briefing(host, index: int) -> void:
	if index>=6 and index not in host.ExpeditionCampaign.available(host.completed,host.expedition):return
	var compact=BriefRows029.applies(index)
	if compact and (host.screen not in ["briefing","reference"] or host.get_meta("onboard2_fit_index",-1)!=index):host.set_meta("onboard2_fit_open",false)
	host.set_meta("onboard2_fit_index",index)
	host.screen="briefing"; host.sim.paused=true; host._clear_menu()
	var briefing=host.Simulation.Missions.make(index,host._launch_context(index))
	host._menu_text("%02d / %s"%[index+1,briefing.title.to_upper()],BriefRows029.STYLE.title if compact else 30)
	var goal=BriefRows029.goal(index,host.OnboardingText.goal(index))
	var photo_problems:String=preload("res://src/simulation/photo_pricing/photo_pricing_briefing.gd").line(index,host.fitted_equipment)
	var manual_control:Button=null
	if not goal.is_empty():
		# Short briefing facts; full rules remain in the optional field manual.
		host._menu_text(goal,BriefRows029.STYLE.goal if compact else 20)
		if not photo_problems.is_empty():host._menu_text(photo_problems,BriefRows029.STYLE.photo if compact else 17)
		manual_control=host._button(host.panel_box,"FIELD MANUAL · full rules and orders",func(): host._reference(index),"manual")
	else:
		host._menu_text(briefing.brief,20)
		if not photo_problems.is_empty():host._menu_text(photo_problems,17)
		if host.ExpeditionOperations.briefing(host,index):pass
		manual_control=host._button(host.panel_box,"FIELD MANUAL · full rules and orders",func(): host._reference(index),"manual")
	var thermal_line=preload("res://src/simulation/thermal_front.gd").briefing(briefing)
	if not thermal_line.is_empty():host._menu_text(thermal_line,17)
	preload("res://src/presentation/archive/voice_feed.gd").briefing(host,index)
	if compact and not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._menu_text(preload("res://src/presentation/launch_summary.gd").short(host),14)
	var stock=host._loadout_stock(host.upgrade)
	var fit_start=host.panel_box.get_child_count()
	if not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._menu_text(EconomyPanel.briefing_line(host),14)
	# Audit 091 F10: launch, retry and bare-baseline cost plus one mount line per craft, before any long fitting list.
	if not compact and not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._menu_text(preload("res://src/presentation/launch_summary.gd").text(host),14)
	preload("res://src/presentation/crew/crew_view.gd").briefing(host,index)
	host._menu_text("NEXT DIVE / RETRY · %s\nO₂ %d%% · DISRUPT %d · SURVEY %d · %d DECOYS · %d TORPEDOES"%[host.upgrade.to_upper(),stock[0],preload("res://src/equipment/tool_racks.gd").total(host.tool_racks,"emp"),preload("res://src/equipment/tool_racks.gd").total(host.tool_racks,"recon"),preload("res://src/equipment/tool_racks.gd").total(host.tool_racks,"decoy"),preload("res://src/equipment/tool_racks.gd").total(host.tool_racks,"knock")],17)
	# Frames open after the first dive; recovered fittings appear once earned. A toggle folds them away.
	if not compact:fit_start=host.panel_box.get_child_count()
	# Keep the first briefing focused; fit details stay available in its existing optional fold.
	host._button(host.panel_box,"EDIT TOOL RACKS / FITTINGS",host._show_fittings,"edit_racks")
	FitSurface.summary(host,host._equipment_context())
	var fold_control:Button=null
	if 0 in host.completed or not host._equipment_entitlements().is_empty():preload("res://src/presentation/equipment_context.gd").loadout(host,host._equipment_context().slots,func(key,id):host._choose_equipment(key,id,index))
	if not host._equipment_entitlements().is_empty():FitSurface.fitting(host,host._equipment_context(),func(slot,item):host._choose_equipment(slot,item,index),func():host._briefing(index))
	if host.panel_box.get_child_count()>fit_start:
		var fit_nodes=host.panel_box.get_children().slice(fit_start)
		var holder=[]
		var fold=host._button(host.panel_box,"HIDE FRAMES AND FITTINGS",host._fold_fit.bind(fit_nodes,holder),"fit_fold")
		holder.append(fold);host.panel_box.move_child(fold,fit_start)
		fold_control=fold
		if compact:
			fold.text=BriefRows029.FOLD_LABELS.hide
			if not host.get_meta("onboard2_fit_open",false):host._fold_fit(fit_nodes,holder)
	var begin=host._button(host.menu_footer,EconomyPanel.begin_text(host),func():
		EconomyPanel.begin(host,index)
		if host.screen=="mission" and host.active_started:host._enter_water()
	,"begin")
	begin.disabled=not EconomyPanel.can_begin(host)
	if compact:
		if not begin.disabled:begin.text="DIVE\nPAUSED"
		manual_control.text="FIELD\nMANUAL"
		if fold_control!=null:fold_control.text="FIT\n"+("HIDE" if host.get_meta("onboard2_fit_open",false) else "SHOW")
		for control in [manual_control,fold_control]:
			if control==null:continue
			host.panel_box.remove_child(control);host.menu_footer.add_child(control)
			control.size_flags_horizontal=Control.SIZE_EXPAND_FILL;control.mouse_filter=Control.MOUSE_FILTER_STOP
	host._button(host.menu_footer,"BACK TO\nOPS" if compact else "BACK TO\nOPERATIONS",host._show_campaign,"back")
	if not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._button(host.menu_footer,"COSTS /\nRETRY",func():preload("res://src/presentation/launch_summary.gd").show(host,index),"launch_costs")
	host.menu_footer.show()
	if compact:preload("res://src/campaign/onboarding2/briefing_layout.gd").attach(host)
	preload("res://src/presentation/arcs/arc_card.gd").intro(host,index)
	host.call_deferred("_layout")

static func fold_fit(host, nodes:Array,holder:Array) -> void:
	var show=not nodes[0].visible
	for node in nodes:node.visible=show
	if host.screen=="briefing" and BriefRows029.applies(int(host.get_meta("onboard2_fit_index",-1))):
		host.set_meta("onboard2_fit_open",show)
		holder[0].text="FIT\nHIDE" if show else "FIT\nSHOW"
	else:holder[0].text="HIDE FRAMES AND FITTINGS" if show else "SHOW FRAMES AND FITTINGS"
	host.call_deferred("_layout")

static func show_reference(host, index:int) -> void:
	host.screen="reference"; host._clear_menu()
	var briefing=host.Simulation.Missions.make(index,host._launch_context(index))
	var parts=host.OnboardingText.reference_text(briefing.brief).split("\n\n")
	for n in parts.size():
		host._menu_text(parts[n],24 if n==0 else 17)
	if briefing.get("blackwater_revision",0)==1:host._menu_text(host._orders_text(briefing),17)
	if BriefRows029.applies(index):host.ExpeditionOperations.briefing(host,index)
	host._button(host.menu_footer,"BACK TO BRIEFING",func():host._briefing(index),"back"); host.menu_footer.show()
	host.call_deferred("_layout")

static func launch_context(host, index:int)->Dictionary:
	var context=preload("res://src/campaign/campaign_consequences.gd").context(host.expedition)
	context["intel"]=host.photo_intel.duplicate(true)
	if index in [9,10]:context.thread="deep" if index==9 else "shelf"
	return context

static func equipment_entitlements(host)->Array:
	return host.EarlyReward.earned(host.early_reward,host.CraftUpgrades.recovered(host.completed,host.expedition,host.photo_intel))

static func campaign_completed(host)->Array:
	return host.completed+host.expedition.get("completed",[])

static func equipment_context(host)->Dictionary:
	var earned=host._equipment_entitlements();var available=host.FleetInventory.available(earned,host.fleet,host.economy)
	return {"slots":Economy.lock_frames(host.economy,host.expedition,host.FleetInventory.reconcile_fitting(host.fitted_equipment,available)),"available":available,"catalog":preload("res://src/equipment/equipment_catalog.gd").public_catalog(earned)}

static func choose_equipment(host, slot:String,item:String,index:int)->void:
	var choice=preload("res://src/equipment/equipment_catalog.gd").choose(host.fitted_equipment,slot,item,host.FleetInventory.available(host._equipment_entitlements(),host.fleet,host.economy))
	if not choice.ok:return
	var catalog=preload("res://src/equipment/equipment_catalog.gd")
	for unit in 3:
		if slot==catalog.FRAME_KEYS[catalog.SLOTS[unit]] and Economy.frame_locked(host.economy,host.expedition,unit,item):return
	var reading_position=host.scroll.scroll_vertical
	host.fitted_equipment=choice.fitted
	host._save_archive()
	if index<0:host._show_fittings()
	else:host._briefing(index)
	var heading=host.panel_box.get_child(0)
	(func():
		# Wait for wrapped text to establish the rebuilt scroll range.
		await host.get_tree().process_frame
		if is_instance_valid(heading) and heading.get_parent()==host.panel_box:host.scroll.scroll_vertical=reading_position
	).call_deferred()

static func debrief(host) -> void:
	preload("res://src/persistence/save_states/save2_controller.gd").terminal(host)
	host.screen="debrief"; host._clear_menu()
	# Capture first completion before either classic or expedition debrief writes
	# progress. The launch's fleet_commit also freezes replay intent across saves.
	var first_recovery=host.mission_index not in host._campaign_completed()
	var fleet_before=host.fleet.duplicate(true)
	if first_recovery:host.fleet=host.FleetInventory.recover(host.fleet,host.sim.mission,host.sim.outcome)
	EconomyPanel.settle(host,first_recovery,fleet_before)
	for loss in Economy.Losses.lines(host.economy,true):host._menu_text(loss,17)
	host.fitted_equipment=host.FleetInventory.reconcile_fitting(host.fitted_equipment,host.FleetInventory.available(host._equipment_entitlements(),host.fleet,host.economy))
	print("SS_DEBRIEF outcome=",host.sim.outcome," mission=",host.mission_index)
	if host.sim.outcome=="won":
		host._retain_evidence()
		host.photo_intel=host.PhotoIntel.recover(host.photo_intel,host.sim.mission)
	if host.ExpeditionOperations.debrief(host):
		preload("res://src/presentation/arcs/arc_card.gd").recovered(host,first_recovery)
		return
	if host.sim.outcome=="won":
		host._retain_evidence()
		if host.mission_index not in host.completed: host.completed.append(host.mission_index)
		host.unlocked=mini(5,maxi(host.unlocked,host.mission_index+1))
		host._sync_craft_upgrades()
		host._menu_text("ARCHIVE RECOVERED",32)
		host._menu_text(host.sim.mission.record,22)
		preload("res://src/presentation/archive/voice_feed.gd").debrief(host)
		host.EarlyReward.debrief(host)
		host.BlackwaterDelivery.debrief(host)
		host.ModuleRecovery.debrief(host)
		host._show_photo_grade(host.sim.mission.objectives)
		host._menu_text("Dive time %02d:%02d  /  Hull %d%%  /  Life support %d%%"%[int(host.sim.elapsed)/60,int(host.sim.elapsed)%60,int(host.sim.hull),int(host.sim.oxygen)],17)
		preload("res://src/presentation/damage_log/damage_log.gd").debrief(host)
		if host.mission_index==5:
			host._menu_text("YOUR FIELD RECORD · ACROSS DIVES",14)
			host._menu_text(preload("res://src/campaign/archive_recap.gd").summary(host.recovered_evidence),14)
		if not host.recovered_evidence.is_empty(): host._button(host.panel_box,"REVIEW FIELD RECORDS",func(): host._evidence_gallery(0),"evidence")
		if host.mission_index==5:
			var discovery="The crown is still sending its list: a bearing for every loud site on this coast. Two of them still answer. South down the trench, the drillship Tessaly. West on the shelf, the sonar station at Port Ardent.\n\n" if host.sim.mission.get("finale_revision",0)==1 else ""
			host._menu_text("THE SONG CONTINUES\n\n"+discovery+"Okafor, on Brannock: \"Two bearings. People at both, and air running down at both. Quietus can reach one first.\" Below, the plant lights go out one by one.\n\nIntroductory arc complete. Every dive remains replayable.",20)
			if 6 in host.ExpeditionCampaign.available(host.completed,host.expedition):host._button(host.panel_box,"BEYOND THE WARNING / THE DIVERGENCE",func():host._briefing(6),"expedition6")
		else: host._button(host.panel_box,"NEXT DIVE",func(): host._briefing(host.mission_index+1),"next_dive")
	else:
		host._menu_text("SIGNAL LOST",32); host._menu_text(host.sim.message,22); host._menu_text(preload("res://src/presentation/loss_summary.gd").line(host.sim),17); preload("res://src/presentation/death_cause/cause_log.gd").debrief(host); preload("res://src/presentation/damage_log/damage_log.gd").debrief(host); host._menu_text("Field records remain reviewable after loss or abandonment. Only successful extraction advances the campaign.",17)
		host.BlackwaterDelivery.debrief(host)
		host.ModuleRecovery.debrief(host)
	host._button(host.panel_box,"RETRY DIVE",func(): host._briefing(host.mission_index),"retry")
	host._button(host.panel_box,"OPERATIONS ARCHIVE",host._show_campaign,"back")
	host._save_archive()
	preload("res://src/presentation/arcs/arc_card.gd").recovered(host,first_recovery)
	host.call_deferred("_layout")

static func sync_craft_upgrades(host)->void:
	if not host.expedition.is_empty():host.expedition.entitlements=host._equipment_entitlements()

static func show_ending(host,photo:bool=true)->void:
	if photo and host.Endings.campaign_resolve(host.expedition).is_empty():host._save_archive();host._show_campaign();return
	if photo and preload("res://src/presentation/endings_photo_view.gd").present(host,func():show_ending(host,false)):return
	var ending=host.Endings.campaign_resolve(host.expedition)
	if ending.is_empty():ending=host.Endings.resolve(host.expedition)
	if ending.is_empty():host._show_campaign();return
	host.sim.paused=true;host.screen="ending";host._clear_menu()
	host._menu_text(preload("res://src/persistence/save_states/save2_controller.gd").legacy_title(host,"SIREN'S SONG / RECOVERED OUTCOME"),18)
	host._menu_text(ending.title,36)
	host._menu_text(ending.outcome,24)
	if host.sim.outcome=="won":host.WitnessView.arrival(host);host.RecipientView.arrival(host);preload("res://src/presentation/concealed_harbour_view.gd").debrief(host)
	host._menu_text(ending.story,21)
	if host.sim.outcome=="won" and host.sim.mission.id in [12,13]:host.ModuleRecovery.debrief(host)
	host._show_photo_grade(host.photo_records.values())
	var save2=preload("res://src/persistence/save_states/save2_controller.gd")
	var save2_on=preload("res://src/persistence/save_states/save2_table.gd").enabled
	if 22 in host.ExpeditionCampaign.available(host.completed,host.expedition) and (not save2_on or 22 not in host.expedition.get("completed",[])):host._button(host.panel_box,"CONTINUE / IRON CHOIR",func():host._briefing(22),"continue_choir")
	if 14 in host.ExpeditionCampaign.available(host.completed,host.expedition) and (not save2_on or 14 not in host.expedition.get("completed",[])):host._button(host.panel_box,"CONTINUE / GLASS REACH",func():host._briefing(14),"continue_glass")
	save2.replay_entry(host,"first_ending")
	if not save2_on:host._button(host.panel_box,"NEW CAMPAIGN / CHOOSE ANOTHER ROUTE",host._confirm_new_campaign,"new_campaign")
	host._button(host.panel_box,"OPERATIONS ARCHIVE",host._show_campaign,"back")
	host._save_archive();host.call_deferred("_layout")

static func confirm_new_campaign(host)->void:
	host.sim.paused=true;host.screen="new_campaign";host._clear_menu()
	host._menu_text("ERASE PROGRESS AND START OVER?",30)
	host._menu_text("This deletes your saved operations, equipment and field records and returns you to operation 1. Audio and display settings stay.",20)
	preload("res://src/persistence/save_states/save2_controller.gd").erase_option(host)
	EconomyPanel.draft_picker(host)
	host._button(host.panel_box,"ERASE AND START OVER",host._new_campaign,"confirm_new_campaign")
	host._button(host.panel_box,"KEEP MY PROGRESS",host._show_campaign,"back")
	host.call_deferred("_layout")

static func new_campaign(host)->void:
	if not preload("res://src/persistence/save_states/save2_controller.gd").before_erase(host):host._confirm_new_campaign();return
	preload("res://src/presentation/arcs/arc_card.gd").clear(host)
	preload("res://src/presentation/finale/finale.gd").clear(host)
	preload("res://src/presentation/archive/voice_feed.gd").clear(host)
	preload("res://src/debug/dev_state.gd").restore(host,{},true)
	host.sim.mission.erase("dev")
	if host.debug_console!=null:host.debug_console.time_scale=1.;host.debug_console.invulnerable=false;host.debug_console.layers.clear()
	host.early_reward={}
	host.completed=[];host.unlocked=0;host.expedition={};host.recovered_evidence={};host.photo_records={};host.photo_intel={};host.hints_seen=[]
	host.fleet={};host.economy=EconomyPanel.take_draft(host)
	host.fitted_equipment=preload("res://src/equipment/equipment_catalog.gd").default_loadout();host.upgrade="endurance"
	host.tool_racks=preload("res://src/equipment/tool_racks.gd").template(host.upgrade)
	preload("res://src/presentation/first_siren_cue/cue_archive.gd").restore_types(host,{})  # a new campaign forgets seen Siren kinds
	host._start_mission(0);host._save_archive();host._show_campaign()
