extends RefCounted
# 121 AI-DESIGNED subject compositions for required photo records. Pat may
# replace any of them. Picture content only: exposure, grading, quality, what
# counts as captured and sensing are untouched. Each composition is a
# subject-specific scene in the photograph's palette. Siren architecture uses
# the game's own basalt and foundry art; human work is plain drawn steel, so the
# contrast itself shows who built what. The decisive evidence (people, bore,
# damage) only becomes readable as the frame resolves its feature: `ev` is the
# best resolved feature quality, and sharpness adds the fine detail on top.
const BASALT=preload("res://assets/materials/basalt.png")
const FOUNDRY=preload("res://assets/structures/foundry.png")
const AMBER=Color("e0bf83")
const PHOSPHOR=Color("8cdcd3")
# Optical key -> composition. Every key is a recorded photo objective.
const LOOKS={
	"glass_record_32":"drill_ribs","glass_record_32_bonus":"nameplate",
	"glass_record_33":"gallery_people","glass_record_33_bonus":"reed_scoring",
	"glass_record_34":"bore_junction","glass_record_34_bonus":"impact_face",
	"glass_record_35":"crushed_keel","glass_record_35_bonus":"empty_berths",
	"glass_record_36":"guard_window","glass_record_36_bonus":"permit_stone",
	"spire":"signal_spire","relay_west":"relay_spine","relay_east":"relay_wall",
	"furnace":"vent_mouth","cradle":"launch_cradle","well_pattern":"array_ribs",
	"well_aperture":"rim_aperture","well_return":"archive_face","transmitter":"vane_crown",
	"departure":"wake_split","final_photo_30":"scour_edge","final_photo_30_bonus":"spindle_collar",
	"final_photo_31":"survivor_marks","final_photo_31_bonus":"feed_terminals"}
# Foundry art regions (source pixels) reused as Siren surface detail.
const SPINE=Rect2(700,60,140,700)
const CYLINDERS=Rect2(470,320,200,330)
const FINS=Rect2(940,170,130,110)
const PANEL=Rect2(1060,390,140,220)
static func has(look:String)->bool:
	return look in LOOKS.values()
static func rnd(n:int)->float:
	return fposmod(sin(float(n)*12.9898)*43758.5453,1.0)
static func _c(c:Color,a:float)->Color:
	return Color(c.r,c.g,c.b,clampf(c.a*a,0.0,1.0))
# Texture modulate for the shared art: the craft lamp lifts it toward pale teal.
static func _tone(ctx:Dictionary,k:float=1.0)->Color:
	var l:float=clampf(float(ctx.light)*1.15*k,0.0,1.0)
	var c:Color=Color(0.2,0.3,0.32).lerp(Color(0.95,1.08,1.04),l)
	c.a=float(ctx.alpha)
	return c
static func _steel(ctx:Dictionary,k:float=1.0)->Color:
	var l:float=clampf(float(ctx.light)*1.25*k,0.0,1.0)
	var c:Color=Color(0.05,0.07,0.08).lerp(Color(0.5,0.58,0.58),l)
	c.a=float(ctx.alpha)
	return c
static func _stone(ci:CanvasItem,pts:PackedVector2Array,ctx:Dictionary,k:float=1.0,seed_n:int=0)->void:
	if pts.size()<3:return
	var lo:=pts[0];var hi:=pts[0]
	for p in pts:lo=Vector2(minf(lo.x,p.x),minf(lo.y,p.y));hi=Vector2(maxf(hi.x,p.x),maxf(hi.y,p.y))
	var size:Vector2=(hi-lo).max(Vector2.ONE)
	var win:Vector2=Vector2(minf(0.9,size.x/700.0+0.15),minf(0.9,size.y/700.0+0.15))
	var off:Vector2=Vector2(rnd(seed_n*3+1),rnd(seed_n*5+2))*(Vector2.ONE-win)
	var uv:=PackedVector2Array()
	for p in pts:uv.append(off+(p-lo)/size*win)
	ci.draw_colored_polygon(pts,_c(Color(0.03,0.05,0.06),float(ctx.alpha)))
	ci.draw_polygon(pts,PackedColorArray([_tone(ctx,k)]),uv,BASALT)
static func _art(ci:CanvasItem,r:Rect2,src:Rect2,ctx:Dictionary,k:float=1.0)->void:
	if r.size.x<2.0 or r.size.y<2.0:return
	ci.draw_texture_rect_region(FOUNDRY,r,src,_tone(ctx,k))
static func _ellipse(c:Vector2,rx:float,ry:float,n:int=28)->PackedVector2Array:
	var pts:=PackedVector2Array()
	for i in n:pts.append(c+Vector2(cos(TAU*i/n)*rx,sin(TAU*i/n)*ry))
	return pts
static func _ring(ci:CanvasItem,c:Vector2,rx:float,ry:float,col:Color,w:float)->void:
	var pts:=_ellipse(c,rx,ry,32);pts.append(pts[0])
	ci.draw_polyline(pts,col,w,true)
static func _glow(ci:CanvasItem,r:Rect2,c:Vector2,rx:float,ry:float,col:Color,steps:int=5)->void:
	for k in steps:
		var f:float=1.0-float(k)/steps
		var pts:=_ellipse(c,rx*f,ry*f,20)
		for i in pts.size():pts[i]=Vector2(clampf(pts[i].x,r.position.x,r.end.x),clampf(pts[i].y,r.position.y,r.end.y))
		ci.draw_colored_polygon(pts,Color(col.r,col.g,col.b,col.a/steps*1.6))
static func _text(ci:CanvasItem,p:Vector2,s:String,size:int,col:Color)->void:
	ci.draw_string(ThemeDB.fallback_font,p,s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,col)
# One human figure, feet on the ground line. kind: driller (hard hat, headlamp,
# reflective band) or guard (peaked cap, slung rifle, armband). pose 1 = a palm
# raised against glass. `see` 0..1 sets how much of the figure is legible.
static func person(ci:CanvasItem,feet:Vector2,h:float,kind:String,sil:Color,rim:Color,see:float,detail:float,pose:int,rect:Rect2)->void:
	var x:float=feet.x;var y:float=feet.y
	var bulk:float=1.15 if kind=="driller" else 1.0
	var sh:float=y-h*0.76;var wa:float=y-h*0.45
	var sw:float=h*0.13*bulk;var ww:float=h*0.1*bulk
	# Legs, torso, arms, head.
	ci.draw_colored_polygon(PackedVector2Array([Vector2(x-ww,wa),Vector2(x-h*0.01,wa),Vector2(x-h*0.03,y),Vector2(x-ww-h*0.02,y)]),sil)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(x+h*0.01,wa),Vector2(x+ww,wa),Vector2(x+ww+h*0.02,y),Vector2(x+h*0.03,y)]),sil)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(x-sw,sh),Vector2(x+sw,sh),Vector2(x+ww*1.05,wa+h*0.02),Vector2(x-ww*1.05,wa+h*0.02)]),sil)
	var aw:float=maxf(1.5,h*0.055*bulk)
	ci.draw_line(Vector2(x-sw,sh+h*0.02),Vector2(x-sw-h*0.04,wa+h*0.04),sil,aw)
	var hand:Vector2=Vector2(x+sw+h*0.1,y-h*0.98) if pose==1 else Vector2(x+sw+h*0.04,wa+h*0.04)
	var elbow:Vector2=Vector2(x+sw+h*0.1,sh+h*0.04) if pose==1 else Vector2(x+sw+h*0.03,(sh+wa)*0.5)
	ci.draw_line(Vector2(x+sw,sh+h*0.02),elbow,sil,aw);ci.draw_line(elbow,hand,sil,aw)
	var head:Vector2=Vector2(x,y-h*0.86);var hr:float=h*0.075
	ci.draw_line(Vector2(x,sh),head,sil,h*0.06)
	ci.draw_circle(head,hr,sil)
	if see<0.25:return
	var hs:float=clampf((see-0.25)/0.35,0.0,1.0)
	if kind=="driller":
		var dome:=PackedVector2Array()
		for i in 13:dome.append(head+Vector2(cos(PI+PI*i/12.0)*hr*1.35,sin(PI+PI*i/12.0)*hr*1.25-hr*0.15))
		ci.draw_colored_polygon(dome,sil)
		ci.draw_line(head+Vector2(-hr*1.6,-hr*0.15),head+Vector2(hr*1.6,-hr*0.15),sil,maxf(1.0,hr*0.35))
		if see>0.4:
			var lamp:Vector2=head+Vector2(hr*0.9,-hr*0.75)
			_glow(ci,rect,lamp,hr*2.6,hr*2.0,Color(1.0,0.85,0.55,0.35*hs*sil.a),4)
			ci.draw_circle(lamp,maxf(1.0,hr*0.35),Color(1.0,0.95,0.8,hs*sil.a))
		if see>0.6 and detail>0.45:
			ci.draw_line(Vector2(x-sw*0.95,sh+h*0.12),Vector2(x+sw*0.95,sh+h*0.12),_c(rim,hs),maxf(1.0,h*0.025))
			ci.draw_line(Vector2(x-ww*0.9,wa-h*0.04),Vector2(x+ww*0.9,wa-h*0.04),_c(rim,hs*0.8),maxf(1.0,h*0.02))
	else:
		ci.draw_colored_polygon(PackedVector2Array([head+Vector2(-hr*1.1,-hr*0.4),head+Vector2(hr*1.1,-hr*0.4),head+Vector2(hr*0.9,-hr*1.25),head+Vector2(-hr*0.9,-hr*1.25)]),sil)
		ci.draw_line(head+Vector2(-hr*0.2,-hr*0.45),head+Vector2(hr*1.9,-hr*0.3),sil,maxf(1.0,hr*0.3))
		if see>0.45:
			ci.draw_line(Vector2(x-sw*1.1,wa+h*0.06),Vector2(x+sw*1.3,sh-h*0.12),sil,maxf(1.5,h*0.035))
			ci.draw_line(Vector2(x-sw*1.1,wa+h*0.06),Vector2(x+sw*1.3,sh-h*0.12),_c(rim,0.35*hs),1.0)
		if see>0.6 and detail>0.45:
			ci.draw_line(Vector2(x-sw-h*0.005,sh+h*0.09),Vector2(x-sw-h*0.025,sh+h*0.15),_c(AMBER,hs*sil.a),maxf(1.5,h*0.045))
			ci.draw_line(Vector2(x+h*0.02,sh+h*0.04),Vector2(x+h*0.07,sh+h*0.04),_c(rim,hs),maxf(1.0,h*0.02))
	if see>0.5:
		ci.draw_line(Vector2(x+sw,sh),Vector2(x+ww*1.05,wa),_c(rim,0.6*hs),1.0)
		ci.draw_arc(head,hr,-1.2,0.6,8,_c(rim,0.7*hs),1.0)
	if pose==1 and see>0.55:
		ci.draw_circle(hand,maxf(1.5,h*0.035),_c(Color(0.78,0.66,0.55),hs*sil.a))
