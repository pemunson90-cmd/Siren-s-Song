extends RefCounted
# RESEARCH and ARCHIVE view data. Presentation only; revert with enabled=false.
const GAP=12
const TEXT={"entry":"RESEARCH / ARCHIVE / FIELD LOG","research":"RESEARCH","archive":"ARCHIVE","log":"FIELD LOG"}
# Best photographs listed per region (sharpest first).
const PHOTO_ROWS=3
# Region groups over operation ids: [name, first id, last id].
const REGIONS=[["SHELF",0,5],["DIVERGENCE",6,10],["CONFLUENCE",11,13],["GLASS REACH",14,21],["IRON CHOIR",22,29],
	["FINAL SURVEY",30,31],["CALDER TRENCH",32,36],["OPTIONAL",37,40]]
const OTHER_REGION="UNSORTED"
