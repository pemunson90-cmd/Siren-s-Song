extends SceneTree
# Transfer seam (handoff 075): fake dialog and callbacks only; no real native dialog is opened.
const Profiles=preload("res://src/persistence/profiles/profile_store.gd")
const Transfer=preload("res://src/persistence/profiles/profile_transfer.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Economy=preload("res://src/campaign/economy.gd")
var checks=0
var failures=0
var calls=[]
var pending:Callable
var fail_open=false
var message=""
var picked={}
class WriteOnlyFile extends RefCounted:
 var succeeds=false
 var closed=false
 var writes=0
 func store_buffer(_bytes):writes+=1;return succeeds
 func flush():pass
 func get_error():return OK # Android reports EOF/OK independently of write failure.
 func close():closed=true
class WriteOnlyTransfer extends Transfer:
 var stream=WriteOnlyFile.new()
 var reads=0
 func _open_external(_path,mode):
  if mode==FileAccess.WRITE:return stream
  reads+=1;return null
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func data(completed=[]):return {"version":1,"unlocked":0,"completed":completed,"settings":{},"upgrade":"endurance"}
func fake_show(title,dir,filename,mode,filters,cb):
 calls.append({"title":title,"filename":filename,"mode":mode,"filters":filters});pending=cb
 return ERR_UNAVAILABLE if fail_open else OK
func yes_dialog():return true
func no_dialog():return false
func note(m):message=m
func got(files,m):picked=files;message=m
func _initialize():call_deferred("run")
func clean(dir):
 DirAccess.make_dir_recursive_absolute(dir)
 for file in DirAccess.open(dir).get_files():DirAccess.remove_absolute(dir+"/"+file)
func handover_export():
 var game=load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 for n in 6:await process_frame
 var front=game.get_node("Frontend")
 var picker=front.profile_picker
 picker.show_picker()
 var model=picker.model
 var save=Store.new();save.path=model.slot_path(0)
 check(save.save(data([0])),"handover export fixture writes real profile")
 var before=model.snapshot(0)
 picker.mutate(func():return model.select(1))
 for n in 12:await process_frame
 check(not is_instance_valid(game),"handover retires the original host")
 var fresh=root.get_child(root.get_child_count()-1)
 var replacement=fresh.get_node("Frontend").profile_picker
 check(replacement.model==model and replacement.transfer.model==model,"handover shares the opened store with transfer helper")
 var t=replacement.transfer;t.platform="Android";t.probe=yes_dialog;t.show=fake_show
 calls.clear();message=""
 var path="user://handover-export.qprofile"
 t.export_to(0,note)
 check(calls.size()==1 and t.busy,"Android export opens after real profile handover")
 if t.busy:
  pending.call(true,PackedStringArray([path]),0)
  check(message=="EXPORT SAVED." and model.read_package(path)==before,"handover export preserves selected package bytes")
 check(model.state.active==1 and model.snapshot(0)==before,"export preserves active choice and independent source profile")
 fresh.free()
func run():
 var p=Profiles.new();p.directory="user://transfer-fixture";p.legacy="user://transfer-legacy.save"
 clean(p.directory);for suffix in p.Rules.SUFFIXES:DirAccess.remove_absolute(p.legacy+suffix)
 var legacy=Store.new();legacy.path=p.legacy
 check(legacy.save(data()) and legacy.save(data([0])) and p.open(),"fixture profile")
 var t=Transfer.new();t.model=p;t.platform="Android";t.show=fake_show
 var ext="user://transfer-fixture/external.qprofile"
 # Capability routing.
 t.probe=yes_dialog
 check(t.route()=="dialog","dialog route when probe passes on Android")
 t.platform="Windows";check(t.route()=="local","desktop keeps the app folder list")
 t.platform="Android";t.probe=no_dialog;t.downloads_dir=""
 check(t.route()=="none","no dialog and no downloads folder fails closed")
 t.downloads_dir=p.directory;check(t.route()=="downloads","downloads fallback when folder exists")
 t.probe=yes_dialog
 # Export through the fake dialog.
 t.export_to(0,note)
 check(calls.size()==1 and calls[0].mode==DisplayServer.FILE_DIALOG_MODE_SAVE_FILE and calls[0].filename=="siren-profile-slot1.qprofile","save dialog suggests slot name")
 check(t.busy and "*.qprofile" in calls[0].filters[0],"dialog filtered to qprofile and marks busy")
 t.export_to(0,note);check(message.contains("already open") and calls.size()==1,"second request while open is refused")
 pending.call(false,PackedStringArray(),0)
 check(message==Transfer.MSG_CANCEL and not t.busy and not FileAccess.file_exists(ext),"cancel is a no-op with a plain notice")
 t.export_to(0,note);pending.call(true,PackedStringArray([ext]),0)
 check(message=="EXPORT SAVED." and FileAccess.file_exists(ext),"saved export written to the chosen path")
 # A failed Android write may leave get_error()==OK and no read permission.
 var write_only=WriteOnlyTransfer.new();write_only.model=p;write_only.platform="Android";write_only.probe=yes_dialog;write_only.show=fake_show
 write_only.export_to(0,note);pending.call(true,PackedStringArray(["content://fixture/export"]),0)
 check(message.contains("Could not write") and message!="EXPORT SAVED.","failed write to unreadable URI cannot report export saved")
 check(write_only.stream.writes==1 and write_only.stream.closed and write_only.reads==0,"failed write closes stream and never accepts unreadable readback")
 write_only.stream=WriteOnlyFile.new();write_only.stream.succeeds=true
 write_only.export_to(0,note);pending.call(true,PackedStringArray(["content://fixture/export"]),0)
 check(message=="EXPORT SAVED." and write_only.reads==1 and write_only.stream.closed,"successful write-only URI remains supported")
 # Import round trip into another slot.
 t.import_pick(got);check(calls[-1].mode==DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,"open dialog uses open mode")
 pending.call(true,PackedStringArray([ext]),0)
 check(picked==p.snapshot(0) and message.is_empty(),"imported files equal the exported profile")
 var keep=p.snapshot(1)
 t.import_pick(got);pending.call(false,PackedStringArray(),0)
 check(picked.is_empty() and message==Transfer.MSG_CANCEL and p.snapshot(1)==keep,"import cancel changes nothing")
 # Corrupt, foreign and oversized files are refused before any replacement.
 var good=FileAccess.get_file_as_bytes(ext)
 var bad=good.duplicate();bad[bad.size()-3]^=255
 for pair in [[bad,"corrupt"],[PackedByteArray([1,2,3,4]),"foreign"],[PackedByteArray(),"empty"]]:
  var f=FileAccess.open(ext,FileAccess.WRITE);f.store_buffer(pair[0]);f.close()
  t.import_pick(got);pending.call(true,PackedStringArray([ext]),0)
  check(picked.is_empty() and not message.is_empty() and p.snapshot(1)==keep,pair[1]+" file refused with a message")
 check(t.load_path("user://transfer-fixture/missing.qprofile").is_empty() and p.warning.contains("unavailable"),"missing file refused")
 check(p.parse_package(PackedByteArray([0]).duplicate()).is_empty(),"parse_package rejects garbage")
 # Dialog errors and stale callbacks.
 fail_open=true;t.export_to(0,note)
 check(message.contains("Could not open") and not t.busy,"dialog open failure reported");fail_open=false
 t.export_to(0,note);var old=pending;message="";t.reset();old.call(true,PackedStringArray([ext]),0)
 check(message.is_empty(),"callback after leaving the screen is ignored")
 # Downloads fallback and unreachable device.
 t.probe=no_dialog;t.export_to(0,note)
 check(message.begins_with("EXPORTED TO") and t.choices().size()>=1,"downloads route writes and lists files")
 t.downloads_dir="";t.export_to(0,note);check(message==Transfer.MSG_NONE,"unreachable device says so plainly");t.downloads_dir=null
 # Ironman guards stay enforced through the seam.
 var slot=Store.new();slot.path=p.slot_path(2)
 check(slot.save({"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","economy":Economy.new_state("standard",true)}),"ironman fixture")
 t.probe=yes_dialog;calls.clear();message=""
 t.export_to(2,note)
 check(calls.is_empty() and message.contains("one timeline"),"ironman export refused before any dialog")
 var iron=p.snapshot(2)
 var payload=var_to_bytes({"files":iron})
 var pack=var_to_bytes({"magic":p.Rules.MAGIC,"version":p.Rules.VERSION,"length":payload.size(),"checksum":payload.hex_encode().sha256_text(),"payload":payload})
 var f2=FileAccess.open(ext,FileAccess.WRITE);f2.store_buffer(pack);f2.close()
 t.import_pick(got);pending.call(true,PackedStringArray([ext]),0)
 check(not picked.is_empty() and not p.replace(1,picked,true) and p.snapshot(1)==keep,"importing an ironman package cannot replace a profile")
 check(not p.replace(2,p.snapshot(0),true) and p.snapshot(2)==iron,"import over an ironman profile refused")
 t.reset()
 await handover_export()
 print("SAVE PROFILES TRANSFER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
