extends RefCounted
const TITLES = ["Shelf Signal", "Split Channel", "Blackwater Relay", "Cold Foundry", "The Listening Well", "Siren's Song"]
const BRIEFS = [
	"A repeating signal rises from the shelf. Photograph the listening spire, then bring Quietus home. Your charts show rock, not what waits behind it. Sonar reveals water but announces your position.",
	"Two channels. Two witnesses. Send the drones around the basalt divide while Quietus holds in shelter. Recover imagery of both relay mouths and return to extraction.",
	"The signal is a conversation. Blackwater absorbs passive returns. Use the relay chain to map the exchange. Drones see farther; the submarine camera remains your fallback.",
	"We found the source: a foundry large enough to build a fleet. Image its furnaces and assembly crown. Amber light marks the active machinery. Sirens listen along the eastern perimeter.",
	"The well is listening to us. Collect three records from its circumference. A mobile hunter patrols the inner water. Break sight before its beam resolves. Silence is a route, too.",
	"The song is a warning, not an invitation. Document the transmission array and its outbound vector. Return with the archive. Command will ask for targets. Bring them evidence instead."
]
const RECORDS = [
	"A manufactured pulse. Something beneath the shelf is counting the seconds between our pings.",
	"The relays exchange corrections. Their network is learning the shape of our instruments.",
	"The carrier contains ocean temperatures from before humans existed. This installation has been waiting.",
	"No weapons leave the furnaces. The machine is constructing vessels for a journey into deeper water.",
	"Our engine note appears in the next transmission. They have heard the lone pilot inside Quietus.",
	"The final packet describes a fracture below the mantle. The Sirens are leaving. Their song asks us to listen."
]
static func make(index: int) -> Dictionary:
	var i = clampi(index,0,5)
	var layouts = [
		[Rect2(440,350,240,260),Rect2(920,140,180,260),Rect2(1020,680,200,180)],
		[Rect2(560,240,240,470),Rect2(1120,440,180,220),Rect2(240,120,160,260)],
		[Rect2(400,430,280,220),Rect2(840,250,240,220),Rect2(1200,650,160,200)],
		[Rect2(360,240,180,390),Rect2(760,500,260,200),Rect2(1020,160,180,160)],
		[Rect2(480,280,240,250),Rect2(880,420,220,250),Rect2(1200,180,160,160)],
		[Rect2(360,300,180,340),Rect2(740,160,220,300),Rect2(1040,540,240,220)]
	]
	var points = [
		[Vector2(1300,300)],
		[Vector2(960,180),Vector2(1400,640)],
		[Vector2(760,200),Vector2(1360,480)],
		[Vector2(1320,220),Vector2(1400,700)],
		[Vector2(800,180),Vector2(1370,450),Vector2(780,780)],
		[Vector2(1160,240),Vector2(1420,460),Vector2(1000,820)]
	]
	var objectives: Array = []
	for n in points[i].size():
		objectives.append({"pos":points[i][n],"name":["SIGNAL SPIRE","RELAY MOUTH","ARCHIVE NODE"][n],"captured":false})
	var patrols: Array = []
	for n in (1 + i / 2):
		patrols.append({"pos":Vector2(620 + n*270,130),"home":Vector2(620+n*270,130),"goal":Vector2(620+n*270,130),"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":n,"path_time":0.0})
	return {"id":i,"title":TITLES[i],"brief":BRIEFS[i],"record":RECORDS[i],"rocks":layouts[i],"objectives":objectives,"sirens":patrols,"extraction":Vector2(140,800),"darkness":i==2,"depth":[840,1320,1850,2360,3100,3840][i]}
