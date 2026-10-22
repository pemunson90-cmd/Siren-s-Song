extends RefCounted
# What a resolved frame teaches. A finding is a plain observation the player can
# act on: a patrol loop, a gap between two loops, a guard post, a route, a cycle,
# a person, a hazard. It exists only when a frame resolved the feature that shows
# it, it is computed from the world as it is, and it reaches the chart and the
# archive as a mark. Findings never change combat, beams, collision or detection.
#   kind   loop | gap | post | route | cycle | person | hazard | weak | lane | note
#   text   one short line
#   pos/r  a point and radius, pts a polyline, cycle has period/open/phase
# Authored findings sit on a subject feature as `finding`: {kind,text,pos|off|pts,r}.
const MAX:=24
const BEHAVIOR={
	"patroller":"Walks a fixed circuit and turns toward noise it hears.",
	"hunter":"Follows real noise and sightings, then searches where it last heard you.",
	"sentinel":"Holds its post and returns to it after an investigation.",
	"warden":"Charges from received evidence: wait out the discharge or break its acquisition.",
	"sweeper":"Winds up before its beam; the warning gives a bearing and a count.",
	"interceptor":"A fast responder that holds its lane.",
	"buoy":"A passive listener that reports to a relay after a charge.",
	"relay":"Forwards stale reports to the nearest investigator."}
static func pt(v:Vector2)->Array:
	return [snappedf(v.x,0.1),snappedf(v.y,0.1)]
static func vec(a)->Vector2:
	return Vector2(float(a[0]),float(a[1]))
static func make(id:String,kind:String,text:String,q:float,op:int,shot:int,extra:Dictionary={})->Dictionary:
	var f={"id":id,"kind":kind,"text":text,"label":text.get_slice(" · ",0),"q":snappedf(q,0.01),"op":op,"shot":shot}
	f.merge(extra,true)
	return f
# Frames of a Siren: its loop from the gait, its post and behavior from the array.
static func from_siren(sim,shot:Dictionary,seen:Array,fq:Dictionary)->Array:
	var result:Array=[]
	var i:int=int(shot.siren)
	if i>=sim.sirens.size():return result
	var s:Dictionary=sim.sirens[i];var type:String=str(shot.type);var tag:="S%d"%(i+1)
	var op:int=int(shot.op);var sid:int=int(shot.id)
	if "gait" in seen:
		var points:Array=s.get("patrol_points",[])
		var q:float=float(fq.get("gait",0.0))
		if points.size()>=2 and q>=0.45:
			var loop:Array=points.map(func(p):return pt(p))
			loop.append(loop[0])
			result.append(make("loop_%d"%i,"loop","%s PATROL LOOP · %d turns"%[tag,points.size()],q,op,sid,{"pts":loop}))
			file(sim,[result.back()])
		elif shot.get("path",[]).size()>=3:
			result.append(make("loop_%d"%i,"loop","%s OBSERVED PATH · loop not yet clear"%tag,q,op,sid,{"pts":shot.path.duplicate(true)}))
		var gap:Dictionary=_gap(sim,i)
		if not gap.is_empty():result.append(make("gap","gap",gap.text,q,op,sid,{"pos":pt(gap.pos),"r":gap.r}))
	if "array" in seen:
		var text:String=str(BEHAVIOR.get(type,"Its behavior is recorded in the archive."))
		var extra:Dictionary={}
		if s.has("tether"):
			extra={"pos":pt(s.home),"r":float(s.tether)}
			text+=" Tethered %dm to this water."%roundi(float(s.tether))
		result.append(make("post_%d"%i,"post","%s %s · %s"%[tag,type.to_upper(),text],float(fq.get("array",0.0)),op,sid,extra))
	return result
