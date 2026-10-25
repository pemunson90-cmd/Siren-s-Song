extends RefCounted
# Bounded one-entry journal. Seams: SAVE2 storage and Store read/write guard.
# No archive/Store/UI dependency. A pending rollback is recovered even flag off.
const Table=preload("res://src/persistence/save_states/save2_table.gd")
const Codec=preload("res://src/persistence/profiles/profile_codec.gd")
static var warning=""
static var test_failures=[]
static func _fail(step:String)->bool:
 if step not in test_failures:return false
 test_failures.erase(step);return true
static func directory(live:String)->String:return live+".save2"
static func entry_path(live:String,kind:String,index:int)->String:
 if kind not in Table.KINDS or index<0 or index>=Table.count(kind):return ""
 return directory(live)+"/"+kind+str(index+1)+".save"
static func allowed(live:String,path:String)->bool:
 for suffix in Table.SUFFIXES:
  if path==live+suffix:return true
 for kind in Table.KINDS:
  for index in Table.count(kind):
   for suffix in Table.SUFFIXES:
    if path==entry_path(live,kind,index)+suffix:return true
 return false
static func bytes_at(path:String,limit:int)->Variant:
 var f=FileAccess.open(path,FileAccess.READ)
 if f==null or f.get_length()>limit:return null
 var b=f.get_buffer(f.get_length());var ok=f.get_error()==OK;f.close()
 return b if ok else null
static func size_at(path:String)->int:
 var f=FileAccess.open(path,FileAccess.READ)
 if f==null:return -1
 var size=f.get_length();f.close();return size
static func write_bytes(path:String,bytes:PackedByteArray)->bool:
 var f=FileAccess.open(path,FileAccess.WRITE)
 if f==null:return false
 f.store_buffer(bytes);f.flush();var ok=f.get_error()==OK;f.close()
 return ok and bytes_at(path,maxi(bytes.size(),1))==bytes
static func remove_file(path:String)->bool:
 if DirAccess.dir_exists_absolute(path):return false
 return not FileAccess.file_exists(path) or DirAccess.remove_absolute(path)==OK
static func _error(text:String)->bool:
 warning=text+" Original files retained; SAVE2 recovery must succeed before further writes."
 return false
static func _retained_valid(live:String,value:Dictionary)->bool:
 if value.size()!=2 or not value.get("retained") is String or not value.get("bytes") is int or value.bytes<0:return false
 var folder=value.retained.get_base_dir();var code=folder.get_file()
 if folder.get_base_dir()!=directory(live)+"/retained" or code.length()!=32 or value.retained.get_file() not in ["0","1","2"]:return false
 for c in code:
  if c not in "0123456789abcdef":return false
 return true
static func _decode(live:String)->Variant:
 var raw=bytes_at(directory(live)+"/transaction",Table.JOURNAL_LIMIT)
 if not raw is PackedByteArray:return null
 var envelope=Codec.decode(raw)
 if not envelope is Dictionary or envelope.size()!=3 or envelope.get("magic")!="QUIETUS_SAVE2_TXN" or not envelope.get("payload") is PackedByteArray or not envelope.get("checksum") is String:return null
 if envelope.payload.hex_encode().sha256_text()!=envelope.checksum:return null
 var journal=Codec.decode(envelope.payload)
 if not journal is Dictionary or journal.size()!=3 or journal.get("revision")!=1 or journal.get("live")!=live or not journal.get("before") is Dictionary:return null
 if journal.before.is_empty() or journal.before.size()>Table.SUFFIXES.size():return null
 for path in journal.before:
  if not path is String or not allowed(live,path):return null
  var value=journal.before[path]
  if value is Dictionary:
   if not _retained_valid(live,value):return null
  elif value!=null and (not value is PackedByteArray or value.size()>Table.FILE_LIMIT):return null
 return journal.before
static func _restore(before:Dictionary)->bool:
 if _fail("rollback"):return false
 for path in before:
  if before[path]==null:
   if not remove_file(path):return false
  elif before[path] is Dictionary:
   var retained:Dictionary=before[path]
   if FileAccess.file_exists(retained.retained):
    if not remove_file(path) or DirAccess.rename_absolute(retained.retained,path)!=OK:return false
   elif not FileAccess.file_exists(path) or size_at(path)!=retained.bytes:return false
  elif not write_bytes(path,before[path]):return false
 return true
static func _cleanup(live:String,before:Dictionary)->bool:
 for path in before:
  if not remove_file(path+".save2-stage"):return false
 return remove_file(directory(live)+"/transaction.tmp") and remove_file(directory(live)+"/transaction")
