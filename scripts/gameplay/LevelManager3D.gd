extends Node3D
class_name LevelManager3D

const TILE_Z: float = 3.0
const LANE_W: float = 1.8
const PATH_WIDTH: float = LANE_W * 3.25
const SIDE_GROUND_WIDTH: float = 3.8

const COLOR_DIRT := Color(0.47, 0.31, 0.16)
const COLOR_DIRT_LIGHT := Color(0.61, 0.42, 0.22)
const COLOR_GRASS := Color(0.18, 0.49, 0.17)
const COLOR_GRASS_DARK := Color(0.10, 0.32, 0.11)
const COLOR_GRASS_LIGHT := Color(0.28, 0.67, 0.23)
const COLOR_FERN := Color(0.13, 0.45, 0.16)
const COLOR_LEAF := Color(0.16, 0.55, 0.20)
const COLOR_PALM := Color(0.19, 0.62, 0.22)
const COLOR_TRUNK := Color(0.35, 0.22, 0.10)
const COLOR_LOG := Color(0.43, 0.26, 0.10)
const COLOR_ROCK := Color(0.48, 0.49, 0.45)
const COLOR_MOSS := Color(0.27, 0.50, 0.18)
const COLOR_SPIKE := Color(0.62, 0.24, 0.18)
const COLOR_MUD := Color(0.30, 0.20, 0.10)
const COLOR_COIN := Color(1.00, 0.82, 0.10)
const COLOR_GEM := Color(0.15, 0.72, 1.00)
const COLOR_STONE := Color(0.46, 0.45, 0.39)
const COLOR_STONE_DARK := Color(0.31, 0.32, 0.29)
const COLOR_PORTAL := Color(0.20, 0.88, 0.65)
const COLOR_TORCH := Color(1.00, 0.55, 0.16)

signal finish_reached
signal coin_collected(total: int)
signal turn_zone_entered(required_dir: int, corner_pos: Vector3)
signal turn_zone_exited
signal path_segment_entered(row: int, center: Vector3, fwd: Vector3, right: Vector3, surface: String, mode: String, width: float, lanes: int)
signal junction_entered(junction_id: String, routes: Array)
signal junction_exited(junction_id: String)

var level_data: Dictionary = {}
var _coin_count: int = 0
var _total_coins: int = 0
var _coin_nodes: Array[Node3D] = []
var _collectable_nodes: Array[Node3D] = []
var _butterflies: Array[Dictionary] = []
var _birds: Array[Dictionary] = []
var _torch_flames: Array[Node3D] = []
var _relic_glows: Array[MeshInstance3D] = []
var _groups: Dictionary = {}
var _path_tiles: Dictionary = {}
var _time: float = 0.0
var _level_id: int = 1
var _theme: Dictionary = {}
var _seg_pos: Dictionary = {}
var _seg_fwd: Dictionary = {}
var _seg_right: Dictionary = {}
var _seg_width: Dictionary = {}
var _seg_lane_count: Dictionary = {}
var _seg_surface: Dictionary = {}
var _seg_mode: Dictionary = {}
var _seg_module: Dictionary = {}
var _turn_rows: Dictionary = {}
var _junction_rows: Dictionary = {}
var _junction_defs: Dictionary = {}
var _wind_nodes: Array[Dictionary] = []
var _grass_marks: Array[Dictionary] = []
var _wind_strength: float = 0.72
var _wind_speed: float = 1.0
var _gust_strength: float = 0.26
var _grass_footprints_enabled: bool = true

func build(data: Dictionary) -> void:
	level_data = data
	_coin_count = 0
	_total_coins = 0
	_time = 0.0
	_coin_nodes.clear()
	_collectable_nodes.clear()
	_butterflies.clear()
	_birds.clear()
	_torch_flames.clear()
	_relic_glows.clear()
	_wind_nodes.clear()
	_grass_marks.clear()
	_groups.clear()
	_path_tiles.clear()
	_seg_pos.clear()
	_seg_fwd.clear()
	_seg_right.clear()
	_seg_width.clear()
	_seg_lane_count.clear()
	_seg_surface.clear()
	_seg_mode.clear()
	_seg_module.clear()
	_turn_rows.clear()
	_junction_rows.clear()
	_junction_defs.clear()
	var environment: Dictionary = data.get("environment", {})
	_wind_strength = float(environment.get("wind_strength", 0.72))
	_wind_speed = float(environment.get("wind_speed", 1.0))
	_gust_strength = float(environment.get("gust_strength", 0.26))
	_grass_footprints_enabled = bool(environment.get("grass_footprints", true))

	for child in get_children():
		remove_child(child)
		child.queue_free()

	_setup_theme(int(data.get("id", 1)))
	_parse_turns(data)
	_create_level_groups()
	_spawn_ground(data)
	_spawn_dressing(data)
	_spawn_obstacles(data)
	_spawn_coins(data)
	_spawn_collectables(data)
	_spawn_wildlife(data)
	_spawn_level_specific_dressing(data)
	_spawn_path_variation(data)
	_spawn_module_landmarks(data)
	_spawn_junction_zones(data)
	_spawn_turn_zones(data)
	_spawn_finish(data)
	_count_total_coins(data)

func _process(delta: float) -> void:
	_time += delta
	_animate_coins(delta)
	_animate_collectables(delta)
	_animate_butterflies()
	_animate_birds()
	_animate_torches()
	_animate_relic_glows()
	_animate_wind()
	_animate_grass_marks(delta)

func _create_level_groups() -> void:
	for group_name in [
		"Terrain",
		"JunglePath",
		"Trees",
		"GrassAndPlants",
		"RocksAndLogs",
		"Obstacles",
		"Collectibles",
		"Animals",
		"Ruins",
		"RouteSigns",
		"ModeEffects",
		"FinishGate"
	]:
		var group := Node3D.new()
		group.name = group_name
		_groups[group_name] = group
		add_child(group)

func _group(name: String) -> Node3D:
	return _groups.get(name, self) as Node3D

func _parse_turns(data: Dictionary) -> void:
	var modules: Array = data.get("path_modules", [])
	if not modules.is_empty():
		_parse_path_modules(data, modules)
		return

	for t in data.get("turns", []):
		_turn_rows[int(t.get("row", 0))] = int(t.get("dir", 1))

	var length: int = data.get("length", 30)
	var cursor := Vector3.ZERO
	var fwd := Vector3(0.0, 0.0, -1.0)
	var right := Vector3(1.0, 0.0, 0.0)

	for i in range(length + 6):
		_seg_pos[i] = cursor
		_seg_fwd[i] = fwd
		_seg_right[i] = right
		_seg_width[i] = PATH_WIDTH
		_seg_lane_count[i] = 3
		_seg_surface[i] = _theme.get("surface", "dirt")
		_seg_mode[i] = "run"
		_seg_module[i] = "legacy_straight"
		if _turn_rows.has(i):
			var d: int = _turn_rows[i]
			fwd = fwd.rotated(Vector3.UP, -float(d) * PI * 0.5).normalized()
			right = right.rotated(Vector3.UP, -float(d) * PI * 0.5).normalized()
		cursor += fwd * TILE_Z

func _parse_path_modules(data: Dictionary, modules: Array) -> void:
	var cursor := Vector3.ZERO
	var fwd := Vector3(0.0, 0.0, -1.0)
	var right := Vector3(1.0, 0.0, 0.0)
	var row := 0
	var module_index := 0

	for raw_module in modules:
		if not (raw_module is Dictionary):
			continue
		var module: Dictionary = raw_module
		var kind := str(module.get("type", "straight_short"))
		var rows: int = max(1, int(module.get("rows", _default_module_rows(kind))))
		var width_name := str(module.get("width", _default_width_name(kind)))
		var lane_count := clampi(int(module.get("lanes", _default_lane_count(kind, width_name))), 1, 3)
		var width := float(module.get("path_width", _width_for_type(width_name)))
		var surface := str(module.get("surface", _default_surface_for_module(kind)))
		var mode := str(module.get("mode", _default_mode_for_module(kind)))
		var curve_degrees := float(module.get("curve_degrees", _default_curve_degrees(kind)))
		var curve_step := deg_to_rad(curve_degrees) / float(rows)
		var junction_row: int = row + max(1, int(rows / 2))

		for local_i in range(rows):
			_seg_pos[row] = cursor
			_seg_fwd[row] = fwd
			_seg_right[row] = right
			_seg_width[row] = width
			_seg_lane_count[row] = lane_count
			_seg_surface[row] = surface
			_seg_mode[row] = mode
			_seg_module[row] = kind

			if (kind == "junction_two_way" or kind == "junction_three_way") and row == junction_row:
				var junction_id := str(module.get("id", "junction_%02d_%02d" % [_level_id, module_index]))
				var routes: Array = module.get("routes", _default_routes_for_junction(kind))
				_junction_rows[row] = junction_id
				_junction_defs[junction_id] = {
					"id": junction_id,
					"row": row,
					"type": kind,
					"routes": routes,
				}

			var actual_curve_step := curve_step
			if kind == "s_curve":
				var half_rows: int = max(1, int(rows / 2))
				var s_degrees := float(module.get("curve_degrees", 36.0))
				actual_curve_step = deg_to_rad(s_degrees) / float(half_rows)
				if local_i >= half_rows:
					actual_curve_step = -actual_curve_step
			if absf(actual_curve_step) > 0.0001:
				fwd = fwd.rotated(Vector3.UP, actual_curve_step).normalized()
				right = right.rotated(Vector3.UP, actual_curve_step).normalized()
			cursor += fwd * TILE_Z
			row += 1

		module_index += 1

	for tail in range(6):
		_seg_pos[row + tail] = cursor + fwd * TILE_Z * float(tail)
		_seg_fwd[row + tail] = fwd
		_seg_right[row + tail] = right
		_seg_width[row + tail] = PATH_WIDTH
		_seg_lane_count[row + tail] = 3
		_seg_surface[row + tail] = _theme.get("surface", "dirt")
		_seg_mode[row + tail] = "run"
		_seg_module[row + tail] = "finish_tail"

	data["length"] = row

func _default_module_rows(kind: String) -> int:
	match kind:
		"straight_long":
			return 8
		"gentle_curve_left", "gentle_curve_right":
			return 8
		"wide_curve_left", "wide_curve_right", "s_curve":
			return 10
		"narrow_passage", "ruins_corridor", "bridge_crossing":
			return 5
		"water_slide_entry", "boat_entry_dock", "skating_entry":
			return 4
		"water_slide_curve", "boat_river_curve", "boat_rapids", "skating_straight", "skating_curve_left", "skating_curve_right":
			return 8
		"junction_two_way", "junction_three_way":
			return 5
		"finish_gate_approach":
			return 4
		_:
			return 5

func _default_curve_degrees(kind: String) -> float:
	match kind:
		"gentle_curve_left", "wide_curve_left", "sand_dune_curve":
			return 24.0
		"gentle_curve_right", "wide_curve_right":
			return -24.0
		"s_curve":
			return 0.0
		"water_slide_curve", "boat_river_curve":
			return 32.0
		"skating_curve_left":
			return 20.0
		"skating_curve_right":
			return -20.0
		_:
			return 0.0

func _default_width_name(kind: String) -> String:
	match kind:
		"narrow_passage", "ruins_corridor", "tree_root_jump_section":
			return "narrow"
		"bridge_crossing":
			return "bridge"
		"wide_curve_left", "wide_curve_right", "animal_chase_lane", "animal_escape_section", "junction_two_way", "junction_three_way":
			return "wide"
		"water_slide_entry", "water_slide_curve", "water_slide_drop":
			return "slide"
		"boat_entry_dock", "boat_river_straight", "boat_river_curve", "boat_rapids":
			return "boat"
		"skating_entry", "skating_straight", "skating_curve_left", "skating_curve_right":
			return "wide"
		_:
			return "normal"

func _width_for_type(width_name: String) -> float:
	match width_name:
		"single":
			return 2.60
		"double":
			return 4.45
		"triple":
			return 6.25
		"narrow":
			return LANE_W * 2.35
		"bridge":
			return LANE_W * 2.05
		"wide":
			return LANE_W * 4.10
		"slide":
			return LANE_W * 2.55
		"boat":
			return LANE_W * 4.35
		_:
			return PATH_WIDTH

func _default_lane_count(kind: String, width_name: String) -> int:
	if width_name == "single" or kind in ["narrow_passage", "ruins_corridor", "tree_root_jump_section", "water_slide_entry", "water_slide_curve", "water_slide_drop"]:
		return 1
	if width_name == "double" or kind == "bridge_crossing":
		return 2
	return 3

func _default_surface_for_module(kind: String) -> String:
	match kind:
		"bridge_crossing", "tree_root_jump_section":
			return "wood"
		"water_slide_entry", "water_slide_curve", "water_slide_drop":
			return "water_slide"
		"boat_entry_dock", "boat_river_straight", "boat_river_curve", "boat_rapids":
			return "boat"
		"skating_entry", "skating_straight", "skating_curve_left", "skating_curve_right":
			return "skating"
		"ruins_corridor", "finish_gate_approach":
			return "stone"
		"sand_dune_curve":
			return "sand"
		"mud_path":
			return "mud"
		_:
			return _theme.get("surface", "dirt")

func _default_mode_for_module(kind: String) -> String:
	match kind:
		"water_slide_entry", "water_slide_curve", "water_slide_drop":
			return "water_slide"
		"boat_entry_dock", "boat_river_straight", "boat_river_curve", "boat_rapids":
			return "boat"
		"skating_entry", "skating_straight", "skating_curve_left", "skating_curve_right":
			return "skating"
		"animal_chase_lane":
			return "chase"
		"animal_escape_section":
			return "escape"
		"mud_path":
			return "tracking"
		_:
			return "run"

func _default_routes_for_junction(kind: String) -> Array:
	if kind == "junction_three_way":
		return [
			{ "direction": "left", "label": "Treasure Route", "reward": "coins" },
			{ "direction": "up", "label": "Safe Route", "reward": "coins" },
			{ "direction": "right", "label": "Animal Tracks", "reward": "animal_badge" },
		]
	return [
		{ "direction": "left", "label": "Safe Route", "reward": "coins" },
		{ "direction": "right", "label": "Reward Route", "reward": "map_piece" },
	]

func _world_pos(row: int, lane: int) -> Vector3:
	var sp: Vector3 = _seg_pos.get(row, Vector3(0.0, 0.0, -float(row) * TILE_Z))
	var sf: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	var sr: Vector3 = _seg_right.get(row, Vector3(1.0, 0.0, 0.0))
	return sp + sf * (TILE_Z * 0.5) + sr * _lane_x_for_row(row, lane)

func _row_center(row: int) -> Vector3:
	var sp: Vector3 = _seg_pos.get(row, Vector3(0.0, 0.0, -float(row) * TILE_Z))
	var sf: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	return sp + sf * (TILE_Z * 0.5)

func _row_local(row: int, x: float, y: float, z: float = 0.0) -> Vector3:
	var center := _row_center(row)
	var sf: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	var sr: Vector3 = _seg_right.get(row, Vector3(1.0, 0.0, 0.0))
	return center + sr * x + sf * z + Vector3(0.0, y, 0.0)

func _spawn_ground(data: Dictionary) -> void:
	var length: int = data.get("length", 30)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 42)) + 101

	for i in range(length + 5):
		var seg_p: Vector3 = _seg_pos.get(i, Vector3(0.0, 0.0, -float(i) * TILE_Z))
		var seg_f: Vector3 = _seg_fwd.get(i, Vector3(0.0, 0.0, -1.0))
		var heading_y := atan2(seg_f.x, -seg_f.z)
		var path_width: float = _seg_width.get(i, PATH_WIDTH)
		var lane_count: int = int(_seg_lane_count.get(i, 3))
		var surface := str(_seg_surface.get(i, _theme.get("surface", "dirt")))
		var mode := str(_seg_mode.get(i, "run"))
		var module_kind := str(_seg_module.get(i, "straight_short"))

		var segment := Node3D.new()
		segment.name = "PathSegment_%02d" % i
		segment.position = seg_p
		segment.rotation.y = heading_y
		_group("JunglePath").add_child(segment)
		_path_tiles[i] = segment

		var track_asset := _place_glb(segment, _track_asset_path(surface, lane_count), Vector3(0.0, 0.01, 0.0), Vector3.ONE)
		if track_asset != null:
			var scale_x := path_width / _base_track_width(lane_count)
			track_asset.scale.x = scale_x * (-1.0 if i % 2 else 1.0)
		else:
			var path_col := _surface_path_color(surface, module_kind, rng)
			_add_box(segment, "DirtPath",
				Vector3(path_width, 0.16, TILE_Z + 0.08),
				Vector3(0.0, -0.08, 0.0),
				path_col
			)
		_add_static_box(segment, "PathCollision",
			Vector3(path_width, 0.16, TILE_Z + 0.08),
			Vector3(0.0, -0.08, 0.0),
			{"surface": surface}
		)
		_add_path_guide(segment, i, path_width, surface, mode, lane_count)

		if track_asset == null and (surface == "water_slide" or surface == "boat"):
			_add_box(segment, "WaterShimmerA",
				Vector3(path_width * 0.55, 0.025, TILE_Z * 0.18),
				Vector3(-path_width * 0.08, 0.015, -TILE_Z * 0.16),
				Color(0.42, 0.86, 1.0, 0.75)
			)
			_add_box(segment, "WaterShimmerB",
				Vector3(path_width * 0.38, 0.025, TILE_Z * 0.15),
				Vector3(path_width * 0.10, 0.02, TILE_Z * 0.18),
				Color(0.78, 0.96, 1.0, 0.55)
			)
		elif track_asset == null and surface == "skating":
			for lane_edge_value in [-0.9, 0.9]:
				var lane_edge := float(lane_edge_value)
				_add_box(segment, "SkateLaneStripe",
					Vector3(0.055, 0.025, TILE_Z * 0.94),
					Vector3(lane_edge, 0.018, 0.0),
					Color(0.15, 0.88, 1.0, 0.82)
				)
			for outer_edge_value in [-1.0, 1.0]:
				var outer_edge := float(outer_edge_value)
				_add_box(segment, "SkateEdgeGlow",
					Vector3(0.09, 0.035, TILE_Z * 0.96),
					Vector3(outer_edge * path_width * 0.43, 0.022, 0.0),
					Color(0.52, 0.24, 0.94, 0.72)
				)
			if i % 2 == 0:
				_add_box(segment, "SkateBoostMark",
					Vector3(1.10, 0.03, 0.18),
					Vector3(0.0, 0.026, 0.18),
					Color(0.92, 0.76, 0.20, 0.78)
				)
		elif track_asset == null and surface == "wood":
			for plank_i in range(3):
				_add_box(segment, "BridgePlank%d" % plank_i,
					Vector3(path_width * 0.92, 0.05, 0.08),
					Vector3(0.0, 0.03, -0.8 + float(plank_i) * 0.8),
					COLOR_LOG.lerp(Color(0.58, 0.38, 0.18), 0.35)
				)

		# Grass tiles as children so they rotate with path direction
		var side_offset := path_width * 0.5 + SIDE_GROUND_WIDTH * 0.5
		_add_box(segment, "GrassLeft",
			Vector3(SIDE_GROUND_WIDTH, 0.12, TILE_Z + 0.08),
			Vector3(-side_offset, -0.12, 0.0), _grass_color(rng))
		_add_box(segment, "GrassRight",
			Vector3(SIDE_GROUND_WIDTH, 0.12, TILE_Z + 0.08),
			Vector3(side_offset, -0.12, 0.0), _grass_color(rng))

		if i % 2 == 0:
			_spawn_path_edge_details(i, rng)

