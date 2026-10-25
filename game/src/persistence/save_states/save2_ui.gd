extends RefCounted
# SAVE2 presentation only. Revert by hiding its entry points; saved files remain intact.
const Table=preload("res://src/persistence/save_states/save2_table.gd")
const CONTROLLER_PATH="res://src/persistence/save_states/save2_controller.gd"
const SESSION_PATH="res://src/persistence/save_states/save2_session.gd"

static func show(host,kind:String="manual",return_to:String="operations",message:String="")->void:
	var controller=load(CONTROLLER_PATH)
	if controller==null:return
	controller.ensure_state(host)
	host.set_meta("save2_ui_page",{"page":"list","kind":kind,"return_to":return_to,"message":message})
	_draw(host)

static func back(host)->bool:
	if not host.has_meta("save2_ui_page"):return false
	var page:Dictionary=host.get_meta("save2_ui_page")
	if page.get("page")=="confirm":
		page.page="list";host.set_meta("save2_ui_page",page);_draw(host);return true
	host.remove_meta("save2_ui_page")
	var return_to:String=page.get("return_to","operations")
	if return_to=="first_ending":host.CampaignFlow.show_ending(host,false)
	elif return_to=="ending":host._show_ending()
	else:host._show_campaign()
	return true

static func _manager(host):
	var controller=load(CONTROLLER_PATH)
	return controller.manager(host) if controller!=null else null

static func _page(host)->Dictionary:
	return host.get_meta("save2_ui_page",{"page":"list","kind":"manual","return_to":"operations"})

static func _draw(host)->void:
	if not is_instance_valid(host):return
	var page=_page(host)
	host._clear_menu();host.screen="save2"
	if page.get("page")=="confirm":_draw_confirm(host,page);return
	_draw_list(host,page)

static func _draw_list(host,page:Dictionary)->void:
	var manager=_manager(host)
	if manager==null:
		host._menu_text("Saved states are unavailable right now.")
		_footer(host,page)
		return
	var kind:String=page.get("kind","manual")
	host._menu_text("HARD SAVES" if kind=="manual" else "FORK STATES",24)
	host._menu_text(Table.EXACT_WARNING)
	host._menu_text(Table.PROFILE_NOTICE)
	if not str(page.get("message","")).is_empty():host._menu_text(str(page.message))
	if kind=="manual":_manual_list(host,manager,page)
	else:_fork_list(host,manager,page)
	_footer(host,page)
	host.call_deferred("_layout")

static func _manual_list(host,manager,page:Dictionary)->void:
	var entries=manager.list_entries("manual")
	var allowed=load(CONTROLLER_PATH).manual_allowed(host)
	for index in range(Table.MANUAL_COUNT):
		var entry:Dictionary=entries[index] if index<entries.size() else {"status":"empty","token":"missing","record":{}}
		var status:String=entry.get("status","unreadable")
		var record:Dictionary=entry.get("record",{})
		host._menu_text("SLOT %d · %s"%[index+1,record.get("label","Empty" if status=="empty" else "Unreadable")],20)
		if status=="ready":
			host._menu_text("Last recovered operation: %s\n%s\nSaved: %s"%[_operation(record.get("last_operation",0)),_recovery_label(entry),_timestamp(record.get("timestamp",0))])
		elif status=="unreadable":host._menu_text("Unreadable save. Its original files are retained.")
		else:host._menu_text("No hard save in this slot.")
		var actions=HBoxContainer.new();actions.add_theme_constant_override("separation",8);host.panel_box.add_child(actions)
		var line=LineEdit.new();line.placeholder_text="Hard save %d"%[index+1];line.text=str(record.get("label","Hard save %d"%[index+1]));line.max_length=Table.NAME_LIMIT;line.virtual_keyboard_enabled=true;line.custom_minimum_size=Vector2(0,host.ui_touch_height);line.size_flags_horizontal=Control.SIZE_EXPAND_FILL;line.set_meta("action","save2_name_%d"%index);line.set_meta("ui_action","save2_name_%d"%index);actions.add_child(line)
		var token:String=entry.get("token","invalid")
		var save=host._button(actions,"SAVE HERE",func():_save_action(host,manager,index,token,line,status,"manual",page.get("return_to","operations")),"save2_save_%d"%index)
		save.disabled=not allowed or status=="unreadable"
		if status=="ready":
			var load_button=host._button(actions,"LOAD",func():_confirm(host,"load",index,token,str(record.get("label","Hard save %d"%[index+1])),"manual",page.get("return_to","operations")),"save2_load_%d"%index)
			load_button.disabled=false
		if status!="empty":
			host._button(actions,"DELETE",func():_confirm(host,"delete",index,token,str(record.get("label","Unreadable save")),"manual",page.get("return_to","operations"),"",bool(entry.get("retained_on_delete",false))),"save2_delete_%d"%index)

