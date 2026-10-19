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
func start(index: int, upgrade: String = "endurance") -> void:
	mission = Missions.make(index)
	units.clear()
	for i in 3:
		units.append({"pos":Vector2(140,800)+[Vector2.ZERO,Vector2(0,-100),Vector2(140,0)][i],"vel":Vector2.ZERO,"angle":-0.3,"route":[],"alive":true,"hold":"","silent":true,"battery":100.0,"name":["QUIETUS","DRONE A","DRONE B"][i]})
	sirens = mission.sirens.duplicate(true)
	known = {}; contacts = {}; events = []; noises = []
	elapsed=0.0; oxygen=100.0; hull=100.0; paused=true; selected=0; queue_mode=false; pass_through=true; outcome=""
	ping_time=0.0; recon_time=0.0; capture_time=0.0; capture_unit=-1; accumulator=0.0
	tools={"emp":2,"decoy":3,"recon":2}
	if upgrade=="disruption": tools.emp += 1
	if upgrade=="survey": tools.recon += 1
	if upgrade=="endurance": oxygen=120.0
	_build_navigation()
	_observe()
func _build_navigation() -> void:
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
	for rock in mission.rocks:
		var polygon=rock_polygon(rock)
		if Geometry2D.is_point_in_polygon(p,polygon): return true
		for n in polygon.size():
			if Geometry2D.get_closest_point_to_segment(p,polygon[n],polygon[(n+1)%polygon.size()]).distance_to(p)<radius: return true
	return false
func line_clear(a: Vector2,b: Vector2) -> bool:
	for rock in mission.rocks:
		var corners=rock_polygon(rock)
		if Geometry2D.is_point_in_polygon(a,corners) or Geometry2D.is_point_in_polygon(b,corners): return false
		for n in corners.size():
			if Geometry2D.segment_intersects_segment(a,b,corners[n],corners[(n+1)%corners.size()]) != null: return false
	return true
func path(a: Vector2, b: Vector2) -> Array:
	var result: Array=[]
	if blocked(b,18): return result
	if segment_safe(a,b,24): return [{"pos":b,"stop":true}]
	var first=Vector2i(clampi(int(a.x/40),0,39),clampi(int(a.y/40),0,23))
	var last=Vector2i(clampi(int(b.x/40),0,39),clampi(int(b.y/40),0,23))
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
			tools.decoy-=1; _noise(args.get("point",u.pos+Vector2(160,0)),1100,"DECOY",15.0); message="Decoy transmitting · 15 seconds"; events.append({"type":"decoy","pos":u.pos})
		"camera":
			if capture_unit>=0: message="One pilot · exposure in progress. Allow it to finish or replace that unit’s route."; return false
			var best := -1
			for i in mission.objectives.size():
				var o=mission.objectives[i]
				if not o.captured and u.pos.distance_to(o.pos)<240 and line_clear(u.pos,o.pos): best=i; break
			if best<0: message="Camera needs a clear view within 240m of an uncaptured marker."; return false
			var target=mission.objectives[best]
			if target.get("required_unit",selected)!=selected: message="Quietus must operate the archive uplink. Bring the submarine to this anchor."; return false
			for prerequisite in target.get("requires",[]):
				if not mission.objectives[prerequisite].captured: message="Uplink needs both relay records. Photograph WEST and EAST first."; return false
			capture_unit=selected; capture_target=best; capture_time=0.0; u.hold="HOLD"; message="Archive uplink · hold 6 seconds" if target.get("kind","")=="uplink" else "Camera exposure · hold 4 seconds"; _noise(u.pos,520,"CAMERA"); events.append({"type":"camera","pos":u.pos})
		_: return false
	return true
func _noise(p: Vector2,radius: float,label: String,duration: float=2.0) -> void:
	noises.append({"pos":p,"radius":radius,"time":duration,"label":label})
func advance(dt: float) -> void:
	if paused or not outcome.is_empty(): return
	accumulator+=minf(dt,0.25)
	while accumulator+0.0000001>=STEP:
		_tick(STEP); accumulator-=STEP
func _tick(dt: float) -> void:
	elapsed+=dt; oxygen=maxf(0,oxygen-dt/18.0)
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
		if not u.alive or u.pos.distance_to(o.pos)>240 or not line_clear(u.pos,o.pos): capture_unit=-1; message="Exposure interrupted · regain clear view"
		else:
			capture_time+=dt
			if capture_time>=o.get("duration",4.0):
				o.captured=true; u.hold=""; capture_unit=-1; message="Record secured. Return Quietus to extraction." if all_records() else "Record secured. Continue the survey."; events.append({"type":"record","pos":o.pos})
	if not units[selected].alive:
		selected=0; queue_mode=false; message="Drone lost · Quietus command restored. Submarine camera remains available."
	if oxygen<=0: outcome="lost"; message="Life support exhausted. The archive is silent."
	if hull<=0: outcome="lost"; message="Quietus lost. Your previous campaign records remain safe."
	if all_records() and units[0].pos.distance_to(mission.extraction)<65 and units[0].vel.length()<12:
		outcome="won"; paused=true; message="Archive recovered. Quietus is home."; events.append({"type":"extraction","pos":units[0].pos})
