extends RefCounted
const Soundscape=preload("res://src/audio/soundscape.gd")
static func run(t) -> void:
	for cue in ["ambience","ping","camera","emp","record","loss","extraction","alert"]:
		var values=Soundscape.samples(cue)
		var peak=0.0; var energy=0.0
		for v in values: peak=maxf(peak,absf(v)); energy+=v*v
		t.check(values.size()>1000 and peak<0.95 and energy>0.01,"audio %s has nonzero signal and clipping headroom"%cue)
