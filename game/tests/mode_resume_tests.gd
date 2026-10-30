extends SceneTree
# Cold hosts/stores and actual mode simulations. Outcomes are staged; touch sizes
# reuse the existing mode suites. No claim of Android process-kill acceptance.
const Active=preload("res://src/campaign/mode_active.gd")
const Run=preload("res://src/campaign/runs/run_state.gd")
const Runs=preload("res://src/campaign/runs/run_archive.gd")
const Career=preload("res://src/campaign/career/career_state.gd")
const Careers=preload("res://src/campaign/career/career_archive.gd")
const RunSim=preload("res://src/campaign/runs/expedition_run.gd")
const Rider=preload("res://src/presentation/career/rider_dive.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frames():
	for n in 4:await process_frame
func host_at(path:String):
	var host=load("res://scenes/main.tscn").instantiate()
	host.set_script(load("res://tests/density_main.gd"))
	host.capture_scenario="runtime-test";host.store.path=path
	return host
func clean(path:String):
	for suffix in [".runs",".career"]:
		for end in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix+end)
func exercise(mode:String):
	var archive=Runs if mode=="runs" else Careers
	var path="user://070-"+mode+".save";clean(path)
	var state:Dictionary
	if mode=="runs":
		var base=Run.new_run(42)
		base=Run.settle(Run.launch(base,false),{"op":Run.current_operation(base),"outcome":"won","time":10.,"hull":100.,"tools":base.stock.duplicate(),"story":{}})
		base=Run.Offers.prepare(base)
		if Run.Offers.pending(base):base=Run.Offers.choose(base,base.offers.pending[0])
		state=Run.launch(base,true)
	else:
		var base=Career.settle(Career.launch(Career.new_career(),"brannock_watch",false),{"outcome":"won","hull":100.,"alive":[true,true]})
		state=Career.launch(base,"brannock_watch",true)
	var sim=RunSim.new() if mode=="runs" else Rider.new()
	if mode=="runs":sim.configure(state);sim.start(-1)
	else:
		sim.configure(state.rider);sim.start(0,"endurance",{"fitted":state.fitted,"tool_racks":state.tool_racks,"context":{"completed":state.progress.completed,"facts":state.progress.facts},"fleet_commit":false})
		Career.Economy.apply_launch(state.economy,sim)
	sim.elapsed=2.;sim.oxygen=87.;sim.units[0].pos+=Vector2(12,3)
	sim.command("emp");sim.command("sonobuoy",{"pos":sim.units[0].pos});sim.loud_time=.5;sim.fail("CHALLENGE · persisted violation")
	var envelope=Active.capture(mode,state,sim)
	check(Active.valid(envelope,state,mode),mode+" actual snapshot and rider runtime validate")
	if mode=="runs":
		var stacked=Run.new_run(12345)
		stacked=Run.settle(Run.launch(stacked),{"op":Run.current_operation(stacked),"outcome":"won","time":1.,"hull":100.,"tools":stacked.stock,"story":{}})
		stacked=Run.Offers.choose(Run.Offers.prepare(stacked),"refit")
		stacked=Run.launch(stacked,true)
		var stacked_sim=RunSim.new();stacked_sim.configure(stacked);stacked_sim.start(-1)
		check(stacked.stock.hull_patch>1 and Active.valid(Active.capture("runs",stacked,stacked_sim),stacked,"runs"),"accepted resupply with stacked patches remains resumable")
		var campaign=Rider.new();campaign.start(0)
		var invalid=campaign.snapshot();invalid.mission.field_tools.counts.hull_patch=2
		check(not Active.Sim.valid_snapshot(invalid),"campaign retains original patch cap")
		invalid=campaign.snapshot();invalid.tools.knock=3
		check(not Active.Sim.valid_snapshot(invalid),"campaign retains original torpedo stock cap")
		# Accepted seeded resupply, no injected ledger fields or stock mutation.
		var supplied=Run.new_run(3)
		while supplied.cursor<1:
			supplied=Run.settle(Run.launch(supplied,false),{"op":Run.current_operation(supplied),"outcome":"won","time":1.,"hull":100.,"tools":supplied.stock,"story":{}})
		var supplied_sim=RunSim.new();supplied=Run.launch(supplied,true);supplied_sim.configure(supplied);supplied_sim.start(-1)
		check(supplied.stock.knock>2 and Active.valid(Active.capture("runs",supplied,supplied_sim),supplied,"runs"),"accepted resupply torpedo stock remains resumable")
	var host=host_at(path)
	check(archive.persist(host,state,envelope),mode+" atomic active sidecar write")
	host.free()
	var cold=host_at(path);var reopened=archive.restore(cold)
	check(reopened==state and cold.get_meta(mode+"_active",{})==envelope,mode+" fresh host/store restores active envelope")
	var restored=RunSim.new() if mode=="runs" else Rider.new()
	check(Active.restore_sim(restored,cold.get_meta(mode+"_active",{}),reopened,mode),mode+" wrapper restores without start")
	check(restored.paused and restored.units==sim.units and restored.tools==sim.tools and restored.oxygen==87. and restored.mission==sim.mission,mode+" positions stock mission and paused state survive")
	check(restored.rider_snapshot()==sim.rider_snapshot() and restored.assignment==sim.assignment,mode+" rider policy spending and violation survive")
	var again=Active.capture(mode,state,restored,envelope)
	check(again.launch_id==envelope.launch_id and Active.capture(mode,state,sim).launch_id!=envelope.launch_id,mode+" stable launch identity and distinct same-seed attempts")
	var bad=envelope.duplicate(true);bad.rider_runtime.used={}
	check(not Active.valid(bad,state,mode),mode+" erased spending rejected")
	bad=envelope.duplicate(true);bad.simulation.mission.launch_context={"wrong":true}
	check(not Active.valid(bad,state,mode),mode+" unrelated launch context rejected")
	bad=envelope.duplicate(true);bad.rider_runtime.loud_time=NAN
	check(not Active.valid(bad,state,mode),mode+" nonfinite rider counter rejected")
	bad=envelope.duplicate(true);bad.launch_id="g".repeat(32)
	check(not Active.valid(bad,state,mode),mode+" malformed launch identity rejected without codec error")
	bad=envelope.duplicate(true);bad.simulation.tools.emp="empty"
	check(not Active.valid(bad,state,mode),mode+" malformed stock rejected without comparison error")
	bad=envelope.duplicate(true);bad.simulation.elapsed={}
	check(not Active.valid(bad,state,mode),mode+" malformed clock rejected before typed feature validation")
	bad=envelope.duplicate(true);bad.simulation.mission.dev=true
	check(not Active.valid(bad,state,mode),mode+" DEV snapshot cannot become a legitimate checkpoint")

	# Instantiate the real isolated session; its inherited startup builds a preview,
	# which must never overwrite the stored dive or restore launch charges.
	root.add_child(cold);await frames()
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/runs/expedition_session.gd" if mode=="runs" else "res://src/presentation/career/career_session.gd"))
	session.name="ExpeditionSession" if mode=="runs" else "CareerSession"
	session.campaign_host=cold
	if mode=="runs":session.run_state=reopened
	else:session.career_state=reopened
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();cold.add_child(session);await frames()
	check(session.active_started and session.sim.paused and session.sim.units==sim.units and session.sim.rider_snapshot()==sim.rider_snapshot(),mode+" real cold session replaces preview with paused dive")
	session._save_archive()
	check(not session.save_failed and cold.get_meta(mode+"_active",{}).launch_id==envelope.launch_id,mode+" inherited save cadence retains launch id")
	# Fail commit by occupying .tmp with a directory. Retry must persist precisely
	# this settled ledger and its record; subsequent callbacks cannot pay twice.
	var tmp=path+"."+mode+".tmp"
	DirAccess.make_dir_absolute(tmp)
	session._debrief(true);await frames()
	var settled:Dictionary=(session.run_state if mode=="runs" else session.career_state).duplicate(true)
	check(session.save_failed and not settled.in_flight,mode+" failed abandon write retains settled candidate")
	check(cold.get_meta(mode+"_archive_dirty",false),mode+" failed candidate blocks frontend advancement")
	check(not archive.persist(cold,Run.new_run(8) if mode=="runs" else Career.new_career()) and cold.get_meta(mode+"_archive_state",{})==settled,mode+" pending settled candidate rejects replacement launch")
	var before_retry=host_at(path)
	check(archive.restore(before_retry)==state,mode+" cold reopen before failed commit retains unpaid active checkpoint")
	before_retry.free()

	session._debrief(true)
	check((session.run_state if mode=="runs" else session.career_state)==settled,mode+" repeat abandon cannot settle twice")
	DirAccess.remove_absolute(tmp)
	if mode=="runs":session._result_menu()
	else:session._save_archive()
	check(not session.save_failed and cold.get_meta(mode+"_active",{})=={},mode+" retry atomically clears active")
	if mode=="runs":check(Runs.records(cold).last.size()==1,"one run record after failed write retry")
	cold.queue_free();await frames()
	var after=host_at(path)
	check(archive.restore(after)==settled and after.get_meta(mode+"_active",{})=={},mode+" cold reopen retains one settled outcome")
	if mode=="runs":check(Runs.records(after).last.size()==1,"cold reopen cannot duplicate 069 record")
	else:check(settled.lost==1 and settled.economy.settled=="career_%d"%state.serial,"one career economy settlement key")
	after.free()
	# Optional malformed active never invalidates an otherwise valid ledger.
	var disk=archive.new();disk.path=path+"."+mode
	var payload={"version":1,"run" if mode=="runs" else "career":state,"active":{"broken":true}}
	check(disk.save(payload),mode+" ledger with unusable optional envelope remains readable")
	var recover=host_at(path);var recovered=archive.restore(recover)
	check(not recovered.in_flight and recovered.get("status","lost")=="lost" and "Could not restore" in recover.get_meta(mode+"_recovery_notice",""),mode+" invalid envelope explains checkpoint loss recovery")
	recover.free()
	# Valid backup active survives corrupt primary bytes through canonical Store.
	payload.active=envelope;check(disk.save(payload) and disk.save(payload),mode+" valid backup fixture")
	var file=FileAccess.open(disk.path,FileAccess.WRITE);file.store_string("corrupt");file.close()
	var backup=host_at(path)
	check(archive.restore(backup)==state and backup.get_meta(mode+"_active",{})==envelope,mode+" corrupt primary recovers valid backup dive")
	check("backup" in backup.get_meta(mode+"_save_error",""),mode+" backup recovery notice remains visible")
	var other=host_at(path+"-other");clean(other.store.path)
	check(archive.restore(other).is_empty(),mode+" pinned physical profile isolation")
	other.store.suspended=true
	check(not archive.persist(other,state,envelope) and not FileAccess.file_exists(other.store.path+"."+mode),mode+" suspended writer rejected")
	other.free();backup.free()
