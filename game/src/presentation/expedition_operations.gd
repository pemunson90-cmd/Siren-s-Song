extends RefCounted
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Missions=preload("res://src/campaign/missions.gd")
static func operations(main)->void:
 var available=Campaign.available(main.completed,main.expedition)
 if available.is_empty():return
 main._menu_text("BEYOND THE WARNING / EXPEDITIONS",22)
 for id in available:
  var mission=Missions.make(id,preload("res://src/campaign/campaign_consequences.gd").context(main.expedition))
  if mission.id!=id:continue
  var status="RECOVERED" if id in main.expedition.get("completed",[]) else "AVAILABLE"
  main._button(main.panel_box,"%s · %s"%[mission.title,status],func():main._briefing(id),"expedition%d"%id)
static func briefing(main,index:int)->bool:
 if index<6:return false
 if index in preload("res://src/campaign/final_pair_operations.gd").IDS:
  main._menu_text("Photograph the core mark in MIDDLE and recover Quietus. The second photograph is optional.",17)
  return true
 if index>=22:
  main._menu_text("IRON CHOIR / Craft → CHOIR WORK or tap acquired machinery and physical loads. Start voyages deliberately, observe actual arrival, tow locally and LAND people at the dock. All machinery/cargo follows its working craft and real depth. Bare Quietus can complete every core job sequentially without finite tools; fitted drones buy alternate narrow load routes.",17)
  main._menu_text(preload("res://src/campaign/glass_research.gd").detail(main.expedition),17)
  return true
 if index>=14:
  main._menu_text("GLASS REACH / Local craft → REACH WORK opens machinery, material and transfer controls. Status gives exact local distance/depth/readiness. The southern mouth also permits explicit incomplete withdrawal. First recovered Lantern Lock choice shapes Last Boat Out; failed dives and replays do not replace it.",17)
  main._menu_text(preload("res://src/campaign/glass_research.gd").detail(main.expedition),17)
  return true
 if index==10:main._menu_text("PLANT ORDERS\nCONNECT a settled craft at WEST for quiet shore power, or START BACKUP once with a 900m / 6s audible start. Quietus or a fitted sampler selects the output at EAST. OPEN SERVICE opens the physical crosslink; NORTH MAST leaves its opening unchanged. Then use SEND WARNING separately. Service requires a local receipt; mast telemetry proves transmission with external reception unknown. Recover Quietus by either mouth after commissioning.",17)
 elif index==8:main._menu_text("WATCH ORDERS\nTap a measured bunker section or the charted bunker alarm for its local warning action and exact readiness. Watch the occupied windows, then hear the returning watch call. No camera hold is required.",17)
 else:main._menu_text("OBSERVATION ORDERS\nArrival arcs show where a carrier reached that receiver; sound may bend around basalt. They are not exact target bearings. Close clear passive reception or local RECON earns a precise source mark. Pause gives planning time, never new passive samples. Named recovery corridors show which interpretations you have confirmed.",17)
 if index in [9,10]:main._menu_text("RECOVERED THREAD / Your first successful recovery from Wake Crossing or Warning Chain selects the history carried into Confluence. The other dive remains replayable; replay does not rewrite a launched dive or the committed thread. Failed dives retain field notes, never the new fitting or continuation.",17)
 if index==6:main._menu_text("Choose a physical exit with Quietus after its carrier is identified. Investigating both retains both facts; your exit selects the continuation. The southern basin permits incomplete withdrawal after departure, without completing an expedition route.",17)
 return true
