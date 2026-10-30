extends RefCounted
# Read-only D1 presentation seam. Existing acquisition decides when to publish.
signal siren_notice(id:int, source_position:Vector2)
const Orders=preload("res://src/simulation/orders/order_table.gd")
const NoticeSources=preload("res://src/presentation/first_siren_cue/cue_table.gd")
const JobRelease=preload("res://src/simulation/job_release.gd")
const SaveChecks=preload("res://src/persistence/save_checks.gd")
const EnemyTypes=preload("res://src/simulation/enemy_types.gd")
const GradeOnSecure=preload("res://src/photo_grade/grade_on_secure.gd")
const LaunchLayout=preload("res://src/simulation/opening_fleet/launch_layout.gd")
const FieldTools=preload("res://src/simulation/field_tool_effects.gd")
const Shelf=preload("res://src/simulation/shelf_habitat.gd")
const Wake=preload("res://src/simulation/wake_crossing.gd")
const Endurance=preload("res://src/simulation/operation_endurance.gd")
const HuntPressure=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
const PolygonContainment=preload("res://src/simulation/polygon_containment.gd")
const Operations=preload("res://src/simulation/resolution_operations.gd")
const Concealed=preload("res://src/simulation/concealed_harbour.gd")
const Witness=preload("res://src/simulation/witness_evacuation.gd")
const Recipient=preload("res://src/simulation/warning_recipient.gd")
const CraftUpgrades=preload("res://src/equipment/craft_upgrades.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const Correlator=preload("res://src/equipment/cadence_correlator.gd")
const Sampler=preload("res://src/equipment/field_sampler.gd")
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
const SignalField=preload("res://src/simulation/signal_field.gd")
const Courier=preload("res://src/simulation/blackwater_courier.gd")
const Delivery=preload("res://src/simulation/blackwater_delivery.gd")
const Chain=preload("res://src/simulation/warning_chain.gd")
const Rendezvous=preload("res://src/simulation/rendezvous_transport.gd")
const Departure=preload("res://src/simulation/foundry_departure.gd")
const DroneOperations=preload("res://src/simulation/drone_operations.gd")
const ContactReports=preload("res://src/simulation/contact_reports.gd")
const Thermal=preload("res://src/simulation/thermal_front.gd")
const Acoustics = preload("res://src/simulation/acoustic_paths.gd")
const TerrainChart=preload("res://src/simulation/terrain_chart.gd")
const RouteProgram=preload("res://src/simulation/route_program.gd")
const ModuleRecovery=preload("res://src/simulation/module_recovery.gd")
const Cache=preload("res://src/simulation/optional_cache.gd")
const Missions = preload("res://src/campaign/missions.gd")
const Depth=preload("res://src/simulation/depth_bands.gd")
const Industry=preload("res://src/simulation/industrial_threats.gd")
const Choir=preload("res://src/simulation/industrial_jobs.gd")
const Glass=preload("res://src/simulation/glass_reach_work.gd")
const Network=preload("res://src/simulation/acoustic_network.gd")
const Sweeper=preload("res://src/simulation/sweeper_senses.gd")
const ContactIdentity=preload("res://src/simulation/contact_identity.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const BandPhoto=preload("res://src/photo_depth/band_photo.gd")
const PhotoRules=preload("res://src/photo_rules/photo_rules.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
var sonar:Dictionary={}
var depth_charts:Dictionary={}
var band_acoustics:Dictionary={}
var band_navigation:Dictionary={}
var band_shapes:Dictionary={}
var band_bounds:Dictionary={}
var geometry_band=1
const STEP := 1.0/60.0
const TILE := 40.0
const DECOY_RANGE := 160.0
const KNOCK_RANGE := 150.0
const KNOCK_TIME := 8.0
const TORPEDO_SPEED := 180.0
const TORPEDO_TURN := 3.0
const TORPEDO_LIFE := 3.0
# Combat tuning (Pat tunes these). A fired Siren beam destroys Quietus outright;
# the 4s lock build before it is the fair warning. Collision hull damage scales
# with impact speed (m/s): bumps at or under the safe speed are free, damage is
# per m/s over it, capped per hit so one strike never destroys Quietus, with a
# cooldown so grinding contact is not a per-frame drain.
const VAPORIZED_TEXT := "VAPORIZED · Siren beam struck Quietus. Your previous campaign records remain safe."
const COLLISION_SAFE_SPEED := 12.0
const COLLISION_DAMAGE_PER_SPEED := 0.45
const COLLISION_MAX_DAMAGE := 35.0
const COLLISION_COOLDOWN := 1.0
const COLLISION_SPEED_RETAINED := 0.25
const COLLISION_HULL_CLEARANCE := 24.0 # Two craft's existing 12m collision radii.
const WorldRegion=preload("res://src/simulation/world_region.gd")
var terrain_chart
var correlation:Dictionary={}
var mission: Dictionary
var units: Array = []
var sirens: Array = []
var known: Dictionary = {}
var contacts: Dictionary = {}
var events: Array = []
var noises: Array = []
var projectiles: Array=[]
var elapsed := 0.0
var oxygen := 100.0
var hull := 100.0
var paused := true
var selected := 0
var queue_mode := false
var pass_through := true
var outcome := ""
var message := "Chart loaded. Tap water to plot a route; unpause when ready."
var tools := {"emp":2,"decoy":3,"recon":2,"knock":2}
var ping_time := 0.0
var ping_origin := Vector2.ZERO
var recon_time := 0.0
var captures:Array=[{},{},{}]
# Foreground projection for diagnostics and single-station consumers. Exposure
# ownership and clocks live only in captures, independently of selection.
var capture_unit:int:
	get:return _capture_station()
var capture_target:int:
	get:return captures[capture_unit].target if capture_unit>=0 else -1
var capture_time:float:
	get:return captures[capture_unit].elapsed if capture_unit>=0 else 0.0
var accumulator := 0.0
var sensor_clock := 0.0
var navigation: AStarGrid2D
var rock_shapes: Array=[]
var rock_bounds:Array=[]
var acoustic_paths=Acoustics.new()
func start(index: int, upgrade: String = "endurance", launch:Dictionary={}) -> void:
	var operation=Missions.make(index,launch.get("context",{}))
	if operation.is_empty():return
	mission=operation
	mission["endurance"]=mission.get("endurance",Endurance.profile(Missions.Catalog.definition(index).config.source_id))
	correlation={}
	mission["launch_equipment"]=launch.get("fitted",Consequences.EMPTY_FIT).duplicate(true)
	units.clear()
	for i in 3:
		units.append({"pos":mission.get("start",Vector2(140,800))+LaunchLayout.offset(index,i),"vel":Vector2.ZERO,"angle":-0.3,"route":[],"alive":true,"hold":"","silent":true,"battery":100.0,"name":["QUIETUS","DRONE A","DRONE B"][i]})
	mission["module_recovery"]=ModuleRecovery.initial(mission.launch_equipment,units)
	mission["fleet_commit"]=launch.get("fleet_commit",false)
	sirens = mission.sirens.duplicate(true)
	Depth.initialize(self);Network.initialize(self);Industry.initialize(self);sonar=Sonar.initial();depth_charts={};geometry_band=1
	known = {}; contacts = {}; events = []; noises = []; projectiles=[]
	ContactIdentity.seed(self,launch.get("context",{}).get("intel",{}))
	elapsed=0.0; oxygen=100.0; hull=100.0; paused=true; selected=0; queue_mode=false; pass_through=true; outcome=""
	message="Chart loaded. Tap a craft for DEPTH / SONAR; tap water to plot a route."
	ping_time=0.0; recon_time=0.0; captures=[{},{},{}]; accumulator=0.0
	tools={"emp":2,"decoy":3,"recon":2,"knock":2}
	if upgrade=="disruption": tools.emp += 1
	if upgrade=="survey": tools.recon += 1
	if upgrade=="endurance": oxygen=120.0
	FieldTools.seed(self,upgrade)
	if launch.has("tool_racks"):preload("res://src/equipment/tool_racks.gd").launch(self,launch.tool_racks)
	_build_navigation()
	_configure_terrain()
	_configure_depth_charts()
	_prepare_siren_starts()
	HuntPressure.initialize(mission)
	_observe()
# Mode wrappers may place their initial patrol phase before any observation.
func _prepare_siren_starts()->void:pass
# Physical terrain still serves enemies, collision and sound. Player routes
# and presentation share only this locally measured chart in Confluence.
func _configure_terrain()->void:
	terrain_chart=null
	if not mission.get("earned_terrain",false):return
	terrain_chart=TerrainChart.new()
	var shapes=rock_shapes.duplicate(true)
	for r in Depth.structures(self,geometry_band):shapes.append(PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]))
	terrain_chart.configure(mission,shapes,mission.get("terrain_chart",{}))
	known=terrain_chart.clear_cells.duplicate();mission["terrain_chart"]=terrain_chart.snapshot()
func _configure_depth_charts()->void:
	depth_charts={}
	for band in 3:
		if band==1:
			depth_charts[band]=terrain_chart;continue
		var chart=TerrainChart.new()
		var config=mission.duplicate();config["world_size"]=world_size();config["launch_seed"]=Rect2(mission.get("start",units[0].pos)-Vector2(60,60),Vector2(120,120))
		config["pilotage_band"]=band
		chart.configure(config,Depth.shapes(self,band),mission.get("depth_charts",{}).get(band,{}))
		depth_charts[band]=chart
	_use_band(units[selected].band)
func _use_band(band:int)->void:
	geometry_band=band
	if not depth_charts.is_empty():terrain_chart=depth_charts.get(band)
	if not band_navigation.is_empty():navigation=band_navigation.get(band,navigation)
func choir_context()->Dictionary:return Choir.status(self)
func glass_context()->Dictionary:return Glass.status(self)
func network_feedback()->Array:return Network.feedback(self)
func public_chart()->Dictionary:
	return terrain_chart.public_chart() if terrain_chart!=null else {}
func player_path(a:Vector2,b:Vector2)->Array:
	return terrain_chart.player_path(a,b) if terrain_chart!=null else path(a,b,true)
func course_status(unit_id:int=-1)->Dictionary:
	var id=selected if unit_id<0 else unit_id
	if id>=units.size():return {}
	var terrain_chart=depth_charts.get(units[id].band)
	if terrain_chart==null:return {}
	var u=units[id]
	if u.has("chart_stop"):return {"state":"blocked","reason":u.chart_stop,"clear_distance":0.0}
	if u.route.is_empty():return {"state":"charted","reason":"","clear_distance":0.0}
	var distance=terrain_chart.clear_distance(u.pos,u.route[0].pos)
	return {"state":"charted" if distance+0.01>=u.pos.distance_to(u.route[0].pos) else ("frontier" if distance<20 else "tentative"),"clear_distance":distance}
func course_segments(unit_id:int=-1)->Array:
	var result=[]
	var id=selected if unit_id<0 else unit_id
	if id>=units.size():return result
	var terrain_chart=depth_charts.get(units[id].band)
	if terrain_chart==null:return result
	var origin:Vector2=units[id].pos
	for node in units[id].route:
		var distance=origin.distance_to(node.pos);var clear=terrain_chart.clear_distance(origin,node.pos)
		var frontier=origin.move_toward(node.pos,clear)
		if clear>0.001:result.append({"from":origin,"to":frontier,"confirmed":true})
		if clear+0.001<distance:result.append({"from":frontier,"to":node.pos,"confirmed":false})
		origin=node.pos
	return result
func _terrain_observe()->void:
	if terrain_chart==null or paused:return
	var receivers=[]
	for i in units.size():
		if units[i].alive and units[i].band==geometry_band:receivers.append({"pos":units[i].pos,"radius":passive_range(i)})

	var survey={"pos":mission.get("survey_origin",units[0].pos),"radius":560.0} if recon_time>0 else {}
	terrain_chart.observe(receivers,survey)
	if geometry_band==1:
		known=terrain_chart.clear_cells.duplicate();mission["terrain_chart"]=terrain_chart.snapshot()
func _course_block(u:Dictionary,reason:String)->void:
	if not u.has("chart_stop"):
		u.chart_stop=reason;message="%s · %s · replot retained course"%[u.name,reason]
func _course_prepare(u:Dictionary,speed:float,holding:bool)->Dictionary:
	if terrain_chart==null:return {"speed":speed,"holding":holding,"earned":false,"ground_cap":-1.0}
	if not holding and not u.route.is_empty() and u.get("chart_stop","") in ["","New terrain"]:
		if not terrain_chart.segment_safe(u.pos,u.route[0].pos):
			if _repair_current_leg(u,true):
				u.erase("chart_stop");message="%s · course adjusted through surveyed water"%u.name
			elif terrain_chart.clear_distance(u.pos,u.route[0].pos)<=20.0:_course_block(u,"New terrain")
			else:u.erase("chart_stop") # Retain useful travel before an unresolved return.
		else:u.erase("chart_stop")
	if u.has("chart_stop"):holding=true
	if u.route.is_empty():return {"speed":speed,"holding":holding,"earned":true,"ground_cap":-1.0}
	var direction:Vector2=u.pos.direction_to(u.route[0].pos)
	var distance=terrain_chart.clear_distance(u.pos,u.pos+direction*maxf(500.0,u.pos.distance_to(u.route[0].pos)))
	if u.vel.length()>0.01:distance=minf(distance,terrain_chart.clear_distance(u.pos,u.pos+u.vel.normalized()*500.0))
	var latency=0.15+STEP*2
	var safe_speed=maxf(0,sqrt(84.0*maxf(0,distance-12.0)+pow(42.0*latency,2))-42.0*latency)
	return {"speed":0.0 if u.vel.length()>safe_speed else minf(speed,safe_speed),"holding":holding,"earned":true,"ground_cap":safe_speed}
func _course_segment_safe(a:Vector2,b:Vector2,margin:float=24.0)->bool:
	return terrain_chart.segment_safe(a,b,margin) if terrain_chart!=null else segment_safe(a,b,margin)
func _course_turn_clear(point:Vector2,radius:float)->bool:
	return terrain_chart.clear_disk(point,radius) if terrain_chart!=null else not blocked(point,radius)
func _course_ground_safe(a:Vector2,b:Vector2)->bool:
	return terrain_chart==null or (terrain_chart.is_clear(b) and terrain_chart.clear_distance(a,b)+0.0001>=a.distance_to(b))
func collision_damage(impact:float)->float:
	return clampf((impact-COLLISION_SAFE_SPEED)*COLLISION_DAMAGE_PER_SPEED,0.0,COLLISION_MAX_DAMAGE)
func _course_collision(u:Dictionary,physical:bool=false,impact:float=-1.0)->void:
	# A chart frontier is a navigation stop, not contact with physical terrain.
	if physical:
		_hull_strike(u,impact);u.vel=u.vel*COLLISION_SPEED_RETAINED if u==units[0] else Vector2.ZERO
		_course_block(u,"Physical clearance stop")
	else:u.vel=Vector2.ZERO
	if u==units[0] and u.has("water_velocity"):u.water_velocity=u.vel-current_at(u.pos)
func _hull_strike(u:Dictionary,impact:float=-1.0,hit:String="terrain")->void:
	if impact<0:impact=u.vel.length()
	if u.name=="QUIETUS" and u.alive and outcome.is_empty() and elapsed-float(u.get("hit_at",-100.0))>=COLLISION_COOLDOWN:
		var damage:=collision_damage(impact)
		if damage>0.0:
			var hull_before_strike:float=hull
			hull=maxf(0.0,hull-damage);u["hit_at"]=elapsed
			FieldTools.record_collision(self,hull_before_strike-hull)
			events.append({"type":"creak","pos":u.pos});message="Hull strike against %s · %dm/s · hull -%d%%"%[hit,roundi(impact),roundi(damage)]
func _hull_contacts(u:Dictionary,origin:Vector2,velocity:Vector2)->void:
	var bodies=units.slice(1)+sirens
	for body in [Recipient.body(self),Choir.body(self)]:
		if not body.is_empty():bodies.append(body)
	if Rendezvous.applies(mission):
		var point=Rendezvous.position(mission,elapsed)
		bodies.append({"pos":point,"band":1,"vel":(point-Rendezvous.position(mission,maxf(0.,elapsed-STEP)))/STEP})
	for body in bodies:
		if not body.get("alive",true) or not Depth.overlap(u,body):continue
		# Apply one contact impulse on entry. Existing overlapping craft remain
		# able to separate; hull contact adds no permanent waypoint exclusion.
		var other_velocity:Vector2=body.get("vel",Vector2.ZERO)
		var separation:Vector2=body.pos-other_velocity*STEP-origin
		if separation.length()<COLLISION_HULL_CLEARANCE:continue
		var closest=Geometry2D.get_closest_point_to_segment(Vector2.ZERO,-separation,u.pos-body.pos)
		if closest.length()>=COLLISION_HULL_CLEARANCE:continue
		var closing=(velocity-other_velocity).dot(separation.normalized())
		if closing<=0:continue # Separating or coincident hulls do not invent impacts.
		_hull_strike(u,closing,str(body.name) if body in units else "another hull");u.vel*=COLLISION_SPEED_RETAINED
		if u.has("water_velocity"):u.water_velocity=u.vel-current_at(u.pos)
		return
func observable_sites() -> Array:
	if Chain.applies(mission):return mission.objectives.slice(0,2).duplicate(true)
	return mission.objectives.map(func(o):return Photo.masked(o)).duplicate(true)
func signal_readings() -> Array:
	return SignalField.readings(self)
func extraction_corridors() -> Array:
	return Consequences.corridors(self) if mission.get("expedition_revision",0)==2 else SignalField.corridors(self) if mission.has("expedition_revision") else [{"pos":mission.extraction,"name":"RECOVERY","route":"","available":all_records()}]
func salvage_sites()->Array:
	var sites=Witness.sites(self,Delivery.sites(self,ModuleRecovery.sites(self)))+Glass.sites(self)+Cache.sites(self)
	for site in sites:
		if not site.has("band"):site["band"]=Depth.cargo_band(self,site.item)
	return sites
func salvage_context(item:String,unit_id:int=-1)->Dictionary:
	var id=selected if unit_id<0 else unit_id
	if Cache.pieces(self).has(item):return Cache.context(self,item,id)
	if units[id].band!=Depth.cargo_band(self,item) or not units[id].transition.is_empty():return {"ready":false,"reason":"Salvage requires its recorded depth band","distance":0.,"active":false,"claimed_by":-1}
	if item.begins_with("glass_"):return Glass.context(self,"recover",id)
	if Witness.handles(self,item):return Witness.context(self,id,item).winch
	if item.begins_with("blackwater_buffer_"):return Delivery.context(self,item,id)
	var context=ModuleRecovery.context(self,item,id)
	if Delivery.applies(mission):
		for site in salvage_sites():
			if site.item==item:context["packets"]=site.packets
	return context
func _blackwater_recovery_busy(unit_id:int)->bool:return Delivery.busy(self,unit_id)
func _collect_shared_wreck(unit_id:int,pos:Vector2)->bool:
	if not Delivery.applies(mission) and not (Witness.available(self) and mission.witness_evacuation.pos.distance_to(pos)<=1):return false
	Witness.collect_at(self,unit_id,pos);ModuleRecovery.collect_at(self,unit_id,pos);Delivery.collect_at(self,unit_id,pos);return true
func _witness_recovery_busy(unit_id:int)->bool:return Witness.busy(self,unit_id)
func concealed_status()->Dictionary:return Concealed.status(self)
func witness_status()->Dictionary:return Witness.status(self)
func witness_context(unit_id:int=-1)->Dictionary:return Witness.context(self,selected if unit_id<0 else unit_id)
func warning_recipient_status()->Dictionary:return Recipient.status(self)
# Public non-player beam endpoints require a current local hull fix.
# Target ownership never aliases the three pilot-controlled craft.
func contact_target(contact:Dictionary)->Dictionary:
	if contact.get("recipient_target",false):
		if Choir.applies(mission):
			var industrial=Choir.status(self).get("load",{})
			return industrial if industrial.get("time",-1.)==elapsed and industrial.get("alive",false) else {}
		var vessel=Recipient.status(self).get("recipient",{})
		return vessel if vessel.get("known",false) and vessel.get("live",false) else {}
	var id=int(contact.get("target",-1))
	return units[id] if id>=0 and id<units.size() else {}
func module_recovery_status()->Dictionary:return ModuleRecovery.status(self)
func blackwater_delivery_status()->Dictionary:return Delivery.status(self)
func blackwater_handoff_context(carrier:int)->Dictionary:return Delivery.handoff_context(self,carrier)
func shelf_context()->Dictionary:return Shelf.context(self)
func warning_chain_context(unit_id:int=-1)->Dictionary:return Chain.context(self,selected if unit_id<0 else unit_id)
func _warning_chain_busy(unit_id:int)->bool:return Chain.connected(self,unit_id)
func departure_context()->Dictionary:
	if outcome.is_empty() and units[0].alive and units[0].vel.length()<12:
		for corridor in extraction_corridors():
			if corridor.available and units[0].pos.distance_to(corridor.pos)<65:return ModuleRecovery.departure(self,corridor)
	return {"available":false,"pending":false,"confirmation_required":false,"corridor":{},"recovered":[],"left":[],"recovered_drones":[],"text":"Bring Quietus and the required records to a recovery mouth"}
func _try_extract(corridor:Dictionary,confirmed:bool=false)->bool:
	if units[0].band!=1 or not units[0].transition.is_empty():return false
	var context=departure_context()
	if not context.available or context.corridor.pos!=corridor.pos or context.corridor.get("route","")!=corridor.get("route",""):return false
	if context.confirmation_required and not confirmed:
		message=context.text;return false
	if not Glass.can_extract(self,corridor):message="Bring the physical Reach material carrier to this recovery mouth in MIDDLE";return false
	if not Choir.can_extract(self,corridor):message="Recover the actual industrial material carrier here in MIDDLE";return false
	Glass.recover(self,corridor);Choir.recover(self,corridor)
	Cache.recover(self,corridor)
	ModuleRecovery.record(self,context)
	if mission.has("expedition_revision"):mission.chosen_route=corridor.route;mission.recovered=true
	outcome="won";paused=true;message="Archive recovered / "+corridor.name;events.append({"type":"extraction","pos":units[0].pos});return true
func operation_context()->Dictionary:
	return Operations.feedback(self)
func confluence_context()->Dictionary:
	if mission.id!=11:return {}
	var result={"landmarks":[],"gates":[],"currents":mission.get("currents",[]).duplicate(true)}
	for landmark in mission.get("landmarks",[]):
		if mission.signal_sources.any(func(source):return source.id==landmark.source_id and source.located):result.landmarks.append(landmark.duplicate(true))
	for gate in mission.get("physical_gates",[]):
		if mission.signal_sources.any(func(source):return source.id==gate.site_id and source.located):result.gates.append({"id":gate.id,"opened":gate.opened})
	return result
func confluence_resolution()->Dictionary:
	if mission.id!=11 or not mission.get("recovered",false):return {}
	var result={"route":mission.chosen_route,"thread":mission.launch_context.get("thread",""),"service_opened":mission.get("physical_gates",[]).any(func(gate):return gate.opened),"facts":mission.expedition_facts.duplicate(true)}
	for corridor in mission.corridors:
		if corridor.route==mission.chosen_route:result["exit"]=corridor.pos
	return result
func opened_terrain(rect:Rect2)->void:
	mission.depth_openings=mission.depth_openings.filter(func(opening):return opening.rect!=rect and elapsed-opening.time<=5.)
	mission.depth_openings.append({"rect":rect,"time":elapsed})
	for band in depth_charts:
		var chart=depth_charts[band]
		if chart==null:continue
		chart.open_structure(rect,Depth.shapes(self,band))
		if band==1:known=chart.clear_cells.duplicate();mission["terrain_chart"]=chart.snapshot()
func recon_feedback()->Dictionary:
	return Recon.feedback(self)
func _capture_station()->int:
	if not captures[selected].is_empty():return selected
	for id in captures.size():
		if not captures[id].is_empty():return id
	return -1
func capture_feedback(unit_id:int=-1)->Dictionary:
	var id=_capture_station() if unit_id<0 else unit_id
	if id<0 or id>=captures.size() or captures[id].is_empty():return {"duration":0.0,"elapsed":0.0,"unit":-1,"target":-1}
	var work=captures[id]
	return {"duration":_capture_duration(Photo.obj(self,work.target),id),"elapsed":work.elapsed,"unit":id,"target":work.target}
func capture_at_target(target:int)->Dictionary:
	for id in captures.size():
		if not captures[id].is_empty() and captures[id].target==target:return capture_feedback(id)
	return {"duration":0.0,"elapsed":0.0,"unit":-1,"target":-1}
func equipment_feedback()->Dictionary:
	return {"fitted":mission.get("launch_equipment",Consequences.EMPTY_FIT).duplicate(true),"correlation":correlation.duplicate(true)}
func _capture_duration(objective:Dictionary,unit_id:int)->float:
	return Glass.machine_duration(self,objective,unit_id,Sampler.capture_spec(unit_id,mission.get("launch_equipment",{}),objective).get("duration",objective.get("duration",4.0)))
func passive_range(unit_id:int)->float:
	return CraftUpgrades.passive_range(mission.get("launch_equipment",{}),unit_id)*(0.65 if mission.darkness else 1.0)*FieldTools.reach_scale(self,unit_id)
func motion_radius(unit_id:int)->float:
	return CraftUpgrades.motion_radius(mission.get("launch_equipment",{}),unit_id,propulsion_speed(units[unit_id]))*AllStop.noise_scale(units[unit_id])+(130.0 if not units[unit_id].get("transition",{}).is_empty() else 0.0)+Choir.noise(self,unit_id)
func _craft_speed(unit:Dictionary,fallback:float)->float:
	var quietus=unit.name=="QUIETUS"
	var speed=RouteProgram.speed(unit,fallback,quietus)
	return Choir.speed(self,units.find(unit),Concealed.speed(self,CraftUpgrades.cruise_speed(mission.get("launch_equipment",{})) if quietus and not unit.silent else CraftUpgrades.frame_speed(mission.get("launch_equipment",{}),units.find(unit),speed),unit))
func world_size() -> Vector2:
	return WorldRegion.size_of(mission)
func _build_navigation() -> void:
	geometry_band=1
	rock_shapes.clear()
	for rock in mission.get("depth_geometry",{}).get(1,{}).get("rocks",mission.rocks): rock_shapes.append(rock_polygon(rock))
	rock_bounds=PolygonContainment.bounds_for(rock_shapes)
	band_shapes={};band_bounds={}
	for band in 3:
		band_shapes[band]=Depth.rock_shapes(self,band);band_bounds[band]=PolygonContainment.bounds_for(band_shapes[band])
	navigation = AStarGrid2D.new()
	var cells=WorldRegion.grid_size(mission)
	navigation.region = Rect2i(Vector2i.ZERO,cells)
	navigation.cell_size=Vector2(TILE,TILE)
	navigation.offset=Vector2(20,20)
	navigation.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	navigation.update()
	for y in cells.y:
		for x in cells.x:
			if blocked(Vector2(x*40+20,y*40+20),21): navigation.set_point_solid(Vector2i(x,y))
	var acoustic_shapes=rock_shapes.duplicate()
	for r in Depth.structures(self,geometry_band):acoustic_shapes.append(PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]))
	acoustic_paths.configure(acoustic_shapes,world_size(),Thermal.fronts(mission,1))
	band_navigation={1:navigation}
	for band in [0,2]:
		var grid=AStarGrid2D.new();grid.region=Rect2i(Vector2i.ZERO,cells);grid.cell_size=Vector2(TILE,TILE);grid.offset=Vector2(20,20);grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES;grid.update()
		for y in cells.y:
			for x in cells.x:
				var point=Vector2(x*40+20,y*40+20)
				if not Depth.clear(self,point,point,band,21):grid.set_point_solid(Vector2i(x,y))
		band_navigation[band]=grid
	band_acoustics={1:acoustic_paths}
	for band in [0,2]:
		var propagation=Acoustics.new();propagation.configure(Depth.shapes(self,band),world_size(),Thermal.fronts(mission,band));band_acoustics[band]=propagation
