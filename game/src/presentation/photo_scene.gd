extends RefCounted
# The photograph as a picture. A stored or live frame is painted as a lit, noisy,
# stylised underwater scene from the craft's own viewpoint: the terrain profile
# across the field of view, the seabed under the lamp, backscatter and marine
# snow, and the subject turned to its true aspect. A feature of the subject is
# drawn only when the frame resolved it; an unresolved one is a smear of grain.
# `develop` 0..1 plays the plate coming up out of the dark.
const PHOSPHOR=Color("8cdcd3")
const AMBER=Color("e0bf83")
const COLS=36
# Subject looks by optical key, siren looks by type.
const LOOKS={"spire":"tower","relay_west":"housing","relay_east":"housing","furnace":"wall","cradle":"gantry","frame_cycle":"wall","well_pattern":"array","well_aperture":"hole","well_return":"hole","transmitter":"array","departure":"field","silt_scour":"field","exhaust_stack":"tower","prism_facets":"crystal","blackwater_request":"housing","blackwater_reply":"housing","final_photo_30":"wall","final_photo_30_bonus":"gantry","final_photo_31":"housing","final_photo_31_bonus":"array"}
const ART={"beacon":"lamp","drill":"string","scoring":"scoring","housing":"none","clock":"clock","mouth":"mouth","lining":"lining","rails":"rails","frames":"frames","hatch":"hatch","ribs":"none","count":"count","face":"none","vanes":"none","throat":"throat","lines":"lines","fracture":"fracture","stack":"lamp","plume":"plume","channel":"channel","prism":"none","facets":"facets","form":"none","array":"array","gait":"gait","overview":"none"}
static func rnd(n:int)->float:
	return fposmod(sin(float(n)*12.9898)*43758.5453,1.0)
static func look_for(vm:Dictionary)->String:
	if str(vm.get("kind","site"))=="siren":return "siren"
	return LOOKS.get(str(vm.get("key","")),"tower")
# Clamps a polygon into the picture so glows never bleed over the interface.
static func _clamp_poly(pts:PackedVector2Array,r:Rect2)->PackedVector2Array:
	var out:=PackedVector2Array()
	for p in pts:out.append(Vector2(clampf(p.x,r.position.x,r.end.x),clampf(p.y,r.position.y,r.end.y)))
	return out
static func _glow(ci:CanvasItem,r:Rect2,c:Vector2,rx:float,ry:float,col:Color,steps:int=6)->void:
	for k in steps:
		var f:float=1.0-float(k)/steps
		var pts:=PackedVector2Array()
		for n in 20:pts.append(c+Vector2(cos(TAU*n/20.0)*rx*f,sin(TAU*n/20.0)*ry*f))
		ci.draw_colored_polygon(_clamp_poly(pts,r),Color(col.r,col.g,col.b,col.a/steps*1.6))
