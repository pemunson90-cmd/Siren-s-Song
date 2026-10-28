extends RefCounted
const Codec = preload("res://src/persistence/profiles/profile_codec.gd")
const Rules = preload("res://src/persistence/profiles/profile_rules.gd")
const Save2Recovery = preload("res://src/persistence/save_states/save2_transaction.gd")
var directory = "user://profiles"
var legacy = "user://quietus.save"
var warning = ""
var state: Dictionary = {}
var healthy = false
var undo_data: Dictionary = {}
var undo_until = 0
func slot_path(index: int) -> String:
 return directory + "/slot%d.save" % (index + 1) if index >= 0 and index < Rules.COUNT else ""
func _fail(message: String) -> bool:
 warning = message + " Original files retained. Check device storage."
 return false
func _write(path: String, bytes: PackedByteArray) -> bool:
 var file = FileAccess.open(path, FileAccess.WRITE)
 if file == null:return false
 file.store_buffer(bytes);file.flush()
 var ok = file.get_error() == OK
 file.close()
 if not ok:return false
 var verified = _bytes(path,Rules.PACKAGE_LIMIT)
 return verified is PackedByteArray and verified == bytes
func _bytes(path: String, limit: int) -> Variant:
 var file = FileAccess.open(path,FileAccess.READ)
 if file == null or file.get_length() > limit:return null
 var value = file.get_buffer(file.get_length())
 var ok = file.get_error() == OK
 file.close()
 return value if ok else null
func _remove(path: String) -> bool:
 return not FileAccess.file_exists(path) or DirAccess.remove_absolute(path) == OK
func _snapshot(path: String) -> Dictionary:
 # Finish any SAVE2 rollback before SAVE1 reads/replaces a slot's live files.
 # Revert the SAVE2 feature flag independently; pending recovery stays active.
 if not Save2Recovery.recover(path):warning=Save2Recovery.warning;return {}
 var out = {}
 for suffix in Rules.SUFFIXES:
  var file = path + suffix
  if not FileAccess.file_exists(file):out[suffix] = null;continue
  var stream = FileAccess.open(file, FileAccess.READ)
  if stream == null or stream.get_length() > Rules.FILE_LIMIT:return {}
  var bytes = stream.get_buffer(stream.get_length())
  if stream.get_error() != OK:return {}
  out[suffix] = bytes
 return out
func snapshot(index: int) -> Dictionary:
 return _snapshot(slot_path(index)) if not slot_path(index).is_empty() else {}
func _restore(entries: Dictionary) -> bool:
 for path in entries:
  if entries[path] == null:
   if not _remove(path):return false
  elif not _write(path, entries[path]):return false
 return true
# Journal is written before replacing any live byte. Interrupted transactions
# recover all old files and absence on the next open, before exposing any slot.
func _transaction(entries: Dictionary, initializing: bool = false) -> bool:
 if FileAccess.file_exists(directory + "/transaction"):return _fail("Pending profile recovery blocks changes.")
 if not initializing and not _ready_for_change():return false
 var before = {}
 for path in entries:
  if FileAccess.file_exists(path):
   var f = FileAccess.open(path,FileAccess.READ)
   if f == null or f.get_length() > Rules.PACKAGE_LIMIT:return _fail("Cannot read transaction source.")
   before[path] = f.get_buffer(f.get_length())
   if f.get_error() != OK:return _fail("Cannot read transaction source.")
  else:before[path] = null
  if entries[path] != null and not _write(path + ".stage",entries[path]):return _fail("Cannot stage profile.")
 var journal = directory + "/transaction"
 if not _write(journal,var_to_bytes(before)):return _fail("Cannot journal profile.")
 var ok = true
 for path in entries:
  if not _remove(path):ok = false;break
  if entries[path] != null and DirAccess.rename_absolute(path + ".stage",path) != OK:ok = false;break
 if not ok:
  if not _restore(before):return _fail("Profile rollback pending on next launch.")
  if not _remove(journal):return _fail("Cannot finalize rollback.")
  return _fail("Profile change rolled back.")
 for path in entries:
  if not _remove(path + ".stage"):
   if not _restore(before):return _fail("Profile rollback pending on next launch.")
   return _fail("Cannot clean staged profile; replacement rolled back.")
 if not _remove(journal):
  if not _restore(before):return _fail("Profile rollback pending on next launch.")
  return _fail("Cannot finalize profile change; replacement rolled back.")
 return true
