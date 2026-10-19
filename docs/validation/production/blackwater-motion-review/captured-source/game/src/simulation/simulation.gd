extends RefCounted
const Missions = preload("res://src/campaign/missions.gd")
const STEP := 1.0/60.0
const TILE := 40.0
const BOUNDS := Vector2(1600,960)
var mission: Dictionary
var units: Array = []
var sirens: Array = []
var known: Dictionary = {}
var contacts: Dictionary = {}
var events: Array = []
var noises: Array = []
var elapsed := 0.0
var oxygen := 100.0
var hull := 100.0
var paused := true
var selected := 0
var queue_mode := false
var pass_through := true
var outcome := ""
var message := "Chart loaded. Tap water to plot a route; unpause when ready."
var tools := {"emp":2,"decoy":3,"recon":2}
var ping_time := 0.0
var ping_origin := Vector2.ZERO
var recon_time := 0.0
var capture_time := 0.0
var capture_unit := -1
var capture_target := -1
var accumulator := 0.0
var sensor_clock := 0.0
var navigation: AStarGrid2D
var rock_shapes: Array=[]
func start(index: int, upgrade: String = "endurance") -> void:
	mission = Missions.make(index)
	units.clear()
	for i in 3:
		units.append({"pos":Vector2(140,800)+[Vector2.ZERO,Vector2(0,-100),Vector2(140,0)][i],"vel":Vector2.ZERO,"angle":-0.3,"route":[],"alive":true,"hold":"","silent":true,"battery":100.0,"name":["QUIETUS","DRONE A","DRONE B"][i]})
	sirens = mission.sirens.duplicate(true)
	known = {}; contacts = {}; events = []; noises = []
	elapsed=0.0; oxygen=100.0; hull=100.0; paused=true; selected=0; queue_mode=false; pass_through=true; outcome=""
	ping_time=0.0; recon_time=0.0; capture_time=0.0; capture_unit=-1; capture_target=-1; accumulator=0.0
	tools={"emp":2,"decoy":3,"recon":2}
	if upgrade=="disruption": tools.emp += 1
	if upgrade=="survey": tools.recon += 1
	if upgrade=="endurance": oxygen=120.0
	_build_navigation()
	_observe()
func _build_navigation() -> void:
	rock_shapes.clear()
	for rock in mission.rocks: rock_shapes.append(rock_polygon(rock))
	navigation = AStarGrid2D.new()
	navigation.region = Rect2i(0,0,40,24)
	navigation.cell_size=Vector2(TILE,TILE)
	navigation.offset=Vector2(20,20)
	navigation.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	navigation.update()
	for y in 24:
		for x in 40:
			if blocked(Vector2(x*40+20,y*40+20),21): navigation.set_point_solid(Vector2i(x,y))
func blocked(p: Vector2, radius: float = 12.0) -> bool:
	if p.x<radius or p.y<radius or p.x>BOUNDS.x-radius or p.y>BOUNDS.y-radius: return true
	for structure in mission.get("structures",[]):
		if structure.grow(radius).has_point(p): return true
	for polygon in rock_shapes:
		if Geometry2D.is_point_in_polygon(p,polygon): return true
		for n in polygon.size():
			if Geometry2D.get_closest_point_to_segment(p,polygon[n],polygon[(n+1)%polygon.size()]).distance_to(p)<radius: return true
	return false
func line_clear(a: Vector2,b: Vector2) -> bool:
	var shapes=rock_shapes.duplicate()
	for structure in mission.get("structures",[]): shapes.append(PackedVector2Array([structure.position,Vector2(structure.end.x,structure.position.y),structure.end,Vector2(structure.position.x,structure.end.y)]))
	for corners in shapes:
		if Geometry2D.is_point_in_polygon(a,corners) or Geometry2D.is_point_in_polygon(b,corners): return false
		for n in corners.size():
			if Geometry2D.segment_intersects_segment(a,b,corners[n],corners[(n+1)%corners.size()]) != null: return false
	return true
func path(a: Vector2, b: Vector2) -> Array:
	var result: Array=[]
	if blocked(b,24): return result
	if blocked(a,24): return _near_wall_recovery(a,b)
	if segment_safe(a,b,24): return [{"pos":b,"stop":true}]
	var first=nearest_navigation_cell(a)
	var last=nearest_navigation_cell(b)
	if first.x<0 or last.x<0: return result
	var grid_path=navigation.get_point_path(first,last)
	var raw: Array=[]
	for n in range(1,grid_path.size()): raw.append(grid_path[n])
	if raw.is_empty(): return result
	raw.append(b)
	var origin=a; var at=0
	while at<raw.size():
		var furthest=at
		for n in range(at+1,raw.size()):
			if segment_safe(origin,raw[n],24): furthest=n
		result.append({"pos":raw[furthest],"stop":furthest==raw.size()-1})
		origin=raw[furthest]; at=furthest+1
	return result
