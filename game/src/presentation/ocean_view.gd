extends Control
var sim
var optical_feed
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
var feedback_font_size:=14
var instrument_top:=64.0
var chart_camera=preload("res://src/presentation/chart_camera.gd").new()
const CYAN := Color("72d9d3")
const INK := Color("07141c")
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	clip_contents=true
	texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
	optical_feed=preload("res://src/presentation/camera_feed.gd").new(); add_child(optical_feed)
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
func _sync_camera() -> void:
	chart_camera.configure(size); world_scale=chart_camera.scale; world_offset=chart_camera.offset
func zoom_at(factor: float,anchor: Vector2) -> void:
	_sync_camera(); chart_camera.zoom_at(factor,anchor); _sync_camera(); queue_redraw()
func pan_chart(delta: Vector2) -> void:
	_sync_camera(); chart_camera.pan(delta); _sync_camera(); queue_redraw()
func fit_chart() -> void:
	chart_camera.fit(); _sync_camera(); queue_redraw()
func _process(dt: float) -> void:
	phase+=dt; camera_flash=maxf(0,camera_flash-dt)
	if optical_feed!=null:
		optical_feed.sim=sim; optical_feed.visible=sim!=null and sim.capture_unit>=0 and sim.selected==sim.capture_unit
		optical_feed.position=Vector2(14,size.y-242); optical_feed.size=Vector2(minf(390,size.x*0.48),228)
	queue_redraw()
func acoustic_rows() -> Array:
	return preload("res://src/presentation/acoustic_feedback.gd").rows(sim.acoustic_feedback()) if sim!=null else []
func contact_entries() -> Array:
	return preload("res://src/presentation/contact_feedback.gd").entries(sim.contacts,sim.elapsed,sim.units,sim.line_clear) if sim!=null else []
func contact_readout_rects() -> Array:
	var result: Array=[]
	var top=instrument_top+acoustic_rows().size()*(feedback_font_size+5)+12+7
	for entry in contact_entries():
		var width=ThemeDB.fallback_font.get_string_size(entry.text,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size).x+20
		result.append(Rect2(12,top,minf(width,size.x-24),feedback_font_size+6))
		top+=feedback_font_size+8
	return result
