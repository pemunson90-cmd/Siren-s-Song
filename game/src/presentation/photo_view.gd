extends RefCounted
# Draws a photograph from frame data: the real terrain depth profile across the
# field of view, the subject at its true bearing, size, aspect and sharpness,
# and only the features this exposure actually resolved. The same function
# draws the live viewfinder and every stored archive shot.
const PHOSPHOR=Color("8cdcd3")
const AMBER=Color("e0bf83")
const COLS=36
static func valid_shots(shots)->bool:
	if not shots is Array or shots.size()>8:return false
	for shot in shots:
		if not shot is Dictionary or not shot.has_all(["q","features","key","frame"]) or not shot.frame is Dictionary:return false
		if not shot.frame.get("cols") is Array or shot.frame.cols.size()!=COLS or not (shot.q is float or shot.q is int):return false
	return true
# View model from a live Photo.frame() result.
static func from_frame(f:Dictionary,kind:String="site")->Dictionary:
	var marks=[]
	for r in f.rows:
		if r.apparent:marks.append({"id":r.id,"x":r.x,"q":r.q if r.ready else 0.0,"label":r.label if r.ready else "","why":r.why})
	return {"cols":f.get("cols",[]),"fov":f.fov,"u":clampf(angle_difference(f.aim,f.bearing)/maxf(f.fov*0.5,0.01),-1.6,1.6),"dist":f.dist,"size":f.size,"aspect":f.aspect,"light":f.light,"clarity":f.clarity,"sharp":f.sharp,"marks":marks,"kind":kind,"seed":int(f.dist)%97,"mode":f.mode,"flash":f.flash,"craft":f.craft,"live":true,"pivot":f.pivot,"glow":f.get("glow",0.0)}
# View model from a stored shot.
static func from_shot(shot:Dictionary)->Dictionary:
	var fr:Dictionary=shot.frame
	return {"cols":fr.cols,"fov":fr.fov,"u":0.0,"dist":fr.dist,"size":fr.size,"aspect":fr.aspect,"light":shot.light,"clarity":shot.clarity,"sharp":shot.sharp,"marks":fr.marks,"kind":fr.get("kind","site"),"seed":fr.seed,"mode":shot.mode,"flash":shot.flash,"craft":shot.craft,"live":false,"pivot":0.0,"usable":shot.get("usable",true),"glow":fr.get("glow",0.0)}
static func _hash(n:int)->float:
	return fposmod(sin(float(n)*12.9898)*43758.5453,1.0)
