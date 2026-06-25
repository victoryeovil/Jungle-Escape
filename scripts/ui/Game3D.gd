extends Node3D

const LEVEL_DATA_PATH := "res://data/levels3d/level3d_%03d.json"

@onready var player:          Player3D       = $Player
@onready var level_mgr:       LevelManager3D = $LevelManager
@onready var input_handler:   InputHandler3D = $InputHandler
@onready var hud:             Node           = $HUD
@onready var pause_menu:      Control        = $PauseMenu
@onready var level_complete:  Control        = $LevelComplete
@onready var game_over:       Control        = $GameOver
@onready var cam_pivot:       Node3D         = $CamPivot
@onready var world_env:       WorldEnvironment = $WorldEnvironment
@onready var sun:             DirectionalLight3D = $Sun
@onready var ambient_fill:    DirectionalLight3D = $AmbientFill

var _level_id: int   = 1
var _finished: bool  = false
var _dead: bool      = false
var _cam_xz: Vector2 = Vector2(0.0, 4.5)  # smoothed (x-behind, z-behind) from player
var _active_mode: String = "run"
var _junction_active: bool = false
var _shake_time: float = 0.0

func _ready() -> void:
	_level_id = GameManager.current_level_id
	_apply_level_atmosphere(_level_id)
	_load_and_build_level()
	input_handler.player = player
	player.died.connect(_on_player_died)
	player.sand_blocked.connect(func() -> void: hud.call("show_sand_warning"))
	level_mgr.finish_reached.connect(_on_finish_reached)
	level_mgr.turn_zone_entered.connect(player._on_turn_zone_entered)
	level_mgr.turn_zone_exited.connect(player._on_turn_zone_exited)
	level_mgr.turn_zone_entered.connect(func(dir: int, cp: Vector3) -> void: hud.call("show_turn_prompt", dir, cp))
	level_mgr.turn_zone_exited.connect(func() -> void: hud.call("hide_turn_prompt"))
	level_mgr.path_segment_entered.connect(_on_path_segment_entered)
	level_mgr.junction_entered.connect(_on_junction_entered)
	level_mgr.junction_exited.connect(_on_junction_exited)
	player.junction_route_chosen.connect(_on_junction_route_chosen)
	player.attract_coins_request.connect(func(pos: Vector3, radius: float) -> void:
		level_mgr.attract_coins(pos, radius)
	)
	player.tribal_path_reveal.connect(func(routes: Array) -> void:
		hud.call("show_tribal_routes", routes)
	)
	player.grass_step.connect(level_mgr.add_grass_footprint)
	hud.call("setup", _level_id)
	GameManager.state = GameManager.GameState.PLAYING
	EventBus.play_music.emit("gameplay")

func _load_and_build_level() -> void:
	var path := LEVEL_DATA_PATH % _level_id
	var data: Dictionary = {}
	if ResourceLoader.exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var raw: Variant = JSON.parse_string(file.get_as_text())
			file.close()
			if raw is Dictionary:
				data = raw
	if data.is_empty():
		push_warning("Game3D: level data missing for " + str(_level_id) + "; using defaults")
		data = _default_level(_level_id)
	level_mgr.build(data)

func _apply_level_atmosphere(id: int) -> void:
	if world_env.environment == null:
		return
	var env := world_env.environment.duplicate() as Environment
	world_env.environment = env

	var atmosphere := _level_atmosphere(id)
	env.background_color = atmosphere.get("background", env.background_color)
	env.ambient_light_color = atmosphere.get("ambient", env.ambient_light_color)
	env.ambient_light_energy = atmosphere.get("ambient_energy", env.ambient_light_energy)
	env.fog_enabled = true
	env.fog_light_color = atmosphere.get("fog", env.fog_light_color)
	env.fog_density = atmosphere.get("fog_density", env.fog_density)

	sun.light_color = atmosphere.get("sun_color", sun.light_color)
	sun.light_energy = atmosphere.get("sun_energy", sun.light_energy)
	ambient_fill.light_color = atmosphere.get("fill_color", ambient_fill.light_color)
	ambient_fill.light_energy = atmosphere.get("fill_energy", ambient_fill.light_energy)

