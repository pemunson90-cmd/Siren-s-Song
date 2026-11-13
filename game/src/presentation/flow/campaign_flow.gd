extends RefCounted
const Names=preload("res://src/names.gd")
const BriefRows029=preload("res://src/campaign/onboarding2/briefing_rows.gd")
const ReleaseControls=preload("res://src/presentation/release_controls.gd")
const EconomyPanel=preload("res://src/presentation/economy_panel.gd")
const Economy=preload("res://src/campaign/economy.gd")
const OpsHome=preload("res://src/presentation/ops_home/ops_home.gd")
const PhotoReview=preload("res://src/presentation/flow/photo_review.gd")
const FitSurface=preload("res://src/presentation/fit_surface/fit_surface_view.gd")
const FitSurfaceModel=preload("res://src/presentation/fit_surface/fit_surface.gd")
const FieldManualTable=preload("res://src/presentation/field_manual_table.gd")
# Campaign/menu flow extracted verbatim from main. Main keeps its existing
# entry points as forwarders; host owns state, callbacks and deferred layout.
# Revert the original extraction to restore bodies in main. 029 display rows
# and width/folding helpers revert with BriefRows029.enabled=false. No saved fields.
static func loadout_stock(host, choice: String) -> Array:
	return {Names.LOADOUT_ENDURANCE:[120,2,2],Names.LOADOUT_EMP:[100,3,2],Names.LOADOUT_SURVEY:[100,2,3]}.get(choice,[100,2,2])

# The stock line without its slash-built heading: "Loadout: Endurance (next dive or retry)" plus the unchanged stock figures.
static func plain_stock(host,index:int=-1) -> String:
	var lines=preload("res://src/presentation/truthful_commands.gd").launch_stock(host,index).split("\n")
	lines[0]="Loadout: %s (next dive or retry)"%preload("res://src/equipment/field_tools.gd").loadout_label(host.upgrade).capitalize()
	return "\n".join(lines)

# The hull the next dive starts with (the launch applies the recorded condition); empty when it starts whole.
const CARRIED_HULL="Quietus starts at hull %d%%: damage from the last dive is not repaired."
static func carried_damage_line(host) -> String:
	if not EconomyPanel.Table.enabled:return ""
	var hull:int=int(host.economy.get("cond",{}).get(Names.CRAFT_QUIETUS,100))
	return CARRIED_HULL%hull if hull<100 else ""

