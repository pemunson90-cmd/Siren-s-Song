extends RefCounted
# WP-175: the order wheel's page buttons for the play API. A player opens the craft's order wheel, goes to a page (TOOLS, ROUTE,
# GUARD, DEPTH, REACH WORK, CHOIR WORK, CACHE) and taps a segment. `pages` reads those pages without opening anything (for `state`);
# `press` does what the player does: open the wheel, go to the page that holds the button, tap it (twice where the wheel asks for a
# confirming tap), then close the wheel. No rule is added: the buttons, their enabled flags and their reasons are the game's own.
# The root page's menu segment that leads to each page (the others are reached from the root only).
const PAGE_ENTRY:={"tools":"tools_menu","route":"route_menu","guard":"guard_menu","acoustics":"depth_menu","glass":"glass_work","choir":"choir_work","cache":"cache_menu"}
const PAGE_NAME:={"craft":"ORDERS","tools":"TOOLS","route":"ROUTE","guard":"GUARD","acoustics":"DEPTH AND SONAR","glass":"REACH WORK","choir":"CHOIR WORK","cache":"CACHE"}

static func _clean(text)->String:
	return str(text).replace("\n"," ").strip_edges()
static func _norm(text)->String:
	return _clean(text).to_upper()
static func _refuse(order:String,why:String)->Dictionary:
	return {"ok":false,"order":order,"refusal":why,"message":""}
static func _select(host,index:int)->void:
	if host.sim.selected!=index:host._order("select",{"unit":index})
# The label as the wheel shows it, without the short reason token a disabled segment adds to its caption.
static func label_of(b:Button)->String:
	var text:String=b.text
	if b.has_meta("truthful_base") and text==str(b.get_meta("truthful_render","")):text=str(b.get_meta("truthful_base"))
	return _clean(text)
static func key_of(b:Button)->String:
	return str(b.get_meta("action",""))
static func reason_of(b:Button)->String:
	if not b.disabled:return ""
	var reason:String=str(b.get_meta("truthful_reason",b.tooltip_text))
	return reason if not reason.is_empty() else "Unavailable here"
# The controls a page holds for the selected craft: Array of Button. The page is set for the read only and put back.
static func page_buttons(hud,page:String)->Array:
	var kept_page:String=hud.page
	hud.page=page
	var out:Array=[]
	for b in hud.command_controls():
		if b is Button and is_instance_valid(b):out.append(b)
	hud.page=kept_page
	return out
# The pages the selected craft's wheel offers now: ["craft", ...]. A page is offered when its root segment is among the root's controls.
static func page_names(hud)->Array:
	var root:Array=page_buttons(hud,"craft")
	var keys:Array=root.map(func(b):return key_of(b))
	var out:Array=["craft"]
	for page in PAGE_ENTRY:
		if PAGE_ENTRY[page] in keys:out.append(page)
	return out
# state: {pages:[{page,name,controls:[{label,enabled,reason?}]}]}, for the selected craft.
static func pages(host)->Array:
	var hud=host.mission_hud
	var out:Array=[]
	if hud==null:return out
	for page in page_names(hud):
		var rows:Array=[]
		for b in page_buttons(hud,page):
			var row:Dictionary={"label":label_of(b),"enabled":not b.disabled}
			if b.disabled:row["reason"]=reason_of(b)
			rows.append(row)
		out.append({"page":page,"name":PAGE_NAME.get(page,page.to_upper()),"controls":rows})
	return out

static func _settle(host)->void:
	await host.get_tree().process_frame
	await host.get_tree().process_frame
static func _open_root(host,hud,craft:int)->void:
	hud.dismiss()
	hud.open("craft",{"kind":"craft","unit":craft,"pos":host.sim.units[craft].pos})
