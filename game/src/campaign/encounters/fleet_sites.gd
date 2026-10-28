extends RefCounted
# Optional fleet payoffs through existing Reach work, currents and finite tools.
# Revert: set ENABLED=false; retain record registration for existing saved notes.
# No new save fields, fleet rules or required records. Cargo cache awaits runtime support.
const W=preload("res://src/campaign/encounters/work_sites.gd")
const ENABLED=true
const LOITER_POS=Vector2(200,1900)
const LOITER_SECONDS=620.
const LISTEN_POS=Vector2(1000,1500)
const SCOUT_PERCH=Vector2(1450,1500)
const SCOUT_SOURCE=Vector2(1450,1100)
const RELAY_PERCH=Vector2(300,1260)
const RELAY_SOURCE=Vector2(300,850)
const SILT_ACCOUNT=Vector2(1500,1680)
const PATROL_ACCOUNT=Vector2(2300,1100)
static func records(id:int)->Array:
 return {37:["glass_record_37_pilot","glass_record_37_hydrophone","glass_record_37_relay"],38:["glass_record_38_pump","glass_record_38_watch"],39:["glass_record_39_patrol"]}.get(id,[])
static func apply(m:Dictionary)->void:
 if not ENABLED:return
 match m.id:
  37:
   var account=W.listen("glass_record_37_pilot","SOUTH PILOT ACCOUNT",LISTEN_POS,"The south approach leaves the trawler's underside in view.",6.)
   account.optional=true
   m.objectives.append(account)
   var pos=Vector2(900,1150)
   m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":-PI/2,"mode":"PATROL","suspicion":0.,"stun":0.,"lock":0.,"target":-1,"patrol":0,"path_time":0.,"type":"sentinel"})
   pos=Vector2(1450,1200)
   m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":-PI/2,"mode":"PATROL","suspicion":0.,"stun":0.,"lock":0.,"target":-1,"patrol":1,"path_time":0.,"type":"sentinel"})
   m.signal_sources.append({"id":"glass_record_37_hydrophone","label":"SOUTH HYDROPHONE ACCOUNT","pos":SCOUT_SOURCE,"evidence":"The trawler's southern hydrophone records a service cadence.","located":false,"cadence":[1.5,2.5,1.5],"optional":true})
   m.brief+="\nOptional south pilot account: a Low noise hull helps cross the southern lane at transit speed below the listener. Standard craft can take it slowly; the DEEP trawler photograph remains the job."
   m.brief+="\nScout drones can receive the optional hydrophone account from 400m south, beyond the eastern listener's approach. Shorter receivers must close in or fit a survey array."
   m.signal_sources.append({"id":"glass_record_37_relay","label":"WEST MOORING ACCOUNT","pos":RELAY_SOURCE,"evidence":"The western mooring account records the trawler's service approach.","located":false,"cadence":[2.,1.,2.],"optional":true})
   m.brief+="\nOptional west mooring account: from the clear western perch (300,1260), a relay buoy lets a standard drone hear the account 410m north without rounding the wreckage. Its chirp is audible; Scout or a closer approach also works. Relay extends listening for both nearby drones, never command range."
  38:
   var pump=W.machine("glass_record_38_pump","SOUTH COUNTERFLOW PUMP",LOITER_POS,{"calm":0.},true,LOITER_SECONDS)
   pump.evidence="The southern counterflow pump is stopped; the return water is still."
   m.objectives.append(pump)
   m.currents.append({"center":LOITER_POS,"radius":140.,"velocity":Vector2(90,0)})
   m.brief+="\nOptional counterflow pump: 620s of continuous MIDDLE work stops the southern current. A Long endurance drone can hold at the pump while Quietus photographs; a standard drone needs a lower-effort standoff."
   var watch=W.listen("glass_record_38_watch","ROOF WATCH ACCOUNT",SILT_ACCOUNT,"The roof watch account records the southern patrol's crossing beneath the roof.",6.)
   watch.optional=true
   m.objectives.append(watch)
   m.brief+="\nOptional roof watch account: LISTEN in MIDDLE along the strip north of the closed sluice (1500,1680). Silt screen can cover this exposed reception from the southern patrol for25s; it also hides your view and its release is audible. Waiting for the patrol or using Disrupt remains possible. The DEEP underside photograph is still the required job."
  39:
   var patrol=W.listen("glass_record_39_patrol","EXHAUST PATROL ACCOUNT",PATROL_ACCOUNT,"The exhaust patrol account records the inner terrace's service crossing.",6.)
   patrol.optional=true
   m.objectives.append(patrol)
   m.brief+="\nOptional exhaust patrol account: LISTEN in MIDDLE near (2300,1100), beside the moving southern patrol. Drop a sonobuoy from the eastern basin to watch coarse bearings turn away before crossing; bearings give direction, never range or a guaranteed safe window. The outer contour or a patient approach needs no tool; the exhaust photograph remains the job."