func success(mode:String):
	var archive=Runs if mode=="runs" else Careers
	var path="user://070-win-"+mode+".save";clean(path)
	var host=host_at(path);root.add_child(host);await frames()
	var initial=Run.new_run(123) if mode=="runs" else Career.new_career()
	check(archive.persist(host,initial),mode+" prelaunch checkpoint")
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/runs/expedition_session.gd" if mode=="runs" else "res://src/presentation/career/career_session.gd"))
	session.name="ExpeditionSession" if mode=="runs" else "CareerSession";session.campaign_host=host
	if mode=="runs":session.run_state=initial
	else:session.career_state=initial
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();host.add_child(session);await frames()
	check(host.get_meta(mode+"_active",{}).is_empty(),mode+" preview does not save an active placeholder")
	session._begin();await frames()
	check(not session.save_failed and host.get_meta(mode+"_active",{}).get("ledger",{}).get("in_flight",false),mode+" fresh launch commits full envelope")
	var live:Dictionary=archive.restore(host)
	var bytes=FileAccess.get_file_as_bytes(path+"."+mode)
	host.store.suspended=true;session._save_archive()
	check(session.save_failed and FileAccess.get_file_as_bytes(path+"."+mode)==bytes,mode+" retired host cannot overwrite active archive")
	host.store.suspended=false
	host.store.path=path+"-other";clean(host.store.path);session._save_archive()
	check(session.save_failed and not FileAccess.file_exists(host.store.path+"."+mode),mode+" live session remains pinned after host path changes")
	host.store.path=path;session._save_archive()
	check(not session.save_failed,mode+" original profile Retry recovers")
	session.sim.outcome="won";session._debrief();await frames()
	var won:Dictionary=(session.run_state if mode=="runs" else session.career_state).duplicate(true)
	session._debrief();session._save_archive()
	check(not won.in_flight and won==(session.run_state if mode=="runs" else session.career_state),mode+" successful settlement callback is idempotent")
	host.queue_free();await frames()
	var cold=host_at(path)
	check(archive.restore(cold)==won and cold.get_meta(mode+"_active",{}).is_empty(),mode+" successful cold reopen cannot launch or pay again")
	if mode=="career":check(won.recovered==1 and won.economy.settled=="career_1", "career keeps original economy key")
	cold.free()
	# Legacy in-flight state explicitly settles loss and explains its absence.
	var disk=archive.new();disk.path=path+"."+mode
	check(disk.save({"version":1,"run" if mode=="runs" else "career":live}),mode+" legacy archive fixture")
	cold=host_at(path)
	check(not archive.restore(cold).in_flight and "Legacy" in cold.get_meta(mode+"_recovery_notice",""),mode+" legacy interrupted loss is visible")
	cold.free()
