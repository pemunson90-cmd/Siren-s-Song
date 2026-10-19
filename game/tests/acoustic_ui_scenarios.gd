extends RefCounted
static func rows(game) -> Array:
	return game.ocean.acoustic_rows() if game.ocean.has_method("acoustic_rows") else []
static func run(t,game) -> void:
	game._start_mission(0); game.sim.command("decoy"); game.sim.command("select",{"unit":1}); game.sim.command("route",{"point":Vector2(500,700)}); game._refresh()
	var lines=rows(game)
	t.check(lines.any(func(line):return "DECOY" in line and "15s" in line),"persistent chart instrument retains decoy countdown after route message overwrites launch")
	t.check(lines.any(func(line):return "reception unknown" in line),"instrument explicitly preserves uncertainty about enemy reception")
	t.check(lines.any(func(line):return "OPEN WATER" in line and "basalt" in line),"own acoustic estimate preserves its honest terrain qualification")
	game.sim.command("ping"); game._refresh()
	t.check(rows(game).any(func(line):return "SONAR" in line and "2s" in line),"own sonar pulse has a finite explained transmission timer")
	lines=rows(game)
	game._show_campaign(); await t.process_frame
	t.check(rows(game)==lines and game.sim.paused,"operations menu pauses the same finite transmission feedback")
	game.sim.units[0].vel=Vector2(60,0); game.sim.units[0].silent=true; game._refresh()
	t.check(rows(game).any(func(line):return "QUIETUS" in line),"residual movement remains visibly audible after selecting silent mode")
	game.sim.units[0].vel=Vector2.ZERO; game.sim.noises.clear(); game._refresh()
	t.check(rows(game).any(func(line):return "idle" in line) and not rows(game).any(func(line):return "safe" in line),"low movement feedback makes no safety claim")
