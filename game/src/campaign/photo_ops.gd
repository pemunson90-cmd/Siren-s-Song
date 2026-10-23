extends RefCounted
# Authored photographic subjects for operations, kept as data so new operations
# add reconnaissance by adding rows here. apply() runs once from the catalog
# after an operation is built:
#   subjects  attached to existing photo objectives (by index)
#   extra     optional objectives added to an operation (long observations)
#   hidden    phenomena that are not charted: they become objectives only after
#             a craft's own camera sights them (see photo_capture.discover)
# Story text here is short placeholder text.
# M1 optional reconnaissance data. Revert by removing the _apply_campaign_rows call.
# Retain subject/key registrations so recovered film and intel in old saves stay valid.
# Long observations use the existing unknown optional objective shape, not a new kind.
const CAMPAIGN_DEFAULTS={"size":80.0,"glow":0.35,"sight":210.0,"arc":1.0,"detail":0.45,"dwell":2.0,"duration":4.0}
const CAMPAIGN_PHOTOS=[
 {"op":7,"key":"tender_door","name":"RENDEZVOUS / BERTHING HULL DOOR","pos":Vector2(650,610),"facing":0.0,"band":1,"feature":"DOOR SIDE","finding":{"kind":"route","text":"LOADING LANE · the door faces the sheltered side","pts":[Vector2(650,610),Vector2(820,760)]}},
 {"op":8,"key":"relay_blink","name":"SHELF RETURN / RELAY LAMP","pos":Vector2(1350,1680),"facing":PI,"band":1,"feature":"BLINK GAP","window":[24.0,6.0,0.0],"duration":28.0,"dwell":3.0,"finding":{"kind":"cycle","text":"RELAY LAMP · 6s opening in each 24s cycle","period":24.0,"open":6.0,"phase":0.0}},
 {"op":11,"key":"structure_edge","name":"CONFLUENCE / SCORED STRUCTURE","pos":Vector2(3180,2810),"facing":PI,"band":2,"feature":"SCOUR EDGE","finding":{"kind":"hazard","text":"SCORED EDGE · recorded wear, not a live patrol contact","off":Vector2(-80,0),"r":120.0}},
 {"op":14,"key":"buoy_blind","name":"GLASS FENCE / LISTENER LAMP","pos":Vector2(1700,1000),"facing":PI,"band":1,"feature":"LAMP ASPECT","finding":{"kind":"post","text":"LISTENER LAMP · the back plate hides its light","off":Vector2(-80,0)}},
 {"op":15,"key":"vane_crack","name":"NEEDLE STRAIT / STRAIN VANE CRACK","pos":Vector2(850,2380),"facing":0.0,"band":1,"feature":"HAIRLINE CRACK","detail":0.68,"dwell":2.5,"sight":300.0,"finding":{"kind":"weak","text":"STRAIN VANE · a crack follows the release seam","off":Vector2(0,40)}},
 {"op":18,"key":"keel_mark","name":"LANTERN LOCK / KEEL SERVICE MARK","pos":Vector2(1840,1220),"facing":PI,"band":0,"feature":"SERVICE MARK","finding":{"kind":"route","text":"INNER PASSAGE · a service mark faces sheltered water","pts":[Vector2(1840,1220),Vector2(2000,1350)]}},
 {"op":19,"key":"boat_keel","name":"LAST BOAT OUT / KEEL PLATE","pos":Vector2(2200,2080),"facing":PI,"band":1,"feature":"BERTH MARK","finding":{"kind":"route","text":"OUTWARD BERTH · the keel mark points to the service lane","pts":[Vector2(2200,2080),Vector2(2400,2220)]}},
 {"op":21,"key":"locker_latch","name":"RANGE LOCKER / SERVICE LATCH","pos":Vector2(1320,1080),"facing":PI,"band":0,"feature":"LATCH SEAM","finding":{"kind":"weak","text":"SHALLOW LATCH · the seam is visible above the door","off":Vector2(0,30)}},
 {"op":23,"key":"shutter_order","name":"PRESSURE STAIR / SHUTTER LAMPS","pos":Vector2(700,1840),"facing":PI,"band":1,"feature":"LAMP ORDER A B C","window":[30.0,9.0,0.0],"duration":34.0,"dwell":3.0,"finding":{"kind":"cycle","text":"SHUTTER LAMPS · A then B then C across the recorded cycle","period":30.0,"open":9.0,"phase":0.0}},
 {"op":24,"key":"bus_cable","name":"CHOIR CUT / BALLAST BUS CABLE","pos":Vector2(2320,1075),"facing":PI,"band":1,"feature":"REPORTING BRANCH","finding":{"kind":"post","text":"BUS CABLE · the marked branch feeds the reporting side","off":Vector2(60,0)}},
 {"op":26,"key":"spindle_wear","name":"COLD HAMMER / SPINDLE WEAR","pos":Vector2(1300,780),"facing":PI,"band":2,"feature":"SPINDLE SCORING","detail":0.64,"dwell":2.5,"finding":{"kind":"weak","text":"SPINDLE WEAR · a tight frame resolves the scored collar","off":Vector2(0,30)}},
 {"op":27,"key":"slide_mark","name":"COUNTERWEIGHT GRAVE / SLIDE MARK","pos":Vector2(1250,1000),"facing":PI,"band":1,"feature":"SLIDE SCORE","detail":0.64,"dwell":2.5,"finding":{"kind":"hazard","text":"SLIDE MARK · fresh scoring runs toward the cradle","off":Vector2(0,-50),"r":80.0}},
 {"op":28,"key":"bell_name","name":"NAMES IN THE BELL / BERTH NAMEPLATE","pos":Vector2(1130,1150),"facing":PI,"band":1,"feature":"HUMAN SURVIVOR MARKS","detail":0.64,"dwell":2.5,"finding":{"kind":"person","text":"HUMAN SURVIVOR MARKS · on the bell-berth nameplate","off":Vector2(0,20)}},
 {"op":29,"key":"feed_room","name":"SPARE LUNG / SECURITY FEED ROOM","pos":Vector2(2180,700),"facing":PI,"band":1,"feature":"FEED TERMINALS","detail":0.64,"dwell":2.5,"finding":{"kind":"post","text":"FEED ROOM · the terminal marks remain on the recovered film","off":Vector2(0,30)}}
]
const LABELS={
	"spire_wreck":"CORRAN SPIRE / DRILL STRING","spire_scoring":"CORRAN SPIRE / SCORED PLATING","relay_clock":"SPLIT CHANNEL / TRANSPONDER CLOCK",
	"foundry_lining":"COLD FOUNDRY / VENT LINING","cradle_frames":"COLD FOUNDRY / OPEN FRAMES","base_cycle":"SIREN BASE / HATCH CYCLE",
	"well_array":"LISTENING WELL / ARRAY RIBS","crown_throat":"TRANSMITTER / CROWN THROAT","wake_fracture":"OUTBOUND WAKES / WARM FRACTURE",
	"silt_scour":"SILT ARCHIVE / SCOUR CUT","exhaust_stack":"FURNACE DRIFT / EXHAUST PLUME","prism_facets":"PRISM GRAVE / FACETS","choir_window":"HAMMERWAKE / LOCK WINDOW","deep_seam":"SPLIT CHANNEL / DEEP SEAM"}