func pending_career_fittings():
	var path="user://070-pending-fittings.save";clean(path)
	var host=host_at(path);root.add_child(host);await frames()
	var initial=Career.new_career()
	initial.economy.stock={"scrap":90,"cells":90,"alloy":90}
	check(Careers.persist(host,initial),"career fittings initial checkpoint")
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/career/career_session.gd"))
	session.name="CareerSession";session.campaign_host=host;session.career_state=initial
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();host.add_child(session);await frames()
	session._change(func():Career.manufacture(session.career_state,"quietus_baffles"),session._show_economy)
	session._choose_equipment("quietus","quietus_baffles",-1)
	check(not session.save_failed and session.fitted_equipment.quietus=="quietus_baffles" and session.economy.stock.scrap<90,"healthy career permits paid manufacture and fitting")
	session._show_fittings()
	var purchase:Button
	for child in session.panel_box.get_children():
		if child is Button and child.get_meta("action","").begins_with("frame_") and "LOCKED" in child.text and not child.disabled:
			purchase=child;break
	check(purchase!=null,"career fixture offers affordable locked frame")
	var tmp=path+".career.tmp";DirAccess.make_dir_absolute(tmp)
	session._save_archive()
	var candidate:Dictionary=host.get_meta("career_archive_state",{}).duplicate(true)
	check(session.save_failed and host.get_meta("career_archive_dirty",false) and not candidate.in_flight,"between-dive write pins failed candidate")
	# Already-rendered callback must refuse before the shared view buys the frame.
	if purchase!=null:purchase.pressed.emit()
	await frames()
	check(session.career_state==candidate,"pending stale frame callback cannot buy an unlock or spend alloy")
	session._choose_equipment("quietus","",-1)
	session._choose_equipment("hull","quiet",-1)
	check(session.career_state==candidate and session.fitted_equipment==candidate.fitted,"pending direct module and hull choices preserve candidate")
	session._change(func():Career.Economy.refine(session.economy),session._show_economy)
	session._change(func():Career.manufacture(session.career_state,"quietus_vector_drive"),session._show_economy)
	check(session.career_state==candidate and session.fitted_equipment==candidate.fitted,"pending fitting purchase/refine/manufacture leave resources unlocks and fit exact")
	session._show_fittings()
	for child in session.panel_box.get_children():
		if child is Button and child.get_meta("action","").begins_with("frame_"):
			check(child.disabled,"pending frame buttons disabled")
	DirAccess.remove_absolute(tmp);session._save_archive()
	check(not session.save_failed and not session._mutations_blocked() and not host.get_meta("career_archive_dirty",false) and session.career_state==candidate,"between-dive retry saves exact candidate and clears pending")
	host.queue_free();await frames()
	var cold=host_at(path)
	check(Careers.restore(cold)==candidate and cold.get_meta("career_active",{}).is_empty(),"cold reopen keeps candidate with no extra resources unlocks or payment")
	cold.free()