func _level_atmosphere(id: int) -> Dictionary:
	match id:
		2:
			return {
				"background": Color(0.17, 0.30, 0.18),
				"ambient": Color(0.36, 0.55, 0.30),
				"ambient_energy": 0.34,
				"fog": Color(0.22, 0.38, 0.22),
				"fog_density": 0.021,
				"sun_color": Color(0.82, 0.92, 0.68),
				"sun_energy": 0.98,
				"fill_color": Color(0.25, 0.42, 0.32),
				"fill_energy": 0.26,
			}
		3:
			return {
				"background": Color(0.32, 0.50, 0.58),
				"ambient": Color(0.52, 0.72, 0.70),
				"ambient_energy": 0.40,
				"fog": Color(0.42, 0.65, 0.68),
				"fog_density": 0.026,
				"sun_color": Color(0.80, 0.94, 0.88),
				"sun_energy": 1.06,
				"fill_color": Color(0.28, 0.52, 0.58),
				"fill_energy": 0.36,
			}
		4:
			return {
				"background": Color(0.15, 0.18, 0.15),
				"ambient": Color(0.36, 0.40, 0.28),
				"ambient_energy": 0.31,
				"fog": Color(0.28, 0.32, 0.23),
				"fog_density": 0.031,
				"sun_color": Color(0.82, 0.72, 0.52),
				"sun_energy": 0.88,
				"fill_color": Color(0.22, 0.30, 0.24),
				"fill_energy": 0.24,
			}
		5:
			return {
				"background": Color(0.39, 0.30, 0.19),
				"ambient": Color(0.72, 0.58, 0.36),
				"ambient_energy": 0.38,
				"fog": Color(0.68, 0.46, 0.22),
				"fog_density": 0.024,
				"sun_color": Color(1.00, 0.72, 0.34),
				"sun_energy": 1.18,
				"fill_color": Color(0.45, 0.28, 0.16),
				"fill_energy": 0.30,
			}
		6:
			return {
				"background": Color(0.62, 0.52, 0.32),
				"ambient": Color(0.82, 0.72, 0.50),
				"ambient_energy": 0.44,
				"fog": Color(0.72, 0.60, 0.38),
				"fog_density": 0.010,
				"sun_color": Color(1.00, 0.90, 0.58),
				"sun_energy": 1.32,
				"fill_color": Color(0.58, 0.44, 0.24),
				"fill_energy": 0.30,
			}
		_:
			return {
				"background": Color(0.40, 0.70, 0.95),
				"ambient": Color(0.75, 0.90, 0.65),
				"ambient_energy": 0.45,
				"fog": Color(0.50, 0.75, 0.45),
				"fog_density": 0.012,
				"sun_color": Color(1.00, 1.00, 1.00),
				"sun_energy": 1.30,
				"fill_color": Color(1.00, 1.00, 1.00),
				"fill_energy": 0.30,
			}

func _default_level(id: int) -> Dictionary:
	return { "id": id, "length": 20 + id * 5, "seed": id * 17,
			 "obstacles": [], "coins": [] }

func _process(delta: float) -> void:
	if _finished or _dead:
		return
	# Keep camera behind the player in their heading direction.
	# Snap instantly when the required movement is large (just after a turn)
	# so the player never runs off-screen; smooth-lerp for minor adjustments.
	var cam_distance := _camera_distance()
	var target_xz := Vector2(-player._move_fwd.x * cam_distance, -player._move_fwd.z * cam_distance)
	if (_cam_xz - target_xz).length_squared() > 6.0:
		_cam_xz = target_xz  # instant snap on turn
	else:
		_cam_xz = _cam_xz.lerp(target_xz, minf(1.0, delta * 8.0))
	var shake := Vector2.ZERO
	if _shake_time > 0.0:
		_shake_time -= delta
		shake = Vector2(sin(Time.get_ticks_msec() * 0.055), cos(Time.get_ticks_msec() * 0.047)) * 0.12
	cam_pivot.global_position.x = player.global_position.x + _cam_xz.x
	cam_pivot.global_position.z = player.global_position.z + _cam_xz.y
	cam_pivot.global_position.x += shake.x
	cam_pivot.global_position.z += shake.y
	cam_pivot.global_position.y = lerpf(cam_pivot.global_position.y, player.global_position.y + _camera_height(), minf(1.0, delta * 5.0))
	# Rotate cam_pivot so its local -Z points at the player.
	# World-forward of a Y-rotated node is (-sin θ, 0, -cos θ), so θ = atan2(-tx, -tz).
	var to_player := player.global_position - cam_pivot.global_position
	if to_player.length_squared() > 0.01:
		cam_pivot.rotation.y = atan2(-to_player.x, -to_player.z)

func _on_path_segment_entered(row: int, center: Vector3, fwd: Vector3, right: Vector3, surface: String, mode: String, width: float, lanes: int) -> void:
	player.set_path_guidance(row, center, fwd, right, surface, mode, width, lanes)
	var next_mode := mode if not mode.is_empty() else "run"
	if next_mode == _active_mode:
		return
	_active_mode = next_mode
	hud.call("show_mode", _active_mode, _mode_title(_active_mode), _mode_message(_active_mode))
	if _active_mode == "escape":
		_shake_time = 2.0

func _on_junction_entered(junction_id: String, routes: Array) -> void:
	_junction_active = true
	player.enter_junction(junction_id, routes)
	hud.call("show_junction_prompt", routes)

func _on_junction_exited(junction_id: String) -> void:
	_junction_active = false
	player.exit_junction(junction_id)
	hud.call("hide_junction_prompt")

