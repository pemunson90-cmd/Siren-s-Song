extends SceneTree
# Item 142: pressing the briefing launch control over a live dive asks first (KEEP / ABANDON);
# with no live dive it launches at once. Also after a save restore (the C2-027 path).
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 7:await process_frame
func find(g,action,parent=null):
	for p in [g.menu_footer,g.panel_box] if parent==null else [parent]:
		for c in p.get_children():
			if c is Button and c.get_meta("action","")==action:return c
	return null
func resume_button(n):
	if n is Button and n.is_visible_in_tree() and n.text.begins_with("RESUME DIVE"):return n
	for c in n.get_children():
		var f=resume_button(c)
		if f!=null:return f
	return null
func press(b):
	b.pressed.emit();await settle()
func make(path):
	var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path=path
	root.add_child(g);await settle();g.set_process(false)
	return g
func cleanup(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func guard_round(g,tag):
	var a=g.mission_index
	var other=1 if a==0 else 0
	g.unlocked=max(g.unlocked,1)
	for index in [other,a]:
		g._briefing(index);await settle()
		var begin=find(g,"begin")
		check(begin!=null and not begin.disabled,tag+" briefing %d has an enabled launch control"%index)
		if begin==null or begin.disabled:continue
		var elapsed=g.sim.elapsed;var hull=g.sim.hull;var mission=g.sim.mission
		await press(begin)
		check(find(g,"launch_guard_keep")!=null and find(g,"launch_guard_abandon")!=null,tag+" confirm offers KEEP and ABANDON (briefing %d)"%index)
		check(g.sim.mission==mission and g.active_started,tag+" the dive is untouched while the confirm is open")
		var texts=[]
		for c in g.panel_box.get_children():
			if c is Label:texts.append(c.text)
		check(" ".join(texts).contains(g.sim.mission.title.to_upper()) and " ".join(texts).contains("hull") and " ".join(texts).contains("life support"),tag+" confirm names the dive with time, hull and life support")
		await press(find(g,"launch_guard_keep"))
		check(g.screen=="briefing" and g.sim.mission==mission and g.sim.elapsed==elapsed and g.sim.hull==hull and g.active_started,tag+" KEEP returns to the briefing with the dive untouched")
		g._show_campaign();await settle()
		check(resume_button(g)!=null,tag+" RESUME DIVE still offered after KEEP")
func run():
	root.size=Vector2i(2520,1080);await settle()
	var path="user://launch-guard-ui.save"
	var g=await make(path)
	g.unlocked=1
	# no live dive: launch starts at once
	g._briefing(0);await settle()
	await press(find(g,"begin"))
	check(find(g,"launch_guard_keep")==null and g.active_started,"no live dive: launch starts at once with no confirm")
	await guard_round(g,"live")
	# ABANDON launches the other operation
	g._briefing(1);await settle()
	await press(find(g,"begin"))
	await press(find(g,"launch_guard_abandon"))
	check(g.active_started and g.mission_index==1 and g.screen=="mission","ABANDON launches the chosen operation")
	g._save_archive()
	g.queue_free();await settle()
	# save restore path (C2-027)
	var r=await make(path)
	check(r.active_started,"restore brings back the active dive")
	if r.active_started:await guard_round(r,"restored")
	r.queue_free();await settle()
	cleanup(path)
	print("LAUNCH GUARD UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