static func debrief(main)->bool:
 var mission=main.sim.mission
 if mission.id not in preload("res://src/campaign/operation_catalog.gd").campaign_ids():return false
 main._retain_evidence()
 var previous=main.expedition.duplicate(true)
 main.expedition=Campaign.recover(main.expedition,mission)
 if main.sim.outcome=="won" and mission.id==31 and not preload("res://src/campaign/endings_photo.gd").resolve(main.expedition,main.photo_intel).is_empty():
  main._show_ending();return true
 if main.sim.outcome=="won" and mission.id in [12,13] and not preload("res://src/campaign/endings.gd").resolve(main.expedition).is_empty():
  main._show_ending();return true
 if main.sim.outcome=="won" and mission.get("recovered",false) and mission.id==11 and preload("res://src/presentation/confluence_resolution.gd").present(main):
  main._save_archive();return true
 if main.sim.outcome=="won" and mission.get("recovered",false):
  main._menu_text("EXPEDITION RECOVERED",32)
  preload("res://src/presentation/witness_evacuation_view.gd").arrival(main)
  preload("res://src/presentation/warning_recipient_view.gd").arrival(main)
  var consequence=preload("res://src/presentation/consequence_lines.gd").line(mission)
  if not consequence.is_empty():main._menu_text(consequence,20)
  main._menu_text(mission.record,22)
  var plant=preload("res://src/presentation/warning_chain_view.gd").debrief_text(main.sim)
  if not plant.is_empty():main._menu_text(plant,19)
  preload("res://src/presentation/module_recovery_view.gd").debrief(main)
  var grade=preload("res://src/simulation/recon_consequences.gd").grade(mission.get("objectives",[]))
  if grade.photos>0:main._menu_text("INTEL PHOTO GRADE %s · %d %s · average %d%%, sharpest %d%%"%[grade.grade,grade.photos,"record" if grade.photos==1 else "records",roundi(grade.quality*100),roundi(grade.best*100)],20)
  if mission.id==6:
   main._menu_text("PHYSICAL ROUTE / %s\nRecovered carrier facts: %s"%[mission.chosen_route.to_upper(),", ".join(mission.expedition_facts.keys())],17)
  for item in main.expedition.get("entitlements",[]):
   if item not in previous.get("entitlements",[]):main._menu_text("RECOVERED FITTING · %s\nChoose BARE or fit it before the next launch."%{"quietus_correlator":"CADENCE CORRELATOR","drone_sampler":"FIELD SAMPLER"}.get(item,item),19)
  var thread=main.expedition.get("selected_thread","")
  if mission.id in [9,10] and not thread.is_empty():main._menu_text("COMMITTED THREAD · %s\nThis recovered history carries forward. Both onward dives remain replayable."%thread.to_upper(),17)
  for next in Campaign.continuations(main.expedition,mission.id):
   var next_mission=Missions.make(next,preload("res://src/campaign/campaign_consequences.gd").context(main.expedition))
   if next_mission.id!=next:continue
   main._button(main.panel_box,"CONTINUE / %s"%next_mission.title,func():main._briefing(next),"next_expedition")
  main._menu_text("Dive time %02d:%02d / Hull %d%%"%[int(main.sim.elapsed)/60,int(main.sim.elapsed)%60,int(main.sim.hull)],17)
 else:
  main._menu_text("INCOMPLETE WITHDRAWAL" if main.sim.outcome=="withdrawn" else "EXPEDITION LOST",30)
  preload("res://src/presentation/witness_evacuation_view.gd").arrival(main)
  preload("res://src/presentation/warning_recipient_view.gd").arrival(main)
  main._menu_text(main.sim.message,20)
  main._menu_text(preload("res://src/presentation/loss_summary.gd").line(main.sim),17)
  main._menu_text("Field observations remain in the archive. This dive grants no new recovered fitting, continuation or committed history.",17)
  preload("res://src/presentation/module_recovery_view.gd").debrief(main)
 if not main.recovered_evidence.is_empty():main._button(main.panel_box,"REVIEW FIELD RECORDS",func():main._evidence_gallery(0),"evidence")
 main._button(main.panel_box,"RETRY EXPEDITION",func():main._briefing(mission.id),"retry")
 main._button(main.panel_box,"OPERATIONS ARCHIVE",main._show_campaign,"back")
 if mission.id>=14:main._menu_text(preload("res://src/campaign/glass_research.gd").detail(main.expedition),17)
 main._save_archive();main.call_deferred("_layout")
 return true
