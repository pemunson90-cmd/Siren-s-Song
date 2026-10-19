extends SceneTree
func _initialize():
 var f=FileAccess.open("/workspace/Siren-s-Song-environment-investigation/work/furnace-earned.snapshot",FileAccess.READ);var data=f.get_var();f.close()
 data.mission["thermal_revision"]=1;data.mission["thermal_fronts"]=preload("res://src/simulation/thermal_front.gd").foundry()
 f=FileAccess.open("/workspace/Siren-s-Song-environment-investigation/work/furnace-qualified.snapshot",FileAccess.WRITE);f.store_var(data);f.close();print("COMMON SNAPSHOT ",var_to_bytes(data).hex_encode().sha256_text());quit()
