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
	check(Grade.note({"photo_quality":.62})==" · 62% B","note shows percent and letter")
	var s=Sim.new();s.start(1,"endurance")
	var rec=s.mission.objectives[0]
	rec["photo_quality"]=.33
	s._record_secured(rec,0)
	check(s.message.contains("Record secured") and s.message.contains(" · 33% C"),"secured message carries the frame grade")
	var s2=Sim.new();s2.start(1,"endurance")
	var r2=s2.mission.objectives[0]
	s2._record_secured(r2,0)
	check(not s2.message.contains("grade"),"no grade text when no frame was taken")
	# A B or C frame names what raises it and what that changes; an A frame adds no advice.
	var advice=Grade.note({"photo_quality":.33},"closer, lit or still")
	check(advice==" · 33% C · better: closer, lit or still" and not advice.contains("intel kept"),"a C frame says what would raise it on a short log line; the panel carries the longer words")
	check(Grade.note({"photo_quality":.7},"closer, lit or still").contains("better:"),"a B frame says what would raise it")
	check(not Grade.note({"photo_quality":.9},"closer, lit or still").contains("better:"),"an A frame adds no advice")
	check(s.message.contains("better: "),"the secured message of a poor frame carries the viewfinder hint")
	var Forecast=preload("res://src/photo_grade/frame_forecast.gd")
	var row={"id":"a","ready":true,"q":0.5,"apparent":true,"why":""}
	var soft={"id":"b","ready":false,"q":0.0,"apparent":true,"why":"TOO SOFT · closer, lit or still"}
	var guess=Forecast.forecast({"mode":"wide","sharp":0.4,"rows":[row,soft]},{"subject":{"required":[]}})
	check(guess.usable and absf(guess.q-(0.4*0.55+0.25*0.45))<0.001 and guess.grade=="C","forecast repeats the one-frame filing formula")
	check(not Forecast.forecast({"mode":"wide","sharp":0.4,"rows":[row,soft]},{"subject":{"required":["b"]}}).usable,"a missing required detail forecasts no usable frame")
	check(Forecast.hint({"rows":[row,soft]})=="closer, lit or still" and Forecast.hint({"rows":[row]})==Forecast.SOFT_HINT,"hint comes from the viewfinder row reason, else the sharpness hint")
	check(Forecast.hint({"rows":[row,soft]},{"hidden":true})==Forecast.HINTS.HIDDEN and Forecast.hint({"rows":[row,soft]},{"light":true})==Forecast.LIGHT_HINT,"the camera panel's advice for the next detail comes first (hidden, then too dark)")
	Grade.enabled=false
	var s3=Sim.new();s3.start(1,"endurance");var r3=s3.mission.objectives[0];r3["photo_quality"]=.9
	s3._record_secured(r3,0)
	check(not s3.message.contains("%"),"switch off restores the old message exactly")
	print("GRADE ON SECURE CHECKS %d FAILURES %d"%[checks,failures])
	quit(1 if failures>0 else 0)