static func recover(live:String)->bool:
 warning=""
 var journal=directory(live)+"/transaction"
 if not FileAccess.file_exists(journal):
  if DirAccess.dir_exists_absolute(journal):return _error("SAVE2 journal is not a readable file.")
  return true
 var before=_decode(live)
 if not before is Dictionary:return _error("SAVE2 recovery journal is unreadable.")
 if not _restore(before) or not _cleanup(live,before):return _error("SAVE2 rollback is pending.")
 return true
static func _journal(live:String,before:Dictionary)->bool:
 var payload=var_to_bytes({"revision":1,"live":live,"before":before})
 var envelope=var_to_bytes({"magic":"QUIETUS_SAVE2_TXN","payload":payload,"checksum":payload.hex_encode().sha256_text()})
 var journal=directory(live)+"/transaction"
 if envelope.size()>Table.JOURNAL_LIMIT or _fail("journal") or not write_bytes(journal+".tmp",envelope):return _error("Cannot journal SAVE2 data.")
 if DirAccess.rename_absolute(journal+".tmp",journal)!=OK:return _error("Cannot commit SAVE2 journal.")
 return true
static func quarantine(live:String,paths:Array)->bool:
 # Explicit deletion of oversized unreadable files clears the slot by rename,
 # retaining originals without loading unbounded bytes into memory.
 if live.is_empty() or not recover(live) or paths.is_empty() or paths.size()>Table.SUFFIXES.size():return false
 var bucket=directory(live)+"/retained/"+Table.identity()
 if DirAccess.make_dir_recursive_absolute(bucket)!=OK:return _error("Cannot retain unreadable SAVE2 originals.")
 var before={};var index=0
 for path in paths:
  if not path is String or not allowed(live,path) or DirAccess.dir_exists_absolute(path):return _error("Invalid SAVE2 retention path.")
  before[path]=null
  if FileAccess.file_exists(path):
   var size=size_at(path)
   if size<0:return _error("Cannot inspect unreadable SAVE2 original.")
   before[path]={"retained":bucket+"/"+str(index),"bytes":size}
  index+=1
 if not _journal(live,before):return false
 var ok=true;index=0
 for path in before:
  if before[path]!=null and DirAccess.rename_absolute(path,before[path].retained)!=OK:ok=false;break
  index+=1
  if _fail("quarantine_"+str(index)):ok=false;break
 if not ok:
  if not _restore(before) or not _cleanup(live,before):return _error("SAVE2 retention rollback is pending.")
  warning="Saved-state deletion failed and was rolled back.";return false
 if not _cleanup(live,before):
  if not _restore(before):return _error("SAVE2 retention finalization rollback is pending.")
  return _error("SAVE2 deletion was rolled back.")
 warning="Slot cleared. Unreadable originals were retained for recovery.";return true
static func replace(live:String,entries:Dictionary)->bool:
 if live.is_empty() or not recover(live):return false
 if entries.is_empty() or entries.size()>Table.SUFFIXES.size():return _error("Invalid SAVE2 transaction size.")
 if DirAccess.make_dir_recursive_absolute(directory(live))!=OK:return _error("Cannot open SAVE2 storage.")
 var before={}
 for path in entries:
  if not path is String or not allowed(live,path) or DirAccess.dir_exists_absolute(path):return _error("Invalid SAVE2 transaction path.")
  var value=entries[path]
  if value!=null and (not value is PackedByteArray or value.size()>Table.FILE_LIMIT):return _error("Invalid SAVE2 transaction bytes.")
  before[path]=null
  if FileAccess.file_exists(path):
   before[path]=bytes_at(path,Table.FILE_LIMIT)
   if not before[path] is PackedByteArray:return _error("Cannot preserve SAVE2 rollback bytes.")
  if value!=null and (_fail("stage") or not write_bytes(path+".save2-stage",value)):return _error("Cannot stage SAVE2 data.")
 if not _journal(live,before):return false
 var ok=true;var index=0
 for path in entries:
  if not remove_file(path):ok=false;break
  if entries[path]!=null and DirAccess.rename_absolute(path+".save2-stage",path)!=OK:ok=false;break
  index+=1
  if _fail("commit_"+str(index)):ok=false;break
 if not ok:
  if not _restore(before) or not _cleanup(live,before):return _error("SAVE2 rollback is pending.")
  warning="SAVE2 write failed and was rolled back. Previous files retained.";return false
 if _fail("finalize") or not _cleanup(live,before):
  if not _restore(before):return _error("SAVE2 finalization rollback is pending.")
  # Keep the journal until a successful cold recovery finalizes the rollback.
  return _error("SAVE2 finalization failed; previous files restored.")
 return true
