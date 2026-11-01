extends RefCounted
# 127 test helper: an authored journey places its own straight legs, the way a
# release-play pilot plots around rock it can see on the chart. The test reads
# the existing pathfinder only to choose leg points; the game installs exactly
# those legs. Works with the dev state on or off. Not a standalone suite.
static func route(s,point:Vector2)->bool:
 var u=s.units[s.selected]
 s._use_band(u.band)
 var origin:Vector2=u.route.back().pos if s.queue_mode and not u.route.is_empty() else u.pos
 var legs=s.player_path(origin,point).map(func(n):return n.pos)
 if legs.is_empty() or legs.back()!=point:legs=[point]
 var queued=s.queue_mode
 for n in legs.size():
  s.queue_mode=queued or n>0
  if not s.command("route",{"point":legs[n]}):s.queue_mode=queued;return false
 s.queue_mode=queued
 return true
