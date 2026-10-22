extends RefCounted
# Reconnaissance photography. A frame is computed from where a craft is, how it
# is oriented, what its optics can resolve and what it chose to frame. Nothing
# here changes combat, beams, collision or detection: it only reads them, and a
# photograph can only contain what the craft could legitimately see.
#
# A photographic objective carries a `subject`:
#   facing   direction the subject's front points (radians)
#   size     width in metres across the frame
#   glow     self light 0..1
#   required feature ids that must resolve for the exposure to be usable
#   features [{id,label,bearing,arc,detail,lat,dwell,glow,need,window,intel,gloss}]
#     bearing/arc  aspect (from the subject's facing) the feature can be seen from
#     detail       sharpness the feature needs (0..1), fine detail needs TIGHT
#     lat          lateral position across the subject, -1..1
#     need         "" | "thermal" (imager, or very close) | "light"
#     window       [period, open, phase] seconds of the shared world clock
#     dwell        seconds of resolved exposure needed
# Observations are plain dictionaries and survive save, restore and archive.
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const Thermal=preload("res://src/simulation/thermal_front.gd")
const COLS:=36
const MAX_SHOTS:=24
const TURN_RATE:=1.8
const FLASH_CHARGES:=[4,2,2]
const STUDY:=1000
const MAX_STUDIES:=8
const SIREN_TYPES:=["patroller","hunter","sentinel","warden","sweeper","interceptor","buoy","relay"]

static func state(sim)->Dictionary:
	if not sim.mission.get("photo") is Dictionary:
		sim.mission["photo"]={"shots":[],"acc":{},"set":{},"next":1,"flash":FLASH_CHARGES.duplicate(),"paths":[],"studies":[]}
	return sim.mission.photo
# Read-only view: never writes into the mission, so drawing and context queries
# cannot change a snapshot. Writers use state().
static func peek(sim)->Dictionary:
	if sim.mission.get("photo") is Dictionary:return sim.mission.photo
	return {"shots":[],"acc":{},"set":{},"next":1,"flash":FLASH_CHARGES.duplicate(),"paths":[],"studies":[]}
# Objective addressing. Charted objectives keep their list index. Siren studies
# are not charted objectives: they live in photo.studies and are addressed at
# STUDY + n, so fixed-size objective checks of an operation never see them.
static func obj(sim,i:int)->Dictionary:
	if i>=STUDY:
		var studies:Array=peek(sim).get("studies",[])
		return studies[i-STUDY] if i-STUDY<studies.size() else {}
	return sim.mission.objectives[i]
static func index_of(sim,o:Dictionary)->int:
	var at:int=sim.mission.objectives.find(o)
	if at>=0:return at
	var studies:Array=peek(sim).get("studies",[])
	for n in studies.size():
		if is_same(studies[n],o) or studies[n]==o:return STUDY+n
	return -1
static func target_valid(mission:Dictionary,t:int)->bool:
	if t>=STUDY:return t-STUDY<mission.get("photo",{}).get("studies",[]).size()
	return t>=0 and t<mission.objectives.size()
static func target_in(mission:Dictionary,t:int)->Dictionary:
	return mission.photo.studies[t-STUDY] if t>=STUDY else mission.objectives[t]
static func applies(o:Dictionary)->bool:
	return o.get("subject") is Dictionary and not o.subject.is_empty()
static func default_subject(facing:float=0.0,size:float=70.0)->Dictionary:
	return {"facing":facing,"size":size,"glow":0.0,"required":["overview"],"features":[{"id":"overview","label":"SUBJECT","bearing":0.0,"arc":3.2,"detail":0.06,"lat":0.0,"dwell":1.0}]}
static func siren_subject(s:Dictionary)->Dictionary:
	var type:String=s.get("type","patroller")
	return {"facing":float(s.get("angle",0.0)),"size":56.0,"glow":0.1,"live":true,"type":type,"required":["form"],"features":[
		{"id":"form","label":"BODY","bearing":0.0,"arc":3.2,"detail":0.08,"lat":0.0,"dwell":1.0,"gloss":"Angular body, red-lit seams."},
		{"id":"array","label":"SENSOR ARRAY","bearing":0.0,"arc":0.9,"detail":0.42,"lat":-0.35,"dwell":1.5,"intel":"siren_"+type,"gloss":"A forward array, the part that listens."},
		{"id":"gait","label":"MOVEMENT","bearing":0.0,"arc":3.2,"detail":0.2,"lat":0.35,"dwell":6.0,"gloss":"Its movement over several seconds."}]}
