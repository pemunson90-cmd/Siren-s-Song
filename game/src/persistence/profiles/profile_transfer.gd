extends RefCounted
# PROFILE TRANSFER (handoff 075). Seam: profile_picker.gd Export/Import screens call route(), export_to() and
# import_pick(); profile_store.gd supplies package_bytes() and parse_package() (same envelope, checksum, validators).
# Routes: "dialog" = Godot native file dialog (probed at runtime, Android only), "downloads" = Downloads folder
# fallback, "local" = the app folder user://profiles list (desktop, unchanged), "none" = nothing reachable, say so.
# Revert: set ENABLED=false (picker behaves as before) or delete this file and the picker calls. No save fields.
const Rules = preload("res://src/persistence/profiles/profile_rules.gd")
const ENABLED = true
# Tunables. Filter is "glob;description;mime" (the MIME part is what Android uses).
const FILTERS = ["*.qprofile;Siren Song profile;application/octet-stream"]
const NAME_FORMAT = "siren-profile-slot%d.qprofile"
const TITLE_SAVE = "Save profile export"
const TITLE_OPEN = "Choose a profile export"
const MSG_NONE = "This device has no reachable folder for profile files. Nothing was exported or imported."
const MSG_CANCEL = "Cancelled. Nothing changed."
var model
var platform = ""
var downloads_dir = null # null = OS Downloads folder; "" = none (tests)
# Test seams. Empty Callables use DisplayServer. probe() -> bool. show(title, dir, filename, mode, filters, cb) -> int.
var probe: Callable
var show: Callable
var serial = 0
var busy = false
func reset() -> void:
 serial += 1;busy = false
func android() -> bool:
 return (platform if not platform.is_empty() else OS.get_name()) == "Android"
func dialog_supported() -> bool:
 if probe.is_valid():return probe.call()
 return DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE)
func downloads() -> String:
 var path = downloads_dir if downloads_dir is String else OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
 return path if not path.is_empty() and DirAccess.dir_exists_absolute(path) else ""
func route() -> String:
 if not ENABLED or not android():return "local"
 if dialog_supported():return "dialog"
 return "downloads" if not downloads().is_empty() else "none"
func _open_dialog(title: String, filename: String, mode: int, callback: Callable) -> int:
 if show.is_valid():return show.call(title,"",filename,mode,FILTERS,callback)
 return DisplayServer.file_dialog_show(title,"",filename,false,mode,PackedStringArray(FILTERS),callback)
func write_external(path: String, bytes: PackedByteArray) -> bool:
 var file = FileAccess.open(path,FileAccess.WRITE)
 if file == null:return false
 file.store_buffer(bytes);file.flush()
 var ok = file.get_error() == OK
 file.close()
 if not ok:return false
 # Some content URIs are write-only; a readable copy must match, an unreadable one is accepted.
 var check = FileAccess.open(path,FileAccess.READ)
 if check == null:return true
 var same = check.get_length() == bytes.size() and check.get_buffer(bytes.size()) == bytes
 check.close()
 return same
func read_external(path: String) -> PackedByteArray:
 var file = FileAccess.open(path,FileAccess.READ)
 if file == null:return PackedByteArray()
 var length = file.get_length()
 if length <= 0 or length > Rules.PACKAGE_LIMIT:return PackedByteArray()
 var bytes = file.get_buffer(length)
 var ok = file.get_error() == OK
 file.close()
 return bytes if ok else PackedByteArray()
func export_to(index: int, done: Callable) -> void:
 # done(message). Nothing is written on cancel or error, and Ironman and validity refusals come from the store.
 var kind = route()
 if kind == "none":done.call(MSG_NONE);return
 if busy:done.call("A file dialog is already open.");return
 var bytes = model.package_bytes(index)
 if bytes.is_empty():done.call(model.warning);return
 if kind == "downloads":
  var dest = downloads().path_join("siren-profile-slot%d-%d.qprofile" % [index + 1,Time.get_unix_time_from_system()])
  done.call(("EXPORTED TO\n" + dest) if write_external(dest,bytes) else "Could not write to the Downloads folder. Nothing was exported.")
  return
 busy = true
 var ticket = serial
 var cb = func(status: bool, paths: PackedStringArray, _filter: int = 0):
  if ticket != serial:return
  busy = false
  if not status or paths.is_empty():done.call(MSG_CANCEL);return
  done.call("EXPORT SAVED." if write_external(paths[0],bytes) else "Could not write the export file. Nothing was saved.")
 if _open_dialog(TITLE_SAVE,NAME_FORMAT % [index + 1],DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,cb) != OK:
  busy = false;done.call("Could not open the save dialog. Nothing was exported.")
func load_path(path: String) -> Dictionary:
 # Reads one external file and validates it. Empty result: see model.warning.
 var raw = read_external(path)
 if raw.is_empty():model.warning = "Import file unavailable or too large.";return {}
 return model.parse_package(raw)
func choices() -> Array:
 # Touch list for routes without a dialog.
 var kind = route()
 if kind == "local":return model.packages()
 var out = []
 var dir = DirAccess.open(downloads()) if kind == "downloads" else null
 if dir == null:return out
 for file in dir.get_files():
  if file.ends_with(".qprofile"):out.append(downloads().path_join(file))
 out.sort();return out
func import_pick(done: Callable) -> void:
 # done(files: Dictionary, message: String). files is empty on cancel or refusal; the picker then confirms before replace.
 if route() != "dialog":done.call({},MSG_NONE);return
 if busy:done.call({},"A file dialog is already open.");return
 busy = true
 var ticket = serial
 var cb = func(status: bool, paths: PackedStringArray, _filter: int = 0):
  if ticket != serial:return
  busy = false
  if not status or paths.is_empty():done.call({},MSG_CANCEL);return
  var files = load_path(paths[0])
  done.call(files,"" if not files.is_empty() else model.warning)
 if _open_dialog(TITLE_OPEN,"",DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,cb) != OK:
  busy = false;done.call({},"Could not open the file dialog. Nothing was imported.")
