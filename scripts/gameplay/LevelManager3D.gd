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

var level_data: Dictionary = {}
var _coin_count: int = 0
var _total_coins: int = 0
var _coin_nodes: Array[Node3D] = []
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
var _turn_rows: Dictionary = {}

func build(data: Dictionary) -> void:
	level_data = data
	_coin_count = 0
	_total_coins = 0
	_time = 0.0
	_coin_nodes.clear()
	_butterflies.clear()
	_birds.clear()
	_torch_flames.clear()
	_relic_glows.clear()
	_groups.clear()
	_path_tiles.clear()
	_seg_pos.clear()
	_seg_fwd.clear()
	_seg_right.clear()
	_turn_rows.clear()

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
	_spawn_wildlife(data)
	_spawn_level_specific_dressing(data)
	_spawn_path_variation(data)
	_spawn_turn_zones(data)
	_spawn_finish(data)
	_count_total_coins(data)

func _process(delta: float) -> void:
	_time += delta
	_animate_coins(delta)
	_animate_butterflies()
	_animate_birds()
	_animate_torches()
	_animate_relic_glows()

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
		"FinishGate"
	]:
		var group := Node3D.new()
		group.name = group_name
		_groups[group_name] = group
		add_child(group)

func _group(name: String) -> Node3D:
	return _groups.get(name, self) as Node3D

func _parse_turns(data: Dictionary) -> void:
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
		if _turn_rows.has(i):
			var d: int = _turn_rows[i]
			fwd = fwd.rotated(Vector3.UP, -float(d) * PI * 0.5).normalized()
			right = right.rotated(Vector3.UP, -float(d) * PI * 0.5).normalized()
		cursor += fwd * TILE_Z

func _world_pos(row: int, lane: int) -> Vector3:
	var sp: Vector3 = _seg_pos.get(row, Vector3(0.0, 0.0, -float(row) * TILE_Z))
	var sf: Vector3 = _seg_fwd.get(row, Vector3(0.0, 0.0, -1.0))
	var sr: Vector3 = _seg_right.get(row, Vector3(1.0, 0.0, 0.0))
	return sp + sf * (TILE_Z * 0.5) + sr * _lane_x(lane)

func _spawn_ground(data: Dictionary) -> void:
	var length: int = data.get("length", 30)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(data.get("seed", 42)) + 101

	for i in range(length + 5):
		var seg_p: Vector3 = _seg_pos.get(i, Vector3(0.0, 0.0, -float(i) * TILE_Z))
		var seg_f: Vector3 = _seg_fwd.get(i, Vector3(0.0, 0.0, -1.0))
		var heading_y := atan2(seg_f.x, -seg_f.z)

		var segment := Node3D.new()
		segment.name = "PathSegment_%02d" % i
		segment.position = seg_p
		segment.rotation.y = heading_y
		_group("JunglePath").add_child(segment)
		_path_tiles[i] = segment

		var dirt_d: Color = _theme.get("dirt_dark", COLOR_DIRT)
		var dirt_l: Color = _theme.get("dirt_light", COLOR_DIRT_LIGHT)
		_add_box(segment, "DirtPath",
			Vector3(PATH_WIDTH, 0.16, TILE_Z + 0.08),
			Vector3(0.0, -0.08, 0.0),
			dirt_d.lerp(dirt_l, rng.randf_range(0.0, 0.35))
		)
		_add_static_box(segment, "PathCollision",
			Vector3(PATH_WIDTH, 0.16, TILE_Z + 0.08),
			Vector3(0.0, -0.08, 0.0),
			{"surface": _theme.get("surface", "dirt")}
		)
		# Grass tiles as children so they rotate with path direction
		_add_box(segment, "GrassLeft",
			Vector3(SIDE_GROUND_WIDTH, 0.12, TILE_Z + 0.08),
			Vector3(-4.75, -0.12, 0.0), _grass_color(rng))
		_add_box(segment, "GrassRight",
			Vector3(SIDE_GROUND_WIDTH, 0.12, TILE_Z + 0.08),
			Vector3(4.75, -0.12, 0.0), _grass_color(rng))

		if i % 2 == 0:
			_spawn_path_edge_details(seg_p.z, rng)