# --- craft optics, settings and charges -------------------------------------
static func optics(sim,uid:int)->Dictionary:
	var fit:Dictionary=sim.mission.get("launch_equipment",{})
	var q=uid==0
	var o={"range":240.0,"fov":1.05 if q else 1.45,"res":1.0 if q else 0.82,"lamp":0.36 if q else 0.12,"gimbal":2.2 if q else 3.0,"blur":1.0,"thermal":false,"flash":false,"integrate":0.0,"sweet":0.35 if q else 0.28}
	if Equipment.has(fit,uid,"quietus_tele_lens"):
		o.range*=1.5;o.fov=0.58;o.blur=1.7;o.sweet=0.42
	if Equipment.has(fit,uid,"photo_flash"):o.flash=true
	if Equipment.has(fit,uid,"thermal_imager"):
		o.thermal=true;o.res*=0.85
	if Equipment.has(fit,uid,"low_light_back"):o.integrate=0.42
	return o
static func settings(sim,uid:int)->Dictionary:
	var st=peek(sim)
	return st.set[uid] if st.set.has(uid) else {"mode":"wide","flash":false,"focus":""}
static func _writable_settings(sim,uid:int)->Dictionary:
	var st=state(sim)
	if not st.set.has(uid):st.set[uid]={"mode":"wide","flash":false,"focus":""}
	return st.set[uid]
static func reach(sim,uid:int,o:Dictionary=Dictionary())->float:
	return float(optics(sim,uid).range)
static func flash_left(sim,uid:int)->int:
	var charges=peek(sim).flash
	return int(charges[uid]) if uid>=0 and uid<charges.size() else 0
# Player framing choices, spent nothing until an exposure begins.
static func set_frame(sim,uid:int,args:Dictionary)->bool:
	var cfg=_writable_settings(sim,uid);var op=optics(sim,uid)
	if args.has("mode"):
		if args.mode not in ["wide","tight"]:return false
		cfg.mode=args.mode
	if args.has("flash"):
		if bool(args.flash) and not op.flash:return false
		cfg.flash=bool(args.flash)
	if args.has("focus"):cfg.focus=str(args.focus)
	if args.get("cycle_focus",false):
		var ids=[]
		var o=_focus_subject(sim,uid)
		for f in o.get("features",[]):ids.append(f.id)
		if not ids.is_empty():cfg.focus=ids[(ids.find(cfg.focus)+1)%ids.size()]
	return true
static func _focus_subject(sim,uid:int)->Dictionary:
	var ctx=sim.camera_context() if uid==sim.selected else {}
	var t=int(ctx.get("target",-1))
	if t==-2:return siren_subject(sim.sirens[int(ctx.siren)])
	if t>=0 and t<sim.mission.objectives.size() and applies(sim.mission.objectives[t]):return sim.mission.objectives[t].subject
	return {}
# --- the frame ---------------------------------------------------------------
static func _window(f:Dictionary,clock:float)->bool:
	if not f.has("window"):return true
	var w:Array=f.window
	return fposmod(clock+float(w[2]),float(w[0]))<float(w[1])
static func seen_before(sim,oi:int)->Array:
	var ids=[]
	for shot in peek(sim).shots:
		if int(shot.obj)==oi:
			for id in shot.features:
				if id not in ids:ids.append(id)
	return ids
