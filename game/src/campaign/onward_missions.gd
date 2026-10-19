extends RefCounted
const Divergence=preload("res://src/campaign/divergence_missions.gd")
static func make(id:int,history:Dictionary={})->Dictionary:
 var wake=id==9
 var m={"id":id,"title":"Wake Crossing" if wake else "Warning Chain","brief":"","record":"","depth":5100 if wake else 2600,"darkness":false,"region_revision":1,"world_size":Vector2(2000,2080),"start":Vector2(1000,1880),"extraction":Vector2(1000,180),"rocks":[],"objectives":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.0,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[],"launch_context":history.duplicate(true)}
 m.corridors=[{"pos":m.extraction,"name":"NORTH WATER RECOVERY","route":"deep" if wake else "shelf"}]
 if wake:
  m.rocks=[Rect2(880,660,240,820),Rect2(100,1020,420,220),Rect2(1480,1020,420,220),Rect2(120,300,420,180),Rect2(1460,300,420,180)]
  m.signal_sources=[{"id":"wake_packet","label":"RETURN RECEIVER","pos":Vector2(480,620),"evidence":"The measured return cadence belongs to a moving evacuation network. Quietus recovers the onward wake corridor without publishing its hull positions.","located":false,"confirm":true,"cadence":[0.8,1.6,0.8]}, {"id":"wake_repeater","label":"ABANDONED REPEATER","pos":Vector2(1520,620),"evidence":"A surviving repeater carries an older unequal cadence. Its close packet identifies it as an empty branch; cadence resemblance alone would never prove a friendly hull.","located":false,"cadence":[1.6,0.8,1.6]}]
  m.required_site_ids=["wake_packet"]
  m.brief="Two unlabeled carriers reach the southern listening lee around the central spine. Neither bearing is a source location. If you recovered and fitted the berthing correlator, settle Quietus for six seconds to compare their intervals with the measured RETURN reference; a pattern match does not establish identity or range. Without it, send a drone close to either basin or spend finite local RECON. Recover the live receiver packet with Quietus, then cross into northern recovery. The empty repeater remains a legitimate finding, not the onward packet. Both western and eastern passages are navigable."
  m.record="The recovered wake packet places an evacuation line beyond the fork. The return pattern has become usable evidence across dives, without becoming a target identifier."
  Divergence._patrol(m,Vector2(620,850),[Vector2(620,850),Vector2(620,520),Vector2(780,420),Vector2(760,1400)])
  Divergence._patrol(m,Vector2(1340,850),[Vector2(1340,850),Vector2(1340,450),Vector2(1220,300),Vector2(1250,1430)])
 else:
  m.rocks=[Rect2(880,800,240,800),Rect2(140,520,500,220),Rect2(1360,520,500,220),Rect2(300,1230,320,200),Rect2(1380,1230,320,200)]
  for item in [[Vector2(480,1000),"WEST WARNING PREPARATION","chain_west"],[Vector2(1520,1000),"EAST WARNING PREPARATION","chain_east"]]:
   m.objectives.append({"pos":item[0],"name":item[1],"site_id":item[2],"captured":false,"kind":"receiver","required_unit":0,"sampler_compatible":true,"duration":4.0,"optical":item[2],"evidence":"A local warning station stores the verified packet for the upper relay. A fitted drone can acquire it slowly under an audible camera exposure; Quietus can receive it passively."})
  m.objectives.append({"pos":Vector2(1000,400),"name":"OUTBOUND WARNING RELAY","site_id":"chain_relay","captured":false,"kind":"uplink","required_unit":0,"duration":4.0,"requires":[0,1],"optical":"chain_relay","evidence":"Quietus combines both station receipts and transmits the warning toward inhabited water. The emission discloses this station, not a live hull tracker.","completion_emission":{"radius":1100.0,"label":"WARNING CHAIN TRANSMISSION","duration":8.0}})
  m.brief="The recovered shelf acknowledgement opens two separated warning preparations. Both receipts are needed before Quietus can transmit at the northern relay. Quietus can receive either station quietly in four seconds. A recovered, fitted drone sampler can do the same local task in eight seconds with an audible camera exposure, letting the pilot divide the two arms while Quietus approaches the relay. Unfitted drones still scout; Quietus remains the complete fallback. The final transmission is audible: plan the northern departure before sending it."
  m.record="The two warning preparations agree. Quietus sends a verified fracture warning toward inhabited water while the evacuation continues below. Disclosure has become a tactical choice with a physical departure."
  Divergence._patrol(m,Vector2(740,1080),[Vector2(740,1080),Vector2(700,760),Vector2(740,380),Vector2(800,1700)])
  Divergence._patrol(m,Vector2(1280,800),[Vector2(1280,800),Vector2(1250,1250),Vector2(1250,1700),Vector2(1280,400)])
 return m