static func show_campaign(host) -> void:
	host.screen="menu"; host._clear_menu()
	host._menu_text("SIREN'S SONG",38).add_theme_color_override("font_color",Color("80d9cf"))
	host._menu_text("ONE PILOT. TWO DRONES. AN OCEAN THAT LISTENS.",14)
	host._menu_text("USS QUIETUS  /  OPERATIONS ARCHIVE",18)
	for i in 6:
		var id=i
		var b=host._button(host.panel_box,"%02d   %s   %s"%[i+1,host.Simulation.Missions.TITLES[i],"RECOVERED" if i in host.completed else ("AVAILABLE" if i<=host.unlocked else "LOCKED")],func(): ReleaseControls.debug_print(["SS_MISSION_SELECT ",id]); host._briefing(id))
		b.disabled=i>host.unlocked
		b.set_meta("action","mission%d"%i)
	host.ExpeditionOperations.operations(host)
	preload("res://src/presentation/route_map/route_map_view.gd").entry(host)
	if host.active_started and host.sim.outcome.is_empty():
		host._button(host.panel_box,"RESUME DIVE · %02d %s"%[host.mission_index+1,host.sim.mission.title.to_upper()],host._enter_water,"resume")
	# Keep the helper row stable too, so Resume cannot introduce a scrollbar
	# and shift the menu horizontally at large text sizes.
	if not host._campaign_pristine() and (preload("res://src/presentation/ops_home/ops_home_table.gd").enabled or (host.active_started and host.sim.outcome.is_empty())):host._menu_text("Resuming keeps this dive's equipment and its place in time.",14).set_meta(OpsHome.GROUP_META,"continue")
	host._button(host.panel_box,"FITTINGS",host._show_fittings,"fittings")
	var difficulty_from=host.panel_box.get_child_count()
	EconomyPanel.entry(host)
	# The supplies button comes first; whatever follows it (preset queue, easier button) is the difficulty group.
	OpsHome.mark(host,difficulty_from+1,"difficulty")
	difficulty_from=host.panel_box.get_child_count()
	EconomyPanel.pristine_picker(host)
	OpsHome.mark(host,difficulty_from,"difficulty")
	if not host.Endings.campaign_resolve(host.expedition).is_empty():host._button(host.panel_box,"VIEW CAMPAIGN ENDING",host._show_ending,"ending")
	elif not host.Endings.course_line(host.expedition).is_empty():host._menu_text(host.Endings.course_line(host.expedition),17)
	preload("res://src/presentation/finale/finale.gd").entry(host)
	preload("res://src/persistence/save_states/save2_controller.gd").entry(host)
	if not preload("res://src/presentation/ops_home/ops_home_table.gd").enabled and not host._campaign_pristine():host._button(host.panel_box,"ERASE PROGRESS · NEW CAMPAIGN",host._confirm_new_campaign,"new_campaign")
	if not host.recovered_evidence.is_empty(): host._button(host.panel_box,PhotoReview.GALLERY_BUTTON,func(): host._evidence_gallery(0),"evidence")
	host._menu_text(PhotoReview.loss_note(host,false),14).set_meta(OpsHome.GROUP_META,"note")
	host._menu_text(plain_stock(host),15)
	var rows=["COMPARE STOCK (O₂, EMP, SURVEY)"]
	for choice in Names.LOADOUTS:
		var supplies=host._loadout_stock(choice)
		rows.append("%s: O₂ %d%%, EMP %d, SURVEY %d"%[preload("res://src/equipment/field_tools.gd").loadout_label(choice),supplies[0],supplies[1],supplies[2]])
	host._menu_text("\n".join(rows),14)
	host._menu_text("TOOLS: "+FitSurfaceModel.stock_text(host.tool_racks)+"\nEMP lasts 12s. SURVEY takes 8s and is audible.",14)
	host._button(host.panel_box,"CYCLE LOADOUT: ENDURANCE, EMP, SURVEY",host._cycle_loadout,"loadout")
	host._button(host.panel_box,"SETTINGS",host._settings_menu,"settings")
	# The reach row (Settings, Game Modes, Title, Challenges, Credits) is built before the hub is arranged around it.
	preload("res://src/presentation/frontend/menu_reach.gd").entries(host)
	OpsHome.arrange(host)
	if not preload("res://src/presentation/ops_home/ops_home_table.gd").enabled:preload("res://src/presentation/arcs/arc_card.gd").group_rows(host,host.panel_box)
	ReleaseControls.debug_print(["SS_SCREEN operations window=",host.get_window().size," viewport=",host.get_viewport_rect().size," root=",host.size," unlocked=",host.unlocked," active_time=",snappedf(host.sim.elapsed,0.01)])
	host.call_deferred("_layout")

static func campaign_pristine(host)->bool:
	return host.completed.is_empty() and host.unlocked==0 and host.expedition.is_empty() and host.recovered_evidence.is_empty() and host.photo_records.is_empty() and host.photo_intel.is_empty()

static func show_fittings(host)->void:
	preload("res://src/presentation/fittings_menu.gd").show(host)

