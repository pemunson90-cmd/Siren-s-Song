extends RefCounted
# Procedural mono16 WAVs, built once and shared. Never generate PCM in update().
# Local deterministic noise avoids touching the simulation's random generator.
const Table=preload("res://src/audio/photo_audio/photo_cue_table.gd")
static var cache:Dictionary={}
static func stream(cue:String)->AudioStreamWAV:
 if cache.has(cue):return cache[cue]
 var row=Table.CUES[cue];var frames=ceili(row.seconds*Table.RATE)
 var pcm=PackedByteArray();pcm.resize(frames*2)
 var noise_seed=7919
 for n in frames:
  var t=float(n)/Table.RATE;var fraction=float(n)/maxi(1,frames-1)
  var phase=TAU*(row.hz[0]*t+(row.hz[1]-row.hz[0])*t*t/(2.*row.seconds))
  noise_seed=(noise_seed*1664525+1013904223)&0xffffffff
  var noise=float(noise_seed)/2147483648.-1.
  var wave=sin(phase)*.7+sin(phase*2.)*.3
  var pulse=absf(sin(PI*fraction*row.pulses))
  var envelope=pow(pulse,row.curve)*sin(PI*fraction)
  var sample=Table.PEAK*lerpf(wave,noise,row.noise)*envelope
  pcm.encode_s16(n*2,clampi(roundi(sample*32767.),-32767,32767))
 var wav=AudioStreamWAV.new();wav.format=AudioStreamWAV.FORMAT_16_BITS
 wav.mix_rate=Table.RATE;wav.stereo=false;wav.data=pcm
 if cue=="hold":wav.loop_mode=AudioStreamWAV.LOOP_FORWARD;wav.loop_begin=0;wav.loop_end=frames-1
 cache[cue]=wav
 return wav
