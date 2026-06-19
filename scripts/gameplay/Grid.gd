extends Node2D
class_name Grid

# The grid is the heart of the game. It:
#   1. Loads a level JSON file and instantiates tiles.
#   2. Controls player movement in response to swipe input.
#   3. Detects level completion and failure.

signal level_ready()

# ── Dependencies (set by GameplayScreen) ──────────────────────────────────────
var player: Player
var input_handler: InputHandler

# ── Level state ───────────────────────────────────────────────────────────────
var level_data: Dictionary = {}
var grid_width: int = 0
var grid_height: int = 0
var _tile_nodes: Dictionary = {}   # Vector2i -> BaseTile (or null for floor/wall)
var _vine_pairs: Array = []        # [{pos_a, pos_b}] for teleport pairs
var _switch_gates: Dictionary = {} # switch_id -> [Vector2i, ...]
var _exit_pos: Vector2i = Vector2i(-1, -1)
var _player_start: Vector2i = Vector2i.ZERO
var _is_resolving: bool = false    # block input while animating

# Tile scene preloads — assign in the Inspector or swap for instancing
const TILE_SCENES := {
	"W": null,   # wall — drawn as a ground sprite
	".": null,   # floor — drawn as a ground sprite
	"C": preload("res://scenes/gameplay/tiles/CoinTile.tscn"),
	"M": preload("res://scenes/gameplay/tiles/GemTile.tscn"),
	"K": preload("res://scenes/gameplay/tiles/KeyTile.tscn"),
	"G": preload("res://scenes/gameplay/tiles/GateTile.tscn"),
	"E": preload("res://scenes/gameplay/tiles/ExitTile.tscn"),
	"S": preload("res://scenes/gameplay/tiles/SpikeTile.tscn"),
	"N": preload("res://scenes/gameplay/tiles/SnakeTile.tscn"),
	"R": preload("res://scenes/gameplay/tiles/RiverTile.tscn"),
	"B": preload("res://scenes/gameplay/tiles/BridgeTile.tscn"),
	"U": preload("res://scenes/gameplay/tiles/MudTile.tscn"),
	"X": preload("res://scenes/gameplay/tiles/SwitchTile.tscn"),
	"V": preload("res://scenes/gameplay/tiles/VineTile.tscn"),
	"F": preload("res://scenes/gameplay/tiles/FruitTile.tscn"),
}

const _FLOOR_PATH  := "res://assets/sprites/tiles/floor.png"
const _WALL_PATH   := "res://assets/sprites/tiles/wall.png"
const _RIVER_PATH  := "res://assets/sprites/tiles/river.png"

# ── Public ─────────────────────────────────────────────────────────────────────

func load_level(level_id: int) -> void:
	level_data = LevelLoader.load_level(level_id)
	if level_data.is_empty():
		push_error("Grid: failed to load level " + str(level_id))
		return
	_build_grid()
	_center_grid()
	_connect_input()
	level_ready.emit()

func teleport_player(dest: Vector2i) -> void:
	player.teleport_to(dest)

func activate_switch(switch_id: String) -> void:
	if not _switch_gates.has(switch_id):
		return
	for gate_pos in _switch_gates[switch_id]:
		if _tile_nodes.has(gate_pos):
			var gate = _tile_nodes[gate_pos]
			if gate is GateTile:
				gate.open_gate()
				_tile_nodes.erase(gate_pos)

# ── Grid construction ──────────────────────────────────────────────────────────

func _build_grid() -> void:
	# Clear previous children except Player
	for child in get_children():
		if not child is Player:
			child.queue_free()
	_tile_nodes.clear()
	_vine_pairs.clear()
	_switch_gates.clear()

	var rows: Array = level_data.get("grid", [])
	grid_height = rows.size()
	grid_width = 0
	if grid_height > 0:
		grid_width = (rows[0] as String).length()

	var vine_positions: Array = []

	for row_idx in range(grid_height):
		var row_str: String = rows[row_idx]
		for col_idx in range(row_str.length()):
			var ch := row_str[col_idx]
			var gp := Vector2i(col_idx, row_idx)
			_spawn_floor(gp, ch)
			_spawn_tile(ch, gp, vine_positions)

	_pair_vines(vine_positions)
	_parse_switch_gates()
	GameManager.move_limit = level_data.get("move_limit", 0)

