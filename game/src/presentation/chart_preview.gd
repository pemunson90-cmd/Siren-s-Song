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
const LABEL_INSET=6.0	# a label keeps this gap from the frame line, so no letter touches it
const FONT_SIZE=13.0
const HEIGHT_SHARE=0.26	# of the screen height; the picture never takes more than about a third of a column
const MIN_HEIGHT=96.0
const SCALE_BAR_METRES=1000.0	# world units are metres
const LABEL_QUIETUS="QUIETUS"
const LABEL_EXTRACTION="EXTRACT"
const LABEL_QUIETUS_EXTRACTION="QUIETUS · EXTRACT"	# WP-111: one label where Quietus starts inside the withdrawal circle
const LABEL_SEARCH="SEARCH"
const LABEL_SITE="SITE"
# WP-111: the briefing line for a target the dive marks as unknown: "<target>: marked as <dive label> on the chart until you photograph it."
const MARKED_AS="%s: marked as %s on the chart until you photograph it."
const MARK_GAP=3.0	# between a label and its marker
const MIN_FONT=11	# the smallest label size layout() will fall back to
const CORE_PX=8.0	# the Quietus dot's drawn radius
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
		# WP-111: an unresolved objective is marked in the dive by its alias ("UNKNOWN HEAT SOURCE"), so the picture
		# uses the same words (masked() already gives the alias) and remembers which target it stands for. The short
		# generic word is the fallback when the full name does not fit. Resolved sites carry their name, as in the dive.
		var unknown:bool=objective.get("unknown",false) and objective.has("alias")
		var named:String=str(site.get("name",""))
		var target:String=str(objective.get("name","")) if unknown else ""
		if site.get("stage","")=="lead":result.append({"pos":site.pos,"radius":float(site.get("lead_r",OBJECTIVE_AREA_RADIUS)),"label":named if unknown else LABEL_SEARCH,"texts":[named,LABEL_SEARCH] if unknown else [LABEL_SEARCH],"target":target,"search":true})
		else:result.append({"pos":site.pos,"radius":0.0,"label":named if not named.is_empty() else LABEL_SITE,"texts":[named,LABEL_SITE] if not named.is_empty() else [LABEL_SITE],"target":target,"search":false})
	return result
# WP-111: how each unresolved target will look in the dive, one line per target, from the same objective data the
# picture is drawn from. Only a target the picture marks (and the briefing names) gets a line.
static func marked_lines(mission:Dictionary)->Array:
	var lines:Array=[]
	for area in briefed_areas(mission):
		if area.target.is_empty() or area.label==area.target:continue
		lines.append(MARKED_AS%[area.target,area.label])
	return lines
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
	_marks(factor)
	draw_set_transform(Vector2.ZERO)
	# Rock runs past the region edge as in the dive; the picture ends at the frame.
	for rect in [Rect2(Vector2.ZERO,Vector2(size.x,box.position.y)),Rect2(Vector2(0,box.end.y),Vector2(size.x,size.y-box.end.y)),Rect2(Vector2(0,box.position.y),Vector2(box.position.x,box.size.y)),Rect2(Vector2(box.end.x,box.position.y),Vector2(size.x-box.end.x,box.size.y))]:draw_rect(rect,UiStyle.PANEL_FILL)
	draw_rect(box,FRAME,false,1.5)
	var font:=ThemeDB.fallback_font
	var plan:=layout(box,factor)
	for placed in plan.labels:draw_string(font,Vector2(placed.rect.position.x,placed.rect.end.y-2.0),placed.text,HORIZONTAL_ALIGNMENT_LEFT,-1,plan.px,placed.color)
	_scale_bar(factor,plan.scale,plan.px)
func _rock(poly:PackedVector2Array,factor:float)->void:
	var origin:=poly[0]
	for p in poly:origin=Vector2(minf(origin.x,p.x),minf(origin.y,p.y))
	var edge:Color=Color(style.edge,0.55) if style.has("edge") else RockPainter.EDGE
	RockPainter.rock(self,poly,origin,BASALT,style.get("stone",RockPainter.STONE),style.get("water",RockPainter.TINT),edge,1.0/factor)
# Draws the marks (lines and radii in world units divided by the factor, so they stay 1.5 pixels wide).
# Their labels are placed by layout(), in screen pixels, after the picture and its frame.
func _marks(factor:float)->void:
	var line:=1.5/factor
	if has_extraction:
		draw_arc(extraction,EXTRACTION_RADIUS,0.0,TAU,48,Color(UiStyle.ACCENT,0.8),line)
	for area in areas:
		if area.search:
			var step:=TAU/40.0
			for n in range(0,40,2):draw_arc(area.pos,area.radius,n*step,(n+1)*step,3,OBJECTIVE,line)
		else:
			draw_arc(area.pos,43.0,0.0,TAU,32,Color(OBJECTIVE,0.6),line)
			draw_line(area.pos-Vector2(14,0),area.pos+Vector2(14,0),OBJECTIVE,line)
			draw_line(area.pos-Vector2(0,14),area.pos+Vector2(0,14),OBJECTIVE,line)
	if has_start:
		draw_circle(start,8.0/factor,Color(UiStyle.TEXT,0.25))
		draw_circle(start,4.0/factor,UiStyle.TEXT)
