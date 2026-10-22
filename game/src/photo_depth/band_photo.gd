extends RefCounted
# DEPTH-BAND PHOTOS: the rules for photographing from SHALLOW, MIDDLE or DEEP.
# One place answers "may this craft frame this subject here" (can_shoot), "how
# does the band change this frame" (mods), "how far is our shutter heard"
# (ring, noise_scale) and "what does the exposure cost" (deep_cost). All numbers
# are in band_table.gd. It reads depth, contacts and sirens; it never changes
# combat, beams, collision, damage, hull, or Siren sight and hearing.
#
# SEAMS (remove this folder and these lines to revert; set band_table.gd to its
# neutral values to keep the code but play exactly as before):
#   photo_capture.gd  frame():        BandPhoto.mods(...) and its uses (light, haze, swell, thermal, blur, slant)
#   photo_capture.gd  noise_radius(): BandPhoto.ring(...)
#   photo_capture.gd  finish():       shot["band"]=...                    optional save field
#   photo_capture.gd  valid():        BandPhoto.valid_shot(shot)
#   photo_capture.gd  preview(), discover() x2:  BandPhoto.can_shoot(...)
#   photo_capture.gd  view():         band geometry for the viewfinder profile
#   simulation.gd     camera order guard, _camera_context_base() first line, camera_context() gate,
#                     capture tick check:  BandPhoto.unready / gate / can_shoot
#   depth_bands.gd    advance(): BandPhoto.deep_cost(...); context(): BandHint.local_record(...)
#   photo_pricing.gd  rings and "if heard" estimate: BandPhoto.ring / hear_scale
# Save: each shot gains an optional "band" (0 to 2, default 1). A build without
# this module ignores it; an old save without it reads as MIDDLE.
const Table = preload("res://src/photo_depth/band_table.gd")

static func row(band: int) -> Dictionary:
	return Table.BANDS[clampi(band, 0, Table.BANDS.size() - 1)]
# The band a subject sits in. A Siren sits in its own band; a charted subject in
# the band it declares (default MIDDLE).
static func subject_band(sim, o: Dictionary) -> int:
	if o.has("siren") and int(o.siren) < sim.sirens.size():
		return int(sim.sirens[int(o.siren)].get("band", 1))
	var s = o.get("subject", {})
	return int(s.get("band", 1)) if s is Dictionary else 1
static func is_subject(o: Dictionary) -> bool:
	return o.get("subject") is Dictionary and not o.subject.is_empty()
static func _declared(o: Dictionary) -> Array:
	var declared = o.subject.get("bands") if is_subject(o) else null
	return declared if declared is Array else []
static func _photographic(band: int) -> bool:
	return band == 1 or band in Table.SHOOT_BANDS
# May this craft frame photographs here? With no objective: is its band a
# photographic band at all. With one: may it frame exactly that subject.
# Anything that is not a photograph (a sample, a listen, an uplink) stays MIDDLE.
# A Siren can be studied only from its own band.
static func can_shoot(sim, u: Dictionary, o: Dictionary = {}) -> bool:
	if not u.get("alive", true) or not u.get("transition", {}).is_empty():
		return false
	var band: int = int(u.get("band", 1))
	if o.is_empty():
		return _photographic(band)
	if not is_subject(o):
		return band == 1
	if o.has("siren"):
		return int(o.siren) < sim.sirens.size() and int(sim.sirens[int(o.siren)].get("band", 1)) == band and _photographic(band)
	var declared: Array = _declared(o)
	if not declared.is_empty() and not (band in declared):
		return false
	return _photographic(band)
# The reason the camera is closed to this craft, or "" when it may frame photographs.
static func unready(sim, u: Dictionary) -> String:
	if can_shoot(sim, u):
		return ""
	if _photographic(int(u.get("band", 1))) and Table.SHOOT_BANDS.size() > 1:
		return Table.TEXT.settle
	return Table.TEXT.middle_only