func blocked(p: Vector2, radius: float = 12.0) -> bool:
	if geometry_band!=1:return not Depth.clear(self,p,p,geometry_band,radius)
	if p.x<radius or p.y<radius or p.x>world_size().x-radius or p.y>world_size().y-radius: return true
	for structure in Depth.structures(self,geometry_band):
		if structure.grow(radius).has_point(p): return true
	for i in rock_shapes.size():
		var polygon=rock_shapes[i]
		if PolygonContainment.contains(p,polygon,rock_bounds[i]): return true
		for n in polygon.size():
			if Geometry2D.get_closest_point_to_segment(p,polygon[n],polygon[(n+1)%polygon.size()]).distance_to(p)<radius: return true
	return false
func line_clear(a: Vector2,b: Vector2) -> bool:
	if geometry_band!=1:return Depth.clear(self,a,b,geometry_band)
	var shapes=rock_shapes.duplicate()
	var structures=Depth.structures(self,geometry_band)
	for structure in structures: shapes.append(PackedVector2Array([structure.position,Vector2(structure.end.x,structure.position.y),structure.end,Vector2(structure.position.x,structure.end.y)]))
	for i in shapes.size():
		var corners=shapes[i]
		var box:Rect2=rock_bounds[i] if i<rock_shapes.size() else structures[i-rock_shapes.size()]
		if PolygonContainment.contains(a,corners,box) or PolygonContainment.contains(b,corners,box): return false
		for n in corners.size():
			if Geometry2D.segment_intersects_segment(a,b,corners[n],corners[(n+1)%corners.size()]) != null: return false
	return true
