extends RefCounted
# Draws a photograph from frame data: the real terrain depth profile across the
# field of view, the subject at its true bearing, size, aspect and sharpness,
# and only the features this exposure actually resolved. The same function
# draws the live viewfinder and every stored archive shot.
const PHOSPHOR=Color("8cdcd3")
const AMBER=Color("e0bf83")
const COLS=36
static func valid_shots(shots)->bool:
	if not shots is Array or shots.size()>8:return false
	for shot in shots:
		if not shot is Dictionary or not shot.has_all(["q","features","key","frame"]) or not shot.frame is Dictionary:return false
		if not shot.frame.get("cols") is Array or shot.frame.cols.size()!=COLS or not (shot.q is float or shot.q is int):return false
		if shot.has("findings") and not preload("res://src/simulation/photo_findings.gd").valid_list(shot.findings):return false
	return true
# View model from a live Photo.frame() result.
static func from_frame(f:Dictionary,kind:String="site",key:String="",type:String="")->Dictionary:
	var marks=[]
	for r in f.rows:
		if r.apparent:marks.append({"id":r.id,"x":r.x,"q":r.q if r.ready else 0.0,"label":r.label if r.ready else "","why":r.why,"art":r.get("art",""),"y":r.get("y",0.4),"find":""})
	return {"cols":f.get("cols",[]),"fov":f.fov,"u":clampf(angle_difference(f.aim,f.bearing)/maxf(f.fov*0.5,0.01),-1.6,1.6),"dist":f.dist,"size":f.size,"aspect":f.aspect,"light":f.light,"clarity":f.clarity,"sharp":f.sharp,"marks":marks,"kind":kind,"key":key,"type":type,"seed":int(f.dist)%97,"mode":f.mode,"flash":f.flash,"craft":f.craft,"live":true,"pivot":f.pivot,"glow":f.get("glow",0.0),"depth":f.get("depth",0.5),"thermal":f.get("thermal",false)}
# View model from a stored shot.
static func from_shot(shot:Dictionary)->Dictionary:
	var fr:Dictionary=shot.frame
	return {"cols":fr.cols,"fov":fr.fov,"u":0.0,"dist":fr.dist,"size":fr.size,"aspect":fr.aspect,"light":shot.light,"clarity":shot.clarity,"sharp":shot.sharp,"marks":fr.marks,"kind":fr.get("kind","site"),"key":str(shot.get("key","")),"type":str(shot.get("type","")),"seed":fr.seed,"mode":shot.mode,"flash":shot.flash,"craft":shot.craft,"live":false,"pivot":0.0,"usable":shot.get("usable",true),"glow":fr.get("glow",0.0),"depth":fr.get("depth",0.5),"thermal":fr.get("thermal",false)}
static func draw(ci:CanvasItem,rect:Rect2,vm:Dictionary,time:float,font_size:int=14)->void:
	preload("res://src/presentation/photo_scene.gd").draw(ci,rect,vm,time,font_size)
# A control that shows one stored shot, for the archive viewer.
class Plate extends Control:
	var vm:Dictionary={}
	var title:=""
	var develop_seconds:=1.5
	var age:=0.0
	func _ready()->void:
		clip_contents=true
		if custom_minimum_size.y<=0.0:custom_minimum_size=Vector2(0,170)
	func _process(dt:float)->void:
		age+=dt;queue_redraw()
	func _draw()->void:
		if vm.is_empty():return
		var R=preload("res://src/presentation/photo_view.gd")
		var shown:Dictionary=vm.duplicate()
		shown["develop"]=clampf(age/develop_seconds,0.0,1.0) if develop_seconds>0.0 else 1.0
		R.draw(self,Rect2(Vector2.ZERO,size),shown,age,12)
		draw_rect(Rect2(Vector2.ZERO,size),Color("6b9d9f"),false,1)
		if not title.is_empty():draw_string(ThemeDB.fallback_font,Vector2(8,16),title,HORIZONTAL_ALIGNMENT_LEFT,-1,12,PHOSPHOR)