static func _fork_list(host,manager,page:Dictionary)->void:
	var entries=manager.list_entries("fork")
	entries.sort_custom(func(a,b):
		var ar:Dictionary=a.get("record",{});var br:Dictionary=b.get("record",{})
		var asq=int(ar.get("sequence",Table.COUNT_LIMIT+1));var bsq=int(br.get("sequence",Table.COUNT_LIMIT+1))
		return asq<bsq if asq!=bsq else int(a.get("index",0))<int(b.get("index",0)))
	var any=false
	for entry in entries:
		if entry.get("status")=="empty":continue
		any=true
		var slot_index:int=int(entry.get("index",0))
		var record:Dictionary=entry.get("record",{})
		var title:String=str(record.get("label","Unreadable fork state"))
		host._menu_text(title,20)
		if entry.get("status")=="ready":
			host._menu_text("Last recovered operation: %s\n%s\nSaved: %s"%[_operation(record.get("last_operation",0)),_recovery_label(entry),_timestamp(record.get("timestamp",0))])
		else:host._menu_text("Unreadable fork state. Its original files are retained.")
		var actions=HBoxContainer.new();actions.add_theme_constant_override("separation",8);host.panel_box.add_child(actions)
		var token:String=entry.get("token","invalid")
		if entry.get("status")=="ready":host._button(actions,"LOAD",func():_confirm(host,"load",slot_index,token,title,"fork",page.get("return_to","ending")),"save2_fork_load_%d"%slot_index)
		host._button(actions,"DELETE",func():_confirm(host,"delete",slot_index,token,title,"fork",page.get("return_to","ending"),"",bool(entry.get("retained_on_delete",false))),"save2_fork_delete_%d"%slot_index)
	if not any:host._menu_text("No fork states have been recorded yet.")

static func _confirm(host,operation:String,index:int,token:String,label:String,kind:String,return_to:String,target_label:String="",retained_on_delete:bool=false)->void:
	host.set_meta("save2_ui_page",{"page":"confirm","operation":operation,"index":index,"token":token,"label":label,"target":target_label if not target_label.is_empty() else label,"kind":kind,"return_to":return_to,"retained_on_delete":retained_on_delete})
	_draw(host)

static func _save_action(host,manager,index:int,token:String,line:LineEdit,status:String,kind:String,return_to:String)->void:
	if status=="empty":_save_empty(host,manager,index,token,line.text)
	else:
		var old=manager.inspect("manual",index)
		_confirm(host,"save",index,token,line.text,kind,return_to,str(old.get("record",{}).get("label","Unreadable save")))