func _near_wall_recovery(origin: Vector2,destination: Vector2) -> Array:
	# Inertia can leave a legal 12m hull inside the 24m routing comfort margin.
	# Escape locally with increasing clearance; retain normal margins after entry.
	if blocked(origin,12): return []
	var candidates: Array=[]
	for radius in [40.0,80.0]:
		for n in 16:
			var entry=origin+Vector2.from_angle(n*TAU/16)*radius
			if blocked(entry,24): continue
			var count=int(ceil(radius/5.0)); var safe=true
			for step in range(1,count+1):
				var fraction=float(step)/count
				if blocked(origin.lerp(entry,fraction),lerpf(12,24,fraction)): safe=false; break
			if safe: candidates.append({"pos":entry,"cost":radius+entry.distance_to(destination)})
	candidates.sort_custom(func(a,b): return a.cost<b.cost)
	for candidate in candidates:
		var onward=path(candidate.pos,destination)
		if not onward.is_empty():
			var route: Array=[{"pos":candidate.pos,"stop":true}]; route.append_array(onward); return route
	return []
func command(order: String,args: Dictionary={}) -> bool:
	if not outcome.is_empty(): return false
	var u=units[selected]
	if not u.alive and order!="select":
		selected=0; queue_mode=false; message="Selected drone lost. Quietus selected; reissue the order."; return false
	match order:
		"select":
			var id=int(args.get("unit",0))
			if id<0 or id>=units.size() or not units[id].alive: return false
			selected=id; queue_mode=false
			message="%s selected · next tap replaces route" % units[id].name
		"waypoint_mode": pass_through=not pass_through; message="Queued waypoints PASS through" if pass_through else "Queued waypoints STOP before continuing"
		"queue": queue_mode=not queue_mode; message="QUEUE: tap to add" if queue_mode else "REPLACE: tap to set route"
		"route", "emergency":
			var append=queue_mode and order!="emergency"
			var origin=u.route.back().pos if append and not u.route.is_empty() else u.pos
			var route=path(origin,args.get("point",origin))
			if route.is_empty(): message="Rock or unsafe clearance. Choose open water."; return false
			if not append:
				u.route.clear(); u.hold=""
				if capture_unit==selected: capture_unit=-1
			elif not u.route.is_empty(): u.route.back().stop=not pass_through
			u.route.append_array(route)
			if order=="emergency": queue_mode=false; u.silent=false
			message="%s · %s route" % [u.name,"queued" if append else "replaced"]
		"hold": u.hold="" if u.hold=="HOLD" else "HOLD"; message="Holding position" if u.hold!="" else "Route released"
		"contact_hold": u.hold="" if u.hold=="CONTACT" else "CONTACT"; message="Will hold when a contact is observed"
		"wait_drone": u.hold="" if u.hold=="DRONE" else "DRONE"; message="Wait until a live drone reaches its final waypoint"
		"silent": u.silent=not u.silent; message="Silent running" if u.silent else "Cruise thrust · increased noise"
		"ping":
			if ping_time>0: return false
			ping_time=3.5; ping_origin=u.pos; _noise(u.pos,950,"ACTIVE SONAR"); events.append({"type":"ping","pos":u.pos}); message="Active return · your position is audible"
			_observe()
			if mission.get("blackwater_revision",0)==1:
				var answered=false
				for target in mission.objectives:
					if not target.captured and u.pos.distance_to(target.pos)<240 and line_clear(u.pos,target.pos):
						target.replay_until=elapsed+3.0;answered=true
				if answered:message="SONAR emitted · local relay replay 3s · settle and SAMPLE"
		"recon":
			if tools.recon<=0: return false
			tools.recon-=1; recon_time=8.0; _noise(u.pos,1100,"RECON UPLINK"); message="Wide survey uplink · 8 seconds"; events.append({"type":"recon","pos":u.pos}); _observe()
		"emp":
			if tools.emp<=0: return false
			tools.emp-=1
			for s in sirens:
				if s.pos.distance_to(u.pos)<340: s.stun=12.0; s.lock=0.0; s.target=-1; s.mode="DISRUPTED"
			_noise(u.pos,650,"DISRUPTION"); message="Disruption pulse · 12 second recovery window"; events.append({"type":"emp","pos":u.pos})
		"decoy":
			if tools.decoy<=0: return false
			tools.decoy-=1; _noise(args.get("point",u.pos+Vector2(160,0)),1100,"DECOY",15.0); message="Decoy launched · 15s transmission"; events.append({"type":"decoy","pos":u.pos})
		"camera":
			var context=camera_context()
			if not context.ready: message=context.text; return false
			var target=mission.objectives[context.target]
			capture_unit=selected; capture_target=context.target; capture_time=0.0; u.hold="HOLD"
			message="%s · hold %.0f seconds"%["Hydrophone reception" if target.get("kind","")=="exchange" else ("Passive hydrophone decode" if target.get("kind","")=="receiver" else ("Archive uplink" if target.get("kind","")=="uplink" else "Camera exposure")),target.get("duration",4.0)]
			if target.get("kind","") not in ["receiver","exchange"]: _noise(u.pos,520,"CAMERA")
			events.append({"type":"camera","pos":u.pos})
		_: return false
	return true
