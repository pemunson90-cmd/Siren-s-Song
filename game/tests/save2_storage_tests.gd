extends SceneTree
# Real-disk contract for bounded hard-save slots and restore metadata.
const SaveStore=preload("res://src/persistence/save_store.gd")
const ModulePath="res://src/persistence/save_states/save2_store.gd"
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func clean(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func archive(version,unlocked=0):
	return {"version":version,"unlocked":unlocked,"completed":[],"settings":{},"upgrade":"endurance","marker":{"whole":"archive","revision":4}}
func same_archive(actual,expected):
	var copy=actual.duplicate(true);copy.erase("save2_record")
	return copy==expected
func ready_count(manager,kind,count):
	var total=0
	for index in count:
		if manager.inspect(kind,index).status=="ready":total+=1
	return total
func find_event(manager,event):
	for index in 4:
		var item=manager.inspect("fork",index)
		if item.status=="ready" and item.get("record",{}).get("event","")==event:return index
	return -1
func write_bytes(path,bytes):
	var file=FileAccess.open(path,FileAccess.WRITE)
	if file==null:return false
	file.store_buffer(bytes);file.flush();file.close();return true
func file_set(path):
	var files={}
	for suffix in ["",".bak",".tmp"]:
		files[suffix]=FileAccess.get_file_as_bytes(path+suffix) if FileAccess.file_exists(path+suffix) else null
	return files
func encoded_payload(payload):
	var stream=StreamPeerBuffer.new()
	stream.put_utf8_string("QUIETUS_PASS0")
	stream.put_utf8_string(payload.hex_encode().sha256_text())
	stream.put_u32(payload.size());stream.put_data(payload)
	return stream.data_array
func encoded_journal(live_path,before):
	var payload=var_to_bytes({"revision":1,"live":live_path,"before":before})
	return var_to_bytes({"magic":"QUIETUS_SAVE2_TXN","payload":payload,"checksum":payload.hex_encode().sha256_text()})
func clean_stages(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix+".save2-stage")
func filled_file(path,size,byte_value):
	var file=FileAccess.open(path,FileAccess.WRITE)
	if file==null:return false
	var chunk=PackedByteArray();chunk.resize(65536);chunk.fill(byte_value)
	var remaining=size
	while remaining>0:
		var count=mini(remaining,chunk.size());file.store_buffer(chunk.slice(0,count));remaining-=count
	file.flush();var ok=file.get_error()==OK;file.close()
	return ok and FileAccess.get_size(path)==size
func file_hash(path):
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null:return ""
	var context=HashingContext.new()
	if context.start(HashingContext.HASH_SHA256)!=OK:file.close();return ""
	while not file.eof_reached():
		var chunk=file.get_buffer(65536)
		if chunk.is_empty() and file.get_error()!=OK:file.close();return ""
		if context.update(chunk)!=OK:file.close();return ""
	file.close();return context.finish().hex_encode()
func file_size(path):
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null:return -1
	var size=file.get_length();file.close();return size
func find_retained_set(root_path,sizes,hashes):
	if not DirAccess.dir_exists_absolute(root_path):return ""
	var root_dir=DirAccess.open(root_path)
	if root_dir==null:return ""
	for bucket_name in root_dir.get_directories():
		var bucket=root_path+"/"+bucket_name;var matches=true
		for index in 3:
			var path=bucket+"/"+str(index)
			if not FileAccess.file_exists(path) or file_size(path)!=sizes[index] or file_hash(path)!=hashes[index]:matches=false;break
		if matches:return bucket
	return ""
func remove_tree(path):
	if not DirAccess.dir_exists_absolute(path):return
	var dir=DirAccess.open(path)
	var files=[];var directories=[]
	if dir!=null:
		files=dir.get_files();directories=dir.get_directories();dir=null
	for file_name in files:DirAccess.remove_absolute(path+"/"+file_name)
	for directory_name in directories:remove_tree(path+"/"+directory_name)
	DirAccess.remove_absolute(path)
func run():
	if not ResourceLoader.exists(ModulePath):
		check(false,"SAVE2 store module exists: "+ModulePath)
		print("SAVE2 STORAGE CHECKS ",checks," FAILURES ",failures);quit(1);return
	var Save2=load(ModulePath)
	var live_path="user://save2-storage-live-a.save"
	var other_live_path="user://save2-storage-live-b.save"
	clean(live_path);clean(other_live_path)
	var manager=Save2.new(live_path)
	var slots=manager.list_entries("manual")
	check(slots.size()==3,"manual slot list has exactly three stable entries")
	var first=archive(1);var second=archive(2,1)
	check(SaveStore.new().valid(first) and SaveStore.new().valid(second),"legacy v1 and current v2 fixtures use the existing archive validator")
	var live=SaveStore.new();live.path=live_path
	check(live.save(first),"live autosave fixture is written before sidecar operations")
	var live_bytes=FileAccess.get_file_as_bytes(live_path)
	check(manager.entry_path("manual",0)!=live_path,"manual entry uses a sidecar path separate from live autosave")
	var initial=manager.inspect("manual",0)
	check(initial.status=="empty" and initial.token=="missing","new manual slot inspects as empty with a missing token")
	check(manager.save_manual(0,first,"V1 checkpoint"),"empty manual slot accepts valid legacy v1 archive")
	var ready=manager.inspect("manual",0)
	check(ready.status=="ready" and ready.data==first,"manual slot exposes its full stored campaign archive")
	check(ready.record.label=="V1 checkpoint" and ready.record.timestamp>0,"manual metadata records its label and timestamp")
	check(ready.record.recovery_count==0 and ready.record.last_operation==0,"manual metadata derives recovered-operation summary")
	check(manager.save_manual(1,second,"V2 checkpoint"),"second slot accepts current v2 archive")
	check(manager.inspect("manual",1).data==second,"v2 archive remains intact on disk")
	check(FileAccess.get_file_as_bytes(live_path)==live_bytes,"manual slot creation leaves live autosave bytes unchanged")
	var malformed_state=first.duplicate(true);malformed_state["save2_state"]="invalid"
	check(not SaveStore.new().valid(malformed_state),"archive validator rejects malformed optional SAVE2 state type")
	var malformed_record=first.duplicate(true);malformed_record["save2_record"]=["invalid"]
	check(not SaveStore.new().valid(malformed_record),"archive validator rejects malformed optional SAVE2 record type")
	var token=ready.token
	check(not manager.save_manual(0,second,"Unconfirmed",false,token),"healthy overwrite requires explicit confirmation")
	check(not manager.save_manual(0,second,"Stale",true,"stale-token"),"overwrite rejects a stale inspection token")
	check(manager.inspect("manual",0).data==first,"rejected overwrite leaves original archive unchanged")
	check(not manager.load_entry("manual",0,live,false,token),"healthy load requires explicit confirmation")
	check(not manager.load_entry("manual",0,live,true,"stale-token"),"load rejects a stale inspection token")
	check(live.save(second),"live campaign changes before confirmed slot replacement")
	var before_load_bytes=FileAccess.get_file_as_bytes(live_path)
	check(manager.load_entry("manual",0,live,true,token),"confirmed load with current inspection token succeeds")
	check(same_archive(live.load_game(),first) and FileAccess.get_file_as_bytes(live_path)!=before_load_bytes,"load replaces the live campaign with the full slot archive")
	var after_load_bytes=FileAccess.get_file_as_bytes(live_path)
	var delete_token=manager.inspect("manual",0).token
	check(not manager.delete_entry("manual",0,false,delete_token),"healthy slot deletion requires explicit confirmation")
	check(not manager.delete_entry("manual",0,true,"stale-token"),"delete rejects a stale inspection token")
	check(manager.inspect("manual",0).status=="ready","rejected deletion retains slot contents")
	check(manager.delete_entry("manual",0,true,delete_token),"confirmed deletion with current token removes slot")
	check(manager.inspect("manual",0).status=="empty","deleted slot inspects empty")
	check(FileAccess.get_file_as_bytes(live_path)==after_load_bytes,"slot deletion leaves the loaded live autosave bytes unchanged")
	# Strict inspection rejects appended bytes and checksummed truncated Variant
	# payloads instead of accepting them or emitting a decode error.
	check(manager.save_manual(0,first,"Decoder checks"),"decoder fixture creates an otherwise valid slot")
	var decoder_path=manager.entry_path("manual",0);var decoder_bytes=FileAccess.get_file_as_bytes(decoder_path)
	var trailing=decoder_bytes.duplicate();trailing.append_array(PackedByteArray([0xaa,0x55]))
	check(write_bytes(decoder_path,trailing),"append bytes after a valid archive envelope")
	check(manager.inspect("manual",0).status=="unreadable","strict primary inspection rejects trailing bytes")
	check(FileAccess.get_file_as_bytes(decoder_path)==trailing,"inspection leaves malformed occupied bytes untouched")
	check(write_bytes(decoder_path,decoder_bytes) and manager.inspect("manual",0).status=="ready","valid slot bytes can be restored for subsequent contracts")
	var truncated_payload=var_to_bytes(first);truncated_payload.resize(truncated_payload.size()-1)
	var truncated=encoded_payload(truncated_payload)
	check(write_bytes(decoder_path,truncated),"write checksummed envelope around truncated ordinary Variant payload")
	check(manager.inspect("manual",0).status=="unreadable","decoder rejects checksummed truncated Variant payload")
	check(write_bytes(decoder_path,decoder_bytes) and manager.inspect("manual",0).status=="ready","restore valid bytes after truncated-payload rejection")
	# An active dive is never a manual checkpoint, even when its archive passes
	# the existing serializer's structural validator.
	var active_archive=archive(1);var sim=preload("res://src/simulation/simulation.gd").new();sim.start(0);active_archive.active=sim.snapshot()
	check(SaveStore.new().valid(active_archive),"active-dive fixture remains a valid existing campaign archive")
	var active_token=manager.inspect("manual",0).token;var before_active_reject=file_set(manager.entry_path("manual",0))
	check(not manager.save_manual(0,active_archive,"Mid-dive",true,active_token),"confirmed manual save rejects an active dive rather than failing its confirmation guard")
	check(file_set(manager.entry_path("manual",0))==before_active_reject and manager.inspect("manual",0).data==first,"active-dive rejection leaves the occupied slot byte-identical")
	var between=active_archive.duplicate(true)
	between.save2_state={"revision":1,"run_id":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","launch_id":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","credited_launch":"","recoveries":3,"last_recovered":9,"legacy_minimum":false,"between":true}
	check(SaveStore.new().valid(between),"between-dive marker uses the validated live-state schema")
	var between_token=manager.inspect("manual",0).token
	check(manager.save_manual(0,between,"Between dives",true,between_token),"valid between-dive state permits a manual save with an inactive archive snapshot")
	var between_record=manager.inspect("manual",0).record
	check(between_record.recovery_count==3 and between_record.last_operation==10,"manual metadata uses credited recovery state rather than guessing from archive fields")
	# A healthy primary is still unreadable when any occupied backup/tmp sidecar
	# is corrupt; rejected writes and loads preserve all suffixes until confirm.
	var aux_path=manager.entry_path("manual",1);var aux_token=manager.inspect("manual",1).token
	check(manager.save_manual(1,first,"Corrupt backup",true,aux_token),"backup corruption fixture creates a primary/backup pair")
	var bad_backup=PackedByteArray([0x42,0x41,0x44,0x00]);check(write_bytes(aux_path+".bak",bad_backup),"corrupt an occupied backup beside a healthy primary")
	var unreadable_backup=manager.inspect("manual",1);var backup_set=file_set(aux_path)
	check(unreadable_backup.status=="unreadable","corrupt backup makes the entire slot unreadable")
	check(not manager.save_manual(1,second,"Overwrite backup",true,unreadable_backup.token),"corrupt backup prevents overwrite")
	check(not manager.load_entry("manual",1,live,true,unreadable_backup.token),"corrupt backup prevents confirmed load")
	check(file_set(aux_path)==backup_set,"rejected backup overwrite/load preserve all suffix bytes")
	check(not manager.delete_entry("manual",1,false,unreadable_backup.token),"corrupt backup deletion requires confirmation")
	check(manager.delete_entry("manual",1,true,unreadable_backup.token),"confirmed delete clears corrupt backup slot")
	check(manager.inspect("manual",1).status=="empty","corrupt backup slot is empty after confirmed delete")
	check(manager.save_manual(1,second,"Corrupt tmp"),"tmp corruption fixture creates a fresh primary")
	var bad_tmp=PackedByteArray([0x54,0x4d,0x50,0x00]);check(write_bytes(aux_path+".tmp",bad_tmp),"corrupt an occupied tmp sidecar beside a healthy primary")
	var unreadable_tmp=manager.inspect("manual",1);var tmp_set=file_set(aux_path)
	check(unreadable_tmp.status=="unreadable","corrupt tmp makes the entire slot unreadable")
	check(not manager.save_manual(1,first,"Overwrite tmp",true,unreadable_tmp.token),"corrupt tmp prevents overwrite")
	check(not manager.load_entry("manual",1,live,true,unreadable_tmp.token),"corrupt tmp prevents confirmed load")
	check(file_set(aux_path)==tmp_set,"rejected tmp overwrite/load preserve all suffix bytes")
	check(not manager.delete_entry("manual",1,false,unreadable_tmp.token),"corrupt tmp deletion requires confirmation")
	check(manager.delete_entry("manual",1,true,unreadable_tmp.token),"confirmed delete clears corrupt tmp slot")
	check(manager.inspect("manual",1).status=="empty","corrupt tmp slot is empty after confirmed delete")
	# A different pinned live path owns independent entries.
	var other=Save2.new(other_live_path);var other_live=SaveStore.new();other_live.path=other_live_path
	check(other_live.save(second),"second profile live archive is written")
	check(other.save_manual(0,second,"Profile B"),"second profile creates its own slot")
	check(manager.inspect("manual",0).data==between and other.inspect("manual",0).data==second,"sidecar slot contents are isolated by pinned live profile path")
	# A damaged occupied primary must not fall back to a valid backup or be
	# overwritten by a confirmed save. Only matching confirmed deletion clears it.
	check(manager.save_manual(2,first,"Corrupt primary"),"corruption fixture creates a manual slot")
	var slot2=manager.entry_path("manual",2);var slot_store=SaveStore.new();slot_store.path=slot2
	var first_token=manager.inspect("manual",2).token
	check(manager.save_manual(2,second,"Backup checkpoint",true,first_token),"second write creates a valid backup for corruption test")
	var primary_bytes=FileAccess.get_file_as_bytes(slot2);var backup_bytes=FileAccess.get_file_as_bytes(slot2+".bak")
	check(not backup_bytes.is_empty(),"corruption fixture has a valid prior backup")
	check(write_bytes(slot2,PackedByteArray([0x53,0x41,0x56,0x45,0x32,0x00,0xff])),"corrupt the occupied primary bytes")
	var corrupt=manager.inspect("manual",2);var corrupt_primary=FileAccess.get_file_as_bytes(slot2);var preserved_backup=FileAccess.get_file_as_bytes(slot2+".bak")
	check(corrupt.status=="unreadable" and corrupt.token!="missing","corrupt primary is shown as occupied and unreadable")
	check(not manager.save_manual(2,first,"Silent repair",true,corrupt.token),"corrupt occupied slot refuses overwrite")
	check(not manager.load_entry("manual",2,live,true,corrupt.token),"corrupt occupied slot refuses confirmed load")
	check(FileAccess.get_file_as_bytes(slot2)==corrupt_primary and FileAccess.get_file_as_bytes(slot2+".bak")==preserved_backup,"refused repair/load preserve primary and valid backup byte-for-byte")
	check(not manager.delete_entry("manual",2,false,corrupt.token),"corrupt slot still requires delete confirmation")
	check(manager.delete_entry("manual",2,true,corrupt.token),"matching confirmed delete clears unreadable slot")
	check(manager.inspect("manual",2).status=="empty","deleted corrupt entry no longer occupies the slot")
	# A slot file larger than the bounded reader is quarantined by rename, never
	# loaded as one unbounded byte array. Its original primary/backup/tmp set is
	# retained intact under the profile-local recovery directory.
	var oversized_path=manager.entry_path("manual",2)
	check(filled_file(oversized_path,4000001,0x5a),"oversized slot primary exceeds the four-million-byte read limit")
	var oversized_backup=PackedByteArray([0x71,0x72,0x73]);var oversized_tmp=PackedByteArray([0x81,0x82])
	check(write_bytes(oversized_path+".bak",oversized_backup) and write_bytes(oversized_path+".tmp",oversized_tmp),"oversized slot has occupied backup and tmp sidecars")
	var oversized_sizes=[4000001,oversized_backup.size(),oversized_tmp.size()]
	var oversized_hashes=[file_hash(oversized_path),file_hash(oversized_path+".bak"),file_hash(oversized_path+".tmp")]
	var oversized_mtime=FileAccess.get_modified_time(oversized_path);var live_before_oversized_delete=file_set(live_path)
	var oversized=manager.inspect("manual",2)
	check(oversized.status=="unreadable" and oversized.token!="missing","oversized occupied slot is unreadable rather than empty")
	check(manager.delete_entry("manual",2,true,oversized.token),"confirmed delete quarantines oversized slot without bounded-read failure")
	check(manager.inspect("manual",2).status=="empty","quarantined slot clears its physical primary/backup/tmp set")
	check(not FileAccess.file_exists(oversized_path) and not FileAccess.file_exists(oversized_path+".bak") and not FileAccess.file_exists(oversized_path+".tmp"),"confirmed oversized delete removes all three original slot paths")
	var retained_bucket=find_retained_set(manager.directory+"/retained",oversized_sizes,oversized_hashes)
	check(not retained_bucket.is_empty(),"quarantine retains exact primary/backup/tmp bytes under retained/<unique>/{0,1,2}")
	if not retained_bucket.is_empty():check(FileAccess.get_modified_time(retained_bucket+"/0")==oversized_mtime,"quarantine preserves source timestamp through rename")
	check(file_set(live_path)==live_before_oversized_delete,"oversized delete leaves live campaign archive unchanged")
	check(manager.save_manual(2,first,"After quarantine"),"manual slot can be reused after confirmed quarantine")
	# Exercise actual filesystem transaction failure points with pre-existing
	# primary, backup and tmp bytes on an allowed scoped sidecar path.
	var Txn=load("res://src/persistence/save_states/save2_transaction.gd")
	var txn_target=manager.entry_path("pending",0)
	var txn_paths=[txn_target,txn_target+".bak",txn_target+".tmp"]
	var replacement={}
	for index in 3:
		var original_bytes=PackedByteArray([0x10+index,0x20+index,0x30+index])
		var new_bytes=PackedByteArray([0x40+index,0x50+index,0x60+index])
		check(write_bytes(txn_paths[index],original_bytes),"write transaction rollback baseline "+str(index))
		replacement[txn_paths[index]]=new_bytes
	for failure in ["stage","journal","commit_1","commit_2","commit_3"]:
		var before=file_set(txn_target);Txn.test_failures=[failure]
		check(not Txn.replace(live_path,replacement),"injected "+failure+" failure rejects SAVE2 replacement")
		check(file_set(txn_target)==before,"injected "+failure+" failure preserves primary/backup/tmp bytes")
		check(not FileAccess.file_exists(manager.directory+"/transaction"),failure+" failure leaves no committed journal")
		clean_stages(txn_target)
	# Finalization failure restores bytes but leaves a journal for fresh recovery.
	var cold_store=SaveStore.new();cold_store.path=live_path
	var before_finalize=file_set(txn_target);var live_before_finalize=file_set(live_path)
	Txn.test_failures=["finalize"]
	check(not Txn.replace(live_path,replacement),"injected finalize failure rejects SAVE2 replacement")
	check(FileAccess.file_exists(manager.directory+"/transaction") and file_set(txn_target)==before_finalize,"finalize failure restores suffixes and retains journal")
	check(cold_store.load_game()==first and file_set(txn_target)==before_finalize,"fresh Store finalizes rollback journal without changing restored suffix bytes")
	check(not FileAccess.file_exists(manager.directory+"/transaction") and file_set(live_path)==live_before_finalize,"cold finalize clears journal and preserves live archive")
	clean_stages(txn_target)
	# A rollback failure leaves a journal and partial target. Fresh ordinary Store
	# access must cold-recover before reading or writing the pinned live archive.
	var txn_before=file_set(txn_target);var live_before_recovery=file_set(live_path)
	Txn.test_failures=["commit_1","rollback"]
	check(not Txn.replace(live_path,replacement),"injected commit plus rollback failure leaves recoverable journal")
	check(FileAccess.file_exists(manager.directory+"/transaction"),"failed rollback retains its journal for cold recovery")
	check(cold_store.load_game()==first,"fresh SaveStore load cold-recovers before reading the live archive")
	check(file_set(txn_target)==txn_before and not FileAccess.file_exists(manager.directory+"/transaction"),"cold recovery restores all sidecar suffix bytes and clears journal")
	check(file_set(live_path)==live_before_recovery,"cold recovery leaves live archive bytes unchanged")
	clean_stages(txn_target)
	# Profile mutations share the pinned live archive path with SAVE2. A pending
	# rollback must be recovered before profile snapshots, exports or replacements
	# can observe and preserve a partially committed archive.
	var Profiles=load("res://src/persistence/profiles/profile_store.gd")
	var race_root="user://save2-profile-race"
	var race_live=race_root+"/slot1.save"
	var race_other=race_root+"/slot2.save"
	var race_profiles=Profiles.new();race_profiles.directory=race_root;race_profiles.legacy=race_root+"/missing-legacy.save"
	remove_tree(race_root);clean(race_live);clean(race_other)
	check(race_profiles.open(),"custom profile store opens under a scoped user path")
	var race_original=archive(1,0);race_original.marker.revision=41
	var race_replacement=archive(2,1);race_replacement.marker.revision=82
	var encoded_original=encoded_payload(var_to_bytes(race_original))
	var encoded_replacement=encoded_payload(var_to_bytes(race_replacement))
	var profile_files={"":encoded_original,".bak":null,".challenges":null,".challenges.bak":null}
	check(race_profiles.replace(0,profile_files,true),"seed profile slot with a valid original live archive")
	profile_files[""]=encoded_replacement
	check(race_profiles.replace(1,profile_files,true),"seed second profile with a valid replacement archive")
	var race_store=SaveStore.new();race_store.path=race_live
	var race_original_bytes=FileAccess.get_file_as_bytes(race_live)
	var race_txn={race_live:encoded_replacement}
	Txn.test_failures=["commit_1","rollback"]
	check(not Txn.replace(race_live,race_txn),"profile race fixture leaves a pending live rollback journal")
	var race_journal=race_live+".save2/transaction"
	check(FileAccess.file_exists(race_journal),"profile race fixture retains pending journal")
	var partial_live=FileAccess.get_file_as_bytes(race_live)
	check(partial_live==encoded_replacement and partial_live!=race_original_bytes,"pending fixture exposes the injected partial replacement before recovery")
	# Persistent rollback failure blocks every reader/mutator before it can turn
	# partial data into a healthy profile snapshot or package.
	Txn.test_failures=["rollback"]
	check(race_profiles.snapshot(0).is_empty(),"profile snapshot is blocked while SAVE2 rollback cannot recover")
	Txn.test_failures=["rollback"]
	check(race_profiles.export_profile(0).is_empty(),"profile export is blocked while SAVE2 rollback cannot recover")
	var before_blocked_copy=file_set(race_live)
	Txn.test_failures=["rollback"]
	check(not race_profiles.copy(1,0,true),"profile copy is blocked while SAVE2 rollback cannot recover")
	check(file_set(race_live)==before_blocked_copy,"blocked copy preserves pending live bytes")
	Txn.test_failures=["rollback"]
	check(race_profiles.snapshot(0).is_empty(),"repeated blocked snapshot does not expose pending bytes")
	Txn.test_failures=["rollback"]
	check(race_profiles.export_profile(0).is_empty(),"repeated blocked export does not expose pending bytes")
	Txn.test_failures=["rollback"]
	check(not race_profiles.clear(0,true),"profile clear is blocked while SAVE2 rollback cannot recover")
	check(FileAccess.get_file_as_bytes(race_live)==partial_live,"blocked clear leaves pending bytes untouched")
	# Once recovery is permitted, clear must first restore the original snapshot,
	# then commit the clear. A later cold Store load must not resurrect it.
	Txn.test_failures=[]
	check(race_profiles.clear(0,true),"profile clear recovers first, then commits its confirmed change")
	check(race_profiles.snapshot(0)[""]==null,"recovered clear leaves the profile slot empty")
	var race_cold=SaveStore.new();race_cold.path=race_live
	check(race_cold.load_game().is_empty(),"cold Store load does not resurrect a profile cleared after recovery")
	check(not FileAccess.file_exists(race_journal),"successful profile clear leaves no pending SAVE2 journal")
	# Public package import and copy also recover first and remain committed after
	# the next ordinary cold Store open.
	var import_source=race_profiles.export_profile(1)
	check(not import_source.is_empty(),"replacement import source exports from the second profile")
	var imported_files=race_profiles.read_package(import_source)
	check(not imported_files.is_empty(),"existing profile package is readable before replacement race")
	Txn.test_failures=["commit_1","rollback"]
	check(not Txn.replace(race_live,race_txn),"replacement-import fixture leaves a pending live rollback journal")
	Txn.test_failures=[]
	check(race_profiles.replace(0,imported_files,true),"confirmed profile import replacement recovers before mutation")
	var imported_cold=SaveStore.new();imported_cold.path=race_live
	check(same_archive(imported_cold.load_game(),race_replacement),"cold Store load keeps the confirmed imported profile replacement")
	Txn.test_failures=["commit_1","rollback"]
	check(not Txn.replace(race_live,race_txn),"copy fixture leaves a pending live rollback journal")
	Txn.test_failures=[]
	check(race_profiles.copy(1,0,true),"confirmed profile copy recovers before mutation")
	var copied_cold=SaveStore.new();copied_cold.path=race_live
	check(same_archive(copied_cold.load_game(),race_replacement),"cold Store load keeps the confirmed profile copy")
	remove_tree(race_root);remove_tree(race_live+".save2");remove_tree(race_other+".save2")
	# A failed oversized-file quarantine remains recoverable. The transaction
	# journal's retained descriptor is constrained to the profile-local
	# allowlist, and cold recovery restores the exact originals by rename.
	var quarantine_paths=[oversized_path,oversized_path+".bak",oversized_path+".tmp"]
	check(filled_file(quarantine_paths[0],4000001,0x39),"quarantine rollback fixture has an oversized primary")
	var quarantine_backup=PackedByteArray([0x31,0x32,0x33,0x34]);var quarantine_tmp=PackedByteArray([0x51,0x52])
	check(write_bytes(quarantine_paths[1],quarantine_backup) and write_bytes(quarantine_paths[2],quarantine_tmp),"quarantine rollback fixture has backup and tmp originals")
	var quarantine_sizes=[file_size(quarantine_paths[0]),file_size(quarantine_paths[1]),file_size(quarantine_paths[2])]
	var quarantine_hashes=[file_hash(quarantine_paths[0]),file_hash(quarantine_paths[1]),file_hash(quarantine_paths[2])]
	var quarantine_times=[FileAccess.get_modified_time(quarantine_paths[0]),FileAccess.get_modified_time(quarantine_paths[1]),FileAccess.get_modified_time(quarantine_paths[2])]
	Txn.test_failures=["quarantine_1","rollback"]
	check(not Txn.quarantine(live_path,quarantine_paths),"injected quarantine plus rollback failure leaves a pending retention journal")
	check(FileAccess.file_exists(manager.directory+"/transaction"),"failed retention rollback keeps its journal")
	check(cold_store.load_game()==first,"fresh Store cold-recovers interrupted oversized quarantine before loading")
	for index in 3:
		check(FileAccess.file_exists(quarantine_paths[index]) and file_size(quarantine_paths[index])==quarantine_sizes[index] and file_hash(quarantine_paths[index])==quarantine_hashes[index],"cold retention recovery restores original suffix bytes "+str(index))
		check(FileAccess.get_modified_time(quarantine_paths[index])==quarantine_times[index],"cold retention recovery preserves original suffix timestamp "+str(index))
	check(not FileAccess.file_exists(manager.directory+"/transaction"),"cold retention recovery clears its journal")
	var live_before_bad_retained=file_set(live_path)
	var unauthorized_retained=manager.directory+"/retained/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee/0"
	var bad_retained_journal=encoded_journal(live_path,{live_path+".outside":{"retained":unauthorized_retained,"bytes":quarantine_sizes[0]}})
	check(write_bytes(manager.directory+"/transaction",bad_retained_journal),"write checksummed journal with retained path outside the transaction allowlist")
	check(cold_store.load_game().is_empty(),"unauthorized retained descriptor blocks a cold Store read")
	check(FileAccess.get_file_as_bytes(manager.directory+"/transaction")==bad_retained_journal and file_set(live_path)==live_before_bad_retained,"blocked retained descriptor preserves journal and live bytes")
	DirAccess.remove_absolute(manager.directory+"/transaction")
	for path in quarantine_paths:DirAccess.remove_absolute(path)
	# A validly checksummed journal pointing outside this manager's allowlist
	# blocks Store reads and writes without mutating the live archive or journal.
	var journal_path=manager.directory+"/transaction"
	var bad_journal=encoded_journal(live_path,{live_path+".outside":null})
	check(write_bytes(journal_path,bad_journal),"write checksummed journal with unauthorized path")
	var live_before_block=file_set(live_path);var journal_before_block=FileAccess.get_file_as_bytes(journal_path)
	check(cold_store.load_game().is_empty(),"bad-path journal blocks ordinary Store read")
	check(not cold_store.save(first),"bad-path journal blocks ordinary Store write")
	check(file_set(live_path)==live_before_block and FileAccess.get_file_as_bytes(journal_path)==journal_before_block,"blocked Store access preserves live archive and corrupt journal bytes")
	DirAccess.remove_absolute(journal_path);clean_stages(txn_target);clean(txn_target)
	# Pending candidates remain separate snapshots and carry their run/launch IDs.
	var pending_run="cccccccccccccccccccccccccccccccc";var pending_launch="dddddddddddddddddddddddddddddddd"
	var pending_archive=between.duplicate(true);pending_archive.save2_state.run_id=pending_run;pending_archive.save2_state.launch_id=pending_launch
	check(manager.save_pending(pending_archive,6,pending_run,pending_launch),"pending candidate stores a valid between-dive archive and target")
	var pending=manager.inspect("pending",0)
	check(pending.status=="ready" and pending.data==pending_archive,"pending inspect roundtrips the complete archive")
	check(pending.record.event=="6" and pending.record.run_id==pending_run and pending.record.launch_id==pending_launch,"pending metadata binds the intended operation to its run and launch IDs")
	var same_live_before=FileAccess.get_file_as_bytes(live_path)
	check(manager.load_entry("pending",0,live,true,pending.token),"pending entry loads with matching pinned profile and token")
	check(live.load_game()==pending_archive,"pending load restores the exact valid between-dive state")
	var other_live_before_pending=FileAccess.get_file_as_bytes(other_live_path)
	check(not manager.load_entry("pending",0,other_live,true,pending.token),"pending load rejects a different live profile path")
	check(FileAccess.get_file_as_bytes(other_live_path)==other_live_before_pending,"cross-profile pending rejection leaves other live archive unchanged")
	check(FileAccess.get_file_as_bytes(live_path)!=same_live_before,"same-profile pending load replaces the live archive")
	# Four fork states are distinct from the three manual slots. Identical
	# event/payload snapshots are idempotent; the fifth event rotates FIFO.
	var forks=manager.list_entries("fork")
	check(forks.size()==4,"fork-state list has exactly four stable entries")
	var fork_data=archive(2,2)
	manager.clock=func():return 300
	check(manager.save_fork("fork_a",fork_data,"Fork A"),"first fork state is saved")
	check(manager.save_fork("fork_a",fork_data,"Fork A"),"same event and payload are safely deduplicated")
	check(ready_count(manager,"fork",4)==1,"deduplicated event occupies one fork entry")
	manager.clock=func():return 200
	for event in ["fork_b","fork_c","fork_d"]:check(manager.save_fork(event,fork_data,event),"save distinct fork state "+event)
	check(ready_count(manager,"fork",4)==4 and find_event(manager,"fork_a")>=0,"four distinct fork events occupy the bounded list")
	var oldest_index=find_event(manager,"fork_a")
	var oldest_record=manager.inspect("fork",oldest_index).record
	manager.clock=func():return 100
	check(manager.save_fork("fork_e",fork_data,"Fork E"),"fifth distinct fork state is saved")
	check(ready_count(manager,"fork",4)==4 and find_event(manager,"fork_e")>=0,"fifth fork keeps the list at four and includes the newest event")
	check(find_event(manager,"fork_a")==-1,"fifth fork replaces the first inserted state, independent of timestamp")
	var new_index=find_event(manager,"fork_e");var new_record=manager.inspect("fork",new_index).record
	check(new_record.timestamp<oldest_record.timestamp and int(new_record.get("sequence",0))>int(oldest_record.get("sequence",0)),"fork rotation follows sequence despite decreasing clock")
	# An unreadable fork remains byte-for-byte in place when the fifth entry is
	# saved; the oldest readable entry is evicted. With all four unreadable,
	# rotation refuses to destroy any of them.
	var event_b=find_event(manager,"fork_b");var corrupt_fork=manager.entry_path("fork",event_b)
	var fork_corrupt_bytes=PackedByteArray([0x61,0x62,0x63,0x00])
	check(write_bytes(corrupt_fork,fork_corrupt_bytes),"corrupt one occupied fork primary")
	check(manager.save_fork("fork_f",fork_data,"Fork F"),"new fork rotates an oldest readable entry beside unreadable one")
	check(FileAccess.get_file_as_bytes(corrupt_fork)==fork_corrupt_bytes and manager.inspect("fork",event_b).status=="unreadable","fifth fork preserves unreadable older state bytes")
	check(find_event(manager,"fork_c")==-1 and find_event(manager,"fork_f")>=0,"fifth fork evicts oldest readable state only")
	var all_corrupt_paths=[];var all_corrupt_sets=[]
	for index in 4:
		var path=manager.entry_path("fork",index);var bytes=PackedByteArray([0x70+index,0x71+index,0x72+index])
		check(write_bytes(path,bytes),"corrupt occupied fork entry "+str(index));all_corrupt_paths.append(path);all_corrupt_sets.append(file_set(path))
	check(not manager.save_fork("fork_g",fork_data,"Fork G"),"all-unreadable fork list refuses destructive rotation")
	for index in 4:check(file_set(all_corrupt_paths[index])==all_corrupt_sets[index],"all-unreadable rotation preserves every suffix "+str(index))
	# Delete-all touches only this profile's SAVE2 sidecars, never either live file.
	var live_a_before=FileAccess.get_file_as_bytes(live_path);var live_b_before=FileAccess.get_file_as_bytes(other_live_path)
	check(not manager.delete_all(false),"delete-all requires explicit confirmation")
	check(manager.delete_all(true),"confirmed delete-all removes this profile's SAVE2 entries")
	check(ready_count(manager,"manual",3)==0 and ready_count(manager,"fork",4)==0,"confirmed delete-all clears manual slots and fork states")
	check(other.inspect("manual",0).status=="ready","delete-all leaves another pinned profile's sidecars intact")
	check(FileAccess.get_file_as_bytes(live_path)==live_a_before and FileAccess.get_file_as_bytes(other_live_path)==live_b_before,"delete-all leaves both live autosaves byte-identical")
	for i in range(3):clean(manager.entry_path("manual",i))
	for i in range(4):clean(manager.entry_path("fork",i))
	for i in range(3):clean(other.entry_path("manual",i))
	remove_tree(manager.directory);remove_tree(other.directory)
	clean(live_path);clean(other_live_path)
	print("SAVE2 STORAGE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