func ledger_cache(host,mode:String)->Dictionary:
	var result={}
	for suffix in ["archive_path","archive_state","archive_dirty","archive_locked","active","records","recorded"]:
		var key=mode+"_"+suffix
		if host.has_meta(key):result[key]=host.get_meta(key)
	return result.duplicate(true)
func dev_composition(mode:String,pending:bool):
	var Dev=preload("res://src/debug/dev_state.gd")
	var archive=Runs if mode=="runs" else Careers
	var path="user://070-dev-%s-%s.save"%[mode,str(pending)];clean(path)
	var host=host_at(path);root.add_child(host);await frames()
	var state=Run.new_run(42) if mode=="runs" else Career.new_career()
	check(archive.persist(host,state),mode+" DEV composition prelaunch fixture")
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/"+mode+"/"+("expedition" if mode=="runs" else "career")+"_session.gd"))
	session.name="ExpeditionSession" if mode=="runs" else "CareerSession";session.campaign_host=host
	if mode=="runs":session.run_state=state
	else:session.career_state=state
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();host.add_child(session);await frames()
	session._begin();session.sim.command("emp");session.sim.elapsed=3.;session._save_archive()
	var launched:Dictionary=(session.run_state if mode=="runs" else session.career_state).duplicate(true)
	var checkpoint:Dictionary=host.get_meta(mode+"_active",{}).duplicate(true)
	# Reopen the actual paused session, including its spent tools and Rider counters.
	session.queue_free();await frames()
	var resumed=load("res://scenes/main.tscn").instantiate()
	resumed.set_script(load("res://src/presentation/"+mode+"/"+("expedition" if mode=="runs" else "career")+"_session.gd"))
	resumed.name="ExpeditionSession" if mode=="runs" else "CareerSession";resumed.campaign_host=host
	if mode=="runs":resumed.run_state=archive.restore(host)
	else:resumed.career_state=archive.restore(host)
	resumed.process_mode=Node.PROCESS_MODE_ALWAYS;host.add_child(resumed);await frames()
	check(resumed.active_started and resumed.sim.paused and resumed.sim.elapsed==3.,mode+" DEV case starts from exact resumed dive")
	var tmp=path+"."+mode+".tmp"
	if pending:
		DirAccess.make_dir_absolute(tmp);resumed.sim.outcome="won";resumed._debrief(mode=="runs");await frames()
		check(resumed.save_failed and host.get_meta(mode+"_archive_dirty",false),mode+" DEV case pins failed settlement candidate")
	var held=ledger_cache(host,mode)
	var bytes=FileAccess.get_file_as_bytes(path+"."+mode)
	var backup=FileAccess.get_file_as_bytes(path+"."+mode+".bak")
	resumed.debug_console.execute("end")
	check(Dev.marked(host) and Dev.marked(resumed),mode+" DEV end permanently taints both hosts")
	var prior:Dictionary=host.get_meta(mode+"_archive_state",{}).duplicate(true)
	check(archive.restore(host)==prior and ledger_cache(host,mode)==held,mode+" DEV restore neither settles nor retries legitimate candidate")
	if mode=="runs":check(Runs.abandon(host)==prior and ledger_cache(host,mode)==held,"DEV Modes END RUN preserves active ledger and records")
	check(archive.persist(host,prior,{} if pending else checkpoint)==(not pending),mode+" DEV memory edit cannot acknowledge pending durable candidate")
	check(ledger_cache(host,mode)==held,mode+" DEV persist preserves ordinary metadata")
	if not pending:
		var injected=checkpoint.duplicate(true);injected.rider_runtime.used={"emp":99}
		check(not archive.persist(host,prior,injected),mode+" DEV memory persistence retains actual spending validation")
	resumed.debug_console.execute("jump 41")
	check(resumed.sim.mission.id==41 and resumed.sim.mission.get("dev",false),mode+" transient DEV jump reaches accepted operation41")
	resumed._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT);resumed._save_archive();resumed._debrief(true)
	check(ledger_cache(host,mode)==held,mode+" DEV jump suspend and abandon cannot capture or settle legitimate state")
	host.store.suspended=true
	check(not archive.persist(host,prior),mode+" DEV persist retains suspended-store guard")
	host.store.suspended=false;host.store.path=path+"-other";resumed._save_archive()
	check(not FileAccess.file_exists(host.store.path+"."+mode) and ledger_cache(host,mode)==held,mode+" DEV jump cannot write through changed host profile")
	host.store.path=path
	Dev.leave(resumed);await frames()
	check(not is_instance_valid(resumed),mode+" DEV Return exits even with failed candidate")
	check(ledger_cache(host,mode)==held and FileAccess.get_file_as_bytes(path+"."+mode)==bytes and FileAccess.get_file_as_bytes(path+"."+mode+".bak")==backup,mode+" DEV Return retains exact primary backup envelope records and pending cache")
	if pending:DirAccess.remove_absolute(tmp)
	# A reset discards only ephemeral copies. Never turn a DEV outcome into payment.
	Dev.restore(host,{},true);host.sim.mission.erase("dev")
	var after=archive.restore(host)
	check(after==prior and not host.get_meta(mode+"_archive_dirty",false),mode+" clean reset retries only original legitimate candidate")
	var cold=host_at(path)
	check(archive.restore(cold)==prior,mode+" cold reopen retains legitimate result or active checkpoint")
	if mode=="runs":check(Runs.records(cold).last.size()==(1 if pending else 0),"DEV cannot add expedition record after eligibility reset")
	else:check(after.recovered==(1 if pending else 0),"DEV cannot add career pay or standing after eligibility reset")
	cold.free();host.queue_free();await frames()
	# A pre-marked cold entry must also preserve a legacy in-flight ledger.
	var disk=archive.new();disk.path=path+"."+mode
	check(disk.save({"version":1,"run" if mode=="runs" else "career":launched}),mode+" DEV legacy fixture")
	var marked=host_at(path);marked.set_meta("dev_profile",true)
	var legacy_bytes=FileAccess.get_file_as_bytes(disk.path)
	check(archive.restore(marked)==launched and FileAccess.get_file_as_bytes(disk.path)==legacy_bytes,mode+" cold DEV entry never converts legitimate legacy flight to loss")
	check(not marked.has_meta(mode+"_archive_state"),mode+" cold DEV entry keeps legitimate cache unmodified")
	marked.free()