static func cycle_loadout(host)->void:
	var reading_position=host.scroll.scroll_vertical
	host.upgrade=Names.LOADOUTS[( [Names.LOADOUT_ENDURANCE,Names.LOADOUT_EMP,Names.LOADOUT_SURVEY].find(host.upgrade)+1)%3]
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
		return "ORDERS\n"+ReleaseControls.CONTROLS_TEXT+"\nTap a craft for its command ring; FLEET chooses a station. Empty water plots its route; a craft that already has orders asks you to confirm. ROUTE → TAPS: REPLACE / QUEUE sets whether a water tap replaces the route or adds to it. PAUSE stays available. Settle and DECODE for two seconds. Quietus receives within156m; drones within214.5m. Cover blocks reception. An audible SONAR may prompt a local relay replay; a decoded packet explains its partner's handshake. Drone buffers TRANSFER locally to Quietus: both settled, within60m, clear link. Return with both packets aboard."
	return "ORDERS\n"+ReleaseControls.CONTROLS_TEXT+"\nTap a craft for its command ring; FLEET chooses a station. Tap empty water to plot a route; a craft that already has orders asks you to confirm. Craft → ROUTE → TAPS: REPLACE / QUEUE sets whether a water tap replaces the route or adds to it. PAUSE stays available. Drag / pinch inspects freely; FOCUS follows the craft and FIT shows the region. CAMERA works within 240m of a gold record marker. Return Quietus after all records are secured."

