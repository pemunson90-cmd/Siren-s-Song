extends RefCounted
# WP-48: the wording of the dive's state controls, in one table. The pause plate names the state first and
# the action second; the silent segment and its centre caption say what the switch does and costs; the
# sonar segments name the ping, not the old transmit jargon; two status lines say why the dive is held and
# when a craft has finished its route. Presentation only: no rule, order id or saved value is touched.
# Every figure shown is read from the constant the simulation uses (see speeds() and sights()):
#   Siren sight   photo_pricing_table.gd SIREN_SIGHT / SIREN_SIGHT_SILENT
#   Quietus speed rule_table.gd CRAFT_SPEED (silent / cruise) through craft_upgrades.gd, the same call
#                 the simulation makes for the fitted hull and drive (cruise_speed, frame_speed).
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const RuleTable=preload("res://src/photo_rules/rule_table.gd")
const CraftUpgrades=preload("res://src/equipment/craft_upgrades.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
const TEXT={
	"paused": "PAUSED",
	# Time stands still only while a menu or the route prompt is open (trial rule 1); closing it lets time run.
	"held": "HELD",
	"running": "RUNNING",
	# WP-94: the plate's first line is what a tap does now, never the state. A play mark while stopped, a pause mark
	# while time runs or a menu holds it (a tap then stops the dive for good).
	"act_run": "▶ RUN",
	"act_pause": "|| PAUSE",
	# WP-103: while something other than the player holds time, the plate's first line is what a tap does then, never
	# "|| PAUSE". A pending route prompt keeps its marker (a tap on the plate says so and changes nothing); an open
	# menu is closed by the tap, which lets time run again.
	"act_answer": "ANSWER",
	"act_close": "CLOSE",
	"plate_answer": "Route marker waiting: tap SEND ANYWAY or CANCEL. Time stays held until you answer.",
	# The lock card's consequence line: what the simulation does when a lock lands (Quietus is destroyed, a drone is lost).
	"lock_lands_quietus": "When it lands, %s is destroyed.",
	"lock_lands_drone": "When it lands, %s is lost.",
	# A craft with a route that is holding in place: why, and the control that lets it go on (presentation/no_progress.gd).
	"hold_HOLD": "%s is holding · route kept · ROUTE page: tap HOLD to go on",
	"hold_CONTACT": "%s is on IF CONTACT guard · route kept · GUARD page: tap IF CONTACT to go on",
	"hold_DRONE": "%s is waiting for a drone · route kept · GUARD page: tap WAIT DRONE to go on",
	"hold_SCOUT_STOP": "%s stopped on a contact · route kept · GUARD page: tap SCOUT to go on",
	# Quietus is in a recovery area but cannot be recovered there yet (presentation/extraction_hint.gd).
	"extract_depth": "Extraction: settle %s in %s to recover",
	"extract_slow": "Extraction: slow %s to under %d m/s to recover",
	"join": " · ",
	# Last line of a tip card while the dive is stopped: GOT IT only closes the card, the plate restarts time.
	# WP-106: the strip line while the dive is stopped: the first thing ▶ RUN will do, most urgent first.
	"run_lock": "After ▶ RUN: a lock lands in %.1f s",
	"run_orders": "After ▶ RUN: orders run for %s",
	"run_none": "After ▶ RUN: no craft has orders",
	# WP-118 (round 9 critics): the strip's standing line while time runs and a launched craft has no orders (route_notes.gd).
	"idle_one": "%s HAS NO ORDERS",
	"idle_many": "%s HAVE NO ORDERS",
	"idle_oxygen": " · oxygen is running",
	"idle_and": " AND ",
	# WP-118: an intel route finding (a lane or passage a photograph revealed: LEE CHANNEL, LOADING LANE, INNER PASSAGE ...)
	# says on its own line that it is not an order (ocean_view.gd). Root: not every such route is sheltered, so the words claim only that.
	"intel_route": "%s · INTEL ROUTE · not an order",
	# WP-118: the status line's next step once the record is secured and Quietus has no route (route_notes.gd).
	"return_old": "Return Quietus to extraction.",
	"return_steps": "Return Quietus to extraction: tap Quietus, then tap the water near EXTRACTION.",
	# WP-106: a route line the craft is not following says why on the chart (route_notes.gd).
	"tag_HOLD": "ROUTE KEPT · HOLDING",
	"tag_CONTACT": "ROUTE KEPT · ON GUARD",
	"tag_DRONE": "ROUTE KEPT · WAITING FOR DRONE",
	"tag_SCOUT_STOP": "ROUTE KEPT · STOPPED ON CONTACT",
	"tag_photo": "ROUTE KEPT · PHOTO UNDER WAY",
	"tag_depth": "ROUTE KEPT · CHANGING DEPTH",
	"tag_stop": "ROUTE KEPT · ALL STOP",
	"tag_task": "ROUTE KEPT · ON A TASK",
	# WP-106: sentences of a tip that say time is stopped, and what they read as once time runs (onboarding_hints.gd).
	"hint_run_swaps": {"sweep": ["Time is stopped. ", ""], "warning": [", so time is stopped", ""], "move": ["Time starts stopped. Tap ▶ RUN (top left) to let it run, and || PAUSE", "Tap || PAUSE (top left)"]},
	"hint_stopped":"GOT IT only closes this note. Time stays stopped until you tap ▶ RUN.",
	# A toggle segment names the action a tap performs (first line) and the state it is in now (small second line).
	"silent_off": "GO SILENT",
	"silent_on": "GO LOUD",
	"silent_state_off": "running loud",
	"silent_state_on": "silent is on",
	"silent_off_line": "%s\nslower (%d m/s) · seen from %d m",
	"silent_on_line": "%s\nfull speed (%d m/s) · seen from %d m",
	"profile_low": "GO LOW PROFILE",
	"profile_open": "GO OPEN",
	"profile_state_low": "low profile is on",
	"profile_state_open": "open profile",
	"profile_low_line": "%s\nSirens see this drone from %d m, not %d m\nIts speed is unchanged",
	"profile_open_line": "%s\nSirens see this drone from %d m, not %d m\nIts speed is unchanged",
	"confirm": "Tap again to confirm",
	# The target chooser's centre question: only craft to pick from, or craft and objects mixed.
	"choose_craft": "WHICH CRAFT?",
	"choose_any": "CRAFT OR OBJECT?",
	"depth_menu": "DEPTH AND\nSONAR",
	"all_stop": "ALL STOP",
	"audio_log_empty": "No sounds logged yet",
	"rock_route": "This route crosses charted rock. Tap the marker again to send it anyway, or tap open water.",
	# WP-117: the card's own sentence names its buttons (the planner's sentence above is for a second tap on the marker),
	# and the status strip says only that the card is waiting, so the card's sentence is not printed twice.
	"rock_strip": "Marker set across charted rock · SEND ANYWAY or CANCEL",
	# WP-69: a tap on open water that orders nothing says what a water tap needs (or that the dive is over).
	"tap_idle": "Select a craft first: tap Quietus or a drone, or use FLEET",
	"tap_over": "The dive is over: no craft can be ordered",
	"send_anyway": "SEND ANYWAY",
	"queued_taps": "%s · next taps add points · TAPS on the ROUTE page switches back",
	"ping": "PING SONAR\nuses %s reserve",
	"ping_free": "PING SONAR\nuses no reserve",
	"ping_caption": "Sirens hear every ping",
	"ping_arc": "PING ARC\n%s",	# two lines: one long line ran past the wheel's rim
	"ping_power": "PING POWER\n%s",
	"arc_all": "ALL",	# "ALL ROUND" wrapped to a third line and ran past the wheel's rim
	"arc_forward": "AHEAD",
	"history": "PAST PINGS",
	"history_heading": "PAST PINGS · %s",
	"paused_notice": "PAUSED: a Siren has noticed you",
	"paused_lock": "PAUSED: a Siren is locking on",
	"paused_route": "PAUSED: choose what to do with the route",
	"held_menu": "HELD: time runs again when you close this menu",
	"held_route": "HELD: time runs again once you answer the route prompt",
	"paused_route_end": "PAUSED: %s finished its route",
	"paused_blocked": "PAUSED: rock blocks %s's route",
	"route_end": "%s has stopped: its route is finished.",
	# A craft with a route that is not getting anywhere (presentation/no_progress.gd). The first line of each pair is the
	# pause reason on the status line; the second is the status message set when the dive pauses.
	"paused_stuck": "PAUSED: %s is not getting anywhere on its route",
	"stuck": "%s · no progress · replot",
	"paused_stuck_current": "PAUSED: the current holds %s back",
	"stuck_current": "%s · no progress · the current is stronger than its drive · replot or wait",
	"paused_stuck_band": "PAUSED: %s cannot pass here at this depth · %s is open",
	"stuck_band": "%s · no progress · %s is open here · replot or change depth",
	"paused_blocked_band": "PAUSED: rock blocks %s's route at this depth · %s is open",
	"blocked_band": "%s · rock blocks this leg at this depth · %s is open · replot or change depth",
	"paused_stuck_rock": "PAUSED: rock blocks %s's route",
	"stuck_rock": "%s · no progress · rock blocks this leg · replot",
	# The status line once a message has gone stale (presentation/strip_message.gd).
	"under_way": "%s · under way to point %d · %dm",
	"at_rest": "%s · at rest · no route set",
	# The move buttons on the lock card: what each move does about this lock (presentation/lock_move_timing.gd).
	"move_now": "works at once",
	"move_after": "works in %.1fs",
	"move_close": "Siren inside %dm",
	# WP-137 (Pat, 15 Nov 2026): a decoy dropped within a locking Siren's hearing breaks the lock; the button's reason line.
	"move_decoy": "draws it off the lock",
	# WP-121 (Pat, 14 Nov 2026): the captions for the rock warning sounds (rock_warning.gd).
	"rock_ahead": "ROCK AHEAD",
	"ramming": "RAMMING SPEED",
	# WP-131: tip sentences that name a state that does not hold (onboarding_hints.gd): [old, new] pairs.
	"hint_silent_swaps": [["Slow down or tap GO SILENT", "Slow down (you are already silent)"], ["slow down or GO SILENT.", "slow down (you are already silent)."]],
	"hint_no_rock_swaps": [[", and keep rock between you and it.", ". No rock is near to hide behind."]],
	# WP-137: the message when a decoy breaks a lock: "S2 LOCK BROKEN · drawn to the decoy" (several: "S1, S2 LOCK BROKEN ...").
	"lock_broken": "%s LOCK BROKEN · drawn to the decoy",
	# WP-127: one predictable tap. With a route set a water tap adds a point; the tap mode is printed beside the craft.
	"tap_mode_set": "TAP WATER · SET ROUTE",
	"tap_mode_add": "TAP WATER · ADD POINT",
	"tap_mode_deploy": "TAP WATER · DEPLOY",
	"rock_bar": "This leg crosses charted rock",
	"replace_route": "REPLACE\nROUTE",
	"replace_none": "%s has no route to replace · tap water to set one",
	"replace_done": "%s · route cleared · tap water to plot a new one · UNDO restores it",
	# WP-128: the standing NEXT line (presentation/next_step.gd): one imperative sentence from the dive's own objective and recovery state.
	"next_search_unknown": "NEXT: search the dashed area, then photograph the source",
	"next_search": "NEXT: search the dashed area for %s",
	"next_photo_reach": "NEXT: photograph %s (in reach of %s)",
	"next_photo_far": "NEXT: photograph %s: bring a craft within %d m",
	"next_listen_reach": "NEXT: listen at %s (in reach of %s)",
	"next_listen_far": "NEXT: listen at %s: bring a craft within %d m",
	"next_transmit": "NEXT: transmit from %s: settle under %d m/s inside the sector",
	"next_open_job": "NEXT: finish the open job on the chart, then return to extraction",
	"next_carrier": "NEXT: bring %s into the %s (%d m): it carries %s",
	"next_salvage": "NEXT: salvage %s with a craft in range, then bring it to the %s",
	"next_material": "NEXT: bring the material carrier into the %s (%d m), settled in MIDDLE",
	"next_ring": "NEXT: bring Quietus into the %s (%d m)",
	"next_ring_name": "EXTRACTION",
	"next_rise": "NEXT: rise to %s to recover",
	"next_sink": "NEXT: sink to %s to recover",
	"next_settle": "NEXT: let the depth change finish in %s to recover",
	"next_slow": "NEXT: slow Quietus under %d m/s to recover",
	"opening_prefix": "Drones aboard.",	# simulation.gd's launch message; the strip leaves it out while a NEXT line exists
	"next_keep": ["Depth change", "Investigation heard", "RAW BUFFER aboard"],	# situational standing lines that stay in place of NEXT
	# WP-149: the header air chip (air_chip.gd): "AIR" over the time left; "AIR LOW" under a quarter of a tank.
	"air": "AIR",
	"air_low": "AIR LOW",
	"air_briefing": "AIR %d:%02d, shown at the top all dive",
	# WP-152: one debrief line when decoys broke locks this dive (loss_summary.decoy_line).
	"decoy_broke": "Decoy broke %d lock",
	"decoy_broke_many": "Decoy broke %d locks",
	# WP-153: the strip while a decoy is armed from a lock card with a marked drop point (the card says the same).
	"decoy_strip_marker": "DECOY · TAP THE MARKED POINT · TAP CANCEL",
}
# WP-153: a no-break space between a number and its metre unit (240 m, 5 m/s) so a lone "m" never starts the next strip line.
static func glue_units(text:String)->String:
	var re:=RegEx.new();re.compile("(\\d) (m/s|m)\\b")
	return re.sub(text,"$1 $2",true)
static func lock_broken(siren_ids:Array)->String:
	return TEXT.lock_broken%", ".join(siren_ids.map(func(id):return preload("res://src/simulation/siren_tag.gd").tag(int(id))))
# The status line for the route dialog's switch ("New points: the craft stops at each one." / "... keeps
# moving through them.") is set where the simulation answers the waypoint_mode order, orders/route_orders.gd.
# tactical_aids.gd words its own automatic pause "AUTO PAUSE: <reason>" in the status message.
const AUTO_PAUSE_PREFIX="AUTO PAUSE: "
const AUTO_PAUSE_REASONS={"FIRST NOTICE": "paused_notice", "LOCK WARNING": "paused_lock"}
# The reason keys of presentation/auto_pause.gd, and the line each one shows. A %s takes the craft's name.
const AUTO_PAUSE_KEYS={"notice": "paused_notice", "lock": "paused_lock", "route_end": "paused_route_end", "blocked": "paused_blocked", "blocked_band": "paused_blocked_band", "stuck": "paused_stuck", "stuck_current": "paused_stuck_current", "stuck_band": "paused_stuck_band", "stuck_rock": "paused_stuck_rock"}
# A route message ends with one of these (route_orders.gd): a craft that has since stopped no longer "set route".
const ROUTE_MESSAGE_ENDINGS=["set route", "replaced route", "queued route"]
# Seconds of dive time a status message counts as new. Older, a craft that is under way says what it is doing now.
const MESSAGE_FRESH_SECONDS=4.0
# Seconds of dive time the "route finished" line stays on the status line.
const ROUTE_END_SECONDS=8.0
# A craft counts as moving above this speed (m/s) when its route runs out.
const MOVING_SPEED=2.0
# WP-118: seconds of running dive time a launched craft stands with no orders before the strip says so (the dive's first
# seconds, a pause, and a fresh order all start the count again).
const IDLE_SECONDS=5.0
static func sights()->Dictionary:
	return {"silent": Pricing.SIREN_SIGHT_SILENT, "open": Pricing.SIREN_SIGHT}
# Quietus silent and cruise speed for the fitted hull and drive, as the simulation computes them.
static func speeds(sim)->Dictionary:
	var fitted:Dictionary=sim.mission.get("launch_equipment",{})
	return {"silent": CraftUpgrades.frame_speed(fitted,0,RuleTable.CRAFT_SPEED.silent), "cruise": CraftUpgrades.cruise_speed(fitted)}

# The pause plate (WP-94): what a tap does first, then the state, then the oxygen reading when it fits.
# paused: the player or an automatic pause stopped the dive (it stays stopped until resumed). held: an open menu
# or the route prompt holds time, which runs again when it closes; the plate says so, not PAUSED.
static func plate_state(paused:bool,held:bool=false)->String:
	return TEXT.paused if paused else TEXT.held if held else TEXT.running
# What a tap on the plate does now (WP-103): "answer" a pending route prompt (the marker stays, time stays held),
# "close" an open menu that holds time (the tap closes it and time runs), "run" a stopped dive, "pause" a running one.
# Without a host (tests of the words alone) only the dive's own state is known.
static func plate_kind(sim,host=null)->String:
	# A marker waiting counts at once, before the next refresh shows its panel, so a tap in that frame cannot drop it.
	if host!=null and (host._order_dialog_open() or (host.mission_hud!=null and host.mission_hud.guard!=null and not host.mission_hud.guard.pending.is_empty())):return "answer"
	if sim.paused:return "run"
	if host!=null and host._time_held():return "close"
	return "pause"
static func plate_action(sim,host=null)->String:
	match plate_kind(sim,host):
		"answer":return TEXT.act_answer
		"close":return TEXT.act_close
		"run":return TEXT.act_run
	return TEXT.act_pause
# The plate without the oxygen reading: the action a tap performs over the state of the dive.
static func plate_text(sim,held:bool,host=null)->String:
	return plate_action(sim,host)+"\n"+plate_state(sim.paused,held)
# The lock card's consequence line for the craft a lock is on (simulation.gd: Quietus is vaporized, a drone is lost).
static func lock_lands(sim,craft:int)->String:
	var name:String=str(sim.units[craft].get("name","CRAFT")).to_upper()
	return (TEXT.lock_lands_quietus if craft==0 else TEXT.lock_lands_drone)%name

# The segments whose tap costs something that cannot be read before it lands: the first tap arms the segment and
# shows its cost in the wheel's centre, the second tap on the same segment performs it. Keys are the segments'
# "action" meta. Segments that only open a page, or are harmless, stay one tap.
const TWO_TAP=["silent","all_stop"]
static func needs_confirm(key:String,sim)->bool:
	if key=="all_stop":
		var u:Dictionary=sim.units[0]
		return not AllStop.stopped(u) and not AllStop.restarting(u)
	return key in TWO_TAP

# A toggle segment: the name says what the tap does, a small second line says how things stand now.
static func silent_label(sim)->String:
	if sim.selected>0:
		return TEXT.profile_low if not sim.units[sim.selected].silent else TEXT.profile_open
	return TEXT.silent_on if sim.units[0].silent else TEXT.silent_off
static func silent_state(sim)->String:
	# WP-156: the second line is the consequence of the tap (was "low profile is on" / "open profile" / "silent is on" / "running loud").
	var sight:=sights()
	if sim.selected>0:
		return ORDER_NOTES.drone_low_on%roundi(sight.open) if sim.units[sim.selected].silent else ORDER_NOTES.drone_low_off%roundi(sight.silent)
	return ORDER_NOTES.quietus_silent_on%roundi(sight.open) if sim.units[0].silent else ORDER_NOTES.quietus_silent_off%roundi(sight.silent)
# The small second line of a segment, by its action key. Empty for a segment that has none.
static func state_line(key:String,sim)->String:
	if key=="program" or key=="route_menu":return ORDER_NOTES[key]  # WP-156: PLAN ROUTE and ROUTE tell themselves apart
	return silent_state(sim) if key=="silent" else ""
# The cost lines shown in the wheel's centre for a segment, by its action key: while a finger is on it, and once
# a two-tap segment is armed. Empty for a segment without a cost to show.
static func cost_lines(key:String,sim)->Array:
	if key=="silent":return silent_caption(sim)
	if key=="all_stop" and needs_confirm(key,sim):
		return [TEXT.all_stop,AllStop.label(sim).get_slice("\n",1)]
	return []
static func silent_caption(sim)->Array:
	var sight:=sights()
	if sim.selected>0:
		if sim.units[sim.selected].silent:return (TEXT.profile_open_line%[TEXT.profile_open,roundi(sight.open),roundi(sight.silent)]).split("\n")
		return (TEXT.profile_low_line%[TEXT.profile_low,roundi(sight.silent),roundi(sight.open)]).split("\n")
	var speed:=speeds(sim)
	if sim.units[0].silent:return (TEXT.silent_on_line%[TEXT.silent_on,roundi(speed.cruise),roundi(sight.open)]).split("\n")
	return (TEXT.silent_off_line%[TEXT.silent_off,roundi(speed.silent),roundi(sight.silent)]).split("\n")

# The question in the wheel's centre on the target chooser.
static func choose_prompt(choices:Array)->String:
	return TEXT.choose_craft if not choices.is_empty() and choices.all(func(c):return c.get("kind","")=="craft") else TEXT.choose_any

# Sonar page segments.
static func ping_label(cost:float)->String:
	return TEXT.ping%String.num(snappedf(cost,0.01)) if cost>0.0 else TEXT.ping_free
static func arc_label(sector:String)->String:
	return TEXT.ping_arc%(TEXT.arc_all if sector=="all" else TEXT.arc_forward)
static func power_label(power:String)->String:
	return TEXT.ping_power%power.to_upper()

# The status panel's row for a route point, in plain words: "Point 1: same speed, stops here". A drone names its
# drive, Quietus its speed; the key is the route program's mode ("inherit", "silent", "cruise").
const POINT_ROW="Point %d: %s, %s"
const POINT_MODES={"inherit": "same speed", "silent": "silent running", "cruise": "cruise speed"}
const POINT_MODES_DRONE={"inherit": "same drive", "silent": "quiet drive", "cruise": "transit drive"}
const POINT_STOPS={true: "stops here", false: "passes through"}
static func point_row(number:int,goal:Dictionary,drone:bool)->String:
	var modes:Dictionary=POINT_MODES_DRONE if drone else POINT_MODES
	return POINT_ROW%[number,modes.get(str(goal.get("mode","inherit")),"same speed"),POINT_STOPS[bool(goal.get("stop",true))]]

# WP-110: the ROUTE PROGRAM screen's words (route_program_panel.gd, route_program_preview.gd). One word for "keep the
# current setting": SAME, on the button, in the rows and in the help line (the route's own mode key is "inherit").
const PROGRAM_MODES={"inherit": "SAME", "silent": "SILENT", "cruise": "CRUISE"}
const PROGRAM_MODES_DRONE={"inherit": "SAME", "silent": "QUIET42", "cruise": "TRANSIT96"}
const PROGRAM_HELP="TO: how %s travels to this point; SAME keeps its current setting.\nAT: STOP halts there first; PASS carries straight on."
# Number, speed, stop, then how far and which way the point lies from the point before it (the craft for the first).
const PROGRAM_ROW="%d · %s · %s · %d m, bearing %03d°"
const PROGRAM_PAN="DRAG TO PAN"
const PROGRAM_ROCK="ROCK"
static func program_mode(mode:String,drone:bool)->String:
	return (PROGRAM_MODES_DRONE if drone else PROGRAM_MODES).get(mode,"SAME")

# extra is the second name some lines carry (the depth that is open).
static func auto_pause_text(key:String,craft:String,extra:String="")->String:
	var line:String=TEXT[AUTO_PAUSE_KEYS[key]]
	if line.count("%s")>=2:return line%[craft,extra]
	return line%craft if "%s" in line else line
# The status message a stall sets when it pauses the dive; "" for a rock hold, whose message the hold already set.
static func stall_message(key:String,craft:String,extra:String="")->String:
	if not TEXT.has(key):return ""
	var line:String=TEXT[key]
	return line%[craft,extra] if line.count("%s")>=2 else line%craft
static func is_route_message(message:String)->bool:
	return ROUTE_MESSAGE_ENDINGS.any(func(ending):return message.ends_with(ending))
# Why the dive is held, when something other than the player held it. Empty when the player paused,
# or when the held state already shows a card that states its reason.
static func pause_reason(host)->String:
	var sim=host.sim
	if host._order_dialog_open():return TEXT.paused_route if sim.paused else TEXT.held_route
	if not sim.paused:return TEXT.held_menu if host._time_held() else ""
	var automatic:String=host.tactical_aids.auto_pause.line(sim)
	# WP-153: "a Siren is locking on" holds only while a lock is counting down (a decoy that broke the last lock ends it).
	var locks:bool=host.lock_warning!=null and not host.lock_warning.rows.is_empty()
	if automatic==TEXT.paused_lock and not locks:return ""
	if not automatic.is_empty():return automatic
	for key in AUTO_PAUSE_REASONS:
		if sim.message==AUTO_PAUSE_PREFIX+key:
			if key=="LOCK WARNING" and not locks:return ""
			return TEXT[AUTO_PAUSE_REASONS[key]]
	return ""

# WP-120: the time speed control beside the pause plate (time_speed.gd decides when it may be used).
const SPEED={
	"label": "SPEED\n%sx",
	"hunting": "1x · SIREN CONTACT", # WP-135: was "1x · a Siren is hunting"; names the contact, not the Hunt meter
	"refused": "2x and 4x stay off while a Siren has contact with you.", # WP-135: the tap explains
}
static func speed_text(speed:float,hunting:bool)->String:
	if hunting and speed<=1.0:return SPEED.hunting
	return SPEED.label%(str(roundi(speed)) if is_equal_approx(speed,roundf(speed)) else "%.2f"%speed)

# WP-156: the craft order panel's second lines say what a tap does, not how things stand (critic, 15 Nov).
# Silent figures are the same sight constants the centre caption shows (sights()).
const ORDER_NOTES={
	"quietus_silent_on": "faster · seen from %d m",   # button reads GO LOUD
	"quietus_silent_off": "slower · seen from %d m",  # button reads GO SILENT
	"drone_low_on": "seen from %d m",                 # button reads GO OPEN
	"drone_low_off": "seen from %d m",                # button reads GO LOW PROFILE
	"program": "draw waypoints · pauses",
	"route_menu": "hold · stop · replace",
	# Camera lines of the wheel centre and the dock: each fact is labelled.
	"target": "TARGET: %s",
	"away": "%dm away",
	"reach": "CAMERA REACH %dm",
}