# Read-only receiver geometry. Relay reply is authored local behavior; no enemy query.
func blackwater_context(target:int,station:int=-1) -> Dictionary:
	if station<0:station=selected
	var u=units[station];var o=mission.objectives[target]
	var radius=(240.0 if station==0 else 330.0)*(0.65 if mission.darkness else 1.0)
	var distance=u.pos.distance_to(o.pos);var clear=line_clear(u.pos,o.pos)
	var replay=maxf(0.0,o.get("replay_until",0.0)-elapsed) if u.alive and clear and distance<240 else 0.0
	return {"distance":distance,"quiet_range":radius,"clear":clear,"quiet":u.alive and clear and distance<radius,"replay":replay,"ready":u.alive and clear and (distance<radius or replay>0),"settled":u.vel.length()<2}
func _blackwater_context_text(target:int,station:int) -> String:
	var c=blackwater_context(target,station);var name=mission.objectives[target].name
	if not c.clear:return "%s · cover blocks reception"%name
	if c.replay>0:return "%s · LOCAL REPLAY %.1fs · SAMPLE 2s"%[name,c.replay]
	if c.quiet:return "%s · quiet receiver ready · SAMPLE 2s"%name
	var learned=mission.objectives.any(func(o):return o.captured)
	return "%s · %dm / quiet%.0fm%s"%[name,c.distance,c.quiet_range," · learned: SONAR + SAMPLE within240m" if learned else " · move closer to listen"]
func camera_context() -> Dictionary:
	if capture_unit>=0:
		var active=mission.objectives[capture_target]
		if active.get("kind","")=="exchange":
			var c=blackwater_context(capture_target,capture_unit)
			return {"target":capture_target,"ready":false,"text":"%s · %s · %s %.1f/2s"%[units[capture_unit].name,active.name,"receiving" if c.settled else "settling",capture_time]}
		return {"target":capture_target,"ready":false,"text":"%s · %s %.1f / %.0fs"%[units[capture_unit].name,active.name,capture_time,active.get("duration",4.0)]}
	var unit=units[selected]; var best=-1; var nearest=-1; var distance=INF
	for id in mission.objectives.size():
		var objective=mission.objectives[id]
		if objective.captured: continue
		var d:float=unit.pos.distance_to(objective.pos)
		if d<distance: nearest=id; distance=d
		if best<0 and d<240 and line_clear(unit.pos,objective.pos): best=id
	if nearest<0: return {"target":-1,"ready":false,"text":"Archive aboard · return Quietus to extraction."}
	if mission.get("blackwater_revision",0)==1:
		var id=best if best>=0 else nearest
		return {"target":id,"ready":blackwater_context(id).ready,"text":_blackwater_context_text(id,selected)}
	if best<0:
		var target=mission.objectives[nearest]
		return {"target":nearest,"ready":false,"text":"%s · %dm away / 240m range%s"%[target.name,roundi(distance)," · view blocked by cover" if not line_clear(unit.pos,target.pos) else ""]}
	var target=mission.objectives[best]
	if target.get("required_unit",selected)!=selected:
		return {"target":best,"ready":false,"text":target.get("unit_requirement","Quietus must operate the archive uplink. Bring the submarine to this anchor.")}
	for prerequisite in target.get("requires",[]):
		if not mission.objectives[prerequisite].captured:
			return {"target":best,"ready":false,"text":target.get("requirement","Uplink needs both relay records. Photograph WEST and EAST first.")}
	return {"target":best,"ready":true,"text":"READY · %s · %s %.0fs"%[target.name,"passive listen" if target.get("kind","")=="receiver" else "exposure",target.get("duration",4.0)]}
