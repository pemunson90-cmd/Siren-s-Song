extends RefCounted
# Mode navigation uses the existing scroll column and full-size touch buttons.
# Revert: remove frontend/menu-reach registrations; retain .runs sidecars.
const State=preload("res://src/campaign/runs/run_state.gd")
const Archive=preload("res://src/campaign/runs/run_archive.gd")
const Records=preload("res://src/campaign/runs/run_records.gd")
const Summary=preload("res://src/presentation/runs/run_summary_view.gd")
const SeedEntry=preload("res://src/presentation/runs/seed_entry.gd")
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
	front._button("NAVAL CAREER",func():load("res://src/presentation/career/career_frontend.gd").show(front),"mode_career",not preload("res://src/campaign/career/career_table.gd").ENABLED)
static func expeditions(front)->void:
	var state=Archive.restore(front.host)
	front._reset("expeditions")
	front._button("BACK",func():show(front),"frontend_back")
	front._text("EXPEDITIONS",32,Color("80d9cf"))
	front._text("Separate fleet, resources and records. Campaign saves, hard saves and Ironman progress stay in their own timeline. Returning between operations keeps this run; ending a dive loses it.",16)
	var notice=str(front.host.get_meta("runs_recovery_notice",""))
	if not notice.is_empty():front._text(notice,16,Color("efc28d"))
	var error=str(front.host.get_meta("runs_save_error",""))
	if not error.is_empty():front._text(error,16,Color("efc28d"))
	if front.host.get_meta("runs_archive_dirty",false):
		front._button("RETRY SAVE",func():expeditions(front),"run_retry_save")
		return
	if not state.is_empty():
		front._text("SEED %d · %s · %d / %d RECOVERED"%[state.seed,state.status.to_upper(),state.cursor,state.operations.size()],20)
		if state.status=="active":
			front._button("RESUME DIVE" if state.in_flight else "CONTINUE EXPEDITION",func():start(front),"run_continue")
			front._text("Finish or end this expedition before starting another.",16)
			front._button("END EXPEDITION",func():confirm_end(front,state),"run_end")
			history(front)
			return
		else:
			front._button("VIEW RUN SUMMARY",func():record_detail(front,Records.summary(state)),"run_summary")
	front._button("NEW SEEDED EXPEDITION",func():seed_screen(front,randi_range(0,Table.MAX_SEED)),"run_new")
	history(front)
static func history(front)->void:
	var records=Archive.records(front.host)
	front._text("RUN RECORDS / BEST DEPTH %d"%records.best_depth,22)
	if records.last.is_empty():front._text("No finished runs recorded yet.",16)
	for i in records.last.size():
		var row:Dictionary=records.last[i]
		front._button("SEED %d / %s / %d OF %d CLEARED"%[row.seed,row.status.to_upper(),row.depth,row.total],func():record_detail(front,row),"run_record_%d"%i)
static func record_detail(front,row:Dictionary)->void:
	Summary.detail(front,row,func():expeditions(front),func():seed_screen(front,row.seed))
static func seed_screen(front,seed_value:int)->void:
	var current=Archive.restore(front.host)
	if not current.is_empty() and current.status=="active":expeditions(front);return
	SeedEntry.show(front,seed_value,func():expeditions(front),func(chosen:int):
		# Recheck at mutation time so a stale screen cannot replace a live run.
		var latest=Archive.restore(front.host)
		if latest.is_empty() or latest.status!="active":Archive.persist(front.host,State.new_run(chosen))
		expeditions(front)
	)

static func confirm_end(front,state:Dictionary)->void:
	front._reset("run_end")
	front._text("END THIS EXPEDITION?",30)
	front._text("The run will be recorded as lost. Campaign progress stays as it was.",17)
	front._button("KEEP EXPEDITION",func():expeditions(front),"run_keep")
	front._button("END RUN",func():
		var ended=Archive.abandon(front.host)
		if not ended.is_empty() and ended.get("status")=="lost" and not front.host.get_meta("runs_archive_dirty",false):record_detail(front,Records.summary(ended))
		else:expeditions(front)
	,"run_confirm_end")
static func start(front)->void:
	var state=Archive.restore(front.host)
	if state.is_empty() or state.status!="active" or front.host.get_meta("runs_archive_dirty",false):return
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/runs/expedition_session.gd"));session.name="ExpeditionSession"
	session.campaign_host=front.host;session.run_state=state.duplicate(true)
	session.return_to_list=func():expeditions(front)
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();front.host.add_child(session)
