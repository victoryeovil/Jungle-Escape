extends RefCounted
class_name EndlessLevel

# Procedural stage generator for Endless Run mode.
# Produces a level-data Dictionary in the same format as data/levels3d JSONs,
# so LevelManager3D builds it with zero special-casing. Challenges arrive in
# short rhythms with recovery space; speed never outruns the available actions.

# Visually distinct theme/atmosphere ids to rotate through per stage
const THEMES: Array[int] = [1, 9, 6, 12, 14, 17, 18, 20, 11, 5]

const FULL_WIDTH := ["log", "branch", "floating_log"]
const ROW_METRES := 3.0
# Includes the longest character jump (Monkey on stone) and time to react again.
const ACTION_RECOVERY_SECONDS := 1.30
const DODGE_REACTION_SECONDS := 0.80
const FASTEST_MODE_MULTIPLIER := 1.24
const TRANSITION_CLEAR_ROWS := 3

static func theme_for_stage(stage: int) -> int:
	return THEMES[(maxi(1, stage) - 1) % THEMES.size()]

static func speed_for_stage(stage: int) -> float:
	return minf(7.4 + float(maxi(1, stage) - 1) * 0.28, 10.4)

static func generate(stage: int, run_seed: int) -> Dictionary:
	stage = maxi(1, stage)
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

	# Store the actual terrain explicitly. Theme 6 is sand (jumping requires an
	# upgrade), and wet themes reduce jump height; assuming dirt creates traps.
	var lanes_per_row: Array[int] = []
	var surface_per_row: Array[String] = []
	var mode_per_row: Array[String] = []
	for m: Dictionary in modules:
		var lane_count := clampi(int(m.get("lanes", 3)), 1, 3)
		var kind := str(m.get("type", ""))
		var surf := str(m.get("surface", _surface_for(kind, theme_for_stage(stage))))
		var mode := str(m.get("mode", _mode_for(kind)))
		m["surface"] = surf
		m["mode"] = mode
		for i in range(int(m.get("rows", 5))):
			lanes_per_row.append(lane_count)
			surface_per_row.append(surf)
			mode_per_row.append(mode)

	var total := lanes_per_row.size()
	var protected_rows: Dictionary = {}
	for r in range(1, total):
		if lanes_per_row[r] != lanes_per_row[r - 1] or mode_per_row[r] != mode_per_row[r - 1] or surface_per_row[r] != surface_per_row[r - 1]:
			# Let lane recentering, the vehicle change and terrain feedback finish.
			for clear_row in range(maxi(0, r - TRANSITION_CLEAR_ROWS), mini(total, r + TRANSITION_CLEAR_ROWS)):
				protected_rows[clear_row] = true
	var obstacles: Array = []
	var event_routes: Dictionary = {}
	var previous_row := -100
	var previous_kind := ""
	var route_lane := 1
	var route_lanes := 3
	var rhythm_step := 0
	var rhythm_length := 2 if stage < 4 else 3
	var breather_until := 0
	var row := 6
	while row < total - 7:
		var lanes := lanes_per_row[row]
		route_lane = _map_lane(route_lane, route_lanes, lanes)
		route_lanes = lanes
		if protected_rows.has(row) or row < breather_until:
			row += 1
			continue
		var kind := _obstacle_for(surface_per_row[row], lanes, rng)
		var action_pair: bool = kind in FULL_WIDTH or previous_kind in FULL_WIDTH
		var min_gap := recovery_rows(stage, action_pair) + (1 if stage < 3 else 0)
		if row - previous_row < min_gap:
			row += 1
			continue
		if kind in FULL_WIDTH:
			obstacles.append({"type": kind, "lane": route_lane, "row": row})
		else:
			# A reachable opening is chosen first. Even later two-obstacle gates
			# leave one lane open and never demand a two-lane last-second swipe.
			route_lane = clampi(route_lane + rng.randi_range(-1, 1), 0, lanes - 1)
			event_routes[row] = route_lane
			var blocked_lanes: Array[int] = []
			for lane in range(lanes):
				if lane != route_lane:
					blocked_lanes.append(lane)
			var block_both := lanes == 3 and stage >= 4 and rhythm_step == 1
			if not block_both:
				blocked_lanes = [blocked_lanes[rng.randi_range(0, blocked_lanes.size() - 1)]]
			for lane in blocked_lanes:
				obstacles.append({"type": kind, "lane": lane, "row": row})
		previous_row = row
		previous_kind = kind
		rhythm_step += 1
		if rhythm_step >= rhythm_length:
			rhythm_step = 0
			breather_until = row + recovery_rows(stage, true) + rng.randi_range(2, 4)
		row += 1

	var coins := _coin_trail(lanes_per_row, obstacles, event_routes)

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

