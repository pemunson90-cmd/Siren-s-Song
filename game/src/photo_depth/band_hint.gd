extends RefCounted
# DEPTH-BAND PHOTOS: the one-line price of a band, written from the table so the
# words can never disagree with the numbers. Display only.
const Table = preload("res://src/photo_depth/band_table.gd")
const BandPhoto = preload("res://src/photo_depth/band_photo.gd")

# "DEEP: dark, clear, heard 416m, costs 0.6% oxygen per 8s"
static func line(sim, uid: int) -> String:
	var band: int = int(sim.units[uid].band)
	var r: Dictionary = BandPhoto.row(band)
	var light: String = Table.TEXT.bright if float(r.light) > 1.2 else (Table.TEXT.dark if float(r.light) < 0.8 else Table.TEXT.even)
	var haze: String = Table.TEXT.hazy if float(r.haze) > 1.2 else (Table.TEXT.clear if float(r.haze) < 0.9 else Table.TEXT.plain)
	var cost: String = ""
	if uid == 0 and float(r.o2) > 0.0:
		cost = Table.TEXT.cost_o2 % [float(r.o2) * Table.HINT_SECONDS, int(Table.HINT_SECONDS)]
	elif uid > 0 and float(r.battery) > 0.0:
		cost = Table.TEXT.cost_battery % [float(r.battery) * Table.HINT_SECONDS, int(Table.HINT_SECONDS)]
	return Table.TEXT.line % [str(r.name), light, haze, roundi(BandPhoto.ring(sim, uid, false)), cost]
# Depth-menu reminder for a craft outside MIDDLE with an unrecorded subject nearby.
# Empty when the camera does not work in this band (the caller keeps its old text).
static func local_record(sim, u: Dictionary) -> String:
	if int(u.band) == 1 or not (int(u.band) in Table.SHOOT_BANDS):
		return ""
	for o in sim.mission.objectives:
		if not o.captured and BandPhoto.is_subject(o) and u.pos.distance_to(o.pos) < 240.0:
			return Table.TEXT.local_record % line(sim, sim.units.find(u))
	return ""
