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
	# An active dive is never a manual checkpoint, even when its archive passes
	# the existing serializer's structural validator.
	var active_archive=archive(1);var sim=preload("res://src/simulation/simulation.gd").new();sim.start(0);active_archive.active=sim.snapshot()
	check(SaveStore.new().valid(active_archive),"active-dive fixture remains a valid existing campaign archive")
	check(not manager.save_manual(0,active_archive,"Mid-dive"),"manual save rejects an active dive")
	# A different pinned live path owns independent entries.
	var other=Save2.new(other_live_path);var other_live=SaveStore.new();other_live.path=other_live_path
	check(other_live.save(second),"second profile live archive is written")
	check(other.save_manual(0,second,"Profile B"),"second profile creates its own slot")
	check(manager.inspect("manual",0).status=="empty" and other.inspect("manual",0).data==second,"sidecar slot contents are isolated by pinned live profile path")
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
	# Four fork states are distinct from the three manual slots. Identical
	# event/payload snapshots are idempotent; the fifth event rotates FIFO.
	var forks=manager.list_entries("fork")
	check(forks.size()==4,"fork-state list has exactly four stable entries")
	var fork_data=archive(2,2)
	check(manager.save_fork("fork_a",fork_data,"Fork A"),"first fork state is saved")
	check(manager.save_fork("fork_a",fork_data,"Fork A"),"same event and payload are safely deduplicated")
	check(ready_count(manager,"fork",4)==1,"deduplicated event occupies one fork entry")
	for event in ["fork_b","fork_c","fork_d"]:check(manager.save_fork(event,fork_data,event),"save distinct fork state "+event)
	check(ready_count(manager,"fork",4)==4 and find_event(manager,"fork_a")>=0,"four distinct fork events occupy the bounded list")
	var oldest_index=find_event(manager,"fork_a")
	var oldest_record=manager.inspect("fork",oldest_index).record
	check(manager.save_fork("fork_e",fork_data,"Fork E"),"fifth distinct fork state is saved")
	check(ready_count(manager,"fork",4)==4 and find_event(manager,"fork_e")>=0,"fifth fork keeps the list at four and includes the newest event")
	check(find_event(manager,"fork_a")==-1,"fifth fork replaces the first inserted state, independent of timestamp")
	var new_index=find_event(manager,"fork_e");var new_record=manager.inspect("fork",new_index).record
	check(int(new_record.get("sequence",0))>int(oldest_record.get("sequence",0)),"fork rotation follows monotonic sequence rather than wall-clock time")
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
	clean(live_path);clean(other_live_path)
	print("SAVE2 STORAGE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
