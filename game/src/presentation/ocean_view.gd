extends Control
const HullBand=preload("res://src/presentation/route_clearance/hull_band.gd")
const Shelf=preload("res://src/presentation/shelf_habitat_view.gd")
const Priced=preload("res://src/presentation/photo_pricing/photo_pricing_overlay.gd")
const RuleOverlay=preload("res://src/photo_rules/rule_overlay.gd")
const Wake=preload("res://src/presentation/wake_crossing_view.gd")
const Recipient=preload("res://src/presentation/warning_recipient_view.gd")
const Concealed=preload("res://src/presentation/concealed_harbour_view.gd")
const Witness=preload("res://src/presentation/witness_evacuation_view.gd")
const EarnedChart=preload("res://src/presentation/earned_chart_view.gd")
const Expedition=preload("res://src/presentation/expedition_view.gd")
const Confluence=preload("res://src/presentation/confluence_world.gd")
const WarningChain=preload("res://src/presentation/warning_chain_view.gd")
const Rendezvous=preload("res://src/presentation/rendezvous_view.gd")
var sim
var presenting_mission=true
var optical_feed
var goal_marker
var siren_ray=preload("res://assets/craft/siren_ray.png")
var phase := 0.0
var world_scale := 1.0
var world_offset := Vector2.ZERO
var ocean: ImageTexture
var rocks: Array = []
var foundry=preload("res://assets/structures/foundry.png")
var quietus=preload("res://assets/craft/quietus.png")
var basalt=preload("res://assets/materials/basalt.png")
var camera_flash := 0.0
var decoy_targeting:=false
var knock_targeting:=false
var knock_touch_size:=48.0
var feedback_font_size:=14
var instrument_top:=64.0
var ui_blocked_rects:Array=[]
var instrument_height=48.
var oxygen_capacity=100.
var fleet_instruments
var warnings_in_hud=false
var chart_camera=preload("res://src/presentation/chart_camera.gd").new()
const CYAN := Color("72d9d3")
const INK := Color("07141c")
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	clip_contents=true
	texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
	optical_feed=preload("res://src/presentation/camera_feed.gd").new(); add_child(optical_feed)
	goal_marker=preload("res://src/presentation/goal_bearing/goal_bearing.gd").new();goal_marker.ocean=self;add_child(goal_marker)
	var noise=FastNoiseLite.new()
	noise.seed=7319; noise.frequency=0.024; noise.fractal_octaves=4
	var img=Image.create(800,480,false,Image.FORMAT_RGB8)
	for y in 480:
		for x in 800:
			var n=noise.get_noise_2d(x,y)*0.5+0.5
			var trench=sin(x*0.014+y*0.007+noise.get_noise_2d(x*0.5,y*0.5)*4)*0.5+0.5
			img.set_pixel(x,y,Color(0.025+n*0.028,0.065+n*0.075+trench*0.015,0.085+n*0.075))
	ocean=ImageTexture.create_from_image(img)
func map_position(screen: Vector2) -> Vector2:
	_sync_camera(); return chart_camera.to_world(screen)
func screen_position(world: Vector2) -> Vector2:
	_sync_camera(); return chart_camera.to_screen(world)
func world_size() -> Vector2:
	return sim.world_size() if sim!=null and sim.has_method("world_size") else Vector2(1600,960)
func observable_sites() -> Array:
	return sim.observable_sites() if sim.has_method("observable_sites") else sim.mission.objectives
# The same observable site targets used by picking must remain reachable
# beneath projected station handles. Fixed unseen sites are excluded here.
func objective_touch_rects(touch:float)->Array:
	_sync_camera();var result:Array=[]
	var radius=maxf(touch*.5,38*world_scale)
	for site in observable_sites():
		if sim.mission.id==8:continue
		if Rendezvous.replaces_site(sim,site) or Witness.replaces_site(sim,site) or Recipient.replaces_site(sim,site) or site.get("own_origin",false):continue
		result.append(Rect2(screen_position(site.pos)-Vector2.ONE*radius,Vector2.ONE*radius*2))
	result.append_array(Witness.touch_rects(self,sim,touch))
	result.append_array(Concealed.touch_rects(self,sim,touch))
	result.append_array(Recipient.touch_rects(self,sim,touch))
	result.append_array(preload("res://src/presentation/industrial_view.gd").touch_rects(self,sim,touch))
	return result
func pick_context(point:Vector2,touch:float) -> Dictionary:
	_sync_camera();var choices=[]
	var industrial=preload("res://src/presentation/industrial_view.gd").pick(self,sim,point,touch)
	if not industrial.is_empty():return industrial
	if sim.mission.has("glass_reach") and sim.mission.glass_reach.artifact.is_empty():
		var pos=sim.mission.glass_reach.work_pos
		if point.distance_to(screen_position(pos))<maxf(touch*.5,24*world_scale):return {"kind":"objective","subkind":"glass_work","name":"REACH MACHINERY","pos":pos}
	for marker in salvage_markers():
		if marker.rect.has_point(point):return {"kind":"salvage","item":marker.site.item,"name":marker.site.name.to_upper(),"pos":marker.site.pos}
	var shelter=Shelf.pick(self,sim,point,touch,false)
	if not shelter.is_empty():return shelter
	var recipient=Recipient.pick(self,sim,point,touch,false)
	if not recipient.is_empty():return recipient
	var tender=Rendezvous.pick(self,sim,point,touch,false)
	if not tender.is_empty():return tender
	for id in sim.units.size():
		var u=sim.units[id]
		if not u.alive:continue
		var local=(point-screen_position(u.pos)).rotated(-u.angle)
		var half=Vector2(66,18)*world_scale if id==0 else Vector2(18,8)*world_scale
		if Rect2(-half,half*2).grow(touch*.32).has_point(local):choices.append(id)
	if choices.size()>1:return {"kind":"fleet","pos":map_position(point)}
	if choices.size()==1:return {"kind":"craft","unit":choices[0],"pos":sim.units[choices[0]].pos}
	tender=Rendezvous.pick(self,sim,point,touch)
	if not tender.is_empty():return tender
	return objective_context(point,touch)
