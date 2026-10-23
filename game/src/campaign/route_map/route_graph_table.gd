extends RefCounted
# Route-map presentation data only. Revert with enabled=false; saves are untouched.
static var enabled=true
const MIN_QUALITY=.3
const REVEALS={"silt_scour":[19],"exhaust_stack":[25]}
const SOURCES={"silt_scour":17,"exhaust_stack":16}
# Opening operations form one visual group, retaining six distinct states.
const POSITIONS={0:Vector2(0,0),1:Vector2(0,1),2:Vector2(0,2),3:Vector2(0,3),4:Vector2(0,4),5:Vector2(0,5),6:Vector2(1,5),7:Vector2(2,4),8:Vector2(2,6),9:Vector2(3,4),10:Vector2(3,6),11:Vector2(4,5),12:Vector2(5,4),13:Vector2(5,6),14:Vector2(6,5),15:Vector2(7,5),16:Vector2(8,5),17:Vector2(9,5),18:Vector2(10,5),19:Vector2(11,5),20:Vector2(8,3),21:Vector2(9,7),22:Vector2(12,5),23:Vector2(13,5),24:Vector2(14,5),25:Vector2(15,5),26:Vector2(12,7),27:Vector2(13,3),28:Vector2(13,7),29:Vector2(14,7)}
const VIEW={"min_target":64.,"margin":16.,"gap_touch":.5,"width_touch":3.,"height_touch":1.3,"font_touch":.23,"font_min":16,"zoom_min":1.,"zoom_max":2.,"zoom_step":.25}
const COLORS={"RECOVERED":"75d7b0","AVAILABLE":"b8e7ed","LOCKED":"415862","KNOWN FROM PHOTOS":"e8c58b"}
