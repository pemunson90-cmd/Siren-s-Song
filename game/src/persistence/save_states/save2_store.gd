extends RefCounted
# SAVE2 bounded sidecars. Never write an unreadable occupied slot implicitly.
# Seams: public Store validator/codec/strict inspection; leaf rollback journal.
# Revert Table.enabled=false in the controller, retaining all sidecar files.
const Table=preload("res://src/persistence/save_states/save2_table.gd")
const Txn=preload("res://src/persistence/save_states/save2_transaction.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Economy=preload("res://src/campaign/economy.gd")
var live_path:String
var directory:String
var warning=""
var clock:Callable=func():return int(Time.get_unix_time_from_system())
func _init(path:String)->void:
 live_path=path;directory=Txn.directory(path)
func entry_path(kind:String,index:int)->String:return Txn.entry_path(live_path,kind,index)
func _open()->bool:
 if live_path.is_empty():warning="No campaign archive is selected.";return false
 if not Txn.recover(live_path):warning=Txn.warning;return false
 return true
func _token(path:String)->String:
 var parts=[]
 for suffix in Table.SUFFIXES:
  var file=path+suffix
  if DirAccess.dir_exists_absolute(file):parts.append(suffix+":directory");continue
  if not FileAccess.file_exists(file):parts.append(suffix+":missing");continue
  var bytes=Txn.bytes_at(file,Table.FILE_LIMIT)
  if bytes is PackedByteArray:parts.append(suffix+":"+bytes.hex_encode().sha256_text())
  else:parts.append(suffix+":unreadable:"+str(FileAccess.get_modified_time(file)))
 return "missing" if parts==[":missing",".bak:missing",".tmp:missing"] else str(parts).sha256_text()
func inspect(kind:String,index:int)->Dictionary:
 var path=entry_path(kind,index)
 var out={"kind":kind,"index":index,"status":"unreadable","token":"invalid","data":{},"record":{},"retained_on_delete":false}
 if path.is_empty() or not _open():return out
 for suffix in Table.SUFFIXES:
  if FileAccess.file_exists(path+suffix) and Txn.size_at(path+suffix)>Table.FILE_LIMIT:out.retained_on_delete=true
 out.token=_token(path)
 var result=Store.new().inspect_primary(path)
 out.status=result.status
 if result.status!="ready":return out
 var data:Dictionary=result.data.duplicate(true)
 var record=data.get(Table.RECORD,{})
 if not record is Dictionary or record.get("kind")!=kind:
  out.status="unreadable";return out
 data.erase(Table.RECORD)
 if record.digest!=var_to_bytes(data).hex_encode().sha256_text():out.status="unreadable";return out
 out.data=data;out.record=record
 return out
func list_entries(kind:String)->Array:
 var out=[]
 for index in Table.count(kind):out.append(inspect(kind,index))
 return out
func _sequence()->int:
 var value=0
 for kind in ["manual","fork"]:
  for entry in list_entries(kind):
   if entry.status=="ready":value=maxi(value,entry.record.sequence)
 return value+1
func _record(kind:String,data:Dictionary,label:String,event:String,run:String="",launch:String="")->Dictionary:
 var recovered=data.get("completed",[])+data.get("expedition",{}).get("completed",[])
 var state=data.get(Table.STATE,{})
 var last=int(state.get("last_recovered",recovered.back() if not recovered.is_empty() else -1))
 return {"revision":1,"kind":kind,"label":label,"timestamp":int(clock.call()),"sequence":_sequence(),"event":event,"digest":var_to_bytes(data).hex_encode().sha256_text(),"recovery_count":int(state.get("recoveries",recovered.size())),"last_operation":last+1,"run_id":run,"launch_id":launch,"ironman":Economy.is_ironman(data.get("economy"))}
func _write(kind:String,index:int,data:Dictionary,record:Dictionary)->bool:
 var payload=data.duplicate(true);payload[Table.RECORD]=record
 var codec=Store.new();var bytes=codec.encoded(payload)
 if bytes.is_empty():warning="Snapshot rejected by the existing archive validator.";return false
 var path=entry_path(kind,index)
 var old=Txn.bytes_at(path,Table.FILE_LIMIT) if FileAccess.file_exists(path) else null
 var entries={};entries[path]=bytes;entries[path+".bak"]=old;entries[path+".tmp"]=null
 if not Txn.replace(live_path,entries):warning=Txn.warning;return false
 warning="";return true
func save_manual(index:int,archive:Dictionary,label:String,confirmed:bool=false,expected_token:String="missing")->bool:
 if not _open():return false
 var current=inspect("manual",index)
 if current.status=="unreadable":warning="Hard save is unreadable. Its files were left alone.";return false
 if current.token!=expected_token or (current.status=="ready" and not confirmed):warning="Confirm the current hard-save slot before replacing it.";return false
 if archive.get("active") is Dictionary and not archive.get(Table.STATE,{}).get("between",false):warning="Hard saves are available between dives only.";return false
 label=label.strip_edges().replace("\n"," ").replace("\r"," ")
 if label.is_empty() or label.length()>Table.NAME_LIMIT:warning="Use a short save name.";return false
 var data=archive.duplicate(true);data.erase(Table.RECORD)
 return _write("manual",index,data,_record("manual",data,label,""))
func save_fork(event:String,archive:Dictionary,label:String)->bool:
 if not _open() or event.is_empty() or event.length()>Table.NAME_LIMIT:return false
 var data=archive.duplicate(true);data.erase(Table.RECORD)
 var digest=var_to_bytes(data).hex_encode().sha256_text();var empty=-1;var oldest=-1;var order=Table.COUNT_LIMIT+1
 for entry in list_entries("fork"):
  if entry.status=="ready":
   if entry.record.event==event and entry.record.digest==digest:return true
   if entry.record.sequence<order:oldest=entry.index;order=entry.record.sequence
  elif entry.status=="empty" and empty<0:empty=entry.index
 var target=empty if empty>=0 else oldest
 if target<0:warning="Fork states are unreadable. Existing files were left alone.";return false
 return _write("fork",target,data,_record("fork",data,label,event))
func save_pending(archive:Dictionary,target:int,run:String,launch:String)->bool:
 if not _open() or target not in Table.TARGETS:return false
 var current=inspect("pending",0)
 if current.status=="unreadable":warning="Pending checkpoint is unreadable. Its files were left alone.";return false
 var data=archive.duplicate(true);data.erase(Table.RECORD)
 return _write("pending",0,data,_record("pending",data,"Before operation "+str(target+1),str(target),run,launch))
func load_entry(kind:String,index:int,live_store,confirmed:bool=false,expected_token:String="")->bool:
 var entry=inspect(kind,index)
 if not confirmed or entry.status!="ready" or entry.token!=expected_token:warning="Confirm the current readable snapshot before loading it.";return false
 if live_store.path!=live_path:warning="The selected campaign changed. No archive was replaced.";return false
 var bytes=live_store.encoded(entry.data)
 if bytes.is_empty():warning="Snapshot is invalid. Live campaign retained.";return false
 var old=Txn.bytes_at(live_path,Table.FILE_LIMIT) if FileAccess.file_exists(live_path) else null
 var entries={};entries[live_path]=bytes;entries[live_path+".bak"]=old;entries[live_path+".tmp"]=null
 if not Txn.replace(live_path,entries):warning=Txn.warning;return false
 warning="";return true
func delete_entry(kind:String,index:int,confirmed:bool=false,expected_token:String="")->bool:
 var entry=inspect(kind,index)
 if not confirmed or entry.token!=expected_token or entry.token=="invalid":warning="Confirm the current saved-state deletion.";return false
 var entries={};var path=entry_path(kind,index)
 if entry.retained_on_delete:
  var paths=[]
  for suffix in Table.SUFFIXES:paths.append(path+suffix)
  var ok=Txn.quarantine(live_path,paths);warning=Txn.warning;return ok
 for suffix in Table.SUFFIXES:entries[path+suffix]=null
 if not Txn.replace(live_path,entries):warning=Txn.warning;return false
 warning="";return true
func delete_all(confirmed:bool=false)->bool:
 if not confirmed or not _open():return false
 var retained=false
 for kind in Table.KINDS:
  for entry in list_entries(kind):
   if entry.status!="empty":
    retained=retained or entry.retained_on_delete
    if not delete_entry(kind,entry.index,true,entry.token):return false
 if retained:warning="Saved states cleared. Unreadable oversized originals were retained for recovery."
 return true