func path(a: Vector2, b: Vector2, player_course:bool=false) -> Array:
	var result: Array=[]
	if blocked(b,24): return result
	if blocked(a,24): return _near_wall_recovery(a,b,player_course)
	if segment_safe(a,b,24) and (not player_course or _player_leg_safe(a,b)): return [{"pos":b,"stop":true}]
	var first=nearest_navigation_cell(a)
	var last=nearest_navigation_cell(b)
	if first.x<0 or last.x<0: return result
	var grid_path=navigation.get_point_path(first,last)
	var raw: Array=[]
	# A legal off-grid start may need the first grid point to round a corner.
	# Player courses retain that entry; the existing Siren path stays unchanged.
	for n in range(0 if player_course else 1,grid_path.size()): raw.append(grid_path[n])
	if raw.is_empty(): return result
	raw.append(b)
	var origin=a; var at=0
	while at<raw.size():
		var furthest=at
		for n in range(at+1,raw.size()):
			if segment_safe(origin,raw[n],24): furthest=n
		if player_course and not _player_leg_safe(origin,raw[furthest]):return []
		result.append({"pos":raw[furthest],"stop":furthest==raw.size()-1})
		origin=raw[furthest]; at=furthest+1
	return result
func _near_wall_recovery(origin: Vector2,destination: Vector2,player_course:bool=false) -> Array:
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
			if safe and (not player_course or _player_leg_safe(origin,entry)): candidates.append({"pos":entry,"cost":radius+entry.distance_to(destination)})
	candidates.sort_custom(func(a,b): return a.cost<b.cost)
	for candidate in candidates:
		var onward=path(candidate.pos,destination,player_course)
		if not onward.is_empty():
			var route: Array=[{"pos":candidate.pos,"stop":true}]; route.append_array(onward); return route
	return []
func command(order: String,args: Dictionary={}) -> bool:
	if not outcome.is_empty(): return false
	if order=="depart":return Orders.TABLE[order][0].command(self,order,args)
	var u=units[selected]
	_use_band(u.band)
	if not u.alive and order!="select":
		selected=0; queue_mode=false; message="Selected drone lost. Quietus selected; reissue the order."; return false
	if order in ["camera","chain_power","chain_route","chain_send","concealed_tow","witness_land","warning_gate","warning_depart","rendezvous_release","wake_playback","shelf_warn","shelf_alarm"] and ((u.band!=1 and not (order=="camera" and BandPhoto.can_shoot(self,u))) or not u.transition.is_empty()):
		message="Ascend to MIDDLE and settle for local work";return false
	if Cache.blocks(self,order):message="Finish this craft's cache winch first";return false
	if mission.has("tool_racks") and order in tools and preload("res://src/equipment/tool_racks.gd").count(self,order)<=0:
		message="%s has no %s aboard"%[u.name,order.to_upper()];return false
	var handler=Orders.TABLE.get(order,[])
	if handler.is_empty():return false
	var accepted:bool=handler[0].command(self,order,args)
	if accepted:preload("res://src/equipment/tool_racks.gd").sync_legacy(self)
	return _finish_command(u,order) if accepted and handler[1] else accepted
func _finish_command(u:Dictionary,order:String)->bool:
	if order=="emp":preload("res://src/simulation/observed_stun.gd").record(self)
	JobRelease.cancel(self,selected,order)
	AllStop.after_order(self,u,order)
	return true
# Public read-only operator intent; legacy navigation corners are not editor rows.
func route_goals(unit_id:int=-1) -> Array:
	return RouteProgram.goals(units[selected if unit_id<0 else unit_id])
func _install_program(u:Dictionary,plan:Array,remember:bool=true,append:bool=false) -> bool:
	if not RouteProgram.valid_goals(plan,world_size()): return false
	var compiled=RouteProgram.compile(u.route.back().pos,[plan.back()],player_path,world_size()) if append else RouteProgram.compile(u.pos,plan,player_path,world_size())
	if not compiled.ok: return false
	if append:
		var prefix:Array=u.route.duplicate(true)
		if not u.has("route_plan"):
			for node in prefix: node.mode="inherit"
			prefix.back().goal=true
		prefix.back().stop=plan[plan.size()-2].stop
		prefix.append_array(compiled.route); compiled.route=prefix
	if remember:
		var history:Array=u.get("route_undo",[]).duplicate(true)
		history.append(RouteProgram.goals(u))
		if history.size()>RouteProgram.MAX_UNDO: history.pop_front()
		u.route_undo=history
	else: u.erase("route_undo")
	u.route_plan=plan.duplicate(true); u.route=compiled.route
	if terrain_chart!=null and not append:u.erase("chart_stop")
	return true
func _edit_program(order:String,args:Dictionary) -> bool:
	var u=units[selected]; var plan=route_goals()
	if order=="route_undo":
		var history:Array=u.get("route_undo",[]).duplicate(true)
		if history.is_empty(): return false
		var previous:Array=history.pop_back()
		if not _install_program(u,previous,false): message="Previous course is no longer safe."; return false
		u.route_undo=history; message="%s · program edit undone"%u.name; return true
	var index=args.get("index",-1)
	if not index is int or index<0 or index>plan.size(): return false
	if order=="route_insert":
		plan.insert(index,{"pos":args.get("point",u.pos),"stop":args.get("stop",true),"mode":args.get("mode","inherit")})
	else:
		if index>=plan.size(): return false
		if order=="route_delete": plan.remove_at(index)
		else:
			for key in ["pos","stop","mode"]:
				if args.has("point" if key=="pos" else key): plan[index][key]=args["point" if key=="pos" else key]
	if order=="route_edit" and args.has("stop"): plan[index].arrival_set=true
	if not _install_program(u,plan): message="Program rejected · choose safe open water."; return false
	message="%s · %d programmed destinations"%[u.name,plan.size()]; return true
# Target guides use cached observed positions only. Final command validation also
# requires current legitimate visibility and a physical launch path.
func knockdown_targets() -> Array:
	var result: Array=[]
	if selected!=0 or units.is_empty() or not units[0].alive or not outcome.is_empty(): return result
	for id in contacts:
		var c=contacts[id]
		if not id is int or not c is Dictionary or not c.has_all(["time","pos"]): continue
		if not c.pos is Vector2 or not c.pos.is_finite() or not (c.time is int or c.time is float) or not is_finite(c.time): continue
		if elapsed-c.time<0 or elapsed-c.time>=0.3 or c.get("mode","") in ["PINNED","DISRUPTED"]: continue
		if units[0].pos.distance_to(c.pos)<=KNOCK_RANGE and _knock_band(c)>=0: result.append({"key":id,"pos":c.pos,"tag":"S%d"%(id+1)})
	return result
# Use only the acquired depth/transition and own geometry for aim previews.
# The projectile occupies one shared water volume, even during a craft shift.
func _knock_band(contact:Dictionary)->int:
	for band in Depth.occupied(units[0]):
		if band in Depth.occupied(contact) and visible(contact.pos,band) and Depth.clear(self,units[0].pos,contact.pos,band,3):return band
	return -1
# Read-only receiver geometry. Relay reply is authored local behavior; no enemy query.
func blackwater_context(target:int,station:int=-1) -> Dictionary:
	if station<0:station=selected
	var u=units[station];var o=mission.objectives[target]
	var radius=passive_range(station)
	var distance=u.pos.distance_to(o.pos);var clear=line_clear(u.pos,o.pos)
	var replay=maxf(0.0,o.get("replay_until",0.0)-elapsed) if u.alive and clear and distance<240 else 0.0
	var fixed={"distance":distance,"quiet_range":radius,"clear":clear,"quiet":u.alive and clear and distance<radius,"replay":replay,"ready":u.alive and clear and (distance<radius or replay>0),"settled":u.vel.length()<2,"source":"relay","origin":o.pos}
	if target==1 and not fixed.ready:
		var moving=Courier.receiver(self,station)
		if not moving.is_empty():
			moving.quiet_range=passive_range(station);return moving
	return fixed