func _noise(p: Vector2,radius: float,label: String,duration: float=2.0) -> void:
	noises.append({"pos":p,"radius":radius,"time":duration,"label":label})
# Own known emissions only. Reception and enemy reaction remain sensor evidence.
# Derive from existing clocks so pause/restore need no extra lifetime state.
func acoustic_feedback() -> Dictionary:
	var result={"motion":[],"pulses":[],"responses":[]}
	for u in units:
		# Match actual movement hearing, including residual speed after SILENT.
		if u.alive and u.vel.length()>50:
			result.motion.append({"name":u.name,"pos":u.pos})
	for n in noises:
		if n.time<=0: continue
		if n.label in ["DECOY","ACTIVE SONAR","RECON UPLINK","DISRUPTION","CAMERA"]:
			result.pulses.append({"label":n.label,"pos":n.pos,"time":n.time})
		elif n.label=="FACTORY RESPONSE" and visible(n.pos):
			result.responses.append({"label":n.label,"pos":n.pos,"time":n.time})
	return result
func advance(dt: float) -> void:
	if paused or not outcome.is_empty(): return
	accumulator+=minf(dt,0.25)
	while accumulator+0.0000001>=STEP:
		_tick(STEP); accumulator-=STEP
func _tick(dt: float) -> void:
	elapsed+=dt; oxygen=maxf(0,oxygen-dt/18.0)
	if mission.get("phase","")=="response": mission.response_time=mission.get("response_time",0.0)+dt
	ping_time=maxf(0,ping_time-dt); recon_time=maxf(0,recon_time-dt)
	for n in noises: n.time-=dt
	noises=noises.filter(func(n): return n.time>0)
	for i in units.size():
		var u=units[i]
		if not u.alive: continue
		var holding=u.hold=="HOLD" or (u.hold=="CONTACT" and has_live_contact())
		if u.hold=="DRONE":
			holding=false
			for j in [1,2]:
				if units[j].alive and not units[j].route.is_empty(): holding=true
		_move(u,dt,(42.0 if u.silent else 78.0) if i==0 else 96.0,holding)
		if i>0:
			u.battery=maxf(0,u.battery-dt/14.0)
			if u.battery<=0: u.alive=false; events.append({"type":"loss","pos":u.pos}); message="%s battery exhausted. Quietus camera remains available."%u.name
	_threats(dt)
	sensor_clock-=dt
	if sensor_clock<=0:
		_observe(); sensor_clock=0.15
	if capture_unit>=0:
		var u=units[capture_unit]; var o=mission.objectives[capture_target]
		var exchange=o.get("kind","")=="exchange" and mission.get("blackwater_revision",0)==1
		var receiver=blackwater_context(capture_target,capture_unit) if exchange else {}
		if not u.alive or (exchange and not receiver.ready) or (not exchange and (u.pos.distance_to(o.pos)>240 or not line_clear(u.pos,o.pos))):
			capture_unit=-1
			if exchange:capture_time=0.0
			message="Reception interrupted · move closer or SONAR for a local replay" if exchange else "Exposure interrupted · regain clear view"
		elif exchange and not receiver.settled:capture_time=0.0
		else:
			capture_time+=dt
			if capture_time+(0.0000001 if exchange else 0.0)>=o.get("duration",4.0):
				if exchange:capture_time=o.duration
				o.captured=true; u.hold=""; capture_unit=-1; _record_secured(o)
	if not units[selected].alive:
		selected=0; queue_mode=false; message="Drone lost · Quietus command restored. Submarine camera remains available."
	if oxygen<=0: outcome="lost"; message="Life support exhausted. The archive is silent."
	if hull<=0: outcome="lost"; message="Quietus lost. Your previous campaign records remain safe."
	if all_records() and units[0].pos.distance_to(mission.extraction)<65 and units[0].vel.length()<12:
		outcome="won"; paused=true; message="Archive recovered. Quietus is home."; events.append({"type":"extraction","pos":units[0].pos})
