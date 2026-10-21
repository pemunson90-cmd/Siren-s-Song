extends RefCounted
const TITLES = ["Shelf Signal", "Split Channel", "Blackwater Relay", "Cold Foundry", "The Listening Well", "Siren's Song"]
const BRIEFS = [
	"Corran Bank's beacon is still pinging from the shelf. Photograph the signal spire, then bring Quietus home. Your charts show rock, not what waits behind it. Sonar shows you the water and tells everything in it where you are.",
	"Two seabed transponders, two halves of the rig's log. Photograph the WEST and EAST relays. Bring Quietus to the covered UPLINK ANCHOR and use CAMERA / LINK to join their records. Drones are faster and can expose a relay while the submarine moves. Lose them and the submarine goes the long way alone. Return with the joined log.",
	"The two relays still trade packets. Blackwater swallows passive returns. Settle within passive reach and SAMPLE the REQUEST and REPLY relays. Drones hear farther; Quietus can recover either record if they are lost. Sonar can make a relay answer, but everything nearby hears the ping. Bring the exchange home.",
	"Enter from the western shelf. Our recovery buoy is past the southern factory wall. Image the FURNACE VENT first, then the LAUNCH CRADLE. The basalt spine gives cover; the factory perimeter does not. Station guards hold the furnace and the recovery channel. A live decoy draws them out; they return when it stops. Cameras can draw a response. Plan Quietus' route before you expose the second record. Drones can take either photograph; the submarine is your fallback.",
	"The well records what it hears. Collect three records from its rim. A fast responder waits in the inner water. Noise draws it out; when sight breaks it searches the last place it heard or saw you. Break sight before its beam resolves. Silence is a route too.",
	"The transmitter crown faces the trench; the wakes run deeper, away from us. Photograph both. Bring Quietus through the southern basalt lee to the LEE RECEIVER and use CAMERA / LISTEN for six quiet seconds. Only the submarine carries the low-frequency hydrophones for this packet. Drones can scout the exposed crown and wakes while Quietus moves under cover; the submarine can take either image if they are lost. Return to the western buoy with what you heard."
]
const RECORDS = [
	"Corran Bank's emergency beacon, still on battery. Under it the broken drill string rings each time the swell moves the wreck.",
	"Both transponders logged the night of the strike. Their clocks agree: the riser parted at 02:14, eleven seconds after the first Siren contact.",
	"The reply is the driller's log. The last entry is a pressure reading, then nothing.",
	"The furnace pours smooth hollow forms. In the cradles the same forms hang finished. One cradle is empty.",
	"Our engine note comes back in the well's next transmission.",
	"The packet is a list of bearings, one for every loud site on this coast. Two of them still make noise."
]
static func make(i: int) -> Dictionary:
	if i<0 or i>=TITLES.size():return {}
	var layouts = [
		[Rect2(440,350,240,260),Rect2(920,140,180,260),Rect2(1020,680,200,180)],
		[Rect2(-100,-100,340,760),Rect2(600,-100,300,700),Rect2(1440,-100,260,700),Rect2(480,900,500,160),Rect2(1030,650,180,160)],
		[Rect2(400,430,280,220),Rect2(840,250,240,220),Rect2(1200,650,160,200)],
		[Rect2(-120,-120,360,680),Rect2(240,-120,660,260),Rect2(500,300,300,360),Rect2(740,900,320,140),Rect2(900,620,120,180)],
		[Rect2(480,280,240,250),Rect2(880,420,220,250),Rect2(1200,180,160,160)],
		[Rect2(-100,-100,340,640),Rect2(560,-100,280,620),Rect2(1000,470,250,190)]
	]
	var points = [
		[Vector2(1300,300)],
		[Vector2(420,280),Vector2(1220,280),Vector2(840,780)],
		[Vector2(760,200),Vector2(1360,480)],
		[Vector2(1090,360),Vector2(1320,770)],
		[Vector2(800,180),Vector2(1370,450),Vector2(780,780)],
		[Vector2(1210,240),Vector2(1400,700),Vector2(900,780)]
	]
	var objectives: Array = []
	for n in points[i].size():
		objectives.append({"pos":points[i][n],"name":["SIGNAL SPIRE","RELAY MOUTH","ARCHIVE NODE"][n],"captured":false})
	if i==1:
		objectives[0].name="WEST RELAY"; objectives[1].name="EAST RELAY"
		objectives[2].name="UPLINK ANCHOR"; objectives[2]["kind"]="uplink"; objectives[2]["duration"]=6.0; objectives[2]["required_unit"]=0; objectives[2]["requires"]=[0,1]
	if i==2:
		for n in 2:
			objectives[n].name=["REQUEST RELAY","REPLY RELAY"][n];objectives[n]["kind"]="exchange";objectives[n]["duration"]=2.0;objectives[n]["replay_until"]=0.0
			objectives[n]["optical"]=["blackwater_request","blackwater_reply"][n]
		objectives[0]["evidence"]="REPLY HANDSHAKE: settle and SAMPLE 2s within passive reach. For standoff, settle first, emit SONAR under 240m with a clear line, then SAMPLE 2s during its 3s reply. The western unit asks its eastern partner for the log it lost when the riser parted."
		objectives[1]["evidence"]="DRILLER'S LOG: the eastern reply carries the rig's last log. The REQUEST uses the same handshake: settle within passive reach and SAMPLE 2s, or settle, SONAR under 240m with a clear line, then SAMPLE during the 3s local replay. Either packet can be recovered first."
	if i==3:
		objectives[0].name="FURNACE VENT"; objectives[0]["optical"]="furnace"
		objectives[0]["evidence"]="Molten material runs into smooth hollow forms. The line feeds the cradles to the south."
		objectives[1].name="LAUNCH CRADLE"; objectives[1]["optical"]="cradle"; objectives[1]["requires"]=[0]
		objectives[1]["requirement"]="Record the furnace first, so the cradle images can be matched to its castings."
		objectives[1]["evidence"]="Long smooth hulls hang in open frames, lit from inside. One frame is empty. Its rails run down toward the trench."
	if i==5:
		objectives[0].name="TRANSMITTER CROWN"; objectives[0]["optical"]="transmitter"
		objectives[0]["evidence"]="Nested resonator vanes point into the trench. They repeat one low pulse, over and over."
		objectives[1].name="OUTBOUND WAKES"; objectives[1]["optical"]="departure"
		objectives[1]["evidence"]="Smooth hulls descend away from the shelf. Past a warm fracture in the trench floor their wakes split: one line runs south down the trench, one turns west along the shelf."
		objectives[2].name="LEE RECEIVER"; objectives[2]["kind"]="receiver"; objectives[2]["required_unit"]=0; objectives[2]["duration"]=6.0; objectives[2]["requires"]=[0,1]; objectives[2]["optical"]="warning"
		objectives[2]["requirement"]="Need both observations: TRANSMITTER CROWN + OUTBOUND WAKES."
		objectives[2]["unit_requirement"]="Quietus hydrophones required · small drones cannot resolve this packet."
		objectives[2]["evidence"]="DECODED: a list of bearings, one for every loud site on this coast the night of the strike. Two still answer. South down the trench: the drillship Tessaly. West on the shelf: the sonar station at Port Ardent."
	var patrols: Array = []
	for n in (1 + i / 2):
		patrols.append({"pos":Vector2(620 + n*270,130),"home":Vector2(620+n*270,130),"goal":Vector2(620+n*270,130),"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":n,"path_time":0.0,"type":"patroller"})
	if i==1:
		patrols[0].pos=Vector2(420,140); patrols[0].home=patrols[0].pos; patrols[0].goal=patrols[0].pos
		var east=patrols[0].duplicate(true); east.pos=Vector2(1220,140); east.home=east.pos; east.goal=east.pos; east.patrol=1; patrols.append(east)
	var result={"id":i,"title":TITLES[i],"brief":BRIEFS[i],"record":RECORDS[i],"rocks":layouts[i],"objectives":objectives,"sirens":patrols,"extraction":Vector2(140,800),"darkness":i==2,"depth":[840,1320,1850,2360,3100,3840][i]}
	result["acoustic_revision"]=1
	if i==2:
		result["blackwater_revision"]=1;result["courier_revision"]=1;result["courier_launch"]=-1.0
		result["blackwater_delivery"]=preload("res://src/simulation/blackwater_delivery.gd").initial()
		objectives[0].evidence+=" The request also announces a survey glider carrying a copy of the eastern REPLY around the southern basalt corridor to a buried western intake. The recovered chart marks its course. Intercept it with a settled SAMPLE 2s before it submerges at the intake; it never visits this REQUEST. Catching it on the way back replaces the eastern approach, not the record. The fixed REPLY and its SONAR replay stay available if you miss it."
		result.brief+=" A recovered request may announce a survey glider; catching it is optional, and the fixed relays work in either order. Blackwater breaks the bulk uplink: field notes are kept, but raw data stays on the craft that sampled it. Bring that craft within 60m of Quietus, settle both below 2m/s with a clear line, then TRANSFER. Lost buffers stay at the wreck; one audible local 4s winch recovers data and kit there, or Quietus can SAMPLE the relay again. Data Quietus samples itself is already aboard; spare drones need not return."
	if i==3:
		result["departure_revision"]=1
		result["thermal_revision"]=1;result["thermal_fronts"]=preload("res://src/simulation/thermal_front.gd").foundry()
		result.brief+=" A charted cold-water front crosses the southern channel. Sound and passive contacts weaken across it in both directions. Waiting west of it may protect a staging drone, but costs information and time. Close sight and visible beam charges still expose you; optical photography remains noisy."
		result.brief+=" The cradle motors warm up, then one hull leaves southeast. Its lit return comes from below our operating depth: it is not cover or an obstacle. Listen and watch the guards before you cross. Waiting costs time; crossing early and loud may need a disruption. Sight still outranks the factory noise."
		var factory=Rect2(1120,140,400,600)
		result["structures"]=[factory]; result["factory_rect"]=factory; result["phase"]="approach"; result["response_time"]=0.0
		result.extraction=Vector2(1420,880)
		for n in patrols.size():
			var home=[Vector2(960,260),Vector2(1320,820)][n]
			patrols[n].pos=home; patrols[n].home=home; patrols[n].goal=home
			patrols[n]["type"]="sentinel"; patrols[n]["tether"]=190.0
	if i==4:
		result["well_revision"]=1;result["well_reference"]={};result["well_observation"]={}
		result.brief="The well repeats an unassigned cadence. Recover three perimeter records and return. Its fast hunter follows real noise and sightings. Optional comparison: after recording the PATTERN ARRAY, cruise Quietus through clear water within 240m of the PROFILE APERTURE while MOTION NOISE shows QUIETUS. Then bring a live receiver within passive reach of the RETURN ARCHIVE. A drone can listen while Quietus makes its pass; Quietus can make the comparison alone. Remote records remain a valid unverified archive. No comparison is worth promising a safe escape."
		result.record="Well archive recovered · signature unverified. The returned cadence remains unassigned; no moving Quietus comparison was observed."
		objectives[0].name="PATTERN ARRAY";objectives[0]["optical"]="well_pattern"
		objectives[0]["evidence"]="UNASSIGNED CADENCE. This perimeter record contains a repeating pattern, not an identified speaker. Optional test: cruise Quietus past the PROFILE APERTURE within 240m and a clear line while its motion-noise instrument is active. Receive the local return near the RETURN ARCHIVE: Quietus within 240m or a live drone within 330m, with a clear line. Keep the remote archive without making this comparison, or risk a moving pass for a recorded match."
		objectives[1].name="PROFILE APERTURE";objectives[2].name="RETURN ARCHIVE"
		patrols[1]["type"]="hunter"; patrols[1].pos=Vector2(800,600); patrols[1].home=patrols[1].pos; patrols[1].goal=patrols[1].pos
	if i==5:
		result["phase"]="observations"; result["finale_revision"]=1
		result["array_rect"]=Rect2(1260,60,300,280); result["structures"]=[result.array_rect]
		for n in patrols.size():
			var home=[Vector2(970,160),Vector2(1390,420),Vector2(1260,830)][n]
			patrols[n].pos=home; patrols[n].home=home; patrols[n].goal=home
	var circuits=[
		[[Vector2(620,130),Vector2(800,150),Vector2(800,310),Vector2(620,280)]],
		[[Vector2(420,140),Vector2(420,420),Vector2(420,700),Vector2(520,780)],[Vector2(1220,140),Vector2(1260,460),Vector2(1360,820),Vector2(1180,560)]],
		[[Vector2(620,130),Vector2(760,130),Vector2(760,350),Vector2(600,330)],[Vector2(890,130),Vector2(1140,160),Vector2(1140,520),Vector2(780,520)]],
		[[Vector2(960,260),Vector2(1040,460),Vector2(1080,580),Vector2(1080,840)],[Vector2(1320,820),Vector2(1450,840),Vector2(1510,880),Vector2(1150,860)]],
		[[Vector2(620,130),Vector2(800,130),Vector2(800,300),Vector2(420,200)],[Vector2(890,130),Vector2(1060,360),Vector2(1180,400),Vector2(1150,740)],[Vector2(1160,130),Vector2(1420,140),Vector2(1450,480),Vector2(1380,780)]],
		[[Vector2(970,160),Vector2(1140,120),Vector2(1080,400),Vector2(920,560)],[Vector2(1390,420),Vector2(1480,500),Vector2(1500,700),Vector2(1340,410)],[Vector2(1260,830),Vector2(1430,880),Vector2(1030,860),Vector2(900,700)]]
	]
	for n in patrols.size():
		patrols[n]["patrol_points"]=circuits[i][n]; patrols[n]["patrol_index"]=0
	if i==5:
		result["contact_report_revision"]=1
		result.brief+=" A Siren with clear sight can report a last-seen area to one nearby peer after 2s. Break sight to interrupt; disruption stops the report but its own noise can expose you. Reports travel through the local water, never the whole network."
	if i==1:preload("res://src/campaign/split_channel_region.gd").apply(result)
	return result

static func supports_config(config:Dictionary)->bool:
	var source=config.get("source_id",-1)
	return config.size()==2 and config.get("history")==false and source>=0 and source<TITLES.size()

# Identity-bound authored helpers remain on their original operation.
static func supports_identity(id:int,config:Dictionary)->bool:
	return id==config.source_id or config.source_id in [0,1,2]