static func draw(ci:CanvasItem,rect:Rect2,vm:Dictionary,time:float,font_size:int=14)->void:
	var font=ThemeDB.fallback_font
	var dev:float=clampf(float(vm.get("develop",1.0)),0.0,1.0)
	var ease_dev:float=dev*dev*(3.0-2.0*dev)
	var light:float=float(vm.light)*lerpf(0.35,1.0,ease_dev)
	var clarity:float=float(vm.clarity)
	var sharp:float=float(vm.sharp)*lerpf(0.15,1.0,ease_dev)
	var seed_n:int=int(vm.get("seed",0))
	var depth:float=float(vm.get("depth",0.5))
	var flash:bool=bool(vm.get("flash",false))
	var look:String=look_for(vm)
	var horizon:float=rect.position.y+rect.size.y*0.5
	# Water column: deeper water is blacker, light lifts it toward teal.
	var top:Color=Color(0.012,0.03,0.05).lerp(Color(0.1,0.27,0.3),clampf(light*0.9,0,1)*(1.0-depth*0.4))
	var low:Color=Color(0.008,0.02,0.032).lerp(Color(0.05,0.15,0.17),clampf(light,0,1)*(1.0-depth*0.4))
	ci.draw_polygon(PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]),PackedColorArray([top,top,low,low]))
	_terrain(ci,rect,vm,horizon,light,clarity,low,seed_n)
	var floor_top:float=horizon+rect.size.y*0.12
	_seabed(ci,rect,floor_top,light,seed_n,vm)
	# The subject, once per ghost pass: a soft frame smears into doubled edges.
	var cx:float=rect.position.x+rect.size.x*(0.5+float(vm.u)*0.5)
	var scale_px:float=clampf(float(vm.size)/maxf(float(vm.dist),20.0)/maxf(float(vm.fov),0.2)*rect.size.x,16.0,rect.size.x*1.1)
	var ctx:={"ci":ci,"rect":rect,"cx":cx,"base":floor_top+rect.size.y*0.1,"s":minf(scale_px,rect.size.y*0.62),"a":float(vm.aspect),"light":light,"glow":float(vm.get("glow",0.0)),"sharp":sharp,"seed":seed_n,"time":time,"flash":flash,"low":low,"vm":vm,"clarity":clarity}
	var blur:float=(1.0-sharp)*13.0
	var passes:Array=[[0.0,1.0]] if blur<1.3 else ([[-blur,0.22],[blur,0.22],[-blur*0.5,0.3],[blur*0.5,0.3],[0.0,0.85]] if blur>6.0 else [[-blur,0.3],[blur,0.3],[0.0,1.0]])
	for p in passes:
		ctx["dx"]=p[0];ctx["alpha"]=p[1]
		_subject(ctx,look)
	# Features: resolved ones are drawn as what they are; unresolved ones only smudge.
	var index:=0
	for mark in vm.marks:
		var mx:float=rect.position.x+rect.size.x*(0.5+float(mark.x)*0.5)+(float(vm.u)*rect.size.x*0.5)
		mx=clampf(mx,rect.position.x+10,rect.end.x-10)
		var my:float=ctx.base-ctx.s*(0.35+0.3*float(mark.get("y",0.35+0.22*float(index%3))))
		var q:float=float(mark.q)
		var visible_at:float=0.45+0.4*(1.0-q)
		if q>0.0 and (dev>=visible_at or dev>=1.0):
			var art:String=str(mark.get("art",""))
			if art.is_empty():art=str(ART.get(str(mark.id),"none"))
			var alpha:float=clampf((dev-visible_at)/0.15+0.4,0.4,1.0) if dev<1.0 else 1.0
			_feature(ctx,art,Vector2(mx,my),q,alpha)
			if not str(mark.get("find","")).is_empty():
				var d:Vector2=Vector2(mx,my-22.0)
				ci.draw_colored_polygon(PackedVector2Array([d+Vector2(0,-7),d+Vector2(7,0),d+Vector2(0,7),d+Vector2(-7,0)]),Color(AMBER,0.92*alpha))
				ci.draw_string(font,d+Vector2(-3,4),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(0.05,0.07,0.08))
			if font_size>=10 and not str(mark.label).is_empty() and bool(vm.get("labels",true)):
				_tag(ci,font,rect,Vector2(mx,my),str(mark.label),font_size,index)
		elif q<=0.0:
			var sm:=Color(0.55,0.62,0.6,0.1+0.1*(1.0-sharp))
			_glow(ci,rect,Vector2(mx,my),10.0+blur,8.0+blur,sm,3)
		index+=1
	_water_effects(ci,rect,vm,time,light,clarity,sharp,flash,dev,seed_n)
	_frame_chrome(ci,rect,vm,font,font_size,dev)
# --- background layers --------------------------------------------------------
static func _terrain(ci:CanvasItem,rect:Rect2,vm:Dictionary,horizon:float,light:float,clarity:float,fog:Color,seed_n:int)->void:
	var cols:Array=vm.cols
	if cols.size()!=COLS:return
	var w:float=rect.size.x/COLS
	for i in COLS:
		var v:float=float(cols[i])/99.0
		if v>=0.985:continue
		var h:float=rect.size.y*(0.14+0.7*pow(1.0-v,1.1))
		var lit:float=clampf(light*(1.0-v)*1.9,0,1)
		var jag:float=(rnd(i*7+seed_n)-0.5)*rect.size.y*0.05
		var rock:Color=Color(0.04,0.06,0.08).lerp(Color(0.38,0.46,0.45),lit)
		var far:float=clampf(v*(1.0-clarity)*1.7+v*0.35,0,0.92)
		rock=rock.lerp(fog.lightened(0.07),far)
		var x:float=rect.position.x+i*w
		var y0:float=horizon-h*0.62+jag
		var edge:Color=rock.lightened(0.18*lit+0.04)
		ci.draw_polygon(PackedVector2Array([Vector2(x,y0),Vector2(x+w+1,y0+(rnd(i*3+seed_n)-0.5)*6.0),Vector2(x+w+1,y0+h),Vector2(x,y0+h)]),PackedColorArray([edge,edge,rock.darkened(0.3),rock.darkened(0.3)]))
		if lit>0.25:
			for n in 2:ci.draw_line(Vector2(x+rnd(i*5+n)*w,y0+h*0.2*(n+1)),Vector2(x+rnd(i*9+n)*w+w*0.5,y0+h*0.24*(n+1)+5.0),Color(0,0,0,0.22),1.0)