func objective_context(point:Vector2,touch:float)->Dictionary:
	var wake=Wake.pick(self,sim,point,touch)
	if not wake.is_empty():return wake
	var shelter=Shelf.pick(self,sim,point,touch)
	if not shelter.is_empty():return shelter
	var recipient=Recipient.pick(self,sim,point,touch)
	if not recipient.is_empty():return recipient
	var work=Concealed.pick(self,sim,point,touch)
	if not work.is_empty():return work
	var witness=Witness.pick(self,sim,point,touch)
	if not witness.is_empty():return witness
	# Fixed public sites share their marker's actual hit area with fleet rings.
	for id in observable_sites().size():
		var site=observable_sites()[id]
		if sim.mission.id==8:continue
		if Rendezvous.replaces_site(sim,site) or Witness.replaces_site(sim,site) or Recipient.replaces_site(sim,site):continue
		if site.get("own_origin",false):continue
		if point.distance_to(screen_position(site.pos))<=maxf(touch*.5,38*world_scale):return {"kind":"objective","subkind":"actuator","index":id,"name":site.name,"pos":site.pos} if site.get("site_id","")=="witness_sluice" else {"kind":"objective","index":id,"name":site.name,"pos":site.pos}
	return Expedition.pick(self,sim,point,touch)
func salvage_markers()->Array:
	return preload("res://src/presentation/module_recovery_view.gd").markers(self,sim,instrument_height)
func _sync_camera() -> void:
	chart_camera.configure(size,world_size())
	if chart_camera.mode=="follow" and sim!=null:chart_camera.follow(sim.units[sim.selected].pos)
	world_scale=chart_camera.scale;world_offset=chart_camera.offset
func focus_craft() -> void:
	if sim==null:return
	chart_camera.follow(sim.units[sim.selected].pos);_sync_camera();queue_redraw()
func zoom_at(factor: float,anchor: Vector2) -> void:
	_sync_camera(); chart_camera.zoom_at(factor,anchor); _sync_camera(); queue_redraw()
func pan_chart(delta: Vector2) -> void:
	_sync_camera(); chart_camera.pan(delta); _sync_camera(); queue_redraw()
func fit_chart() -> void:
	chart_camera.fit(); _sync_camera(); queue_redraw()
func _process(dt: float) -> void:
	phase+=dt; camera_flash=maxf(0,camera_flash-dt);_sync_camera()
	if optical_feed!=null:
		optical_feed.sim=sim; optical_feed.visible=presenting_mission and sim!=null and sim.outcome.is_empty() and optical_feed.viewfinder_visible(sim)
		var height=minf(maxf(300,optical_feed.touch_height*4.8),size.y-instrument_top-54)
		optical_feed.size=Vector2(minf(size.x-28,maxf(480,optical_feed.touch_height*7.5)),height)
		optical_feed.position=Vector2(14,maxf(instrument_top+40,size.y-height-14))
	queue_redraw()
func acoustic_rows() -> Array:
	return preload("res://src/presentation/acoustic_feedback.gd").rows(sim.acoustic_feedback()) if sim!=null else []
func contact_entries() -> Array:
	return preload("res://src/presentation/contact_feedback.gd").entries(sim.contacts,sim.elapsed,sim.units,sim.line_clear,sim.contact_target) if sim!=null else []
func contact_readout_entries() -> Array:
	return contact_entries().filter(func(entry):return not warnings_in_hud or not (entry.urgent or (entry.fresh and ("REPORT" in entry.text or "STUNNED" in entry.text))))
func contact_readout_rects() -> Array:
	var result: Array=[]
	var top=instrument_top+10
	for entry in contact_readout_entries():
		var width=ThemeDB.fallback_font.get_string_size(entry.text,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size).x+20
		result.append(Rect2(12,top,minf(width,size.x-24),feedback_font_size+6))
		top+=feedback_font_size+8
	return result
func knock_visible_targets() -> Array:
	var targets=[]
	if not knock_targeting or sim==null:return targets
	for c in sim.knockdown_targets():
		var anchor=screen_position(c.pos)
		if Rect2(Vector2.ZERO,size).has_point(anchor):targets.append({"key":c.key,"tag":c.tag,"anchor":anchor})
	targets.sort_custom(func(a,b):return a.key<b.key)
	return targets
func knock_aim_targets() -> Array:
	var targets=knock_visible_targets()
	if targets.is_empty():return []
	var blocked=ui_blocked_rects.duplicate();blocked.append(Rect2(0,0,size.x,instrument_top))
	for box in contact_readout_rects():blocked.append(box.grow(4))
	if optical_feed!=null and optical_feed.visible:blocked.append(optical_feed.get_rect().grow(6))
	for u in sim.units:
		if u.alive:blocked.append(Rect2(screen_position(u.pos)-Vector2(85,45)*world_scale,Vector2(170,90)*world_scale).grow(6))
	for target in targets:blocked.append(Rect2(target.anchor-Vector2.ONE*90*world_scale,Vector2.ONE*180*world_scale).grow(6))
	for objective in observable_sites():
		var anchor=screen_position(objective.pos)
		blocked.append(Rect2(anchor-Vector2.ONE*43*world_scale,Vector2.ONE*86*world_scale).grow(4))
		if not objective.captured:
			var font=maxi(17,int(12/world_scale));var width=ThemeDB.fallback_font.get_string_size(objective.name,HORIZONTAL_ALIGNMENT_LEFT,-1,font).x*world_scale
			blocked.append(Rect2(screen_position(objective.pos+Vector2(50,-5))-Vector2(0,font*world_scale),Vector2(width,font*world_scale+6)).grow(4))
	for u in sim.units:
		var previous=screen_position(u.pos)
		for node in u.route:
			var next=screen_position(node.pos)
			blocked.append(Rect2(Vector2(minf(previous.x,next.x),minf(previous.y,next.y)),Vector2(absf(next.x-previous.x),absf(next.y-previous.y))).grow(8));previous=next

	for entry in contact_entries():
		if not entry.urgent:continue
		var c=sim.contacts[entry.key];var aim=screen_position(sim.contact_target(c).pos);var anchor=screen_position(c.pos)
		blocked.append(Rect2(Vector2(minf(anchor.x,aim.x),minf(anchor.y,aim.y)),Vector2(absf(anchor.x-aim.x),absf(anchor.y-aim.y))).grow(8))
	return preload("res://src/presentation/torpedo_aim.gd").layout(targets,Rect2(Vector2.ONE*8,size-Vector2.ONE*16),knock_touch_size,blocked)