func _blackwater_context_text(target:int,station:int) -> String:
	var c=blackwater_context(target,station);var name=mission.objectives[target].name
	if c.get("source","")=="courier":return "REPLY CARRIER · local moving archive · settle + SAMPLE 2s"
	if not c.clear:return "%s · cover blocks reception"%name
	if c.replay>0:return "%s · LOCAL REPLAY %.1fs · SAMPLE 2s"%[name,c.replay]
	if c.quiet:return "%s · quiet receiver ready · SAMPLE 2s"%name
	var learned=mission.objectives.any(func(o):return o.captured)
	return "%s · %dm / quiet %.0fm%s"%[name,c.distance,c.quiet_range," · learned: SONAR + SAMPLE within 240m" if learned else " · move closer to listen"]
func camera_context() -> Dictionary:
	return Pricing.annotate(self,PhotoRules.camera_hint(self,BandPhoto.gate(self,preload("res://src/simulation/photo_context.gd").resolve(self,_camera_context_base()))))
func _camera_context_base() -> Dictionary:
	var closed:String=BandPhoto.unready(self,units[selected])
	if not closed.is_empty():return {"ready":false,"target":-1,"text":closed}
	if Shelf.applies(mission):return Shelf.receiver(self)
	if Chain.applies(mission):return {"target":-1,"ready":false,"text":Chain.context(self,selected).text}
	var work=capture_feedback(selected)
	if work.unit>=0:
		var active=Photo.obj(self,work.target)
		if active.get("kind","")=="exchange":
			var c=blackwater_context(work.target,selected)
			return {"target":work.target,"ready":false,"text":"%s · %s · %s %.1f/2s"%[units[selected].name,"REPLY CARRIER" if c.get("source","")=="courier" else active.name,"receiving" if c.settled else "settling",work.elapsed]}
		return {"target":work.target,"ready":false,"text":"%s · %s %.1f / %.0fs"%[units[selected].name,active.name,work.elapsed,work.duration]}
	if Rendezvous.applies(mission):return Rendezvous.work_receiver(self,selected)
	var camera_sites=mission.objectives.filter(func(o):return preload("res://src/campaign/sorley_rescue.gd").camera_candidate(self,o))
	if mission.has("expedition_revision") and camera_sites.all(func(o):return o.captured) and not camera_sites.any(func(o):return Operations.own_origin(o)):
		if mission.id==41:return {"target":-1,"ready":false,"text":Witness.status(self).text}
		var facts=preload("res://src/campaign/sorley_rescue.gd").camera_facts(mission)
		return {"target":-1,"ready":false,"text":"No exact source located · listen from another position or spend local RECON" if facts.is_empty() and mission.id!=8 else "Observed %s · choose an available named recovery corridor"%", ".join(facts)}
	var unit=units[selected]; var best=-1; var nearest=-1; var distance=INF; var reshoot=-1; var best_score:=INF
	for id in mission.objectives.size():
		var objective=mission.objectives[id]
		if not preload("res://src/campaign/sorley_rescue.gd").camera_candidate(self,objective):continue
		if objective.captured and Photo.applies(objective) and not Operations.own_origin(objective) and Photo.seen_before(self,id).size()<objective.subject.features.size():
			# A resolved record can be re-shot from a better viewpoint for what it missed.
			if reshoot<0 and unit.pos.distance_to(objective.pos)<Photo.reach(self,selected) and Depth.optical_clear(self,unit.pos,objective.pos,unit.band):reshoot=id
			continue
		if objective.captured and not Operations.own_origin(objective) and not Delivery.needs_sample(self,id,selected): continue
		if Operations.own_origin(objective):
			if nearest<0:nearest=id
			if Operations.ready(self,objective,selected):best=id;break
			continue
		var reception=blackwater_context(id) if mission.get("blackwater_revision",0)==1 else {}
		var d:float=reception.distance if not reception.is_empty() else unit.pos.distance_to(objective.pos)
		if not reception.is_empty() and reception.ready and best<0:best=id
		if d<distance: nearest=id; distance=d
		var photo_clear=Depth.optical_clear(self,unit.pos,objective.pos,unit.band) if Photo.applies(objective) else line_clear(unit.pos,objective.pos)
		if d<Photo.reach(self,selected) and photo_clear:
			# Several subjects in reach: the one the craft is turned toward is framed.
			var aim_score:float=absf(angle_difference(unit.angle,unit.pos.angle_to_point(objective.pos)))+d/2000.0
			if best<0:best=id;best_score=aim_score
			elif Photo.applies(objective) and Photo.applies(mission.objectives[best]) and aim_score<best_score:best=id;best_score=aim_score
	if best<0 and reshoot>=0:best=reshoot
	if best<0 and (nearest<0 or not Operations.own_origin(mission.objectives[nearest])):
		var sighted=Photo.siren_candidate(self,selected)
		if sighted>=0:return {"target":-2,"siren":sighted,"ready":true,"text":"READY · S%d %s · PHOTO %.0fs · observe its form and movement from clear water"%[sighted+1,str(sirens[sighted].get("type","patroller")).to_upper(),8.0]}
	if nearest<0 and best<0: return {"target":-1,"ready":false,"text":Delivery.status(self).text if Delivery.applies(mission) else "Archive aboard · return Quietus to extraction."}
	var candidate=best if best>=0 else nearest
	if Witness.applies(mission) and mission.objectives[candidate].get("site_id","")==Witness.packet(mission):return {"target":candidate,"ready":false,"text":Witness.context(self,selected).winch.reason}
	var owner=capture_at_target(candidate)
	if owner.unit>=0:return {"target":candidate,"ready":false,"text":"%s · %s already acquiring this record"%[Photo.label(mission.objectives[candidate]),units[owner.unit].name]}
	if mission.get("blackwater_revision",0)==1:
		var id=best if best>=0 else nearest
		return {"target":id,"ready":blackwater_context(id).ready,"text":_blackwater_context_text(id,selected)}
	if best<0 and Operations.own_origin(mission.objectives[nearest]):
		return {"target":nearest,"ready":false,"text":"TRANSMISSION SECTOR · Quietus chooses clear water inside the charted sector; settle below 12m/s"}
	if best<0:
		var target=mission.objectives[nearest]
		if Photo.stage(target)=="lead":return {"target":nearest,"ready":false,"text":"%s · search the marked area · the camera reaches %dm"%[Photo.label(target),roundi(Photo.reach(self,selected))]}
		return {"target":nearest,"ready":false,"text":"%s · %dm away / %dm range%s"%[Photo.label(target),roundi(distance),roundi(Photo.reach(self,selected))," · view blocked by cover" if not line_clear(unit.pos,target.pos) else ""]}
	var target=mission.objectives[best]
	if target.get("required_unit",selected)!=selected and Sampler.capture_spec(selected,mission.get("launch_equipment",{}),target).is_empty():
		return {"target":best,"ready":false,"text":target.get("unit_requirement","Quietus must operate the archive uplink. Bring the submarine to this anchor.")}
	if not Sampler.capture_spec(selected,mission.get("launch_equipment",{}),target).is_empty() and unit.vel.length()>=12:
		return {"target":best,"ready":false,"text":"FIELD SAMPLE · settle below 12m/s before the audible 8s exposure"}
	for prerequisite in target.get("requires",[]):
		if not mission.objectives[prerequisite].captured:
			return {"target":best,"ready":false,"text":target.get("requirement","Uplink needs both relay records. Photograph WEST and EAST first.")}
	var hint=""
	if Photo.applies(target):
		var framed=Photo.frame(self,selected,target)
		hint=" · SHARP %d%% LIGHT %d%%%s"%[roundi(framed.sharp*100),roundi(framed.light*100)," · TURN %d°"%roundi(rad_to_deg(framed.pivot)) if framed.pivot>0 else ""]
		var weak:PackedStringArray=[]
		for r in framed.rows:
			if r.id in target.subject.get("required",[]) and not r.ready and not r.why.is_empty():weak.append("%s %s"%[r.label,r.why.to_lower()])
		if not weak.is_empty():hint+=" · WILL NOT RESOLVE: "+", ".join(weak)
	return {"target":best,"ready":true,"text":"READY · %s · %s %.0fs%s"%[Photo.label(target),"FIELD SAMPLE · AUDIBLE" if not Sampler.capture_spec(selected,mission.get("launch_equipment",{}),target).is_empty() else "passive listen" if target.get("kind","")=="receiver" else "TRANSMIT · AUDIBLE" if Operations.own_origin(target) else "exposure",_capture_duration(target,selected),hint]}
# Well-specific optional comparison. Own motion and local reception only;
# no Siren query, extra acoustic source or forced enemy intent.
func _well_signature_observe() -> void:
	if mission.get("well_revision",0)!=1 or not mission.objectives[0].captured:return
	var emitter=units[0];var aperture:Vector2=mission.objectives[1].pos
	if mission.well_reference.is_empty() and emitter.alive and emitter.band==1 and emitter.transition.is_empty() and propulsion_speed(emitter)>50 and emitter.pos.distance_to(aperture)<240 and line_clear(emitter.pos,aperture):
		mission.well_reference={"time":elapsed,"speed":propulsion_speed(emitter),"pos":emitter.pos}
		message="Quietus engine reference recorded · compare locally at RETURN ARCHIVE"
	if mission.well_reference.is_empty() or not mission.well_observation.is_empty():return
	var origin:Vector2=mission.objectives[2].pos
	for id in units.size():
		var receiver=units[id];var radius=(240.0 if id==0 else 330.0)*(0.65 if mission.darkness else 1.0)
		if receiver.alive and receiver.band==1 and receiver.transition.is_empty() and receiver.pos.distance_to(origin)<radius and Depth.clear(self,receiver.pos,origin,1):
			mission.well_observation={"time":elapsed,"unit":id,"pos":origin}
			mission.record="A returned pattern matches Quietus' moving engine cadence. Its source and intent remain unresolved."
			message="Returned cadence matches Quietus reference · comparison recorded"
			break
func well_signature_evidence() -> Dictionary:
	if mission.get("well_revision",0)!=1 or mission.well_observation.is_empty():return {}
	var reference=mission.well_reference;var observation=mission.well_observation
	return {"name":"QUIETUS / RETURNED CADENCE","optical":"well_signature","caption":"ENGINE REFERENCE: Quietus moving %.1f m/s at %.1fs near PROFILE APERTURE. LOCAL RETURN: received by %s at %.1fs near RETURN ARCHIVE. The returned cadence matches the recorded reference. Source and intent remain unresolved."%[reference.speed,reference.time,units[observation.unit].name.to_upper(),observation.time]}

func decoy_target_valid(point:Variant) -> bool:
	if not point is Vector2 or not point.is_finite():return false
	var origin=units[selected]
	return origin.alive and outcome.is_empty() and tools.decoy>0 and Rect2(Vector2(6,6),world_size()-Vector2(12,12)).has_point(point) and origin.pos.distance_to(point)<=DECOY_RANGE+0.001 and not blocked(point,6) and segment_safe(origin.pos,point,6)
func _noise(p: Vector2,radius: float,label: String,duration: float=2.0,band:int=1) -> void:
	noises.append({"band":band,"pos":p,"radius":radius,"time":duration,"label":label})
	var pressure={"ACTIVE SONAR":5.0,"DISRUPTION":4.0,"KNOCKDOWN":4.0,"DECOY":4.0,"RECON UPLINK":4.0}.get(label,0.0)
	pressure=HuntPressure.action_amount(mission,label,pressure)
	if pressure>0:Recon.action(mission,pressure,label)
func courier_feedback() -> Dictionary:
	return Courier.feedback(self)
func rendezvous_context(unit_id:int=-1)->Dictionary:return Rendezvous.feedback(self,selected if unit_id<0 else unit_id)
func rendezvous_receiver(unit_id:int=-1)->Dictionary:return Rendezvous.receiver(self,selected if unit_id<0 else unit_id)
func departure_feedback() -> Dictionary:
	return Departure.feedback(self)