static func frame(sim,uid:int,o:Dictionary,t:float=0.0,with_view:bool=false)->Dictionary:
	var u=sim.units[uid];var s:Dictionary=o.subject;var op=optics(sim,uid);var cfg=settings(sim,uid)
	var pos:Vector2=o.pos;var dist:float=u.pos.distance_to(pos)
	var bearing:float=u.pos.angle_to_point(pos)
	var off:float=angle_difference(u.angle,bearing)
	var pivot:float=maxf(0.0,absf(off)-float(op.gimbal))
	var aim:float=bearing if pivot<=0.0 else u.angle+signf(off)*float(op.gimbal)
	var tight:bool=cfg.mode=="tight"
	var fov:float=float(op.fov)*(0.5 if tight else 1.0)
	var aspect:float=angle_difference(float(s.get("facing",0.0)),(u.pos-pos).angle())
	# Light: dark water, own lamp, flash, glow of the subject and low-light film.
	var depth_dark:float=clampf(float(sim.mission.get("depth",2000))/4800.0,0.0,1.0)
	var ambient:float=(0.16-0.12*depth_dark)*(0.55 if sim.mission.get("darkness",false) else 1.0)
	var lamp:float=float(op.lamp)/(1.0+pow(dist/110.0,2.0))
	var flashing:bool=bool(cfg.flash) and bool(op.flash) and flash_left(sim,uid)>0
	var flash:float=0.75/(1.0+pow(dist/170.0,2.0)) if flashing else 0.0
	var light:float=clampf(ambient+lamp+flash+float(s.get("glow",0.0)),0.0,1.0)
	var speed:float=u.vel.length()
	var steady:float=clampf(1.0-speed/(14.0/float(op.blur)),0.25,1.0)
	if float(op.integrate)>0.0 and steady>0.85:light=clampf(light+float(op.integrate)*minf(t,8.0)/8.0,0.0,1.0)
	# Water: distance haze, plus shimmer where the line crosses a thermal front.
	var turbidity:float=float(sim.mission.get("turbidity",0.0016))
	var clarity:float=exp(-turbidity*dist)
	var shimmer:float=1.0
	if sim.mission.get("thermal_revision",0)==1 and not op.thermal:
		shimmer=lerpf(1.0,Thermal.transmission(PackedVector2Array([u.pos,pos]),sim.mission.thermal_fronts),0.85)
	var r_opt:float=float(op.range)*float(op.sweet)
	var res:float=clampf(1.0-maxf(0.0,dist-r_opt)/maxf(1.0,float(op.range)*1.05-r_opt),0.0,1.0)*float(op.res)
	if tight:res=minf(1.1,res*1.3)
	var sharp:float=clampf(res*(0.3+0.7*clampf(light/0.55,0.0,1.0))*(0.45+0.55*clarity)*shimmer*steady,0.0,1.0)
	# Features: what this exact viewpoint, frame and moment can resolve.
	var feats:Array=s.get("features",[])
	var focus:String=str(cfg.focus)
	if tight and (focus.is_empty() or not feats.any(func(f):return f.id==focus)):
		var oi=index_of(sim,o);var done=seen_before(sim,oi)
		for f in feats:
			if f.id not in done:focus=f.id;break
		if focus.is_empty() and not feats.is_empty():focus=feats[0].id
	var size:float=float(s.get("size",70.0));var half:float=fov*dist*0.5
	var center:float=0.0
	if tight:
		for f in feats:
			if f.id==focus:center=float(f.get("lat",0.0))*size*0.5
	var rows:Array=[]
	for f in feats:
		var x:float=float(f.get("lat",0.0))*size*0.5-center
		var inframe:bool=absf(x)<=half
		var side:bool=absf(angle_difference(aspect,float(f.get("bearing",0.0))))<=float(f.get("arc",PI))
		var detail:float=float(f.get("detail",0.1))
		var need:String=str(f.get("need",""))
		var why:String=""
		var local:float=clampf(sharp+float(f.get("glow",0.0))*0.35,0.0,1.0)
		if need=="thermal":
			if op.thermal:local=clampf(res*steady+0.2,0.0,1.0)
			elif dist>=90.0:why="HEAT SHIMMER · needs a thermal imager or close approach"
		elif need=="light" and light<0.35:why="TOO DARK · add light or close in"
		if not inframe:why="CROPPED"
		elif not side:why="HIDDEN"
		elif why.is_empty() and tight and f.id!=focus:why="OUT OF FOCUS"
		elif why.is_empty() and not tight and detail>0.6:why="FINE DETAIL · use a TIGHT frame"
		elif why.is_empty() and not _window(f,sim.elapsed):why="WAITING FOR ITS CYCLE"
		elif why.is_empty() and local<detail:why="TOO SOFT · closer, lit or still"
		var ready:bool=why.is_empty()
		rows.append({"id":f.id,"label":f.label,"art":str(f.get("art","")),"y":float(f.get("y",0.4)),"ready":ready,"why":why,"apparent":inframe and side,"x":x/maxf(half,1.0),"q":clampf((local-detail*0.6)/(1.0-detail*0.6),0.0,1.0) if ready else 0.0,"dwell":float(f.get("dwell",1.2))})
	var result={"unit":uid,"craft":u.name,"dist":dist,"bearing":bearing,"off":off,"aim":aim,"pivot":pivot,"aspect":aspect,"fov":fov,"mode":cfg.mode,"focus":focus,"flash":flashing,"light":light,"clarity":clarity,"shimmer":shimmer,"sharp":sharp,"steady":steady,"res":res,"range":op.range,"in_range":dist<=float(op.range),"rows":rows,"size":size,"facing":float(s.get("facing",0.0)),"heading":u.angle,"pos":u.pos,"glow":float(s.get("glow",0.0)),"depth":depth_dark,"thermal":bool(op.thermal)}
	if with_view:result["cols"]=view(sim,u.pos,aim,fov,float(op.range)*1.25)
	return result