func knock_aim_key(point:Vector2) -> int:
	for aim in knock_aim_targets():
		if aim.rect.has_point(point):return aim.key
	var hits=[]
	for target in knock_visible_targets():
		if point.distance_to(target.anchor)<knock_touch_size/2:hits.append(target.key)
	# A broad phone hit area cannot infer intent between overlapping bodies.
	return hits[0] if hits.size()==1 else -1
func _draw() -> void:
	if sim==null or ocean==null: return
	_sync_camera()
	draw_rect(Rect2(Vector2.ZERO,size),Color("050f17"))
	draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	var region=sim.world_size()
	var earned=EarnedChart.chart(sim)
	draw_texture_rect_region(ocean,Rect2(Vector2.ZERO,region),Rect2(Vector2.ZERO,region/2.0))
	# Cartographic graticule, subordinate to the physical water and stone.
	for x in range(0,int(region.x)+1,160):
		draw_line(Vector2(x,0),Vector2(x,region.y),Color(0.3,0.65,0.67,0.06),1)
	for y in range(0,int(region.y)+1,160):
		draw_line(Vector2(0,y),Vector2(region.x,y),Color(0.3,0.65,0.67,0.06),1)
	# Depth contours and abyssal fissures occupy the navigable seabed.
	for n in (int(ceil(region.y/135.0)) if earned.is_empty() else 0):
		var points=PackedVector2Array()
		for k in int(ceil(region.x/38.0))+1:
			points.append(Vector2(k*38,80+n*135+sin(k*0.19+n)*32))
		draw_polyline(points,Color(0.12,0.3,0.33,0.11),1.2)
	# Briefed environment only; no listener positions or hidden arrival paths.
	# Kept below stone, fog, craft and the foreground charging/beam warnings.
	if sim.mission.get("thermal_revision",0)==1 and sim.mission.id!=8:
		for front in sim.mission.thermal_fronts:
			var area:Rect2=front.area
			draw_rect(area,Color(0.22,0.54,0.7,0.07))
			draw_rect(area,Color(0.36,0.66,0.78,0.38),false,1.2/world_scale)
			_label(area.position+Vector2(120,106),str(sim.mission.get("photo_lane","COLD FRONT")),Color(0.46,0.7,0.78,0.8),14)
	_draw_departure()
	# Bedrock and columnar basalt are original deterministic constructions.
	if earned.is_empty():
		for r in (sim.mission.get("depth_geometry",{}).get(sim.units[sim.selected].band,{}).get("rocks",sim.mission.rocks) if sim.mission.id!=8 else []): _rock(r)
	elif sim.mission.id==11:
		Confluence.draw_terrain(self,earned,world_scale,Rect2(-world_offset/world_scale,size/world_scale))
		if sim.has_method("confluence_context"):
			var context=sim.confluence_context();context["surface_segments"]=earned.get("surface_segments",[])
			Confluence.draw_landmarks(self,context,world_scale)
	else:EarnedChart.draw_terrain(self,earned,world_scale)
	Shelf.draw_ground(self,sim)
	if not presenting_mission or not sim.outcome.is_empty():
		draw_set_transform(Vector2.ZERO)
		return
	for o in sim.mission.get("photo",{}).get("studies",[]):
		if o.captured:_siren_mark(o)
	for h in sim.mission.get("photo_hidden",[]):
		if h.has("lead") and not h.get("found",false):_lead_area({"pos":h.pos+h.lead.get("off",Vector2.ZERO),"lead_r":float(h.lead.get("r",200.0)),"name":str(h.lead.get("alias","UNKNOWN RETURN"))})
	for o in observable_sites():
		if sim.mission.id==8:continue
		if o.get("own_origin",false):continue
		if o.has("siren"):continue
		if o.get("stage","")=="lead":_lead_area(o);continue
		if Wake.replaces_site(sim,o) or Rendezvous.replaces_site(sim,o) or WarningChain.replaces_site(sim,o) or Witness.replaces_site(sim,o) or Recipient.replaces_site(sim,o):continue
		if o.get("kind","")=="receiver":
			draw_arc(o.pos,26,0,TAU,40,Color("80bdb6"),2)
			draw_line(o.pos-Vector2(17,0),o.pos+Vector2(17,0),Color("80bdb6"),2)
			draw_line(o.pos-Vector2(0,17),o.pos+Vector2(0,17),Color("80bdb6"),2)
		else: _installation(o.pos,o.captured)
	if earned.is_empty() and sim.mission.has("factory_rect"):
		var mass:Rect2=sim.mission.factory_rect
		draw_rect(mass,Color("102630")); draw_rect(mass,Color("486268"),false,3)
		draw_set_transform(world_offset+mass.get_center()*world_scale,PI/2,Vector2.ONE*world_scale)
		draw_texture_rect(foundry,Rect2(-mass.size.y/2,-mass.size.x/2,mass.size.y,mass.size.x),false,Color(0.8,0.95,1))
		draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	elif earned.is_empty() and sim.mission.has("array_rect"):
		_finale_array(sim.mission.array_rect)
	elif earned.is_empty() and sim.mission.id in [3,4]:
		draw_texture_rect(foundry,Rect2(1080,-100,540,360),false,Color(0.65,0.8,0.82,0.8))
	# Intelligence marks are briefed coordinates, not live contact observations.
	for o in observable_sites():
		if sim.mission.id==8:continue
		if o.get("own_origin",false) or o.has("siren") or o.get("stage","")=="lead":continue
		if Wake.replaces_site(sim,o) or Rendezvous.replaces_site(sim,o) or WarningChain.replaces_site(sim,o) or Witness.replaces_site(sim,o) or Recipient.replaces_site(sim,o):continue
		var c=CYAN if o.captured else Color("e1b66e")
		draw_arc(o.pos,43,0,TAU,40,Color(c,0.35),1.4)
		draw_line(o.pos+Vector2(-14,0),o.pos+Vector2(14,0),c,1)
		draw_line(o.pos+Vector2(0,-14),o.pos+Vector2(0,14),c,1)
		if not o.captured: _label(o.pos+Vector2(50,-5),"SLUICE CONTROL" if o.get("site_id","")=="witness_sluice" else o.name,c,17)
	# Physical chart is retained. Unknown water, shadows, and contact memory remain separate.
	var low=Vector2i((-world_offset/world_scale)/40.0).max(Vector2i.ZERO)
	var high=Vector2i((size-world_offset)/world_scale/40.0)+Vector2i.ONE
	high=high.min(Vector2i(region/40.0))
	for y in (range(low.y,high.y) if earned.is_empty() else []):
		for x in range(low.x,high.x):
			var key=Vector2i(x,y); var p=Vector2(x*40+20,y*40+20)
			var alpha=0.38 if not sim.known.has(key) else (0.0 if sim.visible(p) else 0.20)
			if alpha>0: draw_rect(Rect2(x*40,y*40,40,40),Color(0.005,0.014,0.025,alpha))
	preload("res://src/presentation/blackwater_courier_view.gd").draw(self,sim)
	Shelf.draw_world(self,sim)
	Wake.draw(self,sim)
	Rendezvous.draw(self,sim)
	WarningChain.draw_world(self,sim)
	Witness.draw_world(self,sim)
	Concealed.draw_world(self,sim)
	Recipient.draw_world(self,sim)
	# Sonar rays stop at actual cover, producing explicit acoustic shadows.
	if earned.is_empty() and sim.ping_time>0:
		var radius=(3.5-sim.ping_time)*210
		for n in 180:
			var direction=Vector2.from_angle(n*TAU/180)
			var end=sim.ping_origin+direction*radius
			if sim.line_clear(sim.ping_origin,end): draw_line(end-direction*6,end,Color(0.3,0.95,0.88,sim.ping_time/5),2)
	var ex=sim.mission.extraction
	if not Expedition.active(sim) or Expedition.entry(sim):
		draw_arc(ex,64,0,TAU,64,Color(CYAN,0.42),2)
		_label(ex+Vector2(-120 if ex.y>830 else -66,66 if ex.y>830 else 90),"WITHDRAWAL" if Expedition.entry(sim) else "EXTRACTION",CYAN,18)
	Expedition.draw(self,sim)
	_draw_observed_paths()
	_draw_findings()
	RuleOverlay.draw_chart(self,sim)
	Priced.draw_chart(self,sim)
	# Own open-water estimate only; deliberately does not sample hidden terrain or
	# listeners. Dotted amber radius is subordinate to later foreground beam cues.
	if sim.mission.get("acoustic_revision",0)==1:
		var own=sim.units[sim.selected]
		var radius=sim.motion_radius(sim.selected)
		if own.alive and radius>8:
			for n in 48:
				var a=float(n)/48*TAU
				draw_arc(own.pos,radius,a,a+TAU/96,3,Color(0.9,0.65,0.3,0.42),1.4)
	# Own deployment reach only; terrain remains authoritative on an actual tap.
	if decoy_targeting and sim.units[sim.selected].alive:
		draw_arc(sim.units[sim.selected].pos,sim.DECOY_RANGE,0,TAU,64,Color(0.82,0.69,0.4,0.8),1.8/world_scale)
	for i in sim.units.size():
		var u=sim.units[i]
		if not u.alive: continue
		if not earned.is_empty():EarnedChart.draw_course(self,EarnedChart.segments(sim,i),world_scale,i==sim.selected)
		if not u.route.is_empty():
			if i==sim.selected:HullBand.draw_world(self,sim,i)
			var last=u.pos
			for n in u.route.size():
				var dest=u.route[n]
				if earned.is_empty():_dash(last,dest.pos,Color(CYAN,0.75 if i==sim.selected else 0.22),2)
				if dest.stop:
					draw_arc(dest.pos,10,0,TAU,24,CYAN,2); draw_circle(dest.pos,3,CYAN)
				last=dest.pos
		_craft(u,i)
	if sim.mission.has("glass_reach") and sim.mission.glass_reach.artifact.is_empty():
		var at=sim.mission.glass_reach.work_pos
		draw_rect(Rect2(at-Vector2.ONE*20,Vector2.ONE*40),Color("d8c591"),false,2./world_scale)
		draw_line(at-Vector2(30,0),at+Vector2(30,0),Color("d8c591"),1.5/world_scale)
	preload("res://src/presentation/industrial_view.gd").draw(self,sim)
	# Only own launcher range and legitimately cached targets; beams draw afterward.
	if knock_targeting and sim.selected==0 and sim.units[0].alive:
		draw_arc(sim.units[0].pos,sim.KNOCK_RANGE,0,TAU,64,Color(0.7,0.85,0.8,0.5),1.5/world_scale)
		for c in knock_visible_targets():
			draw_arc(map_position(c.anchor),maxf(24,feedback_font_size*1.2/world_scale),0,TAU,32,Color("a7c7c3"),1.5/world_scale)
		# Own aim controls are below all observed Sirens/beams in the draw order.
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		for aim in knock_aim_targets():
			var box:Rect2=aim.rect;var center=box.get_center()
			draw_line(aim.anchor,aim.anchor.clamp(box.position,box.end),Color(0.65,0.78,0.76,0.65),1.5)
			draw_circle(aim.anchor,3,Color("a7c7c3"))
			draw_rect(box,Color(0.035,0.09,0.11,0.98));draw_rect(box,Color("a7c7c3"),false,1.5)
			var line_height=feedback_font_size+4
			for i in 2:
				var text=aim.tag if i==0 else "FIRE"
				var width=ThemeDB.fallback_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size).x
				draw_string(ThemeDB.fallback_font,Vector2(center.x-width/2,center.y-line_height+ThemeDB.fallback_font.get_ascent(feedback_font_size)+i*line_height),text,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("c4ded8"))
		draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	for projectile in sim.projectiles:
		var heading=Vector2.from_angle(projectile.angle)
		draw_line(projectile.pos-heading*17,projectile.pos+heading*5,Color("a7c7c3"),3/world_scale)
		draw_circle(projectile.pos+heading*5,2.2/world_scale,Color("ddede2"))
	preload("res://src/presentation/sonar_history.gd").draw_bearings(self,sim)
	var observed=contact_entries()
	for entry in observed:
		var c=sim.contacts[entry.key]; var fresh=entry.fresh
		var aim=float(c.angle)
		var observed_target=sim.contact_target(c)
		if fresh and c.lock>0 and not observed_target.is_empty(): aim=c.pos.angle_to_point(observed_target.pos)
		_siren(c.pos,aim,fresh,c.get("type","patroller"),maxf(0,float(c.get("pin_time",0))-(sim.elapsed-c.time)) if fresh else 0.0)
		if fresh and c.lock>0:
			if not observed_target.is_empty() and observed_target.alive and sim.line_clear(c.pos,observed_target.pos):
				var target:Vector2=observed_target.pos
				var origin:Vector2=c.pos+Vector2.from_angle(aim)*62
				if c.lock>=4:
					draw_line(origin,target,Color(1,0.22,0.09,0.23),10)
					draw_line(origin,target,Color("ff8a59"),3.5); draw_line(origin,target,Color("ffedc5"),1.2)
					draw_arc(target,17+sin(phase*18)*5,0,TAU,24,Color("ffbc83"),2)
				else: _dash(origin,target,Color(1,0.37,0.24,0.32),1.5)
			draw_arc(c.pos,58,-PI/2,-PI/2+TAU*minf(1,c.lock/4),40,Color("fa7969"),3)
	var acoustic=sim.acoustic_feedback()
	for n in acoustic.responses:
		if n.label=="FACTORY RESPONSE":
			draw_arc(n.pos,60+fmod(sim.mission.get("response_time",0.0)*100,350),0,TAU,64,Color(0.95,0.66,0.32,0.6),3)
			_label(sim.mission.factory_rect.position+Vector2(16,520),"CARRIER · CRADLE",Color("e1b66e"),16)
	for n in acoustic.pulses:
		if n.label=="DECOY":
			draw_arc(n.pos,29,0,TAU,40,Color("675b43"),2)
			draw_arc(n.pos,29,-PI/2,-PI/2+TAU*clampf(n.time/15.0,0,1),40,Color("e1b66e"),3)
			draw_circle(n.pos,4,Color("e1b66e"))
	# Sediment, restrained wake, and instrument ticks live above the physical view.
	for i in 70:
		var p=Vector2(fmod(i*241.17+phase*2,region.x),fmod(i*137.3+phase*0.7,region.y))
		draw_circle(p,0.7+float(i%3)*0.35,Color(0.48,0.7,0.7,0.11))
	draw_rect(Rect2(Vector2.ZERO,region),Color(0.3,0.7,0.7,0.19),false,2)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	_draw_pressure_overlay()
	_draw_local_current()
	preload("res://src/presentation/module_recovery_view.gd").draw(self,sim)
	# Short screen-sized tags preserve observed identity without long world labels.
	for entry in observed:
		var anchor=chart_camera.to_screen(entry.pos)+Vector2(12,-18)
		var tag_size=ThemeDB.fallback_font.get_string_size(entry.tag,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size)
		draw_rect(Rect2(anchor-Vector2(3,feedback_font_size),Vector2(tag_size.x+6,feedback_font_size+5)),Color(0.025,0.06,0.075,0.94))
		draw_string(ThemeDB.fallback_font,anchor,entry.tag,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("ed8e79") if entry.fresh else Color("b09a94"))
	for n in acoustic.pulses:
		if n.label=="DECOY":
			draw_string(ThemeDB.fallback_font,chart_camera.to_screen(n.pos)+Vector2(12,-12),"%ds"%ceili(n.time),HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("e1b66e"))
	var readout=contact_readout_rects()
	var listed=contact_readout_entries()
	for i in listed.size():
		var entry=listed[i];var box=readout[i]
		draw_rect(box,Color(0.04,0.07,0.09,0.94))
		draw_string(ThemeDB.fallback_font,box.position+Vector2(8,feedback_font_size),entry.text,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("ffac8c") if entry.urgent else Color("ed8e79") if entry.fresh else Color("b09a94"))

