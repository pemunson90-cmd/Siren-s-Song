extends RefCounted
# WP-10 [AI-DESIGNED] PHOTO PAY display: text only. The pay itself is not here and
# is not changed: the campaign economy credits no currency per photograph, so what a
# secured photograph pays is the photographic intel the profile stored for it
# (campaign/photo_intel.gd recover()), the camera research that intel cuts
# (PhotoIntel.PROJECTS) and the later chart marks it earns (PhotoIntel.RETURNED_FILM).
# REVERT: set `enabled` to false; the debrief and archive lose only these lines.
static var enabled:=true
const TEXT:={
	"head":"PHOTO PAY · what this dive's film added to the archive",
	"record":"%s · grade %s %d%% · %s",
	"credited":"INTEL %s %d%%",
	"kept":"%s %d%% · archive already holds %d%% from dive %d",
	"none":"no intel detail on film",
	"cut":"CAMERA RESEARCH · %s cut from %s %d%%",
	"short":"CAMERA RESEARCH · %s needs %s at %d%% · best %d%%",
	"chart":"LATER CHARTS · %s marks dive %s",
	"archive":"PAID · %s",
	"archive_none":"PAID · no intel currently credited to this operation",
}
const RECORD_NAME_CHARS:=28
