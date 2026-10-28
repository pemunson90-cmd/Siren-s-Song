extends SceneTree
const Profiles=preload("res://src/persistence/profiles/profile_store.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Archive=preload("res://src/campaign/challenges/challenge_archive.gd")
const RunArchive=preload("res://src/campaign/runs/run_archive.gd")
const RunState=preload("res://src/campaign/runs/run_state.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func data(completed=[]):return {"version":1,"unlocked":0,"completed":completed,"settings":{},"upgrade":"endurance"}
func _initialize():call_deferred("run")
func cold_process():
 var p=Profiles.new()
 check(p.open() and p.state.active==1,"child process restores active profile")
 var store=Store.new()
 check(store.path==p.slot_path(1) and store.load_game().completed==[0,1],"child process loads selected campaign")
 var first=Archive.new();first.path=p.slot_path(0)+".challenges"
 var second=Archive.new();second.path=p.slot_path(1)+".challenges"
 check(not first.load_game().get("challenges",{}).is_empty() and second.load_game().is_empty(),"child process keeps challenge records isolated")
 var run_first=RunArchive.new();run_first.path=p.slot_path(0)+".runs"
 var run_second=RunArchive.new();run_second.path=p.slot_path(1)+".runs"
 check(run_first.load_game().get("run",{})==RunState.new_run(31) and run_second.load_game().is_empty(),"child process keeps run ledgers isolated by profile slot")
 print("SAVE PROFILES COLD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func run():
 if "--cold" in OS.get_cmdline_user_args():cold_process();return
 var p=Profiles.new();p.directory="user://profile-fixture";p.legacy="user://legacy-fixture.save"
 # Clean only this suite's fixed isolated user fixture.
 DirAccess.make_dir_recursive_absolute(p.directory)
 var dir=DirAccess.open(p.directory)
 for file in dir.get_files():
  if DirAccess.remove_absolute(p.directory+"/"+file)!=OK:check(false,"fixture cleanup")
 for suffix in p.Rules.SUFFIXES:DirAccess.remove_absolute(p.legacy+suffix)
 var legacy=Store.new();legacy.path=p.legacy
 check(legacy.save(data()) and legacy.save(data([0])),"legacy primary and backup saved")
 var challenge=Archive.new();challenge.path=p.legacy+".challenges"
 check(challenge.save({"version":1,"challenges":{}}) and challenge.save({"version":1,"challenges":{}}),"challenge primary and backup saved")
 var run_archive=RunArchive.new();run_archive.path=p.legacy+".runs"
 var run_state=RunState.new_run(31)
 check(run_archive.save({"version":1,"run":run_state}) and run_archive.save({"version":1,"run":run_state}),"run archive primary and backup saved")
 var original=p._snapshot(p.legacy)
 check(p.open(),"migrate legacy profile")
 check(p.snapshot(0)==original and p._snapshot(p.legacy)==original,"all eight sidecars migrate byte for byte retaining originals")
 var migrated_run=RunArchive.new();migrated_run.path=p.slot_path(0)+".runs"
 check(not original[".runs"].is_empty() and not original[".runs.bak"].is_empty() and migrated_run.load_game().get("run",{})==run_state,"migration preserves both valid slot-pinned run sidecars")
 check(p.rename_profile(0,"First patrol") and p.rename_profile(1,"Second patrol"),"bounded names persist")
 check(not p.rename_profile(1," ") and not p.rename_profile(1,"x".repeat(25)),"invalid names rejected")
 var fresh=Profiles.new();fresh.directory=p.directory;fresh.legacy=p.legacy
 check(fresh.open() and fresh.state.names[0]=="First patrol","cold model reload names")
 check(p.select(1),"select second slot")
 var other=Store.new();other.path=p.slot_path(1)
 check(other.save(data([0,1])),"write independent second campaign")
 check(p.snapshot(0)==original,"second-slot progress leaves all first-slot bytes identical")
 var before=p.snapshot(1)
 check(not p.copy(0,1,false) and p.snapshot(1)==before,"cancel overwrite does not write")
 check(p.copy(0,1,true) and p.snapshot(1)==original,"copy includes all eight raw sidecars")
 check(p.undo(true) and p.snapshot(1)==before,"undo copy restores absence and original target bytes")
 check(p.clear(0,true) and p.snapshot(0)=={"":null,".bak":null,".challenges":null,".challenges.bak":null,".runs":null,".runs.bak":null,".career":null,".career.bak":null},"clear removes all eight sidecars")
 check(p.rename_profile(0,"Renamed during undo"),"rename within undo window")
 check(p.undo(true) and p.snapshot(0)==original and p.state.names[0]=="First patrol","undo clear restores all eight sidecars and prior name")
 var exported=p.export_profile(0)
 check(not exported.is_empty(),"valid profile exports single file")
 var invalid_utf8=var_to_bytes({"files":{}});invalid_utf8[16]=255
 check(p.Codec.decode(invalid_utf8)==null,"reject malformed UTF8 before Variant decoder")
 var package_bytes=FileAccess.get_file_as_bytes(exported)
 check(p._write(exported,package_bytes+PackedByteArray([7,8])) and p.read_package(exported).is_empty(),"reject package trailing bytes")
 check(p._write(exported,package_bytes.slice(0,package_bytes.size()-1)) and p.read_package(exported).is_empty(),"reject truncated package")
 var trailing_envelope=bytes_to_var(package_bytes)
 trailing_envelope.payload+=PackedByteArray([7,8]);trailing_envelope.length=trailing_envelope.payload.size();trailing_envelope.checksum=trailing_envelope.payload.hex_encode().sha256_text()
 check(p._write(exported,var_to_bytes(trailing_envelope)) and p.read_package(exported).is_empty(),"reject payload trailing bytes even with recomputed checksum")
 check(p._write(exported,package_bytes),"restore complete package fixture")
 var imported=p.read_package(exported)
 check(imported==original,"validated package preserves raw bytes")
 var legacy_files=original.duplicate(true);legacy_files.erase(".runs");legacy_files.erase(".runs.bak");legacy_files.erase(".career");legacy_files.erase(".career.bak")
 var legacy_payload=var_to_bytes({"files":legacy_files})
 var legacy_package=var_to_bytes({"magic":p.Rules.MAGIC,"version":p.Rules.VERSION,"length":legacy_payload.size(),"checksum":legacy_payload.hex_encode().sha256_text(),"payload":legacy_payload})
 check(p._write(exported,legacy_package),"write legacy four-sidecar package")
 var legacy_import=p.read_package(exported)
 check(legacy_import.size()==8 and legacy_import[""]==original[""] and legacy_import[".bak"]==original[".bak"] and legacy_import[".challenges"]==original[".challenges"] and legacy_import[".challenges.bak"]==original[".challenges.bak"] and legacy_import[".runs"]==null and legacy_import[".runs.bak"]==null and legacy_import[".career"]==null and legacy_import[".career.bak"]==null,"legacy four-sidecar package imports with empty run history")
 check(p._write(exported,package_bytes),"restore eight-sidecar export fixture")
 check(p.replace(1,imported,true) and p.snapshot(1)==original,"import round trips all files")
 var no_challenges=before.duplicate(true)
 check(p.replace(1,no_challenges,true) and not FileAccess.file_exists(p.slot_path(1)+".challenges"),"replacing challenge-free profile removes stale archive")
 var f=FileAccess.open(exported,FileAccess.WRITE);f.store_buffer(var_to_bytes({"magic":"wrong"}));f.close()
 var keep=p.snapshot(1)
 # Every outer envelope rejection is validated before the target is touched.
 var valid_payload=var_to_bytes({"files":original})
 var envelope={"magic":p.Rules.MAGIC,"version":1,"length":valid_payload.size(),"checksum":valid_payload.hex_encode().sha256_text(),"payload":valid_payload}
 for key in ["magic","version","length","checksum","payload"]:
  var broken=envelope.duplicate(true);broken[key]="invalid"
  check(p._write(exported,var_to_bytes(broken)),"write invalid envelope fixture")
  check(p.read_package(exported).is_empty() and p.snapshot(1)==keep,"reject malformed "+key+" without writes")
 var invalid_files=original.duplicate(true);invalid_files[".challenges"]=PackedByteArray([4,5,6])
 var invalid_payload=var_to_bytes({"files":invalid_files})
 var invalid_envelope=envelope.duplicate(true);invalid_envelope.payload=invalid_payload;invalid_envelope.length=invalid_payload.size();invalid_envelope.checksum=invalid_payload.hex_encode().sha256_text()
 check(p._write(exported,var_to_bytes(invalid_envelope)) and p.read_package(exported).is_empty() and p.snapshot(1)==keep,"valid checksum cannot bypass inner archive validation")
 var invalid_runs=original.duplicate(true);invalid_runs[".runs"]=PackedByteArray([4,5,6])
 var invalid_run_payload=var_to_bytes({"files":invalid_runs})
 var invalid_run_envelope=envelope.duplicate(true);invalid_run_envelope.payload=invalid_run_payload;invalid_run_envelope.length=invalid_run_payload.size();invalid_run_envelope.checksum=invalid_run_payload.hex_encode().sha256_text()
 check(p._write(exported,var_to_bytes(invalid_run_envelope)) and p.read_package(exported).is_empty() and p.snapshot(1)==keep,"corrupt run sidecar rejects import without target writes")
 # A real filesystem staging failure cannot alter an earlier target file.
 var obstruction=p.slot_path(1)+".bak.stage"
 check(DirAccess.make_dir_recursive_absolute(obstruction)==OK,"create real staging obstruction")
 check(not p.copy(0,1,true) and p.snapshot(1)==keep,"filesystem failure leaves all target bytes and absence unchanged")
 check(DirAccess.remove_absolute(obstruction)==OK,"remove staging obstruction")
 check(p.read_package(exported).is_empty() and p.snapshot(1)==keep,"corrupt import rejected without target writes")
 var damaged=original.duplicate(true);damaged[""]=PackedByteArray([1,2,3])
 check(p.replace(2,damaged,true),"raw damaged profiles remain copyable")
 check(p.export_profile(2).is_empty() and p.snapshot(2)==damaged,"invalid export refused retaining raw files")
 var recover=Store.new();recover.path=p.slot_path(2)
 check(not recover.load_game().is_empty() and not recover.warning.is_empty(),"backup-only recovery keeps legacy meanings")
 var cold=Profiles.new();cold.directory=p.directory;cold.legacy=p.legacy
 check(cold.open() and cold.state.active==1 and cold.snapshot(0)==original,"cold restart keeps active slot and independent archive")
 p.undo_until=0
 check(not p.undo(true),"expired undo cannot replace later progress")
 check(not p.select(-1) and not p.clear(3,true) and p.slot_path(3).is_empty(),"indices cannot escape fixed three slots")
 # Default paths migrate lazily, pin once, and explicit fixture paths bypass them.
 var custom=Store.new();custom.path="user://custom-only.save"
 check(not custom.uses_profiles() and custom.path=="user://custom-only.save" and custom.valid(data()),"custom paths and pure validation preserved")
 var default_profiles=Profiles.new()
 check(default_profiles.open() and default_profiles.select(0),"open actual default profiles")
 var pinned=Store.new();var first=pinned.path
 check(default_profiles.select(1),"change active default profile")
 var new_store=Store.new()
 check(first!=new_store.path and pinned.path==first,"old Store path stays pinned across selection")
 check(default_profiles.clear(0,true),"clear pinned slot before queued-save rejection")
 pinned.suspended=true
 check(not pinned.save(data()) and not FileAccess.file_exists(first),"quiesced old session cannot recreate cleared files")
 # Simulate interrupted replacement; journal must restore file and absence before open.
 var transaction={p.slot_path(1):keep[""],p.slot_path(1)+".challenges":null}
 check(p._write(p.directory+"/transaction",var_to_bytes(transaction)),"stage interrupted transaction journal")
 check(p._write(p.slot_path(1),PackedByteArray([9])) and p._write(p.slot_path(1)+".challenges",PackedByteArray([9])),"simulate interrupted write")
 var recovered=cold.open()
 if not recovered:printerr(cold.warning)
 check(recovered and cold.snapshot(1)==keep,"cold open rolls back interrupted files and absence")
  # A cached healthy model must fail closed when a later recovery cannot open.
 var blocked=Profiles.new();blocked.directory="user://profiles-blocked-fixture";blocked.legacy="user://absent-profile-legacy"
 DirAccess.make_dir_recursive_absolute(blocked.directory)
 var blocked_dir=DirAccess.open(blocked.directory)
 for file in blocked_dir.get_files():
  if DirAccess.remove_absolute(blocked.directory+"/"+file)!=OK:check(false,"blocked fixture cleanup")
 check(blocked.open(),"seed cached healthy profile model")
 var broken_journal=PackedByteArray([1,2,3])
 check(blocked._write(blocked.directory+"/transaction",broken_journal),"seed unrecoverable journal")
 check(not blocked.open() and blocked.state.is_empty(),"failed recovery invalidates cached profile state")
 check(not blocked.clear(0,true) and FileAccess.get_file_as_bytes(blocked.directory+"/transaction")==broken_journal,"failed recovery blocks mutation and preserves journal bytes")
 check(DirAccess.remove_absolute(blocked.directory+"/transaction")==OK,"remove only blocked fixture journal")
 check(blocked.open(),"reopen fixture after journal repair")
 check(blocked._write(blocked.directory+"/index",broken_journal) and blocked._write(blocked.directory+"/index.bak",broken_journal),"seed unreadable primary and backup index")
 check(not blocked.open() and blocked.state.is_empty() and not blocked.select(2),"unreadable index invalidates cached state and selection")
 check(FileAccess.get_file_as_bytes(blocked.directory+"/index")==broken_journal and not FileAccess.file_exists(blocked.directory+"/transaction"),"blocked index mutation cannot replace metadata or journal")
 # Actual second native process proves persisted selection and challenge separation.
 var seed0=Store.new();seed0.path=default_profiles.slot_path(0)
 var seed1=Store.new();seed1.path=default_profiles.slot_path(1)
 check(seed0.save(data([0])) and seed1.save(data([0,1])),"seed real cold-process campaigns")
 var records=load("res://src/campaign/challenges/challenge_records.gd").add({},"shelf_passive",{"time":30.,"hull":100.,"tools_used":{},"loss":false})
 var saved_challenge=Archive.new();saved_challenge.path=default_profiles.slot_path(0)+".challenges"
 check(saved_challenge.save({"version":1,"challenges":records}),"seed real first-profile challenges")
 var saved_run=RunArchive.new();saved_run.path=default_profiles.slot_path(0)+".runs"
 check(saved_run.save({"version":1,"run":RunState.new_run(31)}),"seed real first-profile run archive")
 var bytes_before=default_profiles.snapshot(0)
 var output=[]
 var status=OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--audio-driver","Dummy","--script","res://tests/save_profiles_tests.gd","--","--cold"],output,true)
 for line in output:print(line)
 check(status==0 and "SAVE PROFILES COLD CHECKS 4 FAILURES 0" in str(output),"separate native cold process verifies disk state")
 check(default_profiles.snapshot(0)==bytes_before,"cold process leaves other profile byte-identical")
 print("SAVE PROFILES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
