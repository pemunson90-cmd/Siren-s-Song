extends RefCounted
const Divergence=preload("res://src/campaign/divergence_missions.gd")
const CHAIN_INLET=Vector2(480,1000)
const CHAIN_PANEL=Vector2(1520,1000)
const CHAIN_MAST=Vector2(1000,400)
const CHAIN_SHUTTER=Rect2(880,960,240,120)
const CHAIN_RECOVERY=Vector2(180,1000)
static func make(id:int,history:Dictionary={})->Dictionary:
 var wake=id==9
 var m={"id":id,"title":"Wake Crossing" if wake else "Warning Chain","brief":"","record":"","depth":5100 if wake else 2600,"darkness":false,"region_revision":1,"world_size":Vector2(2000,2080),"start":Vector2(1000,1880),"extraction":Vector2(1000,180),"rocks":[],"objectives":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.0,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[],"launch_context":history.duplicate(true)}
 m.corridors=[{"pos":m.extraction,"name":"NORTH WATER RECOVERY","route":"deep" if wake else "shelf"}]
 if wake:
  m.rocks=[Rect2(880,660,240,820),Rect2(100,1020,420,220),Rect2(1480,1020,420,220),Rect2(120,300,420,180),Rect2(1460,300,420,180)]
  m.signal_sources=[{"id":"wake_packet","label":"RETURN RECEIVER","pos":Vector2(480,620),"evidence":"The measured return cadence belongs to a moving evacuation network. Quietus recovers the onward wake corridor without publishing its hull positions.","located":false,"confirm":true,"range":1600.0,"cadence":[0.8,1.6,0.8]}, {"id":"wake_repeater","label":"ABANDONED REPEATER","pos":Vector2(1520,620),"evidence":"A surviving repeater carries an older unequal cadence. Its close packet identifies it as an empty branch; cadence resemblance alone would never prove a friendly hull.","located":false,"range":1600.0,"cadence":[1.6,0.8,1.6]}]
  m.required_site_ids=["wake_packet"]
  m.brief="Two high-power unlabeled evacuation carriers reach the southern listening lee around the central spine. Neither bearing is a source location. If you recovered and fitted the berthing correlator, settle Quietus for six seconds to compare their intervals with the measured RETURN reference; a pattern match does not establish identity or range. Without it, send a drone close to either basin or spend finite local RECON. Recover the live receiver packet with Quietus, then cross into northern recovery. The empty repeater remains a legitimate finding, not the onward packet. Both western and eastern passages are navigable."
  m.record="The recovered wake packet places an evacuation line beyond the fork. The return pattern has become usable evidence across dives, without becoming a target identifier."
  Divergence._patrol(m,Vector2(620,850),[Vector2(620,850),Vector2(620,520),Vector2(780,420),Vector2(760,1400)])
  Divergence._patrol(m,Vector2(1340,850),[Vector2(1340,850),Vector2(1340,450),Vector2(1220,300),Vector2(1250,1430)])
  m.sirens[1].type="hunter"
  m.brief+=" A hunter holds the eastern listening basin; the western arm has a moving patrol."
 else:
  m.rocks=[Rect2(880,800,240,160),Rect2(880,1080,240,520),Rect2(140,520,500,220),Rect2(1360,520,500,220),Rect2(300,1230,320,200),Rect2(1380,1230,320,200)]
  m.structures=[CHAIN_SHUTTER]
  m.warning_chain={"power":"off","unit":-1,"output":"","opened":false,"sends":[],"result":{}}
  for item in [[CHAIN_INLET,"WEST SERVICE INLET","chain_west","The preparations belong to one warning plant. A local craft can supply its service bus; the backup generator frees that body but discloses the western inlet."],[CHAIN_PANEL,"EAST ROUTING PANEL","chain_east","The powered panel can route a narrow service warning across the shutter or energize the northern mast. A service receipt proves one local branch; mast telemetry proves transmission, not an external audience."],[CHAIN_PANEL,"WARNING PLANT OPERATING RECORD","chain_relay","The warning plant was commissioned. The returned operating record distinguishes a verified local service receipt from a mast transmission with external reception unknown."]]:
   m.objectives.append({"pos":item[0],"name":item[1],"site_id":item[2],"captured":false,"kind":"plant","optical":item[2],"evidence":item[3]})
  m.corridors.append({"pos":CHAIN_RECOVERY,"name":"WEST SERVICE RECOVERY","route":"shelf"})
  m.brief="The shelf warning has reached an unpowered industrial relay plant. At WEST SERVICE INLET, CONNECT any settled craft within60m: that body's umbilical powers the distant panel until it releases, moves or is lost. START BACKUP is the complete solo alternative; one audible generator start frees the power craft. At EAST ROUTING PANEL, Quietus or a recovered fitted field sampler can select the output and SEND WARNING through the powered plant. SERVICE opens a real water and sound crosslink and sends from EAST; the western branch must actually receive it. NORTH MAST sends from northern hardware; its telemetry proves transmission, while external reception stays unknown. No camera hold is needed. Once commissioned, disconnect the helper and choose north or west service recovery. Both routes lead onward; an equipped craft still has its ordinary recovery stakes."
  m.record="The warning plant works again. Its operating record preserves exactly what Quietus proved: a local service acknowledgement or a northern mast transmission whose wider audience remains unknown."
  Divergence._patrol(m,Vector2(740,1080),[Vector2(740,1080),Vector2(700,760),Vector2(740,380),Vector2(800,1700)])
  Divergence._patrol(m,Vector2(1280,800),[Vector2(1280,800),Vector2(1250,1250),Vector2(1250,1700),Vector2(1280,400)])
  m.sirens[0].type="sentinel";m.sirens[0]["tether"]=190.0
  m.brief+=" A sentinel defends the western preparation; the eastern arm is patrolled."
 return m
