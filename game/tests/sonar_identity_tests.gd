extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Identity=preload("res://src/simulation/contact_identity.gd")
const Feedback=preload("res://src/presentation/contact_feedback.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var s=Sim.new();s.start(0)
 for u in s.units:u.alive=false
 s.units[0].alive=true;s.units[0].pos=Vector2(40,40)
 s.sirens[0].type="hunter";s.sirens[0].pos=Vector2(1000,700)
 s.contacts.clear();s.sonar.erase("identified")
 s.contacts[0]={"pos":s.sirens[0].pos,"time":s.elapsed,"mode":"ECHO","lock":0.0,"angle":0.0,"target":-1,"type":"hunter","band":1,"source":"active"}
 Identity.observe(s)
 check(Feedback.entries(s.contacts,s.elapsed,s.units)[0].text.contains("PATROLLER"),"unseen moving echo has only coarse class")
 check(not Feedback.entries(s.contacts,s.elapsed,s.units)[0].text.contains("HUNTER"),"contact list cannot leak hunter")
 check(Identity.classification(s,{"enemy":0,"classification":"hunter"})=="PATROLLER","waterfall hides exact echo role")
 check(Identity.event(s,{"type":"sweep_received","enemy":0}).get("sound","")=="carrier_received","unknown role uses shared sound and caption cue")
 s.units[1].alive=true;s.units[1].band=1;s.units[1].pos=s.sirens[0].pos+Vector2(30,0);s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
 s._observe()
 check(Identity.known(s,0),"sight from unselected drone identifies")
 check(Feedback.entries(s.contacts,s.elapsed,s.units)[0].text.contains("HUNTER"),"identified contact shows exact role")
 s.units[1].alive=false;s.contacts.clear();s.elapsed+=21;s._observe()
 check(Identity.known(s,0),"identity survives contact expiry")
 var snapshot=s.snapshot();var restored=Sim.new()
 check(restored.restore(snapshot) and Identity.known(restored,0),"identity survives paused save restore")
 var bad=snapshot.duplicate(true);bad.sonar.identified[99]="hunter"
 check(not Sim.valid_snapshot(bad),"identity index outside roster rejected")
 bad=snapshot.duplicate(true);bad.sonar.identified[0]="relay"
 check(not Sim.valid_snapshot(bad),"identity mismatched to actual role rejected")
 var malformed=snapshot.duplicate(true);malformed.contacts=[]
 check(not Sim.valid_snapshot(malformed),"non-dictionary contacts rejected without script errors")
 malformed=snapshot.duplicate(true);malformed.contacts={0:17}
 check(not Sim.valid_snapshot(malformed),"non-dictionary contact rejected without script errors")
 var legacy_survey={"source":"optical","seen_by":[],"type":"relay","mode":"RELAY IDLE","pos":Vector2.ZERO,"time":0.0,"lock":0.0,"target":-1}
 check(Identity.contact_type(legacy_survey)=="STATIC" and not Feedback.entries({0:legacy_survey},0.0,[])[0].text.contains("RELAY"),"paused legacy survey cache hides role and mode before a tick")
 check(Identity.contact_type({"type":"hunter"})=="hunter","source-absent legacy first-hand fixtures retain exact role")
 var old=snapshot.duplicate(true);old.sonar.erase("identified")
 check(restored.restore(old),"legacy snapshots without identity remain valid")
 s.start(0);check(not s.sonar.get("identified",{}).has(0),"next dive forgets individual identity")
 s.start(0,"endurance",{"context":{"intel":{"siren_hunter":{"q":0.5,"op":0}}}})
 s.sirens[0].type="hunter";Identity.seed(s,{"siren_hunter":{"q":0.5,"op":0}});Identity.observe(s)
 check(Identity.known(s,0),"recovered photographed role pre-identifies matching Siren")
 s.sonar.erase("identified")
 for u in s.units:u.alive=false
 s.mission["photo"]={"shots":[{"usable":true,"siren":0,"type":"hunter"}]}
 Identity.observe(s);check(Identity.known(s,0),"usable current-dive photograph identifies")
 s.sirens[0].type="relay";s.sonar.erase("identified");s.mission["photo"]={"shots":[]}
 check(Identity.classification(s,{"enemy":0,"classification":"RELAY FORWARDING"})=="STATIC","station sound hides exact role")
 # Distinct individuals never share a sight identification merely by role.
 s.sirens[0].type="hunter";s.sirens.append(s.sirens[0].duplicate(true));s.sonar.erase("identified")
 Identity.identify(s,0)
 check(not Identity.known(s,1),"same-role peer remains unidentified")
 check(Identity.classification(s,{"enemy":0,"classification":"PROPULSION"})=="HUNTER - PROPULSION","known passive history names the role")
 var c={"type":"hunter","source":"active"}
 check(Identity.contact_type(c)=="PATROLLER","unidentified chart glyph uses generic moving shape")
 s.contacts[0]=c;Identity.decorate(s,0)
 check(Identity.contact_type(c)=="hunter","known chart glyph restores role shape")
 var event={"type":"sweep_received","enemy":1}
 var masked=Identity.event(s,event)
 check(masked.type=="sweep_received" and masked.get("sound","")=="carrier_received" and event.type=="sweep_received","audio masking never mutates source event")
 check(Identity.event(s,{"type":"sweep_received","enemy":0}).type=="sweep_received","known role keeps original cue")
 s.sonar.erase("identified");s.mission.photo.shots=[{"usable":false,"siren":0}];Identity.observe(s)
 check(not Identity.known(s,0),"unusable photo cannot identify")
 var tracker=preload("res://src/presentation/first_siren_cue/notice_tracker.gd").new();tracker.bind(s)
 s.siren_notice.emit(0,s.sirens[0].pos)
 check(tracker.notes().is_empty() and tracker.saved_types().is_empty(),"acoustic first notice adds no exact role or dossier entry")
 Identity.identify(s,0)
 check(tracker.notes().any(func(row):return row.type=="hunter"),"later sight adds role note after acoustic warning was consumed")
 tracker.unbind()
 var hidden={"type":"relay","display_type":"STATIC","mode":"RELAY IDLE","pos":Vector2.ZERO,"time":0.0,"lock":0.0,"target":-1}
 check(not Feedback.entries({0:hidden},0.0,[])[0].text.contains("RELAY"),"unidentified mode cannot leak relay role")
 hidden.mode="WARDEN CHARGING"
 check(Identity.contact_mode(hidden)=="CHARGING","mode masking preserves actionable charge")
 hidden.mode="INTERCEPT LISTEN"
 check(Identity.contact_mode(hidden)=="LISTEN","unidentified mode strips interceptor alias but preserves listening")
 var orphan=Sim.new();orphan.start(0);orphan.sirens=[];orphan.sonar["identified"]={}
 orphan.contacts={7:{"type":"relay","source":"active"}}
 Identity.decorate(orphan,7)
 check(Identity.contact_type(orphan.contacts[7])=="STATIC","orphaned cached acoustic contact uses safe coarse cached role")
 orphan.sonar.identified[7]="relay";Identity.decorate(orphan,7)
 check(Identity.contact_type(orphan.contacts[7])=="relay","orphaned cache retains earned identity without indexing absent roster")
 await audio_checks(s)
 print("PROBE active hunter: HUNTER -> ",Identity.contact_type({"type":"hunter","source":"active"}))
 print("PROBE stationary relay: RELAY -> ",Identity.coarse("relay"))
 print("PROBE sight/drone/photo/dossier: exact role restored; contact expiry and save restore retain identity")
 print("PROBE audio unknown/known: carrier_received / sweep_received; raw source event unchanged")
 print("SONAR IDENTITY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

func audio_checks(_prior):
 var s=Sim.new();s.start(0);s.sirens.append(s.sirens[0].duplicate(true))
 var sound=preload("res://src/audio/soundscape.gd").new();root.add_child(sound);await process_frame
 var settings=preload("res://src/presentation/frontend/frontend_settings.gd")
 settings.apply({"audio_captions":true,"haptics":false})
 s.sonar["identified"]={};s.paused=false;s.elapsed=100.0;s.events=[];sound.update(s,0.0)
 sound.messages_volume=0.0;sound.alerts_volume=1.0
 var raw={"type":"sweep_received","enemy":1,"receiver":0,"direction":Vector2.UP,"time":s.elapsed}
 var presented=Identity.event(s,raw)
 check(sound.cue_audible(presented.type),"generic sweeper warning remains audible with Messages zero")
 check(sound.Depth.haptic_cue(presented.type),"generic warning preserves original haptic classification")
 var received=preload("res://src/audio/received_cues.gd").new()
 var first=received.take(presented,0,s.elapsed,true)
 var other=Identity.event(s,{"type":"carrier_received","enemy":1,"receiver":0,"direction":Vector2.UP,"time":s.elapsed})
 check(not first.is_empty() and not received.take(other,0,s.elapsed,true).is_empty(),"different original cues preserve separate reception dedup")
 s.events=[raw];sound.update(s,0.0)
 check(sound.accessibility.text().contains("PATROLLER") and not sound.accessibility.text().to_lower().contains("sweeper"),"unidentified warning caption uses coarse class")
 var generic_voice=false
 for voice in sound.voices:
  var bus=AudioServer.get_bus_index(voice.bus)
  if voice.playing and voice.stream==sound.cues.carrier_received and AudioServer.get_bus_send(bus)==sound.ALERTS_BUS:generic_voice=true
 check(generic_voice,"generic recording plays through original alert bus")
 check(sound.received_cues.heard.has("0/sweep_received"),"audio dedup retains original warning identity")
 settings.apply({});sound.queue_free();await process_frame;await create_timer(0.1).timeout
