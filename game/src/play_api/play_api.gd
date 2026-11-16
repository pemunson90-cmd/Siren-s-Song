extends RefCounted
# WP-123 (Pat, 14 Nov 2026): a direct controller for workers and critics who play the game without tapping pixels.
# Three calls, all on the running main scene (the host):
#   state(host,request)  one dictionary of what a player can know now (never hidden truth);
#   order(host,request)  the player's own orders by name, through the same code the taps reach (main.gd _order, the
#                        route guard, the PHOTO action, the HUD buttons); a refusal carries the game's own words;
#   run(host,request)    runs the dive for N game seconds at a speed, stops at anything that pauses it or needs an answer.
# It adds no rule and no shortcut: there is no teleport and no instant travel. The debug console stays the only way to
# cheat and only in debug builds. `state` reads the same sources the HUD reads (received contacts, the masked chart sites,
# the strip). The optional `truth` flag (debug builds only) adds the real Siren positions, marked as testing-only.
# Used by scripts/critic/driver.gd (kit commands state, order, run). Revert: delete this folder and the driver cases.
const Names=preload("res://src/names.gd")
const HudWords=preload("res://src/presentation/hud_words.gd")
const TimeSpeed=preload("res://src/time_speed.gd")
const TrialRules=preload("res://src/trial_rules.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Endurance=preload("res://src/simulation/operation_endurance.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const HuntMeter=preload("res://src/presentation/hunt_meter.gd")
const ContactFeedback=preload("res://src/presentation/contact_feedback.gd")
const ContactIdentity=preload("res://src/simulation/contact_identity.gd")
const LockWarning=preload("res://src/presentation/lock_warning.gd")
const ThreatRead=preload("res://src/presentation/threat_read/threat_read.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const FieldTools=preload("res://src/equipment/field_tools.gd")
const Truthful=preload("res://src/presentation/truthful_commands.gd")
const GradeOnSecure=preload("res://src/photo_grade/grade_on_secure.gd")
const Shutter=preload("res://src/presentation/photo_shutter/shutter.gd")
const CampaignFlow=preload("res://src/presentation/flow/campaign_flow.gd")
const EconomyPanel=preload("res://src/presentation/economy_panel.gd")
const ReleaseControls=preload("res://src/presentation/release_controls.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd") # WP-136: route_check and the chart
const MAX_EVENTS=200
const MAX_MESSAGES=200
const MAX_TEXT_LINES=80

# ---- small helpers --------------------------------------------------------------------------------------------------
static func _v(p)->Array:
	return [snappedf(p.x,0.1),snappedf(p.y,0.1)]
static func _clean(text)->String:
	return str(text).replace("\n"," ").strip_edges()
static func _debug()->bool:
	return OS.is_debug_build()
static func _lines(text)->Array:
	var out:Array=[]
	for line in str(text).split("\n",false):
		if not line.strip_edges().is_empty():out.append(line.strip_edges())
	return out
static func _mission_live(host)->bool:
	return host.screen=="mission" and host.sim!=null and not host.sim.mission.is_empty()
static func craft_index(host,value)->int:
	# "QUIETUS", "drone a", "A", "q", or the index 0..2.
	if value is int or value is float:
		var i:=int(value)
		return i if i>=0 and i<host.sim.units.size() else -1
	var text:=str(value).strip_edges().to_upper()
	for i in Names.UNIT_NAMES.size():
		if text==Names.UNIT_NAMES[i] or text==Names.UNIT_LETTERS[i] or text==Names.UNIT_NAMES[i].replace(" ","_") or text==str(i):return i
	return -1
# WP-136: Expedition and Naval Career open a session node (a second Main) on top of the campaign host and freeze the host. The
# play API reads and drives the session that is on screen: the newest child that points back at this host, else the host.
static func active_host(host):
	for i in range(host.get_child_count()-1,-1,-1):
		var child=host.get_child(i)
		if is_instance_valid(child) and not child.is_queued_for_deletion() and "campaign_host" in child and child.campaign_host==host:return child
	return host
# WP-136: the title overlay counts only while it is on screen (it stays in the tree, hidden, once a mode session opens).
static func _front(host)->Node:
	var front=host.get_node_or_null("Frontend")
	return front if front!=null and front.is_inside_tree() and front.is_visible_in_tree() else null
static func _point(value)->Variant:
	if value is Array and value.size()==2 and (value[0] is float or value[0] is int) and (value[1] is float or value[1] is int):return Vector2(float(value[0]),float(value[1]))
	if value is Dictionary and value.has("x") and value.has("y"):return Vector2(float(value.x),float(value.y))
	return null

# ---- what the player can read ---------------------------------------------------------------------------------------
static func _craft_task(sim,i:int)->String:
	var work=sim.capture_feedback(i)
	var verb:String=""
	if work.unit>=0:
		verb=preload("res://src/presentation/work_task/work_task.gd").action_verb(Photo.obj(sim,work.target))
	var u=sim.units[i]
	var task:String="ABOARD" if sim.DroneBay.aboard(u) else "LOST" if not u.alive else (verb if work.unit>=0 else (u.hold if not u.hold.is_empty() else ("ROUTE" if not u.route.is_empty() else "READY")))
	return {"SCOUT_STOP":"ALERT"}.get(task,task)
static func _crafts(host)->Array:
	var sim=host.sim;var out:Array=[]
	for i in sim.units.size():
		var u=sim.units[i]
		var aboard:bool=sim.DroneBay.aboard(u)
		var row={"index":i,"name":u.name,"selected":sim.selected==i,"alive":bool(u.alive) or aboard,"aboard":aboard,"launched":bool(u.alive) and not aboard,"pos":_v(u.pos),"depth":Names.BANDS[clampi(int(u.band),0,2)],"speed":snappedf(u.vel.length(),0.1),"silent":bool(u.silent),"hold":str(u.hold),"task":_craft_task(sim,i),"film":Photo.flash_left(sim,i)}
		var route:Array=[]
		for goal in sim.route_goals(i):route.append({"pos":_v(goal.pos),"stop":bool(goal.get("stop",true)),"mode":str(goal.get("mode","inherit"))})
		row["route"]=route
		if i>0:row["battery"]=snappedf(float(u.get("battery",0.)),0.1);row["drive"]=str(u.get("drone_drive","transit"))
		if not u.transition.is_empty():row["changing_depth_to"]=Names.BANDS[int(u.transition.to)];row["depth_change_seconds_left"]=snappedf(float(u.transition.remaining),0.1)
		var work=sim.capture_feedback(i)
		if work.unit>=0:row["exposure"]={"target":int(work.target),"seconds":snappedf(work.elapsed,0.1),"of":snappedf(work.duration,0.1)}
		out.append(row)
	return out
static func _contacts(host)->Array:
	var sim=host.sim;var out:Array=[]
	for entry in ContactFeedback.entries(sim.contacts,sim.elapsed,sim.units,sim.line_clear,sim.contact_target,sim.lock_seconds()):
		var c=sim.contacts[entry.key]
		out.append({"id":int(entry.key),"tag":entry.tag,"label":entry.text,"pos":_v(entry.pos),"age":snappedf(maxf(0.,sim.elapsed-float(c.time)),0.1),"fresh":bool(entry.fresh),"mode":ContactIdentity.contact_mode(c) if entry.fresh else "","urgent":bool(entry.urgent)})
	return out
static func _objectives(host)->Array:
	var sim=host.sim;var out:Array=[]
	var sites:Array=sim.observable_sites()
	for i in sites.size():
		var o:Dictionary=sites[i]
		var row={"index":i,"label":str(o.get("name","")),"pos":_v(o.pos) if o.get("pos") is Vector2 else [],"status":"FILED" if o.get("captured",false) else "NOT RECORDED","optional":bool(o.get("optional",false)),"found":not (str(o.get("stage",""))=="lead")}
		if o.has("lead_r"):row["search_radius"]=float(o.lead_r);row["status"]="SEARCH AREA" if not o.get("captured",false) else row.status
		var key:String=str(o.get("optical",o.get("site_id",i)))
		var best:=-1.0
		for shot in Photo.shots_for(sim.mission,key):
			if shot.get("usable",false):best=maxf(best,float(shot.get("q",0.)))
		if best>=0.:row["photo_grade"]=GradeOnSecure.letter(best);row["photo_percent"]=roundi(best*100.)
		out.append(row)
	return out
static func _extraction(host)->Dictionary:
	var sim=host.sim
	var out={"pos":_v(sim.mission.extraction),"records_complete":bool(sim.all_records())}
	var corridors:Array=[]
	for c in sim.extraction_corridors():corridors.append({"name":str(c.get("name","")),"pos":_v(c.pos),"available":bool(c.get("available",false))})
	out["corridors"]=corridors
	var departure=sim.departure_context()
	out["quietus_may_leave_now"]=bool(departure.get("available",false))
	out["hint"]=str(departure.get("text",""))
	return out
static func _tools(host)->Dictionary:
	var sim=host.sim;var out={}
	for id in FieldTools.ids():
		var n:int=Truthful.stock(sim,id)
		if n>0 or id in ["emp","decoy","recon","knock"]:out[id]=n
	return {"craft":sim.units[sim.selected].name,"left":out}
static func _locks(host)->Array:
	var sim=host.sim;var out:Array=[]
	for frame in LockWarning.frames(sim):
		var c=sim.contacts[frame.id]
		var craft:int=int(c.get("target",-1))
		out.append({"siren":"S%d"%(int(frame.id)+1),"craft":Names.unit_name(craft),"seconds_left":snappedf(frame.remaining,0.1),"pos":_v(frame.pos)})
	return out
static func _label_of(button:Button)->String:
	return _clean(button.text)
static func _visible_buttons(node:Node)->Array:
	var out:Array=[]
	if node==null:return out
	for b in node.find_children("*","Button",true,false):
		if b.is_visible_in_tree():out.append(b)
	return out
# Open cards and prompts as the player sees them, each with the buttons that answer it: [{kind,text,buttons:[Button]}].
static func _prompts(host)->Array:
	var out:Array=[]
	if host.screen=="mission" and host.mission_hud!=null:
		var hud=host.mission_hud
		if hud.guard!=null and hud.guard.panel.visible:
			var bs:Array=[hud.guard.go_button,hud.guard.cancel_button] # WP-138: the rock bar's SEND ANYWAY / CANCEL
			out.append({"kind":"route_marker","text":_clean(hud.guard.prompt.text),"buttons":bs})
		if hud.hints!=null and hud.hints.panel.visible:out.append({"kind":"tip","text":_clean(hud.hints.label.text),"buttons":[hud.hints.dismiss_button]})
		if hud.contact_card!=null and hud.contact_card.panel.visible:out.append({"kind":"contact_card","text":_clean(hud.contact_card.title_label.text+" · "+hud.contact_card.facts_label.text),"buttons":[hud.contact_card.close_button]})
		if hud.chart_choice!=null and hud.chart_choice.panel.visible:out.append({"kind":"chart_stop","text":_clean(hud.chart_choice.prompt.text),"buttons":[hud.chart_choice.continue_button,hud.chart_choice.replan_button]})
		if host.lock_warning!=null and host.lock_warning.visible and not host.lock_warning.card_text.is_empty():
			out.append({"kind":"lock","text":_clean(host.lock_warning.card_text),"buttons":host.lock_warning.buttons.filter(func(b):return b.visible)})
		if hud.recovery_box!=null and hud.recovery_box.is_visible_in_tree():out.append({"kind":"recovery_choice","text":"CHOOSE RECOVERY","buttons":_visible_buttons(hud.recovery_box)})
		var targets:Array=hud.target_buttons.filter(func(b):return is_instance_valid(b) and b.is_visible_in_tree())
		if not targets.is_empty():out.append({"kind":"choose_target","text":"WHICH CRAFT OR OBJECT?","buttons":targets})
		if host.advanced_orders:
			var wheel:Array=[]
			for b in hud.action_controls().values():
				if b is Button and not b.disabled:wheel.append(b)
			out.append({"kind":"orders_menu","text":"Order menu open (page %s) · time is held"%hud.page,"buttons":wheel})
	else:
		var buttons:Array=[]
		var front=_front(host)
		if front!=null:
			buttons=_visible_buttons(front)
			out.append({"kind":"title","text":" / ".join(_visible_texts(front,12)),"buttons":buttons})
		else:
			buttons=_visible_buttons(host.menu_footer)+_visible_buttons(host.panel_box)
			if host.archive_status!=null and host.archive_status.is_visible_in_tree():buttons=_visible_buttons(host.archive_status)+buttons
			out.append({"kind":"screen","text":" / ".join(_visible_texts(host.panel_box,6)),"buttons":buttons})
	return out
static func _visible_texts(node:Node,limit:int)->Array:
	var out:Array=[]
	for l in node.find_children("*","Label",true,false):
		if l.is_visible_in_tree() and not str(l.text).strip_edges().is_empty():
			out.append(_clean(l.text))
			if out.size()>=limit:break
	return out
static func _prompt_view(prompts:Array)->Array:
	return prompts.map(func(p):return {"kind":p.kind,"text":p.text,"buttons":p.buttons.map(func(b):return {"label":_label_of(b),"enabled":not b.disabled})})

# The whole picture a player could read now. request: {"truth":true} (debug builds only) adds hidden truth, marked.
static func state(host,request:Dictionary={})->Dictionary:
	var root=host
	host=active_host(host)
	var sim=host.sim
	var out:={"screen":host.screen}
	if host!=root:out["mode_session"]=str(host.name)
	var front=_front(host)
	if front!=null:out["title_overlay"]=str(front.screen)
	out["prompts"]=_prompt_view(_prompts(host))
	if host.screen!="mission":
		# Menus: the visible text and buttons are the whole picture (ENTER WATER, BACK TO OPERATIONS, debrief lines).
		var source=front if front!=null else host.panel_box
		out["text"]=_visible_texts(source,MAX_TEXT_LINES)
		if host==root:out["operations"]={"unlocked_up_to":host.unlocked+1,"recovered":host.completed.map(func(i):return int(i)+1)}
		if not sim.mission.is_empty() and host.active_started:out["dive_in_progress"]={"operation":host.mission_index+1,"title":str(sim.mission.title)}
		if not sim.outcome.is_empty():out["outcome"]=sim.outcome
		return out
	out["operation"]={"number":host.mission_index+1,"title":str(sim.mission.title),"depth_m":int(sim.mission.depth)}
	var held:bool=host._time_held()
	out["time"]={"state":"paused" if sim.paused else ("held" if held else "running"),"paused":bool(sim.paused),"held_by_menu_or_prompt":held,"speed":snappedf(host.time_speed,0.01),"speed_forced_by_debug":bool(host.time_forced),"dive_seconds":snappedf(sim.elapsed,0.1),"why_paused":HudWords.pause_reason(host)}
	out["siren_hunting_blocks_speedup"]=TimeSpeed.hunting(sim)
	var drain:float=Endurance.oxygen_drain(sim.mission,1.0)
	out["oxygen"]={"percent":int(sim.oxygen),"seconds_left":snappedf(sim.oxygen/maxf(drain,0.000001),1.0)}
	out["hull"]=int(sim.hull)
	out["outcome"]=sim.outcome
	out["selected"]=sim.units[sim.selected].name
	out["taps_add_to_route"]=bool(sim.queue_mode)
	out["new_points_pass_through"]=bool(sim.pass_through)
	out["crafts"]=_crafts(host)
	out["contacts"]=_contacts(host)
	out["objectives"]=_objectives(host)
	out["extraction"]=_extraction(host)
	out["chart"]=_chart(host)
	out["tools"]=_tools(host)
	out["locks"]=_locks(host)
	var hunt=Hunt.view(sim)
	out["hunt"]={"stage":str(hunt.stage),"scale":snappedf(float(hunt.scale),0.01),"label":_clean(HuntMeter.label(hunt)),"active":bool(hunt.active)}
	var strip:Array=_lines(host.mission_hud.intent.text) if host.mission_hud.intent.visible else []
	out["strip"]=strip
	out["message"]=_clean(sim.message)
	out["status_line"]=_clean(host.status_label.text)
	var camera=sim.camera_context()
	out["camera"]={"ready":bool(camera.get("ready",false)),"text":_clean(camera.get("text","")),"selected_craft":sim.units[sim.selected].name,"frame":Photo.settings(sim,sim.selected).duplicate(true)}
	if bool(request.get("truth",false)):
		if _debug():
			var sirens:Array=[]
			for i in sim.sirens.size():
				var s=sim.sirens[i]
				sirens.append({"tag":"S%d"%(i+1),"pos":_v(s.pos),"mode":str(s.get("mode","")),"type":str(s.get("type","")),"target":int(s.get("target",-1)),"lock":snappedf(float(s.get("lock",0.)),0.1)})
			out["truth"]={"WARNING":"TESTING ONLY: hidden simulation truth, not something a player can know","sirens":sirens}
		else:out["truth_refused"]="Release build: no hidden truth is available"
	return out

# ---- orders ---------------------------------------------------------------------------------------------------------
static func _answer(ok:bool,order:String,host,extra:Dictionary={})->Dictionary:
	var sim=host.sim
	var r:={"ok":ok,"order":order,"message":_clean(sim.message) if sim!=null else ""}
	if not ok and not r.has("refusal"):r["refusal"]=_clean(sim.message) if sim!=null and not str(sim.message).is_empty() else "Refused"
	r.merge(extra,true)
	return r
static func _refuse(order:String,why:String)->Dictionary:
	return {"ok":false,"order":order,"refusal":why,"message":why}
static func _select(host,index:int)->void:
	if host.sim.selected!=index:host._order("select",{"unit":index})
static func _need_dive(host,order:String)->String:
	if not _mission_live(host):return "No dive is running: this order needs the dive screen"
	if not host.sim.outcome.is_empty():return HudWords.TEXT.tap_over
	return ""
static func order(host,request:Dictionary)->Dictionary:
	var name:String=str(request.get("order","")).to_lower()
	var root=host
	host=active_host(host) # WP-136: an open Expedition or Career session is the game on screen
	var sim=host.sim
	if name in ["start","begin"]:
		# `start` opens a Campaign operation. Expedition and Naval Career are entered through the menus with `answer`.
		if host!=root:return _refuse(name,"%s is open: finish or leave it first. start opens a Campaign operation; Expedition and Naval Career are entered with answer (GAME MODES, then EXPEDITIONS or NAVAL CAREER)"%str(host.name))
		return _start(host,request)
	if name=="answer":return await _press(root,request)
	if name.is_empty():return _refuse(name,"Say which order: start, route, route_check, depth, deploy, recall, photo, tool, ping, silent, loud, hold, all_stop, select, answer, pause, run, speed")
	var why:=_need_dive(host,name)
	if not why.is_empty():return _refuse(name,why)
	# An order for another craft selects it first, as a tap on its chip would. Dive time is not touched.
	var craft:int=sim.selected
	if request.has("craft"):
		craft=craft_index(host,request.craft)
		if craft<0:return _refuse(name,"Unknown craft: %s (QUIETUS, DRONE A, DRONE B)"%str(request.craft))
	match name:
		"select":
			_select(host,craft);return _answer(sim.selected==craft,name,host)
		"pause","run","resume":
			var want:bool=name=="pause"
			if sim.paused==want:return _answer(true,name,host,{"note":"Already %s"%("paused" if want else "running")})
			host._pause()
			return _answer(sim.paused==want,name,host)
		"speed":return _speed(host,request)
		"route":return _route(host,request,craft)
		"route_check":return _route_check(host,request,craft)
		"depth":
			_select(host,craft)
			var band:int=_band(host,request,craft)
			if band<0:return _refuse(name,"Depth is shallow, middle or deep, or up or down")
			host._order("depth",{"band":band})
			return _answer(not sim.units[craft].transition.is_empty() and int(sim.units[craft].transition.to)==band,name,host)
		"deploy":
			var id:int=craft if request.has("craft") else ReleaseControls.deploy_target(sim)
			if id<1:return _refuse(name,"No drone is aboard to deploy")
			host._order("deploy",{"unit":id})
			return _answer(sim.DroneBay.aboard(sim.units[id])==false,name,host,{"craft":sim.units[id].name})
		"recall":
			var drone:int=craft if craft>0 else 0
			if drone==0:
				_select(host,0);host._order("recall_all")
			else:
				_select(host,drone);host._order("recall")
			var plan_ok:bool=(not sim.units[drone].route.is_empty()) if drone>0 else [1,2].any(func(d):return sim.units[d].alive and not sim.units[d].route.is_empty())
			return _answer(plan_ok,name,host)
		"photo":return _photo(host,request,craft)
		"tool":return _tool(host,request,craft)
		"ping":
			_select(host,craft);var before:float=sim.ping_time;host._order("ping")
			return _answer(sim.ping_time>before,name,host)
		"silent","loud":
			_select(host,craft)
			var silent_now:bool=bool(sim.units[craft].silent)
			if silent_now==(name=="silent"):return _answer(true,name,host,{"note":"Already %s"%("silent" if silent_now else "running loud")})
			host._order("silent")
			return _answer(bool(sim.units[craft].silent)==(name=="silent"),name,host)
		"hold":
			_select(host,craft);var on:bool=bool(request.get("on",true))
			if (sim.units[craft].hold=="HOLD")==on:return _answer(true,name,host,{"note":"Already %s"%("holding" if on else "released")})
			host._order("hold")
			return _answer((sim.units[craft].hold=="HOLD")==on,name,host)
		"all_stop":
			_select(host,0);host._order("all_stop")
			return _answer(not sim.message.is_empty() and not sim.message.to_lower().contains("unavailable"),name,host)
		"extract","withdraw":
			# The one-press withdraw shortcut is dev-only (ReleaseControls); a player plots legs by hand.
			host._recovery_route()
			return _answer(not sim.units[0].route.is_empty() and ReleaseControls.allowed(host,"withdraw_home"),name,host)
	return _refuse(name,"Unknown order: %s"%name)
static func _band(host,request:Dictionary,craft:int)->int:
	var u=host.sim.units[craft]
	var text:String=str(request.get("band","")).to_upper()
	if text in ["UP","SHALLOWER"]:return maxi(0,int(u.band)-1)
	if text in ["DOWN","DEEPER"]:return mini(2,int(u.band)+1)
	if text.is_valid_int() and int(text)>=0 and int(text)<=2:return int(text)
	return Names.BANDS.find(text)
static func _start(host,request:Dictionary)->Dictionary:
	# Begin an operation exactly as the screens do: pass the title, open the operation's briefing, press ENTER WATER.
	var index:int=int(request.get("operation",1))-1
	if host.screen=="mission" and host.active_started and host.sim.outcome.is_empty():return _refuse("start","A dive is in progress: finish it or open the OPERATIONS menu first")
	if index<0 or index>host.unlocked:return _refuse("start","Operation %d is locked"%(index+1))
	var front=host.get_node_or_null("Frontend")
	if front!=null and front.is_inside_tree():front._dismiss()
	host._briefing(index)
	CampaignFlow.launch_now(host,index)
	var ok:bool=host.screen=="mission" and host.active_started and int(host.sim.mission.id)==index
	if not ok:return _refuse("start",_clean(EconomyPanel.begin_text(host)))
	return {"ok":true,"order":"start","message":_clean(host.sim.message),"operation":index+1,"title":str(host.sim.mission.title)}
static func _speed(host,request:Dictionary)->Dictionary:
	var sim=host.sim;var want:float=float(request.get("speed",1.0))
	var releases:Array=TrialRules.time_speeds()
	if releases.any(func(s):return is_equal_approx(float(s),want)):
		for n in releases.size():
			if is_equal_approx(host.time_speed,want):break
			if not TimeSpeed.cycle(host):host._refresh();return _refuse("speed",HudWords.SPEED.hunting)
			host._refresh()
		var ok:bool=is_equal_approx(host.time_speed,want)
		return {"ok":ok,"order":"speed","speed":host.time_speed,"message":_clean(HudWords.speed_text(host.time_speed,TimeSpeed.hunting(sim))),"refusal":"" if ok else HudWords.SPEED.hunting}
	# Speeds above the release set exist only in a debug build, through the console's own `time` line (it marks the profile DEV).
	if host.debug_console==null:return _refuse("speed","Speed %s is not offered (1, 2 or 4)"%str(want))
	var reply:String=str(host.debug_console.execute("time %s"%str(want)))
	return {"ok":is_equal_approx(host.time_speed,want),"order":"speed","speed":host.time_speed,"message":reply,"marked_dev":true}
static func _route(host,request:Dictionary,craft:int)->Dictionary:
	var sim=host.sim
	var points:Array=request.get("points",[])
	if points.is_empty():return _refuse("route","Give points: [[x,y],...] in chart metres")
	if sim.DroneBay.aboard(sim.units[craft]):return _refuse("route","%s is still aboard: deploy it first (order deploy), then route it"%sim.units[craft].name) # WP-136: the order used to launch it
	var mode:String=str(request.get("mode","replace")).to_lower()
	if mode not in ["replace","append"]:return _refuse("route","mode is replace or append")
	_select(host,craft)
	var guard=host.mission_hud.guard
	guard.pending={} # a marker left open is superseded by this order, as a new tap moves it
	var queue_before:bool=sim.queue_mode
	var crosses:bool=false
	var done:=0
	for i in points.size():
		var p=_point(points[i])
		if p==null:sim.queue_mode=queue_before;return _refuse("route","Point %d is not [x,y]"%(i+1))
		# The first point replaces, or adds when asked; every later point adds. The game's QUEUE toggle is put back after.
		var append:bool=(i>0) or (mode=="append" and not sim.units[craft].route.is_empty())
		sim.queue_mode=append
		if guard.leg_crosses_rock(p,append):crosses=true
		var goals_before:Array=sim.route_goals(craft).map(func(g):return g.pos)
		host._order("route",{"point":p}) # TRAVEL:water_leg WP-134: the critic kit places the same hand-set legs as a water tap
		var goals:Array=sim.route_goals(craft)
		var took:bool=not goals.is_empty() and goals.back().pos.distance_to(p)<0.5 and (goals.size()>goals_before.size() or (i==0 and not append))
		if not took:
			sim.queue_mode=queue_before
			return _answer(false,"route",host,{"craft":sim.units[craft].name,"points_accepted":done,"refusal":_clean(sim.message)})
		done+=1
	sim.queue_mode=queue_before
	var extra:={"craft":sim.units[craft].name,"points_accepted":done,"route":sim.route_goals(craft).map(func(g):return _v(g.pos))}
	if crosses:extra["warning"]=HudWords.TEXT.rock_route
	return _answer(true,"route",host,extra)
# WP-136: does each leg of a would-be route cross charted rock? Plots nothing, moves nothing, spends no dive time. It asks the
# call the game's own red leg uses (HandPilot.rock_point), so it knows only the rock the chart shows.
static func _route_check(host,request:Dictionary,craft:int)->Dictionary:
	var sim=host.sim
	var points:Array=request.get("points",[])
	if points.is_empty():return _refuse("route_check","Give points: [[x,y],...] in chart metres")
	var mode:String=str(request.get("mode","replace")).to_lower()
	if mode not in ["replace","append"]:return _refuse("route_check","mode is replace or append")
	var u=sim.units[craft]
	var origin:Vector2=u.route.back().pos if mode=="append" and not u.route.is_empty() else u.pos
	var legs:Array=[]
	var any_rock:=false
	if not HandPilot.release(sim):return _answer(true,"route_check",host,{"craft":u.name,"legs":legs,"crosses_charted_rock":false,"note":"Dev profile: the route checker is off"})
	sim._use_band(u.band)
	for i in points.size():
		var p=_point(points[i])
		if p==null:sim._use_band(sim.units[sim.selected].band);return _refuse("route_check","Point %d is not [x,y]"%(i+1))
		var rock=HandPilot.rock_point(sim,origin,p)
		var leg:={"from":_v(origin),"to":_v(p),"crosses_charted_rock":rock!=null,"end_in_rock":HandPilot.rock_at(sim,p)}
		if rock!=null:leg["rock_at"]=_v(rock);any_rock=true
		legs.append(leg)
		origin=p
	sim._use_band(sim.units[sim.selected].band)
	return _answer(true,"route_check",host,{"craft":u.name,"depth":Names.BANDS[clampi(int(u.band),0,2)],"legs":legs,"crosses_charted_rock":any_rock})
# WP-136: the rock the player can see on the chart, so a route can be planned without a screenshot. Opening charts show the
# briefed rock as polygons (chart metres); an earned chart shows only the 40 m cells the craft has received as rock. Unknown
# water is never listed, nor is any rock the chart does not draw. Rock is per depth band: this is the selected craft's band.
static func _chart(host)->Dictionary:
	var sim=host.sim
	var band:int=int(sim.units[sim.selected].band)
	sim._use_band(band)
	var out:={"band":Names.BANDS[clampi(band,0,2)],"world_m":_v(sim.world_size())}
	if sim.terrain_chart!=null:
		var pub:Dictionary=sim.public_chart()
		var cells:Array=pub.get("return_cells",[]).map(func(c):return [int(c.x),int(c.y)])
		cells.sort_custom(func(a,b):return a[1]<b[1] or (a[1]==b[1] and a[0]<b[0]))
		out["kind"]="earned"
		out["cell_m"]=pub.get("cell_size",40.0)
		out["rock_cells"]=cells
		out["charted_clear_cells"]=pub.get("clear_cells",[]).size()
	else:
		var polygons:Array=[]
		if int(sim.mission.id)!=8:
			for r in sim.mission.get("depth_geometry",{}).get(band,{}).get("rocks",sim.mission.rocks):
				var poly:PackedVector2Array=sim.rock_polygon(r)
				polygons.append(Array(poly).map(func(p):return _v(p)))
		out["kind"]="opening"
		out["rock"]=polygons
	return out
static func _photo(host,request:Dictionary,craft:int)->Dictionary:
	var sim=host.sim
	_select(host,craft)
	# Optional framing first (the camera panel's own choices): mode wide|tight, flash, focus.
	var frame:={}
	for key in ["mode","flash","focus"]:
		if request.has(key):frame[key]=request[key]
	if not frame.is_empty():
		host._order("frame",frame)
	var before:bool=not sim.captures[craft].is_empty()
	host._primary_action()
	var started:bool=not sim.captures[craft].is_empty() and not before
	var extra:={"craft":sim.units[craft].name}
	if not started and not before and bool(request.get("insist",false)):
		# The shutter warns on the first press of a frame it expects to be unusable; a second press exposes. insist presses again.
		extra["first_press"]=_clean(sim.message)
		host._primary_action()
		started=not sim.captures[craft].is_empty()
	if before:extra["note"]="An exposure is already under way"
	# WP-136: say whether the flash fired. It fires only when the frame asks for it, a flash unit is fitted and a charge is left.
	var asked:bool=bool(Photo.settings(sim,craft).get("flash",false))
	var fitted:bool=bool(Photo.optics(sim,craft).flash)
	var fired:bool=bool(Photo.peek(sim).acc.get(craft,{}).get("flash",false)) and (started or before)
	extra["flash"]={"asked":asked or bool(request.get("flash",false)),"fitted":fitted,"fired":fired,"charges_left":Photo.flash_left(sim,craft)}
	if bool(request.get("flash",false)) and not fired:
		extra["flash"]["why_not"]="No flash unit is fitted to %s"%sim.units[craft].name if not fitted else ("No flash charge is left" if Photo.flash_left(sim,craft)<=0 else "The exposure did not start")
	return _answer(started or before,"photo",host,extra)
static func _tool(host,request:Dictionary,craft:int)->Dictionary:
	var sim=host.sim;var tool:String=str(request.get("tool","")).to_lower()
	if not FieldTools.ids().has(tool):return _refuse("tool","Unknown tool: %s (%s)"%[tool,", ".join(FieldTools.ids())])
	_select(host,craft)
	var stock_before:int=Truthful.stock(sim,tool)
	match tool:
		"decoy":
			var p=_point(request.get("point"))
			if p==null:return _refuse("tool","DECOY needs a point: [x,y] of clear water within its range")
			# WP-148: arm only when not already armed for this craft (a second press would disarm), and when arming fails say why
			# (the chart's message may be a stale earlier one such as AUTO PAUSE: LOCK WARNING).
			if not (host.decoy_armed and int(host.decoy_unit)==craft):host._order("decoy")
			if not host.decoy_armed:
				var why:String="Decoy unavailable · no charge spent"
				if not sim.units[craft].alive:why="%s is lost · no charge spent"%str(sim.units[craft].name)
				elif Truthful.stock(sim,"decoy")<=0:why="No decoy left · no charge spent"
				return _answer(false,"tool",host,{"tool":tool,"refusal":why,"message":why})
			host._order("decoy",{"point":p})
		"knock":
			var target:int=int(request.get("target",-1))-1 if request.has("target") else -1
			if target<0:return _refuse("tool","TORPEDO needs target: the S number of a contact, for example 1 for S1")
			host._order("knock")
			if not host.knock_armed:return _answer(false,"tool",host,{"tool":tool})
			# WP-136: the sim's own list (fresh, in range, clear path), not the on-screen FIRE boxes: the API has no screen to pan.
			if not sim.knockdown_targets().any(func(c):return c.key==target):
				# The same words the chart gives for a shot at no clear contact; the arming is cancelled, nothing spent.
				sim.message="Choose an S# FIRE box or a clear contact · no torpedo spent"
				host._order("knock")
				return _answer(false,"tool",host,{"tool":tool,"clear_targets":sim.knockdown_targets().map(func(c):return c.tag)})
			host._order("knock",{"target":target})
		_:
			host._order(tool)
	return _answer(Truthful.stock(sim,tool)<stock_before,"tool",host,{"tool":tool,"left":Truthful.stock(sim,tool)})
static func _norm(text)->String:
	return _clean(text).to_upper()
# Presses one button of an open card, prompt or screen, found by its label (case and line breaks ignored).
static func _press(root,request:Dictionary)->Dictionary:
	var host=active_host(root) # WP-136: the session on screen, if a mode is open
	var wanted:String=_norm(request.get("button",request.get("label","")))
	if wanted.is_empty():return _refuse("answer","Name the button to press, as its label reads")
	var matches:Array=[];var near:Array=[]
	var seen:Array=[]
	for prompt in _prompts(host):
		for b in prompt.buttons:
			if not is_instance_valid(b) or b in seen:continue
			seen.append(b)
			var label:String=_norm(b.text)
			if label==wanted or str(b.get_meta("action","")).to_upper()==wanted:matches.append(b)
			elif label.contains(wanted):near.append(b)
	if matches.is_empty():matches=near
	if matches.is_empty():
		return {"ok":false,"order":"answer","refusal":"No open button reads %s"%wanted,"message":"","available":seen.map(func(b):return _label_of(b))}
	# WP-136: two buttons can read the same (two "Scout drone"): `index` (0 = the first, in the order state lists them) picks one.
	if request.has("index"):
		var pick:int=int(request.index)
		if pick<0 or pick>=matches.size():return {"ok":false,"order":"answer","refusal":"index %d: only %d button(s) read %s"%[pick,matches.size(),wanted],"message":"","candidates":matches.map(func(b):return _label_of(b))}
		matches=[matches[pick]]
	if matches.size()>1:return {"ok":false,"order":"answer","refusal":"More than one button reads %s: add index 0 to %d"%[wanted,matches.size()-1],"message":"","candidates":matches.map(func(b):return _label_of(b))}
	var button:Button=matches[0]
	if button.disabled:return {"ok":false,"order":"answer","refusal":"%s is greyed out%s"%[_label_of(button),(": "+button.tooltip_text) if not button.tooltip_text.is_empty() else ""],"message":""}
	var label:String=_label_of(button) # read first: a screen button is freed when its screen is rebuilt
	button.pressed.emit()
	# The game's buttons answer on the next idle step (deferred); let it settle before anyone reads the result.
	await host.get_tree().process_frame
	await host.get_tree().process_frame
	host=active_host(root) # the press may have opened or closed a mode session
	var sim=host.sim
	return {"ok":true,"order":"answer","pressed":label,"message":_clean(sim.message) if sim!=null else "","screen":host.screen}

# ---- run ------------------------------------------------------------------------------------------------------------
static func _signature(prompts:Array)->Array:
	return prompts.map(func(p):return "%s|%s"%[p.kind,p.text])
# One step of the dive exactly as Main._process takes it while a dive is on screen: the dive clock (which scales by the
# time speed and runs the pause aids), then the evidence and debrief hooks. It leaves out the frame-bound extras (sound,
# the per-frame HUD refresh, quality sampling) that are not game state; `run` refreshes the HUD every REFRESH_EVERY seconds.
static func _advance(host,dt:float)->void:
	if not host._time_held():preload("res://src/dive_clock.gd").advance(host,host.tactical_aids,dt)
	host._observation_diagnostics()
	if not host.sim.outcome.is_empty():host._debrief()
	elif host.sim.has_method("departure_context") and host.sim.departure_context().get("pending",false):host._confirm_module_departure()
const REFRESH_EVERY=2.0
# Runs the dive for `seconds` of game time, at `speed` when given. Starts it if paused, and leaves it paused (a tactical
# pause) so nothing runs between commands. Stops early at: a pause the game made, a lock, a new card or prompt, a craft
# lost, the end of the dive, a Siren hunting while sped up.
static func run(host,request:Dictionary)->Dictionary:
	host=active_host(host) # WP-136
	var why:=_need_dive(host,"run")
	if not why.is_empty():return _refuse("run",why)
	var sim=host.sim
	var seconds:float=clampf(float(request.get("seconds",10.0)),0.0,7200.0)
	var out:={"ok":true,"command":"run"}
	if request.has("speed"):
		var set_speed:Dictionary=_speed(host,{"speed":request.speed})
		# A refused speed (a Siren is hunting, or the speed is not offered) does not stop the run: it runs at the speed the
		# game allows and says so, as a player who tapped SPEED and was refused would carry on at 1x.
		if not set_speed.ok:out["speed_note"]=str(set_speed.get("refusal","Speed refused"))
		if set_speed.get("marked_dev",false):out["marked_dev"]=true
	var started_paused:bool=sim.paused
	if sim.paused:
		host._pause()
		if sim.paused:
			out["ok"]=false;out["stopped"]="could_not_start";out["refusal"]=_clean(sim.message);out["state"]=state(host);return out
	var start_time:float=sim.elapsed
	var started_ms:int=Time.get_ticks_msec()
	var event_start:int=sim.events.size()
	var alive_before:Array=sim.units.map(func(u):return bool(u.alive))
	var sig_before:Array=_signature(_prompts(host))
	var locks_before:Array=_locks(host).map(func(l):return l.siren)
	var speed_before:float=host.time_speed
	var messages:Array=[]
	var last_message:String=str(sim.message)
	var max_real:float=float(request.get("max_real_seconds",300.0))
	var reason:="time_elapsed"
	var step_count:=0
	var last_refresh:float=sim.elapsed
	var clock_seen:float=-1.0
	var stalled:=0
	while true:
		var remaining:float=seconds-(sim.elapsed-start_time)
		if remaining<=0.0001:break
		# A dive that does not move forward (nothing holds it, yet its clock stands still) is reported, never spun on.
		if sim.elapsed==clock_seen:stalled+=1
		else:stalled=0;clock_seen=sim.elapsed
		if stalled>40:reason="stalled";break
		var speed:float=maxf(host.time_speed,0.25)
		var game_chunk:float=minf(1.0,remaining)
		var dt:float=minf(0.25,game_chunk/speed)
		_advance(host,dt)
		step_count+=1
		# The HUD's own refresh builds the cards and warnings the player would see; every couple of game seconds is enough
		# to notice a new one and costs far less than one per step.
		if sim.elapsed-last_refresh>=REFRESH_EVERY:last_refresh=sim.elapsed;host._refresh()
		if str(sim.message)!=last_message:
			last_message=str(sim.message)
			if messages.size()<MAX_MESSAGES:messages.append({"t":snappedf(sim.elapsed,0.1),"text":_clean(last_message)})
		if not sim.outcome.is_empty() or host.screen!="mission":reason="dive_ended";break
		var lost:=false
		for i in sim.units.size():
			if alive_before[i] and not sim.units[i].alive:lost=true
		if lost:reason="craft_lost";break
		if sim.paused:reason="paused";break
		if host._time_held():reason="held_for_answer";break
		var now_locks:Array=_locks(host)
		if now_locks.any(func(l):return l.siren not in locks_before):reason="lock";break
		var sig_now:Array=_signature(_prompts(host))
		if sig_now.any(func(s):return s not in sig_before):reason="card_or_prompt";break
		if speed_before>1.0 and host.time_speed<=1.0 and not host.time_forced:reason="siren_hunting_speed_dropped";break
		if (Time.get_ticks_msec()-started_ms)/1000.0>max_real:reason="real_time_limit";break
	# Leave the dive in a tactical pause so nothing runs between commands (the player's own pause, as the plate does it).
	if not sim.paused and sim.outcome.is_empty():
		sim.paused=true;host.tactical_aids.auto_pause.clear()
	host._refresh()
	var events:Array=[]
	for i in range(event_start,sim.events.size()):
		var e=sim.events[i]
		if events.size()>=MAX_EVENTS:break
		var row:={}
		for key in e:row[key]=_v(e[key]) if e[key] is Vector2 else (e[key] if e[key] is String or e[key] is int or e[key] is float or e[key] is bool else str(e[key]))
		events.append(row)
	var real:float=maxf(0.001,(Time.get_ticks_msec()-started_ms)/1000.0)
	out["stopped"]=reason
	out["started_paused"]=started_paused
	out["game_seconds"]=snappedf(sim.elapsed-start_time,0.01)
	out["real_seconds"]=snappedf(real,0.001)
	out["game_seconds_per_real_second"]=snappedf((sim.elapsed-start_time)/real,0.1)
	out["steps"]=step_count
	out["events"]=events
	out["messages"]=messages
	out["state"]=state(host,request)
	return out