func _move(u: Dictionary,dt: float,speed: float,holding: bool,report_collision: bool=true) -> void:
	var desired=Vector2.ZERO
	if not u.route.is_empty() and not holding:
		var dest=u.route[0]
		var delta:Vector2=dest.pos-u.pos
		var arrival=9.0 if dest.stop else 11.0
		if not dest.stop and u.route.size()>1 and delta.length()<28 and segment_safe(u.pos,u.route[1].pos,24): arrival=28.0
		if delta.length()<arrival:
			if dest.stop and u.vel.length()>2:
				u.vel=u.vel.move_toward(Vector2.ZERO,100*dt)
				var braking:Vector2=u.pos+u.vel*dt
				if not blocked(braking,12): u.pos=braking
				return
			u.route.pop_front()
			if dest.stop: u.vel=u.vel.move_toward(Vector2.ZERO,120*dt)
		if not u.route.is_empty():
			delta=u.route[0].pos-u.pos
			var target_speed=speed
			if u.route[0].stop: target_speed=minf(speed,sqrt(maxf(0,delta.length()-4)*70))
			var target_angle=delta.angle()
			var turn=absf(angle_difference(u.angle,target_angle))
			if turn>0.3: target_speed=minf(target_speed,28.0+35.0*maxf(0,cos(turn)))
			if turn>0.15 and blocked(u.pos,24): target_speed=0.0 # Thruster-turn away before a near-wall restart.
			if u.route.size()>1:
				var next_direction:Vector2=u.route[1].pos-u.route[0].pos
				var corner=absf(delta.angle_to(next_direction))
				if corner>0.3: target_speed=minf(target_speed,20+sqrt(delta.length()*35))
			u.angle=rotate_toward(u.angle,target_angle,1.8*dt)
			desired=Vector2.from_angle(u.angle)*target_speed
	u.vel=u.vel.move_toward(desired,42*dt)
	var next:Vector2=u.pos+u.vel*dt
	if not blocked(next,12): u.pos=next
	else:
		u.vel=Vector2.ZERO; u.route.clear()
		if report_collision: message="Autopilot stopped at unsafe terrain. Replot in open water."
func _observe() -> void:
	for y in 24:
		for x in 40:
			var p=Vector2(x*40+20,y*40+20)
			if visible(p): known[Vector2i(x,y)]=true
	for i in sirens.size():
		if visible(sirens[i].pos): contacts[i]={"pos":sirens[i].pos,"time":elapsed,"mode":sirens[i].mode,"lock":sirens[i].lock,"angle":sirens[i].angle,"target":sirens[i].target,"type":sirens[i].get("type","patroller")}
	var expired: Array=[]
	for i in contacts:
		if elapsed-contacts[i].time>20: expired.append(i)
	for i in expired: contacts.erase(i)
func visible(p: Vector2) -> bool:
	if recon_time>0: return true
	for i in units.size():
		var u=units[i]
		if not u.alive: continue
		var radius=240.0 if i==0 else 330.0
		if mission.darkness: radius*=0.65
		if u.pos.distance_to(p)<radius and line_clear(u.pos,p): return true
	if ping_time>0 and ping_origin.distance_to(p)<650 and line_clear(ping_origin,p): return true
	return false
