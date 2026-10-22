extends RefCounted
# Authored photographic subjects for operations, kept as data so new operations
# add reconnaissance by adding rows here. apply() runs once from the catalog
# after an operation is built:
#   subjects  attached to existing photo objectives (by index)
#   extra     optional objectives added to an operation (long observations)
#   hidden    phenomena that are not charted: they become objectives only after
#             a craft's own camera sights them (see photo_capture.discover)
# Story text here is short placeholder text.
const LABELS={
	"spire_wreck":"CORRAN SPIRE / DRILL STRING","spire_scoring":"CORRAN SPIRE / SCORED PLATING","relay_clock":"SPLIT CHANNEL / TRANSPONDER CLOCK",
	"foundry_lining":"COLD FOUNDRY / VENT LINING","cradle_frames":"COLD FOUNDRY / OPEN FRAMES","base_cycle":"SIREN BASE / HATCH CYCLE",
	"well_array":"LISTENING WELL / ARRAY RIBS","crown_throat":"TRANSMITTER / CROWN THROAT","wake_fracture":"OUTBOUND WAKES / WARM FRACTURE",
	"silt_scour":"SILT ARCHIVE / SCOUR CUT","exhaust_stack":"FURNACE DRIFT / EXHAUST PLUME","prism_facets":"PRISM GRAVE / FACETS","choir_window":"HAMMERWAKE / LOCK WINDOW"}
const EVIDENCE_KEYS=["spire","relay_west","relay_east","frame_cycle","well_aperture","well_return","silt_scour","exhaust_stack","prism_facets","choir_window"]
static func intel_keys()->Array:
	return LABELS.keys()
static func intel_label(key:String)->String:
	return LABELS.get(key,key.to_upper())
static func evidence_keys()->Array:
	var result=EVIDENCE_KEYS.duplicate()
	for type in preload("res://src/simulation/photo_capture.gd").SIREN_TYPES:result.append("siren_"+type)
	return result
static func F(id:String,label:String,bearing:float=0.0,arc:float=PI,detail:float=0.1,lat:float=0.0,extra:Dictionary={})->Dictionary:
	var f={"id":id,"label":label,"bearing":bearing,"arc":arc,"detail":detail,"lat":lat}
	f.merge(extra,true)
	return f
static func S(facing:float,size:float,glow:float,required:Array,features:Array,extra:Dictionary={})->Dictionary:
	var s={"facing":facing,"size":size,"glow":glow,"required":required,"features":features}
	s.merge(extra,true)
	return s
# An unresolved subject: only an area on the chart until a craft sights it, then
# only an unnamed shape until a frame resolves what it is.
static func _unknown(o:Dictionary,alias:String,radius:float,off:Vector2,sight:float=170.0)->void:
	o["unknown"]=true;o["alias"]=alias;o["lead"]={"r":radius,"off":off,"sight":sight}
static func _tag(o:Dictionary,subject:Dictionary,optical:String="",evidence:String="")->void:
	o["subject"]=subject
	if not optical.is_empty():o["optical"]=optical
	if not evidence.is_empty() and not o.has("evidence"):o["evidence"]=evidence