# Own known emissions only. Reception and enemy reaction remain sensor evidence.
# Derive from existing clocks so pause/restore need no extra lifetime state.
func acoustic_feedback() -> Dictionary:
	var result={"motion":[],"pulses":[],"responses":[],"revision":mission.get("acoustic_revision",0),"thermal":mission.get("thermal_revision",0)==1,"thermal_band":Thermal.BAND_NAMES[Thermal.band(mission)]}
	for u in units:
		# Match actual movement hearing, including residual speed after SILENT.
		if u.alive and (propulsion_speed(u)>0.0 if mission.get("acoustic_revision",0)==1 else propulsion_speed(u)>50):
			result.motion.append({"name":u.name,"pos":u.pos,"radius":motion_radius(units.find(u)) if mission.get("acoustic_revision",0)==1 else 430.0,"speed":propulsion_speed(u)})
	for n in noises:
		if n.time<=0: continue
		if n.label in ["DECOY","ACTIVE SONAR","RECON UPLINK","DISRUPTION","CAMERA","KNOCKDOWN","TORPEDO RUN","WARNING CHAIN TRANSMISSION","SERVICE SLUICE MOTOR","RECOVERY WINCH","BERTH RELEASE","BACKUP GENERATOR START","SERVICE SHUTTER","SERVICE WARNING","NORTH MAST WARNING"]:
			result.pulses.append({"label":n.label,"pos":n.pos,"time":n.time,"radius":n.radius})
		elif n.label=="FACTORY RESPONSE" and visible(n.pos):
			result.responses.append({"label":n.label,"pos":n.pos,"time":n.time})
	return result
func advance(dt: float) -> void:
	if paused or not outcome.is_empty(): return
	accumulator+=minf(dt,0.25)
	while accumulator+0.0000001>=STEP and outcome.is_empty():
		_tick(STEP); accumulator-=STEP
func _tick(dt: float) -> void:
	var hull_origin:Vector2=units[0].pos;var hull_velocity:Vector2=units[0].vel
	Departure.emit(self)
	elapsed+=dt
	AllStop.tick(self,dt)
	Depth.advance(self,dt);Sonar.advance(self,dt); oxygen=maxf(0,oxygen-Endurance.oxygen_drain(mission,dt))
	Recon.tick(mission,dt)
	if mission.get("phase","")=="response": mission.response_time=mission.get("response_time",0.0)+dt
	ping_time=maxf(0,ping_time-dt); recon_time=maxf(0,recon_time-dt)
	for n in noises: n.time-=dt
	noises=noises.filter(func(n): return n.time>0)
	for i in units.size():
		var u=units[i]
		if not u.alive: continue
		if i>0 and u.hold==DroneOperations.ARMED:
			var observed=DroneOperations.local_contact(contacts,i,elapsed)
			if observed>=0:
				u.hold=DroneOperations.STOPPED;message="%s observed S%d · SCOUT braking · release SCOUT or replot"%[u.name,observed+1]
		var holding=u.hold in ["HOLD",DroneOperations.STOPPED] or (u.hold=="CONTACT" and has_live_contact())
		if u.hold=="DRONE":
			holding=false
			for j in [1,2]:
				if units[j].alive and not units[j].route.is_empty(): holding=true
		_move(u,dt,(42.0 if u.silent else 78.0) if i==0 else 96.0,holding,true,true)
		if i>0:
			u.battery=maxf(0,u.battery-Endurance.battery_drain(mission,i,propulsion_speed(u),dt))
			if u.battery<=0: u.alive=false; events.append({"type":"loss","pos":u.pos}); message=("%s battery exhausted · Quietus can SAMPLE either relay." if mission.get("blackwater_revision",0)==1 else "%s battery exhausted. Quietus camera remains available.")%u.name
	_advance_projectiles(dt)
	Recipient.tick(self,dt)
	var vaporized=_threats(dt)
	Network.advance(self,dt)
	Glass.tick(self,dt);Choir.tick(self,dt)
	Cache.tick(self,dt)
	_hull_contacts(units[0],hull_origin,hull_velocity)
	Depth.cargo_bands(self)
	Shelf.tick(self)
	Chain.tick(self)
	Delivery.losses(self)
	Witness.losses(self)
	ModuleRecovery.tick(self,dt)
	Delivery.tick(self,dt)
	Witness.tick(self,dt)
	Concealed.tick(self,dt)
	sensor_clock-=dt
	if sensor_clock<=0:
		_observe(); SignalField.observe(self); Consequences.observe(self); Photo.discover(self); sensor_clock=0.15
	for station in captures.size():
		if captures[station].is_empty():continue
		var work=captures[station];var u=units[station]; _use_band(u.band); var o=Photo.obj(self,work.target)
		if o.has("siren") and int(o.siren)<sirens.size():o.pos=sirens[o.siren].pos
		var exchange=o.get("kind","")=="exchange" and mission.get("blackwater_revision",0)==1
		var mobile=Rendezvous.applies(mission) and o.get("site_id","")=="rendezvous"
		var receiver=rendezvous_receiver(station) if mobile else blackwater_context(work.target,station) if exchange else {}
		var photo_line_clear=Depth.optical_clear(self,u.pos,o.pos,u.band) if Photo.applies(o) else line_clear(u.pos,o.pos)
		if not BandPhoto.can_shoot(self,u,o) or ((exchange or mobile) and not receiver.ready) or (Operations.own_origin(o) and not Operations.receiving(self,o,station)) or (not exchange and not mobile and not Operations.own_origin(o) and (u.pos.distance_to(o.pos)>Photo.reach(self,station) or not photo_line_clear or (o.has("siren") and not contact_visible(sirens[o.siren])))):
			captures[station]={}
			message=u.name+" · "+("Reception interrupted · move closer or SONAR for a local replay" if exchange else "Exposure interrupted · regain clear view")
		elif exchange and not receiver.settled:work.elapsed=0.0
		elif not Sampler.capture_spec(station,mission.get("launch_equipment",{}),o).is_empty() and u.vel.length()>=12:work.elapsed=0.0
		else:
			if not Photo.applies(o) or Photo.tick(self,station,o,dt):work.elapsed+=dt
			if work.elapsed+(0.0000001 if exchange else 0.0)>=_capture_duration(o,station):
				var first=not o.captured
				var usable=true
				if Photo.applies(o):
					var result=Photo.finish(self,station,o);usable=result.usable
					if not usable:message="%s · exposure unusable: %s · retake from another angle"%[u.name,Photo.missing_text(Photo.frame(self,station,o),o.subject)];Recon.action(mission,3.0,"UNUSABLE EXPOSURE")
				u.hold=""; captures[station]={}
				if usable:o.captured=true
				if not usable:pass
				elif first or (not Delivery.applies(mission) and not Photo.applies(o)):_record_secured(o,station)
				elif Photo.applies(o):message="Re-shot filed · %d frames of this subject in the archive"%Photo.shots_for(mission,str(o.get("optical",o.get("site_id",work.target)))).size()
				else:Delivery.sampled(self,work.target,station)
	if mission.get("expedition_revision",0)==2:
		var was=correlation.get("status","")
		correlation=Correlator.advance(correlation,signal_readings(),mission.get("launch_context",{}).get("references",{}).get("return_cadence",[]),units[0].pos,units[0].vel.length(),elapsed,dt,units[0].alive and Equipment.has(mission.get("launch_equipment",{}),0,"quietus_correlator"))
		if was!="match" and correlation.get("status","")=="match":
			var direction=correlation.arrivals.filter(func(r):return r.classification=="match")[0].direction
			events.append({"type":"return_received","receiver":0,"direction":direction,"identity":"return","time":elapsed})
	_well_signature_observe()
	_use_band(units[selected].band)
	if not units[selected].alive:
		selected=0; queue_mode=false; message="Drone lost · Quietus selected · SAMPLE remains available." if mission.get("blackwater_revision",0)==1 else "Drone lost · Quietus command restored. Submarine camera remains available."
	if oxygen<=0: outcome="lost"; message="Life support exhausted. The archive is silent."
	if hull<=0:
		outcome="lost";message=VAPORIZED_TEXT if vaporized else "Quietus lost. Your previous campaign records remain safe."
	SignalField.extract(self)
	Consequences.extract(self)
	if not mission.has("expedition_revision") and outcome.is_empty() and all_records() and units[0].pos.distance_to(mission.extraction)<65 and units[0].vel.length()<12:
		_try_extract({"pos":mission.extraction,"name":"RECOVERY","route":"","available":true})
	HuntPressure.observe(self,dt) # Commit actual sight/photo edges before pause input can clear them.
# Player-only continuous hull corridor, O(terrain edges) rather than O(length).
# Endpoints vs edges are covered by blocked(); the remaining closest segment
# pairs are an edge intersection or a rock vertex vs this leg. No convexity
# assumption is made, and bounds follow blocked()'s current world contract.
func _player_leg_safe(a:Vector2,b:Vector2) -> bool:
	if terrain_chart!=null:return terrain_chart.segment_safe(a,b)
	if blocked(a,12) or blocked(b,12): return false
	for structure in Depth.structures(self,geometry_band):
		if _leg_enters_rect(a,b,structure.grow(12)): return false
	for polygon in rock_shapes:
		for n in polygon.size():
			var vertex:Vector2=polygon[n]
			if Geometry2D.segment_intersects_segment(a,b,vertex,polygon[(n+1)%polygon.size()])!=null: return false
			if Geometry2D.get_closest_point_to_segment(vertex,a,b).distance_squared_to(vertex)<144.0: return false
	return true
# Slab clipping retains Rect2.has_point's included minimum/excluded maximum,
# including parallel/tangent legs and a single-corner contact.
func _leg_enters_rect(a:Vector2,b:Vector2,rect:Rect2) -> bool:
	var enter=0.0;var leave=1.0;var delta=b-a
	for axis in 2:
		if delta[axis]==0.0:
			if a[axis]<rect.position[axis] or a[axis]>=rect.end[axis]: return false
		else:
			var first=(rect.position[axis]-a[axis])/delta[axis]
			var last=(rect.end[axis]-a[axis])/delta[axis]
			enter=maxf(enter,minf(first,last));leave=minf(leave,maxf(first,last))
			if enter>leave: return false
	return rect.has_point(a.lerp(b,(enter+leave)*0.5))
# Physical turns can leave the line compiled at order time. Repair only a dirty
# current leg; keep every accepted node/goal after it and never re-run AStar for
# an unobstructed leg. This is player autopilot, not enemy pursuit steering.
func _repair_current_leg(u:Dictionary,confirmed_only:bool=false) -> bool:
	var index=0
	# Earned returns can invalidate generated corners. Rejoin the same accepted
	# goal through surveyed water, preserving every later operator waypoint.
	if confirmed_only and u.has("route_plan"):
		while index<u.route.size()-1 and not u.route[index].get("goal",false):index+=1
	var destination:Dictionary=u.route[index]
	var leg=terrain_chart.known_path(u.pos,destination.pos) if confirmed_only else player_path(u.pos,destination.pos)
	if leg.is_empty() or not _player_leg_safe(u.pos,leg[0].pos): return false
	for node in leg:
		# Keep a near-wall recovery safety STOP, distinct from operator arrival.
		if destination.has("mode"): node.mode=destination.mode
	leg[leg.size()-1]=destination.duplicate(true)
	leg.append_array(u.route.slice(index+1));u.route=leg
	return true
func propulsion_speed(u:Dictionary) -> float:
	# Engine effort is through water; u.vel remains actual chart/ground motion.
	return u.get("water_velocity",u.vel).length()
func current_at(point:Vector2) -> Vector2:
	return preload("res://src/simulation/current_field.gd").sample(mission.get("currents",[]),point)
func current_feedback() -> Array:
	var result=[]
	for id in units.size():
		var u=units[id];var flow=current_at(u.pos)
		if not u.alive or flow.length()<0.1:continue
		result.append({"unit":id,"pos":u.pos,"flow":flow,"ground_velocity":u.vel,"water_velocity":u.get("water_velocity",u.vel-flow),"effort":propulsion_speed(u)})
	return result