func _on_junction_route_chosen(junction_id: String, direction: String, route: Dictionary) -> void:
	_junction_active = false
	level_mgr.apply_junction_choice(junction_id, direction, route)
	hud.call("hide_junction_prompt")
	hud.call("show_route_chosen", str(route.get("label", "Route")))

func _camera_distance() -> float:
	if _junction_active:
		return 6.1
	match _active_mode:
		"boat":
			return 6.4
		"water_slide":
			return 5.7
		"skating":
			return 5.3
		"chase", "escape":
			return 5.8
		_:
			return 4.5

func _camera_height() -> float:
	if _junction_active:
		return 3.2
	match _active_mode:
		"boat":
			return 3.3
		"water_slide":
			return 2.05
		"skating":
			return 2.35
		"chase", "escape":
			return 2.65
		_:
			return 2.5

func _mode_title(mode: String) -> String:
	match mode:
		"tracking":
			return "TRACKING"
		"chase":
			return "CHASE"
		"escape":
			return "SURVIVAL"
		"water_slide":
			return "WATER SLIDE"
		"boat":
			return "BOAT MODE"
		"skating":
			return "SKATE RUN"
		_:
			return ""

func _mode_message(mode: String) -> String:
	match mode:
		"tracking":
			return "Follow prints and choose the marked trail."
		"chase":
			return "Keep the animal in sight."
		"escape":
			return "Danger behind. Dodge and reach safety."
		"water_slide":
			return "Steer through rocks, vines and drops."
		"boat":
			return "Steer the canoe through river hazards."
		"skating":
			return "Glide through the market track and dodge lane hazards."
		_:
			return ""

func _on_player_died() -> void:
	if _dead:
		return
	_dead = true
	if GameManager.in_daily_challenge:
		GameManager._challenge_fail_count += 1
	EventBus.play_sfx.emit("game_over")
	GameManager.state = GameManager.GameState.GAME_OVER
	get_tree().paused = true
	var message := "You hit an obstacle!"
	if _level_id > 3:
		var lost_life := SaveManager.lose_life(_level_id)
		if lost_life:
			message += "\n\nExpedition Life lost. " + SaveManager.get_lives_display() + " remain."
		else:
			message += "\n\nNo Expedition Lives were available."
	game_over.call("show_fail", message)

func _on_finish_reached() -> void:
	if _finished:
		return
	_finished = true
	player.play_victory()
	player._is_dead = true
	EventBus.play_sfx.emit("level_complete")
	var coins := GameManager.session_coins
	var stars := _calc_stars(coins, level_mgr.get_total_coins())
	SaveManager.complete_level(_level_id, stars, coins)
	_award_level_resources(_level_id)
	# Provide challenge context before level_completed fires
	GameManager._challenge_completion_stars = stars
	GameManager._challenge_total_coins = level_mgr.get_total_coins()
	EventBus.level_completed.emit(_level_id, stars, coins, 0)
	GameManager.state = GameManager.GameState.LEVEL_COMPLETE
	get_tree().paused = true
	var rewards := _level_resource_rewards(_level_id)
	level_complete.call("show_result", stars, coins, _level_id, rewards)

func _award_level_resources(level_id: int) -> void:
	for res_id: String in _level_resource_rewards(level_id):
		GameManager.collect_resource(res_id, _level_resource_rewards(level_id)[res_id])

func _level_resource_rewards(level_id: int) -> Dictionary:
	match level_id:
		1: return { "map_pieces": 1 }
		2: return { "sunstone_shards": 1 }
		3: return { "wood": 1, "sunstone_shards": 1 }
		4: return { "relic_keys": 1, "bricks": 2, "sunstone_shards": 1 }
		5: return { "map_pieces": 1, "sunstone_shards": 1 }
		6: return { "wood": 1, "bricks": 2, "food": 1, "sunstone_shards": 1 }
		7: return { "wood": 2, "bricks": 3, "food": 1 }
		8: return { "bricks": 4, "tools": 1 }
		9: return { "wood": 4, "tools": 1 }
		10: return { "food": 2, "map_pieces": 1 }
		11: return { "animal_badge": 1, "food": 1 }
		12: return { "water_token": 2, "fish_token": 1, "wood": 1 }
		13: return { "animal_badge": 1, "food": 1 }
		14: return { "animal_badge": 1, "bricks": 2, "tiles": 1 }
		15: return { "trade_token": 2, "wood": 2, "windows": 1 }
		16: return { "animal_badge": 1, "map_pieces": 1 }
		17: return { "fish_token": 1, "river_relic": 1, "wood": 2 }
		18: return { "relic_keys": 1, "map_pieces": 1 }
		19: return { "tools": 2, "bricks": 3 }
		20: return { "sunstone_shards": 3, "river_relic": 1, "relic_keys": 1 }
		_: return {}

func _calc_stars(collected: int, total: int) -> int:
	if total == 0:
		return 3
	var ratio := float(collected) / float(total)
	if ratio >= 1.0: return 3
	if ratio >= 0.5: return 2
	return 1
