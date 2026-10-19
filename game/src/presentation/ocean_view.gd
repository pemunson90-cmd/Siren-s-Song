extends Control
var sim
var phase := 0.0
var world_scale := 1.0
var world_offset := Vector2.ZERO
var ocean: ImageTexture
var rocks: Array = []
var foundry=preload("res://assets/structures/foundry.png")
var quietus=preload("res://assets/craft/quietus.png")
var basalt=preload("res://assets/materials/basalt.png")
var camera_flash := 0.0
const CYAN := Color("72d9d3")
const INK := Color("07141c")
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	clip_contents=true
	texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
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
	return (screen-world_offset)/world_scale
func _process(dt: float) -> void:
	phase+=dt; camera_flash=maxf(0,camera_flash-dt); queue_redraw()
func _draw() -> void:
	if sim==null or ocean==null: return
	world_scale=minf(size.x/1600.0,size.y/960.0)
	world_offset=(size-Vector2(1600,960)*world_scale)/2.0
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
	for o in sim.mission.objectives: _installation(o.pos,o.captured)
	if sim.mission.id>=3:
		draw_texture_rect(foundry,Rect2(1080,-100,540,360),false,Color(0.65,0.8,0.82,0.8))
	# Intelligence marks are briefed coordinates, not live contact observations.
	for o in sim.mission.objectives:
		var c=CYAN if o.captured else Color("e1b66e")
		draw_arc(o.pos,43,0,TAU,40,Color(c,0.35),1.4)
		draw_line(o.pos+Vector2(-14,0),o.pos+Vector2(14,0),c,1)
		draw_line(o.pos+Vector2(0,-14),o.pos+Vector2(0,14),c,1)
		_label(o.pos+Vector2(50,-5),"RECOVERED" if o.captured else o.name,c,17)
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
	_label(ex+Vector2(-66,90),"EXTRACTION",CYAN,18)
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
	for id in sim.contacts:
		var c=sim.contacts[id]; var fresh=sim.elapsed-c.time<0.3
		_siren(c.pos,c.angle,c.mode,fresh)
		if fresh and c.lock>0:
			draw_arc(c.pos,58,-PI/2,-PI/2+TAU*minf(1,c.lock/4),40,Color("fa7969"),3)
			_label(c.pos+Vector2(-50,-70),"BEAM %.1fs"%maxf(0,4-c.lock),Color("fa7969"),18)
		elif not fresh: _label(c.pos+Vector2(35,0),"ECHO · %ds"%int(sim.elapsed-c.time),Color("9a8079"),17)
	for n in sim.noises:
		if n.label=="DECOY":
			draw_arc(n.pos,25+sin(phase*4)*9,0,TAU,32,Color("e1b66e"),2)
	# Sediment, restrained wake, and instrument ticks live above the physical view.
	for i in 70:
		var p=Vector2(fmod(i*241.17+phase*2,1600),fmod(i*137.3+phase*0.7,960))
		draw_circle(p,0.7+float(i%3)*0.35,Color(0.48,0.7,0.7,0.11))
	draw_rect(Rect2(0,0,1600,960),Color(0.3,0.7,0.7,0.19),false,2)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	draw_string(ThemeDB.fallback_font,Vector2(16,26),"TACTICAL / BATHYMETRY",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("76959c"))
	draw_string(ThemeDB.fallback_font,Vector2(size.x-202,26),"%04d m  ·  CHART MEMORY"%sim.mission.depth,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("76959c"))
	if sim.capture_unit>=0:
		var text="OPTICAL FEED  /  EXPOSING %d%%"%int(sim.capture_time/4*100)
		draw_rect(Rect2(12,size.y-50,size.x-24,38),Color("102b35"))
		_label(Vector2(26,size.y-25),text,Color("e1b66e"),17)
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
	_label(p+Vector2(-39,63 if index==0 else 45),u.name,CYAN if index==sim.selected else Color("7e9da4"),18)
func _hull_style() -> StyleBoxFlat:
	var style=StyleBoxFlat.new(); style.bg_color=Color("263841"); style.border_color=Color("627780"); style.set_border_width_all(1); style.set_corner_radius_all(7); return style
func _siren(p: Vector2,angle: float,mode: String,fresh: bool) -> void:
	draw_set_transform(world_offset+p*world_scale,angle,Vector2.ONE*world_scale)
	var poly=PackedVector2Array([Vector2(55,0),Vector2(4,-15),Vector2(-23,-52),Vector2(-13,-8),Vector2(-42,-15),Vector2(-28,0),Vector2(-42,15),Vector2(-13,8),Vector2(-23,52),Vector2(4,15)])
	draw_colored_polygon(poly,Color("20262c") if fresh else Color(0.3,0.15,0.13,0.4))
	draw_polyline(poly,Color("aa6158") if fresh else Color(0.5,0.3,0.25,0.4),1.4)
	if fresh:
		draw_line(Vector2(-5,-11),Vector2(42,0),Color("ee7664"),2)
		draw_line(Vector2(-5,11),Vector2(42,0),Color("ee7664"),2)
		draw_circle(Vector2(45,0),3,Color("ffc59b"))
	draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
	_label(p+Vector2(-35,75),mode,Color("ed8e79") if fresh else Color("94766e"),17)
func _dash(a: Vector2,b: Vector2,color: Color,width: float) -> void:
	var distance=a.distance_to(b)
	for n in range(0,int(distance),18): draw_line(a.move_toward(b,n),a.move_toward(b,minf(n+9,distance)),color,width)
func _label(p: Vector2,text: String,color: Color,font_size: int) -> void:
	draw_string(ThemeDB.fallback_font,p,text,HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(font_size,int(12.0/world_scale)),color)
