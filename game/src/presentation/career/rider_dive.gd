extends "res://src/simulation/simulation.gd"
# Optional policy wrapper: record a rejected rule, then execute the base command.
# Never changes outcome, craft availability, launch gear or physical rules.
# Revert: instantiate ordinary Simulation; no shared Simulation edits required.
const Riders=preload("res://src/campaign/career/riders.gd")
const Rules=preload("res://src/campaign/challenges/challenge_rules.gd")
var assignment:Dictionary={}
var policy:Dictionary={}
var launched:Array=[]
var used:Dictionary={}
var loud_time:=0.0
var rule_failure:=""
func rider_snapshot()->Dictionary:
	return {"launched":launched.duplicate(),"used":used.duplicate(),"loud_time":loud_time,"rule_failure":rule_failure}
static func valid_rider_snapshot(value,snapshot:Dictionary)->bool:
	if not value is Dictionary or value.size()!=4 or not value.has_all(["launched","used","loud_time","rule_failure"]):return false
	if not value.launched is Array or not value.used is Dictionary or not value.rule_failure is String or value.rule_failure.length()>300:return false
	if not (value.loud_time is float or value.loud_time is int) or not is_finite(value.loud_time) or value.loud_time<0 or value.loud_time>snapshot.get("elapsed",0.):return false
	# Every mode launches the same independent three-craft fleet, including craft
	# subsequently lost. Omitting a lost craft would erase a rider violation.
	if value.launched!=[0,1,2]:return false
	for key in value.used:
		if key not in Rules.FINITE_TOOLS or not value.used[key] is int or value.used[key]<0 or value.used[key]>100:return false
	return true
func restore_rider(value:Dictionary)->void:
	launched=value.launched.duplicate();used=value.used.duplicate();loud_time=float(value.loud_time);rule_failure=value.rule_failure
func configure(value:Dictionary)->bool:
	assignment=value.duplicate(true) if Riders.valid(value) else {}
	policy=Riders.policy(assignment)
	return Riders.valid(value)
func start(index:int,upgrade:String="endurance",launch:Dictionary={})->void:
	used={};launched=[];loud_time=0.;rule_failure=""
	super.start(index,upgrade,launch)
	for id in units.size():
		if units[id].alive:launched.append(id)
func fail(reason:String)->void:
	if rule_failure.is_empty() and not reason.is_empty():
		rule_failure=reason.trim_prefix("CHALLENGE · ")
		message="RIDER FAILED · %s · base contract continues"%rule_failure
func command(order:String,args:Dictionary={})->bool:
	var reason=Rules.before(self,order,args) if not policy.is_empty() else ""
	var before=charge_counts()
	var accepted=super.command(order,args)
	if accepted:
		var after=charge_counts()
		for key in before:used[key]=int(used.get(key,0))+maxi(0,int(before[key])-int(after.get(key,0)))
		# Challenge's fixed field loadout rejects even the first allowed charge.
		# Riders count actual expenditure instead, while keeping its other hooks.
		if order not in Rules.FieldTools.field_ids():fail(reason)
		if not policy.is_empty() and assignment.get("id")=="no_tools" and tools_used()>0:fail("No finite tool charges")
	if not policy.is_empty():fail(Rules.violation(self))
	return accepted
func charge_counts()->Dictionary:
	var counts=tools.duplicate()
	counts.merge(mission.get("field_tools",{}).get("counts",{}),true)
	return counts
func _tick(dt:float)->void:
	super._tick(dt)
	if policy.is_empty():return
	Rules.observe(self,dt);fail(Rules.violation(self))
func tools_used()->int:
	var count=0
	for value in used.values():count+=int(value)
	return count
func lost_craft()->int:
	var count=0
	for id in launched:
		if not units[id].alive or (id==0 and hull<=0):count+=1
	return count
func rider_status()->String:
	if policy.is_empty():return ""
	return "RIDER FAILED · "+rule_failure if not rule_failure.is_empty() else "RIDER · "+Rules.status(self)
func rider_result()->Dictionary:
	if not policy.is_empty():fail(Rules.violation(self))
	return {"assignment":assignment.duplicate(true),"passed":not policy.is_empty() and rule_failure.is_empty() and outcome=="won"}