static func _seabed(ci:CanvasItem,rect:Rect2,floor_top:float,light:float,seed_n:int,vm:Dictionary)->void:
	var dark:=Color(0.02,0.04,0.045,0.0)
	var sand:=Color(0.05,0.1,0.1).lerp(Color(0.3,0.42,0.38),clampf(light,0,1))
	ci.draw_polygon(PackedVector2Array([Vector2(rect.position.x,floor_top),Vector2(rect.end.x,floor_top),rect.end,Vector2(rect.position.x,rect.end.y)]),PackedColorArray([dark,dark,Color(sand,0.92),Color(sand,0.92)]))
	for n in 7:
		var f:float=pow(float(n+1)/7.0,1.7)
		var fy:float=floor_top+(rect.end.y-floor_top)*f
		var amp:float=2.0+6.0*f
		var pts:=PackedVector2Array()
		for k in range(0,17):
			var x:float=rect.position.x+rect.size.x*float(k)/16.0
			pts.append(Vector2(x,fy+sin(float(k)*1.3+float(n)*2.1+float(seed_n))*amp*0.4))
		ci.draw_polyline(pts,Color(0.5,0.7,0.65,0.05+0.1*light*f),1.0+f)
	# Pebbles and low ridges, the nearer ones larger.
	for n in 14:
		var f:float=rnd(n*11+seed_n)
		var px:float=rect.position.x+rnd(n*17+seed_n+3)*rect.size.x
		var py:float=floor_top+(rect.end.y-floor_top)*(0.15+0.8*f)
		var r:float=1.5+7.0*f
		ci.draw_colored_polygon(PackedVector2Array([Vector2(px-r,py),Vector2(px-r*0.4,py-r*0.7),Vector2(px+r*0.5,py-r*0.6),Vector2(px+r,py)]),Color(sand.r*0.6,sand.g*0.7,sand.b*0.7,0.8))
		ci.draw_line(Vector2(px-r*0.4,py-r*0.7),Vector2(px+r*0.5,py-r*0.6),Color(0.8,0.95,0.9,0.12*light),1.0)
	# Pool of the craft's own lamp on the seabed.
	_glow(ci,rect,Vector2(rect.get_center().x,floor_top+rect.size.y*0.2),rect.size.x*0.46,rect.size.y*0.16,Color(0.6,0.88,0.82,0.05+0.2*light),6)
# --- subject --------------------------------------------------------------------
static func _shade(ctx:Dictionary,lit:float)->Color:
	var l:float=clampf(float(ctx.light)*1.25*lit,0,1)
	return Color(0.04,0.06,0.075).lerp(Color(0.33,0.45,0.45),l)
