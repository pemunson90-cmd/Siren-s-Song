extends Control
var sim
var receiver_font_size=14
var optics=preload("res://src/presentation/evidence_catalog.gd").IMAGES
var foundry=preload("res://assets/structures/foundry.png")
const PHOSPHOR=Color("8cdcd3")
func _ready() -> void:
	clip_contents=true; mouse_filter=Control.MOUSE_FILTER_STOP
func _process(_dt: float) -> void: queue_redraw()
func _draw() -> void:
	if sim==null or sim.capture_unit<0: return
	var objective=sim.mission.objectives[sim.capture_target]
	var duration=objective.get("duration",4.0)
	var progress=clampf(sim.capture_time/duration,0,1)
	draw_rect(Rect2(Vector2.ZERO,size),Color("07151d")); draw_rect(Rect2(Vector2.ZERO,size),Color("6b9d9f"),false,1)
	var picture=Rect2(8,36,size.x-16,size.y-78)
	draw_rect(picture,Color("102a32"))
	if objective.get("kind","")=="exchange":
		# Live local receiver trace; interpretation plate is retained only after decode.
		var context=sim.blackwater_context(sim.capture_target,sim.capture_unit)
		var trace=PackedVector2Array()
		var center=picture.get_center();var amp=minf(32,picture.size.y*0.2)
		for x in range(0,int(picture.size.x),2):
			var phase=float(x)*0.17+sim.capture_time*5.0
			var envelope=pow(maxf(0,sin(float(x)*0.037)),3)
			trace.append(Vector2(picture.position.x+x,center.y+sin(phase)*envelope*amp))
		draw_polyline(trace,PHOSPHOR,2.0)
		draw_string(ThemeDB.fallback_font,picture.position+Vector2(8,receiver_font_size+5),"LOCAL REPLAY" if context.replay>0 else "QUIET RECEPTION",HORIZONTAL_ALIGNMENT_LEFT,-1,receiver_font_size,PHOSPHOR)
		if not context.settled:draw_string(ThemeDB.fallback_font,picture.position+Vector2(8,picture.size.y-8),"SETTLING · wait for rest",HORIZONTAL_ALIGNMENT_LEFT,-1,receiver_font_size,Color("e0bf83"))
	elif objective.has("optical") and optics.has(objective.optical):
		var image=optics[objective.optical]
		var image_size=Vector2(picture.size.x,picture.size.x*9.0/16.0)
		if image_size.y>picture.size.y: image_size=Vector2(picture.size.y*16.0/9.0,picture.size.y)
		draw_texture_rect(image,Rect2(picture.get_center()-image_size/2,image_size),false)
	elif sim.mission.id>=3:
		draw_texture_rect(foundry,Rect2(14,34,size.x-28,size.y-72),false,Color(0.9,1,1))
	else:
		# Magnified image of the same ribbed listening spire seen in bathymetry.
		var center=Vector2(size.x*0.5,size.y*0.5+4)
		draw_colored_polygon(PackedVector2Array([center+Vector2(-84,-53),center+Vector2(55,-68),center+Vector2(83,38),center+Vector2(-60,61)]),Color("243e46"))
		for x in range(-70,65,18):
			draw_colored_polygon(PackedVector2Array([center+Vector2(x,-49),center+Vector2(x+9,-52),center+Vector2(x+26,41),center+Vector2(x+15,44)]),Color("101e28"))
			draw_line(center+Vector2(x+7,-43),center+Vector2(x+22,33),Color("5fc3c7") if x<0 else Color("c29a60"),2)
		for y in [-30,0,30]: draw_line(center+Vector2(-66,y+9),center+Vector2(65,y-6),Color("647e84"),3)
		draw_circle(center+Vector2(-8,-8),28,Color("091b23")); draw_arc(center+Vector2(-8,-8),22,0,TAU,48,Color("d1a25d"),3)
		for k in 12:
			var p=center+Vector2(-8,-8)+Vector2.from_angle(k*TAU/12)*17
			draw_line(p,p.move_toward(center+Vector2(-8,-8),8),Color("a38553"),2)
		# Fine image detail is reserved for the risky optical observation.
		for k in 42:
			var p=center+Vector2((k*37)%137-68,(k*19)%95-47)
			draw_circle(p,0.7,Color("6b888c"))
	for y in range(36,int(size.y-40),4): draw_line(Vector2(8,y),Vector2(size.x-8,y),Color(0,0.02,0.04,0.11),1)
	var font=ThemeDB.fallback_font
	var type=objective.get("kind","")
	var font_size=receiver_font_size if type=="exchange" else 14
	draw_string(font,Vector2(14,24),"%s / %s"%["HYDROPHONES" if type in ["receiver","exchange"] else ("ARCHIVE LINK" if objective.get("kind","")=="uplink" else "OPTICAL"),sim.units[sim.capture_unit].name],HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,PHOSPHOR)
	draw_string(font,Vector2(14,size.y-24),objective.name,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("e0bf83"))
	draw_string(font,Vector2(size.x-68,size.y-24),"%02d%%"%int(progress*100),HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,PHOSPHOR)
	draw_rect(Rect2(12,size.y-12,size.x-24,3),Color("25464b")); draw_rect(Rect2(12,size.y-12,(size.x-24)*progress,3),PHOSPHOR)
