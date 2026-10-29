extends "res://src/presentation/career/rider_dive.gd"
# Only session policy changes: operation context, finite supplies and initial Hunt.
# Physical rules, photography, oxygen, film and enemy behavior stay inherited.
# Revert: choose the ordinary Simulation at the mode seam.
const SeededPatrol=preload("res://src/campaign/runs/seeded_siren_patrol.gd")
const RunState=preload("res://src/campaign/runs/run_state.gd")
const RunTable=preload("res://src/campaign/runs/run_table.gd")
var run_state:Dictionary={}
var dev_launch=false
func start_dev(index:int,upgrade:String,launch:Dictionary)->void:
	# Console-only transient launch: bypass seeded operation selection, retain rules.
	# DEV session guards exclude this simulation from checkpoints and settlement.
	dev_launch=true
	super.start(index,upgrade,launch)
	dev_launch=false
func configure(state:Dictionary)->bool:
	if not RunTable.enabled or state.is_empty() or not RunState.valid(state) or state.status!="active":return false
	run_state=state.duplicate(true)
	super.configure(RunState.rider_assignment(state))
	return true
func start(_index:int,_upgrade:String="endurance",_launch:Dictionary={})->void:
	if run_state.is_empty():return
	var op=RunState.current_operation(run_state)
	super.start(op,run_state.loadout,{"fitted":Equipment.default_loadout(),"context":RunState.context(run_state),"fleet_commit":false})
	if run_state.has("tool_racks"):
		var rack_launch={}
		if preload("res://src/equipment/tool_racks.gd").prepare_launch(rack_launch,Equipment.default_loadout(),run_state.tool_racks).is_empty():
			preload("res://src/equipment/tool_racks.gd").launch(self,rack_launch.tool_racks)
	else:
		# Legacy active states retain their pooled launch stock and snapshot contract.
		for key in tools:tools[key]=run_state.stock[key]
		for key in mission.get("field_tools",{}).get("counts",{}):mission.field_tools.counts[key]=run_state.stock[key]
	var stage=RunState.starting_hunt(run_state,op)
	if HuntPressure.active(mission):
		var pressure=Recon.state(mission).duplicate(true)
		pressure.hunt=0. if stage==0 else HuntPressure.Table.THRESHOLDS[stage-1]
		mission.reconnaissance=pressure;mission.hunt_pressure.stage=stage
	mission["run_seed"]=run_state.seed
	_observe()
func _prepare_siren_starts()->void:
	if not dev_launch and not run_state.is_empty():SeededPatrol.apply(self,int(run_state.seed))
func result(abandoned:bool=false)->Dictionary:
	var counts=run_state.stock.duplicate()
	var remaining=charge_counts()
	for key in remaining:
		var carried=preload("res://src/equipment/tool_racks.gd").total(run_state.tool_racks,key) if run_state.has("tool_racks") else int(run_state.stock[key])
		counts[key]=int(run_state.stock[key])-maxi(0,carried-int(remaining[key]))
	var value={"op":mission.id,"outcome":"won" if not abandoned and outcome=="won" else "lost","time":elapsed,"hull":hull,
		"tools":counts,"story":mission.get("expedition_facts",{}).duplicate(true)}
	value.photo=-1.
	for objective in mission.objectives+mission.get("photo",{}).get("studies",[]):
		if objective.get("captured",false) and objective.has("photo_quality"):value.photo=maxf(value.photo,float(objective.photo_quality))
	if run_state.has("riders"):
		value.rider=rider_result()
		if abandoned:value.rider.passed=false
	return value