# One-dimensional depth profile of the real terrain across the frame.
static func view(sim,origin:Vector2,aim:float,fov:float,far:float)->Array:
	var cols:Array=[]
	var shapes:Array=sim.rock_shapes.duplicate();var bounds:Array=sim.rock_bounds.duplicate()
	for rect in sim.Depth.structures(sim,sim.geometry_band):
		shapes.append(PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]));bounds.append(rect)
	for i in COLS:
		var a:float=aim+(float(i)/(COLS-1)-0.5)*fov
		var end:Vector2=origin+Vector2.from_angle(a)*far
		var box:=Rect2(Vector2(minf(origin.x,end.x),minf(origin.y,end.y)),Vector2(absf(end.x-origin.x),absf(end.y-origin.y))).grow(2.0)
		var best:float=far
		for n in shapes.size():
			if not box.intersects(bounds[n]):continue
			var poly:PackedVector2Array=shapes[n]
			for k in poly.size():
				var hit=Geometry2D.segment_intersects_segment(origin,end,poly[k],poly[(k+1)%poly.size()])
				if hit!=null:best=minf(best,origin.distance_to(hit))
		cols.append(roundi(best/far*99.0))
	return cols
# --- exposure ----------------------------------------------------------------
static func begin(sim,uid:int,oi:int)->void:
	var st=state(sim);var o=obj(sim,oi);var cfg=settings(sim,uid)
	st.acc[uid]={"obj":oi,"t":0.0,"sharp":0.0,"dwell":{},"fq":{},"path":[],"flash":false,"clock":0.0}
	if bool(cfg.flash) and optics(sim,uid).flash and flash_left(sim,uid)>0:
		st.flash[uid]=int(st.flash[uid])-1;st.acc[uid].flash=true
static func noise_radius(sim,uid:int)->float:
	var acc=peek(sim).acc.get(uid,{})
	return 760.0 if acc.get("flash",false) else 520.0
# Advances one step. False while the craft is still turning onto the subject.
static func tick(sim,uid:int,o:Dictionary,dt:float)->bool:
	var st=state(sim);var u=sim.units[uid];var oi=index_of(sim,o)
	var acc:Dictionary=st.acc.get(uid,{})
	if acc.is_empty() or int(acc.obj)!=oi:
		begin(sim,uid,oi);acc=st.acc[uid]
	if o.has("siren") and int(o.siren)<sim.sirens.size():o.pos=sim.sirens[o.siren].pos;o.subject.facing=float(sim.sirens[o.siren].angle)
	var f=frame(sim,uid,o,acc.t)
	if f.pivot>0.0:
		u.angle=rotate_toward(u.angle,f.bearing,TURN_RATE*dt)
		return false
	acc.t+=dt;acc.sharp+=f.sharp*dt;acc.clock+=dt
	for r in f.rows:
		if r.ready:
			acc.dwell[r.id]=float(acc.dwell.get(r.id,0.0))+dt
			acc.fq[r.id]=maxf(float(acc.fq.get(r.id,0.0)),r.q)
	if o.has("siren") and acc.clock>=1.0:
		acc.clock-=1.0;acc.path.append([snappedf(o.pos.x,0.1),snappedf(o.pos.y,0.1)])
	st.acc[uid]=acc
	return true