func _current_step(u:Dictionary,dt:float,desired_ground:Vector2,speed:float,flow:Vector2,report_collision:bool,player_craft:bool,ground_cap:float=-1.0) -> void:
	# Independent vector thrusters have the same bounded acceleration and total
	# through-water speed budget as ordinary motion. Hull turning stays physical.
	if ground_cap>=0:desired_ground=desired_ground.limit_length(ground_cap)
	var water:Vector2=u.get("water_velocity",u.vel-flow)
	water=water.move_toward((desired_ground-flow).limit_length(speed),AllStop.decel(u,42.0)*dt)
	u["water_velocity"]=water
	var ground:Vector2=water+flow
	var next:Vector2=u.pos+ground*dt
	if player_craft and not _course_ground_safe(u.pos,next):
		_course_collision(u,false,maxf(u.vel.length(),ground.length()));u["water_velocity"]=u.vel-flow
		return
	if not blocked(next,12) and segment_safe(u.pos,next,12):
		u.pos=next;u.vel=ground
	else:
		if player_craft and terrain_chart!=null:
			_course_collision(u,true,maxf(u.vel.length(),ground.length()));u["water_velocity"]=u.vel-flow
			return
		if player_craft:_hull_strike(u,maxf(u.vel.length(),ground.length()))
		u.vel=u.vel*COLLISION_SPEED_RETAINED if player_craft and u==units[0] else Vector2.ZERO;u.route.clear();u["current_station"]=u.pos
		if player_craft and u==units[0]:u.water_velocity=u.vel-flow
		if player_craft:RouteProgram.clear(u)
		if report_collision:message="%s autopilot stopped at unsafe terrain. Replot in open water."%u.name
func _move(u: Dictionary,dt: float,speed: float,holding: bool,report_collision: bool=true,player_craft: bool=false) -> void:
	_use_band(u.get("band",1))
	_move_in_band(u,dt,speed,holding or not u.get("transition",{}).is_empty(),report_collision,player_craft)
	_use_band(units[selected].band)
func _move_in_band(u: Dictionary,dt: float,speed: float,holding: bool,report_collision: bool=true,player_craft: bool=false) -> void:
	var desired=Vector2.ZERO
	if not u.get("transition",{}).is_empty():
		u.vel=Vector2.ZERO
		if not mission.get("currents",[]).is_empty():u["water_velocity"]=-current_at(u.pos)
		return
	if player_craft:
		speed=_craft_speed(u,speed)
		var engines:Dictionary=AllStop.shape(u,speed,holding);speed=engines.speed;holding=engines.holding
	var thrust_capacity=speed
	var course=_course_prepare(u,speed,holding) if player_craft else {"speed":speed,"holding":holding,"earned":false}
	speed=course.speed;holding=course.holding
	var ground_cap:float=course.get("ground_cap",-1.0)
	var flowing=not mission.get("currents",[]).is_empty()
	var flow=current_at(u.pos) if flowing else Vector2.ZERO
	if flowing:
		if holding or u.route.is_empty():
			if not u.has("current_station"):u["current_station"]=u.pos
		else:u.erase("current_station")
	if player_craft and not course.earned and not holding and not u.route.is_empty() and not _player_leg_safe(u.pos,u.route[0].pos):
		if _repair_current_leg(u):
			if report_collision: message="%s · course adjusted around charted terrain"%u.name
		else:
			u.route.clear();RouteProgram.clear(u)
			if report_collision: message="%s autopilot stopped at unsafe terrain. Replot in open water."%u.name
	if not u.route.is_empty() and not holding:
		var dest=u.route[0]
		var delta:Vector2=dest.pos-u.pos
		var arrival=9.0 if dest.stop else 11.0
		var mode_boundary=player_craft and dest.get("goal",false) and u.route.size()>1 and u.route[1].get("mode","inherit")!="inherit" and u.route[1].get("mode","inherit")!=dest.get("mode","inherit")
		if not mode_boundary and not dest.stop and u.route.size()>1 and delta.length()<28 and (_course_segment_safe(u.pos,u.route[1].pos,24) if player_craft else segment_safe(u.pos,u.route[1].pos,24)): arrival=28.0
		if delta.length()<arrival:
			if dest.stop and u.vel.length()>2:
				if flowing:
					_current_step(u,dt,(dest.pos-u.pos).limit_length(6.0),thrust_capacity,flow,report_collision,player_craft,ground_cap)
					return
				u.vel=u.vel.move_toward(Vector2.ZERO,100*dt)
				var braking:Vector2=u.pos+u.vel*dt
				if player_craft and not _course_ground_safe(u.pos,braking):_course_collision(u)
				elif not blocked(braking,12): u.pos=braking
				elif course.earned:_course_collision(u,true)
				return
			u.route.pop_front()
			if player_craft: RouteProgram.arrived(u,dest); speed=_craft_speed(u,speed)
			if flowing and dest.stop and u.route.is_empty():u["current_station"]=dest.pos
			if dest.stop: u.vel=u.vel.move_toward(Vector2.ZERO,120*dt)
		if not u.route.is_empty():
			delta=u.route[0].pos-u.pos
			var target_speed=speed
			if u.route[0].stop: target_speed=minf(speed,sqrt(maxf(0,delta.length()-4)*70))
			var target_angle=delta.angle()
			var turn=absf(angle_difference(u.angle,target_angle))
			if turn>0.3: target_speed=minf(target_speed,28.0+35.0*maxf(0,cos(turn)))
			if player_craft and turn>0.3:
				# Reserve hull room for the remaining turn and current momentum.
				# Withhold thrust, retaining normal braking/rotation until the arc fits.
				var maneuver_room=12.0+target_speed*turn/1.8+u.vel.length_squared()/84.0
				if not _course_turn_clear(u.pos,maneuver_room): target_speed=0.0
			if turn>0.15 and (not _course_turn_clear(u.pos,24) if player_craft else blocked(u.pos,24)): target_speed=0.0
			if u.route.size()>1:
				var next_direction:Vector2=u.route[1].pos-u.route[0].pos
				var corner=absf(delta.angle_to(next_direction))
				if corner>0.3: target_speed=minf(target_speed,20+sqrt(delta.length()*35))
			u.angle=rotate_toward(u.angle,target_angle,1.8*dt)
			desired=Vector2.from_angle(u.angle)*target_speed
			if flowing and not (u.route[0].stop and delta.length()<12.0+u.vel.length_squared()/70.0):
				# Cancel crossflow; retain useful assistance/opposition along the leg.
				desired+=flow.project(delta.normalized())
	if flowing:
		if (holding or u.route.is_empty()) and u.has("current_station"):
			desired=((u.current_station-u.pos)*2.0).limit_length(12.0)
		_current_step(u,dt,desired,thrust_capacity,flow,report_collision,player_craft,ground_cap)
		return
	u.vel=u.vel.move_toward(desired,AllStop.decel(u,42.0)*dt)
	var next:Vector2=u.pos+u.vel*dt
	if player_craft and not _course_ground_safe(u.pos,next):
		_course_collision(u);return
	if not blocked(next,12): u.pos=next
	else:
		if course.earned:_course_collision(u,true);return
		if player_craft:_hull_strike(u)
		u.vel=u.vel*COLLISION_SPEED_RETAINED if player_craft and u==units[0] else Vector2.ZERO; u.route.clear()
		if player_craft: RouteProgram.clear(u)
		if report_collision: message="%s autopilot stopped at unsafe terrain. Replot in open water."%u.name
func _observe() -> void:
	for band in 3:
		_use_band(band);_terrain_observe()
	_use_band(units[selected].band)
	Recipient.observe(self);Choir.observe(self)
	if depth_charts.get(1)!=null:pass # Only the unpaused sensor pulse stamps terrain.
	elif mission.has("world_size"):
		for cell in WorldRegion.observation_cells(self):
			# Known water is permanent here. visible() is pure, and setting true
			# again cannot change the archive; unknown/false cells still need sight.
			if known.get(cell,false)==true:continue
			if visible(Vector2(cell)*TILE+Vector2.ONE*TILE/2):known[cell]=true
	else:
		for y in 24:
			for x in 40:
				if known.get(Vector2i(x,y),false)==true:continue
				var p=Vector2(x*40+20,y*40+20)
				if visible(p): known[Vector2i(x,y)]=true
	for i in sirens.size():
		if contact_visible(sirens[i]):
			contacts[i]={"pos":sirens[i].pos,"time":elapsed,"mode":sirens[i].mode,"lock":sirens[i].lock,"angle":sirens[i].angle,"target":sirens[i].target,"type":sirens[i].get("type","patroller"),"band":sirens[i].band,"transition":sirens[i].transition.duplicate(),"source":"optical","confidence":1.0}
			contacts[i]["seen_by"]=passive_receivers(sirens[i].pos,sirens[i].band)
			if mission.get("thermal_revision",0)==1:
				for occupied_band in Depth.occupied(sirens[i]):
					for receiver in passive_receivers(sirens[i].pos,occupied_band):
						if receiver not in contacts[i].seen_by:contacts[i].seen_by.append(receiver)
			if sirens[i].get("recipient_target",false):contacts[i]["recipient_target"]=true
			if sirens[i].get("report",{}).get("charge",0)>0:contacts[i]["report_remaining"]=ContactReports.CHARGE-sirens[i].report.charge
			if sirens[i].get("report",{}).get("sent",0)>0:contacts[i]["report_sent"]=true
			if sirens[i].get("pin_time",0)>0: contacts[i]["pin_time"]=sirens[i].pin_time
	preload("res://src/simulation/observed_stun.gd").record(self)
	for i in sonar.fixes:
		var fix=sonar.fixes[i]
		if not contacts.has(i) or contacts[i].time<fix.time:
			contacts[i]={"pos":fix.pos,"time":fix.time,"mode":"TRIANGULATED","lock":0.0,"angle":0.0,"target":-1,"type":"unknown","band":-1,"seen_by":[],"confidence":fix.confidence,"source":"triangulation"}
	var expired: Array=[]
	for i in contacts:
		if elapsed-contacts[i].time>20: expired.append(i)
	for i in expired: contacts.erase(i)
	ContactIdentity.observe(self)
# Acquisition provenance; active sonar/survey and remote beam warnings are not
# a passive observation by every craft. Main reads the resulting cache only.
func passive_receivers(point:Vector2,band:int=1)->Array:
	var receivers=[]
	for i in units.size():
		var u=units[i]
		if not u.alive:continue
		var radius=passive_range(i)
		if mission.get("thermal_revision",0)==1:radius*=Thermal.transmission(PackedVector2Array([u.pos,point]),Thermal.fronts(mission,band))
		if band in Depth.occupied(u) and u.pos.distance_to(point)<radius and Depth.clear(self,u.pos,point,band):receivers.append(i)
	return receivers
func scout_context(unit_id:int=-1)->Dictionary:
	var id=selected if unit_id<0 else unit_id
	if id<1 or id>=units.size():return {"state":"none","contact":-1}
	var hold=units[id].hold
	return {"state":"armed" if hold==DroneOperations.ARMED else ("stopped" if hold==DroneOperations.STOPPED else ("legacy" if hold=="CONTACT" else "none")),"contact":DroneOperations.local_contact(contacts,id,elapsed)}
# Chart/optical visibility stays independent. Thermal masking affects receiver
# contacts, not terrain knowledge, photography or a visible beam on our craft.
func contact_visible(enemy:Dictionary)->bool:
	if WorldRegion.survey_visible(self,enemy.pos):return true
	for i in units.size():
		var u=units[i];var reach=passive_range(i)*Depth.transmission(u,enemy)
		if mission.get("thermal_revision",0)==1:reach*=Thermal.reception(self,u,enemy)
		if u.alive and u.pos.distance_to(enemy.pos)<reach and Depth.sight(self,u,enemy):return true
	var target=int(enemy.get("target",-1))
	if enemy.get("lock",0)>0 and enemy.get("stun",0)<=0 and target>=0 and target<units.size():
		var craft=units[target]
		return craft.alive and craft.pos.distance_to(enemy.pos)<(180.0 if craft.silent else 290.0)*HuntPressure.sight(mission,enemy,Recon.readiness(enemy)) and Depth.sight(self,craft,enemy)
	return false
func visible(p: Vector2,band:int=1) -> bool:
	if WorldRegion.survey_visible(self,p): return true
	for i in units.size():
		var u=units[i]
		if not u.alive: continue
		var radius=passive_range(i)
		if band in Depth.occupied(u) and u.pos.distance_to(p)<radius and Depth.clear(self,u.pos,p,band): return true

	return false
