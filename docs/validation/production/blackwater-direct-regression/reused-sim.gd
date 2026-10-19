extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
func _initialize():
 var s=preload("res://tests/finale_command_plan.gd").play(false,"warning",true)
 print("HUNT previous_mission=",s.mission.id," previous_elapsed=",s.elapsed," all_records=",s.all_records()," capture_target=",s.capture_target," capture_unit=",s.capture_unit)
 s.start(2)
 var archive={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"active":s.snapshot()}
 var store=Store.new();store.path="user://reused-mission.save"
 print("HUNT new_mission=",s.mission.id," revision=",s.mission.get("blackwater_revision",0)," capture_target=",s.capture_target," capture_unit=",s.capture_unit," snapshot_valid=",Sim.valid_snapshot(s.snapshot())," archive_valid=",store.valid(archive)," actual_archive_save=",store.save(archive)," warning=",store.warning)
 quit()
