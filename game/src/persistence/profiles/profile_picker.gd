extends RefCounted
const Rules = preload("res://src/persistence/profiles/profile_rules.gd")
var model = preload("res://src/persistence/profiles/profile_store.gd").new()
var front
var notice = ""
var target = 0
var return_dialog: Callable
func setup(owner_front) -> void:
 front = owner_front
func available() -> bool:
 return Rules.ENABLED and front.host.store.uses_profiles()
func show_picker() -> void:
 if not model.open():notice = model.warning
 front._reset("profiles")
 front._button("BACK",front._title_screen,"profiles_back")
 front._text("SAVE PROFILES",32)
 if not notice.is_empty():front._text(notice,16)
 if model.state.is_empty():return
 for n in Rules.COUNT:
  var slot = n
  front._button(("ACTIVE · " if n == model.state.active else "") + model.state.names[n],func():show_slot(slot),"profile_slot_%d" % n)
 if model.can_undo():front._button("UNDO LAST REPLACEMENT",func():confirm("Restore the previous name and all four files? Progress made since the replacement will be replaced.",func():mutate(func():return model.undo(true))),"profile_undo")
func show_slot(index: int) -> void:
 target = index;front._reset("profile_slot")
 front._button("BACK",show_picker,"profiles_back")
 front._text(model.state.names[index],30)
 front._text("Each profile keeps its own campaign, backup and challenge results.",16)
 front._button("SELECT PROFILE",func():mutate(func():return model.select(index)),"profile_select")
 front._button("RENAME",show_rename,"profile_rename")
 front._button("COPY FROM ANOTHER PROFILE",show_copy,"profile_copy")
 front._button("CLEAR PROFILE",func():confirm("Clear campaign, backups and challenge results? Undo is available for %d seconds." % Rules.UNDO_SECONDS,func():mutate(func():return model.clear(target,true))),"profile_clear")
 front._button("EXPORT",func():var path = model.export_profile(target);notice = "EXPORTED TO\n" + path if not path.is_empty() else model.warning;show_picker(),"profile_export")
 front._button("IMPORT",show_import,"profile_import")
func show_rename() -> void:
 front._reset("profile_rename")
 front._button("CANCEL",func():show_slot(target),"profiles_cancel")
 front._text("NAME PROFILE",30)
 var entry = LineEdit.new();entry.text = model.state.names[target];entry.max_length = Rules.NAME_LIMIT
 entry.virtual_keyboard_enabled = true;entry.custom_minimum_size.y = front.touch_height();entry.set_meta("ui_action","profile_name");front.column.add_child(entry)
 front._button("SAVE NAME",func():notice = "Name saved." if model.rename_profile(target,entry.text) else model.warning;show_picker(),"profile_name_save")
func show_copy() -> void:
 front._reset("profile_copy")
 front._button("CANCEL",func():show_slot(target),"profiles_cancel")
 front._text("COPY INTO " + model.state.names[target],25)
 for n in Rules.COUNT:
  if n == target:continue
  var source = n
  front._button("FROM " + model.state.names[n],func():confirm("Replace all files in " + model.state.names[target] + " with " + model.state.names[source] + "? Undo lasts %d seconds." % Rules.UNDO_SECONDS,func():mutate(func():return model.copy(source,target,true))),"profile_copy_%d" % n)
func show_import() -> void:
 front._reset("profile_import")
 front._button("CANCEL",func():show_slot(target),"profiles_cancel")
 front._text("IMPORT INTO " + model.state.names[target],25)
 front._text("Place a .qprofile export in:\n" + ProjectSettings.globalize_path(model.directory),16)
 var files = model.packages()
 if files.is_empty():front._text("No profile exports found.",16)
 for path in files:
  var source: String = path
  front._button(source.get_file(),func():var bytes = model.read_package(source);if bytes.is_empty():notice = model.warning;show_picker()
  else:confirm("Replace this profile with the validated import? Undo lasts %d seconds." % Rules.UNDO_SECONDS,func():mutate(func():return model.replace(target,bytes,true))),"profile_file_" + source.get_file())
func confirm(message: String, action: Callable) -> void:
 front._reset("profile_confirm")
 front._button("CANCEL",func():show_slot(target),"profiles_cancel")
 front._text(message,22)
 front._button("CONFIRM REPLACEMENT",action,"profiles_confirm")
func mutate(action: Callable) -> void:
 load("res://src/persistence/profiles/profile_session.gd").handover(front,action)
func back() -> void:
 if front.screen == "profile_confirm":show_slot(target)
 elif front.screen == "profiles":front._title_screen()
 elif front.screen == "profile_slot":show_picker()
 else:show_slot(target)
