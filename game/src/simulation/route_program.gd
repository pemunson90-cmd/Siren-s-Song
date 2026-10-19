extends RefCounted
# Operator goals are separate from terrain-avoidance corners. Legacy courses stay
# byte-for-byte intact until an explicit edit/route order requests a new course.
const MODES=["inherit","silent","cruise"]
const MAX_GOALS=32
const MAX_UNDO=8
static func goals(unit:Dictionary) -> Array:
 if unit.has("route_plan"):return unit.route_plan.duplicate(true)
 if unit.route.is_empty():return []
 return [{"pos":unit.route.back().pos,"stop":bool(unit.route.back().stop),"mode":"inherit","legacy":true}]
static func valid_goals(value,world_size:Vector2=Vector2(1600,960)) -> bool:
 if not value is Array or value.size()>MAX_GOALS:return false
 for goal in value:
  if not goal is Dictionary or not goal.has_all(["pos","stop","mode"]):return false
  if not goal.pos is Vector2 or not goal.pos.is_finite() or not goal.stop is bool or goal.mode not in MODES:return false
  if goal.has("legacy") and not goal.legacy is bool:return false
  if goal.has("arrival_set") and not goal.arrival_set is bool:return false
  if goal.pos.x<12 or goal.pos.y<12 or goal.pos.x>world_size.x-12 or goal.pos.y>world_size.y-12:return false
 return true
static func compile(origin:Vector2,plan:Array,pathfinder:Callable,world_size:Vector2=Vector2(1600,960)) -> Dictionary:
 var route:Array=[]
 if not valid_goals(plan,world_size):return {"ok":false}
 for goal in plan:
  var leg:Array=pathfinder.call(origin,goal.pos)
  if leg.is_empty():return {"ok":false}
  for node in leg:node.mode=goal.mode
  leg.back().stop=goal.stop;leg.back().goal=true
  route.append_array(leg);origin=goal.pos
 return {"ok":true,"route":route}
static func valid_unit(unit:Dictionary,quietus:bool=true,world_size:Vector2=Vector2(1600,960)) -> bool:
 if unit.has("route_plan") and not valid_goals(unit.route_plan,world_size):return false
 if not quietus and unit.has("route_plan") and unit.route_plan.any(func(goal):return goal.mode!="inherit"):return false
 if unit.has("route_undo"):
  if not unit.route_undo is Array or unit.route_undo.size()>MAX_UNDO:return false
  for plan in unit.route_undo:
   if not valid_goals(plan,world_size) or (not quietus and plan.any(func(goal):return goal.mode!="inherit")):return false
 var goal_index=0
 for node in unit.route:
  if node.has("mode") and (node.mode not in MODES or (not quietus and node.mode!="inherit")):return false
  if node.has("goal") and not node.goal is bool:return false
  if unit.has("route_plan"):
   if goal_index>=unit.route_plan.size() or node.get("mode","")!=unit.route_plan[goal_index].mode:return false
   if node.get("goal",false):
    var goal=unit.route_plan[goal_index]
    if node.pos!=goal.pos or node.stop!=goal.stop:return false
    goal_index+=1
 if unit.has("route_plan") and goal_index!=unit.route_plan.size():return false
 return true
static func speed(unit:Dictionary,fallback:float,quietus:bool) -> float:
 if unit.route.is_empty():return fallback
 var mode=unit.route[0].get("mode","inherit")
 if mode!="inherit":unit.silent=mode=="silent"
 return (42.0 if unit.silent else 78.0) if quietus else fallback
static func arrived(unit:Dictionary,node:Dictionary) -> void:
 if not node.get("goal",false):return
 if unit.has("route_plan") and not unit.route_plan.is_empty():unit.route_plan.pop_front()
 unit.erase("route_undo")
static func clear(unit:Dictionary) -> void:
 unit.erase("route_plan");unit.erase("route_undo")