static func briefing(host, index: int) -> void:
	if index>=6 and index not in host.ExpeditionCampaign.available(host.completed,host.expedition):return
	var compact=BriefRows029.applies(index)
	if compact and (host.screen not in ["briefing","reference"] or host.get_meta("onboard2_fit_index",-1)!=index):host.set_meta("onboard2_fit_open",false)
	host.set_meta("onboard2_fit_index",index)
	host.screen="briefing"; host.sim.paused=true; host._clear_menu()
	var briefing=host.Simulation.Missions.make(index,host._launch_context(index))
	host._menu_text("%02d  %s"%[index+1,briefing.title.to_upper()],BriefRows029.STYLE.title if compact else 30)
	var goal=BriefRows029.goal(index,host.OnboardingText.goal(index))
	var photo_problems:String=preload("res://src/simulation/photo_pricing/photo_pricing_briefing.gd").line(index,host.fitted_equipment)
	var manual_control:Button=null
	if not goal.is_empty():
		# Short briefing facts; full rules remain in the optional field manual.
		host._menu_text(goal,BriefRows029.STYLE.goal if compact else 20)
		var primer:String=host.OnboardingText.primer(index,host.completed)
		if not primer.is_empty():host._menu_text(primer,17)
		if not photo_problems.is_empty():host._menu_text(photo_problems,BriefRows029.STYLE.photo if compact else 17)
		manual_control=host._button(host.panel_box,FieldManualTable.BUTTON_TEXT,func(): host._reference(index),"manual")
	else:
		host._menu_text(briefing.brief,20)
		if not photo_problems.is_empty():host._menu_text(photo_problems,17)
		if host.ExpeditionOperations.briefing(host,index):pass
		manual_control=host._button(host.panel_box,FieldManualTable.BUTTON_TEXT,func(): host._reference(index),"manual")
	var thermal_line=preload("res://src/simulation/thermal_front.gd").briefing(briefing)
	if not thermal_line.is_empty():host._menu_text(thermal_line,17)
	preload("res://src/presentation/archive/voice_feed.gd").briefing(host,index)
	if compact and not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._menu_text(preload("res://src/presentation/launch_summary.gd").short(host),14)
	var fit_start=host.panel_box.get_child_count()
	if not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._menu_text(EconomyPanel.briefing_line(host),14)
	# Audit 091 F10: later briefings compare costs and mounts; the opening briefing keeps fit details optional.
	if index>0 and not compact and not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._menu_text(preload("res://src/presentation/launch_summary.gd").text(host),14)
	preload("res://src/presentation/crew/crew_view.gd").briefing(host,index)
	# The opening brief confirms Quietus stock; its FITTINGS entry owns the full per-craft list.
	host._menu_text(plain_stock(host,index),17)
	var carried_line=carried_damage_line(host)
	if not carried_line.is_empty():host._menu_text(carried_line,17)
	var carry=preload("res://src/presentation/tool_racks_view.gd").carry_text(host.tool_racks)
	if index>=3:host._menu_text(carry,14)
	# Frames open after the first dive; recovered fittings appear once earned. One fold hides them.
	if not compact:fit_start=host.panel_box.get_child_count()
	# Keep the first briefing focused; fit details stay available in the optional fold below LOADOUT.
	FitSurface.summary(host,host._equipment_context(),carry if index<3 else "")
	# The summary toggle keeps its id; its label says what it does and follows its state.
	var summary_toggle=host.panel_box.get_child(host.panel_box.get_child_count()-1)
	if summary_toggle is Button and summary_toggle.get_meta("action","")=="fit_summary":
		summary_toggle.text="SHOW FIT SUMMARY"
		summary_toggle.pressed.connect(func():summary_toggle.text="HIDE FIT SUMMARY" if summary_toggle.text.begins_with("SHOW") else "SHOW FIT SUMMARY",CONNECT_DEFERRED)
	var fold_control:Button=null
	if 0 in host.completed or not host._equipment_entitlements().is_empty():preload("res://src/presentation/equipment_context.gd").loadout(host,host._equipment_context().slots,func(key,id):host._choose_equipment(key,id,index))
	if not host._equipment_entitlements().is_empty():FitSurface.fitting(host,host._equipment_context(),func(slot,item):host._choose_equipment(slot,item,index),func():host._briefing(index))
	# One clearly named entry opens the fittings screen; it sits above the fold and is never folded away.
	var loadout_entry=host._button(host.panel_box,"LOADOUT",host._show_fittings,"edit_racks")
	host.panel_box.move_child(loadout_entry,fit_start);fit_start+=1
	var fit_nodes=host.panel_box.get_children().slice(fit_start)
	# A fold is offered only when it has frames or fittings to hide. The first briefing has none yet:
	# a fold over nothing, or over the summary toggle alone, is one button too many.
	if fit_nodes.any(func(node):return node is Control and node.visible and node.get_meta("action","")!="fit_summary"):
		var holder=[]
		var fold=host._button(host.panel_box,fold_text(false,true),host._fold_fit.bind(fit_nodes,holder),"fit_fold")
		holder.append(fold);host.panel_box.move_child(fold,fit_start)
		fold_control=fold
		if compact and not host.get_meta("onboard2_fit_open",false):host._fold_fit(fit_nodes,holder)
	var begin=host._button(host.menu_footer,EconomyPanel.begin_text(host),func():
		if host.active_started and host.sim.outcome.is_empty():confirm_launch(host,index);return
		launch_now(host,index)
	,"begin")
	begin.disabled=not EconomyPanel.can_begin(host)
	if compact:
		if not begin.disabled:begin.text="DIVE\nPAUSED"
		manual_control.text="FIELD\nMANUAL"
		if fold_control!=null:fold_control.text=fold_text(true,host.get_meta("onboard2_fit_open",false))
		for control in [manual_control,fold_control]:
			if control==null:continue
			host.panel_box.remove_child(control);host.menu_footer.add_child(control)
			control.size_flags_horizontal=Control.SIZE_EXPAND_FILL;control.mouse_filter=Control.MOUSE_FILTER_STOP
	host._button(host.menu_footer,"BACK TO\nOPS" if compact else "BACK TO\nOPERATIONS",host._show_campaign,"back")
	if index>0 and not host._campaign_pristine() and not EconomyPanel.briefing_line(host).is_empty():host._button(host.menu_footer,"COSTS AND\nRETRY",func():preload("res://src/presentation/launch_summary.gd").show(host,index),"launch_costs")
	host.menu_footer.show()
	# Wide landscape screens: facts and orders on the left, loadout controls on the right.
	var wide=preload("res://src/presentation/layout_metrics.gd").hub_wide(host.size,host.ui_touch_height)
	host.set_meta("hub_wide",wide)
	# The compact (029) briefings already run full width on the cover screen; only the opening briefings split.
	if wide and not compact:
		var split=loadout_entry.get_index();var nodes=host.panel_box.get_children()
		var columns=HBoxContainer.new();columns.add_theme_constant_override("separation",int(preload("res://src/presentation/layout_metrics.gd").MENU_COLUMN_GAP));host.panel_box.add_child(columns)
		var left=OpsHome.column(14);var right=OpsHome.column(14);columns.add_child(left);columns.add_child(right)
		for i in nodes.size():nodes[i].reparent(left if i<split else right)
	if compact:preload("res://src/campaign/onboarding2/briefing_layout.gd").attach(host)
	preload("res://src/presentation/arcs/arc_card.gd").intro(host,index)
	host.call_deferred("_layout")

