extends Control
# A small picture of the operation's chart, shown before the dive (briefing and region entry card).
# It is a picture, not a control: it takes no taps. It shows what the dive opens with and no more:
# the region outline, charted rock (art/rock_painter.gd, the dive's own rock drawing), the Quietus
# start, the extraction circle and the briefed objective areas. It never shows listeners, Siren
# positions, hidden objectives, or rock of an operation whose terrain the dive charts as it is sensed.
const RockPainter=preload("res://src/presentation/art/rock_painter.gd")
const WorldRegion=preload("res://src/simulation/world_region.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const BASALT=preload("res://assets/materials/basalt.png")
const WATER=Color("050f17")
const FRAME=Color("47636a")
const OBJECTIVE=Color("e1b66e")	# the dive's briefed-site colour (ocean_view.gd)
const OBJECTIVE_AREA_RADIUS=150.0
const EXTRACTION_RADIUS=64.0	# as the dive draws it
const MARGIN=6.0
const FONT_SIZE=13.0
const HEIGHT_SHARE=0.26	# of the screen height; the picture never takes more than about a third of a column
const MIN_HEIGHT=96.0
const SCALE_BAR_METRES=1000.0	# world units are metres
const LABEL_QUIETUS="QUIETUS"
const LABEL_EXTRACTION="EXTRACT"
const LABEL_SEARCH="SEARCH"
const LABEL_SITE="SITE"
var region:=WorldRegion.LEGACY_SIZE
var rocks:Array=[]	# polygons
var start:=Vector2.ZERO
var has_start:=false
var extraction:=Vector2.ZERO
var has_extraction:=false
var areas:Array=[]	# {"pos","radius","label","search"}
var style:Dictionary={}
var text_scale:=1.0
# The one entry point: adds the preview to `parent` (at `index` when given) for one mission dictionary.
# `screen_height` sets its height and `text_scale` its label size (touch height over 48 times the text setting).
static func attach(parent:Node,mission:Dictionary,screen_height:float,label_scale:float=1.0,index:int=-1)->Control:
	var view=load("res://src/presentation/chart_preview.gd").new()
	view.setup(mission,screen_height,label_scale)
	parent.add_child(view)
	if index>=0:parent.move_child(view,index)
	return view
func setup(mission:Dictionary,screen_height:float,label_scale:float)->void:
	name="ChartPreview";mouse_filter=Control.MOUSE_FILTER_IGNORE;texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
	size_flags_horizontal=Control.SIZE_EXPAND_FILL;text_scale=label_scale
	clip_contents=true
	custom_minimum_size.y=maxf(MIN_HEIGHT,screen_height*HEIGHT_SHARE)
	region=WorldRegion.size_of(mission)
	rocks=visible_rock(mission)
	if mission.has("start"):start=mission.start;has_start=true
	# An expedition's withdrawal is drawn by the dive only at its entry operation.
	if mission.has("extraction") and (not mission.has("expedition_revision") or mission.id==6):extraction=mission.extraction;has_extraction=true
	areas=briefed_areas(mission)
	var table=load("res://src/presentation/art/region_table.gd")
	style=table.style(mission)
# Rock the dive draws from its first frame. An operation with earned terrain (and the Glass-bound operation 8)
# charts rock only as it is sensed, so the preview shows none.
static func visible_rock(mission:Dictionary)->Array:
	if mission.get("earned_terrain",false) or mission.get("id",-1)==8:return []
	var result:Array=[]
	for rock in mission.get("depth_geometry",{}).get(1,{}).get("rocks",mission.get("rocks",[])):result.append(load("res://src/simulation/simulation.gd").rock_polygon(rock))
	return result
# Briefed objective areas as the dive's first frame shows them (observable_sites): named sites at their
# briefed position, unfound sites as a search area. Siren-linked, origin-bound and expedition-signal sites
# are left out: if unsure, show less.
static func briefed_areas(mission:Dictionary)->Array:
	var result:Array=[]
	if mission.get("id",-1)==8 or mission.has("expedition_revision"):return result
	var objectives:Array=mission.get("objectives",[])
	if mission.has("warning_chain"):objectives=objectives.slice(0,2)
	for objective in objectives:
		var site:Dictionary=Photo.masked(objective)
		if site.get("own_origin",false) or site.has("siren") or not site.has("pos"):continue
		if site.get("stage","")=="lead":result.append({"pos":site.pos,"radius":float(site.get("lead_r",OBJECTIVE_AREA_RADIUS)),"label":LABEL_SEARCH,"search":true})
		else:result.append({"pos":site.pos,"radius":0.0,"label":LABEL_SITE,"search":false})
	return result
# Where the region sits inside the control, and how many control pixels one world unit takes.
func fit()->Rect2:
	var room:=size-Vector2.ONE*MARGIN*2.0
	var factor:=minf(room.x/region.x,room.y/region.y)
	if factor<=0.0:return Rect2()
	var drawn:=region*factor
	return Rect2((size-drawn)/2.0,drawn)
func _draw()->void:
	var box:=fit()
	if box.size==Vector2.ZERO:return
	var factor:=box.size.x/region.x
	draw_rect(box,WATER)
	draw_set_transform(box.position,0.0,Vector2.ONE*factor)
	for poly in rocks:_rock(poly,factor)
	var labels:=_marks(factor)
	draw_set_transform(Vector2.ZERO)
	# Rock runs past the region edge as in the dive; the picture ends at the frame.
	for rect in [Rect2(Vector2.ZERO,Vector2(size.x,box.position.y)),Rect2(Vector2(0,box.end.y),Vector2(size.x,size.y-box.end.y)),Rect2(Vector2(0,box.position.y),Vector2(box.position.x,box.size.y)),Rect2(Vector2(box.end.x,box.position.y),Vector2(size.x-box.end.x,box.size.y))]:draw_rect(rect,UiStyle.PANEL_FILL)
	draw_rect(box,FRAME,false,1.5)
	var placed:Array=[]
	for mark in labels:_label(box,factor,mark,placed)
	_scale_bar(box,factor)
func _rock(poly:PackedVector2Array,factor:float)->void:
	var origin:=poly[0]
	for p in poly:origin=Vector2(minf(origin.x,p.x),minf(origin.y,p.y))
	var edge:Color=Color(style.edge,0.55) if style.has("edge") else RockPainter.EDGE
	RockPainter.rock(self,poly,origin,BASALT,style.get("stone",RockPainter.STONE),style.get("water",RockPainter.TINT),edge,1.0/factor)
# Draws the marks (lines and radii in world units divided by the factor, so they stay 1.5 pixels wide)
# and returns the labels, which are drawn afterwards in screen pixels.
func _marks(factor:float)->Array:
	var line:=1.5/factor
	var labels:=[]
	if has_extraction:
		draw_arc(extraction,EXTRACTION_RADIUS,0.0,TAU,48,Color(UiStyle.ACCENT,0.8),line)
		labels.append({"at":extraction+Vector2(0,EXTRACTION_RADIUS),"below":true,"text":LABEL_EXTRACTION,"color":UiStyle.ACCENT})
	for area in areas:
		if area.search:
			var step:=TAU/40.0
			for n in range(0,40,2):draw_arc(area.pos,area.radius,n*step,(n+1)*step,3,OBJECTIVE,line)
			labels.append({"at":area.pos+Vector2(0,-area.radius),"below":false,"text":area.label,"color":OBJECTIVE})
		else:
			draw_arc(area.pos,43.0,0.0,TAU,32,Color(OBJECTIVE,0.6),line)
			draw_line(area.pos-Vector2(14,0),area.pos+Vector2(14,0),OBJECTIVE,line)
			draw_line(area.pos-Vector2(0,14),area.pos+Vector2(0,14),OBJECTIVE,line)
			labels.append({"at":area.pos+Vector2(0,-43.0),"below":false,"text":area.label,"color":OBJECTIVE})
	if has_start:
		draw_circle(start,8.0/factor,Color(UiStyle.TEXT,0.25))
		draw_circle(start,4.0/factor,UiStyle.TEXT)
		labels.append({"at":start+Vector2(0,-8.0/factor),"below":false,"text":LABEL_QUIETUS,"color":UiStyle.TEXT})
	return labels
# A label centred on its mark, above or below it, kept inside the picture. A label that would cover one
# already drawn moves up a line at a time; a repeat of the same word close by is dropped.
func _label(box:Rect2,factor:float,mark:Dictionary,placed:Array)->void:
	var font:=ThemeDB.fallback_font
	var px:=int(roundf(FONT_SIZE*text_scale))
	var width:=font.get_string_size(mark.text,HORIZONTAL_ALIGNMENT_LEFT,-1,px).x
	var at:Vector2=box.position+mark.at*factor
	var x:=clampf(at.x-width/2.0,box.position.x+2.0,box.end.x-width-2.0)
	var base:=at.y+px+2.0 if mark.below else at.y-4.0
	var rect:=Rect2()
	for attempt in 4:
		var line_y:=clampf(base-attempt*(px+2.0),box.position.y+px,box.end.y-2.0)
		rect=Rect2(x,line_y-px,width,px+2.0)
		if not placed.any(func(other):return other.rect.intersects(rect)):break
	if placed.any(func(other):return other.text==mark.text and other.rect.position.distance_to(rect.position)<width*2.0):return
	placed.append({"rect":rect,"text":mark.text})
	draw_string(font,Vector2(rect.position.x,rect.end.y-2.0),mark.text,HORIZONTAL_ALIGNMENT_LEFT,-1,px,mark.color)
func _scale_bar(box:Rect2,factor:float)->void:
	var length:=SCALE_BAR_METRES*factor
	if length>box.size.x*0.5 or length<4.0:return
	var y:=box.end.y-8.0
	var x:=box.position.x+8.0
	draw_line(Vector2(x,y),Vector2(x+length,y),UiStyle.QUIET_TEXT,2.0)
	draw_line(Vector2(x,y-3),Vector2(x,y+3),UiStyle.QUIET_TEXT,1.5)
	draw_line(Vector2(x+length,y-3),Vector2(x+length,y+3),UiStyle.QUIET_TEXT,1.5)
	draw_string(ThemeDB.fallback_font,Vector2(x+length+6.0,y+4.0),"1 km",HORIZONTAL_ALIGNMENT_LEFT,-1,int(roundf(FONT_SIZE*text_scale*0.9)),UiStyle.QUIET_TEXT)