# A Siren study keeps only where it was last photographed, never where it is.
func _siren_mark(o:Dictionary)->void:
	var c=Color(0.9,0.42,0.34,0.7)
	draw_polyline(PackedVector2Array([o.pos+Vector2(0,-16),o.pos+Vector2(14,0),o.pos+Vector2(0,16),o.pos+Vector2(-14,0),o.pos+Vector2(0,-16)]),c,1.6)
	_label(o.pos+Vector2(22,20),"%s · LAST PHOTOGRAPHED"%o.name,c,14)
# An unresolved lead: an area from an earlier return, never an exact position or a name.
func _lead_area(o:Dictionary)->void:
	var c=Color(0.92,0.74,0.42,0.75);var r:float=float(o.get("lead_r",150.0))
	var n:int=28
	for k in n:
		if k%2==0:draw_arc(o.pos,r,TAU*k/n,TAU*(k+1)/n,6,c,2.0/world_scale)
	for k in 4:draw_line(o.pos+Vector2.from_angle(k*PI/2)*6,o.pos+Vector2.from_angle(k*PI/2)*16,Color(c,0.7),1.2/world_scale)
	var from:Vector2=sim.units[sim.selected].pos
	_label(o.pos+Vector2(r*0.72,-r*0.72),"%s · AREA · BRG %03d"%[o.name,roundi(fposmod(rad_to_deg(from.angle_to_point(o.pos)),360.0))],c,16)