static func draw(ctx:Dictionary,look:String)->void:
	var ci:CanvasItem=ctx.ci;var rect:Rect2=ctx.rect
	var g:={"ci":ci,"rect":rect,"cx":float(ctx.cx)+float(ctx.dx),"base":float(ctx.base),"s":float(ctx.s),"a":float(ctx.a),"al":float(ctx.alpha),
		"light":float(ctx.light),"detail":clampf(float(ctx.sharp)*1.3,0.0,1.0),"ev":float(ctx.get("ev",0.0)),"seed":int(ctx.seed),"time":float(ctx.time),"evs":ctx.get("evs",{})}
	# A composed scene foreshortens gently; it stays readable side on.
	g["fx"]=lerpf(0.72,1.0,absf(cos(g.a)))
	g["w"]=minf(g.s*2.3*g.fx,rect.size.x*0.9)
	g["see"]=clampf(g.ev*1.2,0.0,1.0)
	g["lit"]=clampf(g.light*1.3,0.0,1.0)
	var c:={"light":g.light,"alpha":g.al}
	g["tone"]=c
	match look:
		"gallery_people":_gallery_people(g)
		"bore_junction":_bore_junction(g)
		"drill_ribs":_drill_ribs(g)
		"nameplate":_nameplate(g)
		"reed_scoring":_reed_scoring(g)
		"impact_face":_impact_face(g)
		"crushed_keel":_crushed_keel(g)
		"empty_berths":_empty_berths(g)
		"guard_window":_guard_window(g)
		"permit_stone":_permit_stone(g)
		"signal_spire":_signal_spire(g)
		"relay_spine":_relay(g,true)
		"relay_wall":_relay(g,false)
		"vent_mouth":_vent_mouth(g)
		"launch_cradle":_launch_cradle(g)
		"array_ribs":_array_ribs(g)
		"rim_aperture":_rim_aperture(g)
		"archive_face":_archive_face(g)
		"vane_crown":_vane_crown(g)
		"wake_split":_wake_split(g)
		"scour_edge":_scour_edge(g)
		"spindle_collar":_spindle_collar(g)
		"survivor_marks":_survivor_marks(g)
		"feed_terminals":_feed_terminals(g)
# --- shared pieces -------------------------------------------------------------
# How legible one feature's evidence is: its own resolved quality, so a subject
# with several features shows each one only when the frame resolved that one.
static func _see(g:Dictionary,id:String)->float:
	return clampf(float(g.evs.get(id,0.0))*1.2,0.0,1.0)
# The seabed falls away into the trench beyond x.
static func trench_polygon(rect:Rect2,x:float,base:float,s:float)->PackedVector2Array:
	var top:float=base-s*0.06
	if rect.size.x<=0.0 or rect.size.y<=0.0 or s<=0.0 or x>=rect.end.x-2.0 or top>=rect.end.y:return PackedVector2Array()
	# A subject can leave only a sliver of trench at the picture's right edge.
	# Keep its sloping foot left of that edge, so the sides never cross.
	var foot:float=x+minf(s*0.1,(rect.end.x-x)*0.5)
	return PackedVector2Array([Vector2(x,top),Vector2(rect.end.x,top-s*0.02),rect.end,Vector2(foot,rect.end.y)])
static func _trench(g:Dictionary,x:float)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al;var base:float=g.base;var s:float=g.s
	var pts:=trench_polygon(rect,x,base,s)
	if pts.is_empty():return
	ci.draw_polygon(pts,PackedColorArray([Color(0.0,0.01,0.015,al*0.9),Color(0.0,0.01,0.015,al*0.9),Color(0.0,0.0,0.005,al),Color(0.0,0.0,0.005,al)]))
	ci.draw_line(pts[0],pts[1],Color(0.7,0.88,0.84,al*0.3*float(g.lit)),1.5)
static func _plated_wall(g:Dictionary,l:float,r:float,t:float,b:float)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var body:Color=_steel(g.tone,1.0);var dark:Color=_steel(g.tone,0.45)
	ci.draw_polygon(PackedVector2Array([Vector2(l,t),Vector2(r,t),Vector2(r,b),Vector2(l,b)]),PackedColorArray([body,body,dark,dark]))
	var seam:=Color(0.0,0.02,0.03,al*0.5*float(g.detail))
	var plates:int=8
	for k in range(1,plates):
		var x:float=l+(r-l)*float(k)/plates
		ci.draw_line(Vector2(x,t+2),Vector2(x,b-2),seam,1.0)
	for k in range(1,3):ci.draw_line(Vector2(l+2,t+(b-t)*k/3.0),Vector2(r-2,t+(b-t)*k/3.0),seam,1.0)
	if float(g.detail)>0.5:
		var riv:=Color(0.75,0.9,0.86,al*0.3*float(g.lit))
		for k in int((r-l)/9.0):ci.draw_circle(Vector2(l+4+k*9.0,t+4),1.0,riv)
	ci.draw_line(Vector2(l,t),Vector2(r,t),Color(0.75,0.92,0.88,al*0.35*float(g.lit)),1.5)
	# Growth and rust streaks running down the plating.
	for k in 7:
		var x:float=l+(r-l)*rnd(int(g.seed)+k*13)
		ci.draw_line(Vector2(x,t+4),Vector2(x+2,t+(b-t)*(0.3+0.5*rnd(k*7+int(g.seed)))),Color(0.35,0.22,0.12,al*0.25),1.0+rnd(k)*2.0)
static func _stone_face(g:Dictionary,l:float,r:float,t:float,b:float,seed_n:int)->PackedVector2Array:
	var pts:=PackedVector2Array()
	var n:=10
	for i in n+1:
		var x:float=lerpf(l,r,float(i)/n)
		pts.append(Vector2(x,t+(rnd(seed_n+i*7)-0.5)*(b-t)*0.16+(0.0 if i>0 and i<n else (b-t)*0.12)))
	pts.append(Vector2(r,b));pts.append(Vector2(l,b))
	_stone(g.ci,pts,g.tone,1.0,seed_n)
	return pts
