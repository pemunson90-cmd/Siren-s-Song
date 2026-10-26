extends RefCounted
# Leaf optional-field validation, independent of Store/UI to avoid load cycles.
const Table=preload("res://src/persistence/save_states/save2_table.gd")
static func integer(value,low:int,high:int)->bool:
 return value is int and value>=low and value<=high
static func hex(value,count:int)->bool:
 if not value is String or value.length()!=count:return false
 for c in value:
  if c not in "0123456789abcdef":return false
 return true
static func valid(data:Dictionary)->bool:
 if data.has(Table.STATE):
  var s=data[Table.STATE]
  if not s is Dictionary or s.size()!=8 or not s.has_all(["revision","run_id","launch_id","credited_launch","recoveries","last_recovered","legacy_minimum","between"]):return false
  if not integer(s.revision,1,1) or not hex(s.run_id,32) or not hex(s.launch_id,32) or not (s.credited_launch=="" or hex(s.credited_launch,32)):return false
  if not integer(s.recoveries,0,Table.COUNT_LIMIT) or not integer(s.last_recovered,-1,31) or not s.legacy_minimum is bool or not s.between is bool:return false
 if data.has(Table.RECORD):
  var r=data[Table.RECORD]
  if not r is Dictionary or r.size()!=11 or not r.has_all(["revision","kind","label","timestamp","sequence","event","digest","recovery_count","last_operation","run_id","launch_id"]):return false
  if not integer(r.revision,1,1) or r.kind not in Table.KINDS or not r.label is String or r.label.is_empty() or r.label.length()>Table.NAME_LIMIT or "\n" in r.label or "\r" in r.label:return false
  if not integer(r.timestamp,0,9007199254740991) or not integer(r.sequence,1,Table.COUNT_LIMIT) or not r.event is String or r.event.length()>Table.NAME_LIMIT or not hex(r.digest,64):return false
  if not integer(r.recovery_count,0,Table.COUNT_LIMIT) or not integer(r.last_operation,0,32):return false
  if not (r.run_id=="" or hex(r.run_id,32)) or not (r.launch_id=="" or hex(r.launch_id,32)):return false
  if r.kind=="fork" and r.event.is_empty():return false
  var snapshot=data.duplicate(true);snapshot.erase(Table.RECORD)
  if r.digest!=var_to_bytes(snapshot).hex_encode().sha256_text():return false
 return true
