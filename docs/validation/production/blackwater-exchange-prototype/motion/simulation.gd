extends "res://src/simulation/simulation.gd"
const Exchange=preload("res://proto/exchange_model.gd")
var variant="cycle"
var exchange=Exchange.new()
func set_variant(value:String):variant=value
func start(index:int,upgrade:String="endurance") -> void:
	super.start(index,upgrade);exchange=Exchange.new();exchange.variant=variant
	if mission.id!=2 or variant=="baseline":return
	mission["prototype"]=variant
	for id in 2:
		var o=mission.objectives[id];o.name=["REQUEST RELAY","REPLY RELAY"][id];o["kind"]="exchange";o["duration"]=Exchange.SAMPLE
		o["evidence"]=["A request names an archive older than humanity. Its rhythm predicts the paired reply.","The reply carries ancient ocean temperatures. It answers the matching request; these two sites exchange a historical archive."][id]
func _sense(id:int,station:int) -> Dictionary:
	var u=units[station];var point:Vector2=mission.objectives[id].pos;var radius=(240.0 if station==0 else 330.0)*0.65
	var distance=u.pos.distance_to(point);var clear=line_clear(u.pos,point)
	return {"alive":u.alive,"clear":clear,"local":distance<radius,"standoff":distance<240,"settled":u.vel.length()<2,"distance":distance,"radius":radius}
func exchange_context(id:int,station:int=-1) -> Dictionary:
	var sense=_sense(id,selected if station<0 else station);var data=exchange.prediction(id,elapsed)
	data.merge({"local_observed":sense.alive and sense.clear and (sense.local or (sense.standoff and exchange.replay_until[id]>elapsed)),"eligible":exchange.eligible(id,elapsed,sense),"distance":sense.distance,"radius":sense.radius,"replay":maxf(0,exchange.replay_until[id]-elapsed),"progress":exchange.progress})
	if data.local_observed:data["open"]=exchange.signal_open(id,elapsed) or data.replay>0
	return data
func command(order:String,args:Dictionary={}) -> bool:
	if mission.id!=2 or variant=="baseline":return super.command(order,args)
	if not outcome.is_empty():return false
	if order=="camera":
		if not units[selected].alive:return false
		if exchange.site>=0:message="Receiver already sampling · change route to break off";return false
		var id=_nearest_exchange()
		if id<0:return false
		if not exchange.arm(id,selected,elapsed,_sense(id,selected)):
			message="%s · close to passive reach or settle, SONAR, then SAMPLE within 3s"%mission.objectives[id].name;return false
		capture_unit=selected;capture_target=id;capture_time=0;units[selected].hold="HOLD";message="Receiving %s · 2 settled seconds on carrier"%mission.objectives[id].name;return true
	var original_station=selected
	var accepted=super.command(order,args)
	if accepted and order=="ping":
		for id in 2:
			var sense=_sense(id,original_station);exchange.solicit(id,elapsed,sense.alive and sense.clear and sense.standoff)
		message="SONAR emitted · local relay replay only where range and cover permit"
	if accepted and order in ["route","emergency"] and original_station==exchange.unit:exchange.cancel();capture_unit=-1
	return accepted
func _nearest_exchange() -> int:
	var best=-1;var distance=INF
	for id in 2:
		if mission.objectives[id].captured:continue
		var d=units[selected].pos.distance_to(mission.objectives[id].pos)
		if d<distance:best=id;distance=d
	return best
func camera_context() -> Dictionary:
	if mission.id!=2 or variant=="baseline":return super.camera_context()
	var id=exchange.site if exchange.site>=0 else _nearest_exchange()
	if id<0:return {"target":-1,"ready":false,"text":"Exchange matched · return Quietus to extraction"}
	var c=exchange_context(id,exchange.unit if exchange.site>=0 else selected);var target=mission.objectives[id]
	var text="%s · %dm / quiet%.0fm"%[target.name,c.distance,c.radius]
	if exchange.site>=0:text="%s · %s %.1f/2s"%[target.name,"CARRIER" if c.get("open",false) else "GAP · waiting",exchange.progress]
	elif c.replay>0:text+=" · local replay %.1fs · SAMPLE"%c.replay
	elif c.local_observed:text+=" · %s · SAMPLE"%("carrier open" if c.open else "carrier gap")
	elif c.prediction:text+=(" · calibrated continuous carrier" if c.get("continuous",false) else " · PREDICTED opening %.1fs"%c.until_open)
	else:text+=" · move closer or SONAR for local replay"
	return {"target":id,"ready":exchange.site<0 and c.eligible,"text":text}
func _tick(dt:float) -> void:
	if mission.id!=2 or variant=="baseline":super._tick(dt);return
	var active=exchange.site>=0
	# Production movement, sensing, AI and resource clocks stay unmodified.
	capture_unit=-1
	super._tick(dt)
	if active and outcome.is_empty():
		var id=exchange.site;var station=exchange.unit
		var complete=exchange.step(dt,elapsed,_sense(id,station))
		if complete>=0:
			mission.objectives[complete].captured=true;units[station].hold="";_record_secured(mission.objectives[complete])
			message="Exchange matched · bring Quietus home" if all_records() else (("Request recorded · paired reply calibrated" if complete==0 else "Reply recorded · paired request calibrated")+(" · continuous carrier" if variant=="direct" else " · next opening predicted"))
	if exchange.site>=0:capture_unit=exchange.unit;capture_target=exchange.site;capture_time=exchange.progress
	else:capture_unit=-1;capture_target=-1;capture_time=0
func snapshot() -> Dictionary:
	var data=super.snapshot()
	if mission.id==2 and variant!="baseline":data.mission["exchange_model"]=exchange.snapshot()
	return data
func restore(data:Dictionary) -> bool:
	if not super.restore(data):return false
	exchange=Exchange.new()
	if mission.id==2 and mission.has("exchange_model"):
		if not exchange.restore(mission.exchange_model):return false
		variant=exchange.variant;mission.erase("exchange_model")
	else:variant="baseline"
	return true
