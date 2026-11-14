extends RefCounted
# The Field Manual's content: one table, drawn by field_manual_view.gd. Every line restates a rule the game
# already enforces (see the work package report for the source of each). Control names are spelled exactly as
# the buttons show them. The OPERATION topic has no lines here: the view fills it from the open briefing.
const BUTTON_TEXT="FIELD MANUAL\nHow to move, stay quiet, use drones and take photographs."
const OPERATION_ID="operation"
const TOPICS=[
	{"id":"moving","title":"MOVING","lines":[
		"Tap || PAUSE (top left) to stop time and plan for as long as you like. Tap Quietus or a drone, then tap open water to place a straight leg. Nothing moves until you tap ▶ RUN.",
		"A craft does not steer around rock. A red leg crosses charted rock and can crash. Tap the marker a second time to send a route across rock anyway.",
		"A craft that already has a route asks first: REPLACE ROUTE swaps it, ADD TO ROUTE extends it.",
		"The switch STOP AT EACH NEW POINT decides whether the craft halts at added points or keeps moving through them.",
		"Drag and pinch to look around. FOCUS follows the craft and FIT shows the region.",
	]},
	{"id":"quiet","title":"STAYING QUIET","lines":[
		"Speed makes noise. Fast movement is heard from farther away.",
		"GO SILENT is slower and quieter: Sirens see Quietus from 290m, or from 180m when it runs silent. GO LOUD gives the speed back. The segment names what a tap does and its small line says how things stand; tap it once to read the cost, tap again to confirm.",
		"A Siren that hears noise goes to that spot, then searches. When one notices you, or starts to lock on, time pauses and shows its bearing and the seconds left.",
		"Break line of sight, slow down or GO SILENT, then tap ▶ RUN.",
		"Cover blocks sonar, enemy sight and torpedoes. Keep rock between you and a Siren.",
	]},
	{"id":"drones","title":"DRONES","lines":[
		"Both drones start aboard Quietus. Tap Quietus and choose DEPLOY DRONE, or choose a drone under FLEET and tap water to deploy it on that route.",
		"A deployed drone stays out for the rest of the dive. Drones are expendable. Quietus is not.",
		"A calm Siren ignores a drone. Once it is alerted, or Hunt reaches SEARCHING, drones are targets.",
		"To bring a drone back, choose it and use RECALL. Quietus has RECALL ALL.",
	]},
	{"id":"sonar","title":"SONAR AND DEPTH","lines":[
		"Depth and sonar sit under DEPTH AND SONAR on the wheel.",
		"SHALLOWER and DEEPER change the layer. The craft holds still for 4 seconds and is exposed in both layers.",
		"PING SONAR spends reserve and makes noise. Sirens hear every sonar ping.",
		"PING ARC and PING POWER set the next ping's coverage and reach. Returns take time. PAST PINGS lists what came back.",
	]},
	{"id":"photos","title":"PHOTOGRAPHS","lines":[
		"CAMERA works within 240m of a gold record marker.",
		"Closer is clearer. The rings show how near a detail resolves.",
		"A dark subject needs you to close in, or to hold still for 8 seconds. Flash is loud and limited.",
		"Some details show only in a cycle. The viewfinder counts down to the next opening.",
		"Film is limited. Every exposure costs one, even a failed one.",
	]},
	{"id":"tools","title":"TOOLS","lines":[
		"Field tools spend finite stock. SUPPLIES prepares the next launch; RESUME keeps this dive's stock.",
		"EMP interrupts nearby Sirens for 12 seconds.",
		"TORPEDO: tap a fresh contact. It travels noisily up to 150m, and impact pins one Siren for 8 seconds.",
		"DECOY is placed by tapping clear water within 160m.",
		"SURVEY takes 8 seconds and is audible.",
	]},
	{"id":"home","title":"GOING HOME","lines":[
		"Return Quietus to its extraction point once the records are secured.",
		"Quietus carries limited life support (O₂), and some actions spend it. Plan your way back before you spend it.",
		"The ▶ RUN / || PAUSE control stays available all the way home.",
		"The game also pauses when a craft reaches the end of its route, and time stands still while the command wheel, a status sheet or the FLEET panel is open.",
	]},
	{"id":OPERATION_ID,"title":"THIS OPERATION","lines":[]},
]
static func topic(id:String)->Dictionary:
	for entry in TOPICS:
		if entry.id==id:return entry
	return TOPICS[0]
