extends RefCounted
# All PHOTO AUDIO levels and synthesis curves are here. Gains are dB on the
# existing effects bus, so its mute/volume settings and master limiter still apply.
const RATE=22050
const VOICES=4
const PEAK=.42
const LOW_FILM=2
const SPIN_DOWN=.65
# hz is a start/end chirp; noise is its mix fraction; curve shapes each pulse.
# hold build_curve/pitch map real exposure progress, independently of music.
const CUES={
 "shutter":{"seconds":.13,"gain_db":-22.,"hz":[650.,130.],"noise":.55,"curve":3.,"pulses":2},
 "hold":{"seconds":.8,"gain_db":-38.,"max_db":-27.,"pitch":[.9,1.12],"build_curve":1.7,"hz":[90.,90.],"noise":.12,"curve":.4,"pulses":1},
 "develop":{"seconds":.48,"gain_db":-29.,"hz":[180.,330.],"noise":.6,"curve":1.4,"pulses":1},
 "film_low":{"seconds":.22,"gain_db":-25.,"hz":[470.,530.],"noise":.02,"curve":1.8,"pulses":2},
 "film_empty":{"seconds":.32,"gain_db":-23.,"hz":[340.,150.],"noise":.04,"curve":1.4,"pulses":2},
 "engine_down":{"seconds":.55,"gain_db":-25.,"hz":[110.,28.],"noise":.15,"curve":.8,"pulses":1},
 "pressure_shallow":{"seconds":.32,"gain_db":-30.,"hz":[220.,150.],"noise":.3,"curve":1.3,"pulses":1},
 "pressure_deep":{"seconds":.42,"gain_db":-28.,"hz":[130.,58.],"noise":.4,"curve":1.3,"pulses":1}
}
