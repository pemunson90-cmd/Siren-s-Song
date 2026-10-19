extends RefCounted
const Soundscape=preload("res://src/audio/soundscape.gd")
static func run(t) -> void:
	for cue in ["ambience","ping","camera","emp","record","loss","extraction","alert","engine","creak","beam","factory"]:
		var values=Soundscape.samples(cue)
		var peak=0.0; var energy=0.0
		for v in values: peak=maxf(peak,absf(v)); energy+=v*v
		t.check(values.size()>1000 and peak<0.95 and energy>0.01,"audio %s has nonzero signal and clipping headroom"%cue)

	t.check(Soundscape.engine_gain(0,true)==0 and Soundscape.engine_gain(42,true)>0 and Soundscape.engine_gain(78,false)>Soundscape.engine_gain(42,true)*2,"propulsion audio reflects stationary, silent and noisy cruise thrust")
	for cue in ["engine","creak","beam","recon","decoy","factory"]:
		t.check(Soundscape.samples(cue)!=Soundscape.samples("alert"),"%s has its own functional sonic identity"%cue)

	for cue in ["ambience","engine"]:
		var wav=Soundscape.stream(cue)
		var frames=wav.data.size()/2
		t.check(wav.loop_begin>=0 and wav.loop_begin<wav.loop_end and wav.loop_end<frames,"%s loop endpoints address valid PCM frames at the native mixer boundary"%cue)