# Observations the player resolved on film, and marks cut from earlier film.
const FINDING_COLORS={"loop":Color(0.95,0.6,0.35),"gap":Color(0.5,0.95,0.6),"post":Color(0.95,0.4,0.35),"route":Color(0.5,0.9,0.85),"cycle":Color(0.95,0.8,0.4),"person":Color(0.9,0.95,0.7),"hazard":Color(0.95,0.5,0.3),"weak":Color(0.95,0.8,0.4),"lane":Color(1.0,0.6,0.3)}
func _draw_findings()->void:
	var list:Array=[]
	list.append_array(sim.mission.get("photo",{}).get("findings",[]))
	list.append_array(sim.mission.get("photo_marks",[]))
	for f in list:
		var kind:String=str(f.kind)
		if not FINDING_COLORS.has(kind):continue
		var c:Color=FINDING_COLORS[kind];var w:float=1.8/world_scale;var label:String=str(f.get("label",f.text))
		var at:Vector2=Vector2.ZERO
		if f.has("pos"):at=Vector2(float(f.pos[0]),float(f.pos[1]))
		if f.has("pts") and f.pts.size()>=2:
			var pts:=PackedVector2Array()
			for p in f.pts:pts.append(Vector2(float(p[0]),float(p[1])))
			for n in pts.size()-1:draw_dashed_line(pts[n],pts[n+1],Color(c,0.85),w,(7.0 if kind=="loop" else 14.0)/world_scale)
			if kind=="route":
				var tip:Vector2=pts[-1];var back:Vector2=(pts[-2]-tip).normalized()
				draw_colored_polygon(PackedVector2Array([tip,tip+back.rotated(0.5)*18/world_scale,tip+back.rotated(-0.5)*18/world_scale]),Color(c,0.9))
			_label(pts[0]+Vector2(10,-8),label,c,15)
			continue
		match kind:
			"gap":
				draw_arc(at,float(f.get("r",90.0)),0,TAU,40,Color(c,0.55),w)
				draw_line(at+Vector2(-12,0),at+Vector2(12,0),c,w);draw_line(at+Vector2(0,-12),at+Vector2(0,12),c,w)
			"post":
				if f.has("r"):draw_arc(at,float(f.r),0,TAU,48,Color(c,0.45),w)
				draw_rect(Rect2(at-Vector2(9,9),Vector2(18,18)),Color(c,0.85),false,w)
			"cycle":
				var period:float=float(f.get("period",30.0));var open:float=float(f.get("open",7.0))
				var t:float=fposmod(sim.elapsed+float(f.get("phase",0.0)),period)
				label="%s · %s"%[label,"OPEN %.0fs" % (open-t) if t<open else "OPENS IN %.0fs"%(period-t)]
				draw_arc(at,40.0,0,TAU,28,Color(c,0.5),w);draw_arc(at,40.0,-PI/2,-PI/2+TAU*t/period,28,c,w*1.6)
			"person":
				draw_circle(at+Vector2(0,-9),4.0/world_scale*world_scale,c);draw_line(at+Vector2(0,-4),at+Vector2(0,10),c,w);draw_line(at+Vector2(-7,2),at+Vector2(7,2),c,w)
				draw_arc(at,22.0,0,TAU,24,Color(c,0.4),w)
			"hazard":
				draw_colored_polygon(PackedVector2Array([at+Vector2(0,-16),at+Vector2(15,12),at+Vector2(-15,12)]),Color(c,0.28))
				draw_polyline(PackedVector2Array([at+Vector2(0,-16),at+Vector2(15,12),at+Vector2(-15,12),at+Vector2(0,-16)]),c,w)
				if f.has("r"):draw_arc(at,float(f.r),0,TAU,40,Color(c,0.35),w)
			"weak":
				draw_line(at+Vector2(-11,-11),at+Vector2(11,11),c,w*1.4);draw_line(at+Vector2(-11,11),at+Vector2(11,-11),c,w*1.4)
			"lane":
				if f.has("rect"):
					var r:=Rect2(float(f.rect[0]),float(f.rect[1]),float(f.rect[2]),float(f.rect[3]))
					draw_rect(r,Color(c,0.07));draw_rect(r,Color(c,0.6),false,w)
					at=r.position+Vector2(r.size.x*0.5,12)
		_label(at+Vector2(16,-10),label,c,15)