static func _subject(ctx:Dictionary,look:String)->void:
	var ci:CanvasItem=ctx.ci;var cx:float=ctx.cx+ctx.dx;var base:float=ctx.base;var s:float=ctx.s;var a:float=ctx.a;var al:float=ctx.alpha
	var front:float=s*maxf(0.32,absf(cos(a)))
	var side:float=s*0.5*sin(a)
	var left:float=cx-front*0.5;var right:float=cx+front*0.5
	var detail:float=clampf(float(ctx.sharp)*1.3,0,1)
	var body:Color=_shade(ctx,1.0);var shade:Color=_shade(ctx,0.45)
	body.a=al;shade.a=al
	var line:Color=Color(0.01,0.03,0.04,al*0.55*detail)
	var hi:Color=Color(0.7,0.9,0.86,al*0.35*clampf(float(ctx.light)*1.3,0,1))
	match look:
		"siren":_siren(ctx,cx,base,s,a,front,side,body,shade,detail,al)
		"wall":
			var h:float=s*0.55
			_slab(ci,left,right,base-h,base,side,body,shade)
			for k in range(1,6):
				var x:float=left+front*float(k)/6.0
				ci.draw_line(Vector2(x,base-h*0.92),Vector2(x,base-h*0.05),line,maxf(1.0,front*0.01))
			for k in range(1,3):ci.draw_line(Vector2(left+2,base-h*float(k)/3.0),Vector2(right-2,base-h*float(k)/3.0),line,1.0)
			ci.draw_rect(Rect2(left,base-h,front,h*0.06),hi)
		"gantry":
			var h:float=s*0.6
			for k in 5:
				var x:float=left+front*float(k)/4.0
				ci.draw_line(Vector2(x,base),Vector2(x,base-h),body.lightened(0.05),maxf(1.5,front*0.025))
			for k in 4:
				var y:float=base-h*float(k+1)/4.0
				ci.draw_line(Vector2(left,y),Vector2(right,y),shade,1.4)
				if detail>0.4:ci.draw_line(Vector2(left+front*float(k)/4.0,base),Vector2(left+front*float(k+1)/4.0,y),line,1.0)
			ci.draw_line(Vector2(left-8,base+3),Vector2(right+8,base+3),hi,2.0)
		"housing":
			var h:float=s*0.5
			_slab(ci,left+front*0.18,right-front*0.18,base-h,base-h*0.15,side*0.5,body,shade)
			ci.draw_line(Vector2(cx,base-h*0.15),Vector2(cx,base),shade,maxf(2.0,front*0.05))
			ci.draw_rect(Rect2(left+front*0.1,base-h*0.15,front*0.8,h*0.15),shade)
			if detail>0.5:ci.draw_rect(Rect2(left+front*0.2,base-h*0.95,front*0.6,h*0.16),line)
		"array":
			var h:float=s*0.6
			var rx:float=front*0.5;var ry:float=h*0.5
			var cpt:=Vector2(cx,base-h*0.55)
			for k in 7:
				var f:float=float(k)/6.0
				var pts:=PackedVector2Array()
				for n in 24:
					var t:float=TAU*float(n)/24.0
					pts.append(cpt+Vector2(cos(t)*rx*(0.35+0.65*f)*maxf(0.35,absf(cos(a))),sin(t)*ry*(0.35+0.65*f)))
				pts.append(pts[0])
				ci.draw_polyline(pts,Color(body.r,body.g,body.b,al*(0.9-0.5*f)),maxf(1.2,front*0.02))
			ci.draw_line(Vector2(cx,cpt.y+ry),Vector2(cx,base),shade,maxf(2.0,front*0.04))
		"hole":
			var h:float=s*0.5
			_slab(ci,left,right,base-h,base,side,body,shade)
			var cpt:=Vector2(cx,base-h*0.5)
			var pts:=PackedVector2Array()
			for n in 20:
				var t:float=TAU*float(n)/20.0
				pts.append(cpt+Vector2(cos(t)*front*0.28*maxf(0.4,absf(cos(a))),sin(t)*h*0.32))
			ci.draw_colored_polygon(pts,Color(0.0,0.01,0.015,al))
			ci.draw_polyline(pts+PackedVector2Array([pts[0]]),hi,1.6)
		"field":
			# Marks on the seabed itself, laid in perspective.
			for k in 7:
				var f:float=float(k)/6.0
				var y:float=base-s*0.04+f*s*0.28
				ci.draw_line(Vector2(cx-s*0.55*(0.6+f*0.5),y),Vector2(cx+s*0.55*(0.6+f*0.5),y+(f-0.5)*s*0.05),Color(0.04,0.07,0.07,al*0.6),1.0+f*2.0)
		"crystal":
			var h:float=s*0.75
			var tip:=Vector2(cx+side*0.3,base-h)
			ci.draw_polygon(PackedVector2Array([Vector2(left,base),tip,Vector2(cx,base)]),PackedColorArray([shade,body,shade]))
			ci.draw_polygon(PackedVector2Array([Vector2(cx,base),tip,Vector2(right,base)]),PackedColorArray([body,body.lightened(0.1),shade]))
			if detail>0.4:ci.draw_line(tip,Vector2(cx,base),hi,1.2)
		_:
			# tower
			var h:float=s*0.95
			ci.draw_polygon(PackedVector2Array([Vector2(left+front*0.12,base-h),Vector2(right-front*0.12,base-h),Vector2(right,base),Vector2(left,base)]),PackedColorArray([body.lightened(0.08),body.lightened(0.08),shade,shade]))
			if side>1.0:ci.draw_polygon(PackedVector2Array([Vector2(right-front*0.12,base-h),Vector2(right-front*0.12+side*0.6,base-h+4.0),Vector2(right+side*0.6,base),Vector2(right,base)]),PackedColorArray([shade,shade,shade.darkened(0.3),shade.darkened(0.3)]))
			for k in range(1,8):
				var y:float=base-h*float(k)/8.0
				ci.draw_line(Vector2(left+front*0.1*(1.0-float(k)/8.0),y),Vector2(right-front*0.1*(1.0-float(k)/8.0),y),line,maxf(1.0,front*0.015))
			ci.draw_line(Vector2(left+front*0.12,base-h),Vector2(left+front*0.02,base),hi,1.5)
	# Contact shadow on the seabed.
	ci.draw_rect(Rect2(cx-s*0.5,base+1,s,s*0.04),Color(0,0.01,0.015,0.35*al))