func _threats(dt: float) -> void:
	for s in sirens:
		if s.stun>0:
			s.stun-=dt; s.lock=0.0; s.target=-1; s.mode="DISRUPTED"; continue
		var detected := -1
		var heard := false
		s["attention_time"]=maxf(0.0,float(s.get("attention_time",0.0))-dt)
		for i in units.size():
			var u=units[i]
			if not u.alive: continue
			var dist=s.pos.distance_to(u.pos)
			var radius=180.0 if u.silent else 290.0
			if dist<radius and line_clear(s.pos,u.pos): detected=i; break
			if u.vel.length()>50 and dist<430:
				s.goal=u.pos; heard=true; s.mode="INVESTIGATE"; s.suspicion=maxf(s.suspicion,0.3)
		for noise in noises:
			var acoustic=1.0 if line_clear(s.pos,noise.pos) else 0.36
			if s.pos.distance_to(noise.pos)<noise.radius*acoustic:
				s.goal=noise.pos; heard=true; s.mode="INVESTIGATE"; s.suspicion=maxf(s.suspicion,0.45)
		if heard:
			s["last_known"]=s.goal; s["attention_time"]=12.0; s["search_index"]=0
		if detected>=0:
			if s.target!=detected: s.lock=0.0
			if s.get("type","patroller")=="patroller": s.route.clear()
			else: _visual_pursuit(s,units[detected].pos,dt)
			if s.route.is_empty(): s.angle=rotate_toward(s.angle,s.pos.angle_to_point(units[detected].pos),1.8*dt)
			var previous_lock:float=s.lock
			s.target=detected; s.goal=units[detected].pos; s["last_known"]=s.goal; s["attention_time"]=12.0; s["search_index"]=0; s.lock+=dt; s.suspicion=minf(1,s.suspicion+dt*0.3); s.mode="LOCKING" if s.lock<4 else "BEAM"
			if s.lock>=4:
				if previous_lock<4: events.append({"type":"beam","pos":units[detected].pos})
				if detected==0: hull=maxf(0,hull-dt*18)
				else: units[detected].alive=false; s.lock=0; events.append({"type":"loss","pos":units[detected].pos}); message="%s lost · submarine camera remains available"%units[detected].name
		else:
			s.target=-1; s.lock=maxf(0,s.lock-dt*3); s.suspicion=maxf(0,s.suspicion-dt*0.015)
			if s.get("type","patroller")!="patroller":
				_station_intent(s,heard,dt)
			else:
				if s.pos.distance_to(s.goal)<35:
					s.mode="SEARCH" if s.suspicion>0.1 else "PATROL"
					s.route=_patrol_route(s); s.path_time=2.0
				s.path_time-=dt
				if s.path_time<=0:
					s.route=path(s.pos,s.goal)
					if s.route.is_empty() and s.pos.distance_to(s.goal)>=35:
						# Preserve investigation intent at a reachable edge of a heard point.
						if s.mode=="INVESTIGATE": s.route=_search_approach(s)
						if s.route.is_empty():
							s.mode="SEARCH" if s.suspicion>0.1 else "PATROL"; s.route=_patrol_route(s)
					s.path_time=2.0
		var speed=48.0 if s.suspicion>0.1 else 25.0
		if s.get("type","")=="hunter": speed=38.0 if s.mode in ["RETURN","DORMANT"] else 64.0
		_move(s,dt,speed,false,false)

func _visual_pursuit(s: Dictionary,target: Vector2,dt: float) -> void:
	# Port station-role pursuit without the v7 straight-line overlap. The beam's
	# independent four-second lock still requires current sight on every tick.
	if s.pos.distance_to(target)<=205:
		s.route.clear(); return
	s.path_time-=dt
	if s.path_time<=0 or s.route.is_empty():
		var approach=target+target.direction_to(s.pos)*180.0
		s.route=path(s.pos,approach) if line_clear(approach,target) else []
		s.path_time=0.3

func _station_intent(s: Dictionary,heard: bool,dt: float) -> void:
	# v7 station roles react to evidence, then return. Tether is conditional,
	# never an invisible wall that defeats a currently heard lure or visual lock.
	var outside=s.pos.distance_to(s.home)>float(s.get("tether",190.0))
	var returning=s.get("attention_time",0.0)<=0 or (s.get("type","")=="sentinel" and outside and not heard)
	if returning:
		s["attention_time"]=0.0; s.goal=s.home
		s.mode="DORMANT" if s.pos.distance_to(s.home)<15 else "RETURN"
		if s.mode=="DORMANT": s.route.clear(); return
	elif s.pos.distance_to(s.goal)<35:
		s.mode="SEARCH"
		# Search the observed area, never the pilot's now-hidden location.
		if not heard:
			var center:Vector2=s.get("last_known",s.goal)
			for attempt in 8:
				var index=int(s.get("search_index",0)); s["search_index"]=index+1
				var point=center+Vector2.from_angle(index*TAU/8)*80.0
				if not path(s.pos,point).is_empty(): s.goal=point; break
	s.path_time-=dt
	if s.path_time<=0 or s.route.is_empty() or s.route.back().pos.distance_to(s.goal)>1:
		s.route=path(s.pos,s.goal)
		if s.route.is_empty() and s.pos.distance_to(s.goal)>=35: s.route=_search_approach(s)
		s.path_time=2.0