func _surface_path_color(surface: String, module_kind: String, rng: RandomNumberGenerator) -> Color:
	match surface:
		"water_slide":
			return Color(0.05, 0.42, 0.62).lerp(Color(0.16, 0.70, 0.92), rng.randf_range(0.0, 0.35))
		"boat":
			return Color(0.04, 0.22, 0.32).lerp(Color(0.05, 0.44, 0.62), rng.randf_range(0.0, 0.28))
		"skating":
			return Color(0.16, 0.20, 0.28).lerp(Color(0.32, 0.38, 0.50), rng.randf_range(0.0, 0.30))
		"stone":
			return Color(0.36, 0.35, 0.30).lerp(_theme.get("stone", COLOR_STONE), rng.randf_range(0.0, 0.35))
		"wood":
			return COLOR_LOG.lerp(Color(0.58, 0.36, 0.14), rng.randf_range(0.0, 0.40))
		"sand":
			return Color(0.74, 0.60, 0.34).lerp(Color(0.92, 0.76, 0.46), rng.randf_range(0.0, 0.35))
		"mud":
			return COLOR_MUD.lerp(Color(0.42, 0.27, 0.12), rng.randf_range(0.0, 0.25))
		"grass":
			return _grass_color(rng).lerp(Color(0.22, 0.42, 0.12), 0.30)
		_:
			var dirt_d: Color = _theme.get("dirt_dark", COLOR_DIRT)
			var dirt_l: Color = _theme.get("dirt_light", COLOR_DIRT_LIGHT)
			var tint := 0.18 if module_kind == "narrow_passage" else 0.35
			return dirt_d.lerp(dirt_l, rng.randf_range(0.0, tint))

func _add_path_guide(segment: Node3D, row: int, path_width: float, surface: String, mode: String, lane_count: int) -> void:
	var area := Area3D.new()
	area.name = "PathGuide"
	area.monitoring = true
	area.monitorable = false
	var col := CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	(col.shape as BoxShape3D).size = Vector3(path_width + 0.5, 2.4, TILE_Z + 0.12)
	col.position = Vector3(0.0, 1.05, 0.0)
	area.add_child(col)
	area.body_entered.connect(_on_path_segment_body_entered.bind(row, surface, mode, path_width, lane_count))
	segment.add_child(area)

func _on_path_segment_body_entered(body: Node3D, row: int, surface: String, mode: String, path_width: float, lane_count: int) -> void:
	if not (body is CharacterBody3D):
		return
	var center := _row_center(row)
	var fwd: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	var right: Vector3 = _seg_right.get(row, Vector3(1.0, 0.0, 0.0))
	path_segment_entered.emit(row, center, fwd, right, surface, mode, path_width, lane_count)

func _track_asset_path(surface: String, lane_count: int) -> String:
	var safe_surface := surface if surface in ["dirt", "grass", "mud", "stone", "wood", "sand", "skating", "water_slide", "boat"] else "dirt"
	return "res://assets/3d/environment/tracks/%s/track_%s_%dlane.glb" % [safe_surface, safe_surface, clampi(lane_count, 1, 3)]

func _base_track_width(lane_count: int) -> float:
	match clampi(lane_count, 1, 3):
		1:
			return 2.60
		2:
			return 4.45
		_:
			return 6.25

func _spawn_path_edge_details(row: int, rng: RandomNumberGenerator) -> void:
	var parent := _group("GrassAndPlants")
	var path_width: float = _seg_width.get(row, PATH_WIDTH)
	var edge_base := path_width * 0.5 + 0.30
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		for j in range(2):
			var x: float = side * rng.randf_range(edge_base, edge_base + 0.55)
			var detail_z: float = rng.randf_range(-1.25, 1.25)
			var detail_pos := _row_local(row, x, 0.0, detail_z)
			if rng.randf() < 0.55:
				_grass_clump(detail_pos, rng)
			else:
				_fern(detail_pos, rng)

		if rng.randf() < 0.55:
			_pebble_cluster(parent, _row_local(row, side * rng.randf_range(path_width * 0.5 - 0.15, path_width * 0.5 + 0.45), 0.02, rng.randf_range(-1.2, 1.2)), rng)
		if rng.randf() < 0.30:
			_root_strip(parent, _row_local(row, 0.0, 0.02, rng.randf_range(-1.1, 1.1)), rng)

func _spawn_obstacles(data: Dictionary) -> void:
	var obstacles: Array = data.get("obstacles", [])
	var skip_chance: float = AdaptiveDifficulty.get_obstacle_skip_chance(_level_id)
	for ob in obstacles:
		if skip_chance > 0.0 and randf() < skip_chance:
			continue
		var kind: String = ob.get("type", "rock")
		var lane: int = ob.get("lane", 1)
		var row: int = ob.get("row", 5)
		_spawn_obstacle(kind, lane, row)

func _spawn_obstacle(kind: String, lane: int, row: int) -> void:
	# Clear 3 tiles of approach AND 3 tiles of exit around every turn corner
	for tr in _turn_rows.keys():
		if row >= tr - 3 and row <= tr + 3:
			return

	var base := _world_pos(row, 1)  # centre of path at this row
	var lane_pos := _world_pos(row, lane)
	var seg_f: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	var heading_y := atan2(seg_f.x, -seg_f.z)

	match kind:
		"log":
			_obstacle_log(base + Vector3(0.0, 0.34, 0.0), heading_y)
		"branch", "low_branch":
			_obstacle_low_branch(base + Vector3(0.0, 1.32, 0.0), heading_y)
		"rock":
			_obstacle_rock(lane_pos + Vector3(0.0, 0.42, 0.0))
		"spike":
			_obstacle_spikes(lane_pos + Vector3(0.0, 0.38, 0.0))
		"thorn", "thorn_bush":
			_obstacle_thorn_bush(lane_pos + Vector3(0.0, 0.38, 0.0))
		"water_rock", "river_rock":
			_obstacle_water_rock(lane_pos + Vector3(0.0, 0.35, 0.0))
		"floating_log":
			_obstacle_floating_log(base + Vector3(0.0, 0.20, 0.0), heading_y)
		"crocodile_zone":
			_obstacle_crocodile_zone(lane_pos + Vector3(0.0, 0.12, 0.0), heading_y)
		"whirlpool":
			_obstacle_whirlpool(lane_pos + Vector3(0.0, 0.08, 0.0))
		"crate":
			_obstacle_crate(lane_pos + Vector3(0.0, 0.38, 0.0))
		"broken_plank", "falling_plank":
			_obstacle_broken_planks(lane_pos + Vector3(0.0, 0.24, 0.0), heading_y)
		"mud":
			_area_slow(Vector3(_seg_width.get(row, PATH_WIDTH), 0.05, TILE_Z), COLOR_MUD, base + Vector3(0.0, 0.03, 0.0))
		"gap":
			_remove_ground_at(row)
		_:
			_obstacle_rock(lane_pos + Vector3(0.0, 0.42, 0.0))

func _obstacle_log(pos: Vector3, heading_y: float = 0.0) -> void:
	var root := Node3D.new()
	root.name = "JumpLog"
	root.position = pos
	root.rotation.y = heading_y
	_group("Obstacles").add_child(root)

	if _place_glb(root, "res://assets/3d/obstacles/fallen_log.glb", Vector3.ZERO, Vector3(1.0, 1.0, 1.0)) == null:
		# Cylinder height is local Y; rotation.z = 90 makes height go along local X (= path right)
		var log := _add_cylinder(root, "Log", 0.26, 0.31, PATH_WIDTH * 0.92, Vector3.ZERO, COLOR_LOG)
		log.rotation_degrees.z = 90.0
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			var cap := _add_cylinder(root, "CutFace", 0.28, 0.28, 0.08, Vector3(side * PATH_WIDTH * 0.46, 0.0, 0.0), Color(0.58, 0.38, 0.18))
			cap.rotation_degrees.z = 90.0

	# Collision box: X-width spans path, Z-depth is obstacle thickness (both in local space)
	_add_static_box(root, "LogCollision", Vector3(PATH_WIDTH * 0.90, 0.58, 0.55), Vector3.ZERO, {"obstacle": true})
	_grass_clump(Vector3(-2.75, 0.0, pos.z + 0.35), RandomNumberGenerator.new())
	_grass_clump(Vector3(2.75, 0.0, pos.z - 0.35), RandomNumberGenerator.new())

func _obstacle_low_branch(pos: Vector3, heading_y: float = 0.0) -> void:
	var root := Node3D.new()
	root.name = "SlideBranch"
	root.position = pos
	root.rotation.y = heading_y
	_group("Obstacles").add_child(root)

	var branch := _add_cylinder(root, "LowBranch", 0.13, 0.17, PATH_WIDTH * 0.95, Vector3.ZERO, COLOR_LOG)
	branch.rotation_degrees.z = 90.0
	_add_static_box(root, "BranchCollision", Vector3(PATH_WIDTH * 0.95, 0.30, 0.42), Vector3.ZERO, {"obstacle": true})

	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var vine := _add_box(root, "HangingVine", Vector3(0.08, 0.72, 0.08), Vector3(side * 1.45, -0.46, 0.0), COLOR_FERN)
		vine.rotation_degrees.z = side * 8.0
		_add_box(root, "BranchLeaf", Vector3(0.42, 0.10, 0.22), Vector3(side * 2.05, -0.22, 0.0), COLOR_LEAF)