static func _draw_confirm(host,page:Dictionary)->void:
	var op:String=page.operation
	var kind:String=page.kind
	var label:String=page.label
	var target:String=page.get("target",label)
	var index:int=page.index
	var heading="SAVE HERE" if op=="save" else ("LOAD SAVED STATE" if op=="load" else "DELETE SAVED STATE")
	host._menu_text(heading,24)
	host._menu_text("Target: %s"%target)
	if op=="save":
		host._menu_text("Replace %s in slot %d with “%s”?"%[target,index+1,label])
	elif op=="load":
		host._menu_text("Load %s and replace the current campaign?"%label)
		host._menu_text(Table.EXACT_WARNING)
	else:
		host._menu_text("Delete %s? This saved state belongs to this profile slot."%label)
		if bool(page.get("retained_on_delete",false)):host._menu_text("This oversized unreadable original will be moved aside and retained for recovery while its saved-state slot is cleared.")
		elif label=="Unreadable save" or label=="Unreadable fork state":host._menu_text("This state is unreadable. Its original files will be retained for recovery if deletion cannot safely complete.")
	var row=HBoxContainer.new();row.add_theme_constant_override("separation",10);host.panel_box.add_child(row)
	host._button(row,"CONFIRM",func():_perform(host,page),"save2_confirm")
	host._button(row,"CANCEL",func():_cancel(host),"save2_cancel")
	host._button(host.menu_footer,"BACK",func():_cancel(host),"save2_back");host.menu_footer.show()
	host.call_deferred("_layout")

static func _cancel(host)->void:
	var page=_page(host);page.page="list";page.erase("operation");page.erase("index");page.erase("token");page.erase("label");host.set_meta("save2_ui_page",page);_draw(host)

static func _perform(host,page:Dictionary)->void:
	var manager=_manager(host)
	if manager==null:_result(host,"Saved states are unavailable.");return
	var kind:String=page.kind;var index:int=page.index;var token:String=page.token
	var ok=false;var message=""
	match page.operation:
		"save":
			var archive:Dictionary=host._archive()
			ok=manager.save_manual(index,archive,str(page.label),true,token)
			message="Hard save written." if ok else str(manager.warning)
		"delete":
			ok=manager.delete_entry(kind,index,true,token)
			message=(str(manager.warning) if not str(manager.warning).is_empty() else "Saved state deleted.") if ok else str(manager.warning)
		"load":
			var session=load(SESSION_PATH)
			if session!=null:ok=session.restore(host,kind,index,token)
			message="Saved state loaded." if ok else str(host.get_meta("save2_session_error","The state was not loaded. The current session is unchanged."))
	if page.operation=="load" and ok:return
	if not message.is_empty():
		var controller=load(CONTROLLER_PATH)
		if controller!=null:controller.notice(host,message)
	_result(host,message)

static func _save_empty(host,manager,index:int,token:String,label:String)->void:
	var archive:Dictionary=host._archive()
	var ok=manager.save_manual(index,archive,label,false,token)
	var message="Hard save written." if ok else str(manager.warning)
	var controller=load(CONTROLLER_PATH)
	if controller!=null:controller.notice(host,message)
	_result(host,message)

static func _result(host,message:String)->void:
	var page=_page(host);page.page="list";page.message=message;host.set_meta("save2_ui_page",page);_draw(host)

static func _footer(host,page:Dictionary)->void:
	if page.get("kind")=="manual":
		host._button(host.menu_footer,"FORK STATES",func():show(host,"fork",page.get("return_to","operations")),"save2_forks")
	else:
		host._button(host.menu_footer,"MANUAL SAVES",func():show(host,"manual",page.get("return_to","operations")),"save2_manual")
	host._button(host.menu_footer,"BACK",func():back(host),"save2_back")
	host.menu_footer.show()

static func _recovery_label(entry:Dictionary)->String:
	var state:Dictionary=entry.get("data",{}).get(Table.STATE,{})
	var count=int(entry.get("record",{}).get("recovery_count",0))
	if state.is_empty() or bool(state.get("legacy_minimum",false)):return "Known recoveries (at least): %d"%count
	return "Successful recoveries (including replays): %d"%count

static func _operation(value)->String:
	var number=int(value)
	return "None" if number<=0 else "%02d"%number

static func _timestamp(value)->String:
	if int(value)<=0:return "Unknown"
	return Time.get_datetime_string_from_unix_time(int(value),true)
