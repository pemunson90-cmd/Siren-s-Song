extends SceneTree
# DEPTH-BAND PHOTOS: the band table, the single can_shoot rule, band mods on the
# frame, the shutter ring by band, the deep exposure cost, the optional shot
# band and the Priced Shots rings. Everything the feature adds lives in
# src/photo_depth/; these tests sit beside it.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Table=preload("res://src/photo_depth/band_table.gd")
const BandPhoto=preload("res://src/photo_depth/band_photo.gd")
const BandHint=preload("res://src/photo_depth/band_hint.gd")
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
func put(s,uid:int,pos:Vector2,angle:float=0.0,band:int=1):
	s.units[uid].pos=pos;s.units[uid].angle=angle;s.units[uid].vel=Vector2.ZERO;s.units[uid].band=band;s._use_band(s.units[s.selected].band)
func at(origin:Vector2,angle:float,dist:float)->Vector2:
	return origin+Vector2.from_angle(angle)*dist
func _initialize():
	var spire=Vector2(1300,300);var facing=2.74;var spot=at(spire,facing,110)
	# 1 / The table: MIDDLE is neutral, the other bands are the approved numbers.
	var mid=Table.BANDS[1]
	check(mid.light==1.0 and mid.haze==1.0 and mid.swell==1.0 and mid.ring==1.0 and mid.thermal==1.0 and mid.blur==1.0 and mid.o2==0.0 and mid.battery==0.0,"the MIDDLE row changes nothing")
	check(Table.BANDS.size()==3 and Table.BANDS[0].ring==1.3 and Table.BANDS[2].ring==0.8 and Table.BANDS[2].o2==0.075 and Table.BANDS[2].battery==0.3,"the table holds the approved shutter and cost figures")
	check(is_equal_approx(BandPhoto.ring(fresh(0),0,false),520.0) and is_equal_approx(BandPhoto.ring(fresh(0),0,true),760.0),"MIDDLE keeps the 520 m and 760 m shutter rings")
	# 2 / Shutter ring by band.
	var s=fresh(0);put(s,0,spot,facing+PI,0)
	check(is_equal_approx(BandPhoto.ring(s,0,false),676.0) and is_equal_approx(BandPhoto.ring(s,0,true),988.0),"SHALLOW is heard to 676 m (988 m flashing)")
	put(s,0,spot,facing+PI,2)
	check(is_equal_approx(BandPhoto.ring(s,0,false),416.0) and is_equal_approx(BandPhoto.ring(s,0,true),608.0),"DEEP is heard to 416 m (608 m flashing)")
	# 3 / The frame: haze, slant and light change with the band, MIDDLE does not.
	var o=s.mission.objectives[0]
	put(s,0,spot,facing+PI,1);var fm=Photo.frame(s,0,o,0.0)
	put(s,0,spot,facing+PI,0);var fs=Photo.frame(s,0,o,0.0)
	put(s,0,spot,facing+PI,2);var fd=Photo.frame(s,0,o,0.0)
	check(is_equal_approx(fm.dist,110.0) and is_equal_approx(fs.dist,sqrt(110.0*110.0+1600.0)) and is_equal_approx(fd.dist,fs.dist),"a band between craft and subject adds a 40 m slant")
	check(fd.clarity>fm.clarity or fd.dist>fm.dist,"DEEP water is clearer per metre")
	check(fs.clarity<fm.clarity,"SHALLOW water is hazier")
	check(fm.band==1 and fs.band==0 and fd.band==2,"a frame records the band it was taken from")
	var dim=fresh(0);dim.mission.objectives[0].subject.glow=0.0
	put(dim,0,spot,facing+PI,1);var lm=Photo.frame(dim,0,dim.mission.objectives[0],0.0).light
	put(dim,0,spot,facing+PI,0);var ls=Photo.frame(dim,0,dim.mission.objectives[0],0.0).light
	put(dim,0,spot,facing+PI,2);var ld=Photo.frame(dim,0,dim.mission.objectives[0],0.0).light
	check(ls>lm and lm>ld,"SHALLOW is brighter than MIDDLE and DEEP is darker (unlit subject)")
	# 4 / One can_shoot rule.
	var q=s.units[0]
	var site=s.mission.objectives[0]
	for band in 3:
		q.band=band;q.transition={}
		check(BandPhoto.can_shoot(s,q) and BandPhoto.can_shoot(s,q,site),"the camera works in band %d"%band)
	q.band=2;q.transition={"to":1,"remaining":2.0}
	check(not BandPhoto.can_shoot(s,q) and not BandPhoto.can_shoot(s,q,site),"a craft in transition cannot frame")
	q.transition={};q.band=2
	check(not BandPhoto.can_shoot(s,q,{"name":"SAMPLE","captured":false}),"a non-photographic job stays MIDDLE only")
	q.band=1
	check(BandPhoto.can_shoot(s,q,{"name":"SAMPLE","captured":false}),"a non-photographic job still works in MIDDLE")
	var banded={"name":"SEAM","captured":false,"pos":Vector2(10,10),"subject":{"bands":[2],"band":2,"required":["a"],"features":[{"id":"a","label":"A"}]}}
	q.band=1;var m1=BandPhoto.can_shoot(s,q,banded);q.band=0;var m0=BandPhoto.can_shoot(s,q,banded);q.band=2;var m2=BandPhoto.can_shoot(s,q,banded)
	check(not m1 and not m0 and m2,"a subject that declares DEEP can be framed only from DEEP")
	# 5 / Sirens only from their own band.
	var sr=Sim.new();sr.start(0,"endurance")
	var study={"siren":0,"subject":Photo.siren_subject(sr.sirens[0])}
	sr.sirens[0].band=1;sr.units[0].band=2;sr.units[0].transition={}
	check(not BandPhoto.can_shoot(sr,sr.units[0],study),"a MIDDLE Siren cannot be studied from DEEP")
	sr.units[0].band=0
	check(not BandPhoto.can_shoot(sr,sr.units[0],study),"a MIDDLE Siren cannot be studied from SHALLOW")
	sr.sirens[0].band=2;sr.units[0].band=2
	check(BandPhoto.can_shoot(sr,sr.units[0],study),"a DEEP Siren can be studied from DEEP")
	sr.units[0].band=1;sr.sirens[0].band=1
	check(BandPhoto.can_shoot(sr,sr.units[0],study),"a MIDDLE Siren can be studied from MIDDLE")
	# 6 / The camera in DEEP: ready, a quiet ring, an oxygen charge, a recorded band.
	var d=fresh(0);put(d,0,spot,facing+PI,2)
	var ctx=d.camera_context()
	check(ctx.ready and ctx.text.contains("DEEP:") and ctx.text.contains("heard 416m") and ctx.text.contains("oxygen"),"the DEEP camera line states light, haze, shutter ring and oxygen cost")
	var m=fresh(0);put(m,0,spot,facing+PI,1)
	check(not m.camera_context().text.contains("heard 416m") and m.camera_context().ready,"MIDDLE camera text is unchanged by the band line")
	var o2d=d.oxygen;var o2m=m.oxygen
	check(d.command("camera"),"the camera order is accepted in DEEP")
	check(d.noises.size()>0 and is_equal_approx(float(d.noises.back().radius),416.0) and d.noises.back().band==2,"the DEEP shutter is a 416 m ring in band 2")
	m.command("camera")
	check(is_equal_approx(float(m.noises.back().radius),520.0),"the MIDDLE shutter is still a 520 m ring")
	run(d,6);run(m,6)
	check(d.mission.objectives[0].captured and m.mission.objectives[0].captured,"the spire is photographed from DEEP and from MIDDLE")
	var spent_d=o2d-d.oxygen;var spent_m=o2m-m.oxygen
	check(spent_d>spent_m+0.025*6.0+0.075*3.0 and spent_d<spent_m+0.1*6.0+0.05,"a DEEP exposure draws the pump cost plus 0.075 oxygen a second (%.3f vs %.3f)"%[spent_d,spent_m])
	check(Photo.peek(d).shots.size()==1 and Photo.peek(d).shots[0].band==2 and Photo.peek(m).shots[0].band==1,"each shot records its band")
	# 7 / SHALLOW works too, louder.
	var sh=fresh(0);put(sh,0,spot,facing+PI,0)
	sh.command("camera")
	check(is_equal_approx(float(sh.noises.back().radius),676.0),"the SHALLOW shutter is a 676 m ring")
	# 8 / A drone pays in battery, not oxygen.
	var dr=fresh(0);dr.units[1].alive=true;dr.units[1].band=2;dr.units[1].battery=50.0
	dr.captures[1]={"target":0,"elapsed":0.0}
	var ox=dr.oxygen;BandPhoto.deep_cost(dr,2.0)
	check(is_equal_approx(dr.units[1].battery,50.0-0.6) and is_equal_approx(dr.oxygen,ox),"a DEEP drone exposure drains 0.3 battery a second and no oxygen")
	var idle=fresh(0);idle.units[0].band=2;var ox2=idle.oxygen;BandPhoto.deep_cost(idle,2.0)
	check(is_equal_approx(idle.oxygen,ox2),"no exposure, no extra deep cost")
	# 9 / A subject that needs another band says so and refuses MIDDLE.
	var b=fresh(0);b.mission.objectives[0].subject["bands"]=[2];put(b,0,spot,facing+PI,1)
	var bc=b.camera_context()
	check(not bc.ready,"a DEEP-only subject is not ready from MIDDLE")
	check(bc.text.contains("seen only from DEEP"),"and the text says which band to use")
	put(b,0,spot,facing+PI,2)
	check(b.camera_context().ready,"the same subject is ready from DEEP")
	# 10 / Depth hint offers the band price near an unrecorded subject.
	var h=fresh(0);put(h,0,spot,facing+PI,2)
	check(h.Depth.context(h).contains("CAMERA works"),"the depth reminder names the camera and the band price")
	# 11 / Hidden phenomena can be sighted from any photographic band.
	var hid=fresh(17);hid.mission.photo_hidden[0].found=false
	var hp:Vector2=hid.mission.photo_hidden[0].pos
	put(hid,0,hp+Vector2(-100,0),0.0,2)
	Photo.discover(hid)
	check(hid.mission.photo_hidden[0].found,"a hidden phenomenon is sighted from DEEP")
	# 12 / Priced Shots reads the band's ring.
	var pr=fresh(0);put(pr,0,spot,facing+PI,2)
	var read=Pricing.readout(pr,0,pr.mission.objectives[0])
	check(is_equal_approx(float(read.heard),416.0) and read.lines.any(func(l):return str(l.text).contains("DEEP:")),"the Priced Shots strip shows the DEEP ring and band line")
	put(pr,0,spot,facing+PI,0)
	read=Pricing.readout(pr,0,pr.mission.objectives[0])
	check(is_equal_approx(float(read.heard),676.0),"and the SHALLOW ring (cache keyed by band)")
	# 13 / A Siren in the next band hears a DEEP shutter only through transmission.
	var hr=fresh(0);put(hr,0,spot,facing+PI,2)
	hr.contacts[0]={"pos":spot+Vector2(150,0),"time":hr.elapsed,"band":1,"type":"patroller","mode":"PATROL"}
	var near=Pricing.readout(hr,0,hr.mission.objectives[0]).lines.back().text
	hr.contacts[0].pos=spot+Vector2(300,0)
	Pricing._cache.clear()
	var far=Pricing.readout(hr,0,hr.mission.objectives[0]).lines.back().text
	check(str(near).contains("~") and not str(far).contains("~"),"a MIDDLE Siren hears the DEEP shutter inside 175 m and not at 300 m (%s | %s)"%[near,far])
	# 14 / Saves: the shot band is optional and validated.
	var snap=d.snapshot()
	var back=Sim.new();back.start(0,"endurance")
	check(back.restore(snap) and Photo.peek(back).shots[0].band==2,"a saved DEEP shot restores with its band")
	var plain=d.snapshot();plain.mission.photo.shots[0].erase("band")
	var again=Sim.new();again.start(0,"endurance")
	check(again.restore(plain),"a save without the band field still loads")
	var bad=d.snapshot();bad.mission.photo.shots[0].band=7
	var refused=Sim.new();refused.start(0,"endurance")
	check(not refused.restore(bad),"a band outside 0 to 2 is refused")
	# 15 / The required exposure of operations 0 and 3 can be taken from every band.
	for op in [0,3]:
		for band in 3:
			var g=fresh(op);var target=g.mission.objectives[0];var face=float(target.subject.facing)
			put(g,0,target.pos+Vector2.from_angle(face)*100.0,face+PI,band)
			g.command("camera");run(g,8)
			check(target.captured,"operation %d: the required frame is taken from band %d"%[op,band])
	print("PHOTO DEPTH CHECKS ",checks," FAILURES ",failures)
	quit()