static func progress_text(sim,uid:int,o:Dictionary)->String:
	var f=frame(sim,uid,o,float(peek(sim).acc.get(uid,{}).get("t",0.0)))
	if f.pivot>0.0:return "TURNING onto subject · %d° off"%roundi(rad_to_deg(f.pivot))
	return "SHARP %d%% · LIGHT %d%% · CLARITY %d%%"%[roundi(f.sharp*100),roundi(f.light*100),roundi(f.clarity*100)]
# Resolves the exposure: appends a structured observation and updates the objective.
static func finish(sim,uid:int,o:Dictionary)->Dictionary:
	var st=state(sim);var acc:Dictionary=st.acc.get(uid,{});var oi=index_of(sim,o)
	var f=frame(sim,uid,o,float(acc.get("t",0.0)),true)
	var s:Dictionary=o.subject;var seen:Array=[];var fq:Dictionary={};var intel:Dictionary={};var marks:Array=[]
	var dwell:Dictionary=acc.get("dwell",{})
	for i in f.rows.size():
		var r=f.rows[i];var feat:Dictionary=s.features[i]
		var held:bool=float(dwell.get(r.id,0.0))>=float(feat.get("dwell",1.2)) and float(acc.get("fq",{}).get(r.id,0.0))>0.0
		if held:
			seen.append(r.id);fq[r.id]=snappedf(float(acc.fq[r.id]),0.01)
			if feat.has("intel") and float(acc.fq[r.id])>=0.3:intel[str(feat.intel)]=snappedf(float(acc.fq[r.id]),0.01)
			marks.append({"id":r.id,"x":snappedf(r.x,0.01),"q":fq[r.id],"label":r.label,"art":r.art,"y":snappedf(r.y,0.01)})
		elif r.apparent:
			marks.append({"id":r.id,"x":snappedf(r.x,0.01),"q":0.0,"label":"","art":"","y":snappedf(r.y,0.01)})
	var required:Array=s.get("required",[])
	var usable:bool=required.all(func(id):return id in seen) if not required.is_empty() else not seen.is_empty()
	if f.mode=="tight" and str(f.focus) in seen:usable=true
	var mean_sharp:float=float(acc.get("sharp",0.0))/maxf(float(acc.get("t",0.0)),0.001)
	var total:float=float(s.features.size())
	var gained:float=0.0
	for id in seen:gained+=float(fq[id])
	var coverage:float=gained/maxf(1.0,1.0 if f.mode=="tight" else total)
	var quality:float=clampf(mean_sharp*0.55+minf(1.0,coverage)*0.45,0.0,1.0) if usable else clampf(mean_sharp*0.3,0.0,0.4)
	var shot={"id":int(st.next),"op":int(sim.mission.id),"obj":oi,"key":str(o.get("optical",o.get("site_id",oi))),"name":str(o.name),"unit":uid,"craft":str(f.craft),"pos":[snappedf(f.pos.x,0.1),snappedf(f.pos.y,0.1)],"heading":snappedf(f.heading,0.01),"dist":snappedf(f.dist,0.1),"aspect":snappedf(f.aspect,0.01),"mode":f.mode,"flash":f.flash,"q":snappedf(quality,0.01),"sharp":snappedf(mean_sharp,0.01),"light":snappedf(f.light,0.01),"clarity":snappedf(f.clarity,0.01),"shimmer":snappedf(f.shimmer,0.01),"features":seen,"fq":fq,"intel":intel,"usable":usable,"time":snappedf(sim.elapsed,0.1),"frame":{"fov":snappedf(f.fov,0.01),"aim":snappedf(f.aim,0.01),"cols":f.cols,"marks":marks,"size":s.get("size",70.0),"dist":snappedf(f.dist,1.0),"facing":snappedf(f.facing,0.01),"aspect":snappedf(f.aspect,0.01),"bearing":snappedf(f.bearing,0.01),"glow":snappedf(f.glow,0.01),"seed":int(st.next)*7919%1000,"kind":"siren" if o.has("siren") else "site","depth":snappedf(f.depth,0.01),"thermal":f.thermal}}
	if o.has("siren"):
		shot["path"]=acc.get("path",[]);shot["siren"]=int(o.siren);shot["type"]=str(sim.sirens[o.siren].get("type","patroller"));shot["mode_seen"]=str(sim.sirens[o.siren].get("mode",""))
		if shot.path.size()>=4:st.paths.append({"siren":int(o.siren),"pts":shot.path.duplicate(),"time":sim.elapsed})
	st.next=int(st.next)+1
	st.shots.append(shot)
	while st.shots.size()>MAX_SHOTS:st.shots.remove_at(_weakest(st.shots))
	st.acc.erase(uid)
	if usable:
		# The record's grade rewards the sharpest frame and how much of the subject
		# the whole set of frames has shown: circling a target improves its record.
		var best_sharp:float=0.0;var union:Dictionary={}
		for other in st.shots:
			if int(other.obj)!=oi or not other.usable:continue
			best_sharp=maxf(best_sharp,float(other.sharp))
			for id in other.fq:union[id]=maxf(float(union.get(id,0.0)),float(other.fq[id]))
		var union_gain:float=0.0
		for id in union:union_gain+=float(union[id])
		var record_quality:float=clampf(best_sharp*0.55+minf(1.0,union_gain/maxf(1.0,total))*0.45,0.0,1.0)
		if float(o.get("photo_quality",0.0))<record_quality:
			o["photo_quality"]=record_quality;o["photo_craft"]=f.craft;o["photo_distance"]=f.dist
		var reveal=str(s.get("reveal",""))
		if not reveal.is_empty() and o.get("unknown",false):
			o.name=reveal;o.erase("unknown")
		var glosses=[]
		for i in s.features.size():
			if s.features[i].id in seen and s.features[i].has("gloss"):glosses.append(str(s.features[i].gloss))
		if o.has("siren"):o["optical"]="siren_"+str(shot.type);o["evidence"]="%s observed at %dm, %s. %s"%[str(shot.type).capitalize(),roundi(f.dist),"flash lit" if f.flash else "own lamp",". ".join(glosses)]
		elif not glosses.is_empty():
			var base=str(o.get("evidence_base",o.get("evidence","")))
			o["evidence_base"]=base;o["evidence"]=(base+" " if not base.is_empty() else "")+" ".join(glosses)
	return {"usable":usable,"shot":shot}
