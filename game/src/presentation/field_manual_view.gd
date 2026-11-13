extends RefCounted
# The Field Manual: a row of topic buttons and one short card at a time. The content is
# field_manual_table.gd; this view draws any table. Entry points: show(host, index) from a briefing.
const Table=preload("res://src/presentation/field_manual_table.gd")
const Style=preload("res://src/presentation/ui_style.gd")
const ACTION_PREFIX="manual_topic_"

static func show(host,index:int,topic_id:String="")->void:
	host.screen="reference"; host._clear_menu()
	host._menu_text("FIELD MANUAL",Style.MANUAL_HEADING_SIZE)
	var briefing=host.Simulation.Missions.make(index,host._launch_context(index))
	var row=HFlowContainer.new()
	row.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("h_separation",8);row.add_theme_constant_override("v_separation",8)
	host.panel_box.add_child(row)
	var holder=VBoxContainer.new()
	holder.add_theme_constant_override("separation",10)
	host.panel_box.add_child(holder)
	var buttons={}
	for entry in Table.TOPICS:
		var topic_id_now:String=entry.id
		var button:Button=host._button(row,entry.title,func():open(host,briefing,buttons,holder,topic_id_now),ACTION_PREFIX+topic_id_now)
		button.custom_minimum_size.x=host.ui_touch_height*Style.MANUAL_TOPIC_WIDTH
		buttons[topic_id_now]=button
	open(host,briefing,buttons,holder,topic_id if buttons.has(topic_id) else Table.TOPICS[0].id)
	if briefing_has_work_rows(host,index):host.ExpeditionOperations.briefing(host,index)
	host._button(host.menu_footer,"BACK TO BRIEFING",func():host._briefing(index),"back"); host.menu_footer.show()
	host.call_deferred("_layout")

static func briefing_has_work_rows(host,index:int)->bool:
	return preload("res://src/campaign/onboarding2/briefing_rows.gd").applies(index)

# Opens one topic: marks its button as chosen (the others are not) and redraws the card.
static func open(host,briefing:Dictionary,buttons:Dictionary,holder:Control,id:String)->void:
	host.set_meta("field_manual_open",id)
	for key in buttons:
		var chosen:bool=key==id
		buttons[key].set_meta("chosen",chosen)
		Style.apply_card(buttons[key],chosen,false)
	for old in holder.get_children():
		holder.remove_child(old);old.queue_free()
	var entry=Table.topic(id)
	line(host,holder,entry.title,Style.MANUAL_TITLE_SIZE).add_theme_color_override("font_color",Style.ACCENT)
	var mark="" if id==Table.OPERATION_ID else "• "
	for text in lines_of(host,briefing,entry):line(host,holder,mark+text,Style.MANUAL_BODY_SIZE)
	host.call_deferred("_layout")

static func lines_of(host,briefing:Dictionary,entry:Dictionary)->Array:
	if entry.id!=Table.OPERATION_ID:return entry.lines
	var out:Array=[]
	for part in String(briefing.brief).split("\n\n"):out.append(part)
	if briefing.get("blackwater_revision",0)==1:out.append(host._orders_text(briefing))
	return out

static func line(host,holder:Control,text:String,font_size:int)->Label:
	text=preload("res://src/presentation/public_copy.gd").present(text)
	var label=host._label(holder,text,roundi(font_size*host.ui_touch_height/48.0*preload("res://src/presentation/frontend/frontend_settings.gd").text_scale()))
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.custom_minimum_size.x=minf(610,host.size.x-120)
	return label