static func launch_now(host,index:int)->void:
	PhotoReview.retain_abandoned(host)
	EconomyPanel.begin(host,index)
	if host.screen=="mission" and host.active_started:host._enter_water()
	elif host.screen=="launch_guard":host._briefing(index) # a blocked launch returns to the briefing it came from

# The live state of a dive that can still be resumed; shared by the launch guard and the supplies page.
static func in_progress_line(host)->String:
	var sim=host.sim
	var seconds:int=int(sim.elapsed)
	return "%02d %s is in progress · time %02d:%02d · hull %d%% · life support %d%%."%[host.mission_index+1,sim.mission.title.to_upper(),seconds/60,seconds%60,roundi(sim.hull),roundi(sim.oxygen)]

# Item 142: a launch over a live dive asks first; KEEP leaves the dive and its briefing untouched.
static func confirm_launch(host,index:int)->void:
	host.screen="launch_guard"; host._clear_menu()
	host._menu_text("ABANDON THE CURRENT DIVE?",24)
	host._menu_text(in_progress_line(host)+"\nLaunching replaces it.",17)
	host._button(host.menu_footer,"KEEP DIVE",func():host._briefing(index),"launch_guard_keep")
	host._button(host.menu_footer,"ABANDON DIVE\nAND LAUNCH",func():launch_now(host,index),"launch_guard_abandon")
	host.menu_footer.show()
	host.call_deferred("_layout")

# The one fold's label: the compact footer button takes two short lines.
static func fold_text(compact:bool,open:bool) -> String:
	if compact:return "HIDE LOADOUT\nDETAILS" if open else "SHOW LOADOUT\nDETAILS"
	return "HIDE LOADOUT DETAILS" if open else "SHOW LOADOUT DETAILS"

static func fold_fit(host, nodes:Array,holder:Array) -> void:
	var show=not nodes[0].visible
	for node in nodes:node.visible=show
	if host.screen=="briefing" and BriefRows029.applies(int(host.get_meta("onboard2_fit_index",-1))):
		host.set_meta("onboard2_fit_open",show)
		holder[0].text=fold_text(true,show)
	else:holder[0].text=fold_text(false,show)
	host.call_deferred("_layout")

static func show_reference(host, index:int) -> void:
	preload("res://src/presentation/field_manual_view.gd").show(host,index)

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

# One end-of-dive line for every debrief path (recovered, lost, expedition).
static func stats_line(sim)->String:
	var oxygen=sim.get("oxygen")
	var elapsed=int(sim.elapsed)
	return "Dive time %02d:%02d  /  Hull %d%%  /  Life support %d%%"%[elapsed/60,elapsed%60,int(sim.hull),int(oxygen) if oxygen!=null else 0]

