extends RefCounted
# EVENT AUDIO levels, priorities and repeat limits. Tunable numbers live only here.
# Revert: enabled=false restores today's soundscape exactly (no node, no state read).
# Generated cues share PhotoWave synthesis; gains are dB on the existing effects bus,
# so mute/volume, the master peak guard and the Night mode compressor still apply.
# Captions: each id has a row in presentation/accessibility/cue_table.gd TEXT.
static var enabled:=true
const VOICES:=3
const MAX_PER_FRAME:=2
# Field tool ids whose stock drop (a successful use) plays the cue of the same name.
const TOOLS:=["sonobuoy","silt_screen","hull_patch","relay_buoy"]
# Hull strain tiers by the hull percent the strike removed (highest matching min wins).
const HULL_TIERS:=[{"min":0.01,"id":"hull_light"},{"min":6.,"id":"hull_medium"},{"min":15.,"id":"hull_heavy"}]
# hz is a start/end chirp, noise its mix fraction, curve and pulses shape the envelope.
# interval is the minimum seconds between two plays of one id; higher priority plays first.
# recording rows reuse an imported Soundscape recording (their sound already plays from the
# event stream); they exist so a caller may use play() and so captions/priority are in one place.
const CUES:={
 "siren_report":{"seconds":.6,"gain_db":-22.,"hz":[620.,880.],"noise":.2,"curve":1.,"pulses":3,"interval":1.,"priority":5},
 "hull_light":{"seconds":.22,"gain_db":-26.,"hz":[150.,95.],"noise":.5,"curve":1.2,"pulses":1,"interval":.8,"priority":3},
 "hull_medium":{"seconds":.36,"gain_db":-21.,"hz":[120.,60.],"noise":.55,"curve":1.1,"pulses":2,"interval":.8,"priority":4},
 "hull_heavy":{"seconds":.55,"gain_db":-16.,"hz":[90.,38.],"noise":.65,"curve":.9,"pulses":3,"interval":.8,"priority":6},
 "survivor_aboard":{"seconds":.4,"gain_db":-24.,"hz":[300.,420.],"noise":.04,"curve":1.2,"pulses":2,"interval":2.,"priority":5},
 "survivor_landed":{"seconds":.7,"gain_db":-22.,"hz":[320.,560.],"noise":.03,"curve":.9,"pulses":3,"interval":2.,"priority":6},
 "cargo_handoff":{"seconds":.3,"gain_db":-27.,"hz":[250.,330.],"noise":.08,"curve":1.5,"pulses":2,"interval":2.,"priority":3},
 "artifact_secured":{"seconds":.65,"gain_db":-22.,"hz":[220.,460.],"noise":.06,"curve":.8,"pulses":2,"interval":3.,"priority":6},
 "research_complete":{"seconds":.9,"gain_db":-23.,"hz":[260.,620.],"noise":.02,"curve":.7,"pulses":3,"interval":3.,"priority":6},
 "sonobuoy":{"seconds":.3,"gain_db":-26.,"hz":[700.,520.],"noise":.05,"curve":2.,"pulses":2,"interval":1.,"priority":3},
 "silt_screen":{"seconds":.5,"gain_db":-27.,"hz":[200.,140.],"noise":.8,"curve":.6,"pulses":1,"interval":1.,"priority":3},
 "hull_patch":{"seconds":.45,"gain_db":-26.,"hz":[160.,230.],"noise":.3,"curve":1.,"pulses":2,"interval":1.,"priority":4},
 "relay_buoy":{"seconds":.4,"gain_db":-26.,"hz":[480.,640.],"noise":.04,"curve":1.6,"pulses":3,"interval":1.,"priority":3},
 "emp":{"recording":"emp","interval":1.,"priority":4},
 "decoy":{"recording":"decoy","interval":1.,"priority":4},
 "recon":{"recording":"recon","interval":1.,"priority":3},
 "knock":{"recording":"knock","interval":1.,"priority":4}}
static func hull_cue(lost:float)->String:
 var id=""
 for tier in HULL_TIERS:
  if lost>=float(tier.min):id=str(tier.id)
 return id