# Paths the player actually photographed a Siren following; stale by definition.
func _draw_observed_paths()->void:
	for path in sim.mission.get("photo",{}).get("paths",[]):
		var points=PackedVector2Array()
		for p in path.pts:points.append(Vector2(p[0],p[1]))
		if points.size()<2:continue
		for n in points.size()-1:draw_dashed_line(points[n],points[n+1],Color(0.9,0.55,0.35,0.7),2.0/world_scale,6.0/world_scale)
		_label(points[-1]+Vector2(10,24),"OBSERVED PATH · S%d"%(int(path.siren)+1),Color(0.9,0.62,0.45,0.9),14)
func _draw_pressure_overlay()->void:
	var pressure=sim.recon_feedback()
	var threat=float(pressure.threat)
	if threat<.1:return
	var pulse=.75+.25*sin(sim.elapsed*7)
	var color=Color("e26a50") if threat>=.75 else Color("cb9959")
	for edge in 8:
		var thickness=float(8-edge)*5
		var alpha=threat*pulse*.018*(1.0-float(edge)/10)
		var tint=Color(color,alpha)
		draw_rect(Rect2(0,0,size.x,thickness),tint)
		draw_rect(Rect2(0,size.y-thickness,size.x,thickness),tint)
		draw_rect(Rect2(0,0,thickness,size.y),tint)
		draw_rect(Rect2(size.x-thickness,0,thickness,size.y),tint)
func _draw_local_current()->void:
	if not sim.has_method("current_feedback"):return
	for reading in sim.current_feedback():
		if reading.unit!=sim.selected or reading.flow.length()<.1:continue
		var anchor=screen_position(reading.pos)+Vector2(0,70)
		var direction:Vector2=reading.flow.normalized()
		var tip=anchor+direction*clampf(reading.flow.length()*2,12,60)
		draw_line(anchor,tip,Color("81c7b8"),2)
		draw_line(tip,tip-direction.rotated(.5)*10,Color("81c7b8"),2)
		draw_line(tip,tip-direction.rotated(-.5)*10,Color("81c7b8"),2)
		draw_string(ThemeDB.fallback_font,anchor+Vector2(12,18),"FLOW %.0f · ENGINE %.0f"%[reading.flow.length(),reading.effort],HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("a1d8cc"))

func ship_instrument_layout() -> Array:
	if fleet_instruments==null:return []
	return fleet_instruments.readouts.map(func(reading):return {"text":reading.text,"rect":reading.rect})
func ship_instrument_rects() -> Array:
	return ship_instrument_layout().map(func(reading):return reading.rect) if fleet_instruments!=null and fleet_instruments.visible else []
func _finale_array(mass: Rect2) -> void:
	draw_rect(mass,Color("142930")); draw_texture_rect(basalt,mass,false,Color(0.45,0.58,0.6))
	draw_rect(mass,Color("627a7d"),false,3)
	for n in 8:
		var x=mass.position.x+22+n*35
		draw_rect(Rect2(x,mass.position.y+8,16,mass.size.y-16),Color("203c43"))
		draw_line(Vector2(x,mass.position.y+8),Vector2(x,mass.end.y-8),Color("6a8082"),2)
	var mouth=mass.position+Vector2(mass.size.x*0.5,mass.size.y-18)
	for n in 5:
		draw_arc(mouth,35+n*24,PI,TAU,40,Color("72a3a4") if n%2==0 else Color("31474e"),7)
	for n in 7:
		var a=PI+float(n)/6*PI
		draw_line(mouth+Vector2.from_angle(a)*35,mouth+Vector2.from_angle(a)*132,Color("b39363"),3)
	if sim.mission.objectives[1].captured:
		_dash(Vector2(1410,720),Vector2(1250,880),Color("80bdb6"),3)
		draw_line(Vector2(1250,880),Vector2(1256,850),Color("80bdb6"),3)
		draw_line(Vector2(1250,880),Vector2(1280,873),Color("80bdb6"),3)