# order: {"order":"control","label":"RELEASE VANE","craft":"QUIETUS"?}
static func press(host,request:Dictionary,craft:int)->Dictionary:
	var hud=host.mission_hud
	var wanted:String=_norm(request.get("label",request.get("button","")))
	if wanted.is_empty():return _refuse("control","Name the wheel button to press, as its label reads (part of it is enough); state lists them under controls")
	if hud==null:return _refuse("control","No order wheel on this screen")
	_select(host,craft)
	# Find the page and the button by label without touching the screen: exact label first, then part of a label.
	var found:Array=[];var near:Array=[];var every:Array=[]
	for page in page_names(hud):
		for b in page_buttons(hud,page):
			var label:String=_norm(label_of(b))
			var entry:Dictionary={"page":page,"key":key_of(b),"label":label_of(b),"enabled":not b.disabled}
			every.append(entry)
			if label==wanted or key_of(b).to_upper()==wanted:found.append(entry)
			elif label.contains(wanted):near.append(entry)
	if found.is_empty():found=near
	# WP-179: no craft button matches (or an object was named): the buttons on a charted object's wheel, opened as a tap on it would.
	if request.has("object") or found.is_empty():
		var by_object:Dictionary=await _press_object(host,hud,request,craft,wanted,found.is_empty())
		if not by_object.is_empty():return by_object
	if found.is_empty():
		return {"ok":false,"order":"control","refusal":"No order-wheel button reads %s for %s"%[wanted,host.sim.units[craft].name],"message":"","available":every.map(func(e):return "%s > %s%s"%[PAGE_NAME.get(e.page,e.page),e.label,"" if e.enabled else " (greyed out)"])}
	# One button on several pages (ROUTE HERE...): take the enabled one when only one is enabled; otherwise ask for a clearer label.
	var pick:Dictionary=found[0]
	if found.size()>1:
		var live:Array=found.filter(func(e):return e.enabled)
		var seen:Array=[]
		for e in found:
			if not (e.key+"|"+e.page in seen):seen.append(e.key+"|"+e.page)
		if live.size()==1:pick=live[0]
		elif seen.size()>1 and not request.has("index"):
			return {"ok":false,"order":"control","refusal":"More than one wheel button reads %s: name it fully, or add index 0 to %d"%[wanted,found.size()-1],"message":"","candidates":found.map(func(e):return "%s > %s"%[PAGE_NAME.get(e.page,e.page),e.label])}
		elif request.has("index"):
			var i:int=int(request.index)
			if i<0 or i>=found.size():return {"ok":false,"order":"control","refusal":"index %d: only %d button(s) read %s"%[i,found.size(),wanted],"message":""}
			pick=found[i]
	# Do it as a player: open the craft's wheel, go to the page, tap the segment.
	_open_root(host,hud,craft)
	await _settle(host)
	if pick.page!="craft":
		var entry:Button=hud.extra[PAGE_ENTRY[pick.page]]
		if entry.disabled:
			var why:String=reason_of(entry)
			hud.dismiss();return {"ok":false,"order":"control","refusal":"%s is greyed out: %s"%[label_of(entry),why],"message":""}
		hud.segments.tap(hud,entry)
		await _settle(host)
		if hud.page!=pick.page:
			hud.dismiss();return {"ok":false,"order":"control","refusal":"The wheel did not open the %s page"%PAGE_NAME.get(pick.page,pick.page),"message":""}
	var button:Button=null
	for b in hud.command_controls():
		if b is Button and key_of(b)==pick.key and b.is_visible_in_tree():button=b;break
	if button==null:
		hud.dismiss();return {"ok":false,"order":"control","refusal":"%s is not shown on the %s page just now"%[pick.label,PAGE_NAME.get(pick.page,pick.page)],"message":""}
	if button.disabled:
		var reason:String=reason_of(button)
		var shown:String=label_of(button)
		hud.dismiss()
		return {"ok":false,"order":"control","refusal":"%s is greyed out: %s"%[shown,reason],"message":"","page":PAGE_NAME.get(pick.page,pick.page)}
	var label:String=label_of(button)
	var taps:int=1
	hud.segments.tap(hud,button)
	if hud.segments.is_armed(button):hud.segments.tap(hud,button);taps=2 # the wheel's confirming tap ("Tap again to confirm")
	await _settle(host)
	var sim=host.sim
	var out:Dictionary={"ok":true,"order":"control","pressed":label,"page":PAGE_NAME.get(pick.page,pick.page),"craft":sim.units[craft].name,"taps":taps,"message":_clean(sim.message)}
	if host.advanced_orders and not PAGE_ENTRY.values().has(pick.key):hud.dismiss() # a menu segment leaves its page open, as a player would
	return out