static func _weakest(shots:Array)->int:
	var worst:=0;var score:=INF
	for i in shots.size():
		var v:float=float(shots[i].q)+float(i)*0.002
		if v<score:score=v;worst=i
	return worst
static func missing_text(f:Dictionary,s:Dictionary)->String:
	var parts=[]
	for r in f.rows:
		if r.apparent and not r.ready and not r.why.is_empty() and r.id in s.get("required",[]):parts.append("%s: %s"%[r.label,r.why.to_lower()])
	return "; ".join(parts) if not parts.is_empty() else "the frame did not resolve the subject"
# --- discovery ---------------------------------------------------------------
# Unnamed phenomena are not objectives until a craft's own forward camera sees
# them. Craft heading, clear water and the sight distance decide.
static func discover(sim)->void:
	var hidden:Array=sim.mission.get("photo_hidden",[])
	for h in hidden:
		if h.get("found",false):continue
		for uid in sim.units.size():
			var u=sim.units[uid]
			if not u.alive or u.band!=1 or not u.transition.is_empty():continue
			var op=optics(sim,uid)
			var sight:float=float(h.get("sight",170.0))*(0.65 if sim.mission.get("darkness",false) else 1.0)
			if u.pos.distance_to(h.pos)>sight:continue
			if absf(angle_difference(u.angle,u.pos.angle_to_point(h.pos)))>float(op.fov)*0.5+0.3:continue
			if not sim.Depth.clear(sim,u.pos,h.pos,1):continue
			h.found=true
			var o={"pos":h.pos,"name":str(h.get("seen_as","UNIDENTIFIED SHAPE")),"captured":false,"optional":true,"unknown":true,"kind":"","subject":h.subject.duplicate(true),"optical":h.key,"site_id":h.key,"evidence":str(h.get("evidence",""))}
			sim.mission.objectives.append(o)
			sim.message="%s sighted something ahead · %s · unidentified"%[u.name,"bearing %d"%roundi(fposmod(rad_to_deg(u.pos.angle_to_point(h.pos)),360.0))]
			sim.events.append({"type":"sighting","pos":h.pos})
			break