func _rock(r) -> void:
	var poly=sim.rock_polygon(r)
	var origin:Vector2=r.position if r is Rect2 else poly[0]
	if r is PackedVector2Array:
		for p in poly:origin=Vector2(minf(origin.x,p.x),minf(origin.y,p.y))
	var lower=PackedVector2Array(); var uv=PackedVector2Array()
	for p in poly:
		lower.append(p+Vector2(9,23)); uv.append((p-origin)/Vector2(400,400))
	draw_colored_polygon(lower,Color("030b11"))
	draw_colored_polygon(poly,Color("31474c"))
	draw_polygon(poly,PackedColorArray([Color(0.72,0.85,0.86)]),uv,basalt)
	for n in poly.size():
		var a=poly[n]; var b=poly[(n+1)%poly.size()]
		if b.x<a.x:
			draw_colored_polygon(PackedVector2Array([a,b,b+Vector2(9,23),a+Vector2(9,23)]),Color("11252e"))
			for k in range(0,int(a.distance_to(b)),8):
				var p=a.move_toward(b,k)
				draw_line(p,p+Vector2(7,21),Color(0.2,0.35,0.39,0.5),2)
		else: draw_line(a,b,Color(0.49,0.65,0.66,0.55),1.8)
	draw_polyline(poly,Color(0.17,0.26,0.3,0.5),2)
func _installation(p: Vector2,recorded: bool) -> void:
	var rect=Rect2(p-Vector2(38,72),Vector2(76,108))
	draw_rect(Rect2(rect.position+Vector2(14,18),rect.size),Color(0.0,0.02,0.03,0.8))
	draw_rect(rect,Color("1c343b")); draw_rect(rect,Color("476269"),false,2)
	for x in [-26,-8,10,28]:
		draw_rect(Rect2(p+Vector2(x,-64),Vector2(9,90)),Color("10242d"))
		draw_line(p+Vector2(x+3,-58),p+Vector2(x+3,16),Color("49b5b6") if x<0 else Color("ac8050"),2)
	for y in [-48,-18,12]:
		draw_line(p+Vector2(-37,y),p+Vector2(37,y),Color("4a6268"),3)
	draw_circle(p+Vector2(0,-32),17,Color("061920"))
	draw_arc(p+Vector2(0,-32),13,0,TAU,32,Color("6ae4d5") if recorded else Color("ce9b53"),2)
func _craft(u: Dictionary,index: int) -> void:
	var p:Vector2=u.pos
	if index==sim.selected:
		draw_line(p+Vector2(-55,-38),p+Vector2(-42,-38),CYAN,2)
		draw_line(p+Vector2(-55,-38),p+Vector2(-55,-25),CYAN,2)
	draw_set_transform(world_offset+p*world_scale,u.angle,Vector2.ONE*world_scale)
	if index==0:
		draw_texture_rect_region(quietus,Rect2(-66,-17,132,34),Rect2(60,145,1940,390))
		if u.vel.length()>8:
			for n in 3: draw_line(Vector2(-69-n*10,-3-n),Vector2(-75-n*13,-3-n),Color(0.4,0.75,0.75,0.14),2)
	else:
		draw_style_box(_hull_style(),Rect2(-18,-5,36,10))
		draw_line(Vector2(-9,-6),Vector2(-9,6),Color("b69251"),3)
		draw_line(Vector2(9,-5),Vector2(9,5),Color("8a9b9d"),1)
		draw_circle(Vector2(18,0),3,Color("7edfe4")); draw_line(Vector2(-20,-9),Vector2(-16,9),Color("506e77"),2)
	Witness.draw_carried(self,sim,index)
	draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	if index==0 and index==sim.selected:
		var heading=selected_heading_marker()
		if not heading.is_empty():
			draw_polyline(heading,INK,feedback_font_size*0.27/world_scale,true)
			draw_polyline(heading,Color("a7c7c3"),feedback_font_size*0.15/world_scale,true)
	var label_y=63 if index==0 else 45
	if (world_offset+p*world_scale).y+label_y*world_scale>size.y-8: label_y=-36
	if index!=sim.selected and (fleet_instruments==null or not fleet_instruments.is_visible_in_tree()):_label(p+Vector2(-8,label_y),["Q","A","B"][index],Color("7e9da4"),18)
func selected_heading_marker() -> PackedVector2Array:
	if sim==null or sim.selected!=0 or sim.units.is_empty(): return PackedVector2Array()
	var u=sim.units[sim.selected]
	if not u.alive or not sim.outcome.is_empty(): return PackedVector2Array()
	var scale=maxf(world_scale,0.001)
	var length=float(feedback_font_size)/scale
	var direction=Vector2.from_angle(u.angle)
	var bow:Vector2=u.pos+direction*(66.0+length*0.55)
	var side=direction.orthogonal()*length*0.36
	return PackedVector2Array([bow+side,bow+direction*length,bow-side])
func _hull_style() -> StyleBoxFlat:
	var style=StyleBoxFlat.new(); style.bg_color=Color("263841"); style.border_color=Color("627780"); style.set_border_width_all(1); style.set_corner_radius_all(7); return style