# Camera context gate: outside MIDDLE only photographic subjects in a band that
# can frame them may be ready; a subject that needs another band says which.
static func gate(sim, ctx: Dictionary) -> Dictionary:
	var u: Dictionary = sim.units[sim.selected]
	var t: int = int(ctx.get("target", -1))
	var o: Dictionary = {}
	if t == -2:
		o = {"siren": int(ctx.siren), "subject": {"live": true}}
	elif t >= 0 and t < sim.mission.objectives.size():
		o = sim.mission.objectives[t]
	if not ctx.get("ready", false):
		var declared: Array = _declared(o)
		if not declared.is_empty() and not (int(u.band) in declared):
			ctx["text"] = str(ctx.get("text", "")) + " · seen only from " + _band_names(declared)
		elif int(u.band) != 1:
			ctx["text"] = str(ctx.get("text", "")) + Table.TEXT.other_work
		return ctx
	if o.is_empty():
		if int(u.band) == 1:
			return ctx
		ctx["ready"] = false
		ctx["text"] = Table.TEXT.middle_only
		return ctx
	if can_shoot(sim, u, o):
		if int(u.band) != 1 and is_subject(o):
			ctx["text"] = str(ctx.get("text", "")) + " · " + preload("res://src/photo_depth/band_hint.gd").line(sim, sim.selected)
		return ctx
	ctx["ready"] = false
	if o.has("siren"):
		ctx["text"] = Table.TEXT.siren_band
	elif not _declared(o).is_empty():
		ctx["text"] = Table.TEXT.only_in % [str(o.get("name", "")), _band_names(_declared(o))]
	else:
		ctx["text"] = Table.TEXT.middle_only
	return ctx
static func _band_names(bands: Array) -> String:
	var names: PackedStringArray = []
	for b in bands:
		names.append(str(row(int(b)).name))
	return " or ".join(names)
# --- the frame ----------------------------------------------------------------
# Multipliers for one frame. `dv` is the slant added by bands between craft and subject.
static func mods(sim, u: Dictionary, o: Dictionary) -> Dictionary:
	var r: Dictionary = row(int(u.get("band", 1)))
	var steps: int = absi(int(u.get("band", 1)) - subject_band(sim, o))
	return {"light": float(r.light), "haze": float(r.haze), "swell": float(r.swell), "thermal": float(r.thermal), "blur": float(r.blur), "dv": Table.VERTICAL * steps}
# Distance with the slant of the bands between craft and subject.
static func slant(m: Dictionary, dist: float) -> float:
	var dv: float = float(m.dv)
	return dist if dv <= 0.0 else sqrt(dist * dist + dv * dv)
# The band's tele effect only changes blur a lens already has.
static func blur(m: Dictionary, lens_blur: float) -> float:
	return lens_blur * float(m.blur) if lens_blur > 1.0 else lens_blur
# --- our own shutter noise ------------------------------------------------------
static func noise_scale(band: int) -> float:
	return float(row(band).ring)
static func ring(sim, uid: int, flash: bool) -> float:
	var band: int = int(sim.units[uid].get("band", 1)) if uid >= 0 and uid < sim.units.size() else 1
	return (Table.BASE_FLASH_RING if flash else Table.BASE_RING) * noise_scale(band)
# How much of a noise made in band a a listener in band b hears: the existing
# depth transmission, read and not copied.
static func hear_scale(sim, a: int, b: int) -> float:
	return sim.Depth.transmission({"band": a}, {"band": b})
# --- the cost of exposing in this band -------------------------------------------
# Called every step from Depth.advance, beside the existing pressure-pump cost.
static func deep_cost(sim, dt: float) -> void:
	for i in sim.units.size():
		var u = sim.units[i]
		if not u.alive or i >= sim.captures.size() or sim.captures[i].is_empty():
			continue
		var o: Dictionary = sim.Photo.obj(sim, int(sim.captures[i].target))
		if not is_subject(o):
			continue
		var r: Dictionary = row(int(u.band))
		if i == 0:
			sim.oxygen = maxf(0.0, sim.oxygen - dt * float(r.o2))
		else:
			u.battery = maxf(0.0, u.battery - dt * float(r.battery))
# --- saves -------------------------------------------------------------------------
static func valid_shot(shot: Dictionary) -> bool:
	if not shot.has("band"):
		return true
	return shot.band is int and shot.band >= 0 and shot.band <= 2