static func recovery_rows(stage: int, includes_jump_or_slide: bool) -> int:
	var seconds := ACTION_RECOVERY_SECONDS if includes_jump_or_slide else DODGE_REACTION_SECONDS
	return maxi(3, ceili(speed_for_stage(stage) * FASTEST_MODE_MULTIPLIER * seconds / ROW_METRES))

static func _map_lane(lane: int, from_count: int, to_count: int) -> int:
	# Lane indices change meaning: lane 1 is centre on a wide trail but right
	# on a bridge. Preserve the closest physical position at each transition.
	var offset := float(lane) - float(from_count - 1) * 0.5
	return clampi(roundi(offset + float(to_count - 1) * 0.5), 0, to_count - 1)

static func _coin_trail(lanes_per_row: Array[int], obstacles: Array, event_routes: Dictionary) -> Array:
	var coins: Array = []
	var blocked: Dictionary = {}
	var action_rows: Dictionary = {}
	for ob: Dictionary in obstacles:
		var row := int(ob["row"])
		if str(ob["type"]) in FULL_WIDTH:
			# Ground-level coins cannot communicate a jump arc, so keep the
			# approach/landing clear instead of tempting a player into the log.
			for near_row in range(row - 1, row + 2):
				action_rows[near_row] = true
		else:
			blocked[Vector2i(row, int(ob["lane"]))] = true
	var lane := 1
	var previous_lanes := 3
	for row in range(3, lanes_per_row.size() - 3):
		var lanes := lanes_per_row[row]
		lane = _map_lane(lane, previous_lanes, lanes)
		previous_lanes = lanes
		# Start the safe lane line two rows before a gate and hold that lane
		# afterwards. A visible string gives advance notice of each dodge.
		for lookahead in range(3):
			var next_row := row + lookahead
			if event_routes.has(next_row) and lanes_per_row[next_row] == lanes:
				lane = int(event_routes[next_row])
				break
		if action_rows.has(row) or blocked.has(Vector2i(row, lane)):
			continue
		var coin := {"lane": lane, "row": row}
		if (coins.size() + 1) % 24 == 0:
			coin["gem"] = true
		coins.append(coin)
	return coins

static func _mode_for(kind: String) -> String:
	match kind:
		"water_slide_entry", "water_slide_curve":
			return "water_slide"
		"boat_entry_dock", "boat_river_curve":
			return "boat"
		"skating_entry", "skating_straight":
			return "skating"
		"animal_chase_lane":
			return "chase"
		"animal_escape_section":
			return "escape"
		_:
			return "run"

static func _surface_for(kind: String, theme_id: int = 1) -> String:
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
			match theme_id:
				6:
					return "sand"
				9, 12, 17:
					return "mud"
				5, 14, 18, 20:
					return "stone"
				_:
					return "dirt"

static func _obstacle_for(surface: String, lanes: int, rng: RandomNumberGenerator) -> String:
	if lanes == 1:
		match surface:
			"water_slide", "boat":
				return "floating_log"
			"sand", "mud":
				return "branch"
			_:
				return "log" if rng.randf() < 0.6 else "branch"
	match surface:
		"water_slide", "boat":
			return ["water_rock", "floating_log", "whirlpool", "crocodile_zone"][rng.randi_range(0, 3)]
		"wood":
			return ["broken_plank", "crate"][rng.randi_range(0, 1)]
		"skating":
			return ["crate", "rock"][rng.randi_range(0, 1)]
		"sand", "mud":
			# These remain playable with the starter character and no upgrades.
			return ["rock", "branch", "thorn_bush", "boulder"][rng.randi_range(0, 3)]
		_:
			return ["rock", "log", "spike", "branch", "thorn_bush", "boulder"][rng.randi_range(0, 5)]