# --- compositions --------------------------------------------------------------
# 33: survivors at the gallery glass. A plated pressure wall with a long lit
# gallery window; behind it four drillers and two guards, lit from inside.
static func _gallery_people(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var h:float=s*0.9;var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-h
	_plated_wall(g,l,r,t,base)
	var wl:float=l+w*0.08;var wr:float=r-w*0.08;var wt:float=t+h*0.14;var wb:float=base-h*0.2
	# The interior is lit by the survivors' own lamps, so it reads even in a dark frame.
	var inner_top:=Color(0.42,0.32,0.18,al).lerp(Color(0.7,0.55,0.32,al),0.4*float(g.lit))
	var inner_low:=Color(0.16,0.12,0.08,al)
	ci.draw_polygon(PackedVector2Array([Vector2(wl,wt),Vector2(wr,wt),Vector2(wr,wb),Vector2(wl,wb)]),PackedColorArray([inner_top,inner_top,inner_low,inner_low]))
	# Back wall of the gallery: a pipe run, a pressure door and a hanging lamp.
	ci.draw_line(Vector2(wl,wt+(wb-wt)*0.22),Vector2(wr,wt+(wb-wt)*0.22),Color(0.1,0.08,0.05,al*0.7),maxf(2.0,h*0.025))
	ci.draw_rect(Rect2(wl+(wr-wl)*0.78,wt+(wb-wt)*0.3,(wr-wl)*0.1,(wb-wt)*0.7),Color(0.12,0.09,0.06,al*0.8))
	var lamp:Vector2=Vector2(wl+(wr-wl)*0.35,wt+(wb-wt)*0.1)
	_glow(ci,rect,lamp,(wr-wl)*0.22,(wb-wt)*0.5,Color(1.0,0.82,0.5,0.3*al),5)
	ci.draw_circle(lamp,maxf(1.5,h*0.02),Color(1.0,0.95,0.8,al))
	var see:float=g.see
	var kinds:=["driller","guard","driller","driller","guard","driller"]
	var poses:=[0,1,0,1,0,0]
	var fh:float=(wb-wt)*0.82
	var sil:=Color(0.015,0.025,0.03,al)
	var rim:=Color(0.95,0.85,0.6,al)
	for i in kinds.size():
		var x:float=wl+(wr-wl)*(0.09+0.142*i)+(rnd(i*5+int(g.seed))-0.5)*(wr-wl)*0.02
		var hh:float=fh*(0.9+0.1*rnd(i*3+1))
		if see<=0.0:
			# Unresolved: only dark shapes moving behind the lit pane.
			_glow(ci,rect,Vector2(x,wb-hh*0.5),hh*0.16,hh*0.5,Color(0.02,0.03,0.035,0.55*al),3)
		else:
			person(ci,Vector2(x,wb),hh,kinds[i],Color(sil.r,sil.g,sil.b,al*lerpf(0.55,1.0,see)),rim,see,g.detail,poses[i],rect)
	# Glass: mullions, glare and grime over the figures.
	var frame_c:Color=_steel(g.tone,0.7)
	ci.draw_rect(Rect2(wl,wt,wr-wl,wb-wt),frame_c,false,maxf(3.0,h*0.04))
	for k in range(1,3):
		var x:float=wl+(wr-wl)*k/3.0
		ci.draw_line(Vector2(x,wt),Vector2(x,wb),frame_c,maxf(2.0,h*0.025))
	var glare:=Color(0.85,0.97,0.95,al*0.1*(0.4+float(g.lit)))
	for k in 3:
		var gx:float=wl+(wr-wl)*(0.15+0.3*k)
		ci.draw_colored_polygon(PackedVector2Array([Vector2(gx,wt),Vector2(gx+(wr-wl)*0.05,wt),Vector2(gx-(wr-wl)*0.05,wb),Vector2(gx-(wr-wl)*0.1,wb)]),glare)
	if float(g.detail)>0.6 and see>0.75:
		_text(ci,Vector2(wl+4,wb+maxf(10.0,h*0.08)),"GALLERY",clampi(int(h*0.07),9,15),_c(AMBER,al*0.85))
# 34: the human bore through the Siren foundation. Layered foundation stone
# with ornate Siren courses; a plain steel casing punches straight through.
static func _bore_junction(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var h:float=s*0.95;var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-h
	_stone_face(g,l,r,t,base,int(g.seed)+34)
	# Siren courses: three bands of foundry art laid across the face.
	for k in 3:
		var y:float=t+h*(0.22+0.25*k)
		_art(ci,Rect2(l+w*0.02,y,w*0.96,h*0.09),Rect2(330,620+k*40,800,60),g.tone,0.9)
		ci.draw_line(Vector2(l+w*0.02,y+h*0.045),Vector2(r-w*0.02,y+h*0.045),Color(0.9,0.22,0.16,al*0.35*(0.4+float(g.lit))),1.5)
	var see:float=g.see
	var c:=Vector2(cx+w*0.04,t+h*0.5)
	var ry:float=h*0.24;var rx:float=ry*maxf(0.55,float(g.fx))
	# Raw broken stone around the cut is paler than the weathered face.
	var raw:=PackedVector2Array()
	for i in 22:
		var a:float=TAU*i/22.0;var k:float=1.3+0.25*rnd(i*11+int(g.seed))
		raw.append(c+Vector2(cos(a)*rx*k,sin(a)*ry*k))
	ci.draw_colored_polygon(raw,_c(Color(0.55,0.62,0.6).lerp(Color(0.2,0.25,0.25),1.0-float(g.lit)),al*0.75))
	ci.draw_colored_polygon(_ellipse(c,rx*1.08,ry*1.08),Color(0.0,0.008,0.012,al))
	if see<=0.0:return
	var steel:Color=_steel(g.tone,1.2)
	# Casing tube receding into the dark, offset by the aspect.
	var depth_dir:=Vector2(-sin(float(g.a))*rx*0.5,ry*0.08)
	for k in 5:
		var f:float=float(k)/4.0
		_ring(ci,c+depth_dir*f,rx*(1.0-0.45*f),ry*(1.0-0.45*f),_c(steel,(1.0-0.75*f)*lerpf(0.5,1.0,see)),maxf(1.0,ry*0.09*(1.0-0.6*f)))
	if see>0.4:
		# Severed Siren courses: their red seams end at the casing.
		for k in 3:
			var y:float=t+h*(0.22+0.25*k)+h*0.045
			if absf(y-c.y)<ry*1.2:
				var dx:float=rx*1.15*sqrt(maxf(0.0,1.0-pow((y-c.y)/(ry*1.15),2)))
				for side in [-1.0,1.0]:ci.draw_circle(Vector2(c.x+side*dx,y),maxf(1.5,ry*0.06),Color(1.0,0.3,0.2,al*0.85))
		for i in 9:
			var a:float=TAU*i/9.0+0.3
			var p0:=c+Vector2(cos(a)*rx*1.2,sin(a)*ry*1.2)
			ci.draw_polyline(PackedVector2Array([p0,p0+Vector2(cos(a+0.2)*rx*0.35,sin(a+0.2)*ry*0.35),p0+Vector2(cos(a-0.1)*rx*0.7,sin(a-0.1)*ry*0.7)]),Color(0.0,0.02,0.03,al*0.7),1.2)
	if see>0.3:
		# Drill string leaving the bore to the seabed.
		ci.draw_line(c+depth_dir*0.3,Vector2(c.x+w*0.32,base+s*0.06),_c(steel,0.9),maxf(2.0,ry*0.14))
		for k in 4:
			var p:=(c+depth_dir*0.3).lerp(Vector2(c.x+w*0.32,base+s*0.06),0.2+0.2*k)
			ci.draw_circle(p,maxf(1.5,ry*0.1),_c(steel.lightened(0.2),0.9))
	if see>0.6 and float(g.detail)>0.5:
		for i in 12:
			var a:float=TAU*i/12.0
			ci.draw_circle(c+Vector2(cos(a)*rx*1.0,sin(a)*ry*1.0),maxf(1.0,ry*0.035),Color(0.85,0.95,0.92,al*0.7*float(g.lit)+0.15*al))
	if see>0.75 and float(g.detail)>0.6:
		for k in 3:ci.draw_arc(c+depth_dir*0.6,ry*(0.3+0.12*k),0.4+k,2.4+k,10,Color(0.75,0.85,0.82,al*0.35),1.0)
# 32: the drill string driven into the old Siren ribs.
static func _drill_ribs(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var see:float=g.see
	var hit:=Vector2.ZERO
	for k in 5:
		var x:float=cx-w*0.42+w*0.21*k
		var rh:float=s*(0.62+0.22*sin(float(k)*1.1+0.6))
		var rw:float=w*0.085
		var outer:=PackedVector2Array();var inner:=PackedVector2Array()
		for i in 13:
			var a:float=PI+PI*i/12.0
			outer.append(Vector2(x+cos(a)*rw,base+sin(a)*rh))
			inner.append(Vector2(x+cos(a)*rw*0.62,base+sin(a)*rh*0.86))
		inner.reverse()
		_stone(ci,outer+inner,g.tone,0.95,k*17+int(g.seed))
		ci.draw_polyline(outer,Color(0.75,0.9,0.86,al*0.3*float(g.lit)),1.2)
		ci.draw_polyline(inner,Color(0.9,0.22,0.16,al*0.3*(0.4+float(g.lit))),1.2)
		if k==3:hit=Vector2(x+rw*0.2,base-rh*0.96)
	var steel:Color=_steel(g.tone,1.2)
	var top:=Vector2(hit.x+w*0.22,rect.position.y)
	var a_pipe:float=lerpf(0.35,1.0,see)
	ci.draw_line(top,hit,_c(steel,a_pipe),maxf(2.5,s*0.035))
	if see<=0.0:return
	for k in 5:
		var p:=top.lerp(hit,0.15+0.17*k)
		ci.draw_line(p+Vector2(-s*0.03,0),p+Vector2(s*0.03,0),_c(steel.lightened(0.2),a_pipe),maxf(2.0,s*0.02))
	if see>0.4:
		_glow(ci,rect,hit,s*0.12,s*0.08,Color(0.85,0.95,0.9,0.35*al),4)
		_ring(ci,hit,s*0.04,s*0.025,Color(0.95,1.0,0.98,al*0.9),1.5)
		for i in 6:
			var a:float=PI*0.15+PI*0.7*i/5.0
			ci.draw_line(hit,hit+Vector2(cos(a),sin(a))*s*(0.08+0.06*rnd(i)),Color(0.0,0.02,0.03,al*0.8),1.2)
	if see>0.7 and float(g.detail)>0.5:
		for i in 10:
			ci.draw_circle(hit+Vector2((rnd(i*3)-0.5)*s*0.25,rnd(i*7)*s*0.3),1.0+rnd(i)*1.5,Color(0.7,0.8,0.78,al*0.5))
# 32 bonus: the guard shift roster beside a hatch.
static func _nameplate(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var h:float=s*0.85;var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-h
	_plated_wall(g,l,r,t,base)
	var hc:=Vector2(l+w*0.28,t+h*0.5)
	ci.draw_colored_polygon(_ellipse(hc,w*0.12,h*0.34),_c(_steel(g.tone,0.35),1.0))
	_ring(ci,hc,w*0.12,h*0.34,_steel(g.tone,1.1),maxf(2.0,h*0.03))
	_ring(ci,hc,w*0.05,w*0.05,_steel(g.tone,1.2),2.0)
	var pr:=Rect2(l+w*0.5,t+h*0.22,w*0.36,h*0.52)
	ci.draw_rect(pr,_steel(g.tone,1.35))
	ci.draw_rect(pr,Color(0.0,0.02,0.03,al*0.6),false,1.5)
	for p in [pr.position,Vector2(pr.end.x,pr.position.y),pr.end,Vector2(pr.position.x,pr.end.y)]:
		ci.draw_circle(p+(pr.get_center()-p).normalized()*6.0,maxf(1.5,h*0.02),Color(0.0,0.02,0.03,al*0.8))
	var see:float=g.see
	if see<=0.0:return
	var rows:=6
	for k in rows:
		var y:float=pr.position.y+pr.size.y*(0.24+0.12*k)
		var len_f:float=0.5+0.4*rnd(k*9+3)
		ci.draw_line(Vector2(pr.position.x+pr.size.x*0.1,y),Vector2(pr.position.x+pr.size.x*(0.1+0.8*len_f),y),Color(0.02,0.04,0.05,al*lerpf(0.3,0.9,see)),maxf(1.0,h*0.025))
	if see>0.7 and float(g.detail)>0.55:
		_text(ci,pr.position+Vector2(pr.size.x*0.08,pr.size.y*0.15),"WATCH ROSTER",clampi(int(h*0.07),8,14),Color(0.02,0.04,0.05,al))
# 33 bonus: parallel Siren cuts in stone, a loose choir reed below.
static func _reed_scoring(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var h:float=s*0.8;var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-h
	_stone_face(g,l,r,t,base,int(g.seed)+33)
	var see:float=g.see
	for k in 5:
		var p0:=Vector2(cx-w*0.25+k*w*0.07,t+h*0.15)
		var p1:=p0+Vector2(w*0.22,h*0.62)
		var mid:=(p0+p1)*0.5+Vector2(-w*0.03,0)
		var groove:=PackedVector2Array([p0,mid,p1])
		ci.draw_polyline(groove,Color(0.0,0.01,0.015,al*lerpf(0.35,0.95,see)),maxf(2.0,s*0.03))
		if see>0.3:ci.draw_polyline(PackedVector2Array([p0+Vector2(2,2),mid+Vector2(2,2),p1+Vector2(2,2)]),Color(0.8,0.92,0.88,al*0.4*float(g.lit)),1.0)
	if see<=0.0:return
	var a:=Vector2(cx-w*0.35,base+s*0.06);var b:=Vector2(cx+w*0.1,base+s*0.02)
	ci.draw_line(a,b,Color(0.5,0.42,0.36,al),maxf(3.0,s*0.04))
	for k in 7:
		var p:=a.lerp(b,0.1+0.13*k)
		ci.draw_line(p+Vector2(0,-s*0.025),p+Vector2(0,s*0.025),Color(0.2,0.15,0.12,al),1.4)
	if see>0.5:_glow(ci,rect,b,s*0.06,s*0.04,Color(1.0,0.3,0.2,0.4*al),3)
# 34 bonus: the cratered, glassed first-strike face.
static func _impact_face(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var h:float=s*0.85;var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-h
	_stone_face(g,l,r,t,base,int(g.seed)+341)
	var c:=Vector2(cx,t+h*0.5);var ry:float=h*0.28;var rx:float=ry*1.3*float(g.fx)
	ci.draw_colored_polygon(_ellipse(c,rx,ry),Color(0.01,0.02,0.025,al*0.65))
	var see:float=g.see
	if see<=0.0:return
	for i in 14:
		var a:float=TAU*i/14.0+rnd(i)*0.2
		var p0:=c+Vector2(cos(a)*rx*0.8,sin(a)*ry*0.8)
		ci.draw_polyline(PackedVector2Array([p0,p0+Vector2(cos(a+0.15),sin(a+0.15))*ry*0.5,p0+Vector2(cos(a),sin(a))*ry*(0.9+0.5*rnd(i*5))]),Color(0.0,0.015,0.02,al*0.85),1.3)
	for k in 3:_ring(ci,c,rx*(0.35+0.2*k),ry*(0.35+0.2*k),Color(0.75,0.9,0.95,al*0.25*see),1.0)
	if see>0.5:
		# Glassed rim: the stone melted and set smooth around the crater.
		var rim:=PackedVector2Array()
		for i in 25:
			var a:float=TAU*i/24.0
			rim.append(c+Vector2(cos(a)*rx*(1.0+0.08*rnd(i*3)),sin(a)*ry*(1.0+0.08*rnd(i*3))))
		ci.draw_polyline(rim,Color(0.8,0.95,1.0,al*0.5*(0.4+float(g.lit))),maxf(2.0,ry*0.08))
		for i in 6:
			var a:float=TAU*rnd(i*13+5)
			ci.draw_circle(c+Vector2(cos(a)*rx*0.95,sin(a)*ry*0.95),maxf(1.0,ry*0.04),Color(1.0,1.0,1.0,al*0.6*float(g.lit)))
	if see>0.65 and float(g.detail)>0.5:
		for i in 8:
			var p:=Vector2(cx+(rnd(i*4)-0.3)*w*0.6,base+s*(0.02+0.05*rnd(i*9)))
			var q:float=s*(0.02+0.03*rnd(i))
			ci.draw_colored_polygon(PackedVector2Array([p+Vector2(-q,0),p+Vector2(-q*0.3,-q*0.8),p+Vector2(q,-q*0.4),p+Vector2(q*0.8,0)]),_steel(g.tone,0.8))
# 35: a guard boat keel crushed under the fallen drill deck.
static func _crushed_keel(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var see:float=g.see
	var l:float=cx-w*0.5;var r:float=cx+w*0.5
	var hull_h:float=s*0.4
	var dent:float=hull_h*0.5*see
	# A guard boat side on: square stern, raised bow, a keel curving under it.
	var hull:=PackedVector2Array([Vector2(l+w*0.02,base-hull_h),Vector2(cx-w*0.12,base-hull_h*1.02),Vector2(cx,base-hull_h+dent),Vector2(cx+w*0.14,base-hull_h*1.05),Vector2(r,base-hull_h*1.3)])
	for i in 9:
		var f:float=float(i)/8.0
		hull.append(Vector2(lerpf(r-w*0.02,l+w*0.06,f),base-hull_h*(1.2*pow(1.0-f,3.0)+0.03)))
	hull.append(Vector2(l+w*0.02,base-hull_h*0.35))
	var body:Color=_steel(g.tone,0.8);var dark:Color=_steel(g.tone,0.4)
	ci.draw_colored_polygon(hull,body)
	ci.draw_line(Vector2(l+w*0.03,base-hull_h*0.62),Vector2(r-w*0.06,base-hull_h*0.78),Color(0.85,0.6,0.3,al*0.6),maxf(2.0,s*0.025))
	ci.draw_polyline(PackedVector2Array([Vector2(l+w*0.04,base-hull_h*0.25),Vector2(r-w*0.2,base-hull_h*0.2)]),dark,maxf(1.5,s*0.015))
	for k in 9:
		var x:float=l+w*(0.08+0.1*k)
		var bend:float=dent*(1.0-clampf(absf(x-cx)/(w*0.15),0.0,1.0))
		ci.draw_line(Vector2(x,base-hull_h*0.85+bend),Vector2(x,base-2),Color(0.0,0.02,0.03,al*0.45*float(g.detail)),1.0)
	# Fallen drill deck: a lattice girder slab resting on the keel.
	var d0:=Vector2(l-w*0.05,base-s*0.95);var d1:=Vector2(cx+w*0.02,base-hull_h+dent-2)
	var n:=(d1-d0).orthogonal().normalized()*s*0.09
	ci.draw_colored_polygon(PackedVector2Array([d0,d1,d1+n,d0+n]),_steel(g.tone,0.75))
	for k in 8:
		var p:=d0.lerp(d1,float(k)/8.0);var q:=d0.lerp(d1,float(k+1)/8.0)
		ci.draw_line(p,q+n,Color(0.0,0.02,0.03,al*0.7),1.2)
		ci.draw_line(p+n,q,Color(0.0,0.02,0.03,al*0.5),1.0)
	ci.draw_line(d0,d1,Color(0.75,0.9,0.86,al*0.35*float(g.lit)),1.5)
	if see>0.45:
		for i in 6:
			var a:float=PI*0.1+PI*0.8*i/5.0
			ci.draw_line(Vector2(cx,base-hull_h+dent),Vector2(cx,base-hull_h+dent)+Vector2(cos(a),sin(a)*0.6)*s*0.12,Color(0.0,0.02,0.03,al*0.8),1.3)
	if see>0.65 and float(g.detail)>0.5:
		_text(ci,Vector2(r-w*0.36,base-hull_h*0.42),"GUARD",clampi(int(s*0.07),8,14),Color(0.85,0.92,0.88,al*0.75))
		for i in 5:
			var p:=Vector2(cx+w*(0.15+0.06*i),base+s*0.04)
			ci.draw_colored_polygon(PackedVector2Array([p,p+Vector2(s*0.05,-s*0.02),p+Vector2(s*0.07,s*0.01)]),dark)
# 35 bonus: a row of guard berth cradles, most of them empty.
static func _empty_berths(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var see:float=g.see
	var steel:Color=_steel(g.tone,1.1)
	for k in 5:
		var f:float=1.0-0.12*k
		var x:float=cx-w*0.4+w*0.2*k
		var bw:float=w*0.075*f;var bh:float=s*0.45*f
		var y:float=base-k*s*0.02
		ci.draw_line(Vector2(x-bw,y),Vector2(x-bw,y-bh),steel,maxf(2.0,s*0.025*f))
		ci.draw_line(Vector2(x+bw,y),Vector2(x+bw,y-bh),steel,maxf(2.0,s*0.025*f))
		ci.draw_line(Vector2(x-bw,y-bh*0.25),Vector2(x+bw,y-bh*0.25),steel,maxf(1.5,s*0.02*f))
		if k==1:
			var boat:=PackedVector2Array([Vector2(x-bw*1.1,y-bh*0.95),Vector2(x+bw*1.1,y-bh*0.95)])
			for i in 9:boat.append(Vector2(x+cos(PI*i/8.0)*bw*1.05,y-bh*0.95+sin(PI*i/8.0)*bh*0.65))
			ci.draw_colored_polygon(boat,_steel(g.tone,0.7))
			ci.draw_line(Vector2(x-bw*1.05,y-bh*0.8),Vector2(x+bw*1.05,y-bh*0.8),Color(0.85,0.6,0.3,al*0.6),maxf(1.5,s*0.015))
		elif see>0.3:
			var line:=PackedVector2Array()
			for i in 7:line.append(Vector2(x-bw+bw*2.0*i/6.0,y-bh+sin(PI*i/6.0)*bh*0.25))
			ci.draw_polyline(line,Color(0.5,0.45,0.35,al*see),1.0)
		if see>0.65 and float(g.detail)>0.5:
			_text(ci,Vector2(x-bw,y-bh-4),str(k+1),clampi(int(s*0.07),8,14),_c(AMBER,al*0.8))
# 36: the guard station window that looks onto the first strike.
static func _guard_window(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w*0.7;var cx:float=g.cx;var base:float=g.base
	var see:float=g.see
	var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-s*0.98;var b:float=base-s*0.32
	for x in [l+w*0.1,cx,r-w*0.1]:ci.draw_line(Vector2(x,b),Vector2(x,base),_steel(g.tone,0.6),maxf(2.0,s*0.03))
	_plated_wall(g,l,r,t,b)
	ci.draw_line(Vector2(r-w*0.15,t),Vector2(r-w*0.15,t-s*0.12),_steel(g.tone,0.9),1.5)
	var wr:=Rect2(l+w*0.12,t+(b-t)*0.2,w*0.76,(b-t)*0.52)
	ci.draw_rect(wr,Color(0.48,0.36,0.2,al).lerp(Color(0.7,0.55,0.3,al),0.4*float(g.lit)))
	if see>0.0:
		var gh:float=(b-wr.position.y-wr.size.y*0.25)/0.86
		var feet:=Vector2(wr.position.x+wr.size.x*0.45,b)
		person(ci,feet,gh,"guard",Color(0.015,0.025,0.03,al*lerpf(0.55,1.0,see)),Color(0.95,0.85,0.6,al),see,g.detail,1,rect)
		if see>0.5:
			# Field glasses raised toward the strike ground.
			var e:=Vector2(feet.x+gh*0.06,feet.y-gh*0.87)
			ci.draw_line(e,e+Vector2(gh*0.12,0),Color(0.015,0.025,0.03,al),maxf(2.0,gh*0.06))
			ci.draw_circle(e+Vector2(gh*0.13,0),maxf(1.5,gh*0.035),Color(0.6,0.75,0.8,al*0.7))
	else:
		_glow(ci,rect,wr.get_center(),wr.size.x*0.15,wr.size.y*0.4,Color(0.02,0.03,0.035,0.5*al),3)
	# The wall below the sill hides the rest of the guard.
	_plated_wall(g,l,r,wr.end.y,b)
	ci.draw_rect(wr,_steel(g.tone,0.7),false,maxf(2.0,s*0.02))
	# The strike site seen past the station: scarred seabed off to the left.
	if see>0.35:
		var sp:=Vector2(minf(rect.end.x-rect.size.x*0.12,r+w*0.5),base+s*0.05)
		_glow(ci,rect,sp,s*0.25,s*0.06,Color(1.0,0.5,0.2,0.25*al*see),4)
		for i in 5:ci.draw_line(sp+Vector2(-s*0.2+i*s*0.1,0),sp+Vector2(-s*0.15+i*s*0.1,-s*0.05),Color(1.0,0.55,0.25,al*0.5*see),1.2)
		if float(g.detail)>0.55:
			var a:=Vector2(wr.end.x,wr.get_center().y)
			for i in 8:
				var p:=a.lerp(sp,float(i)/8.0);var q:=a.lerp(sp,(float(i)+0.5)/8.0)
				ci.draw_line(p,q,_c(AMBER,al*0.35),1.0)
# 36 bonus: a drill permit plate bolted onto old Siren stone.
static func _permit_stone(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w*0.8;var cx:float=g.cx;var base:float=g.base
	var h:float=s*0.85;var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-h
	var block:=PackedVector2Array()
	for i in 17:
		var a:float=PI+PI*i/16.0
		block.append(Vector2(cx+cos(a)*w*0.5,base+sin(a)*h))
	_stone(ci,block,g.tone,1.0,int(g.seed)+36)
	_art(ci,Rect2(cx-w*0.08,t+h*0.12,w*0.16,h*0.8),SPINE,g.tone,0.85)
	for k in 3:ci.draw_arc(Vector2(cx,base),w*(0.22+0.1*k),PI+0.2,TAU-0.2,18,Color(0.9,0.22,0.16,al*0.25*(0.4+float(g.lit))),1.2)
	var pr:=Rect2(cx+w*0.1,t+h*0.38,w*0.28,h*0.3)
	ci.draw_rect(pr,_steel(g.tone,1.4))
	var see:float=g.see
	if see<=0.0:return
	for p in [pr.position,Vector2(pr.end.x,pr.position.y),pr.end,Vector2(pr.position.x,pr.end.y)]:
		ci.draw_circle(p+(pr.get_center()-p).normalized()*5.0,maxf(1.5,h*0.02),Color(0.0,0.02,0.03,al*0.85))
	for k in 4:
		var y:float=pr.position.y+pr.size.y*(0.35+0.15*k)
		ci.draw_line(Vector2(pr.position.x+pr.size.x*0.12,y),Vector2(pr.end.x-pr.size.x*(0.12+0.2*rnd(k)),y),Color(0.02,0.04,0.05,al*lerpf(0.3,0.9,see)),maxf(1.0,h*0.02))
	if see>0.7 and float(g.detail)>0.55:
		_text(ci,pr.position+Vector2(pr.size.x*0.1,pr.size.y*0.25),"PERMIT",clampi(int(h*0.08),8,14),Color(0.02,0.04,0.05,al))
# --- ops 0 to 31 ----------------------------------------------------------------
# 0: the Corran signal spire. A leaning steel derrick beside its plated housing;
# the battery beacon at the crown, the drill string snapped clean below it, and
# deep parallel scoring on the housing's sheltered side.
static func _signal_spire(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var b:float=_see(g,"beacon");var d:float=_see(g,"drill");var sc:float=_see(g,"scoring")
	var hl:float=cx-w*0.46;var hr:float=cx-w*0.02;var ht:float=base-s*0.34
	_plated_wall(g,hl,hr,ht,base)
	var steel:Color=_steel(g.tone,1.1)
	var lean:float=s*0.16
	var l0:=Vector2(cx,base);var r0:=Vector2(cx+w*0.22,base)
	var top:=Vector2(cx+w*0.11+lean,base-s*0.9)
	var lt:=top+Vector2(-w*0.025,0);var rt:=top+Vector2(w*0.025,0)
	var lw:float=maxf(2.0,s*0.022)
	ci.draw_line(l0,lt,steel,lw);ci.draw_line(r0,rt,steel,lw)
	var brace:=_c(steel,lerpf(0.4,1.0,float(g.detail)))
	for k in 6:
		var f0:float=float(k)/6.0;var f1:float=float(k+1)/6.0
		var a0:=l0.lerp(lt,f0);var b0:=r0.lerp(rt,f0);var a1:=l0.lerp(lt,f1);var b1:=r0.lerp(rt,f1)
		ci.draw_line(a1,b1,brace,maxf(1.0,lw*0.5))
		if float(g.detail)>0.35:
			ci.draw_line(a0,b1,brace,1.0);ci.draw_line(b0,a1,brace,1.0)
	ci.draw_rect(Rect2(top+Vector2(-w*0.04,-s*0.05),Vector2(w*0.08,s*0.05)),steel)
	# Scoring on the housing's sheltered side.
	if sc>0.0:
		for k in 4:
			var p0:=Vector2(hr-w*0.2+k*w*0.035,ht+s*0.05);var p1:=p0+Vector2(w*0.07,s*0.24)
			ci.draw_line(p0,p1,Color(0.0,0.01,0.015,al*lerpf(0.4,0.95,sc)),maxf(2.0,s*0.022))
			if sc>0.4:ci.draw_line(p0+Vector2(2,1),p1+Vector2(2,1),Color(0.8,0.92,0.88,al*0.45*float(g.lit)),1.0)
			if sc>0.7 and float(g.detail)>0.55:
				ci.draw_colored_polygon(PackedVector2Array([p1,p1+Vector2(s*0.025,-s*0.01),p1+Vector2(s*0.01,s*0.02)]),_steel(g.tone,1.4))
	# Drill string from the crown boom, snapped clean partway down.
	var hang:=top+Vector2(w*0.1,s*0.02)
	ci.draw_line(top+Vector2(0,-s*0.02),hang,steel,maxf(1.5,lw*0.7))
	var brk:=Vector2(hang.x,base-s*0.4)
	if d<=0.0:
		ci.draw_line(hang,brk,_c(steel,0.3),maxf(1.5,s*0.015))
	else:
		var pa:float=lerpf(0.5,1.0,d)
		ci.draw_line(hang,brk,_c(steel,pa),maxf(2.0,s*0.028))
		for k in 4:
			var p:=hang.lerp(brk,0.18+0.2*k)
			ci.draw_line(p+Vector2(-s*0.025,0),p+Vector2(s*0.025,0),_c(steel.lightened(0.2),pa),maxf(2.0,s*0.018))
		if d>0.35:
			ci.draw_polyline(PackedVector2Array([brk+Vector2(-s*0.016,0),brk+Vector2(-s*0.006,s*0.01),brk+Vector2(s*0.004,-s*0.004),brk+Vector2(s*0.016,s*0.006)]),Color(0.95,1.0,0.98,al*0.95),1.5)
			var g0:=Vector2(hang.x+w*0.04,base+s*0.03);var g1:=Vector2(hang.x+w*0.3,base+s*0.06)
			ci.draw_line(g0,g1,_c(steel,pa*0.9),maxf(2.0,s*0.026))
			ci.draw_circle(g0,maxf(1.5,s*0.014),Color(0.95,1.0,0.98,al*0.85))
		if d>0.7 and float(g.detail)>0.5:
			for k in 3:ci.draw_arc(brk,s*(0.04+0.03*k),0.3,PI-0.3,10,Color(0.75,0.9,0.86,al*0.3),1.0)
	# The beacon on battery at the crown.
	var lamp:=top+Vector2(0,-s*0.08)
	if b<=0.0:
		ci.draw_circle(lamp,maxf(2.0,s*0.03),_steel(g.tone,0.6))
		_glow(ci,rect,lamp,s*0.08,s*0.08,Color(1.0,0.8,0.5,0.12*al),3)
	else:
		var pulse:float=0.65+0.35*sin(float(g.time)*3.0)
		_glow(ci,rect,lamp,s*0.2*b,s*0.2*b,Color(1.0,0.82,0.5,0.4*al*pulse),5)
		ci.draw_circle(lamp,maxf(2.0,s*0.032),Color(1.0,0.95,0.8,al))
		if b>0.6 and float(g.detail)>0.5:
			var box:=Rect2(l0+Vector2(-w*0.07,-s*0.1),Vector2(w*0.06,s*0.1))
			ci.draw_rect(box,_steel(g.tone,0.9))
			ci.draw_circle(box.position+Vector2(box.size.x*0.5,s*0.025),maxf(1.0,s*0.012),_c(AMBER,al))
			ci.draw_line(box.position+Vector2(box.size.x,s*0.02),l0.lerp(lt,0.95),_c(steel,0.7),1.0)
# 1: a seabed transponder relay, its riser parted and its clock stopped. The
# west relay stands under the basalt spine; the east one beside the long wall.
static func _relay(g:Dictionary,west:bool)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var h:float=_see(g,"housing");var c:float=_see(g,"clock")
	if west:
		var ridge:=PackedVector2Array([Vector2(cx-w*0.62,base),Vector2(cx-w*0.5,base-s*0.7),Vector2(cx-w*0.32,base-s*1.08),Vector2(cx-w*0.18,base-s*0.9),Vector2(cx-w*0.06,base-s*0.5),Vector2(cx+w*0.02,base)])
		_stone(ci,ridge,g.tone,0.8,int(g.seed)+101)
		ci.draw_polyline(PackedVector2Array([ridge[1],ridge[2],ridge[3]]),Color(0.75,0.9,0.86,al*0.3*float(g.lit)),1.2)
	else:
		var wl:float=cx-w*0.62;var wr:float=minf(rect.end.x,cx+w*0.2)
		_stone(ci,PackedVector2Array([Vector2(wl,base-s*0.42),Vector2(wr,base-s*0.38),Vector2(wr,base-s*0.06),Vector2(wl,base-s*0.06)]),g.tone,0.75,int(g.seed)+102)
		ci.draw_line(Vector2(wl,base-s*0.42),Vector2(wr,base-s*0.38),Color(0.75,0.9,0.86,al*0.3*float(g.lit)),1.2)
	var bx:float=cx+w*0.12;var bw:float=w*0.12;var bt:float=base-s*0.62;var bb:float=base-s*0.3
	var steel:Color=_steel(g.tone,1.0)
	for x in [bx-bw*0.8,bx,bx+bw*0.8]:
		ci.draw_line(Vector2(lerpf(bx,x,0.6),bb),Vector2(x,base),_steel(g.tone,0.7),maxf(1.5,s*0.018))
	ci.draw_polygon(PackedVector2Array([Vector2(bx-bw,bt),Vector2(bx+bw,bt),Vector2(bx+bw,bb),Vector2(bx-bw,bb)]),PackedColorArray([steel,_steel(g.tone,0.6),_steel(g.tone,0.4),_steel(g.tone,0.7)]))
	ci.draw_colored_polygon(_ellipse(Vector2(bx,bt),bw,s*0.035),_steel(g.tone,1.3))
	ci.draw_line(Vector2(bx-bw,bt+(bb-bt)*0.2),Vector2(bx+bw,bt+(bb-bt)*0.2),Color(0.85,0.6,0.3,al*0.5),maxf(1.5,s*0.015))
	if h>0.3:
		# The riser parted: frayed ends above the housing, the upper run adrift.
		var r0:=Vector2(bx,bt);var r1:=Vector2(bx+w*0.02,bt-s*0.22)
		ci.draw_line(r0,r1,_c(steel,lerpf(0.5,1.0,h)),maxf(1.5,s*0.02))
		for k in 3:ci.draw_line(r1,r1+Vector2((k-1)*s*0.02,-s*0.035),Color(0.85,0.95,0.92,al*0.8*h),1.0)
		var drift:=PackedVector2Array()
		for i in 7:drift.append(Vector2(bx+w*0.08+i*w*0.03,bt-s*0.42-sin(i*0.9)*s*0.04))
		ci.draw_polyline(drift,_c(steel,0.5*h),maxf(1.0,s*0.014))
	if h>0.6 and float(g.detail)>0.5:
		ci.draw_circle(Vector2(bx+bw*0.7,bt+s*0.03),maxf(1.0,s*0.012),Color(0.9,0.25,0.18,al*0.9))
	var dc:=Vector2(bx,bt+(bb-bt)*0.6);var dr:float=maxf(4.0,minf(bw*0.55,(bb-bt)*0.3))
	if c<=0.0:
		ci.draw_circle(dc,dr,_steel(g.tone,0.35))
		return
	ci.draw_circle(dc,dr,_c(Color(0.82,0.86,0.78),al*lerpf(0.5,1.0,c)))
	ci.draw_arc(dc,dr,0,TAU,24,_steel(g.tone,1.3),maxf(1.0,dr*0.15))
	var hand:=Color(0.02,0.03,0.035,al)
	ci.draw_line(dc,dc+Vector2(cos(-0.6),sin(-0.6))*dr*0.55,hand,maxf(1.5,dr*0.14))
	ci.draw_line(dc,dc+Vector2(cos(2.1),sin(2.1))*dr*0.85,hand,maxf(1.0,dr*0.09))
	if c>0.6 and float(g.detail)>0.5:
		for i in 12:
			var a:float=TAU*i/12.0
			ci.draw_line(dc+Vector2(cos(a),sin(a))*dr*0.8,dc+Vector2(cos(a),sin(a))*dr*0.95,hand,1.0)
		ci.draw_line(dc+Vector2(-dr*0.7,-dr*0.5),dc+Vector2(dr*0.4,dr*0.75),Color(1,1,1,al*0.55),1.0)
# 3: the Siren furnace vent. A basalt mound with foundry flanks, heat at the
# mouth, a feed line leaving it; the lining inside is grown, not cast.
static func _vent_mouth(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var m:float=_see(g,"mouth");var ln:float=_see(g,"lining")
	var mound:=PackedVector2Array()
	for i in 17:
		var a:float=PI+PI*i/16.0
		mound.append(Vector2(cx+cos(a)*w*0.4,base+sin(a)*s*0.78*(0.92+0.08*rnd(i+int(g.seed)))))
	_stone(ci,mound,g.tone,0.9,int(g.seed)+3)
	_art(ci,Rect2(cx-w*0.34,base-s*0.42,w*0.12,s*0.38),CYLINDERS,g.tone,0.8)
	_art(ci,Rect2(cx+w*0.2,base-s*0.38,w*0.13,s*0.3),FINS,g.tone,0.8)
	# Feed line south toward the frames.
	var f0:=Vector2(cx+w*0.3,base-s*0.12);var f1:=Vector2(minf(rect.end.x-4.0,cx+w*0.62),base+s*0.05)
	ci.draw_line(f0,f1,_steel(g.tone,0.8),maxf(3.0,s*0.05))
	ci.draw_line(f0,f1,Color(0.9,0.22,0.16,al*0.35*(0.4+float(g.lit))),1.5)
	var mc:=Vector2(cx-w*0.02,base-s*0.5);var rx:float=w*0.1*float(g.fx);var ry:float=s*0.13
	_glow(ci,rect,mc,rx*2.6,ry*2.4,Color(1.0,0.5,0.22,(0.18+0.3*m)*al),5)
	ci.draw_colored_polygon(_ellipse(mc,rx,ry),Color(0.02,0.01,0.008,al))
	if m>0.0:
		ci.draw_colored_polygon(_ellipse(mc+Vector2(0,ry*0.15),rx*0.45,ry*0.4),Color(1.0,0.58,0.26,al*m))
		ci.draw_colored_polygon(_ellipse(mc+Vector2(0,ry*0.15),rx*0.2,ry*0.18),Color(1.0,0.9,0.6,al*m))
		for k in 3:
			var pts:=PackedVector2Array()
			for i in 8:pts.append(mc+Vector2((k-1)*rx*0.5+sin(i*1.2+float(g.time)*2.0+k)*rx*0.12,-ry-i*s*0.035))
			ci.draw_polyline(pts,Color(1.0,0.7,0.4,al*0.3*m),1.0)
	if ln>0.0:
		# Grown lamellae reaching in from the rim, thinnest at the mouth.
		for i in 18:
			var a:float=TAU*i/18.0+rnd(i*7)*0.15
			var k:float=0.5+0.22*rnd(i*13+int(g.seed))
			var p0:=mc+Vector2(cos(a)*rx,sin(a)*ry);var p1:=mc+Vector2(cos(a)*rx*k,sin(a)*ry*k)
			var n:=Vector2(-sin(a),cos(a))*maxf(1.0,rx*0.08)
			ci.draw_colored_polygon(PackedVector2Array([p0-n,p0+n,p1]),Color(0.78,0.72,0.6,al*0.8*ln))
		if ln>0.5:_ring(ci,mc,rx,ry,Color(0.95,0.92,0.82,al*0.7*ln),1.0)
		if ln>0.7 and float(g.detail)>0.55:
			for i in 10:
				var a:float=TAU*rnd(i*5+3)
				var p:=mc+Vector2(cos(a)*rx*0.7,sin(a)*ry*0.7)
				ci.draw_line(p,p+Vector2(cos(a+0.8),sin(a+0.8))*rx*0.12,Color(0.9,0.85,0.72,al*0.7),1.0)
	else:
		_ring(ci,mc,rx,ry,_steel(g.tone,0.5),maxf(1.0,ry*0.08))
# 3: the launch cradle. Siren frames standing open on rails that run to the
# trench edge, still warm.
static func _launch_cradle(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var rl:float=_see(g,"rails");var fr:float=_see(g,"frames")
	var edge:float=cx+w*0.44
	_trench(g,edge)
	var steel:Color=_steel(g.tone,1.2)
	var rails:=[[Vector2(cx-w*0.6,base-s*0.04),Vector2(edge,base-s*0.06)],[Vector2(cx-w*0.6,base+s*0.05),Vector2(edge+s*0.03,base+s*0.02)]]
	if rl>0.3:
		for k in 14:
			var f:float=float(k)/13.0
			var ra:Vector2=rails[0][0].lerp(rails[0][1],f);var rb:Vector2=rails[1][0].lerp(rails[1][1],f)
			ci.draw_line(ra,rb,_steel(g.tone,0.6),maxf(1.0,s*0.012))
	for r in rails:
		ci.draw_line(r[0],r[1],_c(steel,lerpf(0.4,1.0,rl)),maxf(1.5,s*0.018))
		if rl>0.6:ci.draw_circle(r[1],maxf(1.5,s*0.014),Color(0.9,1.0,0.96,al*0.8))
	for k in 3:
		var x:float=cx-w*0.34+w*0.24*k
		var fw:float=w*0.15;var fh:float=s*(0.72-0.04*k)
		var t:float=base-s*0.02-fh
		var post:float=maxf(3.0,w*0.022)
		if fr<=0.0:
			ci.draw_rect(Rect2(x-fw*0.5,t,fw,fh),Color(0.02,0.03,0.035,al*0.75),false,post)
			continue
		var fa:float=lerpf(0.5,1.0,fr)
		var c:={"light":g.light,"alpha":al*fa}
		_art(ci,Rect2(x-fw*0.5,t,post,fh),SPINE,c,0.9)
		_art(ci,Rect2(x+fw*0.5-post,t,post,fh),SPINE,c,0.9)
		_art(ci,Rect2(x-fw*0.5,t,fw,post),Rect2(330,620,800,60),c,0.9)
		_art(ci,Rect2(x-fw*0.5,t+fh*0.55,fw,post*0.8),Rect2(330,660,800,60),c,0.9)
		ci.draw_line(Vector2(x-fw*0.5+post*0.5,t),Vector2(x-fw*0.5+post*0.5,t+fh),Color(0.9,0.22,0.16,al*0.35*fr),1.0)
		for j in [Vector2(x-fw*0.5,t),Vector2(x+fw*0.5,t),Vector2(x-fw*0.5,t+fh*0.55),Vector2(x+fw*0.5,t+fh*0.55)]:
			_glow(ci,rect,j,s*0.05,s*0.05,Color(1.0,0.55,0.25,0.35*al*fr),3)
		if fr>0.5:
			for i in 2:
				var pts:=PackedVector2Array()
				for n in 6:pts.append(Vector2(x+(i-0.5)*fw*0.4+sin(n*1.3+float(g.time)*2.0+k)*fw*0.05,t-n*s*0.03))
				ci.draw_polyline(pts,Color(1.0,0.7,0.4,al*0.25*fr),1.0)
		if fr>0.7 and float(g.detail)>0.55:
			for side in [-1.0,1.0]:
				ci.draw_line(Vector2(x+side*fw*0.5,t+fh*0.3),Vector2(x+side*fw*0.22,t+fh*0.38),_steel(g.tone,1.2),maxf(1.5,post*0.5))
# 4: the listening well's array ribs along the rim; resolved, each rib carries
# notches in a repeating count of one, two, three.
static func _array_ribs(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var ri:float=_see(g,"ribs");var co:float=_see(g,"count")
	var rim:=PackedVector2Array()
	for i in 13:
		var f:float=float(i)/12.0
		rim.append(Vector2(cx-w*0.5+w*f,base-s*0.12-s*0.1*sin(PI*f)))
	rim.append(Vector2(cx+w*0.5,base));rim.append(Vector2(cx-w*0.5,base))
	_stone(ci,rim,g.tone,0.85,int(g.seed)+4)
	var heights:=[0.85,0.65,0.45]
	for k in 9:
		var f:float=(float(k)+0.5)/9.0
		var x:float=cx-w*0.46+w*0.92*f
		var y0:float=base-s*0.12-s*0.1*sin(PI*f)
		var rh:float=s*float(heights[k%3]);var rw:float=w*0.026
		var lean:float=(cx-x)*0.06
		var rib:=PackedVector2Array([Vector2(x-rw,y0+2),Vector2(x+rw,y0+2),Vector2(x+rw*0.45+lean,y0-rh),Vector2(x-rw*0.45+lean,y0-rh)])
		_stone(ci,rib,g.tone,0.95,k*11+int(g.seed))
		if ri>0.3:ci.draw_line(Vector2(x+rw,y0),Vector2(x+rw*0.45+lean,y0-rh),Color(0.75,0.9,0.86,al*0.4*ri*float(g.lit)),1.0)
		if co>0.0:
			for n in (k%3)+1:
				var ny:float=y0-rh*(0.55+0.12*n)
				var nx:float=x+lean*(0.55+0.12*n)
				ci.draw_line(Vector2(nx-rw*0.7,ny),Vector2(nx+rw*0.7,ny),Color(PHOSPHOR.r,PHOSPHOR.g,PHOSPHOR.b,al*co),maxf(1.5,s*0.016))
				if co>0.6 and float(g.detail)>0.5:ci.draw_line(Vector2(nx-rw*0.7,ny+2),Vector2(nx+rw*0.7,ny+2),Color(0,0.01,0.015,al*0.7),1.0)
# 4: the profile aperture: a stepped opening cut into the well rim.
static func _rim_aperture(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w*0.85;var cx:float=g.cx;var base:float=g.base
	var f:float=_see(g,"face")
	var h:float=s*0.8;var t:float=base-h
	_stone_face(g,cx-w*0.5,cx+w*0.5,t,base,int(g.seed)+40)
	_art(ci,Rect2(cx-w*0.32,t+h*0.15,w*0.08,h*0.75),PANEL,g.tone,0.8)
	_art(ci,Rect2(cx+w*0.24,t+h*0.15,w*0.08,h*0.75),PANEL,g.tone,0.8)
	var steps:=4
	for k in steps:
		var sw:float=w*(0.16-0.03*k)*float(g.fx);var top:float=t+h*(0.12+0.06*k)
		var bot:float=base-h*(0.04+0.03*k)
		var col:Color=Color(0.0,0.008,0.012,al*(0.55+0.15*k))
		if f<=0.0:col=Color(0.0,0.008,0.012,al*0.7)
		var arch:=PackedVector2Array([Vector2(cx-sw,bot),Vector2(cx-sw,top+sw),Vector2(cx,top),Vector2(cx+sw,top+sw),Vector2(cx+sw,bot)])
		ci.draw_colored_polygon(arch,col)
		if f>0.0 and k<steps-1:
			ci.draw_polyline(PackedVector2Array([Vector2(cx-sw,bot),Vector2(cx-sw,top+sw),Vector2(cx,top)]),Color(0.8,0.94,0.9,al*0.5*f*(0.4+float(g.lit))),1.2)
		if f<=0.0:break
	if f>0.6:
		_glow(ci,rect,Vector2(cx,base-h*0.4),w*0.04,h*0.15,Color(PHOSPHOR.r,PHOSPHOR.g,PHOSPHOR.b,0.25*al*f),3)
	if f>0.7 and float(g.detail)>0.55:
		for k in 6:ci.draw_line(Vector2(cx-w*0.16*float(g.fx),t+h*(0.3+0.08*k)),Vector2(cx-w*0.13*float(g.fx),t+h*(0.3+0.08*k)),Color(0.8,0.94,0.9,al*0.4),1.0)
# 4: the return archive: rows of fine grooves laid into a panel in the rim face.
static func _archive_face(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w*0.9;var cx:float=g.cx;var base:float=g.base
	var f:float=_see(g,"face")
	var h:float=s*0.85;var t:float=base-h
	_stone_face(g,cx-w*0.5,cx+w*0.5,t,base,int(g.seed)+41)
	var pr:=Rect2(cx-w*0.32,t+h*0.2,w*0.64,h*0.62)
	ci.draw_rect(pr,_steel(g.tone,0.45))
	_art(ci,Rect2(pr.position.x-w*0.05,pr.position.y,w*0.05,pr.size.y),PANEL,g.tone,0.8)
	_art(ci,Rect2(pr.end.x,pr.position.y,w*0.05,pr.size.y),PANEL,g.tone,0.8)
	if f<=0.0:return
	var rows:=6;var lines:int=int(lerpf(5.0,20.0,float(g.detail)*f))
	for r in rows:
		var y0:float=pr.position.y+pr.size.y*(float(r)+0.15)/rows;var y1:float=y0+pr.size.y*0.7/rows
		ci.draw_line(Vector2(pr.position.x,y1+2),Vector2(pr.end.x,y1+2),Color(0,0.01,0.015,al*0.7),1.5)
		var x:float=pr.position.x+3.0
		for n in lines:
			x+=pr.size.x/float(lines+2)*(0.5+rnd(r*31+n*7+int(g.seed)))
			if x>pr.end.x-3.0:break
			ci.draw_line(Vector2(x,y0),Vector2(x,y1),Color(0.78,0.9,0.86,al*0.55*f*(0.35+float(g.lit))),1.0)
	ci.draw_colored_polygon(PackedVector2Array([pr.position+Vector2(pr.size.x*0.2,0),pr.position+Vector2(pr.size.x*0.32,0),pr.position+Vector2(pr.size.x*0.12,pr.size.y),pr.position+Vector2(0,pr.size.y)]),Color(0.85,0.97,0.95,al*0.08*f*float(g.lit)))
# 5: the transmitter crown. Nested resonator vanes on a basalt plinth all open
# toward the trench; resolved, the throat at their focus pulses into it.
static func _vane_crown(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var v:float=_see(g,"vanes");var th:float=_see(g,"throat")
	_trench(g,cx+w*0.36)
	_stone(ci,PackedVector2Array([Vector2(cx-w*0.32,base),Vector2(cx-w*0.24,base-s*0.22),Vector2(cx+w*0.14,base-s*0.22),Vector2(cx+w*0.22,base)]),g.tone,0.85,int(g.seed)+5)
	var fc:=Vector2(cx+w*0.08,base-s*0.55)
	for k in 5:
		var r0:float=s*(0.12+0.09*k);var r1:float=r0+s*0.045
		var band:=PackedVector2Array();var inner:=PackedVector2Array()
		for i in 13:
			var a:float=PI*0.55+PI*0.9*i/12.0
			band.append(fc+Vector2(cos(a)*r1*float(g.fx),sin(a)*r1))
			inner.append(fc+Vector2(cos(a)*r0*float(g.fx),sin(a)*r0))
		var seam:=inner.slice(2,11)
		inner.reverse()
		_stone(ci,band+inner,g.tone,lerpf(0.6,1.05,v),k*19+int(g.seed))
		if v>0.3:ci.draw_polyline(band,Color(0.75,0.9,0.86,al*0.4*v*float(g.lit)),1.2)
		if v>0.5:ci.draw_polyline(seam,Color(0.9,0.22,0.16,al*0.35*v),1.0)
	ci.draw_colored_polygon(_ellipse(fc,s*0.06*float(g.fx),s*0.08),Color(0.0,0.008,0.012,al))
	if th<=0.0:return
	_glow(ci,rect,fc,s*0.1,s*0.1,Color(PHOSPHOR.r,PHOSPHOR.g,PHOSPHOR.b,0.3*al*th),4)
	var ph:float=fposmod(float(g.time)*0.5,1.0)
	for k in 3:
		var f:float=fposmod(ph+k/3.0,1.0)
		ci.draw_arc(fc,s*(0.12+0.18*f),-0.55,0.75,12,Color(PHOSPHOR.r,PHOSPHOR.g,PHOSPHOR.b,al*0.55*th*(1.0-f)),1.5)
	if th>0.6 and float(g.detail)>0.5:
		var a:=fc+Vector2(s*0.1,s*0.06);var b:=Vector2(minf(rect.end.x-6.0,cx+w*0.5),base+s*0.06)
		for i in 7:ci.draw_line(a.lerp(b,i/7.0),a.lerp(b,(i+0.5)/7.0),_c(AMBER,al*0.45),1.0)
# 5: the outbound wakes. Disturbed silt lines run out from the shelf; resolved
# with a thermal frame, they split at a warm fracture, one south and one west.
static func _wake_split(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var rect:Rect2=g.rect;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var ln:float=_see(g,"lines");var fr:float=_see(g,"fracture")
	var shelf:=PackedVector2Array()
	for i in 11:shelf.append(Vector2(cx-w*0.6+w*1.2*i/10.0,base-s*0.75+(rnd(i*7+int(g.seed))-0.5)*s*0.1))
	shelf.append(Vector2(cx+w*0.6,base-s*0.04));shelf.append(Vector2(cx-w*0.6,base-s*0.04))
	_stone(ci,shelf,g.tone,0.8,int(g.seed)+50)
	var src:=Vector2(cx,base-s*0.04);var split:=Vector2(cx,base+s*0.1)
	var bottom:float=minf(rect.end.y-4.0,base+s*0.4)
	var la:float=al*lerpf(0.25,0.85,ln)
	var west:=Vector2(maxf(rect.position.x+6.0,cx-w*0.5),split.y+(bottom-split.y)*0.55)
	var south:=Vector2(cx+w*0.22,bottom)
	for k in 5:
		var off:float=(k-2)*w*0.025
		var col:=Color(0.72,0.84,0.8,la*(0.7+0.3*rnd(k)))
		ci.draw_line(src+Vector2(off*0.6,0),split+Vector2(off,0),col,maxf(1.0,s*0.012))
		if fr<=0.0:
			ci.draw_line(split+Vector2(off,0),Vector2(cx+off*1.6,bottom),Color(col.r,col.g,col.b,col.a*0.5),maxf(1.0,s*0.012))
		else:
			var dst:Vector2=west if k<2 else south
			ci.draw_polyline(PackedVector2Array([split+Vector2(off,0),split.lerp(dst,0.5)+Vector2(off,(dst.y-split.y)*-0.1),dst+Vector2(off,0)]),col,maxf(1.0,s*0.012))
	if fr<=0.0:return
	var crack:=PackedVector2Array()
	for i in 9:crack.append(split+Vector2((i-4)*w*0.03,(rnd(i*5+int(g.seed))-0.5)*s*0.03))
	_glow(ci,rect,split,w*0.16,s*0.05,Color(1.0,0.5,0.2,0.35*al*fr),4)
	ci.draw_polyline(crack,Color(1.0,0.62,0.3,al*fr),maxf(1.5,s*0.016))
	if fr>0.6 and float(g.detail)>0.5:
		for k in 3:
			var pts:=PackedVector2Array()
			for i in 6:pts.append(split+Vector2((k-1)*w*0.06+sin(i*1.4+float(g.time)*2.0)*s*0.01,-i*s*0.03))
			ci.draw_polyline(pts,Color(1.0,0.7,0.4,al*0.3*fr),1.0)
# 30: the scour edge. A Siren-coursed structure whose corner the current has
# worn round and grooved, a silt fan at its foot.
static func _scour_edge(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var e:float=_see(g,"mark")
	var l:float=cx-w*0.5;var c:float=cx+w*0.14;var t:float=base-s*0.82;var rr:float=s*0.12
	var block:=PackedVector2Array([Vector2(l,base),Vector2(l,t)])
	for i in 7:
		var a:float=-PI*0.5+PI*0.5*i/6.0
		block.append(Vector2(c-rr+cos(a)*rr,t+rr+sin(a)*rr))
	block.append(Vector2(c+s*0.04,base))
	_stone(ci,block,g.tone,0.9,int(g.seed)+30)
	for k in 3:
		var y:float=t+s*(0.18+0.22*k)
		_art(ci,Rect2(l+w*0.02,y,(c-l)-w*0.04,s*0.07),Rect2(330,620+k*40,800,60),g.tone,0.85)
	if e<=0.0:return
	for k in 6:
		var y:float=t+s*(0.12+0.12*k)
		var pts:=PackedVector2Array([Vector2(c-w*0.16,y),Vector2(c-w*0.04,y+s*0.01),Vector2(c+s*0.01,y+s*0.03)])
		ci.draw_polyline(pts,Color(0.0,0.01,0.015,al*lerpf(0.4,0.9,e)),maxf(1.5,s*0.014))
		if e>0.4:ci.draw_polyline(PackedVector2Array([pts[0]+Vector2(0,2),pts[1]+Vector2(0,2),pts[2]+Vector2(0,2)]),Color(0.8,0.92,0.88,al*0.35*float(g.lit)),1.0)
	ci.draw_line(Vector2(c-s*0.01,t+rr),Vector2(c+s*0.02,base-s*0.05),Color(0.85,0.95,0.92,al*0.4*e*(0.4+float(g.lit))),maxf(2.0,s*0.02))
	if e>0.6 and float(g.detail)>0.5:
		for i in 7:
			var p:=Vector2(c+s*0.04,base-s*0.01)
			ci.draw_line(p,p+Vector2(s*(0.12+0.04*i),s*(0.01+0.012*i)),Color(0.72,0.82,0.78,al*0.35),1.0)
# 30 bonus: a spindle whose collar is scored with fine turning rings.
static func _spindle_collar(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var e:float=_see(g,"mark")
	for x in [cx-w*0.3,cx+w*0.3]:
		ci.draw_line(Vector2(x,base),Vector2(x,base-s*0.95),_steel(g.tone,0.8),maxf(3.0,s*0.04))
	ci.draw_line(Vector2(cx-w*0.34,base-s*0.95),Vector2(cx+w*0.34,base-s*0.95),_steel(g.tone,0.9),maxf(3.0,s*0.05))
	var sw:float=w*0.07
	ci.draw_polygon(PackedVector2Array([Vector2(cx-sw,base-s*0.92),Vector2(cx+sw,base-s*0.92),Vector2(cx+sw,base),Vector2(cx-sw,base)]),PackedColorArray([_steel(g.tone,1.2),_steel(g.tone,0.6),_steel(g.tone,0.5),_steel(g.tone,1.0)]))
	var cr:=Rect2(cx-sw*1.7,base-s*0.58,sw*3.4,s*0.2)
	ci.draw_polygon(PackedVector2Array([cr.position,Vector2(cr.end.x,cr.position.y),cr.end,Vector2(cr.position.x,cr.end.y)]),PackedColorArray([_steel(g.tone,1.3),_steel(g.tone,0.6),_steel(g.tone,0.5),_steel(g.tone,1.1)]))
	if e<=0.0:return
	var n:int=int(lerpf(4.0,14.0,float(g.detail)*e))
	for k in n:
		var y:float=cr.position.y+cr.size.y*(float(k)+0.5)/n
		ci.draw_line(Vector2(cr.position.x+2,y),Vector2(cr.end.x-2,y),Color(0.0,0.01,0.015,al*0.6*e),1.0)
	ci.draw_line(Vector2(cr.position.x+cr.size.x*0.3,cr.position.y),Vector2(cr.position.x+cr.size.x*0.3,cr.end.y),Color(0.95,1.0,0.98,al*0.5*e*(0.4+float(g.lit))),maxf(2.0,sw*0.3))
	if e>0.65 and float(g.detail)>0.5:
		for i in 8:ci.draw_circle(Vector2(cx+(rnd(i*3)-0.5)*w*0.3,base+s*0.02+rnd(i*7)*s*0.04),1.0+rnd(i),Color(0.8,0.9,0.88,al*0.6))
# 31: the bell berth. A diving bell's nameplate, scratched by hand with tally
# marks and an arrow once the frame resolves it.
static func _survivor_marks(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var e:float=_see(g,"mark")
	var bw:float=w*0.3;var bt:float=base-s*0.95;var skirt:float=base-s*0.38
	var bell:=PackedVector2Array()
	for i in 17:
		var a:float=PI+PI*i/16.0
		bell.append(Vector2(cx+cos(a)*bw,skirt+sin(a)*(skirt-bt)))
	var dome:=bell.duplicate()
	bell.append(Vector2(cx+bw*1.05,base-s*0.02));bell.append(Vector2(cx-bw*1.05,base-s*0.02))
	ci.draw_colored_polygon(bell,_steel(g.tone,0.8))
	ci.draw_polyline(dome,Color(0.75,0.92,0.88,al*0.35*float(g.lit)),1.5)
	ci.draw_line(Vector2(cx-bw,skirt),Vector2(cx+bw,skirt),_steel(g.tone,0.45),maxf(2.0,s*0.025))
	if float(g.detail)>0.5:
		for k in 14:ci.draw_circle(Vector2(cx-bw+bw*2.0*(k+0.5)/14.0,skirt+s*0.025),1.0,Color(0.75,0.9,0.86,al*0.35*float(g.lit)))
	var port:=Vector2(cx-bw*0.45,skirt-(skirt-bt)*0.5)
	ci.draw_circle(port,s*0.07,_steel(g.tone,1.2));ci.draw_circle(port,s*0.05,Color(0.08,0.12,0.12,al))
	var pr:=Rect2(cx-bw*0.05,skirt+s*0.06,bw*0.85,s*0.18)
	ci.draw_rect(pr,_steel(g.tone,1.4))
	ci.draw_rect(pr,Color(0.0,0.02,0.03,al*0.6),false,1.5)
	if e<=0.0:return
	var stamp:=Color(0.02,0.04,0.05,al*0.7)
	ci.draw_line(pr.position+Vector2(pr.size.x*0.1,pr.size.y*0.25),pr.position+Vector2(pr.size.x*0.7,pr.size.y*0.25),stamp,maxf(1.0,s*0.016))
	var scr:=Color(0.95,0.97,0.92,al*lerpf(0.4,0.95,e))
	for grp in 3:
		var gx:float=pr.position.x+pr.size.x*(0.1+0.28*grp);var gy0:float=pr.position.y+pr.size.y*0.45;var gy1:float=pr.end.y-pr.size.y*0.12
		for n in 4:ci.draw_line(Vector2(gx+n*pr.size.x*0.045,gy0),Vector2(gx+n*pr.size.x*0.045+1,gy1),scr,1.2)
		ci.draw_line(Vector2(gx-pr.size.x*0.02,gy1),Vector2(gx+pr.size.x*0.17,gy0),scr,1.2)
	if e>0.6 and float(g.detail)>0.5:
		var a0:=Vector2(pr.end.x+s*0.05,pr.position.y);var a1:=Vector2(pr.end.x+s*0.05,pr.end.y+s*0.1)
		ci.draw_line(a0,a1,scr,1.4);ci.draw_line(a1,a1+Vector2(-s*0.03,-s*0.03),scr,1.4);ci.draw_line(a1,a1+Vector2(s*0.03,-s*0.03),scr,1.4)
		var palm:=Vector2(pr.position.x-s*0.08,pr.position.y+pr.size.y*0.4)
		ci.draw_circle(palm,s*0.03,Color(0.85,0.9,0.86,al*0.3))
		for n in 4:ci.draw_line(palm+Vector2((n-1.5)*s*0.016,-s*0.025),palm+Vector2((n-1.5)*s*0.02,-s*0.06),Color(0.85,0.9,0.86,al*0.3),maxf(1.0,s*0.01))
# 31 bonus: the security feed room seen through its window, a bank of terminals.
static func _feed_terminals(g:Dictionary)->void:
	var ci:CanvasItem=g.ci;var al:float=g.al
	var s:float=g.s;var w:float=g.w;var cx:float=g.cx;var base:float=g.base
	var e:float=_see(g,"mark")
	var h:float=s*0.85;var l:float=cx-w*0.5;var r:float=cx+w*0.5;var t:float=base-h
	_plated_wall(g,l,r,t,base)
	var wr:=Rect2(l+w*0.1,t+h*0.18,w*0.8,h*0.5)
	ci.draw_rect(wr,Color(0.03,0.06,0.07,al))
	for k in 5:
		var sr:=Rect2(wr.position.x+wr.size.x*(0.05+0.19*k),wr.position.y+wr.size.y*0.25,wr.size.x*0.15,wr.size.y*0.38)
		ci.draw_rect(sr,Color(PHOSPHOR.r*0.4,PHOSPHOR.g*0.4,PHOSPHOR.b*0.4,al*(0.25+0.5*e)))
		ci.draw_rect(Rect2(sr.position.x,sr.end.y,sr.size.x,wr.size.y*0.2),Color(0.02,0.03,0.035,al))
		if e>0.3:
			for n in 3:ci.draw_line(sr.position+Vector2(sr.size.x*0.12,sr.size.y*(0.3+0.22*n)),sr.position+Vector2(sr.size.x*(0.3+0.5*rnd(k*7+n)),sr.size.y*(0.3+0.22*n)),Color(PHOSPHOR.r,PHOSPHOR.g,PHOSPHOR.b,al*e),1.0)
		if e>0.65 and float(g.detail)>0.5:
			for n in int(sr.size.y/3.0):ci.draw_line(Vector2(sr.position.x,sr.position.y+n*3.0),Vector2(sr.end.x,sr.position.y+n*3.0),Color(0,0,0,al*0.25),1.0)
	ci.draw_rect(wr,_steel(g.tone,0.7),false,maxf(2.0,h*0.03))
	ci.draw_colored_polygon(PackedVector2Array([wr.position+Vector2(wr.size.x*0.3,0),wr.position+Vector2(wr.size.x*0.38,0),wr.position+Vector2(wr.size.x*0.24,wr.size.y),wr.position+Vector2(wr.size.x*0.16,wr.size.y)]),Color(0.85,0.97,0.95,al*0.08*(0.4+float(g.lit))))
