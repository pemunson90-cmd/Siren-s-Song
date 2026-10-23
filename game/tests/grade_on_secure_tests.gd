extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Grade=preload("res://src/photo_grade/grade_on_secure.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
	check(Grade.letter(.9)=="A" and Grade.letter(.7)=="B" and Grade.letter(.3)=="C","letters follow the debrief thresholds")
	check(Grade.note({})=="","a record without a frame adds nothing")
	check(Grade.note({"photo_quality":.62})==" · frame 62% grade B","note shows percent and letter")
	var s=Sim.new();s.start(1,"endurance")
	var rec=s.mission.objectives[0]
	rec["photo_quality"]=.33
	s._record_secured(rec,0)
	check(s.message.contains("Record secured") and s.message.contains("frame 33% grade C"),"secured message carries the frame grade")
	var s2=Sim.new();s2.start(1,"endurance")
	var r2=s2.mission.objectives[0]
	s2._record_secured(r2,0)
	check(not s2.message.contains("grade"),"no grade text when no frame was taken")
	Grade.enabled=false
	var s3=Sim.new();s3.start(1,"endurance");var r3=s3.mission.objectives[0];r3["photo_quality"]=.9
	s3._record_secured(r3,0)
	check(not s3.message.contains("grade"),"switch off restores the old message exactly")
	print("GRADE ON SECURE CHECKS %d FAILURES %d"%[checks,failures])
	quit(1 if failures>0 else 0)
