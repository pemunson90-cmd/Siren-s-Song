extends RefCounted
# The challenge profile field "challenges" holds best, last and attempt count.
# Unknown short ids remain readable when a row is removed. Results contain own-state data only.
# ChallengeArchive persists these separately from the campaign.
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const MAX_RECORDS=128
const MAX_ATTEMPTS=1000000000
static func number(value,low:float,high:float)->bool:
	return (value is int or value is float) and is_finite(float(value)) and value>=low and value<=high
static func valid_result(value)->bool:
	if not value is Dictionary or not value.has_all(["time","hull","tools_used","loss"]):return false
	if not number(value.time,0.,86400.) or not number(value.hull,0.,100.) or not value.loss is bool:return false
	if not value.tools_used is Dictionary or value.tools_used.size()>16:return false
	for key in value.tools_used:
		if not key is String or key.length()>32 or not value.tools_used[key] is int or value.tools_used[key]<0 or value.tools_used[key]>999:return false
	if value.has("lost_craft") and (not value.lost_craft is int or value.lost_craft<0 or value.lost_craft>3):return false
	if value.has("loud_time") and not number(value.loud_time,0.,86400.):return false
	return true
static func valid(value)->bool:
	if not value is Dictionary or value.size()>MAX_RECORDS:return false
	for id in value:
		if not id is String or id.is_empty() or id.length()>64:return false
		var row=value[id]
		if not row is Dictionary or not row.has_all(["attempts","last","best"]):return false
		if not row.attempts is int or row.attempts<1 or row.attempts>MAX_ATTEMPTS or not valid_result(row.last):return false
		if not row.best is Dictionary or (not row.best.is_empty() and (not valid_result(row.best) or row.best.loss)):return false
	return true
static func tools_used(result:Dictionary)->int:
	var total=0
	for count in result.get("tools_used",{}).values():total+=int(count)
	return total
static func pars(row:Dictionary,result:Dictionary)->int:
	if result.is_empty() or result.get("loss",true):return 0
	return int(result.time<=row.par.time)+int(result.hull>=row.par.hull)+int(tools_used(result)<=row.par.tools)
static func better(row:Dictionary,result:Dictionary,best:Dictionary)->bool:
	if best.is_empty():return true
	var score=pars(row,result);var previous=pars(row,best)
	if score!=previous:return score>previous
	if not is_equal_approx(result.time,best.time):return result.time<best.time
	if not is_equal_approx(result.hull,best.hull):return result.hull>best.hull
	if result.get("lost_craft",0)!=best.get("lost_craft",0):return result.get("lost_craft",0)<best.get("lost_craft",0)
	return tools_used(result)<tools_used(best)
static func add(records:Dictionary,id:String,result:Dictionary)->Dictionary:
	var out=records.duplicate(true);var definition=Catalog.get_challenge(id)
	if definition.is_empty() or not valid_result(result):return out
	var row=out.get(id,{"attempts":0,"last":{},"best":{}})
	row.attempts=mini(MAX_ATTEMPTS,int(row.attempts)+1);row.last=result.duplicate(true)
	if not result.loss and better(definition,result,row.best):row.best=result.duplicate(true)
	out[id]=row
	return out
static func summary(result:Dictionary)->String:
	if result.is_empty():return "No successful recovery yet."
	return "%02d:%02d · HULL %d%% · TOOLS %d · CRAFT LOST %d"%[int(result.time)/60,int(result.time)%60,roundi(result.hull),tools_used(result),result.get("lost_craft",0)]
