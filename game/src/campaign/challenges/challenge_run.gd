extends "res://src/simulation/simulation.gd"
# Fixed challenge session. The only engine seam is choosing this Simulation subclass.
# It inherits movement, sensing, tools, work and victory; its own policies may reject
# an order or end this mode's attempt. Inactive craft are removed before observation.
# Revert: remove the frontend session and this folder; ordinary Simulation has no hooks here.
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const Rules=preload("res://src/campaign/challenges/challenge_rules.gd")
var definition:Dictionary={}
var policy:Dictionary={}
var launched:Array=[]
var used:Dictionary={}
var loud_time:=0.0
var rule_failure:=""
func configure(id:String)->bool:
	definition=Catalog.get_challenge(id);policy=Catalog.rule(definition)
	return not definition.is_empty()
func setup(id:String)->bool:
	if not configure(id):return false
	start(int(definition.op));return true
func start(_index:int,_upgrade:String="endurance",_launch:Dictionary={})->void:
	if definition.is_empty():return
	super.start(int(definition.op),str(definition.loadout),{"fitted":Catalog.fitting(definition),"context":definition.get("context",{}).duplicate(true),"fleet_commit":false})
	launched=[];used={};loud_time=0.;rule_failure=""
	for id in units.size():
		if units[id].alive:launched.append(id)
	for key in tools:used[key]=0
func _observe()->void:
	if policy.has("crafts"):
		for id in units.size():
			if id not in policy.crafts:units[id].alive=false
	super._observe()
func command(order:String,args:Dictionary={})->bool:
	if definition.is_empty():return false
	var reason=Rules.before(self,order,args)
	if not reason.is_empty():message=reason;return false
	var before=tools.duplicate()
	var accepted=super.command(order,args)
	if accepted:
		for key in before:used[key]=int(used.get(key,0))+maxi(0,int(before[key])-int(tools.get(key,0)))
	return accepted
func _tick(dt:float)->void:
	super._tick(dt)
	Rules.observe(self,dt)
	var reason=Rules.violation(self)
	if not reason.is_empty():rule_failure=reason;message=reason;outcome="lost"
func tools_used()->int:
	var count=0
	for value in used.values():count+=int(value)
	return count
func lost_craft()->int:
	var count=0
	for id in launched:
		if not units[id].alive or (id==0 and hull<=0):count+=1
	return count
func result(abandoned:bool=false)->Dictionary:
	var reason=Rules.violation(self)
	return {"time":elapsed,"hull":hull,"tools_used":used.duplicate(),"loss":abandoned or outcome!="won" or not rule_failure.is_empty() or not reason.is_empty(),"lost_craft":lost_craft(),"loud_time":loud_time}
