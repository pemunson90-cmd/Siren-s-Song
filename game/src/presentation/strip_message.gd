extends RefCounted
# The message the status strip shows (critic 14 Nov: after a route order the strip kept "QUIETUS · set route"
# while the craft was already under way, and for tens of seconds afterwards). The newest message is shown whole
# while it is new, MESSAGE_FRESH_SECONDS of dive time. After that the selected craft says what it is doing now:
# under way to point N and how far, or, for a route message only, that it is at rest with no route. Any other
# message stays until a newer one replaces it. Reads the dive; changes no rule and no saved value.
const Words=preload("res://src/presentation/hud_words.gd")
const RouteProgram=preload("res://src/simulation/route_program.gd")
var text:=""
var at:=0.0
var mission=null
var clock:=-1.0
# Per craft: the last point of its plan (a new one is a new order) and how many points the order had.
var order_end:Dictionary={}
var order_size:Dictionary={}
func current(sim)->String:
	if not is_same(mission,sim.mission) or sim.elapsed<clock:
		mission=sim.mission;order_end.clear();order_size.clear();text="";at=sim.elapsed
	clock=sim.elapsed
	var renewed:bool=sim.message!=text
	for i in sim.units.size():
		var goals:Array=RouteProgram.goals(sim.units[i])
		if goals.is_empty():
			order_end.erase(i);order_size.erase(i);continue
		var end:Vector2=goals.back().pos
		if order_end.get(i)!=end:order_end[i]=end;order_size[i]=goals.size();renewed=true
		else:order_size[i]=maxi(int(order_size.get(i,0)),goals.size())
	if renewed:text=sim.message;at=sim.elapsed
	if sim.elapsed-at<Words.MESSAGE_FRESH_SECONDS or not sim.outcome.is_empty():return sim.message
	var id:int=sim.selected;var u=sim.units[id]
	if not u.alive or not str(u.get("hold","")).is_empty():return sim.message
	if not u.route.is_empty():
		if u.vel.length()<=Words.MOVING_SPEED:return sim.message
		var goals:Array=RouteProgram.goals(u)
		var number:int=maxi(1,int(order_size.get(id,goals.size()))-goals.size()+1)
		return Words.TEXT.under_way%[str(u.name),number,roundi(_to_next_point(u))]
	if Words.is_route_message(sim.message) and u.vel.length()<=Words.MOVING_SPEED:return Words.TEXT.at_rest%str(u.name)
	return sim.message
# The way left to the next point the player placed: through the route's own bends, to the first node marked as a point.
func _to_next_point(u:Dictionary)->float:
	var total:=0.0;var from:Vector2=u.pos
	for node in u.route:
		total+=from.distance_to(node.pos);from=node.pos
		if node.get("goal",false):break
	return total