func _valid_state(value: Variant) -> bool:
 if not value is Dictionary or not value.get("version") is int or value.version != 1 or not value.get("active") is int or value.active < 0 or value.active >= Rules.COUNT:return false
 if not value.get("names") is Array or value.names.size() != Rules.COUNT:return false
 for label in value.names:
  if not label is String or label.is_empty() or label.length() > Rules.NAME_LIMIT:return false
 return true
func open() -> bool:
 healthy = false;state = {}
 var ok = _open()
 if not ok:healthy = false;state = {}
 return ok
func _open() -> bool:
 warning = ""
 if DirAccess.make_dir_recursive_absolute(directory) != OK:return _fail("Cannot open profiles.")
 var journal = directory + "/transaction"
 if FileAccess.file_exists(journal):
  var raw = _bytes(journal,Rules.PACKAGE_LIMIT)
  if raw == null:return _fail("Profile recovery journal unreadable.")
  var previous = Codec.decode(raw)
  if not previous is Dictionary:return _fail("Profile recovery journal invalid.")
  for path in previous:
   if not path is String or (path != directory + "/index" and path != directory + "/index.bak" and not _allowed_path(path)):return _fail("Profile recovery path invalid.")
   if previous[path] != null and not previous[path] is PackedByteArray:return _fail("Profile recovery bytes invalid.")
  if not _restore(previous) or not _remove(journal):return _fail("Profile recovery pending.")
 var index_path = directory + "/index"
 for suffix in ["", ".bak"]:
  if not FileAccess.file_exists(index_path + suffix):continue
  var raw = _bytes(index_path + suffix,Rules.INDEX_LIMIT)
  if raw == null:continue
  var value = Codec.decode(raw)
  if _valid_state(value):state = value;healthy = true;return true
 if FileAccess.file_exists(index_path) or FileAccess.file_exists(index_path + ".bak"):return _fail("Profile index unreadable; no saves were remapped.")
 state = {"version":1,"active":0,"names":["Profile 1","Profile 2","Profile 3"]}
 var old = _snapshot(legacy)
 if old.is_empty():return _fail("Cannot read legacy files.")
 var entries = {}
 for suffix in Rules.SUFFIXES:
  if FileAccess.file_exists(slot_path(0) + suffix):return _fail("Unindexed profile files need recovery.")
  entries[slot_path(0) + suffix] = old[suffix]
 entries[index_path] = var_to_bytes(state)
 entries[index_path + ".bak"] = var_to_bytes(state)
 if not _transaction(entries,true):return false
 healthy = true;return true
func _ready_for_change() -> bool:
 if not healthy or state.is_empty() or FileAccess.file_exists(directory + "/transaction"):return _fail("Profile recovery must succeed before changes.")
 for suffix in ["", ".bak"]:
  var raw = _bytes(directory + "/index" + suffix,Rules.INDEX_LIMIT)
  if raw == null:continue
  var value = Codec.decode(raw)
  if _valid_state(value):return true
 healthy = false;state = {};return _fail("Profile index unreadable; changes blocked.")
func _allowed_path(path: String) -> bool:
 for n in Rules.COUNT:
  for suffix in Rules.SUFFIXES:
   if path == slot_path(n) + suffix:return true
 return false
func _metadata(next: Dictionary) -> Dictionary:
 return {directory + "/index":var_to_bytes(next),directory + "/index.bak":var_to_bytes(next)}
func select(index: int) -> bool:
 if not _ready_for_change() or slot_path(index).is_empty():return false
 var next = state.duplicate(true);next.active = index
 if not _transaction(_metadata(next)):return false
 state = next;return true
func rename_profile(index: int, label: String) -> bool:
 if not _ready_for_change():return false
 label = label.strip_edges().replace("\n"," ").replace("\r"," ")
 if slot_path(index).is_empty() or label.is_empty() or label.length() > Rules.NAME_LIMIT:return _fail("Use a name of 1 to 24 characters.")
 var next = state.duplicate(true);next.names[index] = label
 if not _transaction(_metadata(next)):return false
 state = next;return true