func _patrol_route(s: Dictionary) -> Array:
	var points: Array=s.get("patrol_points",[])
	for _attempt in points.size():
		var index=int(s.get("patrol_index",0))%points.size()
		s["patrol_index"]=(index+1)%points.size()
		var point:Vector2=points[index]
		if s.pos.distance_to(point)<35: continue
		var route=path(s.pos,point)
		if not route.is_empty(): s.goal=point; return route
	# Legacy archives have no authored points. Validate alternatives instead of
	# retrying a blocked procedural destination forever. Also recover malformed routes.
	var angle=elapsed/19.0+float(s.patrol)
	for ring in [190.0,120.0]:
		for n in 16:
			var point:Vector2=(s.home if ring==190.0 else s.pos)+Vector2.from_angle(angle+n*TAU/16)*ring
			if s.pos.distance_to(point)<75: continue
			var route=path(s.pos,point)
			if not route.is_empty(): s.goal=point; return route
	return []
func _search_approach(s: Dictionary) -> Array:
	var heard:Vector2=s.goal
	for radius in [40.0,80.0,120.0,160.0]:
		for n in 16:
			var point=heard+Vector2.from_angle(n*TAU/16)*radius
			var route=path(s.pos,point)
			if not route.is_empty(): s.goal=point; return route
	return []
func all_records() -> bool:
	for o in mission.objectives:
		if not o.captured: return false
	return true
func snapshot() -> Dictionary:
	return {"mission":mission.duplicate(true),"units":units.duplicate(true),"sirens":sirens.duplicate(true),"known":known.duplicate(true),"contacts":contacts.duplicate(true),"noises":noises.duplicate(true),"elapsed":elapsed,"oxygen":oxygen,"hull":hull,"paused":paused,"selected":selected,"tools":tools.duplicate(),"outcome":outcome,"ping_time":ping_time,"ping_origin":ping_origin,"recon_time":recon_time,"capture_time":capture_time,"capture_unit":capture_unit,"capture_target":capture_target}
func restore(data: Dictionary) -> bool:
	if not valid_snapshot(data): return false
	mission=data.mission.duplicate(true); units=data.units.duplicate(true); sirens=data.sirens.duplicate(true); known=data.known.duplicate(true); contacts=data.get("contacts",{}).duplicate(true); noises=data.get("noises",[]).duplicate(true)
	elapsed=float(data.get("elapsed",0)); oxygen=float(data.get("oxygen",100)); hull=float(data.get("hull",100)); selected=clampi(int(data.get("selected",0)),0,2); tools=data.tools.duplicate(); outcome=data.get("outcome",""); paused=true; queue_mode=false
	ping_time=data.get("ping_time",0.0); ping_origin=data.get("ping_origin",Vector2.ZERO); recon_time=data.get("recon_time",0.0); capture_time=data.get("capture_time",0.0); capture_unit=data.get("capture_unit",-1); capture_target=data.get("capture_target",-1); accumulator=0.0
	_build_navigation(); message="Mission restored · paused for review"; return true

static func valid_snapshot(data: Dictionary) -> bool:
	if not data.has_all(["mission","units","sirens","known","tools"]): return false
	if not data.mission is Dictionary or not data.units is Array or not data.sirens is Array or not data.known is Dictionary or not data.tools is Dictionary: return false
	if not data.mission.has_all(["id","rocks","objectives","extraction","title","darkness","depth"]): return false
	if not data.mission.id is int or data.mission.id<0 or data.mission.id>5: return false
	if not data.mission.rocks is Array or not data.mission.objectives is Array or not data.mission.extraction is Vector2: return false
	for r in data.mission.rocks:
		if not r is Rect2: return false
	if data.mission.has("structures"):
		if not data.mission.structures is Array: return false
		for structure in data.mission.structures:
			if not structure is Rect2: return false
	for o in data.mission.objectives:
		if not o is Dictionary or not o.has_all(["pos","name","captured"]) or not o.pos is Vector2: return false
	if data.mission.has("blackwater_revision"):
		if data.mission.id!=2 or not data.mission.blackwater_revision is int or data.mission.blackwater_revision!=1 or data.mission.objectives.size()!=2:return false
		var time=data.get("elapsed",0.0)
		if not (time is float or time is int) or not is_finite(float(time)) or time<0:return false
		for o in data.mission.objectives:
			if o.get("kind","")!="exchange" or o.get("duration",0)!=2.0:return false
			var until=o.get("replay_until",null)
			if not (until is float or until is int) or not is_finite(float(until)) or until<0 or until>time+3.001:return false
		var station=data.get("capture_unit",-1);var target=data.get("capture_target",-1);var progress=data.get("capture_time",0.0)
		if not station is int or station< -1 or station>2 or not target is int or target< -1 or target>1:return false
		if station>=0 and target<0:return false
		if not (progress is float or progress is int) or not is_finite(float(progress)) or progress<0 or progress>2.01:return false
	if data.units.size()!=3 or not data.tools.has_all(["emp","decoy","recon"]): return false
	for u in data.units:
		if not u is Dictionary or not u.has_all(["pos","vel","angle","route","alive","hold","silent","battery","name"]): return false
		if not u.pos is Vector2 or not u.vel is Vector2 or not u.route is Array: return false
		for w in u.route:
			if not w is Dictionary or not w.has_all(["pos","stop"]) or not w.pos is Vector2: return false
	for e in data.sirens:
		if not e is Dictionary or not e.has_all(["pos","home","goal","vel","route","angle","mode","suspicion","stun","lock","target","patrol","path_time"]): return false
		if e.has("type") and e.type not in ["patroller","sentinel","hunter"]: return false
		if e.has("tether") and (not (e.tether is float or e.tether is int) or e.tether<=0): return false
		if e.has("attention_time") and (not (e.attention_time is float or e.attention_time is int) or e.attention_time<0): return false
		if e.has("last_known") and not e.last_known is Vector2: return false
		if e.has("search_index") and (not e.search_index is int or e.search_index<0): return false
		if e.has("patrol_points"):
			if not e.patrol_points is Array or not e.get("patrol_index",0) is int or e.get("patrol_index",0)<0: return false
			for point in e.patrol_points:
				if not point is Vector2: return false
	return true

