extends SceneTree
# Focused saved-assignment, optional-failure and payout fixtures, not player voyages.
const Riders=preload("res://src/campaign/career/riders.gd")
const Dive=preload("res://src/presentation/career/rider_dive.gd")
const Base=preload("res://src/simulation/simulation.gd")
const State=preload("res://src/campaign/career/career_state.gd")
const Archive=preload("res://src/campaign/career/career_archive.gd")
const Runs=preload("res://src/campaign/runs/run_state.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const RunArchive=preload("res://src/campaign/runs/run_archive.gd")
const RunDive=preload("res://src/campaign/runs/expedition_run.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize()->void:call_deferred("run")
func assigned(id:String)->Dictionary:
	for serial in range(1,1000):
		var offer=Riders.offer(Riders.Table.SEED,serial,"brannock_watch")
		if offer.id==id:return offer
	return {}
func result()->Dictionary:return {"outcome":"won","hull":100.,"alive":[true,true]}
func run()->void:
	eligibility()
	var old=State.new_career()
	check(State.valid(old) and not old.has("rider"),"old career remains valid without optional field")
	for id in Riders.Table.ROWS:
		var assignment=assigned(id)
		check(Riders.valid(assignment) and assignment==Riders.offer(assignment.seed,assignment.serial,assignment.contract),"deterministic validated offer "+id)
		check(Riders.description(assignment).contains(Riders.bonus_text(assignment)),"condition announces bonus "+id)
		var run=Dive.new();run.configure(assignment);run.start(0)
		run.outcome="won"
		check(run.rider_result().passed and run.rider_status().begins_with("RIDER · "),"rider passes "+id)
		run.outcome=""
		var ordinary=Base.new();ordinary.start(0)
		match id:
			"no_sonar","no_tools","middle_only":
				var order="ping" if id=="no_sonar" else ("emp" if id=="no_tools" else "depth")
				var args={"band":0} if id=="middle_only" else {}
				var accepted=ordinary.command(order,args)
				check(run.command(order,args)==accepted and run.tools==ordinary.tools and run.units==ordinary.units,"rule rejection preserves actual base command "+id)
			"hull_intact":run.hull=99.;run._tick(0.)
			"no_losses":run.units[1].alive=false;run._tick(0.)
			"one_tool":
				run.used={"emp":1}
				var accepted=ordinary.command("emp")
				check(run.command("emp")==accepted and run.tools==ordinary.tools,"spent budget still executes base tool")
			"quiet_propulsion":run.loud_time=21.;run._tick(0.)
			"time_limit":run.elapsed=361.;run._tick(0.)
		check(not run.rule_failure.is_empty() and run.outcome.is_empty(),"failure leaves base contract running "+id)
		run.outcome="won"
		check(not run.rider_result().passed,"failed rider stays failed on base win "+id)
		var career=State.new_career();career.serial=assignment.serial-1;career.recovered=career.serial
		var launched=State.launch(career,"brannock_watch")
		check(launched.rider==assignment and State.valid(launched),"launch persists announced assignment "+id)
		var base_result=result()
		var no_bonus=State.settle(launched,base_result)
		var declined=launched.duplicate(true);declined.erase("rider")
		var plain=State.settle(declined,base_result)
		check(no_bonus.economy==plain.economy and no_bonus.standing==plain.standing and no_bonus.progress==plain.progress,"base reward and progress unchanged "+id)
		base_result.rider={"assignment":assignment,"passed":true}
		var paid=State.settle(launched,base_result)
		var bonus=Riders.Table.ROWS[id]
		for key in State.Economy.Table.RES:
			check(paid.economy.stock[key]==mini(State.Economy.Table.CAP,no_bonus.economy.stock[key]+bonus.pay.get(key,0)),"explicit bonus math "+id+" "+key)
		check(paid.standing.brannock==no_bonus.standing.brannock+bonus.standing and paid.recovered==no_bonus.recovered,"bonus standing preserves base completion "+id)
		check(State.valid(paid) and State.settle(paid,base_result)==paid,"payout only once "+id)
		base_result.rider.passed=false
		check(State.settle(launched,base_result)==no_bonus,"failed rider preserves base reward "+id)
		base_result.rider.passed=true;base_result.outcome="lost"
		check(State.settle(launched,base_result).report.contains("BONUS NONE"),"base loss forfeits bonus "+id)
	var launch=State.launch(old,"brannock_watch")
	var capped=State.new_career();var standing_assignment=assigned("no_losses")
	capped.serial=standing_assignment.serial-1;capped.recovered=capped.serial
	capped.standing.brannock=State.Table.MAX_STANDING
	capped.economy.stock={"scrap":99,"cells":99,"alloy":99}
	var cap_result=result();cap_result.rider={"assignment":standing_assignment,"passed":true}
	var cap_paid=State.settle(State.launch(capped,"brannock_watch"),cap_result)
	check(cap_paid.standing.brannock==State.Table.MAX_STANDING and cap_paid.economy.stock==capped.economy.stock and State.valid(cap_paid),"bonus respects existing resource and standing caps")
	var archive=Archive.new();archive.path="user://rider-roundtrip.career"
	check(archive.save({"version":1,"career":launch}) and archive.load_game().career==launch,"assignment round trips through checked career archive")
	var corrupt=launch.duplicate(true);corrupt.rider.serial+=1
	check(not State.valid(corrupt),"reject assignment from different contract serial")
	corrupt=launch.duplicate(true);corrupt.rider.id="invented"
	check(not State.valid(corrupt),"reject unknown rider")
	corrupt=launch.duplicate(true);corrupt.rider.seed="bad"
	check(not State.valid(corrupt),"reject invalid seed type")
	corrupt=launch.duplicate(true);corrupt.rider.contract="varne_watch"
	check(not State.valid(corrupt),"reject mismatched contract")
	check(State.launch(old,"brannock_watch",false).rider.is_empty(),"player can decline rider")
	var mismatch=result();var other=launch.rider.duplicate(true);other.serial+=1
	mismatch.rider={"assignment":other,"passed":true}
	check(State.settle(launch,mismatch).report.contains("BONUS NONE"),"mismatched result cannot grant bonus")
	check(State.interrupted(launch).lost==1 and State.interrupted(State.interrupted(launch))==State.interrupted(launch),"interruption settles once")
	Riders.Table.enabled=false
	check(State.valid(launch) and State.rider_offer(old,"brannock_watch").is_empty(),"off switch retains save compatibility and removes offers")
	var off=Dive.new();off.configure(launch.rider);off.start(0);off.command("ping")
	check(off.policy.is_empty() and off.rule_failure.is_empty(),"off switch disables enforcement")
	var staged=result();staged.rider={"assignment":launch.rider,"passed":true}
	check(State.settle(launch,staged).report.contains("BONUS NONE"),"off switch disables bonus")
	Riders.Table.enabled=true
	expeditions()
	print("RIDER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func eligibility()->void:
	for contract in ["mariners_trawler","mariners_thread"]:
		var mission=Riders.Operations.make(State.Table.CONTRACTS[contract].op)
		check(mission.objectives.any(func(o):return not o.get("optional",false) and o.get("subject",{}).get("bands",[])==[2]),"actual required DEEP photograph "+contract)
		check(not Riders.eligible("middle_only",mission),"actual contract excludes middle rider "+contract)
		var legacy={}
		for serial in range(1,129):
			var original=Riders.seeded(Riders.Table.SEED,serial,contract)
			var offer=Riders.offer(Riders.Table.SEED,serial,contract)
			check(offer.is_empty() if original.id=="middle_only" else offer==original,"filter preserves original draw without reroll "+contract)
			var run_contract="expedition_%d"%mission.id
			var run_original=Riders.seeded(42,serial,run_contract)
			var run_offer=Riders.offer(42,serial,run_contract)
			check(run_offer.is_empty() if run_original.id=="middle_only" else run_offer==run_original,"expedition operation uses same required-band filter")
			if original.id=="middle_only" and legacy.is_empty():legacy=original
		check(not legacy.is_empty() and Riders.valid(legacy),"historical impossible assignment remains valid "+contract)
		var career=State.new_career();career.standing.mariners=10
		career.serial=legacy.serial-1;career.recovered=career.serial
		var fresh=State.launch(career,contract)
		check(fresh.rider.is_empty() and State.valid(fresh),"new career launch suppresses impossible rider "+contract)
		var saved=fresh.duplicate(true);saved.rider=legacy
		var archive=Archive.new();archive.path="user://legacy-%s.career"%contract
		check(State.valid(saved) and archive.save({"version":1,"career":saved}) and archive.load_game().career==saved,"saved historical assignment roundtrip "+contract)
		var won=result();won.rider={"assignment":legacy,"passed":true}
		var paid=State.settle(saved,won);var plain=State.settle(fresh,result())
		check(paid.economy.stock.cells==mini(State.Economy.Table.CAP,plain.economy.stock.cells+2) and State.settle(paid,won)==paid,"saved historical bonus compatibility and once-only payout "+contract)
	# Confluence's authored hidden DEEP frame becomes optional when discovered.
	var optional=Riders.Operations.make(11)
	var deep=optional.get("photo_hidden",[]).filter(func(o):return o.get("subject",{}).get("bands",[])==[2])
	if not deep.is_empty():
		var discovered=deep[0].duplicate(true);discovered.optional=true;discovered.site_id=discovered.key
		optional.objectives.append(discovered)
	check(not deep.is_empty() and Riders.eligible("middle_only",optional),"actual optional DEEP photograph permits middle rider")
	if not deep.is_empty():
		optional.required_site_ids=[deep[0].key]
		check(not Riders.eligible("middle_only",optional),"required site overrides optional flag")
	var eligible_count=0
	for contract in State.Table.CONTRACTS:
		var mission=Riders.Operations.make(State.Table.CONTRACTS[contract].op)
		for serial in range(1,65):
			var offer=State.rider_offer({"serial":serial-1},contract)
			if not offer.is_empty():
				eligible_count+=1
				check(Riders.valid(offer) and Riders.eligible(offer.id,mission) and offer==State.rider_offer({"serial":serial-1},contract),"seeded career offer is feasible and stable")
	check(eligible_count>600,"eligible career riders remain available")
	for seed in range(64):
		var state=Runs.new_run(seed)
		var offer=Runs.rider_offer(state)
		var mission=Riders.Operations.make(Runs.current_operation(state))
		var launched=Runs.launch(state,true)
		check(not offer.is_empty() and Riders.eligible(offer.id,mission) and Runs.rider_assignment(launched)==offer and Runs.valid(launched),"seeded expedition launch uses feasible offer and historical replay")
	check(Riders.offer(1,1,"unknown_contract").is_empty(),"unknown operation cannot offer rider")
func expeditions()->void:
	for seed in [42,12345,2147483647]:
		var state=Runs.new_run(seed)
		check(Runs.valid(state),"legacy run without rider ledger")
		# Recover legacy stage, then opt in after a persisted 068 route selection.
		var first={"op":Runs.current_operation(state),"outcome":"won","time":12.,"hull":100.,"tools":state.stock,"story":{}}
		state=Offers.prepare(Runs.settle(Runs.launch(state),first))
		var slate=state.duplicate(true)
		state=Offers.choose(state,state.offers.pending[0])
		var assignment=Runs.rider_offer(state)
		var launched=Runs.launch(state,true)
		check(Runs.valid(launched) and Runs.rider_assignment(launched)==assignment,"selected operation pins seeded rider at full run seed range")
		var dive=RunDive.new();check(dive.configure(launched),"configure combined offer and rider")
		dive.start(-1);dive.outcome="won"
		var result=dive.result()
		var paid=Offers.prepare(Runs.settle(launched,result))
		check(result.rider.passed and Runs.valid(paid),"combined offers and successful rider replay")
		var archive=RunArchive.new();archive.path="user://rider-run-%d.runs"%seed
		check(archive.save({"version":1,"run":paid}) and archive.load_game().run==paid,"combined rider and offer sidecar roundtrip")
		check(Runs.settle(paid,result)==paid and Offers.prepare(paid)==paid,"reload and repeated settle grant bonus once")
		var failed=result.duplicate(true);failed.rider.passed=false
		var plain=Runs.settle(launched,failed)
		var declined=Runs.settle(Runs.launch(state,false),dict_without_rider(result))
		check(plain.stock==declined.stock and plain.story==declined.story and plain.cursor==declined.cursor and plain.status==declined.status,"rider failure preserves base supply and completion")
		for tool in Runs.Table.TOOLS:
			check(paid.stock[tool]==mini(9,plain.stock[tool]+Runs.RIDER_PAY[assignment.id].get(tool,0)),"one-time run bonus math "+tool)
		check(paid.offers==Offers.prepare(plain).offers,"bonus leaves deterministic 068 slate unchanged")
		var tampered=paid.duplicate(true);tampered.results.back().rider.assignment.contract="expedition_other"
		check(not Runs.valid(tampered),"reject mismatched saved rider identity")
		tampered=paid.duplicate(true);tampered.riders.choices[str(state.cursor)]=false
		check(not Runs.valid(tampered),"reject altered accepted ledger")
		tampered=paid.duplicate(true);tampered.results.back().rider.passed="yes"
		check(not Runs.valid(tampered),"reject corrupt bonus flag")
		tampered=paid.duplicate(true);tampered.stock.emp=99
		check(not Runs.valid(tampered),"reject excess grant")
		check(Runs.valid(Runs.interrupted(launched)) and Runs.interrupted(launched).status=="lost","interruption forfeits rider without invalidating ledger")
		var ended=Runs.settle(paid,{"op":Runs.current_operation(paid),"outcome":"lost","time":0.,"hull":100.,"tools":paid.stock,"story":{}})
		check(Runs.valid(ended) and ended.status=="lost","pending offer abandonment remains valid with rider history")
		Riders.Table.enabled=false
		check(Runs.valid(paid) and archive.load_game().run==paid,"off switch preserves historical grants and save validation")
		Riders.Table.enabled=true
		check(slate.offers.pending==Offers.draw(slate),"riders never reroll original offer slate")
		var journey=paid
		while journey.status=="active":
			if Offers.pending(journey):journey=Offers.choose(journey,journey.offers.pending[journey.cursor%3])
			var stage=Runs.launch(journey,journey.cursor%2==0)
			var next_dive=RunDive.new();next_dive.configure(stage);next_dive.start(-1);next_dive.outcome="won"
			journey=Offers.prepare(Runs.settle(stage,next_dive.result()))
			check(Runs.valid(journey) and archive.save({"version":1,"run":journey}) and archive.load_game().run==journey,"all remaining combined stages replay and reload")
		check(journey.status=="won" and journey.cursor==journey.operations.size(),"riders allow complete expedition through final recovery")
	for id in ["no_tools","one_tool"]:
		var dive=Dive.new();dive.configure(assigned(id));dive.start(0)
		check(dive.command("sonobuoy") and dive.tools_used()==1,"field charge executes and is counted "+id)
		check(dive.rule_failure.is_empty()==(id=="one_tool"),"first field charge respects rider budget "+id)
		if id=="one_tool":
			check(dive.command("sonobuoy") and not dive.rule_failure.is_empty(),"second field charge forfeits bonus while base tool works")
	var refused=Dive.new();refused.configure(assigned("no_tools"));refused.start(0);refused.tools.emp=0
	check(not refused.command("emp") and refused.rule_failure.is_empty(),"refused base action spends no charge and does not fail rider")
	var disabled_assignment=assigned("no_tools")
	Riders.Table.enabled=false
	var disabled=Dive.new();disabled.configure(disabled_assignment);disabled.start(0);disabled.command("sonobuoy")
	check(disabled.policy.is_empty() and disabled.rule_failure.is_empty(),"disabled riders never fail on field tools")
	Riders.Table.enabled=true
func dict_without_rider(value:Dictionary)->Dictionary:
	var next=value.duplicate(true);next.erase("rider");return next