func label_px()->int:return int(roundf(FONT_SIZE*text_scale))
# WP-111: the markers in screen pixels, in the order their labels are placed (Quietus, withdrawal, then objectives):
# {"c" centre, "r" radius, "ring" (a thin ring: only its line is an obstacle), "texts" (longest first), "color"}.
func _mark_list(box:Rect2,factor:float)->Array:
	var marks:Array=[]
	# The withdrawal circle is a ring: only its line is an obstacle. Where Quietus starts inside it (every operation that draws
	# both) the two share one label outside the ring, and the dot is a marker of its own.
	var together:bool=has_start and has_extraction and start.distance_to(extraction)<EXTRACTION_RADIUS
	if has_start:marks.append({"c":box.position+start*factor,"r":CORE_PX,"ring":false,"texts":[] if together else [LABEL_QUIETUS],"color":UiStyle.TEXT})
	if has_extraction:marks.append({"c":box.position+extraction*factor,"r":maxf(EXTRACTION_RADIUS*factor,CORE_PX+1.0 if together else 0.0),"ring":true,"texts":[LABEL_QUIETUS_EXTRACTION,LABEL_QUIETUS,LABEL_EXTRACTION] if together else [LABEL_EXTRACTION],"color":UiStyle.ACCENT})
	for area in areas:
		var radius:float=float(area.radius) if area.search else 43.0
		marks.append({"c":box.position+area.pos*factor,"r":radius*factor,"ring":area.search,"texts":area.texts,"color":OBJECTIVE})
	return marks
# Whether a label rectangle touches a marker: a filled marker takes its whole box, a search ring only its line.
static func hits(rect:Rect2,mark:Dictionary)->bool:
	var c:Vector2=mark.c
	var r:float=mark.r
	if not mark.ring:return rect.intersects(Rect2(c-Vector2.ONE*r,Vector2.ONE*r*2.0))
	var near:=Vector2(clampf(c.x,rect.position.x,rect.end.x),clampf(c.y,rect.position.y,rect.end.y)).distance_to(c)
	var far:=0.0
	for corner in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:far=maxf(far,corner.distance_to(c))
	return near<=r+1.0 and far>=r-1.0
var _rock_screen:Array=[]	# WP-132: the rock outlines in screen pixels, set by layout()
# Whether a label rectangle touches rock: a rock corner inside it, or a sample point of its outline or middle inside a rock.
var _avoid_rock:=false
func over_rock(rect:Rect2)->bool:
	if not _avoid_rock:return false
	for poly in _rock_screen:
		for p in poly:
			if rect.grow(1.0).has_point(p):return true
		for n in 9:
			var x:=rect.position.x+rect.size.x*float(n)/8.0
			for y in [rect.position.y,rect.position.y+rect.size.y*0.5,rect.end.y]:
				if Geometry2D.is_point_in_polygon(Vector2(x,y),poly):return true
	return false
# Where each label goes: beside its own marker (above, below, right, left, then inside a ring's top), whole inside the
# picture, clear of every marker line, of the scale bar and of the labels already placed. A label that finds no clear
# place falls back to its shorter text, and is dropped when that finds none either: less is shown, never an overlap.
# The picture is small and the text size setting multiplies the label size (a 150% setting once drew labels 60 px tall in
# a picture 175 px tall), so when labels do not all fit at the wanted size the whole set is tried again at smaller sizes
# down to MIN_FONT, and the size that keeps the most labels (largest first) wins.
# Returns {"labels":[{"rect","text","color"}],"marks":[...],"scale":Rect2,"px":int}.
func layout(box:Rect2,factor:float)->Dictionary:
	var marks:=_mark_list(box,factor)
	# WP-132: a label never sits over rock either (the briefing chart's "UNKNOWN SIGNAL SOURCE" ran across a rock).
	_rock_screen=rocks.map(func(poly):return PackedVector2Array(Array(poly).map(func(p):return box.position+p*factor)))
	var wanted:=label_px()
	var best:Dictionary={}
	var tried:Array=[]
	for share in [1.0,0.85,0.7,0.6,0.5,0.4]:
		var px:=maxi(MIN_FONT,int(roundf(wanted*share)))
		if px in tried:continue
		tried.append(px)
		# WP-132: clear of rock when that keeps every label; a label is never dropped only to stay off rock.
		_avoid_rock=true
		var attempt:=_layout_at(px,box,factor,marks)
		_avoid_rock=false
		var free:=_layout_at(px,box,factor,marks)
		if free.score>attempt.score:attempt=free
		if best.is_empty() or attempt.score>best.score:best=attempt
		if best.score>=marks.filter(func(mark):return not mark.texts.is_empty()).size()*2:break
		if px==MIN_FONT:break
	# The scale bar is the least important mark: bottom left, else bottom right, else left out (never over a label or marker).
	var placed:Array=best.labels
	var scale_rect:=Rect2()
	for at_right in [false,true]:
		var candidate:=scale_bar_rect(box,factor,best.px,at_right)
		if candidate.size==Vector2.ZERO:break
		if placed.any(func(other):return other.rect.grow(1.0).intersects(candidate)) or marks.any(func(other):return hits(candidate.grow(1.0),other)):continue
		scale_rect=candidate;break
	return {"labels":placed,"marks":marks,"scale":scale_rect,"px":best.px}