func _spawn_floor(gp: Vector2i, tile_char: String) -> void:
	var tex_path: String
	match tile_char:
		"W": tex_path = _WALL_PATH
		"B": tex_path = _RIVER_PATH
		_:   tex_path = _FLOOR_PATH

	if ResourceLoader.exists(tex_path):
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.position = _gp_to_local(gp)
		sprite.texture = load(tex_path) as Texture2D
		var tex_size := sprite.texture.get_size()
		if tex_size.x > 0.0 and tex_size.y > 0.0:
			sprite.scale = Vector2(
				Constants.TILE_SIZE / tex_size.x,
				Constants.TILE_SIZE / tex_size.y
			)
		add_child(sprite)
	else:
		var rect := ColorRect.new()
		rect.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
		rect.position = _gp_to_local(gp)
		match tile_char:
			"W":  rect.color = Color(0.10, 0.07, 0.03)
			"R":  rect.color = Color(0.10, 0.40, 0.90)
			_:    rect.color = Color(0.18, 0.35, 0.10)
		add_child(rect)

func _spawn_tile(ch: String, gp: Vector2i, vine_positions: Array) -> void:
	match ch:
		"P":
			_player_start = gp
			if player:
				player.teleport_to(gp)
		"E":
			_exit_pos = gp
			_instance_tile(ch, gp)
		"W":
			# Wall blocks use the wall floor sprite and do not need a tile node.
			pass
		"V":
			vine_positions.append(gp)
			_instance_tile(ch, gp)
		_:
			if ch != ".":
				_instance_tile(ch, gp)

func _instance_tile(ch: String, gp: Vector2i) -> void:
	if not TILE_SCENES.has(ch) or TILE_SCENES[ch] == null:
		return
	var tile: BaseTile = TILE_SCENES[ch].instantiate()
	tile.position = _gp_to_local(gp)
	tile.grid_pos = gp
	add_child(tile)
	_tile_nodes[gp] = tile

func _parse_switch_gates() -> void:
	# Level JSON format: "switch_gates": {"A": [[col,row], ...], "B": [[col,row], ...]}
	var raw: Variant = level_data.get("switch_gates", {})
	if raw is Dictionary:
		var raw_dict: Dictionary = raw
		for sid in raw_dict:
			var gate_list: Array = []
			for pair in raw_dict[sid]:
				if pair is Array:
					var pair_arr: Array = pair
					if pair_arr.size() >= 2:
						gate_list.append(Vector2i(int(pair_arr[0]), int(pair_arr[1])))
			_switch_gates[str(sid)] = gate_list

func _pair_vines(positions: Array) -> void:
	# Pair vines sequentially: V[0]↔V[1], V[2]↔V[3], etc.
	var i := 0
	while i + 1 < positions.size():
		var a: Vector2i = positions[i]
		var b: Vector2i = positions[i + 1]
		(_tile_nodes[a] as VineTile).destination = b
		(_tile_nodes[b] as VineTile).destination = a
		i += 2

func _center_grid() -> void:
	var viewport_size := get_viewport_rect().size
	var grid_px := Vector2(grid_width * Constants.TILE_SIZE, grid_height * Constants.TILE_SIZE)
	position = (viewport_size - grid_px) / 2.0

func _gp_to_local(gp: Vector2i) -> Vector2:
	return Vector2(gp.x * Constants.TILE_SIZE, gp.y * Constants.TILE_SIZE)

# ── Input / movement ───────────────────────────────────────────────────────────

func _connect_input() -> void:
	if input_handler and not input_handler.swiped.is_connected(_on_swipe):
		input_handler.swiped.connect(_on_swipe)

func _on_swipe(direction: Vector2i) -> void:
	if _is_resolving or player.is_moving:
		return
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	_try_move(direction)

func _try_move(direction: Vector2i) -> void:
	var new_pos := player.grid_pos + direction
	if not _in_bounds(new_pos):
		return

	var tile = _tile_nodes.get(new_pos, null)

	# Wall check (no tile node but floor colour used)
	var grid_rows: Array = level_data["grid"]
	var row_str: String  = grid_rows[new_pos.y]
	if new_pos.x < row_str.length() and row_str[new_pos.x] == "W":
		EventBus.play_sfx.emit("bump")
		return

	# Let tile decide if player can enter (gates, etc.)
	if tile != null and not tile.interact(player):
		return

	_is_resolving = true
	GameManager.register_move()
	player.move_to(new_pos)
	await player.move_finished
	_is_resolving = false

	# Post-move: call on_player_enter
	if tile != null:
		tile.on_player_enter(player)

	# Check exit
	if new_pos == _exit_pos:
		await get_tree().create_timer(0.3).timeout
		var perfect_moves: int = level_data.get("perfect_moves", level_data.get("move_limit", GameManager.moves_used))
		GameManager.complete_current_level(perfect_moves)

func _in_bounds(gp: Vector2i) -> bool:
	return gp.x >= 0 and gp.y >= 0 and gp.x < grid_width and gp.y < grid_height
