extends SceneTree
# The chart preview in the briefing and the region entry card: it exists, it sits inside its column,
# it is not a control, it never pushes the footer off-screen, and it shows only what the dive opens with.
const Preview=preload("res://src/presentation/chart_preview.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Missions=preload("res://src/campaign/missions.gd")
const SHAPES=[Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(1080,2400)]
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 7:await process_frame
# Pictures for a person to look at: only when a window exists and CHART_PREVIEW_CAPTURE names a folder.
func capture(label):
	var folder=OS.get_environment("CHART_PREVIEW_CAPTURE")
	if folder.is_empty() or DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder+"/"+label+".png")
func make(path):
	var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path=path
	root.add_child(g);await settle();g.set_process(false)
	return g
func cleanup(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func previews(node):
	return node.find_children("ChartPreview","Control",true,false)
# What the picture may show, from the data alone: no rock for an earned-terrain operation, no area
# the dive keeps hidden, and nothing outside the region.
func data_rules():
	var any_rock=false;var any_area=false
	for id in Catalog.registered_ids():
		var mission=Missions.make(id,{})
		var rocks=Preview.visible_rock(mission)
		var areas=Preview.briefed_areas(mission)
		if mission.get("earned_terrain",false) or id==8:check(rocks.is_empty(),"operation %d (earned terrain) shows no rock"%id)
		if mission.has("expedition_revision") or id==8:check(areas.is_empty(),"operation %d shows no objective area"%id)
		any_rock=any_rock or not rocks.is_empty();any_area=any_area or not areas.is_empty()
		var region=Vector2(mission.get("world_size",Vector2(1600,960)))
		for area in areas:check(area.pos.x>=0 and area.pos.y>=0 and area.pos.x<=region.x and area.pos.y<=region.y,"operation %d area %s lies inside the region"%[id,area.label])
		for objective in mission.get("objectives",[]):
			if objective.has("siren"):check(areas.all(func(a):return not a.pos.is_equal_approx(objective.pos)),"operation %d keeps a Siren-linked site off the picture"%id)
	check(any_rock,"some operation shows charted rock");check(any_area,"some operation shows a briefed area")
func briefing_case(g,shape,index):
	g._briefing(index);await settle()
	g._briefing(index);await settle()
	await capture("briefing_%d_%d"%[shape.x,index])
	var found=previews(g.panel_box)
	check(found.size()==1,"%s briefing %d has exactly one chart preview"%[shape,index])
	if found.is_empty():return
	var view=found[0]
	check(view.mouse_filter==Control.MOUSE_FILTER_IGNORE,"%s briefing %d: the preview takes no taps"%[shape,index])
	var column:Control=view.get_parent()
	var inside=column.get_global_rect().grow(1.0).encloses(view.get_global_rect())
	check(inside,"%s briefing %d: the preview sits inside its column"%[shape,index])
	check(view.size.x>=100 and view.size.y>=Preview.MIN_HEIGHT-1.0,"%s briefing %d: the preview has a readable size %s"%[shape,index,view.size])
	check(view.size.y<=g.size.y*Preview.HEIGHT_SHARE+Preview.MIN_HEIGHT,"%s briefing %d: the preview stays within its share of the screen"%[shape,index])
	var scroll_box:Rect2=g.scroll.get_global_rect()
	check(view.get_global_rect().position.x>=scroll_box.position.x-1.0 and view.get_global_rect().end.x<=scroll_box.end.x+1.0,"%s briefing %d: the preview is within the scrolling panel horizontally %s of %s"%[shape,index,view.get_global_rect(),scroll_box])
	var footer:Rect2=g.menu_footer.get_global_rect()
	check(g.menu_footer.visible and footer.end.y<=g.size.y+1.0 and footer.position.y>=0,"%s briefing %d: the footer stays on screen %s of %s"%[shape,index,footer,g.size])
	var begin=null
	for c in g.menu_footer.get_children():
		if c is Button and c.get_meta("action","")=="begin":begin=c
	check(begin!=null and g.get_viewport_rect().encloses(begin.get_global_rect()),"%s briefing %d: the launch control is on screen"%[shape,index])
	# A two-column briefing puts the picture above the loadout, in the right column.
	var loadout=null
	for c in g.panel_box.find_children("*","Button",true,false):
		if c.get_meta("action","")=="edit_racks":loadout=c
	if loadout!=null and loadout.get_parent()==view.get_parent():check(view.get_index()<loadout.get_index(),"%s briefing %d: the preview sits above the loadout"%[shape,index])
func arc_case(g,shape):
	g.set_meta("arc_seen",{})
	g._show_campaign();await settle()
	g.unlocked=max(g.unlocked,1)
	var Arc=load("res://src/presentation/arcs/arc_card.gd")
	var Table=load("res://src/campaign/arcs/arc_table.gd")
	var arc=Table.ARCS[0]
	g._briefing(arc.first);await settle()
	var card=g.get_node_or_null("ArcCard")
	if card==null:
		Arc.intro(g,arc.first);await settle();card=g.get_node_or_null("ArcCard")
	check(card!=null,"%s region entry card opens"%shape)
	if card==null:return
	await capture("arc_card_%d"%shape.x)
	var found=previews(card)
	check(found.size()==1,"%s region entry card has one chart preview"%shape)
	if found.is_empty():return
	var view=found[0]
	check(card.get_global_rect().grow(1.0).encloses(view.get_global_rect()),"%s region entry card: the preview is inside the card"%shape)
	var buttons=card.find_children("*","Button",true,false)
	check(not buttons.is_empty() and g.get_viewport_rect().encloses(buttons[0].get_global_rect()),"%s region entry card: CONTINUE stays on screen"%shape)
	card.dismiss();await settle()
func run():
	data_rules()
	var path="user://chart-preview-ui.save"
	for shape in SHAPES:
		root.size=shape;await settle()
		var g=await make(path)
		g.unlocked=3
		for index in [0,1,3]:await briefing_case(g,shape,index)
		await arc_case(g,shape)
		g.queue_free();await settle()
		cleanup(path)
	print("CHART PREVIEW UI CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
