extends SceneTree
# 121: every Calder record subject and every required photo subject of ops 0 to
# 31 has its own photographed composition and an interpretation, while the photo
# subject data that grading reads, and staged frames' optical numbers, stay
# exactly as they were.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Scene=preload("res://src/presentation/photo_scene.gd")
const Subjects=preload("res://src/presentation/photo_subjects.gd")
const View=preload("res://src/presentation/photo_view.gd")
const IDS=[32,33,34,35,36]
# Required photo subjects of ops 0 to 31 (and the two finale bonus frames), with
# the md5 of the subject dictionary photo_capture grades and the exposure time.
const EARLY={
	"spire":0,"relay_west":1,"relay_east":1,"furnace":3,"cradle":3,"well_pattern":4,"well_aperture":4,"well_return":4,
	"transmitter":5,"departure":5,"final_photo_30":30,"final_photo_31":31,"final_photo_30_bonus":30,"final_photo_31_bonus":31}
# Captions rewritten as short interpretations in 121.
const READ_KEYS=["well_aperture","well_return","final_photo_30","final_photo_31","final_photo_30_bonus","final_photo_31_bonus"]
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
class Canvas extends Control:
	var vms:Array=[]
	var drawn:=0
	func _draw()->void:
		var w:float=size.x/2.0;var h:float=size.y/float(maxi(1,(vms.size()+1)/2))
		for i in vms.size():
			View.draw(self,Rect2(Vector2((i%2)*w,(i/2)*h),Vector2(w,h)),vms[i],1.0,14)
			drawn+=1
