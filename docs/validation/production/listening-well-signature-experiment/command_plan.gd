extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
var s
var last_emp=-99.0
var defend=true
var actions=[]
var use_decoy=false
var decoy_spent=false
func order(name:String,args:Dictionary={}):
	var ok=s.command(name,args);actions.append({"time":s.elapsed,"order":name,"args":args,"accepted":ok});return ok
func advance(seconds:float):
	for n in int(round(seconds*60)):
		if not s.outcome.is_empty():return
		s.advance(1.0/60)
		if use_decoy and not decoy_spent and s.units[2].alive and s.units[2].pos.distance_to(Vector2(780,850))<20 and s.units[2].vel.length()<2:
			var station=s.selected;order("select",{"unit":2});order("decoy");order("select",{"unit":station});decoy_spent=true
		if defend and s.elapsed-last_emp>1:
			for c in s.contacts.values():
				if s.elapsed-c.time<.3 and c.lock>1 and c.target>=0 and s.tools.emp>0:
					var unit=s.selected;order("select",{"unit":c.target});order("emp");order("select",{"unit":unit});last_emp=s.elapsed;break
func travel(unit:int,point:Vector2):
	order("select",{"unit":unit})
	if not order("route",{"point":point}):return false
	s.paused=false
	for n in 2400:
		advance(1.0/15)
		if not s.outcome.is_empty():return s.outcome=="won"
		if not s.units[unit].alive:return false
		if s.units[unit].route.is_empty() and s.units[unit].vel.length()<2:return true
	return false
func sample(unit:int):
	order("select",{"unit":unit})
	if not order("camera"):return false
	advance(4.5);return true
func remote(required:bool=false):
	for id in 3:
		var unit=1 if s.units[1].alive else 2
		if not s.units[unit].alive:return
		if not travel(unit,[Vector2(800,390),Vector2(1150,450),Vector2(780,850)][id]):return
		if required and id==2 and s.mission.get("well_observation",{}).is_empty():print("REQUIRED_POLICY withholding final sample: no moving comparison");return
		if not sample(unit):return
func moving(solo:bool=false,covered:bool=false):
	if solo:s.units[1].alive=false;s.units[2].alive=false
	var first=0 if solo else 1
	if not travel(first,Vector2(800,390)):return
	if not sample(first):return
	if not solo:
		order("select",{"unit":1});order("route",{"point":Vector2(420,180)})
		order("select",{"unit":2});order("route",{"point":Vector2(780,850)})
	order("select",{"unit":0});order("silent")
	if not travel(0,Vector2(1150,450)):return
	order("silent")
	if not s.mission.objectives[1].captured and not sample(0):return
	if not solo and s.units[2].alive:
		order("select",{"unit":2});sample(2)
	if not s.mission.objectives[2].captured:
		if not travel(0,Vector2(780,850)):return
		sample(0)
	if covered and s.units[0].pos.y<500:
		order("select",{"unit":0});order("silent")
		if not travel(0,Vector2(1140,380)):return
		if not travel(0,Vector2(800,380)):return
		order("silent")
		if not travel(0,Vector2(400,700)):return
	else:order("select",{"unit":0});order("silent")
	travel(0,s.mission.extraction)