# The expedition debrief owns its own text; give it the same single line, in place when it already has one.
static func expedition_stats(host)->void:
	if host.screen not in ["debrief","ending"]:return
	var line=stats_line(host.sim)
	var first_button=null
	for child in host.panel_box.get_children():
		if child is Label and child.text.begins_with("Dive time"):child.text=line;return
		if child is Button and first_button==null:first_button=child
	var label=host._menu_text(line,17)
	if first_button!=null and label.get_parent()==host.panel_box:host.panel_box.move_child(label,first_button.get_index())

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
	ReleaseControls.debug_print(["SS_DEBRIEF outcome=",host.sim.outcome," mission=",host.mission_index])
	host._retain_evidence() # WP-34: a loss keeps its photographs only where PhotoReview.keeps_photos_after_loss says so
	if host.sim.outcome=="won":
		host.photo_intel=host.PhotoIntel.recover(host.photo_intel,host.sim.mission)
	if host.ExpeditionOperations.debrief(host):
		expedition_stats(host)
		preload("res://src/presentation/arcs/arc_card.gd").recovered(host,first_recovery)
		return
	var lift_at=-1
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
		preload("res://src/presentation/photo_pay/photo_pay.gd").debrief(host)
		host._menu_text(stats_line(host.sim),17)
		preload("res://src/presentation/damage_log/damage_log.gd").debrief(host)
		if host.mission_index==5:
			host._menu_text("YOUR FIELD RECORD · ACROSS DIVES",14)
			host._menu_text(preload("res://src/campaign/archive_recap.gd").summary(host.recovered_evidence),14)
		if not host.recovered_evidence.is_empty(): host._button(host.panel_box,PhotoReview.GALLERY_BUTTON,func(): host._evidence_gallery(0),"evidence")
		if host.mission_index==5:
			var discovery="The crown is still sending its list: a bearing for every loud site on this coast. Two of them still answer. South down the trench, the drillship Tessaly. West on the shelf, the sonar station at Port Ardent.\n\n" if host.sim.mission.get("finale_revision",0)==1 else ""
			host._menu_text("THE SONG CONTINUES\n\n"+discovery+"Okafor, on Brannock: \"Two bearings. People at both, and air running down at both. Quietus can reach one first.\" Below, the plant lights go out one by one.\n\nIntroductory arc complete. Every dive remains replayable.",20)
			if 6 in host.ExpeditionCampaign.available(host.completed,host.expedition):host._button(host.panel_box,"BEYOND THE WARNING / THE DIVERGENCE",func():host._briefing(6),"expedition6")
		else: host._button(host.panel_box,"NEXT DIVE",func(): host._briefing(host.mission_index+1),"next_dive")
	else:
		host._menu_text("SIGNAL LOST",32); host._menu_text(host.sim.message,22); lift_at=host.panel_box.get_child_count(); host._menu_text(preload("res://src/presentation/loss_summary.gd").line(host.sim),17); host._menu_text(stats_line(host.sim),17); preload("res://src/presentation/death_cause/cause_log.gd").debrief(host); preload("res://src/presentation/damage_log/damage_log.gd").debrief(host); var shots_text:String=PhotoReview.loss_photo_lines(host); if not shots_text.is_empty():host._menu_text(shots_text,17)
		host._menu_text(PhotoReview.loss_note(host,not shots_text.is_empty()),17)
		host.BlackwaterDelivery.debrief(host)
		host.ModuleRecovery.debrief(host)
	host._button(host.panel_box,"RETRY DIVE",func(): host._briefing(host.mission_index),"retry")
	host._button(host.panel_box,"OPERATIONS ARCHIVE",host._show_campaign,"back")
	preload("res://src/presentation/debrief_actions.gd").lift(host,lift_at)
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
	host.fitted_equipment=preload("res://src/equipment/equipment_catalog.gd").default_loadout();host.upgrade=Names.LOADOUT_ENDURANCE
	host.tool_racks=preload("res://src/equipment/tool_racks.gd").template(host.upgrade)
	preload("res://src/presentation/first_siren_cue/cue_archive.gd").restore_types(host,{})  # a new campaign forgets seen Siren kinds
	host._start_mission(0);host._save_archive();host._show_campaign()