func dev_entry(mode:String):
	var Dev=preload("res://src/debug/dev_state.gd")
	var archive=Runs if mode=="runs" else Careers
	var path="user://070-dev-entry-"+mode+".save";clean(path)
	var host=host_at(path);root.add_child(host);await frames()
	var state=Run.launch(Run.new_run(42),true) if mode=="runs" else Career.launch(Career.new_career(),"brannock_watch",true)
	var sim=RunSim.new() if mode=="runs" else Rider.new()
	if mode=="runs":sim.configure(state);sim.start(-1)
	else:
		sim.configure(state.rider);sim.start(0,"endurance",{"fitted":state.fitted,"tool_racks":state.tool_racks,"context":Active.context_for(mode,state),"fleet_commit":false})
		Career.Economy.apply_launch(state.economy,sim)
	sim.command("emp");sim.elapsed=4.
	var envelope=Active.capture(mode,state,sim)
	check(archive.persist(host,state,envelope),mode+" premarked entry active fixture")
	var held=ledger_cache(host,mode);var bytes=FileAccess.get_file_as_bytes(path+"."+mode)
	Dev.mark(host);var restored=archive.restore(host)
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/"+mode+"/"+("expedition" if mode=="runs" else "career")+"_session.gd"))
	session.name="ExpeditionSession" if mode=="runs" else "CareerSession";session.campaign_host=host
	if mode=="runs":session.run_state=restored
	else:session.career_state=restored
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();host.add_child(session);await frames()
	check(session.active_started and session.sim.paused and session.sim.elapsed==4. and session.sim.rider_snapshot()==sim.rider_snapshot(),mode+" premarked DEV entry restores exact legitimate paused envelope")
	Dev.restore(host,{},true);host.sim.mission.erase("dev")
	check(Dev.marked(session) and not Dev.marked(host),mode+" mode session retains own taint after parent eligibility reset")
	session.sim.outcome="won";session._debrief();session._save_archive()
	check(session.screen=="dev_debrief" and ledger_cache(host,mode)==held,mode+" parent reset cannot credit DEV mode outcome")
	Dev.leave(session);await frames()
	check(not is_instance_valid(session) and FileAccess.get_file_as_bytes(path+"."+mode)==bytes and ledger_cache(host,mode)==held,mode+" premarked DEV Return preserves legitimate checkpoint")
	host.queue_free();await frames()
