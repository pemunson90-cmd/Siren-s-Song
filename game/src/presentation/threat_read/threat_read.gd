extends RefCounted
# THREAT READ: makes being caught readable on the chart. Presentation only.
#  1. Shutter reach: while a photograph is framed or exposed, the same shutter
#     radius the camera panel prints ("SHUTTER heard to Nm") is drawn around the
#     craft with metres, ticks and a label, and known contacts inside it are named.
#  2. Lock countdown: each living craft under a fresh received lock warning gets
#     a chip beside it with the same remaining time the lock card shows.
#  3. Drone loss: the cause the simulation recorded (Siren beam or battery), the
#     bearing from the wreck to the Siren that fired, and only the Siren identity
#     the chart already shows (coarse class, identified role, or UNSEEN SIREN).
#  4. Optional pause aid: TACTICAL AID: PAUSE ON CRAFT LOSS (tactical_aids.gd).
# It reads simulation state and never writes rules. The one write is the status
# text: on a drone loss the simulation's own loss message gets the cause and
# bearing inserted at its front (sim.message is display text the HUD log shows).
# Fair information: received contacts and the photo readout only; the live
# roster is read for the beam source's bearing and nothing else.
# Seams (one or two lines each):
#   simulation.gd   _threats(): drone beam loss event carries "siren" (read-only index)
#   tactical_aids.gd observe()/advance(): ThreatRead.observe, pause aid, step loop
#   ocean_view.gd   _draw(): draw_world after the priced rings; draw_screen after FeatureViews.draw_screen
#   frontend.gd     _controls_page(): CRAFT LOSS toggle row beside the other pause aids
#   settings_store.gd DEFAULTS and the boolean list: optional auto_pause_loss
# Revert: threat_read_table.gd enabled=false. Full removal: remove those seams
# and this folder; the optional settings key is ignored by sanitize once removed.
const Table=preload("res://src/presentation/threat_read/threat_read_table.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const BandPhoto=preload("res://src/photo_depth/band_photo.gd")
const Identity=preload("res://src/simulation/contact_identity.gd")
const Stun=preload("res://src/simulation/observed_stun.gd")

# Loss observer state for the one live dive: sim instance, mission, clock, last
# alive flags and the recent loss rows. Never saved; a restore primes it again.
static var _state:Dictionary={}
# Read-only record of the last chart draw, for tests: shutter radius drawn,
# loss marks drawn, and the screen chips placed ({"rect","text"}).
static var last_draw:Dictionary={"reach":0.0,"losses":0,"chips":[]}

static func pause_wanted()->bool:
	return Table.enabled and Settings.current.get(Table.SETTING,false)

# --- 1. shutter reach ------------------------------------------------------------
# Same source as the camera panel: Pricing.chart_rings reads Pricing.readout().heard,
# which is BandPhoto.ring for the craft's band and fittings (flash when armed).
static func shutter_reach(sim)->Dictionary:
	if not Table.enabled or sim==null or not sim.outcome.is_empty():return {}
	var rings:Dictionary=Pricing.chart_rings(sim)
	if rings.is_empty():return {}
	var u=sim.units[sim.selected]
	var radius:float=float(rings.heard)
	var inside:Array=[]
	for id in sim.contacts:
		var c=sim.contacts[id]
		if sim.elapsed-float(c.time)>Table.CONTACT_MAX_AGE:continue
		# The panel's ETA counts a listener in another band through the depth transmission.
		var band:int=int(c.get("band",1))
		var hears:float=1.0 if band in [-1,int(u.band)] else BandPhoto.hear_scale(sim,int(u.band),band)
		if u.pos.distance_to(c.pos)<=radius*hears:inside.append(id)
	return {"craft":rings.craft,"radius":radius,"label":Table.TEXT.shutter%roundi(radius),"inside":inside}

# --- 2. lock countdown -----------------------------------------------------------
# Same received-warning filter as tactical_aids.warnings() and lock_warning.frames().
static func lock_rows(sim)->Array:
	if not Table.enabled or sim==null or not sim.outcome.is_empty():return []
	var by_craft:Dictionary={}
	for id in sim.contacts:
		var c=sim.contacts[id];var target:int=int(c.get("target",-1));var age:float=sim.elapsed-float(c.time)
		if age<0 or age>=Table.FRESH_AGE or target<0 or target>=sim.units.size() or c.get("recipient_target",false):continue
		if not sim.units[target].alive or c.get("mode","")!="LOCKING" or c.get("lock",0)<=0 or c.lock>=Table.LOCK_SECONDS:continue
		if Stun.remaining(c,sim.elapsed)>0 or not sim.Depth.sight(sim,c,sim.units[target]):continue
		var remaining:float=Table.LOCK_SECONDS-float(c.lock)
		var row:Dictionary=by_craft.get(target,{})
		var count:int=int(row.get("count",0))+1
		if row.is_empty() or remaining<float(row.remaining):row={"craft":target,"source":int(id),"remaining":remaining}
		row["count"]=count;by_craft[target]=row
	var result:Array=[]
	for target in by_craft:
		var row:Dictionary=by_craft[target]
		row["text"]=Table.TEXT.lock_one%[row.source+1,row.remaining] if row.count==1 else Table.TEXT.lock_many%[row.count,row.remaining]
		row["progress"]=clampf(1.0-float(row.remaining)/Table.LOCK_SECONDS,0.0,1.0)
		result.append(row)
	result.sort_custom(func(a,b):return a.craft<b.craft)
	return result

# --- 3. drone loss ---------------------------------------------------------------
static func _alive(sim)->Array:
	return sim.units.map(func(u):return bool(u.get("alive",true)))
# Call after simulation steps (tactical_aids.observe). Returns the drone losses
# first seen by this call. The first call on a dive, a mission change or a
# rewound clock primes the state and reports nothing, so a restore never replays.
static func observe(sim)->Array:
	if not Table.enabled or sim==null:return []
	if _state.get("sim",-1)!=sim.get_instance_id() or not is_same(_state.get("mission"),sim.mission) or sim.elapsed<float(_state.get("clock",-1.0)):
		_state={"sim":sim.get_instance_id(),"mission":sim.mission,"clock":sim.elapsed,"alive":_alive(sim),"rows":[]}
		return []
	_state.clock=sim.elapsed
	var alive:Array=_alive(sim);var fresh:Array=[]
	for i in range(1,alive.size()):
		# Only a loss the simulation announced (its "loss" event at the craft) counts;
		# a craft removed at launch by a mode rule is not a loss in the dive.
		if i<_state.alive.size() and _state.alive[i] and not alive[i] and _loss_event(sim,sim.units[i].pos)!=null:
			var row:Dictionary=loss_row(sim,i)
			_annotate_message(sim,row)
			_state.rows.append(row);fresh.append(row)
	_state.alive=alive
	_state.rows=_state.rows.filter(func(r):return sim.elapsed-float(r.time)<=Table.LOSS_SECONDS)
	return fresh
# Recent loss rows for drawing, empty for any other dive.
static func loss_rows(sim)->Array:
	if not Table.enabled or sim==null or _state.get("sim",-1)!=sim.get_instance_id() or not is_same(_state.get("mission"),sim.mission):return []
	return _state.rows.filter(func(r):return sim.elapsed-float(r.time)<=Table.LOSS_SECONDS and sim.elapsed>=float(r.time))
static func _loss_event(sim,at:Vector2):
	for e in sim.events:
		if e is Dictionary and e.get("type","")=="loss" and e.get("pos",Vector2.INF) is Vector2 and e.pos.distance_to(at)<=Table.EVENT_MATCH:return e
	return null
static func reset()->void:
	_state={}
static func loss_row(sim,unit:int)->Dictionary:
	var u=sim.units[unit];var text:String=Table.TEXT.lost%str(u.get("name","DRONE"))
	var event=_loss_event(sim,u.pos)
	var siren:int=int(event.get("siren",-1)) if event!=null else -1
	var bearing:=-1.0
	if siren>=0 and siren<sim.sirens.size():
		var d:Vector2=sim.sirens[siren].pos-u.pos
		bearing=fposmod(rad_to_deg(atan2(d.x,-d.y)),360.0)
		text+=Table.TEXT.beam%(roundi(bearing)%360)+source_label(sim,siren)
	elif float(u.get("battery",100.0))<=0.0:text+=Table.TEXT.battery
	return {"unit":unit,"time":sim.elapsed,"pos":u.pos,"bearing":bearing,"siren":siren,"text":text}
# Only what the chart already shows for a held contact: its display class
# (coarse until identified, then the role); with no held contact, UNSEEN SIREN.
static func source_label(sim,id:int)->String:
	if sim.contacts.has(id):
		var kind:String=Identity.contact_type(sim.contacts[id])
		return Table.TEXT.source%[id+1,Table.ROLE_WORDS.get(kind,"PATROL")]
	# No held contact: never a number or role, even when intel seeded the role at launch.
	return Table.TEXT.unseen
# The simulation's own loss messages keep their advice after the cause line.
static func _annotate_message(sim,row:Dictionary)->void:
	var name:String=str(sim.units[row.unit].get("name",""))
	var message:String=str(sim.message)
	for prefix in [name+" lost · ","Drone lost · ",name+" battery exhausted · ",name+" battery exhausted. "]:
		if message.begins_with(prefix):
			sim.message=row.text+" · "+message.substr(prefix.length());return
# The loss line first; another aid's reason in the same step follows it.
static func pause_message(sim,reason:String="")->String:
	return Table.TEXT.pause%(str(sim.message)+("" if reason.is_empty() else " · "+reason))

# --- drawing ---------------------------------------------------------------------
# Inside the chart's world transform (ocean_view, after the priced rings).
static func draw_world(view,sim)->void:
	if not Table.enabled or sim==null or not view.presenting_mission:return
	var scale:float=maxf(view.world_scale,0.001)
	var width:float=Palette.stroke(Table.RING_WIDTH)/scale
	var reach:Dictionary=shutter_reach(sim)
	last_draw["reach"]=float(reach.get("radius",0.0));last_draw["losses"]=loss_rows(sim).size()
	if not reach.is_empty():
		var tint:Color=Palette.chart_color("heard",Color(0.62,0.88,0.97,0.9))
		view.draw_arc(reach.craft,reach.radius,0,TAU,96,Color("07131b"),width+3.0/scale)
		view.draw_arc(reach.craft,reach.radius,0,TAU,96,tint,width)
		for k in Table.RING_TICKS:
			var dir:=Vector2.from_angle(TAU*k/Table.RING_TICKS)
			view.draw_line(reach.craft+dir*reach.radius,reach.craft+dir*(reach.radius-Table.TICK_PIXELS/scale),tint,width)
		view._label(reach.craft+Vector2.from_angle(-PI*0.75)*float(reach.radius),reach.label,tint,14)
		for id in reach.inside:
			view._label(sim.contacts[id].pos+Vector2(0,44),Table.TEXT.in_reach,Palette.chart_color("warning",Color("ffb18b")),14)
	for row in loss_rows(sim):
		var ink:Color=Palette.chart_color("warning",Color("ffb18b"))
		var w:float=Table.WRECK_METRES
		for side in [Vector2(w,w),Vector2(w,-w)]:
			view.draw_line(row.pos-side,row.pos+side,Color("07131b"),width+3.0/scale)
			view.draw_line(row.pos-side,row.pos+side,ink,width)
		if float(row.bearing)>=0.0:
			var dir:=Vector2(sin(deg_to_rad(row.bearing)),-cos(deg_to_rad(row.bearing)))
			var tip:Vector2=row.pos+dir*Table.RAY_METRES
			view.draw_dashed_line(row.pos+dir*w,tip,ink,width,10.0/scale)
			view.draw_colored_polygon(PackedVector2Array([tip+dir*10.0/scale,tip+dir.orthogonal()*6.0/scale,tip-dir.orthogonal()*6.0/scale]),ink)
# Screen space (ocean_view, after FeatureViews.draw_screen): lock and loss chips.
static func draw_screen(view,sim)->void:
	if not Table.enabled or sim==null or not view.presenting_mission or not sim.outcome.is_empty():return
	last_draw["chips"]=[]
	var occupied:Array=view.ui_blocked_rects+view.contact_readout_rects()+view.world_label_rects+view.own_craft_rects()+view.ship_instrument_rects()
	if view.optical_feed!=null and view.optical_feed.is_visible_in_tree():occupied.append(view.optical_feed.get_rect().grow(6))
	var fs:int=view.feedback_font_size
	var warning:Color=Palette.color("warning",Color("ffb18b"))
	for row in lock_rows(sim):
		var anchor:Vector2=view.screen_position(sim.units[row.craft].pos)
		var box:Rect2=chip(view,anchor,row.text,fs,occupied)
		if box.size==Vector2.ZERO:continue
		occupied.append(box);last_draw.chips.append({"rect":box,"text":row.text})
		_draw_chip(view,box,anchor,row.text,fs,warning,float(row.progress))
	for row in loss_rows(sim):
		var anchor:Vector2=view.screen_position(row.pos)
		var box:Rect2=chip(view,anchor,row.text,fs,occupied)
		if box.size==Vector2.ZERO:continue
		occupied.append(box);last_draw.chips.append({"rect":box,"text":row.text})
		_draw_chip(view,box,anchor,row.text,fs,Palette.color("ink",Color("e9f1ef")),-1.0)
# A chip rect beside the anchor inside the chart (below the instruments, inside
# the safe content area) that avoids every occupied rect, or a zero rect.
static func chip(view,anchor:Vector2,text:String,fs:int,occupied:Array)->Rect2:
	var h:float=fs+Table.CHIP_PAD*2
	var gauge:float=h
	var extent:=Vector2(ThemeDB.fallback_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x+Table.CHIP_PAD*2+gauge,h)
	var top:float=float(view.instrument_top)+Table.EDGE
	var bounds:=Rect2(Vector2(Table.EDGE,top),Vector2(view.size.x-Table.EDGE*2,view.size.y-top-Table.EDGE))
	if bounds.size.x<extent.x or bounds.size.y<extent.y:return Rect2()
	if not bounds.has_point(anchor):return Rect2()
	for offset in Table.OFFSETS:
		var gap:float=absf(offset.x)*h
		var x:float=anchor.x+gap if offset.x>0 else anchor.x-gap-extent.x
		var at:=Vector2(x,anchor.y+offset.y*h).clamp(bounds.position,bounds.end-extent)
		var box:=Rect2(at,extent)
		if occupied.any(func(r):return r.intersects(box.grow(4))):continue
		return box
	return Rect2()
static func _draw_chip(view,box:Rect2,anchor:Vector2,text:String,fs:int,tint:Color,progress:float)->void:
	var edge:Vector2=anchor.clamp(box.position,box.end)
	view.draw_line(anchor,edge,Color(.01,.03,.04,.9),4.0)
	view.draw_line(anchor,edge,Color(tint,.7),1.5)
	view.draw_rect(box,Color(.03,.02,.03,.94))
	view.draw_rect(box,tint,false,Palette.stroke(2.0))
	var h:float=box.size.y
	if progress>=0.0:
		# Remaining time as an emptying arc, like the lock card's own gauge.
		var at:=box.position+Vector2(h*.5,h*.5);var r:float=h*.3
		view.draw_arc(at,r,0,TAU,24,Color(.4,.25,.24),3.0)
		view.draw_arc(at,r,-PI/2,-PI/2+TAU*(1.0-progress),24,tint,Palette.stroke(3.0))
	else:
		var at:=box.position+Vector2(h*.5,h*.5);var r:float=h*.22
		view.draw_line(at-Vector2(r,r),at+Vector2(r,r),tint,Palette.stroke(2.0))
		view.draw_line(at-Vector2(r,-r),at+Vector2(r,-r),tint,Palette.stroke(2.0))
	view.draw_string(ThemeDB.fallback_font,box.position+Vector2(h+Table.CHIP_PAD*.5,Table.CHIP_PAD+ThemeDB.fallback_font.get_ascent(fs)),text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,tint)