static func draw(ci:CanvasItem,rect:Rect2,vm:Dictionary,time:float,font_size:int=14)->void:
	var font=ThemeDB.fallback_font
	var light:float=float(vm.light);var clarity:float=float(vm.clarity);var sharp:float=float(vm.sharp)
	var water_top=Color(0.02,0.05,0.08).lerp(Color(0.12,0.3,0.34),clampf(light*1.1,0,1))
	var water_low=Color(0.01,0.025,0.04).lerp(Color(0.06,0.17,0.2),clampf(light,0,1))
	ci.draw_polygon(PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]),PackedColorArray([water_top,water_top,water_low,water_low]))
	var cols:Array=vm.cols
	var horizon:float=rect.position.y+rect.size.y*0.52
	if cols.size()==COLS:
		var w:float=rect.size.x/COLS
		for i in COLS:
			var v:float=float(cols[i])/99.0
			if v>=0.985:continue
			var h:float=rect.size.y*(0.12+0.72*pow(1.0-v,1.1))
			var lit:float=clampf(light*(1.0-v)*1.9,0,1)
			var rock:Color=Color(0.05,0.07,0.09).lerp(Color(0.34,0.42,0.43),lit)
			rock=rock.lerp(water_low.lightened(0.05),clampf(v*(1.0-clarity)*1.6,0,0.9))
			rock=rock.darkened(0.15*_hash(i*7+int(vm.seed)))
			ci.draw_rect(Rect2(rect.position.x+i*w,horizon-h*0.62,w+1,h),rock)
		ci.draw_rect(Rect2(rect.position.x,horizon+rect.size.y*0.2,rect.size.x,rect.size.y*0.3),Color(0.02,0.04,0.05,0.5))
	# Seabed plane and the pool of the craft's own light.
	var floor_top:float=horizon+rect.size.y*0.08
	ci.draw_polygon(PackedVector2Array([Vector2(rect.position.x,floor_top),Vector2(rect.end.x,floor_top),rect.end,Vector2(rect.position.x,rect.end.y)]),PackedColorArray([Color(0.02,0.04,0.05,0.0),Color(0.02,0.04,0.05,0.0),Color(0.03,0.07,0.07,0.85),Color(0.03,0.07,0.07,0.85)]))
	for n in 5:
		var fy:float=floor_top+(rect.end.y-floor_top)*pow(float(n+1)/5.0,1.8)
		ci.draw_line(Vector2(rect.position.x,fy),Vector2(rect.end.x,fy),Color(0.35,0.55,0.55,0.05+0.06*light),1)
	var pool:=PackedVector2Array()
	for k in 24:
		pool.append(Vector2(rect.get_center().x+cos(TAU*k/24.0)*rect.size.x*0.34,floor_top+rect.size.y*0.16+sin(TAU*k/24.0)*rect.size.y*0.11))
	ci.draw_colored_polygon(pool,Color(0.55,0.8,0.78,0.05+0.16*light))
	# Subject at its bearing, scaled by true angular size, turned by aspect.
	var cx:float=rect.position.x+rect.size.x*(0.5+float(vm.u)*0.5)
	var width:float=clampf(float(vm.size)/maxf(float(vm.dist),20.0)/maxf(float(vm.fov),0.2)*rect.size.x,18.0,rect.size.x*1.1)
	var a:float=float(vm.aspect)
	var front:float=width*maxf(0.3,absf(cos(a)))
	var side:float=width*0.45*sin(a) if absf(sin(a))>0.05 else 0.0
	var top:float=horizon-width*0.42
	var tall:float=width*0.8
	var body_tint:Color=Color(0.05,0.075,0.09).lerp(Color(0.24,0.32,0.33),clampf(light*1.2,0,1))
	var glow:float=float(vm.get("glow",0.0))
	var siren:bool=vm.kind=="siren"
	var blur:float=(1.0-sharp)*7.0
	var haze:Color=Color(water_low.r,water_low.g,water_low.b,clampf((1.0-clarity)*0.55,0,0.6))
	for pass_index in (2 if blur>1.2 else 1):
		var dx:float=blur*(1.0 if pass_index==1 else 0.0)
		var alpha:float=0.5 if pass_index==1 else 1.0
		var left:float=cx-front*0.5+dx;var right:float=cx+front*0.5+dx
		var lit_top:Color=Color(body_tint.lightened(0.12),alpha);var lit_low:Color=Color(body_tint.darkened(0.45),alpha)
		if siren:
			var pts:=PackedVector2Array([Vector2(cx+dx,top),Vector2(right+side,horizon),Vector2(cx+dx,horizon+width*0.28),Vector2(left+side,horizon)])
			ci.draw_polygon(pts,PackedColorArray([lit_top,lit_low,lit_low,lit_low]))
			for k in 3:
				var t:float=0.25+0.22*k
				ci.draw_line(pts[0].lerp(pts[3],t),pts[0].lerp(pts[1],t),Color(0.85,0.22,0.18,alpha*clampf(0.35+light+glow,0,1)*0.7),1.2)
			ci.draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color(0.85,0.22,0.18,alpha*clampf(0.4+light,0,1)),1.5)
		else:
			if absf(side)>1.0:
				var sx:float=right if side>0 else left
				ci.draw_polygon(PackedVector2Array([Vector2(sx,top),Vector2(sx+side,top+tall*0.08),Vector2(sx+side,top+tall*1.02),Vector2(sx,top+tall)]),PackedColorArray([lit_low,lit_low,lit_low.darkened(0.3),lit_low.darkened(0.3)]))
			ci.draw_polygon(PackedVector2Array([Vector2(left,top),Vector2(right,top),Vector2(right,top+tall),Vector2(left,top+tall)]),PackedColorArray([lit_top,lit_top,lit_low,lit_low]))
			for k in range(1,7):
				var rx:float=left+front*float(k)/7.0
				ci.draw_line(Vector2(rx,top+tall*0.1),Vector2(rx,top+tall*0.95),Color(0,0.02,0.03,alpha*0.4),maxf(1.0,front*0.012))
			ci.draw_rect(Rect2(left,top,front,tall*0.07),Color(0.02,0.04,0.05,alpha*0.7))
			ci.draw_rect(Rect2(left,top,front,tall),Color(0.5,0.72,0.7,alpha*0.35),false,1.2)
			if glow>0.15:
				for k in 3:ci.draw_circle(Vector2(left+front*0.28,top+tall*0.3),width*(0.05+0.035*k),Color(0.95,0.7,0.35,alpha*glow*0.22))
		ci.draw_rect(Rect2(left-2,top-2,front+absf(side)+4,tall+6),haze)
	if absf(float(vm.u))>1.0:
		var way:float=signf(float(vm.u));var ex:float=rect.end.x-18.0 if way>0 else rect.position.x+18.0
		ci.draw_colored_polygon(PackedVector2Array([Vector2(ex+way*8,horizon),Vector2(ex-way*6,horizon-10),Vector2(ex-way*6,horizon+10)]),AMBER)
		ci.draw_string(font,Vector2(rect.get_center().x-40,rect.position.y+rect.size.y*0.2),"TURNING ONTO SUBJECT",HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(10,font_size-2),AMBER)
	# Features: resolved ones sharp and labelled; apparent but unresolved ones smudge.
	var index:=0
	for mark in vm.marks:
		var mx:float=rect.position.x+rect.size.x*(0.5+float(mark.x)*0.5)+(float(vm.u)*rect.size.x*0.5)
		mx=clampf(mx,rect.position.x+10,rect.end.x-10)
		var my:float=top+width*(0.18+0.22*float(index%3))
		if float(mark.q)>0.0:
			var c=PHOSPHOR.lerp(AMBER,0.35)
			ci.draw_arc(Vector2(mx,my),9.0,0,TAU,20,c,1.8)
			ci.draw_circle(Vector2(mx,my),2.2,c)
			if not str(mark.label).is_empty() and font_size>=10:
				ci.draw_string(font,Vector2(clampf(mx-30,rect.position.x+4,rect.end.x-96),my+22+(index%2)*font_size),str(mark.label),HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(10,font_size-3),c)
		else:
			ci.draw_circle(Vector2(mx,my),8.0,Color(0.45,0.5,0.5,0.22))
		index+=1
	# Grain from lack of light and haze; scan lines; vignette; corner brackets.
	var grain:int=int((1.0-light)*90.0+(1.0-clarity)*70.0)
	var tick:int=int(time*9.0)
	for i in grain:
		var gx:float=rect.position.x+_hash(i*3+tick*17)*rect.size.x
		var gy:float=rect.position.y+_hash(i*5+tick*31+9)*rect.size.y
		ci.draw_rect(Rect2(gx,gy,1.6,1.6),Color(0.7,0.85,0.85,0.14))
	var y:float=rect.position.y
	while y<rect.end.y:
		ci.draw_line(Vector2(rect.position.x,y),Vector2(rect.end.x,y),Color(0,0.02,0.04,0.11),1)
		y+=4
	var edge=Color(0,0,0,0.35)
	ci.draw_rect(Rect2(rect.position,Vector2(rect.size.x,rect.size.y*0.08)),edge)
	ci.draw_rect(Rect2(Vector2(rect.position.x,rect.end.y-rect.size.y*0.08),Vector2(rect.size.x,rect.size.y*0.08)),edge)
	var bracket:float=14.0;var bc=Color(PHOSPHOR,0.8)
	for corner in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
		var sx:float=1.0 if corner.x<rect.get_center().x else -1.0
		var sy:float=1.0 if corner.y<rect.get_center().y else -1.0
		ci.draw_line(corner,corner+Vector2(sx*bracket,0),bc,2)
		ci.draw_line(corner,corner+Vector2(0,sy*bracket),bc,2)
	if bool(vm.get("live",false)):
		var mid:Vector2=Vector2(rect.get_center().x,horizon)
		ci.draw_line(mid-Vector2(12,0),mid-Vector2(4,0),PHOSPHOR,1.5);ci.draw_line(mid+Vector2(4,0),mid+Vector2(12,0),PHOSPHOR,1.5)
		ci.draw_line(mid-Vector2(0,12),mid-Vector2(0,4),PHOSPHOR,1.5);ci.draw_line(mid+Vector2(0,4),mid+Vector2(0,12),PHOSPHOR,1.5)
	if vm.get("usable",true)==false:
		ci.draw_string(font,rect.position+Vector2(8,rect.size.y*0.5),"UNUSABLE FRAME",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size+2,Color("e08a73"))
	var info:="%dm  ASPECT %d°  %s%s"%[roundi(float(vm.dist)),roundi(rad_to_deg(a)),str(vm.mode).to_upper(),"  FLASH" if vm.flash else ""]
	ci.draw_string(font,Vector2(rect.position.x+8,rect.end.y-6),info,HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(10,font_size-2),PHOSPHOR)
	var bar_w:float=minf(70.0,rect.size.x*0.22)
	var bx:float=rect.end.x-bar_w-8
	for row in [["LUX",light],["CLR",clarity],["SHP",sharp]]:
		var idx:int=["LUX","CLR","SHP"].find(row[0])
		var by:float=rect.position.y+8+idx*(font_size*0.9)
		ci.draw_string(font,Vector2(bx-30,by+font_size*0.7),row[0],HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(9,font_size-4),Color(PHOSPHOR,0.85))
		ci.draw_rect(Rect2(bx,by+2,bar_w,font_size*0.5),Color(0.1,0.22,0.25,0.9))
		ci.draw_rect(Rect2(bx,by+2,bar_w*clampf(float(row[1]),0,1),font_size*0.5),AMBER if row[0]=="SHP" else PHOSPHOR)
# A control that shows one stored shot, for the archive viewer.
class Plate extends Control:
	var vm:Dictionary={}
	var title:=""
	func _ready()->void:
		clip_contents=true;custom_minimum_size=Vector2(0,170)
	func _process(_dt:float)->void:
		queue_redraw()
	func _draw()->void:
		if vm.is_empty():return
		var R=preload("res://src/presentation/photo_view.gd")
		R.draw(self,Rect2(Vector2.ZERO,size),vm,0.0,12)
		draw_rect(Rect2(Vector2.ZERO,size),Color("6b9d9f"),false,1)
		if not title.is_empty():draw_string(ThemeDB.fallback_font,Vector2(8,16),title,HORIZONTAL_ALIGNMENT_LEFT,-1,12,PHOSPHOR)
