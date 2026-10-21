extends SceneTree
func _initialize():
 var s=load("res://src/simulation/simulation.gd").new();s.start(22);var d=s.snapshot()
 for key in ["Depth","Sonar","ModuleRecovery","DroneOperations","Glass","Network","ContactReports","WorldRegion","Witness","Concealed","Recipient","Delivery","Shelf","Wake","Chain"]:print(key," ",s[key].valid(d))
 print("consequences ",s.Consequences.valid_mission(d.mission,0.)," recovered ",d.mission.recovered," outcome ",s.outcome," corridors ",d.mission.corridors)
 quit()