func _spawn_path_edge_details(z: float, rng: RandomNumberGenerator) -> void:
	var parent := _group("GrassAndPlants")
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		for j in range(2):
			var x: float = side * rng.randf_range(2.60, 3.10)
			var detail_z: float = z + rng.randf_range(-1.25, 1.25)
			if rng.randf() < 0.55:
				_grass_clump(Vector3(x, 0.0, detail_z), rng)
			else:
				_fern(Vector3(x, 0.0, detail_z), rng)

		if rng.randf() < 0.55:
			_pebble_cluster(parent, Vector3(side * rng.randf_range(2.15, 2.75), 0.02, z + rng.randf_range(-1.2, 1.2)), rng)
		if rng.randf() < 0.30:
			_root_strip(parent, Vector3(0.0, 0.02, z + rng.randf_range(-1.1, 1.1)), rng)

func _spawn_obstacles(data: Dictionary) -> void:
	var obstacles: Array = data.get("obstacles", [])
	for ob in obstacles:
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
		"mud":
			_area_slow(Vector3(PATH_WIDTH, 0.05, TILE_Z), COLOR_MUD, base + Vector3(0.0, 0.03, 0.0))
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

	for i in range(3):
		var spike := _add_cylinder(root, "Stake", 0.0, 0.15, 0.76, Vector3(-0.28 + float(i) * 0.28, 0.0, 0.0), COLOR_SPIKE)
		spike.rotation_degrees.z = -7.0 + float(i) * 7.0
	_add_static_box(root, "SpikeCollision", Vector3(0.95, 0.70, 0.78), Vector3(0.0, 0.0, 0.0), {"obstacle": true})

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
		GameManager.collect_gem()
	else:
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
		var z := -float(row) * TILE_Z + rng.randf_range(-0.8, 0.8)
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			var near_x: float = side * rng.randf_range(2.85, 3.25)
			var mid_x: float = side * rng.randf_range(3.75, 4.55)
			var far_x: float = side * rng.randf_range(5.20, 6.20)

			if rng.randf() < 0.80:
				_grass_clump(Vector3(near_x, 0.0, z + rng.randf_range(-0.8, 0.8)), rng)
			if rng.randf() < 0.55:
				_fern(Vector3(near_x + side * rng.randf_range(0.2, 0.45), 0.0, z + rng.randf_range(-0.6, 0.6)), rng)
			if rng.randf() < 0.72:
				_bush(Vector3(mid_x, 0.0, z + rng.randf_range(-0.9, 0.9)), rng)
			if rng.randf() < 0.35:
				_pebble_cluster(_group("RocksAndLogs"), Vector3(mid_x + side * 0.30, 0.04, z + rng.randf_range(-0.8, 0.8)), rng)

			if row % 2 == 0:
				if rng.randf() < 0.45:
					_palm_tree(Vector3(far_x, 0.0, z), rng)
				else:
					_jungle_tree(Vector3(far_x, 0.0, z), rng)

			if row % 4 == 1 and rng.randf() < 0.50:
				_fallen_log_dressing(Vector3(side * rng.randf_range(4.15, 4.90), 0.18, z + rng.randf_range(-1.0, 1.0)), side, rng)

			if row % 5 == 0 and rng.randf() < 0.65:
				_ruin_fragment(Vector3(side * rng.randf_range(4.8, 5.6), 0.0, z), rng)

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