func _move(u: Dictionary,dt: float,speed: float,holding: bool) -> void:
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
			if u.route.size()>1:
				var next_direction:Vector2=u.route[1].pos-u.route[0].pos
				var corner=absf(delta.angle_to(next_direction))
				if corner>0.3: target_speed=minf(target_speed,20+sqrt(delta.length()*35))
			u.angle=rotate_toward(u.angle,target_angle,1.8*dt)
			desired=Vector2.from_angle(u.angle)*target_speed
	u.vel=u.vel.move_toward(desired,42*dt)
	var next:Vector2=u.pos+u.vel*dt
	if not blocked(next,12): u.pos=next
	else: u.vel=Vector2.ZERO; u.route.clear(); message="Autopilot stopped at unsafe terrain. Replot in open water."
func _observe() -> void:
	for y in 24:
		for x in 40:
			var p=Vector2(x*40+20,y*40+20)
			if visible(p): known[Vector2i(x,y)]=true
	for i in sirens.size():
		if visible(sirens[i].pos): contacts[i]={"pos":sirens[i].pos,"time":elapsed,"mode":sirens[i].mode,"lock":sirens[i].lock,"angle":sirens[i].angle,"target":sirens[i].target}
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
		for i in units.size():
			var u=units[i]
			if not u.alive: continue
			var dist=s.pos.distance_to(u.pos)
			var radius=180.0 if u.silent else 290.0
			if dist<radius and line_clear(s.pos,u.pos): detected=i; break
			if u.vel.length()>50 and dist<430:
				s.goal=u.pos; s.mode="INVESTIGATE"; s.suspicion=maxf(s.suspicion,0.3)
		for noise in noises:
			var acoustic=1.0 if line_clear(s.pos,noise.pos) else 0.36
			if s.pos.distance_to(noise.pos)<noise.radius*acoustic:
				s.goal=noise.pos; s.mode="INVESTIGATE"; s.suspicion=maxf(s.suspicion,0.45)
		if detected>=0:
			if s.target!=detected: s.lock=0.0
			s.route.clear(); s.angle=rotate_toward(s.angle,s.pos.angle_to_point(units[detected].pos),1.8*dt)
			s.target=detected; s.goal=units[detected].pos; s.lock+=dt; s.suspicion=minf(1,s.suspicion+dt*0.3); s.mode="LOCKING" if s.lock<4 else "BEAM"
			if s.lock>=4:
				if detected==0: hull=maxf(0,hull-dt*18)
				else: units[detected].alive=false; s.lock=0; events.append({"type":"loss","pos":units[detected].pos}); message="%s lost · submarine camera remains available"%units[detected].name
		else:
			s.target=-1; s.lock=maxf(0,s.lock-dt*3); s.suspicion=maxf(0,s.suspicion-dt*0.015)
			if s.pos.distance_to(s.goal)<35:
				s.mode="SEARCH" if s.suspicion>0.1 else "PATROL"
				s.goal=s.home+Vector2(sin(elapsed/19.0+s.patrol)*190,70+cos(elapsed/27.0)*65)
			s.path_time-=dt
			if s.path_time<=0:
				s.route=path(s.pos,s.goal); s.path_time=2.0
		_move(s,dt,48.0 if s.suspicion>0.1 else 25.0,false)
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
	for o in data.mission.objectives:
		if not o is Dictionary or not o.has_all(["pos","name","captured"]) or not o.pos is Vector2: return false
	if data.units.size()!=3 or not data.tools.has_all(["emp","decoy","recon"]): return false
	for u in data.units:
		if not u is Dictionary or not u.has_all(["pos","vel","angle","route","alive","hold","silent","battery","name"]): return false
		if not u.pos is Vector2 or not u.vel is Vector2 or not u.route is Array: return false
		for w in u.route:
			if not w is Dictionary or not w.has_all(["pos","stop"]) or not w.pos is Vector2: return false
	for e in data.sirens:
		if not e is Dictionary or not e.has_all(["pos","home","goal","vel","route","angle","mode","suspicion","stun","lock","target","patrol","path_time"]): return false
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