func _obstacle_rock(pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "DodgeRock"
	root.position = pos
	_group("Obstacles").add_child(root)

	if _place_glb(root, "res://assets/3d/obstacles/rock_obstacle.glb", Vector3.ZERO, Vector3(1.0, 1.0, 1.0)) == null:
		var main := _add_sphere(root, "RockMain", 0.55, Vector3.ZERO, COLOR_ROCK)
		main.scale = Vector3(1.0, 0.72, 0.88)
		var side := _add_sphere(root, "RockSide", 0.32, Vector3(0.33, -0.12, 0.20), COLOR_STONE_DARK)
		side.scale = Vector3(1.05, 0.75, 0.80)
		var moss := _add_box(root, "RockMoss", Vector3(0.55, 0.06, 0.30), Vector3(-0.08, 0.38, -0.10), COLOR_MOSS)
		moss.rotation_degrees.y = 15.0
	_add_static_box(root, "RockCollision", Vector3(1.05, 0.90, 1.00), Vector3.ZERO, {"obstacle": true})

func _obstacle_spikes(pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "TempleStakes"
	root.position = pos
	_group("Obstacles").add_child(root)

	if _place_glb(root, "res://assets/3d/obstacles/spike_trap.glb", Vector3.ZERO, Vector3(1.0, 1.0, 1.0)) == null:
		for i in range(3):
			var spike := _add_cylinder(root, "Stake", 0.0, 0.15, 0.76, Vector3(-0.28 + float(i) * 0.28, 0.0, 0.0), COLOR_SPIKE)
			spike.rotation_degrees.z = -7.0 + float(i) * 7.0
	_add_static_box(root, "SpikeCollision", Vector3(0.95, 0.70, 0.78), Vector3(0.0, 0.0, 0.0), {"obstacle": true})

func _obstacle_thorn_bush(pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "ThornBush"
	root.position = pos
	_group("Obstacles").add_child(root)
	if _place_glb(root, "res://assets/3d/environment/foliage/bushes.glb", Vector3.ZERO, Vector3(1.1, 1.1, 1.1)) == null:
		for i in range(4):
			var leaf := _add_sphere(root, "Bramble%d" % i, 0.28, Vector3(-0.32 + float(i) * 0.20, 0.02 + float(i % 2) * 0.10, randf_range(-0.16, 0.16)), Color(0.10, 0.28, 0.08))
			leaf.scale = Vector3(1.15, 0.68, 0.92)
		for t in range(6):
			var thorn := _add_cylinder(root, "Thorn%d" % t, 0.0, 0.045, 0.26, Vector3(randf_range(-0.42, 0.42), 0.18, randf_range(-0.22, 0.22)), Color(0.72, 0.18, 0.10))
			thorn.rotation_degrees.z = randf_range(-34.0, 34.0)
	_add_static_box(root, "ThornCollision", Vector3(1.05, 0.78, 0.92), Vector3.ZERO, {"obstacle": true})

func _obstacle_water_rock(pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "WaterRock"
	root.position = pos
	_group("Obstacles").add_child(root)
	var rock := _add_sphere(root, "SlickRock", 0.44, Vector3.ZERO, Color(0.26, 0.36, 0.40))
	rock.scale = Vector3(1.15, 0.52, 0.85)
	_add_box(root, "WetHighlight", Vector3(0.46, 0.035, 0.20), Vector3(0.02, 0.24, -0.03), Color(0.72, 0.92, 0.96, 0.75))
	_add_static_box(root, "WaterRockCollision", Vector3(0.95, 0.62, 0.86), Vector3.ZERO, {"obstacle": true})

func _obstacle_floating_log(pos: Vector3, heading_y: float) -> void:
	var root := Node3D.new()
	root.name = "FloatingLog"
	root.position = pos
	root.rotation.y = heading_y
	_group("Obstacles").add_child(root)
	var log := _add_cylinder(root, "Log", 0.18, 0.20, PATH_WIDTH * 0.75, Vector3.ZERO, COLOR_LOG)
	log.rotation_degrees.z = 90.0
	_add_static_box(root, "FloatingLogCollision", Vector3(PATH_WIDTH * 0.72, 0.45, 0.48), Vector3.ZERO, {"obstacle": true})

func _obstacle_crocodile_zone(pos: Vector3, heading_y: float) -> void:
	var root := Node3D.new()
	root.name = "CrocodileDangerZone"
	root.position = pos
	root.rotation.y = heading_y
	_group("Obstacles").add_child(root)
	_add_box(root, "RedWarningWater", Vector3(1.1, 0.035, 1.1), Vector3.ZERO, Color(0.50, 0.05, 0.04, 0.65))
	var body := _add_box(root, "CrocodileBack", Vector3(0.76, 0.16, 0.24), Vector3(0.0, 0.12, 0.0), Color(0.10, 0.28, 0.10))
	body.rotation_degrees.y = 10.0
	for i in range(4):
		_add_box(root, "BackRidge%d" % i, Vector3(0.08, 0.09, 0.08), Vector3(-0.24 + float(i) * 0.16, 0.25, 0.0), Color(0.05, 0.16, 0.05))
	_add_static_box(root, "CrocodileCollision", Vector3(1.0, 0.70, 1.0), Vector3.ZERO, {"obstacle": true})

func _obstacle_whirlpool(pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Whirlpool"
	root.position = pos
	_group("Obstacles").add_child(root)
	for i in range(3):
		var ring := _add_cylinder(root, "Ring%d" % i, 0.26 + float(i) * 0.16, 0.26 + float(i) * 0.16, 0.035, Vector3(0.0, 0.01 + float(i) * 0.01, 0.0), Color(0.70, 0.92, 1.0, 0.55))
		ring.rotation_degrees.x = 90.0
		ring.scale.y = 0.32
	_add_static_box(root, "WhirlpoolCollision", Vector3(1.1, 0.70, 1.1), Vector3.ZERO, {"obstacle": true})

func _obstacle_crate(pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "SupplyCrate"
	root.position = pos
	_group("Obstacles").add_child(root)
	_add_box(root, "Crate", Vector3(0.72, 0.72, 0.72), Vector3.ZERO, Color(0.46, 0.28, 0.12))
	_add_box(root, "CrateBandA", Vector3(0.78, 0.08, 0.78), Vector3(0.0, 0.18, 0.0), Color(0.64, 0.44, 0.20))
	_add_box(root, "CrateBandB", Vector3(0.08, 0.78, 0.78), Vector3(0.0, 0.0, 0.0), Color(0.64, 0.44, 0.20))
	_add_static_box(root, "CrateCollision", Vector3(0.76, 0.82, 0.76), Vector3.ZERO, {"obstacle": true})

func _obstacle_broken_planks(pos: Vector3, heading_y: float) -> void:
	var root := Node3D.new()
	root.name = "BrokenPlanks"
	root.position = pos
	root.rotation.y = heading_y
	_group("Obstacles").add_child(root)
	if _place_glb(root, "res://assets/3d/obstacles/slide_barrier.glb", Vector3.ZERO, Vector3(1.0, 1.0, 1.0)) == null:
		for i in range(3):
			var plank := _add_box(root, "Plank%d" % i, Vector3(0.22, 0.08, 0.92), Vector3(-0.30 + float(i) * 0.30, 0.0, randf_range(-0.12, 0.12)), COLOR_LOG)
			plank.rotation_degrees.y = randf_range(-18.0, 18.0)
	_add_static_box(root, "BrokenPlankCollision", Vector3(1.0, 0.55, 0.90), Vector3.ZERO, {"obstacle": true})

func _area_slow(size: Vector3, color: Color, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "MudPatch"
	root.position = pos
	_group("Obstacles").add_child(root)
	_add_box(root, "Mud", size, Vector3.ZERO, color)

func _remove_ground_at(row: int) -> void:
	if _path_tiles.has(row):
		var tile := _path_tiles[row] as Node3D
		if is_instance_valid(tile):
			tile.queue_free()
		_path_tiles.erase(row)

	var sp: Vector3 = _seg_pos.get(row, Vector3(0.0, 0.0, -float(row) * TILE_Z))
	var sf: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	var gap_center := sp + sf * (TILE_Z * 0.5)

	# Visual gap: dark water strip
	var gap_vis := Node3D.new()
	gap_vis.name = "RiverGap_%02d" % row
	gap_vis.position = gap_center
	gap_vis.rotation.y = atan2(sf.x, -sf.z)
	_group("Terrain").add_child(gap_vis)
	_add_box(gap_vis, "Water", Vector3(PATH_WIDTH, 0.08, TILE_Z), Vector3(0.0, -0.22, 0.0), Color(0.06, 0.18, 0.24))
	# Water shimmer strips
	_add_box(gap_vis, "Shimmer1", Vector3(PATH_WIDTH * 0.6, 0.02, TILE_Z * 0.25), Vector3(-0.4, -0.15, TILE_Z * 0.1), Color(0.14, 0.44, 0.62, 0.60))
	_add_box(gap_vis, "Shimmer2", Vector3(PATH_WIDTH * 0.4, 0.02, TILE_Z * 0.20), Vector3(0.6, -0.15, -TILE_Z * 0.15), Color(0.14, 0.44, 0.62, 0.50))

	# Kill zone — triggers player death when falling into the gap
	var kill := Area3D.new()
	kill.name = "GapKillZone_%02d" % row
	var kill_col := CollisionShape3D.new()
	kill_col.shape = BoxShape3D.new()
	(kill_col.shape as BoxShape3D).size = Vector3(PATH_WIDTH + 0.4, 1.2, TILE_Z)
	kill_col.position = Vector3(0.0, -0.6, 0.0)
	kill.add_child(kill_col)
	kill.body_entered.connect(_on_gap_body_entered)
	gap_vis.add_child(kill)

func _on_gap_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.call("die")

func _spawn_coins(data: Dictionary) -> void:
	var coins: Array = data.get("coins", [])
	for c in coins:
		var lane: int = c.get("lane", 1)
		var row: int = c.get("row", 3)
		var is_gem: bool = c.get("gem", false)
		_spawn_coin(lane, row, is_gem)

func _spawn_coin(lane: int, row: int, is_gem: bool) -> void:
	var coin := Node3D.new()
	coin.name = "Gem" if is_gem else "Coin"
	var base_pos := _world_pos(row, lane)
	coin.position = Vector3(base_pos.x, 0.80, base_pos.z)
	coin.set_meta("base_y", coin.position.y)
	coin.set_meta("phase", float(row) * 0.35 + float(lane))

	var _glb_key := "gem" if is_gem else "coin"
	if _place_glb(coin, "res://assets/3d/collectibles/%s.glb" % _glb_key, Vector3.ZERO, Vector3(0.35, 0.35, 0.35)) == null:
		if is_gem:
			var gem := _add_sphere(coin, "GemMesh", 0.25, Vector3.ZERO, COLOR_GEM)
			gem.scale = Vector3(0.85, 1.25, 0.85)
		else:
			var mesh := _add_cylinder(coin, "CoinMesh", 0.27, 0.27, 0.08, Vector3.ZERO, COLOR_COIN)
			mesh.rotation_degrees.x = 90.0
			var inset := _add_cylinder(coin, "CoinInset", 0.16, 0.16, 0.09, Vector3(0.0, 0.0, 0.01), COLOR_DIRT_LIGHT)
			inset.rotation_degrees.x = 90.0

	var area := Area3D.new()
	area.name = "PickupArea"
	var col := CollisionShape3D.new()
	col.shape = SphereShape3D.new()
	(col.shape as SphereShape3D).radius = 0.38
	area.add_child(col)
	area.set_meta("coin", true)
	area.set_meta("is_gem", is_gem)
	area.body_entered.connect(_on_coin_body_entered.bind(coin, is_gem))
	coin.add_child(area)

	_coin_nodes.append(coin)
	_group("Collectibles").add_child(coin)

func _collect_coin_node(coin_node: Node3D) -> void:
	if not is_instance_valid(coin_node):
		return
	coin_node.queue_free()
	_coin_nodes.erase(coin_node)
	EventBus.play_sfx.emit("coin")
	GameManager.collect_coin()
	_coin_count += 1
	coin_collected.emit(_coin_count)

func _on_coin_body_entered(body: Node3D, coin_node: Node3D, is_gem: bool) -> void:
	if not (body is CharacterBody3D):
		return
	if not is_instance_valid(coin_node):
		return
	if body.has_method("play_collect"):
		body.call("play_collect")
	coin_node.queue_free()
	_coin_nodes.erase(coin_node)
	if is_gem:
		EventBus.play_sfx.emit("gem")
		GameManager.collect_gem()
	else:
		EventBus.play_sfx.emit("coin")
		GameManager.collect_coin()
		_coin_count += 1
		coin_collected.emit(_coin_count)

func _spawn_dressing(data: Dictionary) -> void:
	var length: int = data.get("length", 30)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 42))

	if _level_id == 6:
		_spawn_wildlands_dressing(data, rng)
		return

	for row in range(1, length + 4):
		var path_width: float = _seg_width.get(row, PATH_WIDTH)
		var path_edge := path_width * 0.5
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			var near_x: float = side * rng.randf_range(path_edge + 0.35, path_edge + 0.85)
			var mid_x: float = side * rng.randf_range(path_edge + 1.05, path_edge + 1.85)
			var far_x: float = side * rng.randf_range(path_edge + 2.35, path_edge + 3.35)

			if rng.randf() < 0.80:
				_grass_clump(_row_local(row, near_x, 0.0, rng.randf_range(-0.8, 0.8)), rng)
			if rng.randf() < 0.55:
				_fern(_row_local(row, near_x + side * rng.randf_range(0.2, 0.45), 0.0, rng.randf_range(-0.6, 0.6)), rng)
			if rng.randf() < 0.72:
				_bush(_row_local(row, mid_x, 0.0, rng.randf_range(-0.9, 0.9)), rng)
			if rng.randf() < 0.35:
				_pebble_cluster(_group("RocksAndLogs"), _row_local(row, mid_x + side * 0.30, 0.04, rng.randf_range(-0.8, 0.8)), rng)

			if row % 2 == 0:
				if rng.randf() < 0.45:
					_palm_tree(_row_local(row, far_x, 0.0), rng)
				else:
					_jungle_tree(_row_local(row, far_x, 0.0), rng)

			if row % 4 == 1 and rng.randf() < 0.50:
				_fallen_log_dressing(_row_local(row, side * rng.randf_range(path_edge + 1.35, path_edge + 2.10), 0.18, rng.randf_range(-1.0, 1.0)), side, rng)

			if row % 5 == 0 and rng.randf() < 0.65:
				_ruin_fragment(_row_local(row, side * rng.randf_range(path_edge + 2.0, path_edge + 2.8), 0.0), rng)

func _spawn_wildlife(data: Dictionary) -> void:
	var length: int = data.get("length", 30)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 42)) + 909

	if _level_id == 6:
		_spawn_wildlands_wildlife(data, rng)
		return

	for i in range(3):
		var row := 4 + i * 6
		_butterfly(
			Vector3(
				(-1.0 if i % 2 == 0 else 1.0) * rng.randf_range(2.7, 3.5),
				rng.randf_range(0.8, 1.25),
				-float(row) * TILE_Z + rng.randf_range(-0.8, 0.8)
			),
			rng
		)

	for i in range(2):
		var row := 6 + i * 8
		_bird(
			Vector3(-5.8, rng.randf_range(2.9, 3.8), -float(row) * TILE_Z),
			Vector3(5.8, rng.randf_range(3.0, 4.0), -float(row + 2) * TILE_Z),
			rng
		)

	if length > 24:
		_butterfly(Vector3(3.1, 1.0, -float(length - 4) * TILE_Z), rng)

	# Ambient jungle wildlife at path edges
	if length > 12:
		_wildlife_glb("monkey",      Vector3(rng.randf_range(3.2, 4.5), 1.8, -float(rng.randi_range(5, length - 5)) * TILE_Z), Vector3(0.55, 0.55, 0.55), rng.randf_range(0.0, 360.0))
		_wildlife_glb("weaver_bird", Vector3(-rng.randf_range(3.0, 4.2), 2.5, -float(rng.randi_range(8, length - 4)) * TILE_Z), Vector3(0.35, 0.35, 0.35), rng.randf_range(0.0, 360.0))
	if length > 18:
		_wildlife_glb("frog",        Vector3(rng.randf_range(2.8, 3.8), 0.05, -float(rng.randi_range(6, length - 6)) * TILE_Z), Vector3(0.45, 0.45, 0.45), rng.randf_range(0.0, 360.0))
		_wildlife_glb("snake",       Vector3(-rng.randf_range(3.0, 4.0), 0.02, -float(rng.randi_range(10, length - 5)) * TILE_Z), Vector3(0.50, 0.50, 0.50), rng.randf_range(0.0, 360.0))

func _grass_clump(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "GrassClump"
	root.position = pos
	_group("GrassAndPlants").add_child(root)
	_register_wind(root, 0.075, 1.35, rng.randf_range(0.0, TAU))

	if _place_glb(root, "res://assets/3d/environment/foliage/grass_clumps.glb", Vector3.ZERO, Vector3(0.55, 0.55, 0.55)) == null:
		var blades := 3 + rng.randi_range(0, 3)
		for i in range(blades):
			var blade := _add_box(root, "Blade", Vector3(0.07, rng.randf_range(0.35, 0.70), 0.07), Vector3(rng.randf_range(-0.18, 0.18), 0.18, rng.randf_range(-0.16, 0.16)), _grass_color(rng))
			blade.rotation_degrees.z = rng.randf_range(-18.0, 18.0)
			blade.rotation_degrees.x = rng.randf_range(-10.0, 10.0)

func _fern(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "Fern"
	root.position = pos
	root.rotation_degrees.y = rng.randf_range(0.0, 360.0)
	_group("GrassAndPlants").add_child(root)
	_register_wind(root, 0.060, 1.12, rng.randf_range(0.0, TAU))

	if _place_glb(root, "res://assets/3d/environment/foliage/ferns.glb", Vector3.ZERO, Vector3(0.60, 0.60, 0.60)) == null:
		for i in range(5):
			var leaf := _add_box(root, "FernLeaf", Vector3(0.10, 0.06, rng.randf_range(0.45, 0.70)), Vector3(0.0, 0.20 + float(i) * 0.04, 0.0), COLOR_FERN.lerp(COLOR_GRASS_LIGHT, rng.randf_range(0.0, 0.35)))
			leaf.rotation_degrees.y = -55.0 + float(i) * 27.5
			leaf.rotation_degrees.x = rng.randf_range(-18.0, -8.0)

func _bush(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "Bush"
	root.position = pos
	_group("GrassAndPlants").add_child(root)
	_register_wind(root, 0.035, 0.88, rng.randf_range(0.0, TAU))

	if _place_glb(root, "res://assets/3d/environment/foliage/bushes.glb", Vector3.ZERO, Vector3(0.70, 0.70, 0.70)) == null:
		var blobs := 3 + rng.randi_range(0, 2)
		for i in range(blobs):
			var leaf := _add_sphere(root, "BushLeaf", rng.randf_range(0.35, 0.55), Vector3(rng.randf_range(-0.30, 0.30), rng.randf_range(0.25, 0.55), rng.randf_range(-0.25, 0.25)), _grass_color(rng).lerp(COLOR_LEAF, 0.35))
			leaf.scale = Vector3(rng.randf_range(0.85, 1.25), rng.randf_range(0.62, 0.90), rng.randf_range(0.85, 1.20))

func _palm_tree(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "PalmTree"
	root.position = pos
	root.rotation_degrees.y = rng.randf_range(0.0, 360.0)
	_group("Trees").add_child(root)
	_register_wind(root, 0.018, 0.48, rng.randf_range(0.0, TAU))

	if _place_glb(root, "res://assets/3d/environment/trees/palms.glb", Vector3.ZERO, Vector3(1.0, 1.0, 1.0)) != null:
		return

	var height := rng.randf_range(3.4, 5.0)
	var trunk_col := COLOR_TRUNK.lerp(Color(0.50, 0.33, 0.14), rng.randf_range(0.0, 0.30))
	var trunk := _add_cylinder(root, "PalmTrunk", 0.10, 0.22, height, Vector3(0.0, height * 0.5, 0.0), trunk_col)
	trunk.rotation_degrees.z = rng.randf_range(-10.0, 10.0)

	# Bark ring notches along trunk
	for r in range(5):
		var ring_y := height * (0.18 + float(r) * 0.15)
		_add_box(root, "BarkRing%d" % r,
			Vector3(0.30, 0.05, 0.30),
			Vector3(0.0, ring_y, 0.0),
			trunk_col.lerp(Color(0.58, 0.40, 0.18), 0.35)
		)

	# Arching fronds spread in a crown
	var frond_count := rng.randi_range(7, 10)
	var leaf_col := COLOR_PALM.lerp(COLOR_GRASS_LIGHT, rng.randf_range(0.0, 0.28))
	for i in range(frond_count):
		var angle_deg := float(i) / float(frond_count) * 360.0
		var angle_rad := deg_to_rad(angle_deg)
		var droop := rng.randf_range(-42.0, -26.0)
		var frond_len := rng.randf_range(1.50, 2.10)
		# Offset center of frond so base is at crown, tip fans outward
		var off_x := cos(angle_rad) * 0.38
		var off_z := sin(angle_rad) * 0.38
		var leaf := _add_box(root, "PalmFrond%d" % i,
			Vector3(0.20, 0.06, frond_len),
			Vector3(off_x, height + 0.05, off_z),
			leaf_col
		)
		leaf.rotation_degrees.y = angle_deg
		leaf.rotation_degrees.x = droop

	# Small coconut cluster near crown
	if rng.randf() < 0.55:
		for k in range(rng.randi_range(2, 4)):
			_add_sphere(root, "Coconut%d" % k, 0.10,
				Vector3(rng.randf_range(-0.26, 0.26), height - 0.18, rng.randf_range(-0.22, 0.22)),
				Color(0.40, 0.26, 0.08)
			)

	if rng.randf() < 0.40:
		_vine(root, Vector3(rng.randf_range(-0.16, 0.16), height * 0.68, rng.randf_range(-0.14, 0.14)), rng)

func _jungle_tree(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "JungleTree"
	root.position = pos
	root.rotation_degrees.y = rng.randf_range(0.0, 360.0)
	_group("Trees").add_child(root)
	_register_wind(root, 0.014, 0.42, rng.randf_range(0.0, TAU))

	if _place_glb(root, "res://assets/3d/environment/trees/jungle_trees.glb", Vector3.ZERO, Vector3(1.0, 1.0, 1.0)) != null:
		return

	var height := rng.randf_range(3.0, 4.8)
	var trunk_col := COLOR_TRUNK.lerp(Color(0.28, 0.16, 0.06), rng.randf_range(0.0, 0.40))

	# Tapered trunk — narrow at top
	_add_cylinder(root, "Trunk", 0.10, 0.28, height, Vector3(0.0, height * 0.5, 0.0), trunk_col)

	# Buttress root flanges at base (2–3 thin wedges fanning out)
	var buttress_count := rng.randi_range(2, 3)
	for b in range(buttress_count):
		var ba := float(b) / float(buttress_count) * TAU + rng.randf_range(-0.15, 0.15)
		var br := _add_box(root, "Buttress%d" % b,
			Vector3(0.07, height * 0.28, 0.22),
			Vector3(cos(ba) * 0.22, height * 0.14, sin(ba) * 0.22),
			trunk_col.lerp(COLOR_LOG, 0.3)
		)
		br.rotation_degrees.y = rad_to_deg(ba)
		br.rotation_degrees.x = 20.0

	# Layered cone canopy — widest tier at bottom, smallest at top
	var tier_count := rng.randi_range(3, 4)
	var base_r := rng.randf_range(0.85, 1.20)
	var canopy_start_y := height * 0.52

	for t in range(tier_count):
		var t_frac := float(t) / float(tier_count - 1)
		var tier_r := base_r * (1.0 - t_frac * 0.62)
		var tier_h := 0.80 - t_frac * 0.24
		var tier_y := canopy_start_y + float(t) * 0.52 + tier_h * 0.5
		var tier_col := _grass_color(rng).lerp(COLOR_LEAF, rng.randf_range(0.30, 0.62))
		var cone := _add_cylinder(root, "Canopy%d" % t, 0.0, tier_r, tier_h,
			Vector3(0.0, tier_y, 0.0), tier_col)
		cone.rotation_degrees.x = rng.randf_range(-4.0, 4.0)
		cone.rotation_degrees.z = rng.randf_range(-4.0, 4.0)

	# Secondary branch sticking out mid-trunk
	if rng.randf() < 0.55:
		var branch_y := height * rng.randf_range(0.40, 0.58)
		var branch_side := 1.0 if rng.randf() < 0.5 else -1.0
		var br2 := _add_cylinder(root, "Branch",
			0.04, 0.10, rng.randf_range(0.55, 0.90),
			Vector3(branch_side * 0.30, branch_y, 0.0),
			trunk_col)
		br2.rotation_degrees.z = branch_side * rng.randf_range(55.0, 75.0)
		# Small leaf cluster at branch tip
		_add_sphere(root, "BranchLeaves",
			rng.randf_range(0.25, 0.38),
			Vector3(branch_side * rng.randf_range(0.65, 0.88), branch_y + 0.10, 0.0),
			_grass_color(rng).lerp(COLOR_LEAF, 0.5)
		)

	if rng.randf() < 0.55:
		_vine(root, Vector3(rng.randf_range(-0.22, 0.22), canopy_start_y + 0.25, rng.randf_range(-0.18, 0.18)), rng)

func _vine(parent: Node3D, pos: Vector3, rng: RandomNumberGenerator) -> void:
	if _place_glb(parent, "res://assets/3d/environment/foliage/vines.glb", pos + Vector3(0.0, -0.40, 0.0), Vector3(0.45, 0.45, 0.45)) != null:
		return
	var vine := _add_box(parent, "Vine", Vector3(0.07, rng.randf_range(0.80, 1.35), 0.07), pos + Vector3(0.0, -0.40, 0.0), COLOR_FERN)
	vine.rotation_degrees.z = rng.randf_range(-8.0, 8.0)

func _pebble_cluster(parent: Node3D, pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "Pebbles"
	root.position = pos
	parent.add_child(root)
	if _place_glb(root, "res://assets/3d/environment/rocks/rock_clusters.glb", Vector3.ZERO, Vector3(0.50, 0.50, 0.50)) == null:
		for i in range(3):
			var pebble := _add_sphere(root, "Pebble", rng.randf_range(0.08, 0.16), Vector3(rng.randf_range(-0.28, 0.28), 0.05, rng.randf_range(-0.22, 0.22)), COLOR_ROCK.lerp(COLOR_STONE_DARK, rng.randf_range(0.0, 0.45)))
			pebble.scale = Vector3(1.2, 0.45, 1.0)

func _root_strip(parent: Node3D, pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := _add_box(parent, "RootStrip", Vector3(rng.randf_range(1.0, 1.8), 0.06, 0.08), pos, COLOR_LOG)
	root.rotation_degrees.y = rng.randf_range(-22.0, 22.0)

func _fallen_log_dressing(pos: Vector3, side: float, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "SideFallenLog"
	root.position = pos
	root.rotation_degrees.y = side * rng.randf_range(20.0, 45.0)
	_group("RocksAndLogs").add_child(root)
	if _place_glb(root, "res://assets/3d/obstacles/fallen_log.glb", Vector3.ZERO, Vector3(0.70, 0.70, 0.70)) == null:
		var log := _add_cylinder(root, "SideLog", 0.18, 0.24, rng.randf_range(1.2, 2.2), Vector3.ZERO, COLOR_LOG)
		log.rotation_degrees.x = 90.0

func _ruin_fragment(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "MossyRuin"
	root.position = pos
	root.rotation_degrees.y = rng.randf_range(-18.0, 18.0)
	_group("Ruins").add_child(root)

	if _place_glb(root, "res://assets/3d/environment/rocks/rock_clusters.glb", Vector3.ZERO, Vector3(0.60, 0.60, 0.60)) != null:
		return

	_add_box(root, "BrokenStone", Vector3(0.55, rng.randf_range(0.55, 1.20), 0.45), Vector3(0.0, 0.35, 0.0), COLOR_STONE)
	var cap := _add_box(root, "Moss", Vector3(0.60, 0.08, 0.48), Vector3(0.0, 0.95, 0.0), COLOR_MOSS)
	cap.rotation_degrees.z = rng.randf_range(-6.0, 6.0)

func _butterfly(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "Butterfly"
	root.position = pos
	_group("Animals").add_child(root)

	if _place_glb(root, "res://assets/3d/wildlife/butterfly.glb", Vector3.ZERO, Vector3(0.18, 0.18, 0.18)) == null:
		var body_color := Color(0.12, 0.10, 0.09)
		var wing_color := Color(1.0, rng.randf_range(0.35, 0.75), rng.randf_range(0.10, 0.45))
		_add_box(root, "Body", Vector3(0.04, 0.16, 0.04), Vector3.ZERO, body_color)
		var left := _add_box(root, "WingLeft", Vector3(0.18, 0.04, 0.11), Vector3(-0.10, 0.05, 0.0), wing_color)
		left.rotation_degrees.z = 22.0
		var right := _add_box(root, "WingRight", Vector3(0.18, 0.04, 0.11), Vector3(0.10, 0.05, 0.0), wing_color)
		right.rotation_degrees.z = -22.0

	_butterflies.append({
		"node": root,
		"origin": pos,
		"phase": rng.randf_range(0.0, PI * 2.0),
		"speed": rng.randf_range(1.1, 1.8),
		"amp": rng.randf_range(0.18, 0.32)
	})

func _bird(start_pos: Vector3, end_pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "ParrotFlyover"
	root.position = start_pos
	_group("Animals").add_child(root)

	if _place_glb(root, "res://assets/3d/wildlife/bird.glb", Vector3.ZERO, Vector3(0.30, 0.30, 0.30)) == null:
		var body := _add_sphere(root, "Body", 0.18, Vector3.ZERO, Color(0.10, 0.48, 0.26))
		body.scale = Vector3(1.15, 0.80, 1.45)
		_add_box(root, "Beak", Vector3(0.12, 0.08, 0.18), Vector3(0.0, 0.02, -0.22), Color(1.0, 0.68, 0.08))
		var left := _add_box(root, "WingLeft", Vector3(0.52, 0.06, 0.18), Vector3(-0.33, 0.0, 0.0), Color(0.10, 0.38, 0.82))
		left.rotation_degrees.z = 12.0
		var right := _add_box(root, "WingRight", Vector3(0.52, 0.06, 0.18), Vector3(0.33, 0.0, 0.0), Color(0.10, 0.38, 0.82))
		right.rotation_degrees.z = -12.0
	root.look_at(end_pos, Vector3.UP)

	_birds.append({
		"node": root,
		"start": start_pos,
		"end": end_pos,
		"phase": rng.randf_range(0.0, 1.0),
		"speed": rng.randf_range(0.035, 0.055)
	})

func _spawn_module_landmarks(data: Dictionary) -> void:
	var length: int = data.get("length", 30)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 42)) + 6161
	var last_module := ""
	var spawned_chase := false
	var spawned_escape := false
	var spawned_boat := false
	var spawned_slide := false
	var spawned_skating := false

	for row in range(1, length):
		var kind := str(_seg_module.get(row, ""))
		var mode := str(_seg_mode.get(row, "run"))
		if kind != "" and kind != last_module:
			_spawn_module_start_marker(row, kind)
			last_module = kind

		if mode == "tracking" and row % 3 == 0:
			_spawn_footprints(row, row % 3, Color(0.18, 0.12, 0.06))
		elif mode == "chase":
			if row % 3 == 0:
				_spawn_footprints(row, int(row / 3) % 3, Color(0.32, 0.20, 0.06))
			if not spawned_chase:
				_spawn_simple_animal(_level_chase_animal(), min(length - 3, row + 5), 1, true)
				spawned_chase = true
		elif mode == "escape" and not spawned_escape:
			_spawn_simple_animal("boar", max(1, row - 2), 1, false)
			_spawn_warning_marker(row + 1, "RUN TO SAFETY")
			spawned_escape = true
		elif mode == "water_slide":
			if row % 2 == 0:
				_spawn_splash(row, rng)
			if not spawned_slide:
				_spawn_warning_marker(row, "WATER SLIDE")
				spawned_slide = true
		elif mode == "boat":
			if row % 3 == 0:
				_spawn_river_reeds(row, rng)
			if not spawned_boat:
				_spawn_dock_marker(row)
				spawned_boat = true
		elif mode == "skating" and not spawned_skating:
			_spawn_warning_marker(row, "SKATE RUN")
			spawned_skating = true

		match kind:
			"bridge_crossing":
				if row % 2 == 0:
					_spawn_bridge_posts(row)
			"ruins_corridor":
				if row % 2 == 0:
					_spawn_ruins_wall(row, rng)
			"sand_dune_curve":
				if row % 2 == 0:
					_spawn_sand_ridges(row, rng)

func _spawn_module_start_marker(row: int, kind: String) -> void:
	var label := _module_label(kind)
	if label.is_empty():
		return
	var path_width: float = _seg_width.get(row, PATH_WIDTH)
	var side := -1.0 if row % 2 == 0 else 1.0
	_spawn_signpost(row, side * (path_width * 0.5 + 0.75), label, Color(0.90, 0.68, 0.22))

func _module_label(kind: String) -> String:
	match kind:
		"narrow_passage":
			return "NARROW TRAIL"
		"bridge_crossing":
			return "BRIDGE"
		"water_slide_entry", "water_slide_curve", "water_slide_drop":
			return "WATER SLIDE"
		"boat_entry_dock", "boat_river_straight", "boat_river_curve", "boat_rapids":
			return "RIVER RUN"
		"skating_entry", "skating_straight", "skating_curve_left", "skating_curve_right":
			return "SKATE RUN"
		"animal_chase_lane":
			return "ANIMAL TRACKS"
		"animal_escape_section":
			return "DANGER BEHIND"
		"junction_two_way", "junction_three_way":
			return "CHOOSE TRAIL"
		"ruins_corridor":
			return "RUINS"
		"sand_dune_curve":
			return "SAND DUNES"
		"mud_path":
			return "TRACK PRINTS"
		_:
			return ""

func _spawn_junction_zones(_data: Dictionary) -> void:
	for junction_id in _junction_defs.keys():
		var def: Dictionary = _junction_defs[junction_id]
		var row := int(def.get("row", 0))
		var routes: Array = def.get("routes", [])
		_spawn_junction_visual(row, routes)

		var root := Node3D.new()
		root.name = "JunctionTrigger_" + str(junction_id)
		root.position = _row_center(max(0, row - 1))
		root.rotation.y = _row_heading_y(row)
		_group("RouteSigns").add_child(root)

		var area := Area3D.new()
		area.name = "Area"
		area.monitoring = true
		area.monitorable = false
		var col := CollisionShape3D.new()
		col.shape = BoxShape3D.new()
		(col.shape as BoxShape3D).size = Vector3(_seg_width.get(row, PATH_WIDTH) + 1.0, 2.6, TILE_Z * 3.2)
		col.position = Vector3(0.0, 1.15, 0.0)
		area.add_child(col)
		area.body_entered.connect(_on_junction_body_entered.bind(str(junction_id), routes))
		area.body_exited.connect(_on_junction_body_exited.bind(str(junction_id)))
		root.add_child(area)

func _spawn_junction_visual(row: int, routes: Array) -> void:
	var path_width: float = _seg_width.get(row, PATH_WIDTH)
	_spawn_warning_marker(max(1, row - 2), "TRAIL SPLIT")
	for raw_route in routes:
		if not (raw_route is Dictionary):
			continue
		var route: Dictionary = raw_route
		var direction := str(route.get("direction", "right"))
		var label := str(route.get("label", "Route"))
		var x := 0.0
		var rot := 0.0
		var color := Color(0.92, 0.72, 0.22)
		match direction:
			"left":
				x = -path_width * 0.43
				rot = 24.0
				color = Color(0.70, 0.95, 0.36)
			"right":
				x = path_width * 0.43
				rot = -24.0
				color = Color(0.96, 0.54, 0.22)
			_:
				x = 0.0
				rot = 0.0
				color = Color(0.56, 0.82, 1.0)
		_spawn_route_arrow(row, x, rot, color)
		_spawn_signpost(max(1, row - 1), x, label, color)

func _spawn_route_arrow(row: int, x: float, rot_y_degrees: float, color: Color) -> void:
	var root := Node3D.new()
	root.name = "RouteArrow"
	root.position = _row_local(row, x, 0.05, -0.45)
	root.rotation.y = _row_heading_y(row) + deg_to_rad(rot_y_degrees)
	_group("RouteSigns").add_child(root)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.75
	var shaft := _add_box(root, "Shaft", Vector3(0.22, 0.05, 0.92), Vector3(0.0, 0.0, 0.0), color)
	shaft.material_override = mat
	var head := _add_box(root, "Head", Vector3(0.64, 0.06, 0.36), Vector3(0.0, 0.0, -0.56), color)
	head.rotation_degrees.y = 45.0
	head.material_override = mat

func _on_junction_body_entered(body: Node3D, junction_id: String, routes: Array) -> void:
	if body is CharacterBody3D:
		junction_entered.emit(junction_id, routes)

func _on_junction_body_exited(body: Node3D, junction_id: String) -> void:
	if body is CharacterBody3D:
		junction_exited.emit(junction_id)

func apply_junction_choice(junction_id: String, direction: String, route: Dictionary) -> void:
	if not _junction_defs.has(junction_id):
		return
	var def: Dictionary = _junction_defs[junction_id]
	var row := int(def.get("row", 0))
	var lane := 1
	match direction:
		"left":
			lane = 0
		"right":
			lane = 2
		_:
			lane = 1
	var reward := str(route.get("reward", "coins"))
	var label := str(route.get("label", "Chosen Route"))
	_spawn_signpost(row + 1, _lane_x(lane), "TRAIL CHOSEN: " + label.to_upper(), Color(0.95, 0.84, 0.34))
	for step in range(2, 7):
		_spawn_coin(lane, row + step, false)
		_total_coins += 1
	if reward != "coins":
		_spawn_single_collectable(reward, lane, row + 7)

func _spawn_signpost(row: int, x: float, text: String, color: Color) -> void:
	var root := Node3D.new()
	root.name = "Signpost"
	root.position = _row_local(row, x, 0.0, 0.0)
	root.rotation.y = _row_heading_y(row)
	_group("RouteSigns").add_child(root)
	_add_cylinder(root, "Post", 0.045, 0.06, 0.92, Vector3(0.0, 0.46, 0.0), COLOR_LOG)
	_add_box(root, "Board", Vector3(1.38, 0.34, 0.08), Vector3(0.0, 0.96, 0.0), Color(0.34, 0.20, 0.08))
	var lbl := Label3D.new()
	lbl.name = "Text"
	lbl.text = text
	lbl.font_size = 34
	lbl.modulate = color
	lbl.outline_modulate = Color(0.02, 0.01, 0.0)
	lbl.outline_size = 8
	lbl.position = Vector3(0.0, 0.98, -0.055)
	lbl.scale = Vector3(0.018, 0.018, 0.018)
	root.add_child(lbl)

func _spawn_warning_marker(row: int, text: String) -> void:
	_spawn_signpost(row, 0.0, text, Color(1.0, 0.34, 0.12))

func _spawn_footprints(row: int, lane: int, color: Color) -> void:
	var root := Node3D.new()
	root.name = "Footprints"
	root.position = _world_pos(row, lane)
	root.rotation.y = _row_heading_y(row)
	_group("ModeEffects").add_child(root)
	for i in range(2):
		var print_mesh := _add_box(root, "Print%d" % i, Vector3(0.16, 0.025, 0.26), Vector3((-0.12 if i == 0 else 0.12), 0.035, -0.18 + float(i) * 0.36), color)
		print_mesh.rotation_degrees.y = -8.0 if i == 0 else 8.0

func _spawn_simple_animal(animal: String, row: int, lane: int, ahead: bool) -> void:
	var root := Node3D.new()
	root.name = animal.capitalize() + "Encounter"
	root.position = _world_pos(row, lane)
	root.rotation.y = _row_heading_y(row) + (0.0 if ahead else PI)
	_group("Animals").add_child(root)
	var body_col := Color(0.48, 0.30, 0.12)
	var scale := Vector3.ONE
	match animal:
		"rabbit":
			body_col = Color(0.78, 0.72, 0.58)
			scale = Vector3(0.55, 0.55, 0.55)
		"antelope":
			body_col = Color(0.62, 0.38, 0.16)
			scale = Vector3(0.85, 0.85, 0.85)
		"monkey":
			body_col = Color(0.40, 0.20, 0.08)
			scale = Vector3(0.62, 0.62, 0.62)
		"boar":
			body_col = Color(0.28, 0.18, 0.10)
			scale = Vector3(1.05, 1.05, 1.05)
		_:
			pass
	root.scale = scale
	_add_sphere(root, "Body", 0.45, Vector3(0.0, 0.45, 0.0), body_col).scale = Vector3(1.35, 0.78, 0.70)
	_add_sphere(root, "Head", 0.24, Vector3(0.48, 0.62, 0.0), body_col.lerp(Color(0.92, 0.78, 0.48), 0.15))
	for i in range(4):
		_add_box(root, "Leg%d" % i, Vector3(0.08, 0.38, 0.08), Vector3(-0.26 + float(i % 2) * 0.52, 0.18, -0.16 + float(i / 2) * 0.32), body_col)
	if animal == "rabbit":
		_add_box(root, "EarA", Vector3(0.06, 0.38, 0.06), Vector3(0.52, 0.94, -0.08), body_col)
		_add_box(root, "EarB", Vector3(0.06, 0.38, 0.06), Vector3(0.52, 0.94, 0.08), body_col)
	elif animal == "boar":
		_add_box(root, "TuskA", Vector3(0.20, 0.04, 0.04), Vector3(0.70, 0.54, -0.10), Color(0.88, 0.82, 0.66))
		_add_box(root, "TuskB", Vector3(0.20, 0.04, 0.04), Vector3(0.70, 0.54, 0.10), Color(0.88, 0.82, 0.66))

func _level_chase_animal() -> String:
	match _level_id:
		11:
			return "rabbit"
		16:
			return "antelope"
		20:
			return "rabbit"
		_:
			return "monkey"

func _spawn_splash(row: int, rng: RandomNumberGenerator) -> void:
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var root := Node3D.new()
		root.name = "SlideSplash"
		root.position = _row_local(row, side * (_seg_width.get(row, PATH_WIDTH) * 0.45), 0.08, rng.randf_range(-0.9, 0.9))
		_group("ModeEffects").add_child(root)
		for i in range(3):
			var spray := _add_sphere(root, "Drop%d" % i, rng.randf_range(0.05, 0.10), Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(0.18, 0.55), rng.randf_range(-0.16, 0.16)), Color(0.72, 0.92, 1.0, 0.70))
			spray.scale.y = rng.randf_range(1.2, 2.0)

func _spawn_river_reeds(row: int, rng: RandomNumberGenerator) -> void:
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var root := Node3D.new()
		root.name = "RiverReeds"
		root.position = _row_local(row, side * (_seg_width.get(row, PATH_WIDTH) * 0.5 + 0.35), 0.0, rng.randf_range(-0.6, 0.6))
		_group("GrassAndPlants").add_child(root)
		for i in range(4):
			var reed := _add_box(root, "Reed%d" % i, Vector3(0.045, rng.randf_range(0.55, 0.95), 0.045), Vector3(rng.randf_range(-0.15, 0.15), 0.28, rng.randf_range(-0.12, 0.12)), Color(0.28, 0.44, 0.18))
			reed.rotation_degrees.z = rng.randf_range(-10.0, 10.0)

func _spawn_dock_marker(row: int) -> void:
	var root := Node3D.new()
	root.name = "BoatDock"
	root.position = _row_center(row)
	root.rotation.y = _row_heading_y(row)
	_group("ModeEffects").add_child(root)
	_add_box(root, "DockDeck", Vector3(_seg_width.get(row, PATH_WIDTH) * 0.82, 0.16, 0.90), Vector3(0.0, 0.08, 0.0), COLOR_LOG)
	for side_value in [-1.0, 1.0]:
		_add_cylinder(root, "DockPost", 0.07, 0.09, 0.86, Vector3(float(side_value) * _seg_width.get(row, PATH_WIDTH) * 0.46, 0.43, 0.0), COLOR_LOG)

func _spawn_bridge_posts(row: int) -> void:
	var root := Node3D.new()
	root.name = "BridgePosts"
	root.position = _row_center(row)
	root.rotation.y = _row_heading_y(row)
	_group("ModeEffects").add_child(root)
	if _place_glb(root, "res://assets/3d/environment/bridges/wood_bridge.glb", Vector3.ZERO, Vector3(1.0, 1.0, 1.0)) == null:
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			for z in [-1.05, 1.05]:
				_add_cylinder(root, "Post", 0.06, 0.08, 0.72, Vector3(side * _seg_width.get(row, PATH_WIDTH) * 0.50, 0.36, z), COLOR_LOG)

func _spawn_ruins_wall(row: int, rng: RandomNumberGenerator) -> void:
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var root := Node3D.new()
		root.name = "RuinsWall"
		root.position = _row_local(row, side * (_seg_width.get(row, PATH_WIDTH) * 0.5 + 0.25), 0.0, rng.randf_range(-0.6, 0.6))
		root.rotation.y = _row_heading_y(row)
		_group("Ruins").add_child(root)
		_add_box(root, "Wall", Vector3(0.28, rng.randf_range(0.80, 1.35), 1.15), Vector3(0.0, 0.45, 0.0), _theme.get("stone", COLOR_STONE))

func _spawn_sand_ridges(row: int, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "SandRidges"
	root.position = _row_center(row)
	root.rotation.y = _row_heading_y(row)
	_group("ModeEffects").add_child(root)
	for i in range(3):
		var ridge := _add_box(root, "Ridge%d" % i, Vector3(_seg_width.get(row, PATH_WIDTH) * rng.randf_range(0.35, 0.70), 0.045, 0.08), Vector3(rng.randf_range(-0.6, 0.6), 0.04, -0.8 + float(i) * 0.75), Color(0.92, 0.76, 0.42, 0.65))
		ridge.rotation_degrees.y = rng.randf_range(-10.0, 10.0)

func _row_heading_y(row: int) -> float:
	var fwd: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	return atan2(fwd.x, -fwd.z)

func _spawn_turn_zones(data: Dictionary) -> void:
	for row in _turn_rows.keys():
		var dir: int = _turn_rows[row]
		var sp: Vector3 = _seg_pos.get(row, Vector3.ZERO)
		var sf: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
		var sr: Vector3 = _seg_right.get(row, Vector3(1.0, 0.0, 0.0))
		var heading_y := atan2(sf.x, -sf.z)

		# Turn cue arrows — one 2 tiles out (early warning), one at corner
		var arrow_dir := sr if dir > 0 else -sr
		var arrow_angle := atan2(arrow_dir.x, arrow_dir.z)
		var glow_mat := StandardMaterial3D.new()
		glow_mat.albedo_color = Color(1.0, 0.85, 0.12)
		glow_mat.emission_enabled = true
		glow_mat.emission = Color(1.0, 0.75, 0.05)
		glow_mat.emission_energy_multiplier = 0.8
		glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
		for ai in range(2):
			var adist := TILE_Z * (2.0 - float(ai) * 1.0)  # 2 tiles out, then 1 tile out
			var aroot := Node3D.new()
			aroot.name = "TurnArrow%d_%d" % [row, ai]
			aroot.position = sp - sf * adist + Vector3(0.0, 0.04, 0.0)
			_group("JunglePath").add_child(aroot)
			var asize := 0.28 + float(ai) * 0.04  # slightly bigger at corner
			var amesh := _add_box(aroot, "Arrow", Vector3(asize, 0.06, 0.70), Vector3.ZERO, Color(1.0, 0.85, 0.12))
			amesh.rotation.y = arrow_angle
			amesh.material_override = glow_mat

		# Dam sits EXACTLY at the far edge of the turn tile — no void gap possible.
		var dam_pos := sp + sf * (TILE_Z * 0.5)
		_spawn_dam_barrier(dam_pos, heading_y)

		# Wide trigger zone — 3 tiles of approach gives the player ~1.1 s to queue
		# a swipe before they reach the corner.  Actual execution happens in
		# Player3D when the player is within 1.5 m of sp (the corner).
		var trig_root := Node3D.new()
		trig_root.name = "TurnTrigger%d" % row
		trig_root.position = sp - sf * (TILE_Z * 1.5)
		trig_root.rotation.y = heading_y
		_group("JunglePath").add_child(trig_root)
		var area := Area3D.new()
		area.name = "Area"
		area.monitoring = true
		area.monitorable = false
		var col := CollisionShape3D.new()
		col.shape = BoxShape3D.new()
		(col.shape as BoxShape3D).size = Vector3(PATH_WIDTH * 0.90, 2.5, TILE_Z * 4.0)
		col.position = Vector3(0.0, 1.2, 0.0)
		area.add_child(col)
		area.body_entered.connect(_on_turn_body_entered.bind(dir, sp))
		area.body_exited.connect(_on_turn_body_exited)
		trig_root.add_child(area)

func _spawn_dam_barrier(world_pos: Vector3, heading_y: float) -> void:
	var root := Node3D.new()
	root.name = "DamBarrier"
	root.position = world_pos
	root.rotation.y = heading_y
	_group("Obstacles").add_child(root)

	var dam_w := PATH_WIDTH + 1.4  # slightly wider than path
	var log_col := COLOR_LOG.lerp(Color(0.28, 0.15, 0.06), 0.35)
	var mud_col := Color(0.32, 0.22, 0.12)
	var rock_col := COLOR_STONE.lerp(COLOR_STONE_DARK, 0.4)
	var moss_col := COLOR_MOSS.lerp(Color(0.15, 0.35, 0.12), 0.3)

	# Earth / mud base filling the bottom
	_add_box(root, "MudBase", Vector3(dam_w, 0.42, 0.80), Vector3(0.0, 0.21, 0.0), mud_col)

	# Three stacked horizontal log tiers
	for t in range(3):
		var log_y := 0.44 + float(t) * 0.38
		var log_r := 0.20 - float(t) * 0.02
		var offset_z := float(t) * 0.08 - 0.08
		var log_mesh := _add_cylinder(root, "DamLog%d" % t,
			log_r, log_r + 0.04, dam_w, Vector3(0.0, log_y, offset_z),
			log_col.lerp(Color(0.52, 0.34, 0.16), float(t) * 0.2)
		)
		log_mesh.rotation_degrees.z = 90.0
		# Bark caps on each end
		for side_v in [-1.0, 1.0]:
			var cap := _add_cylinder(root, "LogCap%d_%s" % [t, "L" if side_v < 0 else "R"],
				log_r + 0.02, log_r + 0.02, 0.08,
				Vector3(side_v * dam_w * 0.49, log_y, offset_z),
				Color(0.50, 0.32, 0.14)
			)
			cap.rotation_degrees.z = 90.0

	# Smaller debris logs leaning at the base (adds organic feel)
	for k in range(4):
		var sign_v := 1.0 if k % 2 == 0 else -1.0
		var dx := sign_v * randi_range(0, int(dam_w * 100)) * 0.01 * 0.3
		var debris := _add_cylinder(root, "Debris%d" % k,
			0.10, 0.14, randi_range(6, 12) * 0.1,
			Vector3(dx, 0.28, -0.15),
			log_col
		)
		debris.rotation_degrees.z = 90.0
		debris.rotation_degrees.y = sign_v * float(randi_range(5, 22))

	# Rocks wedged between the lower logs and at sides
	for r in range(5):
		var rx := (float(r) / 4.0 - 0.5) * dam_w * 0.75
		_add_sphere(root, "DamRock%d" % r,
			randf_range(0.16, 0.28),
			Vector3(rx, randf_range(0.22, 0.52), randf_range(-0.18, 0.18)),
			rock_col
		)

	# Mud fill between log gaps
	_add_box(root, "MudFill", Vector3(dam_w, 0.18, 0.55), Vector3(0.0, 0.58, 0.06), mud_col)

	# Moss / algae patches on top
	for m in range(3):
		var mx := (float(m) / 2.0 - 0.5) * dam_w * 0.55
		_add_box(root, "Moss%d" % m,
			Vector3(randf_range(0.55, 0.90), 0.07, randf_range(0.30, 0.55)),
			Vector3(mx, 1.23, randf_range(-0.12, 0.12)),
			moss_col
		)

	# Invisible tall collision so even a jumping player is blocked
	_add_static_box(root, "DamCollision",
		Vector3(dam_w, 4.5, 0.70),
		Vector3(0.0, 2.0, 0.0),
		{"obstacle": true}
	)

func _on_turn_body_entered(body: Node3D, dir: int, corner_pos: Vector3) -> void:
	if body is CharacterBody3D:
		turn_zone_entered.emit(dir, corner_pos)

func _on_turn_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		turn_zone_exited.emit()

func _goal_glb_path() -> String:
	if _level_id <= 4:
		return "res://assets/3d/goals/jungle_gate.glb"
	elif _level_id <= 8:
		return "res://assets/3d/goals/vine_ruin_arch.glb"
	elif _level_id <= 12:
		return "res://assets/3d/goals/temple_doorway.glb"
	elif _level_id <= 16:
		return "res://assets/3d/goals/temple_portal.glb"
	else:
		return "res://assets/3d/goals/river_gate.glb"

func _spawn_finish(data: Dictionary) -> void:
	var length: int = data.get("length", 30)
	var gate_pos: Vector3 = _seg_pos.get(length, Vector3(0.0, 0.0, -float(length) * TILE_Z))
	var gate_fwd: Vector3 = _seg_fwd.get(length, Vector3(0.0, 0.0, -1.0))
	var heading_y := atan2(gate_fwd.x, -gate_fwd.z)

	# Relic altar placed before the gate (2.5 tiles back from gate)
	var altar_pos := gate_pos + gate_fwd * (-TILE_Z * 2.5)
	var altar_root := Node3D.new()
	altar_root.name = "RelicAltar"
	altar_root.position = altar_pos
	altar_root.rotation.y = heading_y
	_group("Ruins").add_child(altar_root)
	_place_glb(altar_root, "res://assets/3d/rewards/relic_altar.glb", Vector3.ZERO, Vector3(0.8, 0.8, 0.8))

	var root := Node3D.new()
	root.name = "TempleFinishGate"
	root.position = gate_pos
	root.rotation.y = heading_y
	_group("FinishGate").add_child(root)

	if _place_glb(root, _goal_glb_path(), Vector3.ZERO, Vector3(1.2, 1.2, 1.2)) != null:
		var area := Area3D.new()
		area.name = "FinishArea"
		var col := CollisionShape3D.new()
		col.shape = BoxShape3D.new()
		(col.shape as BoxShape3D).size = Vector3(PATH_WIDTH, 3.2, 1.2)
		area.add_child(col)
		area.position = Vector3(0.0, 1.55, 0.0)
		area.body_entered.connect(_on_finish_entered)
		root.add_child(area)
		return

	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		_add_box(root, "StonePost", Vector3(0.58, 3.25, 0.58), Vector3(side * 1.95, 1.60, 0.0), COLOR_STONE)
		_add_box(root, "PostBase", Vector3(0.88, 0.32, 0.78), Vector3(side * 1.95, 0.16, 0.0), COLOR_STONE_DARK)
		_add_box(root, "MossBand", Vector3(0.62, 0.12, 0.62), Vector3(side * 1.95, 2.62, 0.0), COLOR_MOSS)
		_torch(root, Vector3(side * 2.45, 1.65, 0.12))

	_add_box(root, "StoneCrossbar", Vector3(4.45, 0.48, 0.58), Vector3(0.0, 3.20, 0.0), COLOR_STONE)
	_add_box(root, "MossCap", Vector3(4.55, 0.14, 0.62), Vector3(0.0, 3.52, 0.0), COLOR_MOSS)
	_add_box(root, "Threshold", Vector3(PATH_WIDTH, 0.16, 0.72), Vector3(0.0, 0.06, 0.0), COLOR_STONE_DARK)

	var glow := _add_sphere(root, "PortalGlow", 0.62, Vector3(0.0, 1.55, -0.10), COLOR_PORTAL)
	glow.scale = Vector3(1.2, 1.55, 0.22)
	glow.set_meta("glow", true)

	var area := Area3D.new()
	area.name = "FinishArea"
	var col := CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	(col.shape as BoxShape3D).size = Vector3(PATH_WIDTH, 3.2, 1.2)
	area.add_child(col)
	area.position = Vector3(0.0, 1.55, 0.0)
	area.body_entered.connect(_on_finish_entered)
	root.add_child(area)

func _torch(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Torch"
	root.position = pos
	parent.add_child(root)
	_add_cylinder(root, "TorchPost", 0.06, 0.08, 0.75, Vector3(0.0, -0.28, 0.0), COLOR_LOG)
	var flame := _add_sphere(root, "Flame", 0.16, Vector3(0.0, 0.18, 0.0), COLOR_TORCH)
	flame.scale = Vector3(0.75, 1.25, 0.75)
	_torch_flames.append(flame)

func _on_finish_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		finish_reached.emit()

func _count_total_coins(data: Dictionary) -> void:
	_total_coins = 0
	for c in data.get("coins", []):
		if not c.get("gem", false):
			_total_coins += 1

func get_total_coins() -> int:
	return _total_coins

func attract_coins(player_pos: Vector3, radius: float) -> void:
	var radius_sq := radius * radius
	for coin in _coin_nodes.duplicate():
		if not is_instance_valid(coin):
			continue
		if coin.global_position.distance_squared_to(player_pos) <= radius_sq:
			_collect_coin_node(coin)

func _animate_coins(delta: float) -> void:
	for coin in _coin_nodes.duplicate():
		if not is_instance_valid(coin):
			_coin_nodes.erase(coin)
			continue
		coin.rotate_y(delta * 4.0)
		var base_y := float(coin.get_meta("base_y", 0.80))
		var phase := float(coin.get_meta("phase", 0.0))
		coin.position.y = base_y + sin(_time * 3.0 + phase) * 0.08

func _spawn_collectables(data: Dictionary) -> void:
	for item in data.get("collectables", []):
		_spawn_single_collectable(
			str(item.get("type", "")),
			int(item.get("lane", 1)),
			int(item.get("row", 3))
		)

func _spawn_single_collectable(res_type: String, lane: int, row: int) -> void:
	var root := Node3D.new()
	root.name = "Collectable_" + res_type
	var base_pos := _world_pos(row, lane)
	root.position = Vector3(base_pos.x, 0.90, base_pos.z)
	root.set_meta("base_y", root.position.y)
	root.set_meta("phase", float(row) * 0.47 + float(lane) * 1.3)

	const _GLB_NAME := { "bricks": "brick", "tiles": "tile" }
	var glb_id: String = _GLB_NAME.get(res_type, res_type)
	if _place_glb(root, "res://assets/3d/collectibles/%s.glb" % glb_id, Vector3.ZERO, Vector3(0.45, 0.45, 0.45)) == null:
		match res_type:
			"sunstone_shard":
				var s := _add_sphere(root, "Stone", 0.22, Vector3.ZERO, Color(1.0, 0.60, 0.08))
				s.scale = Vector3(0.75, 1.80, 0.75)
				_add_sphere(root, "StoneCore", 0.12, Vector3(0.0, 0.08, 0.0), Color(1.0, 0.88, 0.30))
			"relic_key":
				_add_cylinder(root, "KeyShaft", 0.06, 0.06, 0.44, Vector3(0.0, 0.0, 0.0), Color(0.92, 0.78, 0.18))
				_add_cylinder(root, "KeyBow",   0.16, 0.16, 0.06, Vector3(0.0, 0.24, 0.0), Color(0.92, 0.78, 0.18))
				_add_cylinder(root, "KeyHole",  0.08, 0.08, 0.07, Vector3(0.0, 0.24, 0.0), Color(0.30, 0.22, 0.05))
				_add_box(root, "Tooth1", Vector3(0.10, 0.08, 0.10), Vector3(0.09, -0.14, 0.0), Color(0.92, 0.78, 0.18))
				_add_box(root, "Tooth2", Vector3(0.10, 0.08, 0.10), Vector3(0.09, -0.26, 0.0), Color(0.92, 0.78, 0.18))
			"map_piece":
				_add_box(root, "Scroll",       Vector3(0.42, 0.04, 0.32), Vector3.ZERO,            Color(0.86, 0.74, 0.44))
				_add_box(root, "ScrollAccent", Vector3(0.38, 0.05, 0.04), Vector3(0.0, 0.0, 0.12), Color(0.72, 0.52, 0.14))
			"bricks":
				_add_box(root, "Brick1", Vector3(0.36, 0.12, 0.18), Vector3(0.0, 0.06, 0.0), Color(0.58, 0.24, 0.14))
				_add_box(root, "Brick2", Vector3(0.36, 0.12, 0.18), Vector3(0.0, 0.20, 0.0), Color(0.64, 0.28, 0.16))
				_add_box(root, "Brick3", Vector3(0.36, 0.12, 0.18), Vector3(0.0, 0.34, 0.0), Color(0.58, 0.24, 0.14))
			"wood":
				var log := _add_cylinder(root, "WoodLog", 0.18, 0.20, 0.40, Vector3.ZERO, Color(0.42, 0.27, 0.12))
				log.rotation_degrees.z = 90.0
				_add_cylinder(root, "WoodEnd", 0.18, 0.18, 0.04, Vector3(0.22, 0.0, 0.0), Color(0.56, 0.38, 0.18))
			"food":
				_add_sphere(root, "Fruit", 0.22, Vector3.ZERO, Color(0.96, 0.44, 0.10))
				_add_cylinder(root, "Stem", 0.02, 0.02, 0.10, Vector3(0.0, 0.25, 0.0), Color(0.18, 0.52, 0.12))
			"tools":
				_add_cylinder(root, "Handle", 0.05, 0.05, 0.38, Vector3.ZERO, Color(0.56, 0.50, 0.46))
				_add_box(root, "Head", Vector3(0.24, 0.10, 0.10), Vector3(0.0, 0.22, 0.0), Color(0.48, 0.44, 0.42))
			"tiles":
				_add_box(root, "Tile1", Vector3(0.30, 0.04, 0.30), Vector3(0.0, 0.02, 0.0), Color(0.60, 0.52, 0.40))
				_add_box(root, "Tile2", Vector3(0.30, 0.04, 0.30), Vector3(0.0, 0.09, 0.0), Color(0.68, 0.58, 0.44))
				_add_box(root, "Tile3", Vector3(0.30, 0.04, 0.30), Vector3(0.0, 0.16, 0.0), Color(0.60, 0.52, 0.40))
			"rope":
				var coil := _add_cylinder(root, "Coil", 0.18, 0.18, 0.06, Vector3.ZERO, Color(0.54, 0.36, 0.18))
				coil.rotation_degrees.x = 90.0
				_add_cylinder(root, "CoilInner", 0.10, 0.10, 0.08, Vector3.ZERO, Color(0.38, 0.24, 0.10))
				var tail := _add_cylinder(root, "Tail", 0.04, 0.04, 0.22, Vector3(0.18, 0.06, 0.0), Color(0.54, 0.36, 0.18))
				tail.rotation_degrees.z = 30.0
			"medicine_pack":
				_add_box(root, "Pack", Vector3(0.28, 0.22, 0.14), Vector3.ZERO, Color(0.92, 0.94, 0.90))
				_add_box(root, "CrossH", Vector3(0.18, 0.05, 0.06), Vector3(0.0, 0.0, 0.08), Color(0.82, 0.16, 0.14))
				_add_box(root, "CrossV", Vector3(0.06, 0.18, 0.06), Vector3(0.0, 0.0, 0.09), Color(0.82, 0.16, 0.14))
			"dog_token":
				_add_sphere(root, "BoneEnd1", 0.10, Vector3(-0.18, 0.0, 0.0), Color(0.88, 0.80, 0.64))
				_add_sphere(root, "BoneEnd2", 0.10, Vector3( 0.18, 0.0, 0.0), Color(0.88, 0.80, 0.64))
				var shaft := _add_cylinder(root, "BoneShaft", 0.04, 0.04, 0.36, Vector3.ZERO, Color(0.88, 0.80, 0.64))
				shaft.rotation_degrees.z = 90.0
			"animal_badge":
				var badge := _add_cylinder(root, "Badge", 0.20, 0.20, 0.04, Vector3.ZERO, Color(0.96, 0.82, 0.18))
				badge.rotation_degrees.x = 90.0
				_add_box(root, "StarH", Vector3(0.04, 0.18, 0.06), Vector3(0.0, 0.0, 0.0), Color(0.90, 0.70, 0.10))
				_add_box(root, "StarV", Vector3(0.18, 0.04, 0.06), Vector3(0.0, 0.0, 0.0), Color(0.90, 0.70, 0.10))
			"windows":
				_add_box(root, "Frame",  Vector3(0.40, 0.40, 0.04), Vector3.ZERO,            Color(0.66, 0.56, 0.32))
				_add_box(root, "Glass",  Vector3(0.30, 0.30, 0.06), Vector3.ZERO,            Color(0.50, 0.70, 0.86))
				_add_box(root, "PaneH",  Vector3(0.30, 0.04, 0.07), Vector3.ZERO,            Color(0.66, 0.56, 0.32))
				_add_box(root, "PaneV",  Vector3(0.04, 0.30, 0.07), Vector3.ZERO,            Color(0.66, 0.56, 0.32))
			"water_token":
				var drop := _add_sphere(root, "WaterDrop", 0.22, Vector3(0.0, 0.03, 0.0), Color(0.18, 0.74, 1.0))
				drop.scale = Vector3(0.82, 1.30, 0.82)
				_add_sphere(root, "DropGlow", 0.10, Vector3(0.04, 0.14, 0.04), Color(0.82, 0.96, 1.0, 0.75))
			"fish_token":
				_add_sphere(root, "FishBody", 0.18, Vector3.ZERO, Color(0.22, 0.76, 0.78)).scale = Vector3(1.35, 0.62, 0.72)
				_add_box(root, "Tail", Vector3(0.18, 0.16, 0.06), Vector3(-0.25, 0.0, 0.0), Color(0.12, 0.52, 0.58))
				_add_sphere(root, "Eye", 0.035, Vector3(0.17, 0.05, 0.11), Color(0.02, 0.02, 0.02))
			"river_relic":
				var relic := _add_cylinder(root, "RiverRelic", 0.20, 0.20, 0.12, Vector3.ZERO, Color(0.14, 0.62, 0.76))
				relic.rotation_degrees.x = 90.0
				_add_cylinder(root, "GoldRim", 0.23, 0.23, 0.035, Vector3(0.0, 0.0, 0.02), Color(0.92, 0.72, 0.18))
				_add_sphere(root, "RelicCore", 0.09, Vector3(0.0, 0.0, 0.07), Color(0.70, 0.95, 1.0))
			"trade_token":
				var tok := _add_cylinder(root, "Token", 0.22, 0.22, 0.06, Vector3.ZERO, Color(0.88, 0.70, 0.20))
				tok.rotation_degrees.x = 90.0
				_add_cylinder(root, "TokenInset", 0.14, 0.14, 0.07, Vector3.ZERO, Color(0.76, 0.58, 0.12))
			"wildlife_notes":
				_add_box(root, "Cover", Vector3(0.32, 0.40, 0.06), Vector3.ZERO, Color(0.26, 0.56, 0.32))
				_add_box(root, "Page",  Vector3(0.26, 0.34, 0.07), Vector3(0.0, 0.0, 0.02), Color(0.95, 0.93, 0.84))
				_add_box(root, "Line1", Vector3(0.18, 0.02, 0.08), Vector3(0.0,  0.08, 0.0), Color(0.68, 0.78, 0.70))
				_add_box(root, "Line2", Vector3(0.18, 0.02, 0.08), Vector3(0.0,  0.0,  0.0), Color(0.68, 0.78, 0.70))
				_add_box(root, "Line3", Vector3(0.18, 0.02, 0.08), Vector3(0.0, -0.08, 0.0), Color(0.68, 0.78, 0.70))
			_:
				_add_sphere(root, "Unknown", 0.20, Vector3.ZERO, Color(0.75, 0.75, 0.75))

	var area := Area3D.new()
	area.name = "PickupArea"
	var col := CollisionShape3D.new()
	col.shape = SphereShape3D.new()
	(col.shape as SphereShape3D).radius = 0.44
	area.add_child(col)
	area.body_entered.connect(_on_collectable_body_entered.bind(root, res_type))
	root.add_child(area)

	_collectable_nodes.append(root)
	_group("Collectibles").add_child(root)

func _on_collectable_body_entered(body: Node3D, coll_node: Node3D, res_type: String) -> void:
	if not (body is CharacterBody3D):
		return
	if not is_instance_valid(coll_node):
		return
	if body.has_method("play_collect"):
		body.call("play_collect")
	coll_node.queue_free()
	_collectable_nodes.erase(coll_node)
	match res_type:
		"relic_key":
			EventBus.play_sfx.emit("key")
		"sunstone_shard":
			EventBus.play_sfx.emit("gem")
		_:
			EventBus.play_sfx.emit("coin")
	GameManager.collect_resource(res_type, 1)

func _animate_collectables(delta: float) -> void:
	for item in _collectable_nodes.duplicate():
		if not is_instance_valid(item):
			_collectable_nodes.erase(item)
			continue
		item.rotate_y(delta * 2.2)
		var base_y := float(item.get_meta("base_y", 0.90))
		var phase  := float(item.get_meta("phase", 0.0))
		item.position.y = base_y + sin(_time * 2.4 + phase) * 0.10

func _animate_butterflies() -> void:
	for item in _butterflies:
		var node := item.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var origin = item.get("origin", Vector3.ZERO)
		var phase := float(item.get("phase", 0.0))
		var speed := float(item.get("speed", 1.0))
		var amp := float(item.get("amp", 0.2))
		node.position = origin + Vector3(
			sin(_time * speed + phase) * amp,
			sin(_time * speed * 2.3 + phase) * amp * 0.55,
			cos(_time * speed + phase) * amp
		)
		node.rotation_degrees.y = sin(_time * speed + phase) * 18.0

func _animate_birds() -> void:
	for item in _birds:
		var node := item.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var start_pos = item.get("start", Vector3.ZERO)
		var end_pos = item.get("end", Vector3.ZERO)
		var phase := float(item.get("phase", 0.0))
		var speed := float(item.get("speed", 0.05))
		var t := fmod(_time * speed + phase, 1.0)
		node.position = start_pos.lerp(end_pos, t)
		node.position.y += sin(t * PI * 2.0) * 0.35
		node.look_at(end_pos, Vector3.UP)

func _animate_torches() -> void:
	for flame in _torch_flames:
		if not is_instance_valid(flame):
			continue
		var pulse := 1.0 + sin(_time * 7.5 + flame.global_position.x) * 0.10
		flame.scale = Vector3(0.75 * pulse, 1.25 * pulse, 0.75 * pulse)

func _animate_relic_glows() -> void:
	for glow in _relic_glows:
		if not is_instance_valid(glow):
			continue
		var mat := glow.material_override as StandardMaterial3D
		if mat == null:
			continue
		mat.emission_energy_multiplier = 0.75 + sin(_time * 2.6 + glow.global_position.z) * 0.28

func _register_wind(node: Node3D, strength: float, speed: float, phase: float) -> void:
	_wind_nodes.append({
		"node": node,
		"base_x": node.rotation.x,
		"base_z": node.rotation.z,
		"strength": strength,
		"speed": speed,
		"phase": phase,
	})

func _animate_wind() -> void:
	var gust := 1.0 + sin(_time * 0.37) * _gust_strength
	for item in _wind_nodes:
		var node := item.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var phase := float(item.get("phase", 0.0))
		var speed := float(item.get("speed", 1.0)) * _wind_speed
		var amount := float(item.get("strength", 0.02)) * _wind_strength * gust
		node.rotation.z = float(item.get("base_z", 0.0)) + sin(_time * speed + phase) * amount
		node.rotation.x = float(item.get("base_x", 0.0)) + cos(_time * speed * 0.73 + phase) * amount * 0.32

func add_grass_footprint(global_pos: Vector3, right: Vector3, side: int) -> void:
	if not _grass_footprints_enabled:
		return
	var root := Node3D.new()
	root.name = "FlattenedGrass"
	root.position = to_local(global_pos + right.normalized() * 0.14 * float(side))
	root.position.y = 0.025
	var fwd := Vector3(right.z, 0.0, -right.x).normalized()
	root.rotation.y = atan2(fwd.x, -fwd.z)
	_group("ModeEffects").add_child(root)
	for blade_index in range(3):
		var blade := _add_box(
			root,
			"PressedBlade%d" % blade_index,
			Vector3(0.075, 0.012, 0.42 - float(blade_index) * 0.045),
			Vector3((float(blade_index) - 1.0) * 0.075, 0.0, (float(blade_index % 2) - 0.5) * 0.06),
			Color(0.08, 0.24, 0.07, 0.82)
		)
		blade.rotation_degrees.y = -9.0 + float(blade_index) * 9.0
	_grass_marks.append({"node": root, "age": 0.0, "duration": 6.5})
	if _grass_marks.size() > 48:
		var oldest: Dictionary = _grass_marks.pop_front()
		var old_node := oldest.get("node") as Node3D
		if is_instance_valid(old_node):
			old_node.queue_free()

func _animate_grass_marks(delta: float) -> void:
	for index in range(_grass_marks.size() - 1, -1, -1):
		var item: Dictionary = _grass_marks[index]
		var node := item.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			_grass_marks.remove_at(index)
			continue
		var age := float(item.get("age", 0.0)) + delta
		var duration := float(item.get("duration", 6.5))
		item["age"] = age
		_grass_marks[index] = item
		var alpha := clampf(1.0 - age / duration, 0.0, 1.0) * 0.82
		for child in node.get_children():
			if child is MeshInstance3D:
				var mat := (child as MeshInstance3D).material_override as StandardMaterial3D
				if mat != null:
					var color := mat.albedo_color
					color.a = alpha
					mat.albedo_color = color
		if age >= duration:
			node.queue_free()
			_grass_marks.remove_at(index)

func _lane_x_for_row(row: int, lane: int) -> float:
	var lane_count := clampi(int(_seg_lane_count.get(row, 3)), 1, 3)
	if lane_count == 1:
		return 0.0
	if lane_count == 2:
		return -LANE_W * 0.5 if clampi(lane, 0, 1) == 0 else LANE_W * 0.5
	return _lane_x(clampi(lane, 0, 2))

func _lane_x(lane: int) -> float:
	match lane:
		0:
			return -LANE_W
		2:
			return LANE_W
		_:
			return 0.0

func _grass_color(rng: RandomNumberGenerator) -> Color:
	var dark: Color = _theme.get("grass_dark", COLOR_GRASS_DARK)
	var light: Color = _theme.get("grass_light", COLOR_GRASS_LIGHT)
	return dark.lerp(light, rng.randf_range(0.15, 0.75))

func _setup_theme(id: int) -> void:
	_level_id = id
	match id:
		1:
			_theme = {
				"dirt_dark": COLOR_DIRT,
				"dirt_light": COLOR_DIRT_LIGHT,
				"grass_dark": COLOR_GRASS_DARK,
				"grass_light": COLOR_GRASS_LIGHT,
				"stone": COLOR_STONE,
				"moss": COLOR_MOSS,
				"surface": "dirt",
			}
		2:
			_theme = {
				"dirt_dark": Color(0.28, 0.17, 0.07),
				"dirt_light": Color(0.38, 0.24, 0.11),
				"grass_dark": Color(0.06, 0.20, 0.07),
				"grass_light": Color(0.16, 0.46, 0.14),
				"stone": Color(0.35, 0.38, 0.30),
				"moss": Color(0.20, 0.44, 0.14),
				"surface": "dirt",
			}
		3:
			_theme = {
				"dirt_dark": Color(0.28, 0.22, 0.13),
				"dirt_light": Color(0.38, 0.30, 0.18),
				"grass_dark": Color(0.10, 0.30, 0.22),
				"grass_light": Color(0.18, 0.52, 0.38),
				"stone": Color(0.30, 0.38, 0.36),
				"moss": Color(0.18, 0.44, 0.32),
				"surface": "mud",
			}
		4:
			_theme = {
				"dirt_dark": Color(0.25, 0.20, 0.13),
				"dirt_light": Color(0.34, 0.27, 0.19),
				"grass_dark": Color(0.07, 0.17, 0.07),
				"grass_light": Color(0.13, 0.36, 0.13),
				"stone": Color(0.42, 0.40, 0.33),
				"moss": Color(0.22, 0.42, 0.16),
				"surface": "stone",
			}
		5:
			_theme = {
				"dirt_dark": Color(0.40, 0.32, 0.20),
				"dirt_light": Color(0.52, 0.42, 0.26),
				"grass_dark": Color(0.10, 0.22, 0.10),
				"grass_light": Color(0.20, 0.44, 0.18),
				"stone": Color(0.52, 0.48, 0.38),
				"moss": Color(0.28, 0.52, 0.20),
				"surface": "stone",
			}
		6:
			_theme = {
				"dirt_dark":  Color(0.72, 0.60, 0.38),  # sandy path
				"dirt_light": Color(0.84, 0.72, 0.48),
				"grass_dark": Color(0.55, 0.50, 0.28),  # dry savanna grass
				"grass_light": Color(0.72, 0.68, 0.38),
				"stone": Color(0.60, 0.55, 0.40),       # warm sandstone
				"moss": Color(0.55, 0.58, 0.28),
				"surface": "sand",
			}
		7:  # Wildlands Settlement — worn dirt paths, dry grass, wood buildings
			_theme = {
				"dirt_dark":  Color(0.42, 0.28, 0.14),
				"dirt_light": Color(0.56, 0.38, 0.20),
				"grass_dark": Color(0.38, 0.44, 0.16),
				"grass_light": Color(0.52, 0.62, 0.22),
				"stone": Color(0.52, 0.46, 0.32),
				"moss":  Color(0.34, 0.54, 0.20),
				"surface": "dirt",
			}
		8:  # Brick trail — earthy path through a settlement under construction
			_theme = {
				"dirt_dark":  Color(0.46, 0.30, 0.14),
				"dirt_light": Color(0.60, 0.40, 0.20),
				"grass_dark": Color(0.30, 0.40, 0.14),
				"grass_light": Color(0.44, 0.58, 0.20),
				"stone": Color(0.54, 0.42, 0.28),
				"moss":  Color(0.30, 0.50, 0.18),
				"surface": "stone",
			}
		9:  # Deep jungle, thick canopy, root-tangled paths
			_theme = {
				"dirt_dark":  Color(0.22, 0.14, 0.07),
				"dirt_light": Color(0.32, 0.22, 0.11),
				"grass_dark": Color(0.06, 0.22, 0.08),
				"grass_light": Color(0.14, 0.44, 0.16),
				"stone": Color(0.30, 0.36, 0.28),
				"moss":  Color(0.18, 0.48, 0.16),
				"surface": "mud",
			}
		10:  # Animal crossing trail — savanna edge with tall grass
			_theme = {
				"dirt_dark":  Color(0.52, 0.38, 0.18),
				"dirt_light": Color(0.66, 0.50, 0.26),
				"grass_dark": Color(0.48, 0.50, 0.18),
				"grass_light": Color(0.64, 0.68, 0.26),
				"stone": Color(0.56, 0.52, 0.36),
				"moss":  Color(0.44, 0.54, 0.22),
				"surface": "dirt",
			}
		11:  # Wildlife valley — lush greens, animal presence
			_theme = {
				"dirt_dark":  Color(0.28, 0.18, 0.08),
				"dirt_light": Color(0.38, 0.26, 0.13),
				"grass_dark": Color(0.08, 0.30, 0.10),
				"grass_light": Color(0.18, 0.58, 0.20),
				"stone": Color(0.32, 0.40, 0.32),
				"moss":  Color(0.16, 0.48, 0.20),
				"surface": "dirt",
			}
		12:  # Water slide gorge — wet stone, blue-green moss
			_theme = {
				"dirt_dark":  Color(0.20, 0.22, 0.24),
				"dirt_light": Color(0.30, 0.34, 0.38),
				"grass_dark": Color(0.08, 0.32, 0.30),
				"grass_light": Color(0.14, 0.52, 0.48),
				"stone": Color(0.26, 0.42, 0.44),
				"moss":  Color(0.14, 0.44, 0.38),
				"surface": "mud",
			}
		13:  # Chase trail — open clearing, fast ground, bright savanna
			_theme = {
				"dirt_dark":  Color(0.56, 0.44, 0.22),
				"dirt_light": Color(0.70, 0.56, 0.30),
				"grass_dark": Color(0.50, 0.52, 0.20),
				"grass_light": Color(0.66, 0.70, 0.28),
				"stone": Color(0.58, 0.54, 0.36),
				"moss":  Color(0.46, 0.56, 0.22),
				"surface": "dirt",
			}
		14:  # Tiled ruins — warm sandstone tiles, ancient structures
			_theme = {
				"dirt_dark":  Color(0.48, 0.36, 0.22),
				"dirt_light": Color(0.62, 0.48, 0.30),
				"grass_dark": Color(0.16, 0.26, 0.12),
				"grass_light": Color(0.26, 0.44, 0.20),
				"stone": Color(0.62, 0.54, 0.38),
				"moss":  Color(0.30, 0.46, 0.20),
				"surface": "stone",
			}
		15:  # Market skate/river dock — bright, open, planked surfaces
			_theme = {
				"dirt_dark":  Color(0.44, 0.32, 0.18),
				"dirt_light": Color(0.58, 0.44, 0.26),
				"grass_dark": Color(0.20, 0.34, 0.14),
				"grass_light": Color(0.30, 0.52, 0.22),
				"stone": Color(0.50, 0.46, 0.34),
				"moss":  Color(0.28, 0.48, 0.20),
				"surface": "stone",
			}
		16:  # Animal escape — darker urgency, dense foliage
			_theme = {
				"dirt_dark":  Color(0.20, 0.14, 0.06),
				"dirt_light": Color(0.30, 0.20, 0.10),
				"grass_dark": Color(0.06, 0.20, 0.07),
				"grass_light": Color(0.12, 0.40, 0.14),
				"stone": Color(0.28, 0.34, 0.26),
				"moss":  Color(0.14, 0.44, 0.16),
				"surface": "dirt",
			}
		17:  # Rapids/boat — dark wet stone, river mist
			_theme = {
				"dirt_dark":  Color(0.18, 0.22, 0.26),
				"dirt_light": Color(0.26, 0.32, 0.38),
				"grass_dark": Color(0.06, 0.24, 0.24),
				"grass_light": Color(0.12, 0.44, 0.44),
				"stone": Color(0.24, 0.38, 0.42),
				"moss":  Color(0.12, 0.40, 0.36),
				"surface": "mud",
			}
		18:  # Relic trail — ancient stone glyphs, deep purple-grey tones
			_theme = {
				"dirt_dark":  Color(0.22, 0.18, 0.26),
				"dirt_light": Color(0.32, 0.26, 0.36),
				"grass_dark": Color(0.08, 0.14, 0.16),
				"grass_light": Color(0.14, 0.26, 0.30),
				"stone": Color(0.38, 0.32, 0.46),
				"moss":  Color(0.18, 0.30, 0.36),
				"surface": "stone",
			}
		19:  # Boar escape — red-brown earth, scrub brush panic run
			_theme = {
				"dirt_dark":  Color(0.38, 0.18, 0.10),
				"dirt_light": Color(0.52, 0.26, 0.14),
				"grass_dark": Color(0.30, 0.28, 0.10),
				"grass_light": Color(0.48, 0.46, 0.18),
				"stone": Color(0.44, 0.36, 0.24),
				"moss":  Color(0.36, 0.42, 0.14),
				"surface": "dirt",
			}
		20:  # Baobab Treasure — rich gold-amber, ancient majesty
			_theme = {
				"dirt_dark":  Color(0.46, 0.34, 0.16),
				"dirt_light": Color(0.62, 0.48, 0.24),
				"grass_dark": Color(0.16, 0.28, 0.12),
				"grass_light": Color(0.28, 0.50, 0.22),
				"stone": Color(0.58, 0.50, 0.30),
				"moss":  Color(0.28, 0.50, 0.20),
				"surface": "stone",
			}
		_:
			_theme = {
				"dirt_dark": COLOR_DIRT,
				"dirt_light": COLOR_DIRT_LIGHT,
				"grass_dark": COLOR_GRASS_DARK,
				"grass_light": COLOR_GRASS_LIGHT,
				"stone": COLOR_STONE,
				"moss": COLOR_MOSS,
				"surface": "dirt",
			}

func _spawn_level_specific_dressing(data: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 42)) + 7777
	var length: int = data.get("length", 30)

	match _level_id:
		1:
			for i in range(3):
				_butterfly(Vector3(
					(1.0 if i % 2 == 0 else -1.0) * rng.randf_range(1.8, 2.8),
					rng.randf_range(0.9, 1.4),
					-float(rng.randi_range(6, length - 4)) * TILE_Z
				), rng)

		2:
			for i in range(length / 3):
				var row := i * 3 + 2
				var z := -float(row) * TILE_Z
				for s in [-1.0, 1.0]:
					var vroot := Node3D.new()
					vroot.name = "ThickVines"
					vroot.position = Vector3(s * rng.randf_range(2.7, 3.4), 0.0, z + rng.randf_range(-0.9, 0.9))
					_group("GrassAndPlants").add_child(vroot)
					for k in range(3):
						var seg := _add_box(vroot, "Seg%d" % k,
							Vector3(0.06, rng.randf_range(0.9, 1.7), 0.06),
							Vector3(rng.randf_range(-0.12, 0.12), 0.5 + float(k) * 0.45, rng.randf_range(-0.10, 0.10)),
							COLOR_FERN.lerp(Color(0.07, 0.26, 0.07), rng.randf_range(0.0, 0.55))
						)
						seg.rotation_degrees.z = rng.randf_range(-14.0, 14.0)
			for i in range(2):
				var row := 5 + i * 8
				var side: float = 1.0 if i % 2 == 0 else -1.0
				var mroot := Node3D.new()
				mroot.name = "MonkeySilhouette"
				mroot.position = Vector3(side * rng.randf_range(5.2, 5.8), rng.randf_range(2.1, 2.7), -float(row) * TILE_Z)
				_group("Animals").add_child(mroot)
				_add_sphere(mroot, "Body", 0.22, Vector3.ZERO, Color(0.24, 0.14, 0.06))
				_add_sphere(mroot, "Head", 0.14, Vector3(0.0, 0.30, 0.0), Color(0.21, 0.12, 0.05))
				_add_box(mroot, "Tail", Vector3(0.05, 0.55, 0.05), Vector3(side * 0.22, -0.30, 0.0), Color(0.21, 0.12, 0.05))

		3:
			for i in range(length / 2):
				var z := -float(i * 2 + 2) * TILE_Z
				for s in [-1.0, 1.0]:
					if rng.randf() < 0.65:
						var rroot := Node3D.new()
						rroot.name = "Reed"
						rroot.position = Vector3(s * rng.randf_range(3.0, 3.8), 0.0, z + rng.randf_range(-0.8, 0.8))
						_group("GrassAndPlants").add_child(rroot)
						for r in range(4):
							var reed := _add_box(rroot, "Stem%d" % r,
								Vector3(0.04, rng.randf_range(0.55, 1.05), 0.04),
								Vector3(rng.randf_range(-0.12, 0.12), 0.30, rng.randf_range(-0.12, 0.12)),
								Color(0.28, 0.50, 0.26)
							)
							reed.rotation_degrees.z = rng.randf_range(-8.0, 8.0)
						_add_sphere(rroot, "Top", 0.06, Vector3(0.0, 1.0, 0.0), Color(0.44, 0.30, 0.10))
					if rng.randf() < 0.50:
						var wstone := _add_sphere(
							_group("RocksAndLogs"), "WaterStone",
							rng.randf_range(0.10, 0.22),
							Vector3(s * rng.randf_range(2.5, 3.5), 0.04, z + rng.randf_range(-0.9, 0.9)),
							Color(0.26, 0.40, 0.46)
						)
						wstone.scale = Vector3(1.4, 0.35, 1.0)

		4:
			for i in range(length / 4):
				var row := i * 4 + 2
				var z := -float(row) * TILE_Z
				for s in [-1.0, 1.0]:
					var proot := Node3D.new()
					proot.name = "AncientPillar"
					proot.position = Vector3(s * rng.randf_range(3.5, 4.5), 0.0, z + rng.randf_range(-0.6, 0.6))
					proot.rotation_degrees.y = rng.randf_range(-12.0, 12.0)
					_group("Ruins").add_child(proot)
					var shaft_h: float = rng.randf_range(0.8, 1.6)
					var stone_col: Color = _theme.get("stone", COLOR_STONE)
					var moss_col: Color = _theme.get("moss", COLOR_MOSS)
					_add_cylinder(proot, "Shaft", 0.22, 0.26, shaft_h,
						Vector3(0.0, shaft_h * 0.5, 0.0), stone_col)
					if rng.randf() < 0.55:
						_add_box(proot, "Capital",
							Vector3(0.52, 0.18, 0.52), Vector3(0.0, shaft_h + 0.09, 0.0), stone_col)
					var mc := _add_box(proot, "Moss",
						Vector3(0.28, 0.08, 0.28), Vector3(0.0, shaft_h * 0.65, 0.0), moss_col)
					mc.rotation_degrees.y = rng.randf_range(0.0, 45.0)
					if rng.randf() < 0.45:
						var groot := Node3D.new()
						groot.name = "RelicGlyph"
						groot.position = Vector3(s * rng.randf_range(4.0, 5.2), rng.randf_range(0.3, 0.8), z + rng.randf_range(-0.5, 0.5))
						_group("Ruins").add_child(groot)
						var gm := _add_box(groot, "Face", Vector3(0.22, 0.22, 0.06), Vector3.ZERO, Color(0.95, 0.78, 0.22))
						var gmat := StandardMaterial3D.new()
						gmat.albedo_color = Color(0.95, 0.78, 0.22)
						gmat.emission_enabled = true
						gmat.emission = Color(0.95, 0.68, 0.08)
						gmat.emission_energy_multiplier = 0.9
						gmat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
						gm.material_override = gmat
						_relic_glows.append(gm)
						_add_box(groot, "Border", Vector3(0.28, 0.28, 0.04), Vector3(0.0, 0.0, 0.02), stone_col)

		5:
			var pillar_interval := 3
			for i in range(length / pillar_interval):
				var row := i * pillar_interval + 1
				var z := -float(row) * TILE_Z
				var stone_col: Color = _theme.get("stone", COLOR_STONE)
				for s in [-1.0, 1.0]:
					var proot := Node3D.new()
					proot.name = "TemplePillar"
					proot.position = Vector3(s * 3.05, 0.0, z)
					_group("Ruins").add_child(proot)
					_add_box(proot, "Base", Vector3(0.62, 0.22, 0.62), Vector3(0.0, 0.11, 0.0), stone_col)
					_add_cylinder(proot, "Shaft", 0.20, 0.22, 2.2, Vector3(0.0, 1.22, 0.0), stone_col)
					_add_box(proot, "Capital", Vector3(0.58, 0.20, 0.58), Vector3(0.0, 2.52, 0.0), stone_col)
					if i % 2 == 0:
						_torch(proot, Vector3(0.0, 2.35, 0.0))

		6:
			# Acacia trees every 5 rows on both sides
			for i in range(length / 5):
				var row := i * 5 + 2
				var z := -float(row) * TILE_Z
				for s in [-1.0, 1.0]:
					if rng.randf() < 0.65:
						_acacia_tree(
							Vector3(s * rng.randf_range(4.5, 5.8), 0.0, z + rng.randf_range(-1.0, 1.0)),
							rng
						)
			# Distant elephant silhouette mid-level
			var eleph_row := length / 2
			_elephant_silhouette(
				Vector3(rng.randf_range(-5.5, 5.5), 0.0, -float(eleph_row) * TILE_Z - 3.0),
				rng
			)
			# Warthog silhouette near end
			if length > 20:
				_warthog_silhouette(
					Vector3(rng.randf_range(-2.5, 2.5), 0.0, -float(length - 6) * TILE_Z),
					rng
				)
			# Sandy rock clusters along the sides
			for i in range(length / 3):
				var row := i * 3 + 1
				var z := -float(row) * TILE_Z
				if rng.randf() < 0.50:
					_sandy_rock_cluster(
						Vector3((-1.0 if i % 2 == 0 else 1.0) * rng.randf_range(3.2, 4.8), 0.0, z + rng.randf_range(-0.8, 0.8)),
						rng
					)

		7, 8, 9:  # Wildlands Settlement — wooden posts, crates, tool racks
			var stone_col: Color = _theme.get("stone", COLOR_STONE)
			for i in range(length / 4):
				var row := i * 4 + 2
				var side: float = 1.0 if i % 2 == 0 else -1.0
				if rng.randf() < 0.70:
					# Wooden post or log stack on path edge
					var proot := Node3D.new()
					proot.name = "SettlementPost"
					proot.position = _row_local(row, side * rng.randf_range(3.2, 4.4), 0.0, rng.randf_range(-0.8, 0.8))
					_group("RocksAndLogs").add_child(proot)
					_add_cylinder(proot, "Post", 0.08, 0.10, rng.randf_range(0.9, 1.6),
						Vector3(0.0, 0.8, 0.0), Color(0.38, 0.22, 0.10))
					if rng.randf() < 0.45:
						_add_box(proot, "Plank",
							Vector3(rng.randf_range(0.5, 0.9), 0.08, 0.10),
							Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(0.6, 1.3), 0.0),
							Color(0.42, 0.26, 0.12))
				if rng.randf() < 0.45:
					# Crate / supply box
					var crate := _add_box(_group("RocksAndLogs"), "Crate",
						Vector3(rng.randf_range(0.30, 0.48), rng.randf_range(0.28, 0.44), rng.randf_range(0.30, 0.48)),
						_row_local(row, -side * rng.randf_range(3.0, 4.2), 0.20, rng.randf_range(-1.2, 1.2)),
						Color(0.46, 0.30, 0.14))
					crate.rotation_degrees.y = rng.randf_range(-20.0, 20.0)
			# Campfire every ~12 rows
			for i in range(max(1, length / 12)):
				var cf_row := i * 12 + 6
				var cf_side: float = 1.0 if i % 2 == 0 else -1.0
				var cf_root := Node3D.new()
				cf_root.name = "Campfire"
				cf_root.position = _row_local(cf_row, cf_side * rng.randf_range(3.4, 4.8), 0.0, rng.randf_range(-0.4, 0.4))
				_group("Animals").add_child(cf_root)
				_add_sphere(cf_root, "Glow", 0.18, Vector3(0.0, 0.08, 0.0), Color(1.0, 0.55, 0.12))
				_add_box(cf_root, "Log1", Vector3(0.36, 0.07, 0.09), Vector3(-0.09, 0.04, 0.0), stone_col.lerp(Color(0.28, 0.16, 0.06), 0.6))
				_add_box(cf_root, "Log2", Vector3(0.09, 0.07, 0.36), Vector3(0.0, 0.04, -0.09), stone_col.lerp(Color(0.28, 0.16, 0.06), 0.6))

		10, 11, 13:  # Wildlife valley — animal silhouettes and tall grass clumps
			for i in range(length / 5):
				var row := i * 5 + 3
				var side: float = 1.0 if i % 2 == 0 else -1.0
				# Tall grass clump
				var gx: float = side * rng.randf_range(3.4, 5.0)
				var groot := Node3D.new()
				groot.name = "TallGrass"
				groot.position = _row_local(row, gx, 0.0, rng.randf_range(-1.0, 1.0))
				_group("GrassAndPlants").add_child(groot)
				_register_wind(groot, 0.065, 1.28, rng.randf_range(0.0, TAU))
				for b in range(rng.randi_range(4, 7)):
					var blade := _add_box(groot, "Blade%d" % b,
						Vector3(0.05, rng.randf_range(0.65, 1.10), 0.04),
						Vector3(rng.randf_range(-0.22, 0.22), 0.45, rng.randf_range(-0.22, 0.22)),
						_theme.get("grass_light", COLOR_GRASS_LIGHT).lerp(Color(0.55, 0.60, 0.18), rng.randf_range(0.0, 0.5)))
					blade.rotation_degrees.z = rng.randf_range(-18.0, 18.0)
			# Wildlife silhouettes — antelope, warthog, bird
			if length > 15:
				for n in range(min(3, length / 12)):
					var arow := 6 + n * (length / 3)
					var side2: float = 1.0 if n % 2 == 0 else -1.0
					var aroot := Node3D.new()
					aroot.name = "Antelope"
					aroot.position = _row_local(arow, side2 * rng.randf_range(5.0, 6.2), 0.0, 0.0)
					_group("Animals").add_child(aroot)
					# Simple antelope silhouette: body + legs + neck + head + horns
					_add_box(aroot, "Body", Vector3(0.48, 0.22, 0.18), Vector3(0.0, 0.55, 0.0), Color(0.52, 0.38, 0.18))
					_add_cylinder(aroot, "Neck", 0.06, 0.07, 0.28, Vector3(0.18, 0.75, 0.0), Color(0.52, 0.38, 0.18))
					_add_sphere(aroot, "Head", 0.09, Vector3(0.26, 0.96, 0.0), Color(0.52, 0.38, 0.18))
					for f in range(4):
						var fx: float = -0.16 + float(f % 2) * 0.32
						var fz: float = -0.06 + float(f / 2) * 0.12
						_add_cylinder(aroot, "Leg%d" % f, 0.04, 0.04, 0.48,
							Vector3(fx, 0.24, fz), Color(0.42, 0.28, 0.12))
					# Horn
					_add_cylinder(aroot, "Horn", 0.025, 0.01, 0.22, Vector3(0.24, 1.12, 0.0), Color(0.76, 0.68, 0.44))

		12:  # Water slide gorge — moss-dripping walls, spray puffs
			var stone_col_w: Color = _theme.get("stone", COLOR_STONE)
			for i in range(length / 3):
				var row := i * 3 + 2
				for s in [-1.0, 1.0]:
					# Mossy gorge wall slab
					if rng.randf() < 0.65:
						var slab := _add_box(_group("Ruins"), "GorgeWall",
							Vector3(0.30, rng.randf_range(1.2, 2.2), 0.20),
							_row_local(row, s * rng.randf_range(3.0, 3.8), 1.0, rng.randf_range(-0.6, 0.6)),
							stone_col_w.lerp(_theme.get("moss", COLOR_MOSS), rng.randf_range(0.3, 0.7)))
						slab.rotation_degrees.y = rng.randf_range(-6.0, 6.0)
					# Water spray puff
					if rng.randf() < 0.50:
						_add_sphere(_group("GrassAndPlants"), "Spray",
							rng.randf_range(0.10, 0.18),
							_row_local(row, s * rng.randf_range(1.5, 2.5), rng.randf_range(0.12, 0.45), rng.randf_range(-0.4, 0.4)),
							Color(0.75, 0.92, 1.0, 0.65))

		14, 15:  # Market dock — wooden plank stalls, hanging lanterns
			var plank_col := Color(0.38, 0.24, 0.10)
			var light_col := Color(1.00, 0.88, 0.46)
			for i in range(length / 5):
				var row := i * 5 + 2
				var side: float = 1.0 if i % 2 == 0 else -1.0
				if rng.randf() < 0.65:
					# Market stall frame
					var stall := Node3D.new()
					stall.name = "MarketStall"
					stall.position = _row_local(row, side * rng.randf_range(3.8, 5.0), 0.0, rng.randf_range(-0.9, 0.9))
					_group("Ruins").add_child(stall)
					for p in range(2):
						_add_cylinder(stall, "Post%d" % p, 0.06, 0.07, 1.8,
							Vector3(-0.38 + float(p) * 0.76, 0.9, 0.0), plank_col)
					_add_box(stall, "Roof",
						Vector3(0.92, 0.07, 0.52), Vector3(0.0, 1.88, 0.0), plank_col.lightened(0.15))
					# Hanging lantern
					_add_sphere(stall, "Lantern", 0.09, Vector3(0.0, 1.72, 0.0), light_col)
			# Reed clusters along the lower/market edge
			for i in range(length / 3):
				var reed_row := i * 3 + 1
				if rng.randf() < 0.55:
					var rroot := Node3D.new()
					rroot.name = "RiverReed"
					rroot.position = _row_local(reed_row, (1.0 if i % 2 == 0 else -1.0) * rng.randf_range(4.0, 5.2), 0.0, rng.randf_range(-0.4, 0.4))
					_group("GrassAndPlants").add_child(rroot)
					_register_wind(rroot, 0.055, 1.15, rng.randf_range(0.0, TAU))
					for r in range(rng.randi_range(3, 5)):
						var stem := _add_box(rroot, "Stem%d" % r,
							Vector3(0.04, rng.randf_range(0.50, 0.90), 0.04),
							Vector3(rng.randf_range(-0.15, 0.15), 0.35, rng.randf_range(-0.15, 0.15)),
							Color(0.30, 0.52, 0.28))
						stem.rotation_degrees.z = rng.randf_range(-10.0, 10.0)
					_add_sphere(rroot, "Top", 0.05, Vector3(0.0, 0.92, 0.0), Color(0.46, 0.32, 0.12))

		16, 19:  # Escape/panic run — fallen logs across path sides, warning markers
			for i in range(length / 4):
				var row := i * 4 + 2
				var side: float = 1.0 if i % 2 == 0 else -1.0
				if rng.randf() < 0.55:
					# Fallen log across path edge
					var flog := _add_box(_group("RocksAndLogs"), "FallenLog",
						Vector3(rng.randf_range(0.65, 0.95), 0.14, 0.18),
						_row_local(row, side * rng.randf_range(2.9, 3.8), 0.07, rng.randf_range(-0.8, 0.8)),
						COLOR_LOG)
					flog.rotation_degrees.y = rng.randf_range(-25.0, 25.0)
				if rng.randf() < 0.35:
					# Disturbed earth mound
					var mound := _add_sphere(_group("Terrain"), "Mound",
						rng.randf_range(0.28, 0.44),
						_row_local(row, -side * rng.randf_range(3.2, 4.5), 0.04, rng.randf_range(-1.2, 1.2)),
						_theme.get("dirt_dark", COLOR_DIRT))
					mound.scale.y = 0.30

		17:  # Rapids/boat — dark river boulders, mist wisps on banks
			for i in range(length / 3):
				var row := i * 3 + 1
				for s in [-1.0, 1.0]:
					# River boulder
					if rng.randf() < 0.60:
						var boul := _add_sphere(_group("RocksAndLogs"), "RiverBoulder",
							rng.randf_range(0.22, 0.42),
							_row_local(row, s * rng.randf_range(2.8, 4.2), 0.10, rng.randf_range(-0.9, 0.9)),
							_theme.get("stone", COLOR_STONE).darkened(0.25))
						boul.scale.y = 0.55
					# Mist wisp
					if rng.randf() < 0.40:
						var wisp := _add_sphere(_group("GrassAndPlants"), "Mist",
							rng.randf_range(0.18, 0.32),
							_row_local(row, s * rng.randf_range(3.5, 5.0), rng.randf_range(0.2, 0.7), rng.randf_range(-0.6, 0.6)),
							Color(0.78, 0.88, 0.96, 0.38))
						wisp.scale = Vector3(2.2, 0.55, 1.4)

		18:  # Relic trail — glowing stone tablets, purple-grey ruins
			for i in range(length / 4):
				var row := i * 4 + 2
				for s in [-1.0, 1.0]:
					if rng.randf() < 0.60:
						var troot := Node3D.new()
						troot.name = "RelicTablet"
						troot.position = _row_local(row, s * rng.randf_range(3.5, 4.8), 0.0, rng.randf_range(-0.7, 0.7))
						troot.rotation_degrees.y = rng.randf_range(-15.0, 15.0)
						_group("Ruins").add_child(troot)
						var stone_c: Color = _theme.get("stone", COLOR_STONE)
						_add_box(troot, "Slab", Vector3(0.28, 0.66, 0.09), Vector3(0.0, 0.33, 0.0), stone_c)
						# Glowing glyph
						var gm := _add_box(troot, "Glyph", Vector3(0.16, 0.16, 0.06), Vector3(0.0, 0.44, 0.02), Color(0.72, 0.44, 1.0))
						var gmat := StandardMaterial3D.new()
						gmat.albedo_color = Color(0.72, 0.44, 1.0)
						gmat.emission_enabled = true
						gmat.emission = Color(0.60, 0.26, 0.98)
						gmat.emission_energy_multiplier = 1.2
						gm.material_override = gmat
						_relic_glows.append(gm)

		20:  # Baobab Treasure — huge baobab trunks, scattered gold relics
			for i in range(length / 6):
				var row := i * 6 + 3
				var side: float = 1.0 if i % 2 == 0 else -1.0
				# Baobab trunk silhouette
				var broot := Node3D.new()
				broot.name = "Baobab"
				broot.position = _row_local(row, side * rng.randf_range(5.0, 6.5), 0.0, rng.randf_range(-1.5, 1.5))
				_group("Trees").add_child(broot)
				var trunk_h: float = rng.randf_range(2.2, 3.0)
				_add_cylinder(broot, "Trunk", 0.55, 0.70, trunk_h,
					Vector3(0.0, trunk_h * 0.5, 0.0), Color(0.40, 0.24, 0.10))
				# Crown branches
				for b in range(rng.randi_range(3, 5)):
					var ang := deg_to_rad(float(b) * 72.0 + rng.randf_range(-20.0, 20.0))
					var blen: float = rng.randf_range(0.7, 1.2)
					var branch := _add_cylinder(broot, "Branch%d" % b, 0.10, 0.07, blen,
						Vector3(cos(ang) * blen * 0.5, trunk_h + 0.3, sin(ang) * blen * 0.5),
						Color(0.35, 0.20, 0.08))
					branch.rotation_degrees.z = rng.randf_range(35.0, 55.0) * sign(cos(ang))
			# Gold relic glints scattered across the approach
			for i in range(length / 5):
				var row := i * 5 + 4
				if rng.randf() < 0.55:
					var grelic := _add_box(_group("Ruins"), "GoldRelic",
						Vector3(0.18, 0.06, 0.18),
						_row_local(row, rng.randf_range(-3.5, 3.5), 0.03, rng.randf_range(-1.0, 1.0)),
						Color(0.96, 0.82, 0.18))
					var grmat := StandardMaterial3D.new()
					grmat.albedo_color = Color(0.96, 0.82, 0.18)
					grmat.emission_enabled = true
					grmat.emission = Color(0.88, 0.70, 0.08)
					grmat.emission_energy_multiplier = 0.7
					grelic.material_override = grmat
					_relic_glows.append(grelic)

func _spawn_path_variation(data: Dictionary) -> void:
	# Open-sky levels: no jungle arches or root-crossing strips
	if _level_id in [6, 10, 13, 16, 19]:
		return
	var length: int = data.get("length", 30)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 42)) + 5555
	var stone_col: Color = _theme.get("stone", COLOR_STONE)

	# Leaning root-arch landmarks over path edges every 8 rows
	for row in range(5, length - 2, 8):
		var z := -float(row) * TILE_Z
		for s in [-1.0, 1.0]:
			var arch_h := rng.randf_range(1.5, 2.1)
			var aroot := Node3D.new()
			aroot.name = "PathArch"
			aroot.position = Vector3(s * (PATH_WIDTH * 0.50 + 0.12), 0.0, z + rng.randf_range(-0.4, 0.4))
			_group("Trees").add_child(aroot)
			var trunk_col := COLOR_TRUNK.lerp(COLOR_LOG, rng.randf_range(0.0, 0.45))
			var aleg := _add_cylinder(aroot, "ArchLeg", 0.11, 0.17, arch_h,
				Vector3(0.0, arch_h * 0.5, 0.0), trunk_col)
			aleg.rotation_degrees.z = s * rng.randf_range(20.0, 34.0)
			if rng.randf() < 0.65:
				var avine := _add_box(aroot, "ArchVine",
					Vector3(0.06, rng.randf_range(0.45, 0.80), 0.06),
					Vector3(-s * 0.14, arch_h * 0.52, 0.0),
					COLOR_FERN.lerp(Color(0.08, 0.30, 0.08), rng.randf_range(0.0, 0.4))
				)
				avine.rotation_degrees.z = rng.randf_range(-8.0, 8.0)

	# Stone edge markers at path sides (give path a bordered feel)
	for row in range(3, length - 1, 5):
		if rng.randf() > 0.55:
			continue
		var z := -float(row) * TILE_Z + rng.randf_range(-0.65, 0.65)
		for s in [-1.0, 1.0]:
			if rng.randf() > 0.72:
				continue
			var marker := _add_box(
				_group("Ruins"), "PathEdge",
				Vector3(rng.randf_range(0.18, 0.32), rng.randf_range(0.08, 0.20), rng.randf_range(0.20, 0.38)),
				Vector3(s * (PATH_WIDTH * 0.50 - 0.04), 0.05, z),
				stone_col.lerp(COLOR_STONE_DARK, rng.randf_range(0.0, 0.40))
			)
			marker.rotation_degrees.y = rng.randf_range(-25.0, 25.0)

	# Ground-level root strips crossing path at mid-section rows
	for row in range(6, length - 2, 10):
		var z := -float(row) * TILE_Z + rng.randf_range(-0.5, 0.5)
		if rng.randf() < 0.60:
			var rstrip := _add_box(_group("GrassAndPlants"), "GroundRoot",
				Vector3(rng.randf_range(1.8, 2.8), 0.06, 0.10),
				Vector3(rng.randf_range(-0.8, 0.8), 0.02, z),
				COLOR_LOG.lerp(COLOR_TRUNK, rng.randf_range(0.0, 0.5))
			)
			rstrip.rotation_degrees.y = rng.randf_range(-18.0, 18.0)

# ─── Wildlands (Level 6) helpers ────────────────────────────────────────────

const COLOR_DRY_GRASS  := Color(0.72, 0.60, 0.24)
const COLOR_SANDY_SOIL := Color(0.82, 0.68, 0.36)
const COLOR_CLAY       := Color(0.48, 0.34, 0.18)
const COLOR_ACACIA_BARK:= Color(0.38, 0.24, 0.10)
const COLOR_ACACIA_CAN := Color(0.22, 0.38, 0.10)
const COLOR_ELEPHANT   := Color(0.28, 0.26, 0.24)

func _spawn_wildlands_dressing(data: Dictionary, rng: RandomNumberGenerator) -> void:
	var length: int = data.get("length", 30)
	for row in range(1, length + 4):
		var z := -float(row) * TILE_Z + rng.randf_range(-0.6, 0.6)
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			var near_x := side * rng.randf_range(2.8, 3.3)
			var mid_x  := side * rng.randf_range(3.8, 4.6)
			var far_x  := side * rng.randf_range(5.0, 6.0)
			# Dry grass tufts near path
			if rng.randf() < 0.72:
				_dry_grass_tuft(Vector3(near_x, 0.0, z + rng.randf_range(-0.7, 0.7)), rng)
			# Sandy rocks at mid distance
			if rng.randf() < 0.30:
				_sandy_rock_cluster(Vector3(mid_x, 0.0, z + rng.randf_range(-0.8, 0.8)), rng)
			# Far trees sparse
			if row % 3 == 0 and rng.randf() < 0.40:
				_acacia_tree(Vector3(far_x, 0.0, z), rng)

func _wildlife_glb(animal: String, pos: Vector3, s: Vector3, rot_y: float = 0.0) -> void:
	var root := Node3D.new()
	root.name = animal.capitalize()
	root.position = pos
	root.rotation_degrees.y = rot_y
	_group("Animals").add_child(root)
	if _place_glb(root, "res://assets/3d/wildlife/%s.glb" % animal, Vector3.ZERO, s) == null:
		if animal == "elephant":
			var rng2 := RandomNumberGenerator.new()
			_elephant_silhouette(pos, rng2)
			root.queue_free()

func _spawn_wildlands_wildlife(data: Dictionary, rng: RandomNumberGenerator) -> void:
	var length: int = data.get("length", 30)
	var mid_z  := -float(length / 2) * TILE_Z
	var end_z  := -float(length - 6) * TILE_Z
	var near_z := -float(6) * TILE_Z

	# Birds arcing across the sky
	for i in range(2):
		var row := 5 + i * 9
		_bird(
			Vector3(-6.2, rng.randf_range(3.2, 4.4), -float(row) * TILE_Z),
			Vector3(6.2,  rng.randf_range(3.4, 4.8), -float(row + 3) * TILE_Z),
			rng
		)

	# Background wildlife — all placed at |x| > 4.0, never in the gameplay lanes
	_wildlife_glb("elephant",    Vector3(rng.randf_range(4.5, 6.0),  0.0, end_z),          Vector3(1.6, 1.6, 1.6), 180.0)
	_wildlife_glb("giraffe",     Vector3(-rng.randf_range(5.5, 7.0), 0.0, end_z + 8.0),    Vector3(1.2, 1.2, 1.2), 90.0)
	_wildlife_glb("zebra",       Vector3(rng.randf_range(4.0, 5.5),  0.0, mid_z),           Vector3(1.0, 1.0, 1.0), 200.0)
	_wildlife_glb("lion",        Vector3(-rng.randf_range(4.5, 5.5), 0.0, mid_z - 10.0),   Vector3(0.9, 0.9, 0.9), 160.0)
	_wildlife_glb("cape_buffalo",Vector3(rng.randf_range(4.0, 5.5),  0.0, mid_z + 10.0),   Vector3(1.1, 1.1, 1.1), 220.0)
	_wildlife_glb("rhino",       Vector3(-rng.randf_range(5.0, 6.0), 0.0, near_z + 4.0),   Vector3(1.2, 1.2, 1.2), 140.0)
	_wildlife_glb("warthog",     Vector3(rng.randf_range(4.2, 5.0),  0.0, near_z),          Vector3(0.7, 0.7, 0.7), 100.0)
	if length > 25:
		_wildlife_glb("leopard", Vector3(-rng.randf_range(4.5, 5.5), 0.0, end_z + 16.0),   Vector3(0.8, 0.8, 0.8), 250.0)

func _dry_grass_tuft(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "DryGrass"
	root.position = pos
	_group("GrassAndPlants").add_child(root)
	_register_wind(root, 0.065, 1.18, rng.randf_range(0.0, TAU))
	var blades := 2 + rng.randi_range(0, 3)
	for i in range(blades):
		var c := COLOR_DRY_GRASS.lerp(COLOR_SANDY_SOIL, rng.randf_range(0.0, 0.35))
		var blade := _add_box(root, "Blade", Vector3(0.06, rng.randf_range(0.22, 0.50), 0.06),
			Vector3(rng.randf_range(-0.15, 0.15), 0.14, rng.randf_range(-0.12, 0.12)), c)
		blade.rotation_degrees.z = rng.randf_range(-22.0, 22.0)
		blade.rotation_degrees.x = rng.randf_range(-8.0, 8.0)

func _sandy_rock_cluster(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "SandyRocks"
	root.position = pos
	_group("RocksAndLogs").add_child(root)
	var count := 1 + rng.randi_range(0, 2)
	for i in range(count):
		var r := rng.randf_range(0.08, 0.22)
		var rock := _add_sphere(root, "Rock%d" % i, r,
			Vector3(rng.randf_range(-0.22, 0.22), r * 0.55, rng.randf_range(-0.16, 0.16)),
			COLOR_CLAY.lerp(COLOR_SANDY_SOIL, rng.randf_range(0.0, 0.50))
		)
		rock.scale.y = rng.randf_range(0.45, 0.75)
		rock.scale.x = rng.randf_range(0.85, 1.30)

func _acacia_tree(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "AcaciaTree"
	root.position = pos
	root.rotation_degrees.y = rng.randf_range(0.0, 360.0)
	_group("Trees").add_child(root)
	_register_wind(root, 0.016, 0.45, rng.randf_range(0.0, TAU))
	var trunk_h := rng.randf_range(1.4, 2.2)
	_add_cylinder(root, "Trunk", 0.09, 0.13, trunk_h,
		Vector3(0.0, trunk_h * 0.5, 0.0), COLOR_ACACIA_BARK)
	# Flat spreading canopy — acacia characteristic shape
	var canopy_w := rng.randf_range(1.2, 1.9)
	var canopy_c := COLOR_ACACIA_CAN.lerp(Color(0.30, 0.44, 0.12), rng.randf_range(0.0, 0.40))
	var canopy := _add_box(root, "Canopy",
		Vector3(canopy_w, rng.randf_range(0.25, 0.42), canopy_w * 0.9),
		Vector3(0.0, trunk_h + 0.14, 0.0), canopy_c)
	canopy.rotation_degrees.y = rng.randf_range(0.0, 45.0)
	# A secondary smaller sub-canopy
	if rng.randf() < 0.60:
		_add_box(root, "SubCanopy",
			Vector3(canopy_w * 0.55, 0.18, canopy_w * 0.50),
			Vector3(rng.randf_range(-0.3, 0.3), trunk_h + 0.26, rng.randf_range(-0.25, 0.25)),
			canopy_c.lerp(COLOR_ACACIA_CAN, 0.3)
		)

func _elephant_silhouette(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "ElephantSilhouette"
	root.position = pos
	_group("Animals").add_child(root)
	var sc := rng.randf_range(0.85, 1.15)
	root.scale = Vector3(sc, sc, sc)
	var c := COLOR_ELEPHANT
	# Body
	_add_box(root, "Body", Vector3(1.20, 0.74, 0.56), Vector3(0.0, 0.52, 0.0), c)
	# Head
	_add_sphere(root, "Head", 0.30, Vector3(0.66, 0.82, 0.0), c)
	# Trunk
	_add_box(root, "Trunk1", Vector3(0.10, 0.40, 0.10), Vector3(0.88, 0.52, 0.0), c)
	_add_box(root, "Trunk2", Vector3(0.10, 0.22, 0.10), Vector3(0.98, 0.20, 0.0), c)
	# Ear
	_add_box(root, "Ear", Vector3(0.06, 0.28, 0.32), Vector3(0.60, 0.88, 0.15), c)
	# Legs
	for i in range(4):
		var lx := -0.36 + float(i % 2) * 0.72
		var lz := -0.14 + float(i / 2) * 0.28
		_add_box(root, "Leg%d" % i, Vector3(0.18, 0.36, 0.16), Vector3(lx, 0.18, lz), c)
	# Tail
	_add_box(root, "Tail", Vector3(0.06, 0.26, 0.06), Vector3(-0.64, 0.52, 0.0), c)

func _warthog_silhouette(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "WarthogSilhouette"
	root.position = pos
	_group("Animals").add_child(root)
	var c := Color(0.32, 0.24, 0.14)
	# Body
	_add_box(root, "Body", Vector3(0.54, 0.28, 0.24), Vector3(0.0, 0.22, 0.0), c)
	# Head
	_add_box(root, "Head", Vector3(0.22, 0.22, 0.20), Vector3(0.32, 0.28, 0.0), c)
	# Tusks
	_add_box(root, "Tusk1", Vector3(0.14, 0.04, 0.04), Vector3(0.44, 0.20, 0.06), Color(0.88, 0.82, 0.62))
	_add_box(root, "Tusk2", Vector3(0.14, 0.04, 0.04), Vector3(0.44, 0.20, -0.06), Color(0.88, 0.82, 0.62))
	# Legs
	for i in range(4):
		var lx := -0.16 + float(i % 2) * 0.32
		var lz := -0.08 + float(i / 2) * 0.16
		_add_box(root, "Leg%d" % i, Vector3(0.08, 0.18, 0.07), Vector3(lx, 0.10, lz), c)
	# Tail (upright when running)
	var tail := _add_box(root, "Tail", Vector3(0.04, 0.18, 0.04), Vector3(-0.28, 0.34, 0.0), c)
	tail.rotation_degrees.z = 15.0

func _place_glb(parent: Node3D, path: String, offset: Vector3, s: Vector3) -> Node3D:
	if not ResourceLoader.exists(path):
		return null
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	var inst := packed.instantiate() as Node3D
	if inst == null:
		return null
	inst.position = offset
	inst.scale    = s
	parent.add_child(inst)
	return inst

func _add_box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = node_name
	mesh.mesh = BoxMesh.new()
	(mesh.mesh as BoxMesh).size = size
	_set_color(mesh, color)
	mesh.position = pos
	parent.add_child(mesh)
	return mesh

func _add_cylinder(parent: Node3D, node_name: String, top_radius: float, bottom_radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = node_name
	mesh.mesh = CylinderMesh.new()
	(mesh.mesh as CylinderMesh).top_radius = top_radius
	(mesh.mesh as CylinderMesh).bottom_radius = bottom_radius
	(mesh.mesh as CylinderMesh).height = height
	(mesh.mesh as CylinderMesh).radial_segments = 8
	_set_color(mesh, color)
	mesh.position = pos
	parent.add_child(mesh)
	return mesh

func _add_sphere(parent: Node3D, node_name: String, radius: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = node_name
	mesh.mesh = SphereMesh.new()
	(mesh.mesh as SphereMesh).radius = radius
	(mesh.mesh as SphereMesh).height = radius * 2.0
	(mesh.mesh as SphereMesh).radial_segments = 8
	(mesh.mesh as SphereMesh).rings = 4
	_set_color(mesh, color)
	mesh.position = pos
	parent.add_child(mesh)
	return mesh

func _add_static_box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, meta: Dictionary = {}) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	var col := CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	(col.shape as BoxShape3D).size = size
	body.add_child(col)
	for key in meta.keys():
		body.set_meta(str(key), meta[key])
	parent.add_child(body)
	return body

func _set_color(mesh: MeshInstance3D, color: Color) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	if color.a < 0.999:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.roughness = 0.92
	mesh.material_override = mat
