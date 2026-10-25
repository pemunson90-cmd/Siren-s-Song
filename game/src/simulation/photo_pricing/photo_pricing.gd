extends RefCounted
# PRICED SHOTS: what a photograph costs. Read-mostly pricing for the camera:
# finite film, "how far can I stand and still resolve it", "who hears the
# shutter and when do they arrive", the three prices of light, and the clock a
# timed feature runs on. It never changes combat, beams, collision, damage,
# hull, or what a Siren sees or hears; it reads those rules and reports them.
#
# COORDINATED SEAMS (original standalone removal list, not a runtime off switch):
# Keep shared APIs, optional-field validation and tests while later audio/depth consumers
# depend on them. Review those consumers before a coordinated behavioral revert.
#   photo_capture.gd     begin():  Pricing.spend(sim,uid)        film spent when an exposure starts
#   photo_capture.gd     valid():  Pricing.valid(mission)        optional save field check
#   simulation.gd        camera_context(): Pricing.annotate(...)  out-of-film gate and film tag
#   operation_catalog.gd after PhotoOps.apply: PricingData.apply(m,id)   ops 0 to 5 data pass
#   onboarding_text.gd   HINTS entries priced_*  (ids keep the priced_ prefix; valid_seen allows the prefix)
#   onboarding_hints.gd  _wanted()/refresh(): PricingHints.wanted()/stale()
#   camera_feed.gd       _draw_photo(): PricingOverlay.draw_viewfinder(...)
#   ocean_view.gd        _draw(): PricingOverlay.draw_chart(...)
#   main.gd              _briefing(): PricingBriefing line
# Band: the shutter ring and the "if heard" estimate read photo_depth (BandPhoto.ring / hear_scale); remove those
# reads with that module and the fixed 520 m and 760 m in photo_pricing_table.gd apply again.
# Save: mission.photo_pricing = {"film":[q,d,d]} is optional. Absent means full
# film, and a build without this module ignores the key.
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const BandPhoto=preload("res://src/photo_depth/band_photo.gd")
const BandHint=preload("res://src/photo_depth/band_hint.gd")

# --- film ----------------------------------------------------------------------
static func cap(uid:int)->int:
	return int(Table.FILM[uid]) if uid>=0 and uid<Table.FILM.size() else 0
static func film_left(sim,uid:int)->int:
	var p=sim.mission.get("photo_pricing")
	if p is Dictionary and p.get("film") is Array and uid>=0 and uid<p.film.size():return int(p.film[uid])
	return cap(uid)
static func film_used(sim)->int:
	var used:=0
	for uid in Table.FILM.size():used+=cap(uid)-film_left(sim,uid)
	return used
# Called when an exposure starts. Spends one film; never goes below zero.
static func spend(sim,uid:int)->void:
	if uid<0 or uid>=Table.FILM.size():return
	var left:int=film_left(sim,uid)
	var p:Dictionary=sim.mission.get("photo_pricing") if sim.mission.get("photo_pricing") is Dictionary else {}
	var film:Array=p.get("film",Table.FILM.duplicate()).duplicate()
	for n in Table.FILM.size():
		if film.size()<=n:film.append(cap(n))
	film[uid]=maxi(0,left-1)
	sim.mission["photo_pricing"]={"film":film}
static func valid(mission:Dictionary)->bool:
	if not mission.has("photo_pricing"):return true
	var p=mission.photo_pricing
	if not p is Dictionary or not p.get("film") is Array or p.film.size()!=Table.FILM.size():return false
	for n in Table.FILM.size():
		if not p.film[n] is int or p.film[n]<0 or p.film[n]>99:return false
	return true
static func is_subject(sim,ctx:Dictionary)->bool:
	var t=int(ctx.get("target",-1))
	if t==-2:return true
	return t>=0 and t<sim.mission.objectives.size() and sim.Photo.applies(sim.mission.objectives[t])
# Wraps the base camera context: no film means no exposure, and the film count rides on the ready text.
static func annotate(sim,ctx:Dictionary)->Dictionary:
	if not ctx.get("ready",false) or not is_subject(sim,ctx):return ctx
	var left:int=film_left(sim,sim.selected)
	if left<=0:
		ctx["ready"]=false;ctx["text"]=Table.TEXT.film_out
	else:ctx["text"]=str(ctx.get("text",""))+" · "+Table.TEXT.film_tag%[left,cap(sim.selected)]
	return ctx