static func _slab(ci:CanvasItem,l:float,r:float,t:float,b:float,side:float,body:Color,shade:Color)->void:
	if absf(side)>1.0:
		var sx:float=r if side>0 else l
		ci.draw_polygon(PackedVector2Array([Vector2(sx,t),Vector2(sx+side,t+3.0),Vector2(sx+side,b+2.0),Vector2(sx,b)]),PackedColorArray([shade,shade,shade.darkened(0.35),shade.darkened(0.35)]))
	ci.draw_polygon(PackedVector2Array([Vector2(l,t),Vector2(r,t),Vector2(r,b),Vector2(l,b)]),PackedColorArray([body.lightened(0.1),body.lightened(0.1),body,body]))
static func _siren(ctx:Dictionary,cx:float,base:float,s:float,a:float,front:float,side:float,body:Color,shade:Color,detail:float,al:float)->void:
	var ci:CanvasItem=ctx.ci
	var type:String=str(ctx.vm.get("type","patroller"))
	var mid:float=base-s*0.5
	var w:float=front*0.5;var h:float=s*0.28
	var red:=Color(0.88,0.2,0.16,al)
	var long_body:bool=type in ["patroller","hunter","interceptor","sweeper"]
	var seam:Color=Color(red.r,red.g,red.b,al*clampf(0.3+float(ctx.light)+float(ctx.glow),0,1)*0.85*detail)
	# Tail and fins first, so the body overlaps them.
	var wag:float=sin(float(ctx.time)*1.6)*h*0.25
	ci.draw_polygon(PackedVector2Array([Vector2(cx-w*0.8,mid),Vector2(cx-w*1.7,mid-h*0.5+wag),Vector2(cx-w*1.45,mid+wag*0.5),Vector2(cx-w*1.7,mid+h*0.5+wag)]),PackedColorArray([shade,shade.darkened(0.2),shade.darkened(0.2),shade.darkened(0.2)]))
	for k in 3:
		var fx:float=cx-w*0.3+k*w*0.45
		ci.draw_polygon(PackedVector2Array([Vector2(fx,mid-h*0.8),Vector2(fx+w*0.12,mid-h*(1.5+(0.4 if type in ["hunter","interceptor"] else 0.0))),Vector2(fx+w*0.3,mid-h*0.7)]),PackedColorArray([shade,body.darkened(0.2),shade]))
	var pts:=PackedVector2Array([Vector2(cx-w,mid),Vector2(cx-w*0.3,mid-h),Vector2(cx+w*0.7,mid-h*0.55),Vector2(cx+w*(1.2 if long_body else 0.95),mid),Vector2(cx+w*0.7,mid+h*0.55),Vector2(cx-w*0.3,mid+h)])
	ci.draw_polygon(pts,PackedColorArray([shade,body.lightened(0.08),body,body.lightened(0.05),shade,shade.darkened(0.2)]))
	if type in ["sentinel","warden"]:ci.draw_arc(Vector2(cx,mid),h*1.2,0,TAU,24,Color(red.r,red.g,red.b,al*0.5*detail),2.0)
	if type=="sweeper":ci.draw_arc(Vector2(cx+w*1.0,mid),h*0.8,-1.2,1.2,12,Color(red.r,red.g,red.b,al*0.6*detail),2.0)
	for k in 5:
		var t:float=0.18+0.16*float(k)
		var x:float=cx-w*0.9+w*1.8*t
		ci.draw_line(Vector2(x,mid-h*(0.7-0.35*t)),Vector2(x,mid+h*(0.7-0.35*t)),seam,1.4)
	# Eyes: two red points that read even in a poor frame.
	var eye:Vector2=Vector2(cx+w*0.75,mid-h*0.12)
	ci.draw_circle(eye,maxf(1.5,h*0.07),Color(1.0,0.3,0.22,al));ci.draw_circle(eye+Vector2(0,h*0.28),maxf(1.2,h*0.06),Color(1.0,0.3,0.22,al*0.8))
	_glow(ci,ctx.rect,eye,h*0.5,h*0.4,Color(1.0,0.25,0.2,0.25*al),3)
	var outline:=PackedVector2Array(pts);outline.append(pts[0])
	ci.draw_polyline(outline,Color(red.r,red.g,red.b,al*clampf(0.35+float(ctx.light),0,1)*0.7),1.3)
