extends SceneTree
# 121: every Calder record subject has its own photographed composition and a
# short interpretation, while the photo subject data that grading reads, and a
# staged frame's optical numbers, stay exactly as they were.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Scene=preload("res://src/presentation/photo_scene.gd")
const Subjects=preload("res://src/presentation/photo_subjects.gd")
const View=preload("res://src/presentation/photo_view.gd")
const IDS=[32,33,34,35,36]
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
	# Draw every composition at unresolved, partial and full evidence.
	var canvas:=Canvas.new();canvas.size=Vector2(1800,4200);canvas.vms=vms
	root.add_child(canvas)
	for n in 3:await process_frame
	check(canvas.drawn>=vms.size() or DisplayServer.get_name()=="headless","every composition draws without stopping")
	print("AUDIT PHOTO EVIDENCE drawn ",canvas.drawn)
	print("AUDIT PHOTO EVIDENCE CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
const BASELINE="0.8455 0.9350 0.9643 1.0000"