# Siren in clear view of the selected craft that can be framed.
static func siren_candidate(sim,uid:int)->int:
	var u=sim.units[uid];var best:=-1;var d:=INF
	for i in sim.sirens.size():
		var s=sim.sirens[i]
		if s.get("band",1)!=u.band or not s.get("transition",{}).is_empty():continue
		if not sim.contacts.has(i) or sim.elapsed-float(sim.contacts[i].time)>0.6 or not sim.contact_visible(s):continue
		var dist=u.pos.distance_to(s.pos)
		if dist<=reach(sim,uid) and dist<d and sim.Depth.clear(sim,u.pos,s.pos,u.band):best=i;d=dist
	return best
static func siren_objective(sim,i:int)->int:
	var st=state(sim)
	for n in st.studies.size():
		if st.studies[n].get("siren",-1)==i:return STUDY+n
	var s=sim.sirens[i];var type=str(s.get("type","patroller"))
	var study={"pos":s.pos,"name":"S%d %s"%[i+1,type.to_upper()],"captured":false,"optional":true,"kind":"","duration":8.0,"siren":i,"subject":siren_subject(s),"optical":"siren_"+type,"site_id":"siren_"+type,"evidence":""}
	if st.studies.size()>=MAX_STUDIES:st.studies.remove_at(0)
	st.studies.append(study)
	return STUDY+st.studies.size()-1
# --- records -----------------------------------------------------------------
static func shots_for(mission:Dictionary,key:String)->Array:
	return mission.get("photo",{}).get("shots",[]).filter(func(s):return s.key==key)
static func valid(mission:Dictionary)->bool:
	if not mission.has("photo"):return true
	var p=mission.photo
	if not p is Dictionary or not p.get("shots") is Array or p.shots.size()>MAX_SHOTS or not p.get("acc") is Dictionary or not p.get("set") is Dictionary:return false
	if not p.get("flash") is Array or p.flash.size()!=3 or not p.get("paths") is Array or p.paths.size()>32:return false
	if p.has("studies"):
		if not p.studies is Array or p.studies.size()>MAX_STUDIES:return false
		for study in p.studies:
			if not study is Dictionary or not study.has_all(["pos","name","captured","siren","subject"]) or not study.pos is Vector2 or not study.siren is int:return false
	for shot in p.shots:
		if not shot is Dictionary or not shot.has_all(["id","obj","key","q","features","frame"]) or not shot.frame is Dictionary or not shot.frame.get("cols") is Array or shot.frame.cols.size()!=COLS:return false
	return true

# The subject a craft would photograph next, for the live viewfinder.
static func preview(sim,uid:int)->Dictionary:
	if uid<0 or uid>=sim.units.size() or not sim.units[uid].alive or sim.units[uid].band!=1:return {}
	var ctx=sim.camera_context()
	var t=int(ctx.get("target",-1))
	if t==-2:
		var i=int(ctx.siren);var s=sim.sirens[i]
		return {"o":{"pos":s.pos,"name":"S%d %s"%[i+1,str(s.get("type","patroller")).to_upper()],"subject":siren_subject(s),"siren":i},"index":-2,"unit":uid,"ctx":ctx}
	if t>=0 and t<sim.mission.objectives.size() and applies(sim.mission.objectives[t]):
		var o=sim.mission.objectives[t]
		if sim.units[uid].pos.distance_to(o.pos)<=reach(sim,uid)*1.5:return {"o":o,"index":t,"unit":uid,"ctx":ctx}
	return {}