func _grass_clump(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "GrassClump"
	root.position = pos
	_group("GrassAndPlants").add_child(root)

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

	for i in range(5):
		var leaf := _add_box(root, "FernLeaf", Vector3(0.10, 0.06, rng.randf_range(0.45, 0.70)), Vector3(0.0, 0.20 + float(i) * 0.04, 0.0), COLOR_FERN.lerp(COLOR_GRASS_LIGHT, rng.randf_range(0.0, 0.35)))
		leaf.rotation_degrees.y = -55.0 + float(i) * 27.5
		leaf.rotation_degrees.x = rng.randf_range(-18.0, -8.0)

func _bush(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "Bush"
	root.position = pos
	_group("GrassAndPlants").add_child(root)

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
	var vine := _add_box(parent, "Vine", Vector3(0.07, rng.randf_range(0.80, 1.35), 0.07), pos + Vector3(0.0, -0.40, 0.0), COLOR_FERN)
	vine.rotation_degrees.z = rng.randf_range(-8.0, 8.0)

func _pebble_cluster(parent: Node3D, pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "Pebbles"
	root.position = pos
	parent.add_child(root)
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
	var log := _add_cylinder(root, "SideLog", 0.18, 0.24, rng.randf_range(1.2, 2.2), Vector3.ZERO, COLOR_LOG)
	log.rotation_degrees.x = 90.0

func _ruin_fragment(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "MossyRuin"
	root.position = pos
	root.rotation_degrees.y = rng.randf_range(-18.0, 18.0)
	_group("Ruins").add_child(root)

	_add_box(root, "BrokenStone", Vector3(0.55, rng.randf_range(0.55, 1.20), 0.45), Vector3(0.0, 0.35, 0.0), COLOR_STONE)
	var cap := _add_box(root, "Moss", Vector3(0.60, 0.08, 0.48), Vector3(0.0, 0.95, 0.0), COLOR_MOSS)
	cap.rotation_degrees.z = rng.randf_range(-6.0, 6.0)

func _butterfly(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "Butterfly"
	root.position = pos
	_group("Animals").add_child(root)

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

func _spawn_finish(data: Dictionary) -> void:
	var length: int = data.get("length", 30)
	var gate_pos: Vector3 = _seg_pos.get(length, Vector3(0.0, 0.0, -float(length) * TILE_Z))
	var gate_fwd: Vector3 = _seg_fwd.get(length, Vector3(0.0, 0.0, -1.0))
	var heading_y := atan2(gate_fwd.x, -gate_fwd.z)
	var root := Node3D.new()
	root.name = "TempleFinishGate"
	root.position = gate_pos
	root.rotation.y = heading_y
	_group("FinishGate").add_child(root)

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

func _animate_coins(delta: float) -> void:
	for coin in _coin_nodes.duplicate():
		if not is_instance_valid(coin):
			_coin_nodes.erase(coin)
			continue
		coin.rotate_y(delta * 4.0)
		var base_y := float(coin.get_meta("base_y", 0.80))
		var phase := float(coin.get_meta("phase", 0.0))
		coin.position.y = base_y + sin(_time * 3.0 + phase) * 0.08

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
				var z := -float(i * 3 + 2) * TILE_Z
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
				var z := -float(i * 4 + 2) * TILE_Z
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

func _spawn_path_variation(data: Dictionary) -> void:
	if _level_id == 6:
		return  # Savanna has open sky — no jungle arches or root strips
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

func _spawn_wildlands_wildlife(data: Dictionary, rng: RandomNumberGenerator) -> void:
	var length: int = data.get("length", 30)
	# Birds crossing the sky
	for i in range(2):
		var row := 5 + i * 9
		_bird(
			Vector3(-6.2, rng.randf_range(3.2, 4.4), -float(row) * TILE_Z),
			Vector3(6.2, rng.randf_range(3.4, 4.8), -float(row + 3) * TILE_Z),
			rng
		)
	# Background elephant at end of level
	if length > 15:
		_elephant_silhouette(
			Vector3(rng.randf_range(3.5, 5.5), 0.0, -float(length - 8) * TILE_Z - 3.0),
			rng
		)

func _dry_grass_tuft(pos: Vector3, rng: RandomNumberGenerator) -> void:
	var root := Node3D.new()
	root.name = "DryGrass"
	root.position = pos
	_group("GrassAndPlants").add_child(root)
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
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.roughness = 0.92
	mesh.material_override = mat
