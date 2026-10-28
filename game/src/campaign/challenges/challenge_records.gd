extends RefCounted
# The challenge profile field "challenges" holds best, last and attempt count.
# Unknown short ids remain readable when a row is removed. Results contain own-state data only.
# ChallengeArchive persists these separately from the campaign.
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const MAX_RECORDS=128
const MAX_ATTEMPTS=1000000000
# Route pars (handoff 059). A row with "route_pars" scores a result against the par of the route it took
# (result.route, read from mission state by ChallengeRun) and keeps a best per route beside the overall best.
# Revert: set ROUTE_PARS_ENABLED false; every row then scores against row.par and no route bests are written.
const ROUTE_PARS_ENABLED=true
const MAX_ROUTES=8
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
	if value.has("route") and (not value.route is String or value.route.length()>32):return false
	return true
static func valid_routes(value)->bool:
	if not value is Dictionary or value.size()>MAX_ROUTES:return false
	for route in value:
		if not route is String or route.is_empty() or route.length()>32:return false
		if not valid_result(value[route]) or value[route].loss:return false
	return true
static func valid(value)->bool:
	if not value is Dictionary or value.size()>MAX_RECORDS:return false
	for id in value:
		if not id is String or id.is_empty() or id.length()>64:return false
		var row=value[id]
		if not row is Dictionary or not row.has_all(["attempts","last","best"]):return false
		if not row.attempts is int or row.attempts<1 or row.attempts>MAX_ATTEMPTS or not valid_result(row.last):return false
		if not row.best is Dictionary or (not row.best.is_empty() and (not valid_result(row.best) or row.best.loss)):return false
		if row.has("routes") and not valid_routes(row.routes):return false
	return true
static func tools_used(result:Dictionary)->int:
	var total=0
	for count in result.get("tools_used",{}).values():total+=int(count)
	return total
static func par_for(row:Dictionary,result:Dictionary)->Dictionary:
	var table=row.get("route_pars",{}).get("pars",{})
	var route=str(result.get("route",""))
	return table[route] if ROUTE_PARS_ENABLED and table.has(route) else row.par
static func pars(row:Dictionary,result:Dictionary)->int:
	if result.is_empty() or result.get("loss",true):return 0
	var par=par_for(row,result)
	return int(result.time<=par.time)+int(result.hull>=par.hull)+int(tools_used(result)<=par.tools)
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
	var route=str(result.get("route",""))
	if ROUTE_PARS_ENABLED and not result.loss and not route.is_empty():
		var routes=row.get("routes",{}).duplicate(true)
		if (routes.has(route) or routes.size()<MAX_ROUTES) and better(definition,result,routes.get(route,{})):routes[route]=result.duplicate(true)
		row.routes=routes
	out[id]=row
	return out
static func route_lines(row:Dictionary,entry:Dictionary)->Array:
	var lines=[]
	if not ROUTE_PARS_ENABLED:return lines
	var table=row.get("route_pars",{}).get("pars",{});var routes=entry.get("routes",{})
	for route in table:
		var par=table[route]
		lines.append("%s PAR %02d:%02d · BEST %s"%[route.to_upper(),int(par.time)/60,int(par.time)%60,summary(routes.get(route,{}))])
	return lines
static func route_tag(result:Dictionary)->String:
	var route=result.get("route","")
	return " · "+route.to_upper() if route is String and not route.is_empty() else ""
static func summary(result:Dictionary)->String:
	if result.is_empty():return "No successful recovery yet."
	return "%02d:%02d · HULL %d%% · TOOLS %d · CRAFT LOST %d"%[int(result.time)/60,int(result.time)%60,roundi(result.hull),tools_used(result),result.get("lost_craft",0)]+route_tag(result)
