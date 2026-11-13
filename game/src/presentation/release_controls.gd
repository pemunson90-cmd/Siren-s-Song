extends RefCounted
# 127 release controls (Pat 2026-10-30): one-press travel shortcuts "are fine
# for testing but they will absolutely have to be stripped for release play".
# Every presentation call that issues a "route" or "emergency" order carries a
# TRAVEL:<key> tag on its line and a row here; release_controls_tests greps
# game/src for untagged calls. Dev-only rows exist only with the existing dev
# state on (src/debug/dev_state.gd). Release play moves by placed legs, depth,
# in-reach work and RECALL. Dev-only rows also need a debug build (see
# debug_build below). Revert: make allowed() return true.
const DevState=preload("res://src/debug/dev_state.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const WARNING=Color("e0634f")
const TRAVEL_SHORTCUTS={
 "water_leg":{"name":"Tap water: place a straight leg","dev_only":false},
 "water_leg_confirm":{"name":"Marker REPLACE ROUTE / ADD TO ROUTE","dev_only":false},
 "route_here":{"name":"ROUTE HERE / PLOT ROUTE on object pages","dev_only":true},
 "glass_route":{"name":"ROUTE TO REACH WORK","dev_only":true},
 "choir_route":{"name":"ROUTE TO LOCAL WORK","dev_only":true},
 "withdraw_home":{"name":"ROUTE page WITHDRAW / EXTRACT autopilot","dev_only":true},
 "recovery_chooser":{"name":"Recovery mouth chooser autopilot","dev_only":true},
 "module_return":{"name":"Departure sheet: send carrier to the mouth","dev_only":true},
}

# Build seam (WP-06, survey S-02). A DEV mark travels inside saved and exported
# profiles, so the mark alone would re-enable the dev-only rows when such a
# profile is imported into a release build. The shortcuts therefore need a
# debug build as well as the mark. The mark itself (DevState.marked) and its
# record exclusions are unchanged in every build. null follows the running
# build; release_build_gate_tests sets false to simulate a release build.
static var build_override=null

static func debug_build()->bool:
 return OS.is_debug_build() if build_override==null else build_override

# Internal SS_ diagnostics (survey S-04): printed only in debug builds, with the
# same text print() gives for the same arguments. Android smoke scripts read
# these from debug packages.
static func debug_print(parts:Array)->void:
 if not debug_build():return
 var text=""
 for part in parts:text+=str(part)
 print(text)

static func dev(host)->bool:
 return host!=null and debug_build() and DevState.marked(host)

static func allowed(host,key:String)->bool:
 return not TRAVEL_SHORTCUTS[key].dev_only or dev(host)

# HUD controls that issue a one-press travel order.
static func shortcut_controls(hud)->Dictionary:
 return {"route_here":hud.extra.route_here,"glass_route":hud.extra.glass_route,"choir_route":hud.extra.choir_route,"withdraw_home":hud.host.order_buttons.home}

# Per-page control set: strip dev-only travel, add RECALL to the route page and
# the depth pair to the per-operation work pages.
static func filter(hud,controls:Array)->Array:
 var result=controls.duplicate()
 if not dev(hud.host):
  for button in shortcut_controls(hud).values():result.erase(button)
 if hud.page=="route":
  var at=result.find(hud.host.order_buttons.home)
  result.insert(at+1 if at>=0 else mini(3,result.size()),hud.extra.recall)
 if hud.page in ["glass","choir"]:
  var at=result.find(hud.extra.inspect)
  if at<0:at=result.size()
  result.insert(at,hud.extra.depth_down);result.insert(at,hud.extra.depth_up)
 if hud.page=="craft":
  # WP-35: DEPLOY joins the main page while a drone is aboard; RECALL joins a deployed drone's page, and RECALL ALL
  # joins Quietus's only while a drone is in the water and none is aboard. A ninth segment would send the wheel into
  # the crowded-wheel re-fit (BACK leaves the centre and can leave the screen), so the main page stays at eight:
  # PLAN ROUTE, which the ROUTE page also lists, gives its place to the added segment.
  # WP-52: the added segment takes PLAN ROUTE's own place in the ring, so DEPLOY, RECALL and PLAN ROUTE each always
  # sit at the same angle and every other segment keeps its angle whether or not a drone is aboard.
  var at=result.find(hud.host.order_buttons.program)
  var bay=bay_control(hud)
  if bay!=null and at>=0:result[at]=bay
 return result

# The segment that shares PLAN ROUTE's place on the main page: DEPLOY while a drone can be put in the water,
# else RECALL while one can be called back, else none.
static func bay_control(hud):
 if deploy_target(hud.host.sim)>=0:return hud.extra.deploy
 var sim=hud.host.sim
 if (sim.units[sim.selected].alive if sim.selected>0 else in_water(sim)>0):return hud.extra.recall
 return null
# The drone DEPLOY would put in the water: Quietus offers the next one aboard, an aboard drone offers itself.
static func deploy_target(sim)->int:
 if sim.selected>0:return sim.selected if sim.DroneBay.aboard(sim.units[sim.selected]) else -1
 for id in [1,2]:
  if sim.DroneBay.aboard(sim.units[id]):return id
 return -1
static func in_water(sim)->int:
 var count=0
 for id in [1,2]:
  if sim.units[id].alive and not sim.DroneBay.aboard(sim.units[id]):count+=1
 return count

static func activate_deploy(hud)->void:
 var id=deploy_target(hud.host.sim)
 if id>0:hud.host._order("deploy",{"unit":id})

static func refresh(hud)->void:
 var sim=hud.host.sim;var b=hud.extra.recall
 var next=deploy_target(sim)
 hud.extra.deploy.text="DEPLOY\n"+(sim.units[next].name if next>0 else "DRONE")
 if sim.selected==0:
  b.text="RECALL\nALL"
  var reasons=[];var ready=0
  for id in [1,2]:
   if not sim.units[id].alive:continue
   var plan=HandPilot.recall_plan(sim,id)
   if plan.has("reason"):reasons.append(plan.reason)
   else:ready+=1
  b.disabled=not sim.units[0].alive or ready==0
  b.tooltip_text=("Quietus lost" if not sim.units[0].alive else "No live drone" if reasons.is_empty() else " / ".join(reasons)) if b.disabled else ""
 else:
  b.text="RECALL"
  var plan=HandPilot.recall_plan(sim,sim.selected)
  b.disabled=plan.has("reason");b.tooltip_text=plan.get("reason","")

static func activate_recall(hud)->void:
 hud.host._order("recall_all" if hud.host.sim.selected==0 else "recall")

# Only a leg across charted rock is a warning. Another craft on the leg ("Passes Quietus") is a neutral note.
static func is_warning(w:Dictionary)->bool:
 return w.reason==HandPilot.ROCK_REASON

# Red over each leg that crosses measured rock; a leg that only passes another craft is drawn in the note colour.
# Called in world transform.
static func draw_legs(view,sim,unit:int,scale:float)->void:
 for w in HandPilot.warnings(sim,unit):
  var base=WARNING if is_warning(w) else UiStyle.NOTE_COLOR
  var color=base if unit==sim.selected else Color(base,.4)
  view.draw_line(w.from,w.to,color,3./maxf(scale,.01))

# Short reason beside the first warned leg of the selected craft (a rock warning before a neutral note). Screen space.
static func draw_reason(view,sim)->void:
 var warned=HandPilot.warnings(sim,sim.selected)
 if warned.is_empty():return
 var w=warned[0]
 for candidate in warned:
  if is_warning(candidate):w=candidate;break
 var at=view.chart_camera.to_screen((w.from+w.to)*.5)+Vector2(12,-10)
 var font=ThemeDB.fallback_font;var size=view.feedback_font_size
 var text=w.reason.to_upper()
 var width=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
 view.draw_rect(Rect2(at-Vector2(3,size),Vector2(width+6,size+5)),Color(0.12,0.025,0.015,0.94))
 view.draw_string(font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,WARNING if is_warning(w) else UiStyle.NOTE_COLOR)

const CONTROLS_TEXT:="MOVE: pause, then tap water to place a straight leg. QUEUE adds legs. The craft does not steer around rock: a red leg crosses charted rock and can crash.\nDEPTH: craft → DEPTH, or the depth pair on a work page.\nWORK: craft → REACH WORK lists the jobs in reach here; a grey job says why.\nDEPLOY: Quietus or an aboard drone → DEPLOY puts the drone in the water beside Quietus. A deployed drone stays out.\nRECALL: drone → RECALL (also under ROUTE) brings it back to stand beside Quietus by straight legs. Quietus has RECALL ALL."