# --- feature art ---------------------------------------------------------------
static func _feature(ctx:Dictionary,art:String,p:Vector2,q:float,alpha:float)->void:
	var ci:CanvasItem=ctx.ci;var s:float=ctx.s;var t:float=ctx.time
	var u:float=clampf(s*0.12,6.0,30.0)
	var warm:=Color(0.95,0.7,0.35,alpha);var cool:=Color(PHOSPHOR,alpha);var dark:=Color(0.01,0.025,0.03,alpha*0.8)
	var rr:Rect2=ctx.rect
	match art:
		"lamp":
			var pulse:float=0.75+0.25*sin(t*3.0)
			_glow(ci,rr,p,u*2.4,u*2.4,Color(warm.r,warm.g,warm.b,0.5*alpha*pulse),6)
			ci.draw_circle(p,u*0.32,Color(1,0.95,0.8,alpha))
		"string":
			var pts:=PackedVector2Array()
			for k in 9:pts.append(p+Vector2((float(k)-4.0)*u*0.6,sin(float(k)*1.7)*u*0.35+float(k)*u*0.12))
			ci.draw_polyline(pts,Color(0.55,0.5,0.42,alpha),maxf(2.0,u*0.3))
			ci.draw_polyline(pts,Color(0.9,0.8,0.6,alpha*0.4),1.0)
			ci.draw_line(pts[8],pts[8]+Vector2(u*0.5,u*0.9),Color(0.9,0.5,0.3,alpha),2.0)
		"scoring":
			for k in 5:ci.draw_line(p+Vector2(-u*1.6+k*u*0.5,-u*0.8),p+Vector2(-u*1.2+k*u*0.5,u*0.9),Color(0.9,0.9,0.8,alpha*0.7),1.4)
		"clock":
			ci.draw_circle(p,u*0.9,Color(0.85,0.82,0.7,alpha));ci.draw_circle(p,u*0.75,dark)
			ci.draw_line(p,p+Vector2(u*0.5,-u*0.2),Color(0.95,0.9,0.7,alpha),1.6);ci.draw_line(p,p+Vector2(-u*0.1,-u*0.6),Color(0.95,0.9,0.7,alpha),1.2)
		"mouth":
			_glow(ci,rr,p,u*2.2,u*1.6,Color(warm.r,warm.g,warm.b,0.55*alpha),6)
			ci.draw_rect(Rect2(p-Vector2(u*1.1,u*0.6),Vector2(u*2.2,u*1.2)),dark)
		"lining":
			for k in 6:ci.draw_arc(p+Vector2(0,-u*0.8+k*u*0.35),u*1.3,0.2,PI-0.2,10,Color(0.52,0.7,0.55,alpha*0.8),1.6)
		"rails":
			ci.draw_line(p+Vector2(-u*2.0,u*0.6),p+Vector2(u*2.0,u*0.2),Color(0.55,0.55,0.5,alpha),2.0);ci.draw_line(p+Vector2(-u*2.0,u*1.0),p+Vector2(u*2.0,u*0.6),Color(0.55,0.55,0.5,alpha),2.0)
		"frames":
			for k in 3:
				var x:float=p.x+(float(k)-1.0)*u*1.5
				ci.draw_polyline(PackedVector2Array([Vector2(x-u*0.5,p.y+u*0.8),Vector2(x-u*0.5,p.y-u*0.8),Vector2(x+u*0.5,p.y-u*0.8),Vector2(x+u*0.5,p.y+u*0.8)]),Color(0.7,0.55,0.4,alpha),2.0)
				_glow(ci,rr,Vector2(x,p.y),u*0.9,u*0.9,Color(warm.r,warm.g,warm.b,0.25*alpha),3)
		"hatch":
			var open:float=0.5+0.5*sin(t*0.9)
			for k in 3:
				var x:float=p.x+(float(k)-1.0)*u*1.5
				ci.draw_rect(Rect2(x-u*0.5,p.y-u*0.4,u,u*0.8),dark)
				ci.draw_rect(Rect2(x-u*0.5,p.y-u*0.05,u,u*0.1+u*0.5*open),Color(warm.r,warm.g,warm.b,alpha*0.9))
		"count":
			for k in 7:ci.draw_line(p+Vector2(-u*1.5+k*u*0.5,-u*0.4),p+Vector2(-u*1.5+k*u*0.5,u*0.4+(u*0.4 if k%3==0 else 0.0)),cool,1.6)
		"throat":
			ci.draw_circle(p,u*1.0,dark);ci.draw_arc(p,u*1.0,0,TAU,20,cool,1.6);ci.draw_arc(p,u*0.5,0,TAU,16,Color(cool.r,cool.g,cool.b,alpha*0.6),1.2)
		"lines":
			for k in 5:ci.draw_line(p+Vector2(-u*1.8,-u*0.4+k*u*0.28),p+Vector2(u*1.8,-u*0.3+k*u*0.28),Color(0.12,0.2,0.2,alpha*0.9),1.8)
		"fracture":
			var pts:=PackedVector2Array([p+Vector2(-u*1.8,-u*0.2),p+Vector2(-u*0.6,u*0.25),p+Vector2(0,-u*0.1),p+Vector2(u*0.9,u*0.35),p+Vector2(u*1.8,0)])
			ci.draw_polyline(pts,Color(1.0,0.55,0.2,alpha),3.0);_glow(ci,rr,p,u*2.2,u*0.9,Color(1.0,0.45,0.15,0.4*alpha),5)
		"plume":
			for k in 4:
				var wob:float=sin(t*2.0+k)*u*0.2
				_glow(ci,rr,p+Vector2(wob,-float(k)*u*0.5),u*0.9+k*u*0.2,u*0.7,Color(1.0,0.5,0.2,0.28*alpha),3)
		"channel":
			ci.draw_rect(Rect2(p-Vector2(u*1.6,u*0.25),Vector2(u*3.2,u*0.5)),Color(0.0,0.015,0.02,alpha));ci.draw_rect(Rect2(p-Vector2(u*1.6,u*0.25),Vector2(u*3.2,u*0.5)),Color(cool.r,cool.g,cool.b,alpha*0.5),false,1.2)
		"facets":
			var pts:=PackedVector2Array()
			for k in 6:pts.append(p+Vector2.from_angle(TAU*float(k)/6.0)*u*(0.9+0.2*rnd(k)))
			ci.draw_colored_polygon(pts,Color(0.5,0.8,0.9,alpha*0.35))
			for k in 6:ci.draw_line(p,pts[k],Color(0.9,1.0,1.0,alpha*0.7),1.2)
		"array":
			for k in 9:ci.draw_circle(p+Vector2((float(k%3)-1.0)*u*0.55,(float(k/3)-1.0)*u*0.5),u*0.16,Color(1.0,0.45,0.35,alpha*(0.5+0.5*sin(t*4.0+k))))
		"gait":
			for k in 4:ci.draw_polyline(PackedVector2Array([p+Vector2(-u*1.2-k*u*0.5,u*0.4),p+Vector2(-u*0.3-k*u*0.5,0),p+Vector2(u*0.6-k*u*0.5,u*0.4)]),Color(0.9,0.4,0.3,alpha*(0.8-0.18*k)),1.4)
		_:
			ci.draw_arc(p,7.0,0,TAU,18,Color(cool.r,cool.g,cool.b,alpha*0.55),1.2)
