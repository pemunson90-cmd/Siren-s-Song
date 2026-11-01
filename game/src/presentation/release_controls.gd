extends RefCounted
# 127 release controls (Pat 2026-10-30): one-press travel shortcuts "are fine
# for testing but they will absolutely have to be stripped for release play".
# Every presentation call that issues a "route" or "emergency" order carries a
# TRAVEL:<key> tag on its line and a row here; release_controls_tests greps
# game/src for untagged calls. Dev-only rows exist only with the existing dev
# state on (src/debug/dev_state.gd). Release play moves by placed legs, depth,
# in-reach work and RECALL. Revert: make allowed() return true.
const DevState=preload("res://src/debug/dev_state.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
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

static func dev(host)->bool:
 return host!=null and DevState.marked(host)

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
 return result

static func refresh(hud)->void:
 var sim=hud.host.sim;var b=hud.extra.recall
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

# Red over each leg that crosses measured rock. Called in world transform.
static func draw_legs(view,sim,unit:int,scale:float)->void:
 for w in HandPilot.warnings(sim,unit):
  var color=WARNING if unit==sim.selected else Color(WARNING,.4)
  view.draw_line(w.from,w.to,color,3./maxf(scale,.01))

# Short reason beside the first warned leg of the selected craft. Screen space.
static func draw_reason(view,sim)->void:
 var warned=HandPilot.warnings(sim,sim.selected)
 if warned.is_empty():return
 var w=warned[0];var at=view.chart_camera.to_screen((w.from+w.to)*.5)+Vector2(12,-10)
 var font=ThemeDB.fallback_font;var size=view.feedback_font_size
 var text=w.reason.to_upper()
 var width=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
 view.draw_rect(Rect2(at-Vector2(3,size),Vector2(width+6,size+5)),Color(0.12,0.025,0.015,0.94))
 view.draw_string(font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,WARNING)

const CONTROLS_TEXT:="MOVE: pause, then tap water to place a straight leg. QUEUE adds legs. The craft does not steer around rock: a red leg crosses charted rock and can crash.\nDEPTH: craft → DEPTH, or the depth pair on a work page.\nWORK: craft → REACH WORK lists the jobs in reach here; a grey job says why.\nRECALL: drone → ROUTE → RECALL brings it back to Quietus by straight legs. Quietus has RECALL ALL."
