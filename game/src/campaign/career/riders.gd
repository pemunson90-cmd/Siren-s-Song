extends RefCounted
# Reusable seeded assignment/result policy. No dependency on career or run state.
# Revert: RiderTable.enabled=false disables new offers and bonus grants.
const Table=preload("res://src/campaign/career/rider_table.gd")
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Contracts=preload("res://src/campaign/career/career_table.gd")
const Operations=preload("res://src/campaign/operation_catalog.gd")
const BandPhoto=preload("res://src/photo_depth/band_photo.gd")
static func offer(seed:int,serial:int,contract:String)->Dictionary:
	if not Table.enabled:return {}
	var assignment=seeded(seed,serial,contract)
	var op=int(Contracts.CONTRACTS[contract].op) if Contracts.CONTRACTS.has(contract) else -1
	if contract.begins_with("expedition_"):
		var suffix=contract.trim_prefix("expedition_")
		if suffix.is_valid_int():op=int(suffix)
	if Operations.definition(op).is_empty():return {}
	return assignment if eligible(assignment.id,Operations.make(op)) else {}
static func eligible(id:String,mission:Dictionary)->bool:
	if not Table.ROWS.has(id) or mission.is_empty():return false
	var rule:Dictionary=Catalog.RULES[id]
	if not rule.has("band"):return true
	# Ask the camera's central band gate; optional frames never gate recovery.
	var craft={"alive":true,"band":int(rule.band),"transition":{}}
	for objective in mission.get("objectives",[]):
		if objective.get("optional",false) and objective.get("site_id","") not in mission.get("required_site_ids",[]):continue
		if not BandPhoto.can_shoot(mission,craft,objective):return false
	return true
static func seeded(seed:int,serial:int,contract:String)->Dictionary:
	# Historical identity is also used by saved run replay. Filter only new offers;
	# suppress an incompatible draw without rerolling or changing existing grants.
	# String.hash is deterministic; use a local RNG, never the global gameplay RNG.
	var rng=RandomNumberGenerator.new();rng.seed=seed+serial+int(contract.hash())
	var ids=Table.ROWS.keys()
	return {"seed":seed,"serial":serial,"contract":contract,"id":ids[rng.randi_range(0,ids.size()-1)]}
static func valid(value)->bool:
	if not value is Dictionary:return false
	if value.is_empty():return true
	if value.size()!=4 or not value.has_all(["seed","serial","contract","id"]):return false
	if not value.seed is int or value.seed<0 or value.seed>2147483647:return false
	if not value.serial is int or value.serial<1 or value.serial>1000000:return false
	if not value.contract is String or value.contract.is_empty() or value.contract.length()>100:return false
	if not value.id is String or not Table.ROWS.has(value.id):return false
	# Validate the seeded identity even while the feature is switched off.
	var rng=RandomNumberGenerator.new();rng.seed=value.seed+value.serial+int(value.contract.hash())
	return value.id==Table.ROWS.keys()[rng.randi_range(0,Table.ROWS.size()-1)]
static func policy(assignment:Dictionary)->Dictionary:
	return Catalog.RULES[assignment.id].duplicate(true) if valid(assignment) and not assignment.is_empty() and Table.enabled else {}
static func bonus_text(assignment:Dictionary)->String:
	if assignment.is_empty():return "NONE"
	var row=Table.ROWS[assignment.id]
	return "+%d CLIENT STANDING"%row.standing if row.standing else Economy.fmt(row.pay)
static func description(assignment:Dictionary,bonus:String="")->String:
	if assignment.is_empty():return "OPTIONAL RIDER · NONE"
	var condition=Catalog.description({"rule":assignment.id})
	# The shared rules include all current finite tools; legacy challenge copy names four.
	if assignment.id=="no_tools":condition="Use no finite tool charges."
	if assignment.id=="one_tool":condition="Use at most one finite tool charge."
	return "OPTIONAL RIDER · %s Bonus %s. Failure forfeits only this bonus."%[condition,bonus_text(assignment) if bonus.is_empty() else bonus]
static func earned(assignment:Dictionary,result:Dictionary)->bool:
	return Table.enabled and valid(assignment) and not assignment.is_empty() and result.get("assignment",{})==assignment and result.get("passed",false)==true