func _draw() -> void:
	if sim==null or ocean==null: return
	_sync_camera()
	draw_rect(Rect2(Vector2.ZERO,size),Color("050f17"))
	draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	draw_texture_rect(ocean,Rect2(0,0,1600,960),false)
	# Cartographic graticule, subordinate to the physical water and stone.
	for x in range(0,1601,160):
		draw_line(Vector2(x,0),Vector2(x,960),Color(0.3,0.65,0.67,0.06),1)
	for y in range(0,961,160):
		draw_line(Vector2(0,y),Vector2(1600,y),Color(0.3,0.65,0.67,0.06),1)
	# Depth contours and abyssal fissures occupy the navigable seabed.
	for n in 7:
		var points=PackedVector2Array()
		for k in 45:
			points.append(Vector2(k*38,80+n*135+sin(k*0.19+n)*32))
		draw_polyline(points,Color(0.12,0.3,0.33,0.11),1.2)
	# Bedrock and columnar basalt are original deterministic constructions.
	for r in sim.mission.rocks: _rock(r)
	for o in sim.mission.objectives:
		if o.get("kind","")=="receiver":
			draw_arc(o.pos,26,0,TAU,40,Color("80bdb6"),2)
			draw_line(o.pos-Vector2(17,0),o.pos+Vector2(17,0),Color("80bdb6"),2)
			draw_line(o.pos-Vector2(0,17),o.pos+Vector2(0,17),Color("80bdb6"),2)
		else: _installation(o.pos,o.captured)
	if sim.mission.has("factory_rect"):
		var mass:Rect2=sim.mission.factory_rect
		draw_rect(mass,Color("102630")); draw_rect(mass,Color("486268"),false,3)
		draw_set_transform(world_offset+mass.get_center()*world_scale,PI/2,Vector2.ONE*world_scale)
		draw_texture_rect(foundry,Rect2(-mass.size.y/2,-mass.size.x/2,mass.size.y,mass.size.x),false,Color(0.8,0.95,1))
		draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	elif sim.mission.has("array_rect"):
		_finale_array(sim.mission.array_rect)
	elif sim.mission.id>=3 and sim.mission.id!=5:
		draw_texture_rect(foundry,Rect2(1080,-100,540,360),false,Color(0.65,0.8,0.82,0.8))
	# Intelligence marks are briefed coordinates, not live contact observations.
	for o in sim.mission.objectives:
		var c=CYAN if o.captured else Color("e1b66e")
		draw_arc(o.pos,43,0,TAU,40,Color(c,0.35),1.4)
		draw_line(o.pos+Vector2(-14,0),o.pos+Vector2(14,0),c,1)
		draw_line(o.pos+Vector2(0,-14),o.pos+Vector2(0,14),c,1)
		if not o.captured: _label(o.pos+Vector2(50,-5),o.name,c,17)
	# Physical chart is retained. Unknown water, shadows, and contact memory remain separate.
	for y in 24:
		for x in 40:
			var key=Vector2i(x,y); var p=Vector2(x*40+20,y*40+20)
			var alpha=0.38 if not sim.known.has(key) else (0.0 if sim.visible(p) else 0.20)
			if alpha>0: draw_rect(Rect2(x*40,y*40,40,40),Color(0.005,0.014,0.025,alpha))
	# Sonar rays stop at actual cover, producing explicit acoustic shadows.
	if sim.ping_time>0:
		var radius=(3.5-sim.ping_time)*210
		for n in 180:
			var direction=Vector2.from_angle(n*TAU/180)
			var end=sim.ping_origin+direction*radius
			if sim.line_clear(sim.ping_origin,end): draw_line(end-direction*6,end,Color(0.3,0.95,0.88,sim.ping_time/5),2)
	var ex=sim.mission.extraction
	draw_arc(ex,64,0,TAU,64,Color(CYAN,0.42),2)
	_label(ex+Vector2(-120 if ex.y>830 else -66,66 if ex.y>830 else 90),"EXTRACTION",CYAN,18)
	# Own open-water estimate only; deliberately does not sample hidden terrain or
	# listeners. Dotted amber radius is subordinate to later foreground beam cues.
	if sim.mission.get("acoustic_revision",0)==1:
		var own=sim.units[sim.selected]
		var radius=preload("res://src/simulation/acoustic_paths.gd").motion_radius(own.vel.length())
		if own.alive and radius>8:
			for n in 48:
				var a=float(n)/48*TAU
				draw_arc(own.pos,radius,a,a+TAU/96,3,Color(0.9,0.65,0.3,0.42),1.4)
	for i in sim.units.size():
		var u=sim.units[i]
		if not u.alive: continue
		if not u.route.is_empty():
			var last=u.pos
			for n in u.route.size():
				var dest=u.route[n]
				_dash(last,dest.pos,Color(CYAN,0.75 if i==sim.selected else 0.22),2)
				if dest.stop:
					draw_arc(dest.pos,10,0,TAU,24,CYAN,2); draw_circle(dest.pos,3,CYAN)
				last=dest.pos
		_craft(u,i)
	var observed=contact_entries()
	for entry in observed:
		var c=sim.contacts[entry.key]; var fresh=entry.fresh
		var aim=float(c.angle)
		var observed_target=int(c.get("target",-1))
		if fresh and c.lock>0 and observed_target>=0 and observed_target<sim.units.size(): aim=c.pos.angle_to_point(sim.units[observed_target].pos)
		_siren(c.pos,aim,fresh,c.get("type","patroller"))
		if fresh and c.lock>0:
			var target_id=int(c.get("target",-1))
			if target_id>=0 and target_id<sim.units.size() and sim.units[target_id].alive and sim.line_clear(c.pos,sim.units[target_id].pos):
				var target:Vector2=sim.units[target_id].pos
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
		var p=Vector2(fmod(i*241.17+phase*2,1600),fmod(i*137.3+phase*0.7,960))
		draw_circle(p,0.7+float(i%3)*0.35,Color(0.48,0.7,0.7,0.11))
	draw_rect(Rect2(0,0,1600,960),Color(0.3,0.7,0.7,0.19),false,2)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	# Short screen-sized tags preserve observed identity without long world labels.
	for entry in observed:
		var anchor=chart_camera.to_screen(entry.pos)+Vector2(12,-18)
		var tag_size=ThemeDB.fallback_font.get_string_size(entry.tag,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size)
		draw_rect(Rect2(anchor-Vector2(3,feedback_font_size),Vector2(tag_size.x+6,feedback_font_size+5)),Color(0.025,0.06,0.075,0.94))
		draw_string(ThemeDB.fallback_font,anchor,entry.tag,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("ed8e79") if entry.fresh else Color("b09a94"))
	draw_rect(Rect2(12,7,minf(430,size.x-194),49),Color(0.025,0.06,0.075,0.94))
	draw_string(ThemeDB.fallback_font,Vector2(16,26),"TAP ROUTE · DRAG CHART · PINCH ZOOM",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("76959c"))
	draw_string(ThemeDB.fallback_font,Vector2(16,46),"CHART %.1f×"%chart_camera.zoom,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("76959c"))

	for n in acoustic.pulses:
		if n.label=="DECOY":
			draw_string(ThemeDB.fallback_font,chart_camera.to_screen(n.pos)+Vector2(12,-12),"%ds"%ceili(n.time),HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("e1b66e"))
	var rows=acoustic_rows()
	var line_height=feedback_font_size+5
	var instrument_height=rows.size()*line_height+12
	var instrument_width=0.0
	for row in rows:instrument_width=maxf(instrument_width,ThemeDB.fallback_font.get_string_size(row,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size).x+20)
	draw_rect(Rect2(12,instrument_top,minf(instrument_width,size.x-24),instrument_height),Color(0.025,0.06,0.075,0.94))
	for i in rows.size():
		draw_string(ThemeDB.fallback_font,Vector2(20,instrument_top+feedback_font_size+5+i*line_height),rows[i],HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("e1b66e") if i==1 and rows[i]!="DECOYS · none" else Color("a4bfbd"))
	var readout=contact_readout_rects()
	for i in observed.size():
		var entry=observed[i];var box=readout[i]
		draw_rect(box,Color(0.04,0.07,0.09,0.94))
		draw_string(ThemeDB.fallback_font,box.position+Vector2(8,feedback_font_size),entry.text,HORIZONTAL_ALIGNMENT_LEFT,-1,feedback_font_size,Color("ffac8c") if entry.urgent else Color("ed8e79") if entry.fresh else Color("b09a94"))

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
func _rock(r: Rect2) -> void:
	var poly=sim.rock_polygon(r)
	var lower=PackedVector2Array(); var uv=PackedVector2Array()
	for p in poly:
		lower.append(p+Vector2(9,23)); uv.append((p-r.position)/Vector2(400,400))
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
		draw_arc(p,48 if index==0 else 31,0,TAU,56,Color(CYAN,0.55),1.5)
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
	draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	if index==0 and index==sim.selected:
		var heading=selected_heading_marker()
		if not heading.is_empty():
			draw_polyline(heading,INK,feedback_font_size*0.27/world_scale,true)
			draw_polyline(heading,Color("a7c7c3"),feedback_font_size*0.15/world_scale,true)
	var label_y=63 if index==0 else 45
	if (world_offset+p*world_scale).y+label_y*world_scale>size.y-8: label_y=-36
	_label(p+Vector2(-39 if index==sim.selected else -8,label_y),u.name if index==sim.selected else ["Q","A","B"][index],CYAN if index==sim.selected else Color("7e9da4"),18)
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
func _siren(p: Vector2,angle: float,fresh: bool,role: String="patroller") -> void:
	draw_set_transform(world_offset+p*world_scale,angle,Vector2.ONE*world_scale)
	if fresh:
		# The same original biological material has distinct station/response profiles.
		var body=Rect2(-67,-40,134,80)
		if role=="sentinel": body=Rect2(-58,-53,116,106)
		elif role=="hunter": body=Rect2(-79,-30,158,60)
		draw_texture_rect(siren_ray,body,false)
		if role=="sentinel":
			for side in [-1,1]:
				draw_line(Vector2(-18,side*39),Vector2(14,side*48),Color("b6a58b"),2)
		elif role=="hunter":
			draw_line(Vector2(-57,-15),Vector2(-76,-26),Color("b6a58b"),2)
			draw_line(Vector2(-57,15),Vector2(-76,26),Color("b6a58b"),2)
	else:
		draw_arc(Vector2.ZERO,24,0,TAU,6,Color("956d63"),1.5)
		draw_line(Vector2(-12,0),Vector2(12,0),Color("956d63"),1)
	draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
func _dash(a: Vector2,b: Vector2,color: Color,width: float) -> void:
	var distance=a.distance_to(b)
	for n in range(0,int(distance),18): draw_line(a.move_toward(b,n),a.move_toward(b,minf(n+9,distance)),color,width)
func _label(p: Vector2,text: String,color: Color,font_size: int) -> void:
	draw_string(ThemeDB.fallback_font,p,text,HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(font_size,int(12.0/world_scale)),color)
