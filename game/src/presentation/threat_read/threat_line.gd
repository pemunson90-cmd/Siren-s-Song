extends RefCounted
# Threat line: a red line from a threatened craft toward the Siren that is locking it, with the
# countdown at the craft's end; or, when only a bearing is known, a wedge of honest width.
# Screen space, drawn by ocean_view through ThreatRead.draw_screen (above terrain, below the HUD)
# and by first_siren_cue for the bearing wedge. Presentation only; draws no allocation.
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const Compass=preload("res://src/presentation/compass.gd")
static func tint()->Color:
	return Palette.chart_color("threat",UiStyle.DANGER_RED)
# A line from the craft (from) toward the Siren's known position (to), cut at the chart edge.
# Returns true when something was drawn. number is the countdown text at the craft's end.
static func line(canvas,from:Vector2,to:Vector2,number:String,font_size:int,bounds:Rect2)->bool:
	var across:Vector2=to-from
	var length:float=across.length()
	if length<1.0 or not bounds.has_point(from):return false
	var dir:Vector2=across/length
	var tip:Vector2=to-dir*UiStyle.THREAT_STANDOFF if bounds.has_point(to) else _clip(from,to,bounds)
	var red:Color=tint()
	var width:float=Palette.stroke(UiStyle.THREAT_LINE_WIDTH)
	var beyond:float=(tip-from).dot(dir)
	if beyond>UiStyle.THREAT_STANDOFF:
		canvas.draw_line(from,tip,UiStyle.THREAT_LINE_BACK,UiStyle.THREAT_LINE_HALO)
		canvas.draw_line(from,tip,red,width)
		for side in [UiStyle.THREAT_ARROW_SPREAD,-UiStyle.THREAT_ARROW_SPREAD]:
			var barb:Vector2=tip-dir.rotated(side)*UiStyle.THREAT_ARROW_LENGTH
			canvas.draw_line(tip,barb,UiStyle.THREAT_LINE_BACK,UiStyle.THREAT_LINE_HALO)
			canvas.draw_line(tip,barb,red,width)
	if not number.is_empty():_number(canvas,from+dir*(UiStyle.THREAT_STANDOFF+font_size),number,font_size+UiStyle.THREAT_NUMBER_BOOST,red)
	return true
# A bearing wedge from the craft: two edges and an arc, never a position or a range.
static func wedge(canvas,from:Vector2,bearing_degrees:float,length:float)->void:
	var red:Color=tint()
	var width:float=Palette.stroke(UiStyle.THREAT_LINE_WIDTH)
	var half:float=UiStyle.THREAT_WEDGE_HALF_DEGREES
	for side in [-half,half]:
		var dir:Vector2=Compass.direction(bearing_degrees+side)
		canvas.draw_line(from+dir*UiStyle.THREAT_STANDOFF,from+dir*length,UiStyle.THREAT_LINE_BACK,UiStyle.THREAT_LINE_HALO)
		canvas.draw_line(from+dir*UiStyle.THREAT_STANDOFF,from+dir*length,red,width)
	canvas.draw_arc(from,length,deg_to_rad(bearing_degrees-half-90.0),deg_to_rad(bearing_degrees+half-90.0),16,red,width)
# The point where the segment leaves the rectangle; from must be inside it.
static func _clip(from:Vector2,to:Vector2,rect:Rect2)->Vector2:
	var d:Vector2=to-from
	var t:float=1.0
	if d.x>0.0:t=minf(t,(rect.end.x-from.x)/d.x)
	elif d.x<0.0:t=minf(t,(rect.position.x-from.x)/d.x)
	if d.y>0.0:t=minf(t,(rect.end.y-from.y)/d.y)
	elif d.y<0.0:t=minf(t,(rect.position.y-from.y)/d.y)
	return from+d*maxf(t,0.0)
static func _number(canvas,at:Vector2,text:String,font_size:int,red:Color)->void:
	var font:Font=ThemeDB.fallback_font
	var size:Vector2=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
	var pad:float=UiStyle.THREAT_NUMBER_PAD
	var box:=Rect2(at-size*0.5-Vector2(pad,pad),size+Vector2(pad,pad)*2.0)
	canvas.draw_rect(box,UiStyle.THREAT_LINE_BACK)
	canvas.draw_rect(box,red,false,Palette.stroke(2.0))
	canvas.draw_string(font,Vector2(box.position.x+pad,box.position.y+pad+font.get_ascent(font_size)),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color.WHITE)
