extends RefCounted
# Deliberate static receiver work, not a scripting language. This module reads
# public sites and canonical capture status; it never advances a second clock.
const Sampler=preload("res://src/equipment/field_sampler.gd")
const HOLDS=["","HOLD","CONTACT","DRONE","SCOUT","SCOUT_STOP"]
static func valid_site_id(value)->bool:
 if not value is String or value.is_empty() or value.length()>64:return false
 for character in value:
  if character not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-":return false
 return true
static func valid_goal(goal:Dictionary)->bool:
 return not goal.has("task_site") or (valid_site_id(goal.task_site) and goal.get("stop",false)==true and not goal.get("legacy",false))
static func valid_run(value)->bool:
 if not value is Dictionary:return false
 if value.is_empty():return true
 return value.size()==3 and value.has_all(["site_id","phase","resume_hold"]) and valid_site_id(value.site_id) and value.phase in ["running","blocked"] and value.resume_hold in HOLDS
static func running(site_id:String,resume_hold:String)->Dictionary:
 var run={"site_id":site_id,"phase":"running","resume_hold":resume_hold}
 return run if valid_run(run) else {}
static func interrupted(run:Dictionary)->Dictionary:
 if not valid_run(run) or run.is_empty():return {}
 var result=run.duplicate(true);result.phase="blocked";return result
static func qualify(goal:Dictionary,sites:Array,unit_id:int,fitted:Dictionary)->Dictionary:
 if unit_id not in [0,1,2] or not goal.has("task_site") or not valid_goal(goal) or not goal.get("pos") is Vector2 or not goal.pos.is_finite():return {"ok":false}
 var matches=[]
 for index in sites.size():
  if sites[index] is Dictionary and sites[index].get("site_id","")==goal.task_site:matches.append(index)
 if matches.size()!=1:return {"ok":false}
 var index=matches[0];var site=sites[index]
 if site.get("kind","")!="receiver" or site.get("moving",false)!=false or not site.get("pos") is Vector2 or not site.pos.is_finite() or not site.get("captured") is bool:return {"ok":false}
 if goal.pos.distance_to(site.pos)>=240:return {"ok":false}
 if site.get("required_unit",unit_id)!=unit_id and Sampler.capture_spec(unit_id,fitted,site).is_empty():return {"ok":false}
 return {"ok":true,"index":index,"site_id":goal.task_site}
static func decide(goal:Dictionary,sites:Array,unit:Dictionary,unit_id:int,fitted:Dictionary,context:Dictionary)->Dictionary:
 if not goal.has("task_site"):return {"action":"none"}
 if not context.has_all(["paused","guard_blocked","ready","capture_unit","capture_site"]):return {"action":"blocked","reason":"invalid_context"}
 for key in ["paused","guard_blocked","ready"]:
  if not context[key] is bool:return {"action":"blocked","reason":"invalid_context"}
 if not context.capture_unit is int or context.capture_unit not in [-1,0,1,2] or not context.capture_site is String:return {"action":"blocked","reason":"invalid_context"}
 if context.paused:return {"action":"wait","reason":"paused"}
 var known=qualify(goal,sites,unit_id,fitted)
 if not known.ok:return {"action":"blocked","reason":"unqualified"}
 if unit.get("alive",false)!=true:return {"action":"blocked","reason":"lost"}
 if not unit.get("pos") is Vector2 or not unit.pos.is_finite() or not unit.get("vel") is Vector2 or not unit.vel.is_finite():return {"action":"blocked","reason":"invalid_unit"}
 var run=unit.get("task_run",{})
 if not valid_run(run) or (not run.is_empty() and run.site_id!=goal.task_site):return {"action":"blocked","reason":"invalid_run"}
 if context.guard_blocked:return {"action":"blocked" if not run.is_empty() else "wait","reason":"guard"}
 if unit.pos.distance_to(goal.pos)>=9:return {"action":"wait","reason":"travel"}
 if unit.vel.length()>2:return {"action":"wait","reason":"settle"}
 if sites[known.index].captured:return {"action":"complete","site_id":goal.task_site}
 if not run.is_empty() and run.phase=="blocked":return {"action":"blocked","reason":"interrupted"}
 if context.capture_unit>=0:
  if context.capture_unit==unit_id and context.capture_site==goal.task_site:return {"action":"wait","reason":"working"}
  return {"action":"wait","reason":"channel_busy"}
 if not run.is_empty():return {"action":"blocked","reason":"interrupted"}
 if not context.ready:return {"action":"blocked","reason":"physical_readiness"}
 return {"action":"begin","site_id":goal.task_site,"index":known.index}