# Clear water between two studied loops, at least GAP_MIN from both. Only loops the
# player has actually resolved count; an unstudied Siren is never consulted.
const GAP_MIN:=90.0
static func _gap(sim,latest:int)->Dictionary:
	var loops:Array=[]
	for f in sim.mission.get("photo",{}).get("findings",[]):
		if f.kind=="loop" and f.has("pts") and f.pts.size()>=3:loops.append(f)
	var mine:Array=sim.sirens[latest].get("patrol_points",[])
	if mine.size()<2:return {}
	var other:Array=[]
	for f in loops:
		if f.id!="loop_%d"%latest:other=f.pts.map(func(p):return vec(p))
	if other.is_empty():return {}
	var a:Array=mine;var best:=Vector2.ZERO;var score:=-1.0
	var mid:Vector2=Vector2.ZERO
	for p in a:mid+=p
	mid/=a.size()
	var mid2:Vector2=Vector2.ZERO
	for p in other:mid2+=p
	mid2/=other.size()
	var span:Vector2=(mid2-mid)
	for k in range(1,12):
		var p:Vector2=mid+span*float(k)/12.0
		if sim.blocked(p,40.0):continue
		var d:float=minf(_dist_loop(p,a),_dist_loop(p,other))
		if d>score:score=d;best=p
	if score<GAP_MIN:return {}
	return {"pos":best,"r":score,"text":"GAP between two studied loops · %dm clear of both"%roundi(score)}
static func _dist_loop(p:Vector2,pts:Array)->float:
	var d:float=INF
	for n in pts.size():
		var a:Vector2=pts[n];var b:Vector2=pts[(n+1)%pts.size()]
		d=minf(d,Geometry2D.get_closest_point_to_segment(p,a,b).distance_to(p))
	return d
# Findings authored on the features of a subject, for the features this frame held.
static func from_subject(o:Dictionary,s:Dictionary,seen:Array,fq:Dictionary,op:int,shot:int)->Array:
	var result:Array=[]
	for feat in s.get("features",[]):
		if not feat.has("finding") or feat.id not in seen:continue
		var spec:Dictionary=feat.finding;var q:float=float(fq.get(feat.id,0.0))
		if q<float(spec.get("min_q",0.3)):continue
		var extra:Dictionary={}
		var here:Vector2=o.pos
		if spec.has("pts"):extra["pts"]=spec.pts.map(func(p):return pt(p))
		if spec.has("pos"):extra["pos"]=pt(spec.pos)
		elif spec.has("off"):extra["pos"]=pt(here+spec.off)
		if spec.has("r"):extra["r"]=float(spec.r)
		if spec.has("period"):extra["period"]=float(spec.period);extra["open"]=float(spec.open);extra["phase"]=float(spec.get("phase",0.0))
		if not extra.has("pos") and not extra.has("pts"):extra["pos"]=pt(here)
		result.append(make("%s:%s"%[str(o.get("optical",o.get("site_id","x"))),feat.id],str(spec.kind),str(spec.text),q,op,shot,extra))
	return result
# Files findings with the mission, keeping the sharper copy of each.
static func file(sim,list:Array)->void:
	var st=sim.mission.photo
	if not st.has("findings"):st["findings"]=[]
	for f in list:
		var at:=-1
		for n in st.findings.size():
			if st.findings[n].id==f.id:at=n
		if at>=0:
			if float(st.findings[at].q)<float(f.q):st.findings[at]=f
		else:st.findings.append(f)
	while st.findings.size()>MAX:st.findings.remove_at(0)
static func valid_list(list)->bool:
	if not list is Array or list.size()>MAX:return false
	for f in list:
		if not f is Dictionary or not f.has_all(["id","kind","text","q"]) or not f.id is String or not f.kind is String or not f.text is String:return false
		if not (f.q is float or f.q is int):return false
		if f.has("pos") and not (f.pos is Array and f.pos.size()==2):return false
		if f.has("pts"):
			if not f.pts is Array or f.pts.size()>40:return false
			for p in f.pts:
				if not p is Array or p.size()!=2:return false
	return true