# WP-179: buttons on an OBJECT's wheel (a charted site, station, pod, switch...), which a player opens by tapping the object.
# The objects are found as a tap finds them: ocean.contexts_at at the screen spot of every visible thing that can be tapped.
static func _seeds(host)->Array:
	var ocean=host.ocean;var sim=host.sim;var touch:float=host.ui_touch_height
	var out:Array=[]
	if ocean==null or sim==null:return out
	var rect:Rect2=Rect2(Vector2.ZERO,ocean.get_global_rect().size)
	var world:Array=[]
	for site in ocean.observable_sites():world.append(site.pos)
	for row in ocean.Shelf.subject_rows(sim)+ocean.Concealed.subjects(sim):world.append(row.pos)
	for target in preload("res://src/presentation/industrial_view.gd").targets(sim):world.append(target.pos)
	if sim.mission.has("glass_reach"):world.append(sim.mission.glass_reach.work_pos)
	var chain=ocean.WarningChain.context(sim)
	if not chain.is_empty():
		for station in chain.stations:world.append(station.pos)
	for corridor in sim.extraction_corridors():world.append(corridor.pos)
	for p in world:out.append(ocean.screen_position(p))
	for marker in ocean.salvage_markers():out.append(marker.rect.get_center())
	for label in ocean.label_targets:out.append(label.rect.get_center())
	for presenter in [ocean.Shelf,ocean.Recipient,ocean.Rendezvous]:
		for marker in presenter.markers(ocean,sim,touch):out.append(marker.rect.get_center())
	for box in ocean.objective_touch_rects(touch):out.append(box.get_center())
	return out.filter(func(p):return rect.has_point(p))
# The tappable objects now on the chart (not crafts or contacts): Array of context Dictionary, as the chooser would list them.
static func objects(host)->Array:
	var out:Array=[]
	if host.ocean==null or host.sim==null:return out
	var seen:Array=[]
	for spot in _seeds(host):
		for ctx in host.ocean.contexts_at(spot,host.ui_touch_height):
			if ctx.kind in ["craft","contact","fleet","extraction"]:continue
			var key:String="%s|%s|%s|%s"%[ctx.kind,str(ctx.get("name","")),str(ctx.get("station",ctx.get("item",ctx.get("index","")))),str(ctx.pos)]
			if key in seen:continue
			seen.append(key);out.append(ctx)
	return out
# The page a tap on this context opens (the chooser's own rule, mission_hud._open_target).
static func _next_page(ctx:Dictionary)->String:
	if ctx.get("subkind","")=="concealed":return "inspect"
	match ctx.kind:
		"habitat":return "habitat"
		"plant":return "plant"
		"objective":return "object"
		"salvage":return "salvage"
		"fleet":return "fleet"
	return "craft"
# The buttons of an object's wheel, read without opening it (subject and page are set for the read and put back).
static func object_buttons(hud,ctx:Dictionary)->Array:
	var kept_subject=hud.subject;var kept_page:String=hud.page
	hud.subject=ctx.duplicate(true);hud.page=_next_page(ctx)
	hud.refresh()
	var out:Array=[]
	for b in hud.command_controls():
		if b is Button and is_instance_valid(b) and key_of(b)!="inspect" and key_of(b)!="route_here":out.append(b)
	var rows:Array=out.map(func(b):return {"label":label_of(b),"enabled":not b.disabled,"reason":reason_of(b),"key":key_of(b)})
	hud.subject=kept_subject;hud.page=kept_page
	hud.refresh()
	return rows
