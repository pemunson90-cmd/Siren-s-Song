extends RefCounted
# PRICED SHOTS drawing: the viewfinder strip (film count, reach, light prices,
# shutter estimate, timing windows) and the chart rings. Draws only what
# photo_pricing.gd reads; nothing here changes the simulation.
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const AMBER=Color("e0bf83")
const WARN=Color("e08a73")
const GREEN=Color(0.5,0.92,0.62)
const INK=Color("a9c9c7")
# Called from the viewfinder after the picture is drawn. `picture` is its rect.
static func draw_viewfinder(ci:CanvasItem,sim,uid:int,o:Dictionary,picture:Rect2,fs:int,frame:Dictionary)->void:
	var r:Dictionary=Pricing.readout(sim,uid,o)
	if r.is_empty():return
	var font=ThemeDB.fallback_font;var small:int=maxi(10,fs-3)
	var tag:String=Table.TEXT.film_tag%[r.film,r.cap]
	var low:bool=int(r.film)<=2
	var tag_w:float=font.get_string_size(tag,HORIZONTAL_ALIGNMENT_LEFT,-1,small).x+10.0
	var box:=Rect2(picture.end.x-tag_w-4,picture.position.y+4,tag_w,small+6)
	ci.draw_rect(box,Color(0.02,0.06,0.08,0.82));ci.draw_rect(box,WARN if low else AMBER,false,1)
	ci.draw_string(font,box.position+Vector2(5,small+1),tag,HORIZONTAL_ALIGNMENT_LEFT,-1,small,WARN if low else AMBER)
	var lines:Array=r.lines.duplicate()
	var heard=lines.pop_back() if not lines.is_empty() else null
	lines.append_array(Pricing.windows(sim,o,frame))
	var rows:int=maxi(1,int(floor(picture.size.y*0.62/float(small+3))))
	lines=lines.slice(0,maxi(0,rows-1))
	if heard!=null:lines.append(heard)
	if lines.is_empty():return
	var h:float=lines.size()*(small+3)+4
	var strip:=Rect2(picture.position.x,picture.end.y-h,picture.size.x,h)
	ci.draw_rect(strip,Color(0.02,0.06,0.08,0.8))
	for n in lines.size():
		var line:Dictionary=lines[n]
		var color:Color=WARN if line.get("warn",false) else (GREEN if line.get("open",false) else INK)
		ci.draw_string(font,strip.position+Vector2(5,(n+1)*(small+3)),ci.fit_caption(str(line.text),strip.size.x-10,small),HORIZONTAL_ALIGNMENT_LEFT,-1,small,color)
# Called inside the chart's world transform. `ci` is the ocean view.
static func draw_chart(ci,sim)->void:
	var rings:Dictionary=Pricing.chart_rings(sim)
	if rings.is_empty():return
	var scale:float=ci.world_scale
	var at:Vector2=rings.pos
	if rings.hidden:
		ci._label(at+Vector2(24,-24),Table.TEXT.reach_hidden%str(rings.label),WARN,14)
	elif float(rings.plain)>0.0:
		ci.draw_arc(at,rings.plain,0,TAU,72,Color(GREEN,0.8),2.0/scale)
		ci._label(at+Vector2.from_angle(-0.8)*float(rings.plain),"%s %dm"%[str(rings.label),roundi(rings.plain)],GREEN,14)
		if float(rings.flash)>float(rings.plain)+1.0:
			_dotted(ci,at,rings.flash,Color(GREEN,0.5),1.4/scale,48)
	for s in rings.sirens:
		_dotted(ci,s.pos,s.r,Color(0.95,0.7,0.35,0.7),1.6/scale,40)
	_dotted(ci,rings.craft,rings.heard,Color(0.55,0.85,0.95,0.28),1.2/scale,64)
static func _dotted(ci,center:Vector2,radius:float,color:Color,width:float,segments:int)->void:
	for k in segments:
		if k%2==0:ci.draw_arc(center,radius,TAU*k/segments,TAU*(k+1)/segments,6,color,width)