# One try at one font size. The score is 2 for a mark labelled with its full words, 1 for its shorter words, 0 for none.
func _layout_at(px:int,box:Rect2,factor:float,marks:Array)->Dictionary:
	var font:=ThemeDB.fallback_font
	var height:=px+2.0
	var inner:=Rect2(box.position+Vector2.ONE*LABEL_INSET,box.size-Vector2.ONE*LABEL_INSET*2.0)
	var placed:Array=[]
	var score:=0
	for mark in marks:
		var done:=false
		var rank:=0
		for text in mark.texts:
			if text.is_empty():continue
			var width:=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,px).x
			rank+=1
			if width>inner.size.x or height>inner.size.y:continue
			var c:Vector2=mark.c;var r:float=mark.r
			var spots:Array=[Vector2(c.x-width/2.0,c.y-r-MARK_GAP-height),Vector2(c.x-width/2.0,c.y+r+MARK_GAP),Vector2(c.x+r+MARK_GAP,c.y-height/2.0),Vector2(c.x-r-MARK_GAP-width,c.y-height/2.0)]
			if mark.ring:spots.append(Vector2(c.x-width/2.0,c.y-r+MARK_GAP+2.0))
			for spot in spots:
				var rect:=Rect2(Vector2(clampf(spot.x,inner.position.x,inner.end.x-width),clampf(spot.y,inner.position.y,inner.end.y-height)),Vector2(width,height))
				if marks.any(func(other):return hits(rect,other)) or over_rock(rect):continue
				if placed.any(func(other):return other.rect.grow(1.0).intersects(rect)):continue
				# A repeat of the same words close by is dropped, as the dive groups areas of one name.
				if not placed.any(func(other):return other.text==text and other.rect.position.distance_to(rect.position)<width*2.0):placed.append({"rect":rect,"text":text,"color":mark.color})
				done=true;break
			if done:break
		if done:score+=3-rank if rank<3 else 1
	return {"labels":placed,"px":px,"score":score}
# The scale bar and its "1 km" words, as one rectangle (empty when the bar does not fit the picture).
func scale_bar_rect(box:Rect2,factor:float,label_size:int,at_right:bool=false)->Rect2:
	var length:=SCALE_BAR_METRES*factor
	if length>box.size.x*0.5 or length<4.0:return Rect2()
	var px:=int(roundf(label_size*0.9))
	var words:=ThemeDB.fallback_font.get_string_size("1 km",HORIZONTAL_ALIGNMENT_LEFT,-1,px).x
	var total:=length+6.0+words
	var x:=box.end.x-8.0-total if at_right else box.position.x+8.0
	var y:=box.end.y-8.0
	return Rect2(x,y-px,total,px+4.0)
func _scale_bar(factor:float,rect:Rect2,label_size:int)->void:
	if rect.size==Vector2.ZERO:return
	var length:=SCALE_BAR_METRES*factor
	var y:=rect.position.y+int(roundf(label_size*0.9))
	var x:=rect.position.x
	draw_line(Vector2(x,y),Vector2(x+length,y),UiStyle.QUIET_TEXT,2.0)
	draw_line(Vector2(x,y-3),Vector2(x,y+3),UiStyle.QUIET_TEXT,1.5)
	draw_line(Vector2(x+length,y-3),Vector2(x+length,y+3),UiStyle.QUIET_TEXT,1.5)
	draw_string(ThemeDB.fallback_font,Vector2(x+length+6.0,y+4.0),"1 km",HORIZONTAL_ALIGNMENT_LEFT,-1,int(roundf(label_size*0.9)),UiStyle.QUIET_TEXT)
