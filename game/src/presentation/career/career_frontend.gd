extends RefCounted
# One mode seam opens a separate Main/simulation pair and a profile-pinned sidecar.
# Saved career files stay separate from campaign archives.
const State=preload("res://src/campaign/career/career_state.gd")
const Archive=preload("res://src/campaign/career/career_archive.gd")
const SaveErrorView=preload("res://src/presentation/frontend/save_error_view.gd")
static func show(front)->void:
	var state=Archive.restore(front.host)
	front._reset("career")
	front._button("BACK",func():load("res://src/presentation/runs/modes_frontend.gd").show(front),"frontend_back")
	front._text("NAVAL CAREER",32,Color("80d9cf"))
	# Wide: what the career is on the left, where it stands and how to go on on the right.
	var boxes=front._split(func():show(front))
	front._into(boxes[0],func():
		front._text("Regional reconnaissance contracts, faction standing and fleet development. Separate resources and research for this profile. Interrupted dives resume paused. Abandoning a dive fails its contract; the career continues.",17)
		SaveErrorView.notices(front,"career_",17))
	if front.host.get_meta("career_archive_locked",false):return
	if front.host.get_meta("career_archive_dirty",false):
		front._into(boxes[1],func():SaveErrorView.front_retry(front,"",17,"RETRY SAVE",func():show(front),"career_retry"))
		return
	if state.is_empty():
		front._into(boxes[1],func():front._button("START NAVAL CAREER",func():
			if Archive.persist(front.host,State.new_career()):start(front)
			else:show(front)
		,"career_new"))
	else:
		front._into(boxes[1],func():
			front._text("%d CONTRACTS RECOVERED · %d LOST"%[state.recovered,state.lost],20)
			front._button("RESUME DIVE" if state.in_flight else "CONTINUE NAVAL CAREER",func():start(front),"career_continue"))
static func start(front)->void:
	var state=Archive.restore(front.host)
	if state.is_empty() or front.host.get_meta("career_archive_dirty",false):show(front);return
	load("res://src/presentation/frontend/mode_launcher.gd").launch(front,load("res://src/presentation/career/career_session.gd"),"CareerSession",{"career_state":state.duplicate(true),"return_to_list":func():show(front)})
