extends Control
# A meter drawn to true scale (UI review C7). The fill is value / scale_max of the bar's width, so the bar and
# the number printed above it agree. A stock mark (the tick and the word STOCK) shows where the stock value
# sits; a value above stock runs past the tick, a value below stops short of it.
const UiStyle=preload("res://src/presentation/ui_style.gd")
var value:=0.0
var scale_max:=1.0
var stock:=-1.0	# the stock value on the same scale; negative draws no stock mark
var over:=false
var unit_height:=48.0
func fraction()->float:
	return clampf(value/scale_max,0.0,1.0) if scale_max>0.0 else 0.0
func stock_fraction()->float:
	return clampf(stock/scale_max,0.0,1.0) if stock>=0.0 and scale_max>0.0 else -1.0
func bar_height()->float:
	return maxf(8.0,unit_height*0.18)
func label_size()->int:
	return roundi(UiStyle.BAR_LABEL_SIZE*unit_height/48.0)
func _ready()->void:
	mouse_filter=Control.MOUSE_FILTER_PASS
	size_flags_horizontal=Control.SIZE_EXPAND_FILL
	custom_minimum_size=Vector2(0,bar_height()+(label_size()+6.0 if stock>=0.0 else 0.0))
func _draw()->void:
	var height:=bar_height()
	draw_rect(Rect2(0,0,size.x,height),UiStyle.BAR_BACK)
	draw_rect(Rect2(0,0,size.x*fraction(),height),UiStyle.BAR_OVER if over else UiStyle.BAR_FILL)
	var at:=stock_fraction()
	if at<0.0:return
	var x:=size.x*at
	draw_line(Vector2(x,-2),Vector2(x,height+3),UiStyle.BAR_TICK,UiStyle.BAR_TICK_WIDTH)
	var font:=ThemeDB.fallback_font;var font_size:=label_size()
	var width:=font.get_string_size("STOCK",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	draw_string(font,Vector2(clampf(x-width*0.5,0.0,maxf(0.0,size.x-width)),height+4.0+font.get_ascent(font_size)),"STOCK",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,UiStyle.BAR_TICK)
# A captioned bar column: label and printed value above, the bar below. Returns the bar.
static func add(host,parent:Node,label:String,value:float,scale_max:float,text:String,over:bool,stock:float=-1.0)->Control:
	var column:=VBoxContainer.new();column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.mouse_filter=Control.MOUSE_FILTER_PASS;parent.add_child(column)
	var caption:=Label.new();caption.text="%s %s"%[label,text];caption.add_theme_font_size_override("font_size",roundi(13*host.ui_touch_height/48.0));column.add_child(caption)
	var bar=load("res://src/presentation/fit_surface/fit_bar.gd").new()
	bar.value=value;bar.scale_max=scale_max;bar.stock=stock;bar.over=over;bar.unit_height=host.ui_touch_height
	bar.set_meta("bar_label",label);column.add_child(bar)
	return bar
