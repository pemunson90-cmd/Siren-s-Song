extends SceneTree
# WP-113: every place that says UNUSABLE says why, the SHUTTER forecast says so before the tap, and a subject
# already filed says what a new frame can add. Words live in shutter_table.gd; rules are untouched.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const ForecastRule=preload("res://src/photo_grade/frame_forecast.gd")
const Reason=preload("res://src/photo_grade/unusable_reason.gd")
const Review=preload("res://src/presentation/flow/photo_review.gd")
const PhotoView=preload("res://src/presentation/photo_view.gd")
const Table=preload("res://src/presentation/photo_shutter/shutter_table.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func run(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
func fresh(id:int):
	var s=Sim.new();s.start(id,"endurance");s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	return s
func put(s,uid:int,pos:Vector2,angle:float=0.0):
	s.units[uid].pos=pos;s.units[uid].angle=angle;s.units[uid].vel=Vector2.ZERO
func _initialize():
	var spire=Vector2(1300,300);var facing=2.74
	# 1 / Reason helper, one case per row reason.
	var rows:=[{"id":"a","label":"SENSOR ARRAY","ready":false,"why":"CROPPED"},{"id":"b","label":"HULL","ready":false,"why":"HIDDEN"}]
	check(Reason.reason(rows,["a"],[],"wide","")=="SENSOR ARRAY: out of frame","a cropped required detail says out of frame")
	check(Reason.reason(rows,["b"],[],"wide","")=="HULL: hidden from this side","a hidden required detail says hidden from this side")
	check(Reason.reason([{"id":"a","label":"X","ready":false,"why":"TOO SOFT · move closer"}],["a"],[],"wide","")=="X: too soft","a soft detail says too soft")
	check(Reason.reason([{"id":"a","label":"X","ready":true,"why":""}],["a"],[],"wide","")=="X: not held long enough","a detail that resolves now but was not held says so")
	check(Reason.reason(rows,["a"],["a"],"wide","")==Table.TEXT.why.NONE,"nothing missing falls back to nothing resolved")
	check(Reason.reason(rows,["a"],[],"tight","b")=="HULL: hidden from this side","a TIGHT frame names the focused detail")
	# 2 / An unusable frame keeps its reason, and the forecast names it before the tap.
	var s=fresh(0);put(s,0,spire+Vector2.from_angle(facing)*110,facing+PI)
	var o:Dictionary=s.mission.objectives[0]
	var forecast_before:Dictionary={}
	# The rear view hides the front detail: require the detail this side cannot show.
	o.subject["required"]=["scoring"]
	forecast_before=ForecastRule.forecast(Photo.frame(s,0,o),o)
	check(not forecast_before.usable and not str(forecast_before.why).is_empty(),"the forecast of an unusable frame carries a reason")
	check(str(forecast_before.why).contains("hidden from this side"),"the forecast says the detail is hidden from this side")
	s.command("camera");run(s,7.0)
	var shot:Dictionary=s.mission.photo.shots.back()
	check(not shot.usable,"setup: the frame is unusable")
	check(str(shot.get("why",""))==str(forecast_before.why),"the filed unusable frame keeps the reason the forecast gave")
	check(s.message.contains(str(shot.why)),"the dive message names the reason")
	var panel_line:String=Table.TEXT.unusable_filed%str(shot.why)
	check(panel_line.begins_with("UNUSABLE · NOT FILED · ") and panel_line.length()>"UNUSABLE · NOT FILED · ".length(),"the camera panel line says why")
	var report:String=Review.shot_report(null,shot,0,1)
	check(report.contains("UNUSABLE · ") and report.contains(str(shot.why)),"the gallery review line says why")
	check(str(PhotoView.from_shot(shot).get("why",""))==str(shot.why),"the photo scene model carries the reason")
	var old:Dictionary=shot.duplicate(true);old.erase("why")
	check(Review.shot_report(null,old,0,1).contains(Table.TEXT.unusable_old),"a frame filed before reasons were kept still says something")
	check(not o.captured and ForecastRule.filed_note(o).is_empty(),"an unusable frame files nothing, so no filed note")
	# 3 / A filed subject says so before a second frame, and the rule it states holds.
	var t=fresh(0);put(t,0,spire+Vector2.from_angle(facing)*110,facing+PI)
	var tt:Dictionary=t.mission.objectives[0]
	check(ForecastRule.filed_note(tt).is_empty(),"an unfiled subject has no filed note")
	t.command("camera");run(t,7.0)
	check(tt.captured and not str(ForecastRule.filed_note(tt)).is_empty(),"setup: first frame filed")
	var record:float=float(tt.photo_quality)
	var note:String=ForecastRule.filed_note(tt)
	check(note=="FILED %d%% · a new frame only helps if it is sharper or shows a new detail"%roundi(record*100.0),"the note gives the filed percentage and the rule")
	t.command("camera");run(t,7.0)
	check(is_equal_approx(float(tt.photo_quality),record),"an equal second frame leaves the filed record as it was (the rule the note states)")
	print("UNUSABLE REASON CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