static func rock_polygon(r: Rect2) -> PackedVector2Array:
	var normalized=[Vector2(0.18,0.0),Vector2(0.62,0.03),Vector2(0.88,0.0),Vector2(1.0,0.22),Vector2(0.94,0.51),Vector2(1.0,0.78),Vector2(0.79,1.0),Vector2(0.43,0.94),Vector2(0.18,1.0),Vector2(0.0,0.8),Vector2(0.04,0.44),Vector2(0.0,0.2)]
	var result=PackedVector2Array()
	for p in normalized: result.append(r.position+p*r.size)
	return result

func segment_safe(a: Vector2,b: Vector2,clearance: float) -> bool:
	if not line_clear(a,b): return false
	var count=maxi(1,int(ceil(a.distance_to(b)/10.0)))
	for n in range(1,count+1):
		if blocked(a.lerp(b,float(n)/count),clearance): return false
	return true

func has_live_contact() -> bool:
	for contact in contacts.values():
		if elapsed-contact.time<0.3: return true
	return false

func _record_secured(record: Dictionary) -> void:
	events.append({"type":"record","pos":record.pos})
	message="Record secured. Return Quietus to extraction." if all_records() else "Record secured. Continue the survey."
	if mission.get("blackwater_revision",0)==1:
		message="Exchange matched · ancient ocean archive aboard · return Quietus home" if all_records() else ("REQUEST decoded · REPLY accepts SONAR replay within240m; or approach quietly" if record.name=="REQUEST RELAY" else "REPLY decoded · ancient temperatures · REQUEST accepts SONAR replay within240m")
	if mission.id==5 and record.get("kind","")=="receiver":
		mission["phase"]="warning"; message="Warning decoded: deep fracture; outbound hulls are leaving. Bring Quietus and this packet home."
	if mission.id==3:
		message="Furnace record secured. Review recovered evidence in Operations."
		if all_records() and mission.get("phase","")!="response":
			mission["phase"]="response"; mission["response_time"]=0.0
			var origin:Vector2=mission.objectives[1].pos
			_noise(origin,1150,"FACTORY RESPONSE",8.0); events.append({"type":"factory","pos":origin})
			message="The factory answers the camera. Carrier pulse at the departure cradle · plan your recovery route."

func nearest_navigation_cell(point: Vector2) -> Vector2i:
	var center=Vector2i(clampi(int(point.x/40),0,39),clampi(int(point.y/40),0,23))
	var best=Vector2i(-1,-1); var distance=INF
	for y in range(maxi(0,center.y-2),mini(24,center.y+3)):
		for x in range(maxi(0,center.x-2),mini(40,center.x+3)):
			var cell=Vector2i(x,y)
			if navigation.is_point_solid(cell): continue
			var candidate=Vector2(x*40+20,y*40+20)
			var d=candidate.distance_squared_to(point)
			if d<distance and segment_safe(candidate,point,24): best=cell; distance=d
	return best