func _siren(p: Vector2,angle: float,fresh: bool,role: String="patroller",pin_time: float=0.0) -> void:
	var depth=1.0
	if pin_time>0: depth=1.0-0.58*minf(clampf((8.0-pin_time)/0.8,0,1),clampf(pin_time/0.8,0,1))
	draw_set_transform(world_offset+p*world_scale,angle,Vector2.ONE*world_scale*depth)
	if fresh:
		# The same original biological material has distinct station/response profiles.
		var body=Rect2(-67,-40,134,80)
		if role=="sweeper": body=Rect2(-70,-50,140,100)
		if role=="sentinel": body=Rect2(-58,-53,116,106)
		var shade=Color(lerpf(0.25,1.0,depth),lerpf(0.44,1.0,depth),lerpf(0.55,1.0,depth),lerpf(0.45,1.0,depth))
		if role=="buoy":
			draw_line(Vector2(0,-36),Vector2(0,48),Color("d5b77c"),4.)
			draw_circle(Vector2.ZERO,20,Color("193a40"));draw_arc(Vector2.ZERO,22,0,TAU,24,Color("d5b77c"),3.)
		elif role=="relay":
			draw_colored_polygon(PackedVector2Array([Vector2(0,-35),Vector2(23,0),Vector2(0,35),Vector2(-23,0)]),Color("578c99"))
			for side in [-1,1]:draw_line(Vector2(side*20,0),Vector2(side*47,-20),Color("dbcfa5"),3.)
		elif role=="interceptor":
			draw_colored_polygon(PackedVector2Array([Vector2(70,0),Vector2(-45,-24),Vector2(-25,-5),Vector2(-60,0),Vector2(-25,5),Vector2(-45,24)]),Color("67868e"))
			for side in [-1,1]:draw_line(Vector2(-40,side*20),Vector2(-65,side*28),Color("d87961"),4.)
		elif role=="warden":
			draw_circle(Vector2.ZERO,30,Color("37535d"))
			for n in 6:
				var spoke=Vector2.from_angle(n*TAU/6);draw_line(spoke*24,spoke*55,Color("d1ad72"),6.)
			draw_arc(Vector2.ZERO,40,0,TAU,24,Color("b87864"),3.)
		elif role=="hunter":Confluence.draw_hunter(self,sim.elapsed,shade)
		else:draw_texture_rect(siren_ray,body,false,shade)
		if role=="sweeper":
			for radius in [30,43,56]:draw_arc(Vector2(25,0),radius,-PI*.45,PI*.45,20,Color("e4b273"),2.)
		if pin_time>0:
			for x in [-25.0,0.0,25.0]:
				draw_arc(Vector2(x,0),26,-PI*0.45,PI*0.45,16,Color("85b1b4"),2.0)
			draw_line(Vector2(-40,19),Vector2(40,-19),Color("85b1b4"),2.0)
			draw_line(Vector2(0,26),Vector2(0,60),Color(0.2,0.35,0.4,0.5),1.5)
		if role=="sentinel":
			for side in [-1,1]:
				draw_line(Vector2(-18,side*39),Vector2(14,side*48),Color("b6a58b"),2)
	else:
		draw_arc(Vector2.ZERO,24,0,TAU,6,Color("956d63"),1.5)
		draw_line(Vector2(-12,0),Vector2(12,0),Color("956d63"),1)
	draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
func _dash(a: Vector2,b: Vector2,color: Color,width: float) -> void:
	var distance=a.distance_to(b)
	for n in range(0,int(distance),18): draw_line(a.move_toward(b,n),a.move_toward(b,minf(n+9,distance)),color,width)
func own_craft_rects() -> Array:
	var result=[]
	for id in sim.units.size():
		if not sim.units[id].alive:continue
		var half=(Vector2(74,32) if id==0 else Vector2(26,20))*world_scale
		result.append(Rect2(screen_position(sim.units[id].pos)-half,half*2))
	return result
func world_label_position(p:Vector2,text:String,font_size:int) -> Vector2:
	var font=ThemeDB.fallback_font;var actual=maxi(font_size,int(12./world_scale));var extent=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,actual)*world_scale
	var origin=chart_camera.to_screen(p);var height=extent.y+6
	var blocked=ui_blocked_rects+ship_instrument_rects()+own_craft_rects()
	for horizontal in [0,extent.x*.75,-extent.x*.75,extent.x*1.5,-extent.x*1.5]:
		for step in [0,-1,-2,1,-3,2,-4,3]:
			var point=origin+Vector2(horizontal,step*height)
			point.x=clampf(point.x,12,maxf(12,size.x-extent.x-12))
			var area=Rect2(point-Vector2(0,font.get_ascent(actual)*world_scale),extent)
			if Rect2(Vector2.ZERO,size).encloses(area) and not blocked.any(func(r):return r.intersects(area.grow(3))):return chart_camera.to_world(point)
	return Vector2.INF
func _label(p:Vector2,text:String,color:Color,font_size:int) -> void:
	var placed=world_label_position(p,text,font_size)
	if placed.is_finite():
		if placed.distance_to(p)*world_scale>feedback_font_size*2:draw_line(p,placed,Color(color,.35),1./world_scale)
		draw_string_outline(ThemeDB.fallback_font,placed,text,HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(font_size,int(12./world_scale)),maxi(1,int(3./world_scale)),Color(.01,.03,.04,.95))
		draw_string(ThemeDB.fallback_font,placed,text,HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(font_size,int(12./world_scale)),color)

func _draw_departure() -> void:
	var report=sim.departure_feedback()
	if report.is_empty():return
	var tint=Color(0.52,0.66,0.64,0.72)
	if report.lit:
		var points=PackedVector2Array()
		for p in [Vector2(-42,0),Vector2(-36,-9),Vector2(24,-10),Vector2(40,-6),Vector2(48,0),Vector2(40,6),Vector2(24,10),Vector2(-36,9)]:points.append(report.pos+p.rotated(report.angle))
		tint.a*=report.fade
		draw_colored_polygon(points,Color(0.15,0.25,0.28,0.92*report.fade))
		draw_polyline(points,tint,1.2/world_scale);draw_line(points[-1],points[0],tint,1.2/world_scale)
		for x in [-24,-8,8,24]:
			draw_line(report.pos+Vector2(x,-7).rotated(report.angle),report.pos+Vector2(x,7).rotated(report.angle),Color(0.31,0.44,0.46,0.7*report.fade),1.0/world_scale)
		var nose:Vector2=report.pos+Vector2(36,0).rotated(report.angle)
		draw_circle(nose,2.0/world_scale,Color(0.85,0.75,0.49,report.fade))
		_label(report.pos+Vector2(-20,28),"DEEP TRANSIT",tint,maxi(4,roundi(feedback_font_size/world_scale)))
	# Only this owned receiver's supported bearing: no source dot behind stone,
	# exact countdown, listener reaction, or promised safe crossing.
	if report.receivers.has(sim.selected):
		var own=sim.units[sim.selected]
		_label(own.pos+Vector2(46,-44),"MOTOR %s · %s"%[report.receivers[sim.selected],"MOVING" if report.moving else "RISING"],Color(0.76,0.65,0.43,0.9),maxi(4,roundi(feedback_font_size/world_scale)))
