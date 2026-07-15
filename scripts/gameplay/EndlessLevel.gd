extends RefCounted
class_name EndlessLevel

# Procedural stage generator for Endless Run mode.
# Produces a level-data Dictionary in the same format as data/levels3d JSONs,
# so LevelManager3D builds it with zero special-casing. Each stage gets longer,
# denser, and faster; themes rotate so every stage looks distinct.

# Visually distinct theme/atmosphere ids to rotate through per stage
const THEMES: Array[int] = [1, 9, 6, 12, 14, 17, 18, 20, 11, 5]

const FULL_WIDTH := ["log", "branch"]

static func theme_for_stage(stage: int) -> int:
	return THEMES[(stage - 1) % THEMES.size()]

static func speed_for_stage(stage: int) -> float:
	return minf(7.4 + float(stage - 1) * 0.28, 10.4)

static func generate(stage: int, run_seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + stage * 7919

	var target_rows: int = clampi(36 + stage * 4, 40, 64)
	var modules: Array = [
		{"type": "straight_short", "rows": 5, "width": "triple", "lanes": 3, "mode": "run"},
	]
	var rows_so_far := 5
	var special_used := false

	while rows_so_far < target_rows:
		var module: Dictionary
		var roll := rng.randf()
		# One special movement section per stage from stage 2 on
		if not special_used and stage >= 2 and roll < 0.22:
			special_used = true
			var chain: Array = _special_chain(stage, rng)
			for m: Dictionary in chain:
				modules.append(m)
				rows_so_far += int(m.get("rows", 5))
			continue
		elif roll < 0.34:
			module = {"type": "straight_short", "rows": rng.randi_range(4, 6), "width": "triple", "lanes": 3}
		elif roll < 0.56:
			var dir := "gentle_curve_left" if rng.randf() < 0.5 else "gentle_curve_right"
			module = {"type": dir, "rows": rng.randi_range(6, 8), "width": "triple", "lanes": 3}
		elif roll < 0.68:
			module = {"type": "s_curve", "rows": 10, "width": "triple", "lanes": 3, "curve_degrees": 34.0}
		elif roll < 0.78:
			module = {"type": "narrow_passage", "rows": 5, "width": "narrow", "lanes": 1}
		elif roll < 0.86:
			var wdir := "wide_curve_left" if rng.randf() < 0.5 else "wide_curve_right"
			module = {"type": wdir, "rows": 8, "width": "wide", "lanes": 3}
		elif roll < 0.93:
			module = {"type": "bridge_crossing", "rows": 5, "width": "bridge", "surface": "wood", "lanes": 2}
		else:
			module = {"type": "ruins_corridor", "rows": 5, "width": "narrow", "surface": "stone", "lanes": 1}
		modules.append(module)
		rows_so_far += int(module.get("rows", 5))

	modules.append({"type": "finish_gate_approach", "rows": 4, "width": "double", "surface": "stone", "lanes": 2})
	rows_so_far += 4

	# Per-row lane counts so obstacle/coin lanes are always valid
	var lanes_per_row: Array[int] = []
	for m: Dictionary in modules:
		var lane_count := clampi(int(m.get("lanes", 3)), 1, 3)
		for i in range(int(m.get("rows", 5))):
			lanes_per_row.append(lane_count)
	var surface_per_row: Array[String] = []
	for m: Dictionary in modules:
		var surf := str(m.get("surface", _surface_for(str(m.get("type", "")))))
		for i in range(int(m.get("rows", 5))):
			surface_per_row.append(surf)

	var total := lanes_per_row.size()
	var obstacles: Array = []
	var min_gap: int = maxi(2, 5 - int(stage / 2))
	var max_gap: int = maxi(min_gap + 1, 8 - int(stage / 2))
	var row := 6
	var prev_full_width := false
	while row < total - 7:
		var lanes := lanes_per_row[row]
		var kind := _obstacle_for(surface_per_row[row], lanes, rng)
		if prev_full_width and kind in FULL_WIDTH:
			kind = "rock"
		obstacles.append({
			"type": kind,
			"lane": rng.randi_range(0, lanes - 1),
			"row": row,
		})
		prev_full_width = kind in FULL_WIDTH
		row += rng.randi_range(min_gap, max_gap) + (1 if prev_full_width else 0)

	# Coin lines threaded through the gaps between obstacles
	var coins: Array = []
	var blocked: Dictionary = {}
	for ob: Dictionary in obstacles:
		if str(ob.get("type", "")) in FULL_WIDTH:
			continue   # coins over jump obstacles are a reward pattern
		blocked[str(ob.get("row", 0)) + "_" + str(ob.get("lane", 0))] = true
	var coin_row := 3
	var coin_count := 0
	while coin_row < total - 3:
		var lanes_here := lanes_per_row[coin_row]
		var lane := rng.randi_range(0, lanes_here - 1)
		var run_len := rng.randi_range(2, 4)
		for i in range(run_len):
			var r := coin_row + i
			if r >= total - 3:
				break
			if lane >= lanes_per_row[r]:
				lane = lanes_per_row[r] - 1
			if blocked.has(str(r) + "_" + str(lane)):
				continue
			coin_count += 1
			if coin_count % 24 == 0:
				coins.append({"lane": lane, "row": r, "gem": true})
			else:
				coins.append({"lane": lane, "row": r})
		coin_row += run_len + rng.randi_range(1, 3)

	return {
		"id": theme_for_stage(stage),
		"length": rows_so_far,
		"seed": run_seed + stage * 131,
		"name": "Endless Expedition — Stage %d" % stage,
		"difficulty": "Endless",
		"path_modules": modules,
		"obstacles": obstacles,
		"coins": coins,
		"collectables": [],
		"environment": {
			"wind_strength": 0.6,
			"wind_speed": 0.9,
			"gust_strength": 0.2,
			"grass_footprints": true,
		},
	}

static func _special_chain(stage: int, rng: RandomNumberGenerator) -> Array:
	match rng.randi_range(0, 3):
		0:
			return [
				{"type": "water_slide_entry", "rows": 4, "lanes": 1},
				{"type": "water_slide_curve", "rows": 8, "lanes": 1},
			]
		1:
			return [
				{"type": "boat_entry_dock", "rows": 4, "lanes": 3},
				{"type": "boat_river_curve", "rows": 8, "lanes": 3},
			]
		2:
			return [
				{"type": "skating_entry", "rows": 4, "lanes": 3},
				{"type": "skating_straight", "rows": 8, "lanes": 3},
			]
		_:
			var mode := "animal_chase_lane" if stage % 2 == 0 else "animal_escape_section"
			return [{"type": mode, "rows": 8, "lanes": 3}]

static func _surface_for(kind: String) -> String:
	match kind:
		"bridge_crossing":
			return "wood"
		"ruins_corridor", "finish_gate_approach":
			return "stone"
		"water_slide_entry", "water_slide_curve":
			return "water_slide"
		"boat_entry_dock", "boat_river_curve":
			return "boat"
		"skating_entry", "skating_straight":
			return "skating"
		_:
			return "dirt"

static func _obstacle_for(surface: String, lanes: int, rng: RandomNumberGenerator) -> String:
	match surface:
		"water_slide", "boat":
			return ["water_rock", "floating_log", "whirlpool", "crocodile_zone"][rng.randi_range(0, 3)]
		"wood":
			return ["broken_plank", "crate"][rng.randi_range(0, 1)]
		"skating":
			return ["crate", "rock"][rng.randi_range(0, 1)]
		_:
			if lanes == 1:
				# single-lane rows: only jump/slide obstacles are fair
				return "log" if rng.randf() < 0.6 else "branch"
			return ["rock", "log", "spike", "branch", "thorn_bush", "boulder"][rng.randi_range(0, 5)]