# --- trial frames --------------------------------------------------------------
# A pure what-if: the same frame the camera would compute, with the craft held
# still at `dist` from the subject on its present side, aimed at it, optionally
# with the flash and after `hold` seconds. The craft and settings are put back.
static func probe(sim,uid:int,o:Dictionary,dist:float,flash:bool,hold:float)->Dictionary:
	var real=sim.units[uid]
	var away:Vector2=real.pos-o.pos
	var dir:Vector2=away.normalized() if away.length()>1.0 else Vector2.RIGHT
	var trial=real.duplicate()
	trial.pos=o.pos+dir*dist;trial.vel=Vector2.ZERO;trial.angle=trial.pos.angle_to_point(o.pos)
	var had_photo:bool=sim.mission.get("photo") is Dictionary
	var cfg:Dictionary=sim.Photo.settings(sim,uid)
	var swap:bool=bool(cfg.flash)!=flash
	var had_cfg:bool=false;var old_flash:bool=false
	if swap:
		var st=sim.Photo.state(sim)
		had_cfg=st.set.has(uid)
		if not had_cfg:st.set[uid]={"mode":"wide","flash":false,"focus":""}
		old_flash=bool(st.set[uid].flash);st.set[uid].flash=flash
	sim.units[uid]=trial
	var f:Dictionary=sim.Photo.frame(sim,uid,o,hold)
	sim.units[uid]=real
	if swap:
		var st=sim.mission.photo
		if had_cfg:st.set[uid].flash=old_flash
		else:st.set.erase(uid)
		if not had_photo:sim.mission.erase("photo")
	return f
static func _row(f:Dictionary,fid:String)->Dictionary:
	for r in f.rows:
		if r.id==fid:return r
	return {}
static func _resolves(r:Dictionary)->bool:
	return not r.is_empty() and (r.ready or str(r.why).begins_with("WAITING"))
# Largest standoff at which the feature would resolve, 0 if never.
static func reach_of(sim,uid:int,o:Dictionary,fid:String,flash:bool)->float:
	var d:float=float(sim.Photo.optics(sim,uid).range)
	while d>=Table.SCAN_MIN:
		if _resolves(_row(probe(sim,uid,o,d,flash,0.0),fid)):return d
		d-=Table.SCAN_STEP
	return 0.0

# --- the readout ---------------------------------------------------------------
static var _cache:Dictionary={}
static var _cache_owner:int=0
# Pure read for the viewfinder and the chart. Cached for CACHE_STEP seconds of
# sim time and a few metres of craft movement.
static func readout(sim,uid:int,o:Dictionary)->Dictionary:
	if uid<0 or uid>=sim.units.size():return {}
	if _cache_owner!=sim.get_instance_id():_cache.clear();_cache_owner=sim.get_instance_id()
	var u=sim.units[uid];var cfg:Dictionary=sim.Photo.settings(sim,uid)
	var key="%d|%s|%d|%d|%d|%s|%s|%s|%d|%d"%[uid,str(o.get("name","")),int(u.pos.x/Table.CACHE_POS),int(u.pos.y/Table.CACHE_POS),int(sim.elapsed/Table.CACHE_STEP),cfg.mode,str(cfg.flash),str(cfg.focus),film_left(sim,uid),int(u.band)]
	if _cache.has(key):return _cache[key]
	if _cache.size()>48:_cache.clear()
	var result:Dictionary=_compute(sim,uid,o,cfg)
	_cache[key]=result
	return result
static func _compute(sim,uid:int,o:Dictionary,cfg:Dictionary)->Dictionary:
	var op=sim.Photo.optics(sim,uid);var u=sim.units[uid]
	var s:Dictionary=o.get("subject",{})
	var f:Dictionary=sim.Photo.frame(sim,uid,o,0.0)
	var oi:int=sim.Photo.index_of(sim,o)
	var done:Array=sim.Photo.seen_before(sim,oi) if oi>=0 else []
	var lines:Array=[];var out={"film":film_left(sim,uid),"cap":cap(uid),"lines":lines,"light":false,"key":"","plain":0.0,"flash":0.0,"hidden":false,"heard":BandPhoto.ring(sim,uid,false)}
	var flash_ok:bool=bool(op.flash) and sim.Photo.flash_left(sim,uid)>0
	var flashing:bool=bool(cfg.flash) and flash_ok
	# The shutter ring is read from the craft's band (photo_depth), not fixed at 520 m.
	var ring_plain:float=BandPhoto.ring(sim,uid,false);var ring_flash:float=BandPhoto.ring(sim,uid,true)
	out.heard=ring_flash if flashing else ring_plain
	# Key feature: the finest detail not yet on film; a feature that is dark or soft takes the light block.
	var key:Dictionary={};var dark:Dictionary={}
	for i in s.get("features",[]).size():
		var feat:Dictionary=s.features[i];var r:Dictionary=f.rows[i]
		if feat.id in done and not o.get("unknown",false):continue
		if key.is_empty() or float(feat.get("detail",0.0))>float(key.get("detail",0.0)):key=feat
		if dark.is_empty() and r.apparent and not r.ready:
			for reason in Table.LIGHT_REASONS:
				if str(r.why).begins_with(reason):dark=feat
	var heard:String=_heard(sim,u,float(out.heard))
	if not dark.is_empty():
		out.light=true;out.key=str(dark.label)
		var d:float=f.dist
		var flash_row:Dictionary=_row(probe(sim,uid,o,d,true,0.0),dark.id) if flash_ok else {}
		if flash_ok:lines.append({"text":Table.TEXT.light_flash%[Table.TEXT.ok if _resolves(flash_row) else Table.TEXT.short,roundi(ring_flash),sim.Photo.flash_left(sim,uid)],"warn":false})
		else:lines.append({"text":Table.TEXT.light_flash_none,"warn":true})
		if float(op.integrate)>0.0:
			var wait_row:Dictionary=_row(probe(sim,uid,o,d,flashing,Table.STILL_HOLD),dark.id)
			lines.append({"text":Table.TEXT.light_wait%[roundi(Table.STILL_HOLD),Table.TEXT.ok if _resolves(wait_row) else Table.TEXT.short,roundi(ring_plain)],"warn":false})
		else:lines.append({"text":Table.TEXT.light_wait_none,"warn":true})
		var close:float=reach_of(sim,uid,o,str(dark.id),false)
		out.plain=close
		lines.append({"text":Table.TEXT.light_close%[roundi(close),Table.TEXT.ok if close>0.0 else Table.TEXT.short],"warn":close<=0.0})
	elif not key.is_empty():
		out.key=str(key.label)
		var row:Dictionary=_row(f,str(key.id))
		if str(row.get("why",""))=="HIDDEN":
			out.hidden=true
			lines.append({"text":Table.TEXT.reach_hidden%str(key.label),"warn":true})
		else:
			out.plain=reach_of(sim,uid,o,str(key.id),false)
			out.flash=reach_of(sim,uid,o,str(key.id),true) if flash_ok else 0.0
			var extra:String=Table.TEXT.reach_flash%roundi(out.flash) if flash_ok and out.flash>out.plain+1.0 else ""
			lines.append({"text":Table.TEXT.reach%[str(key.label),roundi(out.plain),extra],"warn":false})
	if int(u.band)!=1:lines.append({"text":BandHint.line(sim,uid),"warn":false})
	lines.append({"text":heard,"warn":true})
	return out
