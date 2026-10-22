extends Control
var sim
var receiver_font_size=14
var optics=preload("res://src/presentation/evidence_catalog.gd").IMAGES
var foundry=preload("res://assets/structures/foundry.png")
const ReceiverScene=preload("res://src/presentation/receiver_scene.gd")
const PHOSPHOR=Color("8cdcd3")
const PhotoView=preload("res://src/presentation/photo_view.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
var _vm:Dictionary={}
var _frame:Dictionary={}
var _vm_age:=1.0
var _vm_key:=""
var _buttons:Array=[]
var time:=0.0
static func fit_caption(text:String,width:float,font_size:int)->String:
	var font=ThemeDB.fallback_font
	if font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=width:return text
	var shortened=text
	while not shortened.is_empty() and font.get_string_size(shortened+"…",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>width:shortened=shortened.left(shortened.length()-1)
	return shortened+"…"
static func acquisition_progress(state)->float:
	var clock=state.capture_feedback()
	return clampf(clock.elapsed/clock.duration,0,1) if clock.duration>0 else 0.
func _ready() -> void:
	clip_contents=true; mouse_filter=Control.MOUSE_FILTER_STOP
func _process(dt: float) -> void:
	time+=dt;_vm_age+=dt;queue_redraw()
# The subject this panel shows: the live exposure, else the viewfinder of the
# selected craft when it has a photographic subject near.
func subject_view() -> Dictionary:
	if sim==null:return {}
	if sim.capture_unit>=0 and sim.selected==sim.capture_unit:
		var o=sim.mission.objectives[sim.capture_target]
		return {"o":o,"index":sim.capture_target,"unit":sim.capture_unit,"live":true} if Photo.applies(o) else {}
	if sim.capture_unit>=0:return {}
	var preview=Photo.preview(sim,sim.selected)
	if preview.is_empty():return {}
	preview["live"]=false
	return preview
static func viewfinder_visible(state) -> bool:
	return state!=null and (state.capture_unit>=0 or not Photo.preview(state,state.selected).is_empty())
func _gui_input(event: InputEvent) -> void:
	var tap=(event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
	if not tap or sim==null:return
	var point=event.position
	for button in _buttons:
		if button.rect.has_point(point):
			sim.command("frame",button.args);_vm_age=1.0;accept_event();return
func _draw_photo(t:Dictionary) -> void:
	var o:Dictionary=t.o;var uid:int=t.unit;var live:bool=t.get("live",false)
	var font=ThemeDB.fallback_font;var fs:=maxi(12,mini(receiver_font_size,15))
	draw_rect(Rect2(Vector2.ZERO,size),Color("07151d"));draw_rect(Rect2(Vector2.ZERO,size),Color("6b9d9f"),false,1)
	var picture:=Rect2(8,36,size.x-16,size.y-36-50)
	var acc:Dictionary=Photo.state(sim).acc.get(uid,{})
	var key:="%d:%d"%[uid,int(t.index)]
	if _vm_age>0.2 or key!=_vm_key or _vm.is_empty():
		_vm_key=key;_vm_age=0.0
		_frame=Photo.frame(sim,uid,o,float(acc.get("t",0.0)),true)
		_vm=PhotoView.from_frame(_frame,"siren" if o.has("siren") else "site")
	PhotoView.draw(self,picture,_vm,time,fs)
	_buttons=[]
	var cfg=Photo.settings(sim,uid);var op=Photo.optics(sim,uid)
	var bx:=size.x-8.0;var bw:=maxf(70.0,fs*5.2);var bh:=28.0
	var specs:Array=[["TIGHT" if cfg.mode=="tight" else "WIDE",{"mode":"wide" if cfg.mode=="tight" else "tight"}]]
	if op.flash:specs.append(["FLASH %d"%Photo.flash_left(sim,uid) if cfg.flash else "NO FLASH",{"flash":not cfg.flash}])
	if cfg.mode=="tight":specs.append(["FOCUS",{"cycle_focus":true}])
	for spec in specs:
		bx-=bw
		var r:=Rect2(bx,4,bw-4,bh)
		draw_rect(r,Color("12333a"));draw_rect(r,Color("8cdcd3") if spec[0]!="NO FLASH" else Color("4a6a6e"),false,1)
		draw_string(font,r.position+Vector2(6,bh*0.7),spec[0],HORIZONTAL_ALIGNMENT_LEFT,r.size.x-8,fs-2,PHOSPHOR)
		_buttons.append({"rect":r,"args":spec[1]})
	draw_string(font,Vector2(10,24),"%s / %s"%["EXPOSING" if live else "VIEWFINDER",sim.units[uid].name],HORIZONTAL_ALIGNMENT_LEFT,maxf(40.0,bx-14),fs,PHOSPHOR)
	var status:String
	if live:status=Photo.progress_text(sim,uid,o)
	else:
		status=str(t.get("ctx",{}).get("text",""))
		for r in _frame.get("rows",[]):
			if r.apparent and not r.ready and not r.why.is_empty():status="%s: %s"%[r.label,r.why];break
	status=fit_caption(status,size.x-20,fs-2)
	draw_string(font,Vector2(10,size.y-30),fit_caption(str(o.name),size.x-90,fs),HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("e0bf83"))
	if live:
		var progress:=acquisition_progress(sim)
		draw_string(font,Vector2(size.x-62,size.y-30),"%02d%%"%int(progress*100),HORIZONTAL_ALIGNMENT_LEFT,-1,fs,PHOSPHOR)
		draw_rect(Rect2(10,size.y-9,size.x-20,3),Color("25464b"));draw_rect(Rect2(10,size.y-9,(size.x-20)*progress,3),PHOSPHOR)
	draw_string(font,Vector2(10,size.y-14),status,HORIZONTAL_ALIGNMENT_LEFT,-1,fs-2,Color("a9c9c7"))
func _draw() -> void:
	_buttons=[]
	if sim==null:return
	var subject:=subject_view()
	if not subject.is_empty():_draw_photo(subject);return
	if sim.capture_unit<0: return
	var objective=sim.mission.objectives[sim.capture_target]
	var well_site=sim.mission.get("well_revision",0)==1 and (not objective.has("optical") or objective.optical=="well_pattern")
	var progress=acquisition_progress(sim)
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
		draw_string(ThemeDB.fallback_font,picture.position+Vector2(8,receiver_font_size+5),"REPLY CARRIER · LOCAL" if context.get("source","")=="courier" else ("LOCAL REPLAY" if context.replay>0 else "QUIET RECEPTION"),HORIZONTAL_ALIGNMENT_LEFT,-1,receiver_font_size,PHOSPHOR)
		if not context.settled:draw_string(ThemeDB.fallback_font,picture.position+Vector2(8,picture.size.y-8),"SETTLING · wait for rest",HORIZONTAL_ALIGNMENT_LEFT,-1,receiver_font_size,Color("e0bf83"))
	elif ReceiverScene.applies(sim.mission.id,objective):
		if objective.get("own_origin",false):ReceiverScene.draw_transmitter(self,picture,sim.capture_feedback())
		elif objective.get("site_id","")=="rendezvous" and not preload("res://src/presentation/rendezvous_view.gd").context(sim).is_empty():ReceiverScene.draw_rendezvous(self,picture,preload("res://src/presentation/rendezvous_view.gd").receiver_lines(sim,sim.capture_unit))
		else:ReceiverScene.draw(self,picture,sim.signal_readings(),sim.capture_unit)
	elif well_site:
		_draw_well_site(picture,objective)
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
	var font_size=receiver_font_size if type=="exchange" or well_site or ReceiverScene.applies(sim.mission.id,objective) else 14
	var heading="%s / %s"%[("TRANSMITTER · ANALYTICAL" if objective.get("own_origin",false) else ReceiverScene.title()) if ReceiverScene.applies(sim.mission.id,objective) else "SITE SCHEMATIC" if well_site else ("HYDROPHONES" if type in ["receiver","exchange"] else ("ARCHIVE LINK" if objective.get("kind","")=="uplink" else "OPTICAL")),sim.units[sim.capture_unit].name]
	if ReceiverScene.applies(sim.mission.id,objective):heading=fit_caption(heading,size.x-28,font_size)
	draw_string(font,Vector2(14,24),heading,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,PHOSPHOR)
	var received_name="REPLY CARRIER" if type=="exchange" and sim.blackwater_context(sim.capture_target,sim.capture_unit).get("source","")=="courier" else objective.name
	if ReceiverScene.applies(sim.mission.id,objective):received_name=fit_caption(received_name,size.x-100,font_size)
	draw_string(font,Vector2(14,size.y-24),received_name,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("e0bf83"))
	draw_string(font,Vector2(size.x-68,size.y-24),"%02d%%"%int(progress*100),HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,PHOSPHOR)
	draw_rect(Rect2(12,size.y-12,size.x-24,3),Color("25464b")); draw_rect(Rect2(12,size.y-12,(size.x-24)*progress,3),PHOSPHOR)

func _draw_well_site(picture:Rect2,objective:Dictionary) -> void:
	# Analytical rendering of the ribbed site already shown on the chart.
	# No photograph, received cadence, hidden listener or decoded interpretation.
	var font=ThemeDB.fallback_font;var detail_size=mini(receiver_font_size,16)
	draw_string(font,picture.position+Vector2(12,detail_size+5),"SITE %02d / GEOMETRY"%(sim.capture_target+1),HORIZONTAL_ALIGNMENT_LEFT,-1,detail_size,Color("83b8b9"))
	var center=picture.position+Vector2(picture.size.x*0.27,picture.size.y*0.60)
	var scale=clampf((picture.size.y-46)/100,0.55,1.0)
	draw_rect(Rect2(center-Vector2(37,47)*scale,Vector2(74,94)*scale),Color("25434b"),false,1.5)
	for x in [-26,-8,10,28]:
		draw_line(center+Vector2(x,-42)*scale,center+Vector2(x,40)*scale,Color("4a9298") if x<0 else Color("a88451"),2)
	for y in [-34,-7,20]:draw_line(center+Vector2(-37,y)*scale,center+Vector2(37,y)*scale,Color("3e646d"),1.5)
	draw_circle(center-Vector2(0,20)*scale,14*scale,Color("102832"))
	draw_arc(center-Vector2(0,20)*scale,12*scale,0,TAU,32,Color("cba26b"),2)
	var column=picture.position+Vector2(picture.size.x*0.54,64)
	var distance=sim.units[sim.capture_unit].pos.distance_to(objective.pos)
	draw_string(font,column,"CAMERA RANGE",HORIZONTAL_ALIGNMENT_LEFT,-1,detail_size,Color("83b8b9"))
	draw_string(font,column+Vector2(0,27),"%dm"%roundi(distance),HORIZONTAL_ALIGNMENT_LEFT,-1,detail_size+5,PHOSPHOR)
	draw_string(font,column+Vector2(0,53),"ACQUIRING",HORIZONTAL_ALIGNMENT_LEFT,-1,detail_size,Color("e0bf83"))