const EVIDENCE_KEYS=["spire","relay_west","relay_east","frame_cycle","well_aperture","well_return","silt_scour","exhaust_stack","prism_facets","choir_window","deep_seam"]
static func intel_keys()->Array:
	return LABELS.keys()+CAMPAIGN_PHOTOS.map(func(row):return row.key)
static func intel_label(key:String)->String:
	for row in CAMPAIGN_PHOTOS:
		if row.key==key:return row.name
	return LABELS.get(key,key.to_upper())
static func evidence_keys()->Array:
	var result=EVIDENCE_KEYS.duplicate()
	for row in CAMPAIGN_PHOTOS:result.append(row.key)
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
				F("scoring","SCORED PLATING",PI,1.0,0.5,0.5,{"intel":"spire_scoring","gloss":"Deep parallel scoring on the sheltered side of the hull. Not tool marks.","finding":{"kind":"hazard","text":"SCORED HULL · something heavy works this bank","off":Vector2(-70,50),"r":110.0}})]),"spire","Corran Bank's emergency beacon, still on battery.")
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
	_apply_campaign_rows(m,id)
# One data seam; the camera, film, band and finding engines remain unchanged.
static func _apply_campaign_rows(m:Dictionary,id:int)->void:
	for row in CAMPAIGN_PHOTOS:
		if row.op!=id:continue
		var config=CAMPAIGN_DEFAULTS.duplicate(true);config.merge(row,true)
		var feature=F(row.key,row.feature,0.0,config.arc,config.detail,0.3,{"intel":row.key,"dwell":config.dwell,"gloss":row.finding.text,"finding":row.finding.duplicate(true)})
		if row.has("window"):feature["window"]=row.window.duplicate()
		# Existing tight-focus rules may file any held feature: author only the informative one.
		var subject=S(row.facing,config.size,config.glow,[row.key],[feature],{"reveal":row.name,"band":row.band,"bands":[row.band]})
		if row.has("duration"):
			var objective={"pos":row.pos,"name":row.name,"captured":false,"optional":true,"kind":"","duration":config.duration,"optical":row.key,"site_id":row.key,"evidence":row.name+" · recovered field frame.","subject":subject}
			_unknown(objective,"UNKNOWN LAMP RETURN",180.0,Vector2(40,-40),config.sight)
			m.objectives.append(objective)
		else:
			_hidden(m,{"key":row.key,"pos":row.pos,"sight":config.sight,"seen_as":"UNIDENTIFIED SHAPE","lead":{"r":180.0,"off":Vector2(40,-40),"alias":"UNKNOWN FIELD RETURN"},"evidence":row.name+" · recovered field frame.","subject":subject})
static func _hidden(m:Dictionary,h:Dictionary)->void:
	if not m.has("photo_hidden"):m["photo_hidden"]=[]
	h["found"]=false
	m.photo_hidden.append(h)
