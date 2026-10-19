extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Routes=preload("res://tests/campaign_scenarios.gd")
func _initialize():
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.READ);var snapshot=f.get_var();f.close();var s=Sim.new();assert(s.restore(snapshot));print("MATCHED_INITIAL sha=",var_to_bytes(s.snapshot()).hex_encode().sha256_text()," time=",s.elapsed," pos=",s.units[0].pos," angle=",s.units[0].angle," tools=",s.tools)
 var ok=Routes.move(s,s.mission.extraction)
 print("MATCHED_FINAL returned=",ok," won=",s.outcome=="won"," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," pos=",s.units[0].pos," tools=",s.tools," message=",s.message)
 quit()