static func _sight(sim,u)->float:
	return Table.SIREN_SIGHT_SILENT if u.silent else Table.SIREN_SIGHT
# Known Sirens only: contacts the player holds. A contact is a stale fix, never live truth.
static func _heard(sim,u,ring:float)->String:
	var text:String=Table.TEXT.heard%roundi(ring)
	var best:=INF
	for i in sim.contacts:
		var c=sim.contacts[i]
		if sim.elapsed-float(c.time)>Table.CONTACT_MAX_AGE:continue
		# A listener in another band hears the shutter through the existing depth transmission.
		var cb:int=int(c.get("band",1))
		var hears:float=1.0 if cb in [-1,u.band] else BandPhoto.hear_scale(sim,int(u.band),cb)
		var d:float=u.pos.distance_to(c.pos)
		if d>ring*hears:continue
		var speed:float=float(Table.SIREN_SPEED.get(str(c.get("type","")),Table.SIREN_ALERT_SPEED))
		best=minf(best,d/speed)
	return text+(Table.TEXT.heard_eta%ceili(best) if best<INF else Table.TEXT.heard_none)
# Live countdowns for timed features that this view can see. Cheap; not cached.
static func windows(sim,o:Dictionary,f:Dictionary)->Array:
	var lines:Array=[];var s:Dictionary=o.get("subject",{})
	for i in s.get("features",[]).size():
		var feat:Dictionary=s.features[i]
		if not feat.has("window") or not f.rows[i].apparent:continue
		var w:Array=feat.window;var at:float=fposmod(sim.elapsed+float(w[2]),float(w[0]))
		if at<float(w[1]):lines.append({"text":Table.TEXT.window_open%[str(feat.label),ceili(float(w[1])-at)],"warn":false,"open":true})
		else:lines.append({"text":Table.TEXT.window_wait%[str(feat.label),ceili(float(w[0])-at)],"warn":false,"open":false})
	return lines
# Chart rings for the camera the player has armed: where the key detail resolves,
# and the sight radius of every Siren the player holds a fix on.
static func chart_rings(sim)->Dictionary:
	var uid:int=sim.capture_unit if sim.capture_unit>=0 and sim.selected==sim.capture_unit else sim.selected
	var view:Dictionary={}
	if sim.capture_unit>=0 and sim.selected==sim.capture_unit:
		var o=sim.Photo.obj(sim,sim.capture_target)
		if sim.Photo.applies(o):view={"o":o,"unit":uid}
	else:view=sim.Photo.preview(sim,uid)
	if view.is_empty():return {}
	var o:Dictionary=view.o;var u=sim.units[uid];var r:Dictionary=readout(sim,uid,o)
	var sirens:Array=[]
	for i in sim.contacts:
		var c=sim.contacts[i]
		if sim.elapsed-float(c.time)>Table.CONTACT_MAX_AGE or int(c.get("band",1)) not in [-1,u.band]:continue
		var ready:float=sim.Recon.readiness(sim.sirens[i]) if i<sim.sirens.size() else 1.0
		sirens.append({"pos":c.pos,"r":_sight(sim,u)*ready})
	return {"pos":o.pos,"label":r.get("key",""),"plain":r.get("plain",0.0),"flash":r.get("flash",0.0),"hidden":r.get("hidden",false),"light":r.get("light",false),"heard":r.get("heard",Table.SHUTTER_RING),"sirens":sirens,"craft":u.pos}
