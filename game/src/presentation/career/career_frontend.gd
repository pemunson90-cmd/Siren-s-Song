extends RefCounted
# One mode seam opens a separate Main/simulation pair and a profile-pinned sidecar.
# Saved career files stay separate from campaign archives.
const State=preload("res://src/campaign/career/career_state.gd")
const Archive=preload("res://src/campaign/career/career_archive.gd")
static func show(front)->void:
	var state=Archive.restore(front.host)
	front._reset("career")
	front._button("BACK",func():load("res://src/presentation/runs/modes_frontend.gd").show(front),"frontend_back")
	front._text("NAVAL CAREER",32,Color("80d9cf"))
	front._text("Regional reconnaissance contracts, faction standing and fleet development. Separate resources and research for this profile. Interrupted dives resume paused. Abandoning a dive fails its contract; the career continues.",17)
	var notice=str(front.host.get_meta("career_recovery_notice",""))
	if not notice.is_empty():front._text(notice,17,Color("efc28d"))
	var error=str(front.host.get_meta("career_save_error",""))
	if not error.is_empty():front._text(error,17,Color("efc28d"))
	if front.host.get_meta("career_archive_locked",false):return
	if front.host.get_meta("career_archive_dirty",false):
		front._button("RETRY SAVE",func():show(front),"career_retry")
		return
	if state.is_empty():
		front._button("START NAVAL CAREER",func():
			if Archive.persist(front.host,State.new_career()):start(front)
			else:show(front)
		,"career_new")
	else:
		front._text("%d CONTRACTS RECOVERED · %d LOST"%[state.recovered,state.lost],20)
		front._button("RESUME DIVE" if state.in_flight else "CONTINUE NAVAL CAREER",func():start(front),"career_continue")
static func start(front)->void:
	var state=Archive.restore(front.host)
	if state.is_empty() or front.host.get_meta("career_archive_dirty",false):show(front);return
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/career/career_session.gd"));session.name="CareerSession"
	session.campaign_host=front.host;session.career_state=state.duplicate(true)
	session.return_to_list=func():show(front)
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();front.host.add_child(session)