# Physical steering uses Quietus' own current sensor reach and clear sight only.
# Once sight breaks, aim stays at the last acquired point; no through-rock tracking.
func _advance_projectiles(dt: float) -> void:
	for n in range(projectiles.size()-1,-1,-1):
		var p=projectiles[n]; p.life-=dt
		if p.life<=0: projectiles.remove_at(n); message="Torpedo run ended · shot spent"; continue
		var target=sirens[p.target]; var origin=units[0]
		var reach=240.0*(0.65 if mission.darkness else 1.0)
		if origin.alive and Depth.overlap(p,target) and origin.pos.distance_to(target.pos)<reach and Depth.sight(self,origin,target): p.aim=target.pos
		p.angle=rotate_toward(p.angle,p.pos.angle_to_point(p.aim),TORPEDO_TURN*dt)
		var next=p.pos+Vector2.from_angle(p.angle)*TORPEDO_SPEED*dt
		if not Depth.clear(self,p.pos,next,p.get("band",1),3):
			projectiles.remove_at(n); message="Torpedo struck terrain · shot spent"; continue
		var hit=-1; var nearest=INF
		for id in sirens.size():
			var point=Geometry2D.get_closest_point_to_segment(sirens[id].pos,p.pos,next)
			if Depth.overlap(p,sirens[id]) and point.distance_to(sirens[id].pos)<=18 and point.distance_to(p.pos)<nearest:
				hit=id; nearest=point.distance_to(p.pos)
		if hit>=0:
			var struck=sirens[hit]
			struck.stun=maxf(struck.stun,KNOCK_TIME); struck["pin_time"]=KNOCK_TIME; struck.mode="PINNED"; struck.vel=Vector2.ZERO; struck.lock=0.0; struck.target=-1; struck.erase("recipient_target")
			struck.suspicion=maxf(struck.suspicion,0.45)
			projectiles.remove_at(n)
			if visible(struck.pos):
				message="S%d snared · 8s descent and recovery"%(hit+1); events.append({"type":"snare","pos":next}); _observe()
			continue
		p.pos=next; p.noise_clock=maxf(0,p.noise_clock-dt)
		if p.noise_clock<=0:
			_noise(p.pos,430,"TORPEDO RUN",0.25,p.band); p.noise_clock=0.2
func _threats(dt: float) -> bool:
	var vaporized=false # Per-tick terminal cause survives other actors' messages.
	var observations=[];var fresh=[]
	for s in sirens:
		_use_band(s.band)
		if s.get("type","") in Network.ROLES:
			observations.append(-1);fresh.append(false);continue
		if s.get("type","") in Industry.ROLES:
			Industry.advance(self,s,dt);observations.append(-1);fresh.append(false);continue
		Depth.pursue(self,s)
		if s.get("pin_time",0)>0: s.pin_time=maxf(0,s.pin_time-dt)
		if s.stun>0:
			s.stun-=dt; s.lock=0.0; s.target=-1
			s.erase("recipient_target")
			s.mode="PINNED" if s.get("pin_time",0)>0 else "DISRUPTED"
			observations.append(-1);fresh.append(false)
			continue
		var detected := -1
		var heard := false
		var craft_heard := false # Presentation provenance only; never changes hearing.
		s["attention_time"]=maxf(0.0,float(s.get("attention_time",0.0))-dt)
		for i in units.size():
			var u=units[i]
			if not u.alive: continue
			var dist=s.pos.distance_to(u.pos)
			var radius=(180.0 if u.silent else 290.0)*HuntPressure.sight(mission,s,Recon.readiness(s))
			if dist<radius and Depth.sight(self,s,u): detected=i; break
			if mission.get("acoustic_revision",0)!=1 and propulsion_speed(u)>50 and dist<430*Recon.readiness(s)*Sweeper.ear(s)*Depth.transmission(s,u) and Depth.clear(self,s.pos,u.pos,s.band):
				s.goal=u.pos; heard=true; craft_heard=true; s.mode="INVESTIGATE"; s.suspicion=maxf(s.suspicion,0.3)
		var recipient=Choir.body(self) if not Choir.body(self).is_empty() else Recipient.body(self);var recipient_seen=false
		if detected<0 and not recipient.is_empty() and recipient.alive and s.pos.distance_to(recipient.pos)<180.*HuntPressure.sight(mission,s,Recon.readiness(s)) and Depth.sight(self,s,recipient):recipient_seen=true
		if mission.get("acoustic_revision",0)==1:
			var arrival=_heard_arrival(s)
			if not arrival.is_empty():
				craft_heard=arrival.get("player_craft",false)
				s.goal=arrival.goal;
				if arrival.has("band"):s["known_band"]=arrival.band
				heard=true;s.mode="INVESTIGATE";s.suspicion=maxf(s.suspicion,arrival.suspicion);Recon.heard(s,arrival)
		else:
			for noise in noises:
				var acoustic=1.0 if line_clear(s.pos,noise.pos) else 0.36
				if s.pos.distance_to(noise.pos)<noise.radius*acoustic*Sweeper.ear(s)*Depth.transmission(s,noise):
					craft_heard=noise.label in NoticeSources.CRAFT_EMISSIONS
					s.goal=noise.pos; heard=true; s.mode="INVESTIGATE"; s.suspicion=maxf(s.suspicion,0.45)
		if heard:
			s["last_known"]=s.goal; s["attention_time"]=Sweeper.attention(s); s["search_index"]=0; Sweeper.note_heard(s,s.goal,elapsed)
		if craft_heard or detected>=0:siren_notice.emit(sirens.find(s),s.pos)
		observations.append(detected);fresh.append(heard or detected>=0 or recipient_seen)
		if detected>=0 or recipient_seen:
			var victim=recipient if recipient_seen else units[detected]
			if s.target!=detected or s.get("recipient_target",false)!=recipient_seen:s.lock=0.0
			if recipient_seen:s["recipient_target"]=true
			else:s.erase("recipient_target")
			s["known_band"]=victim.get("transition",{}).get("to",victim.get("band",1))
			Recon.seen(s)
			if Sweeper.stands_to_lock(s): s.route.clear()
			else: _visual_pursuit(s,victim.pos,dt)
			if s.route.is_empty(): s.angle=rotate_toward(s.angle,s.pos.angle_to_point(victim.pos),1.8*dt)
			var previous_lock:float=s.lock
			s.target=detected; s.goal=victim.pos; s["last_known"]=s.goal; s["attention_time"]=Sweeper.attention(s); s["search_index"]=0; s.lock+=dt; s.suspicion=minf(1,s.suspicion+dt*0.3); s.mode="LOCKING" if s.lock<4 else "BEAM"
			if s.lock>=4:
				if previous_lock<4: events.append({"type":"beam","pos":victim.pos})
				if recipient_seen:
					if Choir.applies(mission):Choir.damage(self,dt*18)
					else:Recipient.damage(self,dt*18)
				elif detected==0: hull=0.0; outcome="lost";vaporized=true; message=VAPORIZED_TEXT; events.append({"type":"loss","pos":victim.pos})
				else: units[detected].alive=false; s.lock=0; events.append({"type":"loss","pos":units[detected].pos}); message="%s lost · submarine camera remains available"%units[detected].name
		else:
			s.erase("recipient_target")
			s.target=-1; s.lock=maxf(0,s.lock-dt*3); s.suspicion=maxf(float(s.get("alert_floor",0)),s.suspicion-dt*0.015)
			if not Sweeper.walks_lane(s) or s.get("attention_time",0)>0:
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
		speed=Sweeper.speed(s,speed)
		speed*=1.0+float(s.get("alert_floor",0))*.2
		_move(s,dt,speed,false,false)
	_use_band(1)
	ContactReports.advance(self,observations,fresh,dt)
	_use_band(units[selected].band)
	for guard in sirens:
		if guard.has("report_interest"):Recon.seen(guard)
	return vaporized

func _heard_arrival(s:Dictionary)->Dictionary:
	# Never consult player contacts or a hidden exact destination. A listener
	# receives only supported water-path arrivals; visual acquisition stays separate.
	var best:Dictionary={}
	var recipient=Choir.body(self) if not Choir.body(self).is_empty() else Recipient.body(self)
	if not recipient.is_empty() and recipient.alive and recipient.vel.length()>1:
		var arrival=Acoustics.choose(Thermal.arrivals(self,s,recipient.pos,recipient.vel.length_squared()*.12*Recon.readiness(s)*Sweeper.ear(s)*Depth.transmission(s,recipient),recipient),int(s.patrol))
		if not arrival.is_empty():best=arrival;best["suspicion"]=0.3
	for u in units:
		if not u.alive:continue
		var arrival=Acoustics.choose(Thermal.arrivals(self,s,u.pos,motion_radius(units.find(u))*Recon.readiness(s)*Sweeper.ear(s)*Depth.transmission(s,u),u),int(s.patrol))
		if not arrival.is_empty() and (best.is_empty() or arrival.strength>best.strength):
			best=arrival;best["suspicion"]=0.3;best["player_craft"]=true
	for noise in noises:
		if noise.label in ["BUOY REPORT WINDUP","RELAY FORWARD","INTERCEPTOR WINDUP","WARDEN CHARGE","WARDEN PRESSURE"]:continue
		var arrival=Acoustics.choose(Thermal.arrivals(self,s,noise.pos,noise.radius*Recon.readiness(s)*Sweeper.ear(s)*Depth.transmission(s,noise),noise),int(s.patrol))
		if not arrival.is_empty() and (best.is_empty() or arrival.strength>best.strength):
			best=arrival;best["suspicion"]=0.45;best["pulse"]=true;best["player_craft"]=noise.label in NoticeSources.CRAFT_EMISSIONS
			if noise.has("record"):best["record"]=noise.record
			if noise.label in ["ACTIVE SONAR","ACTIVE SWEEP"] and arrival.direct:best["band"]=noise.get("band",1)
	return best

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
		var role_senses= Sweeper.profile(s)
		# Sentinel approaches fresh evidence normally, then holds and scans that
		# reached station. Tether/return and renewed sound remain authoritative.
		if role_senses.search_hold:
			s.route.clear()
			s.angle=wrapf(s.angle+float(role_senses.search_turn_speed)*dt,-PI,PI)
			return
		# Search the observed area, never the pilot's now-hidden location.
		if not heard:
			var center:Vector2=s.get("last_known",s.goal)
			var points:int=role_senses.search_points
			for attempt in points:
				var index=int(s.get("search_index",0)); s["search_index"]=index+1
				var point=center+Vector2.from_angle(index*TAU/points)*float(role_senses.search_radius)
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
	if not Glass.complete(self) or not Choir.complete(self):return false
	if not Shelf.complete(self):return false
	if not Recipient.complete(self):return false
	if not Witness.complete(self):return false
	if not Concealed.complete(self):return false
	if not Chain.complete(self):return false
	if not Delivery.complete(self):return false
	for id in mission.get("required_site_ids",[]):
		if not mission.objectives.any(func(o):return o.get("site_id","")==id and o.captured):return false
	for o in mission.objectives:
		if not o.captured and not o.get("optional",false): return false
	return true
func wake_context()->Dictionary:return Wake.context(self)
func snapshot() -> Dictionary:
	mission["depth_charts"]={}
	for band in [0,2]:mission.depth_charts[band]=depth_charts[band].snapshot()
	var data={"sonar":sonar.duplicate(true),"mission":mission.duplicate(true),"units":units.duplicate(true),"sirens":sirens.duplicate(true),"known":known.duplicate(true),"contacts":contacts.duplicate(true),"noises":noises.duplicate(true),"elapsed":elapsed,"oxygen":oxygen,"hull":hull,"paused":paused,"selected":selected,"tools":tools.duplicate(),"outcome":outcome,"ping_time":ping_time,"ping_origin":ping_origin,"recon_time":recon_time,"captures":captures.duplicate(true)}
	if not correlation.is_empty():data["correlation"]=correlation.duplicate(true)
	if not projectiles.is_empty(): data["projectiles"]=projectiles.duplicate(true)
	return data
func restore(data: Dictionary) -> bool:
	if not valid_snapshot(data): return false
	sonar=data.sonar.duplicate(true)
	correlation=data.get("correlation",{}).duplicate(true)
	mission=data.mission.duplicate(true); units=data.units.duplicate(true); sirens=data.sirens.duplicate(true); known=data.known.duplicate(true); contacts=data.get("contacts",{}).duplicate(true); noises=data.get("noises",[]).duplicate(true); projectiles=data.get("projectiles",[]).duplicate(true)
	elapsed=float(data.get("elapsed",0)); oxygen=float(data.get("oxygen",100)); hull=float(data.get("hull",100)); selected=clampi(int(data.get("selected",0)),0,2); tools=data.tools.duplicate(); outcome=data.get("outcome",""); paused=true; queue_mode=false
	ping_time=data.get("ping_time",0.0); ping_origin=data.get("ping_origin",Vector2.ZERO); recon_time=data.get("recon_time",0.0); captures=data.captures.duplicate(true); accumulator=0.0
	_build_navigation(); _configure_terrain(); _configure_depth_charts(); message="Mission restored · paused for review"; return true