static func _tag(ci:CanvasItem,font:Font,rect:Rect2,p:Vector2,text:String,font_size:int,index:int)->void:
	var fs:int=maxi(10,font_size-3)
	var x:float=clampf(p.x-30,rect.position.x+4,rect.end.x-100)
	var y:float=rect.end.y-rect.size.y*0.2-float(index%3)*(fs+3)
	var c:Color=PHOSPHOR.lerp(AMBER,0.3)
	ci.draw_line(p+Vector2(0,10),Vector2(clampf(p.x,rect.position.x+6,rect.end.x-6),y-fs),Color(c.r,c.g,c.b,0.35),1.0)
	ci.draw_string(font,Vector2(x,y),text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,c)
# --- optics ---------------------------------------------------------------------
static func _water_effects(ci:CanvasItem,rect:Rect2,vm:Dictionary,time:float,light:float,clarity:float,sharp:float,flash:bool,dev:float,seed_n:int)->void:
	# Backscatter veil: murky water lifts the blacks and washes the distance.
	var veil:float=clampf((1.0-clarity)*0.5,0,0.55)
	if veil>0.02:ci.draw_rect(rect,Color(0.1,0.22,0.22,veil*0.55))
	# Marine snow: lit by the lamp, bigger and softer near the lens.
	var tick:float=time*0.35
	for i in 46:
		var depth_n:float=rnd(i*13+seed_n)
		var x:float=rect.position.x+fposmod(rnd(i*3+seed_n)+sin(tick+i)*0.02,1.0)*rect.size.x
		var y:float=rect.position.y+fposmod(rnd(i*5+seed_n+1)+tick*0.05*(0.4+depth_n),1.0)*rect.size.y
		var r:float=0.8+3.6*depth_n*depth_n
		var a:float=(0.12+0.5*light)*(0.3+0.7*depth_n)*(0.5+0.5*sin(time*2.0+i))
		ci.draw_circle(Vector2(x,y),r,Color(0.8,0.95,0.92,clampf(a*0.55,0,0.5)))
	if flash:
		_glow(ci,rect,rect.get_center(),rect.size.x*0.6,rect.size.y*0.6,Color(1,1,0.92,0.1),4)
	# Grain: low light, haze and an unripe plate all add noise.
	var grain:int=int((1.0-light)*130.0+(1.0-clarity)*70.0+(1.0-dev)*160.0)
	var tickg:int=int(time*9.0)
	for i in grain:
		var gx:float=rect.position.x+rnd(i*3+tickg*17)*rect.size.x
		var gy:float=rect.position.y+rnd(i*5+tickg*31+9)*rect.size.y
		var br:float=0.55+0.45*rnd(i*7+tickg)
		ci.draw_rect(Rect2(gx,gy,1.8,1.8),Color(0.7*br,0.9*br,0.88*br,0.16))
	# Low resolution shows as blocky bands rather than a number.
	if sharp<0.3:
		var bands:int=int((0.3-sharp)*40.0)
		for i in bands:
			var by:float=rect.position.y+rnd(i*19+tickg*5)*rect.size.y
			ci.draw_rect(Rect2(rect.position.x,by,rect.size.x,2.0+rnd(i)*4.0),Color(0.5,0.7,0.68,0.06))
	var y:float=rect.position.y
	while y<rect.end.y:
		ci.draw_line(Vector2(rect.position.x,y),Vector2(rect.end.x,y),Color(0,0.02,0.04,0.1),1)
		y+=4
	# Vignette.
	var edge:=Color(0,0,0,0.5);var clear:=Color(0,0,0,0)
	var v:float=rect.size.x*0.22
	ci.draw_polygon(PackedVector2Array([rect.position,Vector2(rect.position.x+v,rect.position.y),Vector2(rect.position.x+v,rect.end.y),Vector2(rect.position.x,rect.end.y)]),PackedColorArray([edge,clear,clear,edge]))
	ci.draw_polygon(PackedVector2Array([Vector2(rect.end.x-v,rect.position.y),Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.end.x-v,rect.end.y)]),PackedColorArray([clear,edge,edge,clear]))
	var vy:float=rect.size.y*0.18
	ci.draw_polygon(PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),Vector2(rect.end.x,rect.position.y+vy),Vector2(rect.position.x,rect.position.y+vy)]),PackedColorArray([edge,edge,clear,clear]))
	ci.draw_polygon(PackedVector2Array([Vector2(rect.position.x,rect.end.y-vy),Vector2(rect.end.x,rect.end.y-vy),rect.end,Vector2(rect.position.x,rect.end.y)]),PackedColorArray([clear,clear,edge,edge]))
