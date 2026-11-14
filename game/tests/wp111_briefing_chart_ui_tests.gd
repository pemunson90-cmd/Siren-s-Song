extends SceneTree
# WP-111 (blind critics, round 8): on the operation briefing the chart picture's labels stay clear of every marker, of the
# scale bar and of each other at 100%, 130% and 150% text, on the cover screen (1680x720) and the inner screen (1280x1153);
# the briefing shows a "MORE BELOW" cue while it scrolls and drops it at the end; an unresolved target is labelled on the
# picture with the words the dive uses, and the briefing says how it will look in the dive; the route map's - then +
# returns to the spot the player was looking at.
const Preview=preload("res://src/presentation/chart_preview.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Missions=preload("res://src/campaign/missions.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const View=preload("res://src/presentation/route_map/route_map_view.gd")
const Cue=preload("res://src/presentation/scroll_cue.gd")
const SHAPES=[Vector2i(1680,720),Vector2i(1280,1153)]
const SCALES=[1.0,1.3,1.5]
const OPS=[0,1,3,5]
var checks=0
var failures=0
var labelled_total=0
var overflowed=0
var round_trips=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 7:await process_frame
func make(path):
	var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path=path
	root.add_child(g);await settle();g.set_process(false)
	return g
func cleanup(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
# Item 4, from the data alone: the picture's label for an unresolved target is the dive's own word for it.
func data_rules():
	var mission=Missions.make(3,{})
	var unknown=mission.objectives.filter(func(o):return o.get("unknown",false))
	check(unknown.size()>=2,"operation 4 has unresolved targets (the heat source and the structure)")
	var areas=Preview.briefed_areas(mission)
	for objective in unknown:
		var dive_word:String=Photo.label(objective)
		check(areas.any(func(a):return a.label==dive_word and a.texts[0]==dive_word and a.target==objective.name),"the picture labels %s as %s, as the dive does"%[objective.name,dive_word])
	var lines=Preview.marked_lines(mission)
	check(lines.size()==unknown.size(),"one briefing line per unresolved target: %s"%str(lines))
	check(lines.any(func(line):return line.begins_with("FURNACE VENT: marked as UNKNOWN HEAT SOURCE")) and lines.any(func(line):return line.begins_with("LAUNCH CRADLE: marked as UNKNOWN STRUCTURE")),"the lines name the furnace and the cradle with the dive's words: %s"%str(lines))
	for id in range(0,30):
		for line in Preview.marked_lines(Missions.make(id,{})):check(not line.contains("null") and line.contains(": marked as "),"operation %d line reads whole: %s"%[id,line])
func label_rules(view,tag):
	var box:Rect2=view.fit()
	if box.size==Vector2.ZERO:return
	var factor:float=box.size.x/view.region.x
	var result:Dictionary=view.layout(box,factor)
	var labels:Array=result.labels
	labelled_total+=labels.size()
	check(labels.any(func(l):return l.text.contains(Preview.LABEL_QUIETUS)) or not view.has_start,"%s: the Quietus start keeps its label (box %s scale %s labels %s marks %s)"%[tag,str(box),str(view.text_scale),str(labels.map(func(l):return [l.text,l.rect])),str(result.marks.map(func(m):return [m.c,m.r,m.texts]))])
	for n in labels.size():
		var rect:Rect2=labels[n].rect
		check(box.encloses(rect),"%s: label %s is whole inside the picture %s of %s"%[tag,labels[n].text,rect,box])
		for mark in result.marks:check(not Preview.hits(rect,mark),"%s: label %s clear of the marker at %s"%[tag,labels[n].text,mark.c])
		if result.scale.size!=Vector2.ZERO:check(not rect.intersects(result.scale),"%s: label %s clear of the scale bar"%[tag,labels[n].text])
		for m in range(n+1,labels.size()):check(not rect.intersects(labels[m].rect),"%s: labels %s and %s do not overlap"%[tag,labels[n].text,labels[m].text])
func briefing_case(g,shape,scale,index):
	var tag="%s %d%% op %d"%[shape,roundi(scale*100.),index+1]
	g._briefing(index);await settle()
	g._briefing(index);await settle()
	var found=g.panel_box.find_children("ChartPreview","Control",true,false)
	check(found.size()==1,"%s: one chart preview"%tag)
	if found.is_empty():return
	label_rules(found[0],tag)
	if index==3:
		var lines=Preview.marked_lines(Missions.make(3,g._launch_context(3)))
		for line in lines:
			var shown=g.panel_box.find_children("*","Label",true,false).filter(func(l):return l.text==line and l.is_visible_in_tree())
			check(shown.size()==1,"%s: the briefing says '%s'"%[tag,line])
	# Item 3: the cue shows while the body runs on below the screen and goes at its end.
	var cue=g.get_node_or_null("ScrollCue")
	check(cue!=null,"%s: the scroll cue exists"%tag)
	if cue==null:return
	var more:bool=cue.more_below()
	check(cue.visible==more,"%s: the cue is shown exactly when there is more below (more %s, cue %s)"%[tag,str(more),str(cue.visible)])
	if more:
		overflowed+=1
		check(g.scroll.get_global_rect().grow(1.0).encloses(cue.get_global_rect()),"%s: the cue sits on the scroll area %s of %s"%[tag,cue.get_global_rect(),g.scroll.get_global_rect()])
		check(cue.mouse_filter==Control.MOUSE_FILTER_IGNORE,"%s: the cue takes no taps"%tag)
		g.scroll.scroll_vertical=int(g.scroll.get_v_scroll_bar().max_value);await settle()
		check(not cue.more_below() and not cue.visible,"%s: the cue is gone at the end of the text"%tag)
		g.scroll.scroll_vertical=0;await settle()
		check(cue.visible,"%s: the cue returns at the top"%tag)
func center_node(view):
	var center:Vector2=Vector2(view.chart.scroll_horizontal,view.chart.scroll_vertical)+view.chart.size*.5
	var best:=-1;var distance:=INF
	for id in view.board.centers:
		var d:float=(view.board.centers[id]-center).length()
		if d<distance:distance=d;best=id
	return best
# Item 2: - then + comes back to what the player was looking at.
func route_case(shape,scale):
	root.size=shape;await settle()
	var path="user://wp111-route.save"
	var g=await make(path)
	Settings.current["text_scale"]=scale;g._layout()
	g.completed=[0,1,2,3,4,5];g.unlocked=5;g.active_started=false
	g._show_campaign();await settle()
	View.open(g);await settle();await settle()
	var view=g.get_node_or_null("RouteMapView")
	check(view!=null,"route map opens %s"%str(shape))
	if view!=null:
		for step in 4:view._zoom(1)
		await settle();await settle()
		for target in [view.graph.nodes[view.graph.nodes.size()-1].id,view.graph.nodes[view.graph.nodes.size()/2].id,view.graph.nodes[3].id]:
			view._center_on(view.board.centers[target]);await settle();await settle()
			var before:int=center_node(view);var zoom_before:float=view.zoom
			var scrolled:bool=view.board.size.x>view.chart.size.x+1. or view.board.size.y>view.chart.size.y+1.
			view._zoom(-1);await settle();await settle()
			view._zoom(1);await settle();await settle()
			check(view.zoom==zoom_before,"- then + returns to the same zoom %s"%str(shape))
			if scrolled:round_trips+=1
			if scrolled:check(center_node(view)==before,"%s %d%%: - then + keeps looking at operation %d, not %d"%[str(shape),roundi(scale*100.),before,center_node(view)])
		# Through the overview (nothing scrolls there) and back.
		var start_zoom:float=view.zoom;var looking:int=center_node(view)
		var steps:int=0
		while view.zoom>view.zoom_floor+.001 and steps<20:view._zoom(-1);steps+=1;await settle()
		await settle()
		for n in steps:view._zoom(1);await settle()
		await settle();await settle()
		if view.zoom>=start_zoom-.001:check(center_node(view)==looking,"%s %d%%: zooming out to the overview and back keeps looking at operation %d, not %d"%[str(shape),roundi(scale*100.),looking,center_node(view)])
	g.queue_free();await settle();cleanup(path)
func run():
	data_rules()
	var prior=Settings.text_scale()
	var path="user://wp111-briefing.save"
	for shape in SHAPES:
		root.size=shape;await settle()
		for scale in SCALES:
			var g=await make(path)
			Settings.current["text_scale"]=scale;g._layout();g.unlocked=5;await settle()
			for index in OPS:await briefing_case(g,shape,scale,index)
			g.queue_free();await settle();cleanup(path)
	check(labelled_total>0,"labels were placed (%d)"%labelled_total)
	check(overflowed>0,"at least one briefing scrolled, so the cue was exercised (%d)"%overflowed)
	for shape in SHAPES:
		for scale in [1.0,1.5]:await route_case(shape,scale)
	check(round_trips>0,"the route map had a scrolled board to round-trip (%d)"%round_trips)
	Settings.current["text_scale"]=prior
	print("WP111 BRIEFING CHART UI CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
