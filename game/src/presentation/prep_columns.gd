extends RefCounted
# One two-column frame for the preparation screens (WP-53). open() returns the boxes a screen builds into:
# on a wide screen a left box and a right box inside one wider panel, on a narrow screen the host's own
# single box twice, so a screen adds its sections in reading order and the narrow layout is unchanged.
# The threshold is LayoutMetrics.prep_wide. With `scrolling` the right box scrolls on its own beside a left
# box that stays on screen; without it both columns scroll with the page.
# Seams: Main._layout (panel width and rebuild when the shape changes) and Main._clear_menu (forget).
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const WIDE_META="prep_wide"
const REBUILD_META="prep_rebuild"
const SCROLL_META="prep_scroll"
const PENDING_META="prep_pending"
const NESTED_META="prep_nested"
static func wide(host)->bool:
	return Metrics.prep_wide(host.size,host.ui_touch_height,Settings.text_scale())
# Whether the screen being built has two columns (false for a screen that has not called open()).
static func is_wide(host)->bool:
	return host.get_meta(WIDE_META,false)
# `rebuild` redraws the whole screen; Main calls it when a turn or resize changes the column count.
static func open(host,rebuild:Callable,scrolling:bool=false)->Array:
	# Inside a column of an outer frame (see nested) a screen section keeps its narrow, stacked form.
	if host.get_meta(NESTED_META,false):return [host.panel_box,host.panel_box]
	var columns:=wide(host)
	host.set_meta(WIDE_META,columns);host.set_meta(REBUILD_META,rebuild)
	if not columns:return [host.panel_box,host.panel_box]
	var row:=HBoxContainer.new();row.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_theme_constant_override("separation",roundi(Metrics.MENU_COLUMN_GAP))
	# The left column is a compact summary that must fit a short screen; the right holds the touch rows.
	var left:=_column(UiStyle.PREP_SUMMARY_SEPARATION);var right:=_column(UiStyle.PREP_CONTROLS_SEPARATION)
	row.add_child(left)
	if scrolling:
		# The page itself fills the panel, so the row takes the height left below the back button.
		host.panel_box.size_flags_vertical=Control.SIZE_EXPAND_FILL;row.size_flags_vertical=Control.SIZE_EXPAND_FILL
		var pane:=ScrollContainer.new();pane.size_flags_horizontal=Control.SIZE_EXPAND_FILL;pane.size_flags_vertical=Control.SIZE_EXPAND_FILL
		pane.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;pane.custom_minimum_size.y=host.ui_touch_height*UiStyle.PREP_SCROLL_MIN_TOUCHES
		pane.add_child(right);row.add_child(pane);host.set_meta(SCROLL_META,pane)
	else:row.add_child(right)
	host.panel_box.add_child(row)
	return [left,right]
static func _column(separation:int)->VBoxContainer:
	var box:=VBoxContainer.new();box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box.add_theme_constant_override("separation",separation)
	return box
# Run `build` as a section of one column of an outer frame: a section that would open its own two columns
# (the tool racks) stays one stacked column inside it.
static func nested(host,build:Callable)->void:
	host.set_meta(NESTED_META,true)
	build.call()
	host.remove_meta(NESTED_META)
# BACK and the screen title: one above the other on a narrow screen (as ever), on one line on a wide one.
# Returns the title label.
static func back_line(host,title:String,back_text:String,back_action:Callable,back_id:String)->Label:
	if not wide(host):
		host._button(host.panel_box,back_text,back_action,back_id)
		return host._menu_text(title,30)
	var line:=HBoxContainer.new();line.add_theme_constant_override("separation",roundi(Metrics.MENU_COLUMN_GAP));host.panel_box.add_child(line)
	var back=host._button(line,back_text,back_action,back_id)
	back.custom_minimum_size.x=host.ui_touch_height*UiStyle.PREP_BACK_TOUCHES
	var label=host._menu_text(title,30)
	label.reparent(line);label.custom_minimum_size.x=0;label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	return label
# What a text column can be asked to hold: one column's width less the room for the right column's scroll bar.
static func text_width(host)->float:
	return Metrics.menu_column_width(host.size,is_wide(host))-(UiStyle.PREP_SCROLLBAR_ALLOWANCE if is_wide(host) else 0.)
# The minimum width of a strip of bars: 610 as ever on a narrow screen, less than a column on a wide one.
static func strip_width(host)->float:
	return minf(610.,minf(host.size.x-120.,text_width(host)) if is_wide(host) else host.size.x-120.)
# Run `build` with the host's menu helpers (_menu_text, _button) adding into `box`. Menu text asks for 610 px;
# in a wide column that is trimmed to what the column holds, so two columns never push past the panel.
static func into(host,box:VBoxContainer,build:Callable)->void:
	var previous=host.panel_box
	host.panel_box=box
	build.call()
	host.panel_box=previous
	if is_wide(host) and box!=previous:
		for label in box.find_children("*","Label",true,false):label.custom_minimum_size.x=minf(label.custom_minimum_size.x,text_width(host))
# The reading position of the right-hand column, kept across a redraw (0 when the screen has no such column).
static func _pane(host)->ScrollContainer:
	var pane=host.get_meta(SCROLL_META) if host.has_meta(SCROLL_META) else null
	return pane if is_instance_valid(pane) else null
static func column_position(host)->int:
	var pane:=_pane(host)
	return pane.scroll_vertical if pane!=null else 0
static func restore_column(host,position:int)->void:
	var pane:=_pane(host)
	if pane!=null:pane.scroll_vertical=position
# The control that scrolls the fittings cards: the right-hand column when there is one, else the menu page.
static func scroller(host)->ScrollContainer:
	var pane:=_pane(host)
	return pane if pane!=null else host.scroll
# Main._layout: rebuild the screen once when its shape no longer matches its column count.
static func relayout(host)->void:
	if not host.has_meta(WIDE_META) or host.get_meta(WIDE_META)==wide(host) or host.get_meta(PENDING_META,false):return
	var rebuild:Callable=host.get_meta(REBUILD_META,Callable())
	if not rebuild.is_valid():return
	host.set_meta(PENDING_META,true)
	rebuild.call_deferred()
# Main._clear_menu: a new screen starts with no columns.
static func forget(host)->void:
	for key in [WIDE_META,REBUILD_META,SCROLL_META,PENDING_META,NESTED_META]:
		if host.has_meta(key):host.remove_meta(key)
	host.panel_box.size_flags_vertical=Control.SIZE_FILL
