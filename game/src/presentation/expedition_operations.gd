extends RefCounted
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Missions=preload("res://src/campaign/missions.gd")
static func operations(main)->void:
 var available=Campaign.available(main.completed,main.expedition)
 if available.is_empty():return
 main._menu_text("BEYOND THE WARNING / EXPEDITIONS",22)
 for id in available:
  var mission=Missions.make(id)
  var status="RECOVERED" if id in main.expedition.get("completed",[]) else "AVAILABLE"
  main._button(main.panel_box,"%s · %s"%[mission.title,status],func():main._briefing(id),"expedition%d"%id)
static func briefing(main,index:int)->bool:
 if index<6:return false
 main._menu_text("OBSERVATION ORDERS\nArrival arcs show where a carrier reached that receiver; sound may bend around basalt. They are not exact target bearings. Close clear passive reception or local RECON earns a precise source mark. Pause gives planning time, never new passive samples. Named recovery corridors show which interpretations you have confirmed.",17)
 if index==6:main._menu_text("Choose a physical exit with Quietus after its carrier is identified. Investigating both retains both facts; your exit selects the continuation. The southern basin permits incomplete withdrawal after departure, without a route or equipment reward.",17)
 return true
static func debrief(main)->bool:
 var mission=main.sim.mission
 if mission.id not in [6,7,8]:return false
 main._retain_evidence()
 if main.sim.outcome=="won" and mission.get("recovered",false):
  main.expedition=Campaign.recover(main.expedition,mission)
  main._menu_text("EXPEDITION RECOVERED",32)
  main._menu_text(mission.record,22)
  if mission.id==6:
   main._menu_text("PHYSICAL ROUTE / %s\nRecovered carrier facts: %s"%[mission.chosen_route.to_upper(),", ".join(mission.expedition_facts.keys())],17)
   var next=7 if mission.chosen_route=="deep" else 8
   main._button(main.panel_box,"CONTINUE / %s"%Missions.make(next).title,func():main._briefing(next),"next_expedition")
  main._menu_text("Dive time %02d:%02d / Hull %d%%"%[int(main.sim.elapsed)/60,int(main.sim.elapsed)%60,int(main.sim.hull)],17)
 else:
  main._menu_text("INCOMPLETE WITHDRAWAL" if main.sim.outcome=="withdrawn" else "EXPEDITION LOST",30)
  main._menu_text(main.sim.message,20)
  main._menu_text("Field observations remain in the archive. This dive grants no route completion or module.",17)
 if not main.recovered_evidence.is_empty():main._button(main.panel_box,"REVIEW FIELD RECORDS",func():main._evidence_gallery(0),"evidence")
 main._button(main.panel_box,"RETRY EXPEDITION",func():main._briefing(mission.id),"retry")
 main._button(main.panel_box,"OPERATIONS ARCHIVE",main._show_campaign,"back")
 main._save_archive();main.call_deferred("_layout")
 return true
