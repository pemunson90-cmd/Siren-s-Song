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