# state: [{object,kind,controls:[{label,enabled,reason?}]}] for the visible objects that have buttons beyond ROUTE HERE / INSPECT.
static func object_pages(host)->Array:
	var hud=host.mission_hud
	var out:Array=[]
	if hud==null:return out
	for ctx in objects(host):
		var rows:Array=[]
		for r in object_buttons(hud,ctx):
			var row:Dictionary={"label":r.label,"enabled":r.enabled}
			if not r.enabled:row["reason"]=r.reason
			rows.append(row)
		if not rows.is_empty():out.append({"object":str(ctx.get("name",ctx.kind)),"kind":str(ctx.kind),"controls":rows})
	return out
# Press a button on an object's wheel. {} when nothing was found and no object was named (the caller reports its own miss).
static func _press_object(host,hud,request:Dictionary,craft:int,wanted:String,quiet:bool)->Dictionary:
	var named:String=_norm(request.get("object",""))
	var hits:Array=[];var every:Array=[]
	for ctx in objects(host):
		var name:String=_norm(ctx.get("name",""))
		if not named.is_empty() and not name.contains(named):continue
		for r in object_buttons(hud,ctx):
			var label:String=_norm(r.label)
			var entry:Dictionary={"ctx":ctx,"object":str(ctx.get("name","")),"key":r.key,"label":r.label,"enabled":r.enabled,"reason":r.reason}
			every.append("%s > %s%s"%[entry.object,entry.label,"" if entry.enabled else " (greyed out)"])
			if label==wanted or r.key.to_upper()==wanted or label.contains(wanted):hits.append(entry)
	if hits.is_empty():
		if quiet and named.is_empty():return {}
		return {"ok":false,"order":"control","refusal":"No object wheel button reads %s%s"%[wanted," on an object named %s"%named if not named.is_empty() else ""],"message":"","available":every}
	var exact:Array=hits.filter(func(e):return _norm(e.label)==wanted or e.key.to_upper()==wanted)
	if not exact.is_empty():hits=exact
	if hits.size()>1:
		var live:Array=hits.filter(func(e):return e.enabled)
		if request.has("index"):
			var i:int=int(request.index)
			if i<0 or i>=hits.size():return {"ok":false,"order":"control","refusal":"index %d: only %d object button(s) read %s"%[i,hits.size(),wanted],"message":""}
			hits=[hits[i]]
		elif live.size()==1:hits=live
		else:return {"ok":false,"order":"control","refusal":"More than one object button reads %s: name the object with object, or add index 0 to %d"%[wanted,hits.size()-1],"message":"","candidates":hits.map(func(e):return "%s > %s"%[e.object,e.label])}
	var pick:Dictionary=hits[0]
	_select(host,craft)
	hud.dismiss()
	hud._open_target(pick.ctx.duplicate(true)) # as the chooser's own choice does
	await _settle(host)
	var button:Button=null
	for b in hud.command_controls():
		if b is Button and key_of(b)==pick.key and b.is_visible_in_tree():button=b;break
	if button==null:
		hud.dismiss();return {"ok":false,"order":"control","refusal":"%s is not shown on %s's wheel just now"%[pick.label,pick.object],"message":""}
	if button.disabled:
		var reason:String=reason_of(button);var shown:String=label_of(button)
		hud.dismiss()
		return {"ok":false,"order":"control","refusal":"%s is greyed out: %s"%[shown,reason],"message":"","object":pick.object}
	var label:String=label_of(button);var taps:int=1
	hud.segments.tap(hud,button)
	if hud.segments.is_armed(button):hud.segments.tap(hud,button);taps=2
	await _settle(host)
	var out:Dictionary={"ok":true,"order":"control","pressed":label,"object":pick.object,"taps":taps,"craft":host.sim.units[craft].name,"message":_clean(host.sim.message)}
	if host.advanced_orders:hud.dismiss() # the object's wheel closes after its action
	return out