func _initialize()->void:
	var looks:={}
	var captions:={}
	var vms:=[]
	for id in IDS:
		var s=Sim.new();s.start(id)
		check(not s.mission.is_empty(),"op %d builds"%id)
		if s.mission.is_empty():continue
		var photos=s.mission.objectives.filter(func(o):return o.has("subject") and o.has("optical"))
		check(photos.size()==2,"op %d keeps one required and one optional record"%id)
		var required=photos.filter(func(o):return not o.get("optional",false))
		check(required.size()==1 and required[0].site_id=="glass_record_%d"%id,"op %d required record key unchanged"%id)
		for o in photos:
			var key:String=o.optical
			var look:String=Scene.look_for({"key":key,"kind":"site"})
			check(Subjects.has(look) and look!="tower","%s has a composed subject, got %s"%[key,look])
			check(not looks.has(look),"%s composition %s is distinct"%[key,look])
			looks[look]=key
			# Grading inputs: the subject data photo_capture scores is untouched.
			var sub:Dictionary=o.subject
			check(is_equal_approx(float(sub.size),100.0) and is_equal_approx(float(sub.glow),0.55) and is_equal_approx(float(sub.facing),PI),"%s subject size, glow and facing unchanged"%key)
			check(sub.required==["mark"] and sub.features.size()==1 and is_equal_approx(float(sub.features[0].detail),0.12) and sub.features[0].arc==PI,"%s feature detail and arc unchanged"%key)
			check(is_equal_approx(float(o.duration),4.0) and o.name==sub.features[0].label,"%s exposure duration and name unchanged"%key)
			# Interpretation: one or two short sentences, distinct, no em dash.
			var text:String=o.evidence
			check(text!=o.name and not text.is_empty() and text.length()<=170 and not String.chr(0x2014) in text and text.count(". ")<=1 and text.ends_with("."),"%s has a short interpretation: %s"%[key,text])
			check(not captions.has(text),"%s interpretation is distinct"%key)
			captions[text]=key
			for q in [0.0,0.5,1.0]:
				vms.append({"cols":range(36).map(func(i):return 70),"fov":1.0,"u":0.0,"dist":80.0,"size":100.0,"aspect":-1.2,"light":0.9,"clarity":0.9,"sharp":0.95 if q>0.0 else 0.4,"marks":[{"id":"mark","x":0.0,"q":q,"label":o.name if q>0.0 else "","art":"count","y":0.4,"find":""}],"kind":"site","key":key,"seed":11,"mode":"wide","flash":false,"craft":"QUIETUS","live":false,"pivot":0.0,"usable":true,"glow":0.55,"depth":0.5,"thermal":false,"develop":1.0})
	check(looks.size()==10,"ten distinct Calder compositions")
	# Ops 0 to 31: every required photo subject is composed, distinct and ungraded-changed.
	var required_early:={}
	for id in [0,1,2,3,4,5]+range(6,32):
		var s=Sim.new();s.start(id)
		if s.mission.is_empty():continue
		for o in s.mission.objectives:
			if o.has("subject") and o.has("optical") and not o.get("optional",false):required_early[o.optical]=id
	for key in required_early:check(EARLY.has(key),"required photo subject %s of op %d is covered"%[key,required_early[key]])
	var early_sum:={}
	for key in EARLY:
		var id:int=EARLY[key]
		var s=Sim.new();s.start(id)
		var hit=s.mission.objectives.filter(func(o):return o.get("optical","")==key and o.has("subject"))
		check(hit.size()==1,"%s is a photo objective of op %d"%[key,id])
		if hit.is_empty():continue
		var o=hit[0]
		if not o.get("optional",false):check(required_early.has(key),"%s listed as required"%key)
		var look:String=Scene.look_for({"key":key,"kind":"site"})
		check(Subjects.has(look) and look!="tower","%s has a composed subject, got %s"%[key,look])
		check(not looks.has(look),"%s composition %s is distinct from %s"%[key,look,looks.get(look,"")])
		looks[look]=key
		var sum:String=(var_to_str(o.subject)+"|"+str(o.get("duration",-1.0))).md5_text()
		early_sum[key]=sum
		check(sum==GRADED.get(key,""),"%s graded subject data and exposure unchanged: %s"%[key,sum])
		var text:String=o.evidence
		check(not text.is_empty() and text!=o.name and not String.chr(0x2014) in text,"%s caption interprets the image"%key)
		if key in READ_KEYS:
			check(text.length()<=170 and text.count(". ")<=1 and text.ends_with("."),"%s has a short interpretation: %s"%[key,text])
		var ids:Array=o.subject.features.map(func(f):return f.id)
		for tier in 3:
			var marks:=[]
			for n in ids.size():
				var q:float=0.0 if tier==0 else (1.0 if tier==2 else (0.6 if n==0 else 0.0))
				marks.append({"id":ids[n],"x":-0.3+0.3*n,"q":q,"label":"","art":"","y":0.4,"find":""})
			vms.append({"cols":range(36).map(func(i):return 70),"fov":1.0,"u":0.0,"dist":80.0,"size":100.0,"aspect":-1.2,"light":0.9,"clarity":0.9,"sharp":0.95 if tier>0 else 0.4,"marks":marks,"kind":"site","key":key,"seed":11,"mode":"wide","flash":false,"craft":"QUIETUS","live":false,"pivot":0.0,"usable":true,"glow":0.55,"depth":0.5,"thermal":false,"develop":1.0})
	print("AUDIT PHOTO EVIDENCE graded ",early_sum)
	check(looks.size()==24,"twenty-four distinct compositions in all, got %d"%looks.size())
	# Each feature's evidence shows only once that feature is resolved.
	var by:=Scene.evidence_by_id({"marks":[{"id":"beacon","q":0.9},{"id":"drill","q":0.0},{"id":"scoring","q":0.4}]},1.0)
	check(by.has("beacon") and not by.has("drill") and is_equal_approx(float(by.scoring),0.4),"evidence is tracked per feature")
	check(Scene.evidence_by_id({"marks":[{"id":"beacon","q":0.3}]},0.5).is_empty(),"a feature waits for the plate to develop")
	# Evidence only shows as the frame resolves it.
	var mk=func(q):return {"marks":[{"q":q}]}
	check(Scene.evidence_level(mk.call(0.0),1.0)==0.0 and is_equal_approx(Scene.evidence_level(mk.call(0.8),1.0),0.8),"resolved quality drives the evidence level")
	check(Scene.evidence_level(mk.call(0.5),0.3)==0.0,"an undeveloped plate does not show the evidence yet")
	# Optical numbers for a staged required frame are identical to the pre-121 build.
	var s=Sim.new();s.start(33)
	var o=s.mission.objectives[0]
	var u=s.units[0]
	u.band=int(o.band);u.vel=Vector2.ZERO
	u.pos=o.pos+Vector2(-60,0);u.angle=u.pos.angle_to_point(o.pos)
	Photo.set_frame(s,0,{"mode":"wide","focus":o.optical})
	var f=Photo.frame(s,0,o,0.0)
	var row=f.rows.filter(func(r):return r.id=="mark")
	print("AUDIT PHOTO EVIDENCE frame light=%.4f clarity=%.4f sharp=%.4f dist=%.2f q=%.4f"%[f.light,f.clarity,f.sharp,f.dist,row[0].q if not row.is_empty() else -1.0])
	check(not row.is_empty() and is_equal_approx(f.dist,60.0),"staged frame sees the record subject")
	check(not row.is_empty() and "%.4f %.4f %.4f %.4f"%[f.light,f.clarity,f.sharp,row[0].q]==BASELINE,"staged frame numbers match the pre-121 build: "+("%.4f %.4f %.4f %.4f"%[f.light,f.clarity,f.sharp,row[0].q] if not row.is_empty() else "none"))
	# A staged early frame (op 4 profile aperture) is also identical to the pre-121 build.
	var s4=Sim.new();s4.start(4)
	var o4=s4.mission.objectives.filter(func(x):return x.get("optical","")=="well_aperture")[0]
	var u4=s4.units[0]
	u4.band=int(o4.get("band",o4.subject.get("band",1)));u4.vel=Vector2.ZERO
	u4.pos=o4.pos+Vector2(-60,0);u4.angle=u4.pos.angle_to_point(o4.pos)
	Photo.set_frame(s4,0,{"mode":"wide","focus":o4.optical})
	var f4=Photo.frame(s4,0,o4,0.0)
	var row4=f4.rows.filter(func(r):return r.id=="face")
	var got4:String="%.4f %.4f %.4f %.4f"%[f4.light,f4.clarity,f4.sharp,row4[0].q if not row4.is_empty() else -1.0]
	print("AUDIT PHOTO EVIDENCE early frame ",got4)
	check(got4==BASELINE_EARLY,"staged early frame numbers match the pre-121 build: "+got4)
	# Draw every composition at unresolved, partial and full evidence.
	var canvas:=Canvas.new();canvas.size=Vector2(1800,9000);canvas.vms=vms
	root.add_child(canvas)
	for n in 3:await process_frame
	check(vms.size()==30+42,"every composition queued at three evidence tiers")
	check(canvas.drawn>=vms.size() or DisplayServer.get_name()=="headless","every composition draws without stopping")
	print("AUDIT PHOTO EVIDENCE drawn ",canvas.drawn)
	print("AUDIT PHOTO EVIDENCE CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
const BASELINE="0.8455 0.9350 0.9643 1.0000"
const BASELINE_EARLY="0.5600 0.9085 0.9497 0.9484"
# Captured on the pre-change source (c2362a71) for each subject: md5 of the
# graded subject dictionary plus exposure duration.
const GRADED={"cradle":"7286d136eb6e451cd55469fdc26df227","departure":"1cb5dbd392894080fa3360eecbd9362f",
	"final_photo_30":"ac8dc379434a986387e3a65c5458afcc","final_photo_30_bonus":"8f56ef90fc2570935f30028bdbce7c4a",
	"final_photo_31":"2849ceb8d4cc946f3e0bb6f4fc1ad790","final_photo_31_bonus":"6f0408450b368e85475acd740b7d0a75",
	"furnace":"a168200e0c2ed6c77d4c41db75778381","relay_east":"369ca74873262bc11ef08cc7cf6e5427",
	"relay_west":"bb59ee9b293641a5ea5a8b6492e013e5","spire":"043e26f4bd35ac7ad7f97e44c6c48a37",
	"transmitter":"9e4d95d40ef69d1039a17d876767945b","well_aperture":"3b0e16affd6033ed7d46e47be9db1164",
	"well_pattern":"132412cbc09da0ffedf43355cff45ac0","well_return":"4b1872e3686faf3f9ab9bd52929d57b9"}