func replace(index: int, files: Dictionary, confirmed: bool, restored_name: String = "") -> bool:
 if not confirmed or not _ready_for_change():return false
 files = _normalize_files(files)
 if slot_path(index).is_empty() or not _valid_files(files):return _fail("Invalid profile replacement.")
 var previous = snapshot(index)
 if previous.is_empty():return _fail("Cannot preserve undo files.")
 # Ironman keeps one timeline: never copy or import an Ironman archive, or replace one with progress.
 # Clear/undo-clear remains available, but stale Undo must never rewind a live Ironman run.
 var clearing = Rules.SUFFIXES.all(func(suffix):return files[suffix] == null)
 var undo_clear = not restored_name.is_empty() and Rules.SUFFIXES.all(func(suffix):return previous[suffix] == null)
 if Rules.IRONMAN_GUARD:
  if (_holds_ironman(previous) and (not clearing or not restored_name.is_empty())) or (_holds_ironman(files) and not undo_clear):
   warning="Ironman keeps one timeline. This profile cannot be copied or replaced; clear it first.";return false
 var entries = {}
 for suffix in Rules.SUFFIXES:entries[slot_path(index) + suffix] = files[suffix]
 var next = state.duplicate(true)
 var previous_name: String = state.names[index]
 if not restored_name.is_empty():
  next.names[index] = restored_name;entries.merge(_metadata(next))
 if not _transaction(entries):return false
 state = next
 undo_data = {"index":index,"files":previous,"name":previous_name};undo_until = Time.get_ticks_msec() + Rules.UNDO_SECONDS * 1000
 return true
func clear(index: int, confirmed: bool) -> bool:
 var empty = {}
 for suffix in Rules.SUFFIXES:empty[suffix] = null
 return replace(index,empty,confirmed)
func copy(source: int, target: int, confirmed: bool) -> bool:
 if source == target:return false
 return replace(target,snapshot(source),confirmed)
func can_undo() -> bool:
 return not undo_data.is_empty() and Time.get_ticks_msec() <= undo_until
func undo(confirmed: bool) -> bool:
 if not confirmed or not can_undo():return false
 var saved = undo_data.duplicate(true)
 if not replace(saved.index,saved.files,true,saved.name):return false
 undo_data = {};return true
func _valid_files(files: Dictionary) -> bool:
 if files.size() != Rules.SUFFIXES.size():return false
 for suffix in Rules.SUFFIXES:
  if not files.has(suffix):return false
  if files[suffix] != null and (not files[suffix] is PackedByteArray or files[suffix].size() > Rules.FILE_LIMIT):return false
 return true
func _normalize_files(files: Dictionary) -> Dictionary:
 var out=files.duplicate(true)
 var legacy=["", ".bak", ".challenges", ".challenges.bak"]
 if out.size()==legacy.size() and legacy.all(func(suffix):return out.has(suffix)):
  out[".runs"]=null;out[".runs.bak"]=null
 if out.size()==6 and ["", ".bak", ".challenges", ".challenges.bak", ".runs", ".runs.bak"].all(func(suffix):return out.has(suffix)):
  out[".career"]=null;out[".career.bak"]=null
 return out
func _holds_ironman(files: Dictionary) -> bool:
 # Match normal load precedence: a valid new ordinary campaign can retain an old Ironman backup.
 for suffix in ["", ".bak"]:
  if not files.get(suffix) is PackedByteArray:continue
  var value = _payload(files[suffix])
  if value is Dictionary:
   return value.get("economy") is Dictionary and value.economy.get("ironman",false) == true
 return false
func _valid_archive(bytes: PackedByteArray, suffix: String) -> bool:
 var value = _payload(bytes)
 if value == null:return false
 var path = "res://src/campaign/career/career_archive.gd" if suffix.begins_with(".career") else "res://src/campaign/runs/run_archive.gd" if suffix.begins_with(".runs") else "res://src/campaign/challenges/challenge_archive.gd" if suffix.contains("challenges") else "res://src/persistence/save_store.gd"
 var validator = load(path).new()
 return validator.valid(value)