static func valid_snapshot(data: Dictionary) -> bool:
	if not data.has_all(["mission","units","sirens","known","tools"]): return false
	if not data.mission is Dictionary or not data.units is Array or not data.sirens is Array or not data.known is Dictionary or not data.tools is Dictionary: return false
	if not data.mission.get("id") is int or data.mission.id not in Missions.Catalog.registered_ids():return false
	if not SaveChecks.valid(data,"initial"):return false
	if data.mission.has("launch_equipment") and (not Equipment.valid_fitting(data.mission.launch_equipment) or not data.mission.launch_equipment.has_all(Equipment.SLOTS)):return false
	if data.mission.has("consequence_revision"):
		if data.mission.consequence_revision!=Missions.Catalog.make(data.mission.id).get("consequence_revision",-1):return false
		if Rendezvous.applies(data.mission):
			var ref=data.mission.get("measured_reference",null)
			if not ref is Array or (not ref.is_empty() and (ref!=[0.8,1.6,0.8] or not data.mission.objectives.any(func(o):return o.get("site_id","")=="rendezvous" and o.captured))):return false
	if not SaveChecks.valid(data,"features"):return false
	if not data.mission.has_all(["id","rocks","objectives","extraction","title","darkness","depth"]): return false
	if not data.mission.id is int or data.mission.id not in Missions.Catalog.registered_ids(): return false
	if not data.mission.rocks is Array or not data.mission.objectives is Array or not data.mission.extraction is Vector2: return false
	for r in data.mission.rocks:
		if not PolygonContainment.valid_shape(r): return false
	if data.mission.has("structures"):
		if not data.mission.structures is Array: return false
		for structure in data.mission.structures:
			if not structure is Rect2: return false
	for o in data.mission.objectives:
		if not o is Dictionary or not o.has_all(["pos","name","captured"]) or not o.pos is Vector2: return false
	if not data.get("captures") is Array or data.captures.size()!=3:return false
	if not SaveChecks.valid(data,"photo"):return false
	var exposed=[]
	for id in data.captures.size():
		var work=data.captures[id]
		if not work is Dictionary:return false
		if work.is_empty():continue
		if work.size()!=2 or not work.has_all(["target","elapsed"]) or not work.target is int or work.target<0 or not Photo.target_valid(data.mission,work.target) or work.target in exposed:return false
		if not (work.elapsed is float or work.elapsed is int) or not is_finite(float(work.elapsed)) or work.elapsed<0:return false
		var site=Photo.target_in(data.mission,work.target)
		var duration=Sampler.capture_spec(id,data.mission.get("launch_equipment",{}),site).get("duration",site.get("duration",4.0))
		if work.elapsed>duration or (site.captured and not Photo.applies(site) and not Operations.own_origin(site) and not (Delivery.applies(data.mission))):return false
		exposed.append(work.target)
	if not SaveChecks.valid(data,"world"):return false
	if data.mission.get("earned_terrain",false):
		if not data.mission.get("launch_seed") is Rect2 or not TerrainChart.valid_state(data.mission.get("terrain_chart"),data.mission):return false
	if data.mission.get("expedition_revision",0)==2:
		if not Consequences.valid_mission(data.mission,float(data.get("elapsed",0))):return false
	elif not SignalField.valid(data.mission,float(data.get("elapsed",0))):return false
	if not SaveChecks.valid(data,"transport"):return false
	if data.mission.has("acoustic_revision") and (not data.mission.acoustic_revision is int or data.mission.acoustic_revision!=1):return false
	if data.mission.has("well_revision"):
		if data.mission.id!=4 or not data.mission.well_revision is int or data.mission.well_revision!=1 or data.mission.objectives.size()!=3 or not data.mission.get("well_reference") is Dictionary or not data.mission.get("well_observation") is Dictionary:return false
		var reference=data.mission.well_reference;var observation=data.mission.well_observation;var time=data.get("elapsed",0.0)
		if not (time is float or time is int) or not is_finite(float(time)) or time<0:return false
		if not reference.is_empty():
			if not reference.has_all(["time","speed","pos"]) or not reference.pos is Vector2 or not reference.pos.is_finite():return false
			for key in ["time","speed"]:
				if not (reference[key] is float or reference[key] is int) or not is_finite(float(reference[key])):return false
			if reference.time<0 or reference.time>time or reference.speed<=50:return false
		if not observation.is_empty():
			if reference.is_empty() or not observation.has_all(["time","unit","pos"]) or not observation.pos is Vector2 or not observation.pos.is_finite():return false
			if not observation.unit is int or observation.unit<0 or observation.unit>2:return false
			if not (observation.time is float or observation.time is int) or not is_finite(float(observation.time)) or observation.time<reference.time or observation.time>time:return false
	if data.mission.has("blackwater_revision"):
		if not Missions.Catalog.supports(data.mission.id,"packet_delivery") or not data.mission.blackwater_revision is int or data.mission.blackwater_revision!=1 or data.mission.objectives.size()!=2:return false
		var time=data.get("elapsed",0.0)
		if not (time is float or time is int) or not is_finite(float(time)) or time<0:return false
		for o in data.mission.objectives:
			if o.get("kind","")!="exchange" or o.get("duration",0)!=2.0:return false
			var until=o.get("replay_until",null)
			if not (until is float or until is int) or not is_finite(float(until)) or until<0 or until>time+3.001:return false
	if data.has("projectiles"):
		if not data.projectiles is Array or data.projectiles.size()>2 or (not data.projectiles.is_empty() and not data.tools.has("knock")): return false
		for p in data.projectiles:
			if not p is Dictionary or not p.has_all(["pos","angle","target","aim","life","noise_clock","band"]) or not p.band is int or p.band not in [0,1,2]: return false
			if not p.pos is Vector2 or not p.pos.is_finite() or not p.aim is Vector2 or not p.aim.is_finite(): return false
			if p.pos.x<0 or p.pos.y<0 or p.pos.x>WorldRegion.size_of(data.mission).x or p.pos.y>WorldRegion.size_of(data.mission).y: return false
			if not p.target is int or p.target<0 or p.target>=data.sirens.size(): return false
			for key in ["angle","life","noise_clock"]:
				if not (p[key] is float or p[key] is int) or not is_finite(p[key]): return false
			if p.life<=0 or p.life>TORPEDO_LIFE or p.noise_clock<0 or p.noise_clock>0.201: return false
	if data.units.size()!=3 or not data.tools.has_all(["emp","decoy","recon"]): return false
	# 070: existing expedition resupply can carry more charges; physical projectile
	# limits remain above. ModeActive also validates the actual ledger budget.
	var knock_cap=FieldTools.stock_cap(data.mission,2)
	if data.tools.has("knock") and (not data.tools.knock is int or data.tools.knock<0 or data.tools.knock>knock_cap): return false
	if data.has("projectiles") and data.projectiles.size()+data.tools.get("knock",0)>knock_cap: return false
	for u in data.units:
		if not u is Dictionary or not u.has_all(["pos","vel","angle","route","alive","hold","silent","battery","name"]): return false
		if not u.pos is Vector2 or not u.vel is Vector2 or not u.route is Array: return false
		if u.has("hit_at") and (not Sonar._number(u.hit_at) or u.hit_at<0 or u.hit_at>data.get("elapsed",0.)):return false
		for w in u.route:
			if not w is Dictionary or not w.has_all(["pos","stop"]) or not w.pos is Vector2: return false
		if not RouteProgram.valid_unit(u,u==data.units[0],WorldRegion.size_of(data.mission)): return false
		if not AllStop.valid(u) or (u!=data.units[0] and u.has("all_stop")): return false
	for e in data.sirens:
		if not Sweeper.valid(e,float(data.get("elapsed",0))):return false
		if not e is Dictionary or not e.has_all(["pos","home","goal","vel","route","angle","mode","suspicion","stun","lock","target","patrol","path_time"]): return false
		if e.has("pin_time"):
			if not (e.pin_time is float or e.pin_time is int) or not is_finite(e.pin_time) or e.pin_time<0 or e.pin_time>KNOCK_TIME: return false
			if e.pin_time>0 and (not (e.stun is float or e.stun is int) or not is_finite(e.stun) or e.stun+0.001<e.pin_time): return false
		if e.has("type") and e.type not in EnemyTypes.ALL: return false
		if e.has("tether") and (not (e.tether is float or e.tether is int) or e.tether<=0): return false
		if e.has("attention_time") and (not (e.attention_time is float or e.attention_time is int) or e.attention_time<0): return false
		if e.has("last_known") and not e.last_known is Vector2: return false
		if e.has("search_index") and (not e.search_index is int or e.search_index<0): return false
		if e.has("patrol_points"):
			if not e.patrol_points is Array or not e.get("patrol_index",0) is int or e.get("patrol_index",0)<0: return false
			for point in e.patrol_points:
				if not point is Vector2: return false
	return true

static func rock_polygon(r) -> PackedVector2Array:
	if r is PackedVector2Array:return r
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

func _record_secured(record: Dictionary,unit_id:int=-1) -> void:
	_record_secured_core(record,unit_id)
	if not record.has("siren"):message+=GradeOnSecure.note(record)
func _record_secured_core(record: Dictionary,unit_id:int=-1) -> void:
	if record.has("siren"):
		# A Siren study is film, not a charted record: it never advances an operation's own record logic.
		Recon.secured(self,record,unit_id);events.append({"type":"record","pos":record.pos});message="Siren study filed · review it in FIELD RECORDS"
		return
	preload("res://src/campaign/sorley_rescue.gd").recorded(self,record)
	Glass.recorded(self,record,unit_id)
	Recon.secured(self,record,unit_id)
	if Rendezvous.applies(mission) and mission.get("consequence_revision",0)==1 and record.get("site_id","")=="rendezvous":mission["measured_reference"]=mission.signal_sources[0].cadence.duplicate()
	if mission.get("expedition_revision",0)==2:Operations.complete(self,record)
	events.append({"type":"record","pos":record.pos})
	message="Warning sent from this origin · listen for a reply from another position; retransmission remains available" if Operations.own_origin(record) else "Record secured. Return Quietus to extraction." if all_records() else "Record secured. Continue the survey."
	if mission.get("well_revision",0)==1 and record==mission.objectives[0]:
		message="Pattern record secured · optional moving Quietus comparison explained in recovered records"
	if mission.get("blackwater_revision",0)==1:
		if record==mission.objectives[0]:Courier.launch(self)
		message="Exchange matched · ancient ocean archive aboard · return Quietus home" if all_records() else ("REQUEST decoded · REPLY accepts SONAR replay within 240m; or approach quietly" if record.name=="REQUEST RELAY" else "REPLY decoded · ancient temperatures · REQUEST accepts SONAR replay within 240m")
		if mission.get("courier_revision",0)==1 and record==mission.objectives[0] and not all_records():message="REQUEST decoded · southern REPLY CARRIER announced · intercept + SAMPLE, or SONAR / quiet eastern relay"
		Delivery.sampled(self,mission.objectives.find(record),unit_id)
	if mission.id==5 and record.get("kind","")=="receiver":
		mission["phase"]="warning"; message="Bearings decoded: every loud site on this coast the night of the strike. Bring Quietus and this packet home."
	if mission.id==3:
		message="Furnace record secured. Review observations in FIELD RECORDS."
		if all_records() and mission.get("phase","")!="response":
			mission["phase"]="response"; mission["response_time"]=0.0
			var origin:Vector2=mission.objectives[1].pos
			_noise(origin,1150,"FACTORY RESPONSE",8.0); events.append({"type":"factory","pos":origin})
			message="The Siren base answers the camera. A heavy pulse from its frames · plan your recovery route."

func nearest_navigation_cell(point: Vector2) -> Vector2i:
	var cells=WorldRegion.grid_size(mission)
	var center=Vector2i(clampi(int(point.x/40),0,cells.x-1),clampi(int(point.y/40),0,cells.y-1))
	var best=Vector2i(-1,-1); var distance=INF
	for y in range(maxi(0,center.y-2),mini(cells.y,center.y+3)):
		for x in range(maxi(0,center.x-2),mini(cells.x,center.x+3)):
			var cell=Vector2i(x,y)
			if navigation.is_point_solid(cell): continue
			var candidate=Vector2(x*40+20,y*40+20)
			var d=candidate.distance_squared_to(point)
			if d<distance and segment_safe(candidate,point,24): best=cell; distance=d
	return best
