extends RefCounted
# Mode navigation uses the existing scroll column and full-size touch buttons.
# Revert: remove frontend/menu-reach registrations; retain .runs sidecars.
const State=preload("res://src/campaign/runs/run_state.gd")
const Archive=preload("res://src/campaign/runs/run_archive.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
static func show(front)->void:
	front._reset("modes")
	front._button("BACK",front._return,"frontend_back")
	front._text("GAME MODES",32,Color("80d9cf"))
	var continuing=front.profile in [front.Profile.OK,front.Profile.RECOVERED]
	front._button("CAMPAIGN · CONTINUE" if continuing else "CAMPAIGN",front._continue if continuing else front._new_campaign,"mode_campaign")
	front._text("A continuing photographic reconnaissance campaign with persistent fleet progress.",16)
	front._button("CHALLENGES",func():load("res://src/presentation/frontend/challenges_frontend.gd").show(front),"mode_challenges",front.profile==front.Profile.UNREADABLE)
	front._text("Fixed attempts unlocked by recovered campaign operations.",16)
	front._button("EXPEDITIONS",func():expeditions(front),"mode_expeditions",not Table.enabled)
	front._text("Seeded runs of 3 to 6 operations. Finite tools carry forward. One loss ends the run.",16)
	front._button("NAVAL CAREER · COMING SOON",func():pass,"mode_career",true)
static func expeditions(front)->void:
	var state=Archive.restore(front.host)
	front._reset("expeditions")
	front._button("BACK",func():show(front),"frontend_back")
	front._text("EXPEDITIONS",32,Color("80d9cf"))
	front._text("Separate fleet, resources and records. Campaign saves, hard saves and Ironman progress stay in their own timeline. Returning between operations keeps this run; ending a dive loses it.",16)
	var error=str(front.host.get_meta("runs_save_error",""))
	if not error.is_empty():front._text(error,16,Color("efc28d"))
	if not state.is_empty():
		front._text("SEED %d · %s · %d / %d RECOVERED"%[state.seed,state.status.to_upper(),state.cursor,state.operations.size()],20)
		if state.status=="active":
			front._button("CONTINUE EXPEDITION",func():start(front),"run_continue")
			front._text("Finish or end this expedition before starting another.",16)
			front._button("END EXPEDITION",func():confirm_end(front,state),"run_end")
			return
	front._button("NEW SEEDED EXPEDITION",func():
		var seed_value=int(Time.get_unix_time_from_system()) & 0x7fffffff
		if Archive.persist(front.host,State.new_run(seed_value)):expeditions(front)
		else:expeditions(front)
	,"run_new")
static func confirm_end(front,state:Dictionary)->void:
	front._reset("run_end")
	front._text("END THIS EXPEDITION?",30)
	front._text("The run will be recorded as lost. Campaign progress stays as it was.",17)
	front._button("KEEP EXPEDITION",func():expeditions(front),"run_keep")
	front._button("END RUN",func():
		var launched=State.launch(state) if not state.in_flight else state
		Archive.persist(front.host,State.settle(launched,{"outcome":"lost","op":State.current_operation(state),"time":0.,"hull":100.,"tools":state.stock,"story":{}}))
		expeditions(front)
	,"run_confirm_end")
static func start(front)->void:
	var state=Archive.restore(front.host)
	if state.is_empty() or state.status!="active":return
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/runs/expedition_session.gd"));session.name="ExpeditionSession"
	session.campaign_host=front.host;session.run_state=state.duplicate(true)
	session.return_to_list=func():expeditions(front)
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();front.host.add_child(session)