func run():
	root.size=Vector2i(1080,2520)
	for mode in ["runs","career"]:
		await dev_composition(mode,false)
		await dev_composition(mode,true)
		await dev_entry(mode)
	await pending_career_fittings()
	await success("runs")
	await success("career")
	await exercise("runs")
	await exercise("career")
	# The Modes END EXPEDITION callback uses this same archive guard rather than
	# manufacturing a fresh zero-time result for a resumed, already-spent dive.
	var path="user://070-modes-end.save";clean(path)
	var host=host_at(path)
	var state=Run.launch(Run.new_run(42),true)
	var sim=RunSim.new();sim.configure(state);sim.start(-1);sim.command("emp")
	check(Runs.persist(host,state,Active.capture("runs",state,sim)),"mode END active checkpoint fixture")
	var tmp=path+".runs.tmp";DirAccess.make_dir_absolute(tmp)
	var ended=Runs.abandon(host)
	check(ended.status=="lost" and ended.results[0].tools==sim.result(true).tools and not ended.results[0].rider.passed,"mode END uses actual spending and forfeits rider")
	check(host.get_meta("runs_archive_dirty",false) and Runs.abandon(host)==ended,"mode END failure retains same loss candidate")
	DirAccess.remove_absolute(tmp)
	check(Runs.restore(host)==ended and Runs.records(host).last.size()==1,"mode END retry commits one069 record")
	host.free();host=host_at(path)
	check(Runs.restore(host)==ended and Runs.records(host).last.size()==1,"mode END cold reopen never records twice")
	host.free()
	print("MODE RESUME CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