static func _frame_chrome(ci:CanvasItem,rect:Rect2,vm:Dictionary,font:Font,font_size:int,dev:float)->void:
	var bracket:float=14.0;var bc=Color(PHOSPHOR,0.8)
	for corner in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
		var sx:float=1.0 if corner.x<rect.get_center().x else -1.0
		var sy:float=1.0 if corner.y<rect.get_center().y else -1.0
		ci.draw_line(corner,corner+Vector2(sx*bracket,0),bc,2)
		ci.draw_line(corner,corner+Vector2(0,sy*bracket),bc,2)
	var horizon:float=rect.position.y+rect.size.y*0.5
	if bool(vm.get("live",false)):
		var mid:Vector2=Vector2(rect.get_center().x,horizon)
		ci.draw_line(mid-Vector2(12,0),mid-Vector2(4,0),PHOSPHOR,1.5);ci.draw_line(mid+Vector2(4,0),mid+Vector2(12,0),PHOSPHOR,1.5)
		ci.draw_line(mid-Vector2(0,12),mid-Vector2(0,4),PHOSPHOR,1.5);ci.draw_line(mid+Vector2(0,4),mid+Vector2(0,12),PHOSPHOR,1.5)
	if absf(float(vm.get("u",0.0)))>1.0:
		var way:float=signf(float(vm.u));var ex:float=rect.end.x-18.0 if way>0 else rect.position.x+18.0
		ci.draw_colored_polygon(PackedVector2Array([Vector2(ex+way*8,horizon),Vector2(ex-way*6,horizon-10),Vector2(ex-way*6,horizon+10)]),AMBER)
		ci.draw_string(font,Vector2(rect.get_center().x-40,rect.position.y+rect.size.y*0.2),"TURNING ONTO SUBJECT",HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(10,font_size-2),AMBER)
	if vm.get("usable",true)==false:
		ci.draw_string(font,rect.position+Vector2(8,rect.size.y*0.5),"UNUSABLE FRAME",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size+2,Color("e08a73"))
	if dev<1.0:
		ci.draw_string(font,rect.position+Vector2(8,rect.size.y-8-font_size),"DEVELOPING %d%%"%roundi(dev*100),HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(10,font_size-3),AMBER)
	var info:="%dm  ASPECT %d°  %s%s%s"%[roundi(float(vm.dist)),roundi(rad_to_deg(float(vm.aspect))),str(vm.mode).to_upper(),"  FLASH" if vm.flash else "","  THERMAL" if vm.get("thermal",false) else ""]
	ci.draw_string(font,Vector2(rect.position.x+8,rect.end.y-6),info,HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(10,font_size-2),PHOSPHOR)
