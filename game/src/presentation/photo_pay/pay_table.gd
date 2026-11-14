extends RefCounted
# WP-10 [AI-DESIGNED] PHOTO PAY display: text only. The pay itself is not here and
# is not changed: the campaign economy credits no currency per photograph, so what a
# secured photograph pays is the photographic intel the profile stored for it
# (campaign/photo_intel.gd recover()), the camera research that intel cuts
# (PhotoIntel.PROJECTS) and the later chart marks it earns (PhotoIntel.RETURNED_FILM).
# REVERT: set `enabled` to false; the debrief and archive lose only these lines.
static var enabled:=true
const TEXT:={
	# WP-109: the head says what the pay is (intel, never scrap or cells) and each row gives its figures: frame quality, intel value, the needed value.
	"head":"PHOTO PAY · film earns intel for the archive, not scrap or cells",
	"record":"%s · grade %s %d%% frame quality · %s",
	"credited":"INTEL %s %d%%",
	"unused":"%s · kept in the archive; it opens no camera research and marks no chart",
	"kept":"%s %d%% · archive already holds %d%% from dive %d",
	"none":"no intel detail on film",
	"cut":"CAMERA RESEARCH · %s cut from %s %d%%",
	"short":"CAMERA RESEARCH · %s needs %s at %d%% · best %d%%",
	"chart":"LATER CHARTS · %s marks dive %s",
	"archive":"PAID · %s",
	"archive_none":"PAID · no intel currently credited to this operation",
}
const RECORD_NAME_CHARS:=28