static func apply(m:Dictionary,id:int,context:Dictionary)->void:
	var objs:Array=m.objectives
	match id:
		0:
			_tag(objs[0],S(2.74,90.0,0.5,["beacon"],[
				F("beacon","BEACON LAMP",0.0,PI,0.04,0.0,{"glow":0.5,"gloss":"The beacon still pulses on battery."}),
				F("drill","BROKEN DRILL STRING",0.0,1.1,0.38,-0.6,{"intel":"spire_wreck","gloss":"A drill string, snapped clean, ringing in the swell.","finding":{"kind":"route","text":"LEE CHANNEL · open water south of the wreck runs to the shelf edge","pts":[Vector2(1240,360),Vector2(1180,520),Vector2(900,540),Vector2(760,720),Vector2(480,760),Vector2(150,800)]}}),
				F("scoring","SCORED PLATING",PI,1.0,0.5,0.5,{"intel":"spire_scoring","gloss":"Deep parallel scoring on the lee plating. Not tool marks.","finding":{"kind":"hazard","text":"SCORED LEE · something heavy works this bank","off":Vector2(-70,50),"r":110.0}})]),"spire","Corran Bank's emergency beacon, still on battery.")
			_unknown(objs[0],"UNKNOWN SIGNAL SOURCE",170.0,Vector2(-70,60))
		1:
			for n in 2:
				_tag(objs[n],S(1.57,60.0,0.3,["housing"],[
					F("housing","TRANSPONDER HOUSING",0.0,PI,0.04,0.0,{"glow":0.3}),
					F("clock","STOPPED CLOCK",0.0,1.2,0.4,0.4,{"intel":"relay_clock","gloss":"Its clock stopped when the riser parted."})]),["relay_west","relay_east"][n],"A seabed transponder, its log intact.")
				_unknown(objs[n],"UNKNOWN SEABED RETURN",150.0,[Vector2(50,-40),Vector2(-40,50)][n])
		3:
			_tag(objs[0],S(1.57,80.0,0.6,["mouth"],[
				F("mouth","VENT MOUTH",0.0,PI,0.04,0.0,{"glow":0.6}),
				F("lining","VENT LINING",0.0,1.0,0.45,0.4,{"intel":"foundry_lining","gloss":"The lining is grown, not cast.","finding":{"kind":"weak","text":"VENT LINING · grown, not cast, and thinnest at the mouth","off":Vector2(0,50)}})]))
			_unknown(objs[0],"UNKNOWN HEAT SOURCE",160.0,Vector2(60,-50))
			_tag(objs[1],S(0.9,110.0,0.3,["rails"],[
				F("rails","RAILS",0.0,PI,0.04,-0.4,{"glow":0.2}),
				F("frames","OPEN FRAMES",0.0,1.2,0.42,0.4,{"intel":"cradle_frames","gloss":"Open frames stand ready on the rails, all still warm.","finding":{"kind":"route","text":"LOAD LANE · the rails run southeast from the cradle to the trench","pts":[Vector2(1320,770),Vector2(1540,880)]}})]))
			_unknown(objs[1],"UNKNOWN STRUCTURE",150.0,Vector2(-50,50))
			var hatch=S(1.57,70.0,0.25,["hatch"],[F("hatch","HATCH SEAM",0.0,1.4,0.3,0.0,{"glow":0.6,"dwell":3.0,"window":[30.0,7.0,0.0],"intel":"base_cycle","gloss":"Every hatch seam opens together, then closes. The cycle repeats on a count of thirty.","finding":{"kind":"cycle","text":"BAY HATCHES · open together 7s of every 30s","period":30.0,"open":7.0,"phase":0.0}})])
			objs.append({"pos":Vector2(1480,790),"name":"FRAME BAY HATCHES","captured":false,"optional":true,"kind":"","duration":34.0,"optical":"frame_cycle","site_id":"frame_cycle","subject":hatch,"evidence":"The bay hatches of the Siren base. Watch them across a full cycle."})
			_unknown(objs[2],"UNKNOWN SIREN STRUCTURE",140.0,Vector2(40,50))
			m.brief+=" The base is theirs, and it keeps a rhythm. An optional long observation of its frame bays pays for patience: hold the camera across a whole cycle from outside its reach."
		4:
			_tag(objs[0],S(0.6,100.0,0.2,["ribs"],[F("ribs","ARRAY RIBS",0.0,PI,0.04),F("count","RIB COUNT",0.0,1.0,0.4,0.4,{"intel":"well_array","gloss":"The ribs repeat a count, not a word.","finding":{"kind":"note","text":"RIB COUNT · the ribs repeat a count, not a word"}})]))
			_tag(objs[1],S(0.0,80.0,0.2,["face"],[F("face","APERTURE",0.0,PI,0.04)]),"well_aperture","A dark aperture in the rim.")
			_tag(objs[2],S(PI,80.0,0.2,["face"],[F("face","ARCHIVE FACE",0.0,PI,0.04)]),"well_return","The rim's return archive.")
		5:
			_tag(objs[0],S(1.2,100.0,0.4,["vanes"],[
				F("vanes","RESONATOR VANES",0.0,PI,0.04,-0.3,{"glow":0.4}),
				F("throat","CROWN THROAT",0.0,0.9,0.5,0.4,{"intel":"crown_throat","gloss":"Every vane aims into the trench.","finding":{"kind":"note","text":"CROWN THROAT · every vane aims into the trench"}})]))
			_unknown(objs[0],"UNKNOWN TRANSMITTER",170.0,Vector2(60,50))
			_tag(objs[1],S(0.0,160.0,0.2,["lines"],[
				F("lines","WAKE LINES",0.0,PI,0.04,-0.3),
				F("fracture","WARM FRACTURE",0.0,PI,0.35,0.5,{"need":"thermal","glow":0.5,"intel":"wake_fracture","gloss":"A warm fracture splits the wakes.","finding":{"kind":"note","text":"WARM FRACTURE · the wakes split: one line south, one west"}})]))
			_unknown(objs[1],"UNKNOWN DISTURBANCE",190.0,Vector2(-60,-40))
		16:
			m.brief+=" The plant has to vent somewhere. Vey: our survey never found where."
			_hidden(m,{"key":"exhaust_stack","pos":Vector2(2100,1190),"sight":260.0,"seen_as":"UNIDENTIFIED HEAT SOURCE","lead":{"r":230.0,"off":Vector2(-80,60),"alias":"UNKNOWN HEAT RETURN"},"evidence":"A hot stack beyond the piers.",
				"subject":S(-1.57,70.0,0.5,["stack"],[
					F("stack","EXHAUST STACK",0.0,PI,0.1,-0.2,{"glow":0.5}),
					F("plume","EXHAUST PLUME",0.0,PI,0.3,0.4,{"need":"thermal","glow":0.5,"intel":"exhaust_stack","gloss":"A hot plume rides the crossflow and clings to the west wall."})],{"reveal":"EXHAUST STACK"})})
		17:
			m.brief+=" Vey: the survey boat logged repeated low strikes from the terraces and never photographed their source."
			_hidden(m,{"key":"silt_scour","pos":Vector2(1750,1230),"sight":190.0,"seen_as":"UNIDENTIFIED DISTURBANCE","lead":{"r":210.0,"off":Vector2(70,-60),"alias":"UNKNOWN LOW STRIKES"},"evidence":"Disturbed silt on the terrace.",
				"subject":S(0.0,120.0,0.0,["lines"],[
					F("lines","SCOUR LINES",0.0,PI,0.12,-0.5,{"gloss":"Parallel scour lines in the silt, fresh."}),
					F("channel","CUT CHANNEL",0.0,1.2,0.38,0.3,{"intel":"silt_scour","gloss":"The scour is a cut channel under the glass line, wider than any hull of ours."})],{"reveal":"SILT SCOUR LINES"})})
		20:
			objs.append({"pos":Vector2(1250,1560),"name":"PRISM FACETS","captured":false,"optional":true,"kind":"","optical":"prism_facets","site_id":"prism_facets","evidence":"The cracked prism, its facets exposed.",
				"subject":S(0.8,60.0,0.15,["prism"],[
					F("prism","CRACKED PRISM",0.0,PI,0.1,-0.3,{"glow":0.15}),
					F("facets","PRISM FACETS",0.0,0.9,0.5,0.4,{"intel":"prism_facets","gloss":"The facets are ground to one measured angle.","finding":{"kind":"weak","text":"PRISM FACETS · ground to one angle, cracked along it","off":Vector2(0,40)}})])})
			_unknown(objs.back(),"UNKNOWN CRYSTAL SHAPE",170.0,Vector2(60,-50))
		22:
			m.brief+=" A lit window shows near the west lock. Photograph it from the lane side and see who is there."
			_hidden(m,{"key":"choir_window","pos":Vector2(1720,470),"sight":230.0,"seen_as":"UNIDENTIFIED LIGHT","lead":{"r":200.0,"off":Vector2(60,-40),"alias":"UNKNOWN LIGHT"},"evidence":"A lit window beside the west lock.",
				"subject":S(1.57,60.0,0.5,["window"],[
					F("window","LIT WINDOW",0.0,PI,0.06,-0.2,{"glow":0.6}),
					F("figure","FIGURE AT THE GLASS",0.0,1.2,0.42,0.4,{"intel":"choir_window","gloss":"Someone is at the glass, signalling by hand.","finding":{"kind":"person","text":"A FIGURE AT THE LOCK A WINDOW · signalling by hand","pos":Vector2(1800,390)}})],{"reveal":"LOCK A WINDOW"})})
static func _hidden(m:Dictionary,h:Dictionary)->void:
	if not m.has("photo_hidden"):m["photo_hidden"]=[]
	h["found"]=false
	m.photo_hidden.append(h)
