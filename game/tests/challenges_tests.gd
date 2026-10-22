extends SceneTree
# Rule and result fixtures are staged; the separate UI journey exercises real play.
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const Run=preload("res://src/campaign/challenges/challenge_run.gd")
const Records=preload("res://src/campaign/challenges/challenge_records.gd")
const Gear=preload("res://src/equipment/equipment_catalog.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds=.1):
	s.paused=false
	for n in roundi(seconds*60):s.advance(1./60)
func forbidden(s,order,args={}):
	var stock=s.tools.duplicate();var oxygen=s.oxygen;var noises=s.noises.duplicate(true)
	check(not s.command(order,args) and s.message.begins_with("CHALLENGE"),"challenge explains its blocked "+order)
	check(s.tools==stock and s.oxygen==oxygen and s.noises==noises,"blocked "+order+" spends no supplies or sound")
func rule(s,row):
	s.sirens=[]
	match row.rule:
		"no_sonar":
			for order in ["ping","recon"]:forbidden(s,order)
		"quietus_only":
			check(s.units[0].alive and not s.units[1].alive and not s.units[2].alive,"the Quietus-only fleet has one launched craft")
			forbidden(s,"select",{"unit":1})
		"no_tools":
			for order in ["emp","decoy","recon","knock"]:forbidden(s,order)
		"hull_intact":
			s.hull=99.;tick(s)
			check(s.outcome=="lost" and not s.rule_failure.is_empty(),"actual hull loss ends the intact-hull challenge")
		"no_losses":
			s.units[1].alive=false;tick(s)
			check(s.outcome=="lost" and not s.rule_failure.is_empty(),"a launched drone loss ends the no-loss challenge")
		"middle_only":
			forbidden(s,"depth",{"band":2})
			check(s.units[0].band==1 and s.units[0].transition.is_empty(),"blocked depth changes preserve the settled band")
			s.units[0].band=2;tick(s)
			check(s.outcome=="lost" and not s.rule_failure.is_empty(),"a forbidden occupied band cannot bypass the rule")
		"one_tool":
			check(s.command("emp"),"the one-charge challenge accepts its first real tool use")
			forbidden(s,"emp")
		"quiet_propulsion":
			s.advance(10.)
			check(s.loud_time==0.,"tactical pause spends no propulsion budget")
			s.units[0].silent=false;s.units[0].vel=Vector2(120,0)
			check(s.motion_radius(0)>430.,"the staged craft really has a loud propulsion footprint")
			s.loud_time=20.;tick(s)
			check(s.outcome=="lost" and not s.rule_failure.is_empty(),"a real loud tick exhausts the propulsion-time budget")
		"time_limit":
			s.elapsed=360.;s.advance(10.)
			check(s.elapsed==360.,"tactical pause spends no timed-challenge budget")
			tick(s)
			check(s.outcome=="lost" and not s.rule_failure.is_empty(),"real simulation time enforces the deadline")
		_:
			check(false,"every authored challenge has an exercised rule")
func _initialize():
	var rows=Catalog.all()
	check(rows.size()==12,"twelve curated challenges cover the existing campaign")
	var ids=[];var operations=[]
	var records={}
	for row in rows:
		check(row.id not in ids,"challenge ids stay unique");ids.append(row.id);operations.append(row.op)
		check(not Catalog.unlocked(row,[]) and Catalog.unlocked(row,[row.op]),"only a recovered operation unlocks "+row.id)
		var s=Run.new();var started=s.setup(row.id)
		check(started,"the fixed challenge starts "+row.id)
		if not started:continue
		check(s.mission.id==row.op and s.paused,"the challenge starts its named operation paused")
		check(s.mission.launch_equipment==Gear.default_loadout(),"the fixed basic fitting is independent of campaign inventory")
		var stock={"endurance":[120.,2,2],"disruption":[100.,3,2],"survey":[100.,2,3]}[row.loadout]
		check(s.oxygen==stock[0] and s.tools.emp==stock[1] and s.tools.recon==stock[2] and s.tools.decoy==3 and s.tools.knock==2,"the displayed fixed loadout sets its real supplies")
		rule(s,row)
		var winner=Run.new();check(winner.setup(row.id),"a fresh attempt restores its fixed loadout")
		winner.elapsed=10.;winner.outcome="won"
		var result=winner.result()
		check(result.get("time")==10. and result.get("hull")==100. and result.get("loss")==false,"result captures the actual successful attempt")
		var before=records.duplicate(true)
		var next=Records.add(records,row.id,result)
		check(records==before and next.has(row.id),"recording a result is additive and leaves its input unchanged")
		if not next.has(row.id):continue
		records=next
		winner.outcome="lost";winner.hull=0.;winner.elapsed=12.
		var lost=winner.result()
		records=Records.add(records,row.id,lost)
		check(records[row.id].best==result and records[row.id].last.loss and records[row.id].attempts==2,"a loss is recorded without overwriting a successful best")
	check(0 in operations and 29 in operations,"the curated set reaches both the opening and the last optional operation")
	check(Records.valid({}) and Records.valid(records),"empty and populated challenge histories are valid")
	var old={"version":2,"unlocked":0,"completed":[],"upgrade":"endurance","settings":{}}
	var store=Store.new();check(store.valid(old),"old profiles need no challenge field")
	var bad=old.duplicate(true);bad.challenges="broken"
	check(not store.valid(bad),"the optional challenge field is validated rather than silently accepted")
	if not records.is_empty():
		var profile=old.duplicate(true);profile.challenges=records
		check(store.valid(profile),"a profile accepts genuine challenge records")
		store.path="user://challenge-records-test.save"
		check(store.save(profile) and store.load_game()==profile,"challenge results survive the normal binary archive round trip")
		var broken=records.duplicate(true);broken[rows[0].id].last.time=NAN
		check(not Records.valid(broken),"non-finite result values are rejected")
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
	print("CHALLENGES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