func _payload(bytes: PackedByteArray) -> Variant:
 var buffer = StreamPeerBuffer.new();buffer.data_array = bytes
 if bytes.size() < 32 or bytes.size() > Rules.FILE_LIMIT:return null
 # Bound Pascal strings before decoding. SaveStore's writer uses little endian.
 var magic_size = buffer.get_u32()
 if magic_size != 13 or buffer.get_available_bytes() < magic_size + 4:return null
 var magic = buffer.get_data(magic_size)[1].get_string_from_utf8()
 if magic != "QUIETUS_PASS0":return null
 var hash_size = buffer.get_u32()
 if hash_size != 64 or buffer.get_available_bytes() < hash_size + 4:return null
 var checksum = buffer.get_data(hash_size)[1].get_string_from_utf8()
 var count = buffer.get_u32()
 if count <= 0 or count != buffer.get_available_bytes():return null
 var payload: PackedByteArray = buffer.get_data(count)[1]
 if payload.hex_encode().sha256_text() != checksum:return null
 var value = Codec.decode(payload)
 if not value is Dictionary or not value.get("version") is int:return null
 return value
func package_bytes(index: int) -> PackedByteArray:
 # Shared by file export and the transfer seam (profile_transfer.gd). Empty means refused; warning says why.
 var none = PackedByteArray()
 if not _ready_for_change():return none
 var files = snapshot(index)
 if not _valid_files(files):_fail("Cannot read export source.");return none
 if Rules.IRONMAN_GUARD and _holds_ironman(files):_fail("Ironman keeps one timeline. An Ironman profile cannot be exported.");return none
 for suffix in Rules.SUFFIXES:
  if files[suffix] != null and not _valid_archive(files[suffix],suffix):_fail("Export refused: unreadable archive " + suffix + ".");return none
 var payload = var_to_bytes({"files":files})
 var package = var_to_bytes({"magic":Rules.MAGIC,"version":Rules.VERSION,"length":payload.size(),"checksum":payload.hex_encode().sha256_text(),"payload":payload})
 if package.size() > Rules.PACKAGE_LIMIT:_fail("Cannot stage export.");return none
 return package
func export_profile(index: int) -> String:
 var package = package_bytes(index)
 if package.is_empty():return ""
 var destination = directory + "/profile%d-%d.qprofile" % [index + 1,Time.get_unix_time_from_system()]
 if not _write(destination + ".stage",package):_fail("Cannot stage export.");return ""
 if DirAccess.rename_absolute(destination + ".stage",destination) != OK:_fail("Cannot commit export.");return ""
 return ProjectSettings.globalize_path(destination)
func read_package(path: String) -> Dictionary:
 warning = ""
 var raw = _bytes(path,Rules.PACKAGE_LIMIT)
 if raw == null:_fail("Import file unavailable or too large.");return {}
 return parse_package(raw)
func parse_package(raw: PackedByteArray) -> Dictionary:
 # Validates a package already read into memory (also used by the transfer dialog seam).
 warning = ""
 if raw.size() > Rules.PACKAGE_LIMIT:_fail("Import file unavailable or too large.");return {}
 var envelope = Codec.decode(raw)
 if not envelope is Dictionary or not envelope.get("magic") is String or envelope.magic != Rules.MAGIC or not envelope.get("version") is int or envelope.version != Rules.VERSION or not envelope.get("length") is int or not envelope.get("checksum") is String or not envelope.get("payload") is PackedByteArray:_fail("Invalid profile package.");return {}
 var payload: PackedByteArray = envelope.payload
 if envelope.get("length") != payload.size() or envelope.get("checksum") != payload.hex_encode().sha256_text():_fail("Import checksum failed.");return {}
 var value = Codec.decode(payload)
 if not value is Dictionary or not value.get("files") is Dictionary:_fail("Invalid profile payload.");return {}
 # Four-sidecar packages predate run archives and remain importable.
 var files=_normalize_files(value.files)
 if not _valid_files(files):_fail("Invalid profile payload.");return {}
 for suffix in Rules.SUFFIXES:
  if files[suffix] != null and not _valid_archive(files[suffix],suffix):_fail("Import archive validation failed.");return {}
 return files
func packages() -> Array:
 var out = []
 var dir = DirAccess.open(directory)
 if dir == null:return out
 for file in dir.get_files():
  if file.ends_with(".qprofile"):out.append(directory + "/" + file)
 out.sort();return out
