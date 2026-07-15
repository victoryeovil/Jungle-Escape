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

const REVIVE_GEM_COST := 5

var _level_id: int   = 1
var _finished: bool  = false
var _dead: bool      = false
var _cam_xz: Vector2 = Vector2(0.0, 4.5)  # smoothed (x-behind, z-behind) from player
var _active_mode: String = "run"
var _junction_active: bool = false
var _shake_time: float = 0.0
# Endless mode
var _endless: bool = false
var _stage: int = 1
var _stage_rows_done: int = 0
var _stage_length: int = 0
var _endless_distance_m: int = 0
# Revive + tutorial
var _revive_used: bool = false
var _last_row: int = 0
var _last_guidance: Array = []   # cached args of the latest path_segment_entered
var _tutorial_hints: Dictionary = {}

func _ready() -> void:
	_endless = GameManager.endless_mode
	_level_id = GameManager.current_level_id
	_apply_level_atmosphere(EndlessLevel.theme_for_stage(1) if _endless else _level_id)
	# Single shadow split with a short range: the camera only ever sees ~30 m
	# of ground, and one split costs a quarter of the default four on mobile.
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 34.0
	_load_and_build_level()
	if game_over.has_signal("revive_requested"):
		game_over.connect("revive_requested", _on_revive_requested)
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
	player.vfx_requested.connect(func(kind: String, pos: Vector3) -> void:
		level_mgr.spawn_vfx(kind, pos)
	)
	hud.call("setup", _level_id)
	GameManager.state = GameManager.GameState.PLAYING
	EventBus.play_music.emit("gameplay")

func _load_and_build_level() -> void:
	if _endless:
		_build_endless_stage()
		return
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
	player.set_level_speed(_level_id)
	_setup_tutorial(data)

func _build_endless_stage() -> void:
	var data := EndlessLevel.generate(_stage, GameManager.endless_run_seed)
	level_mgr.build(data)
	_stage_length = int(data.get("length", 40))
	player.set_run_speed(EndlessLevel.speed_for_stage(_stage))
	hud.call("set_progress_text", "Stage %d  •  %d m" % [_stage, _endless_distance_m])

func _setup_tutorial(data: Dictionary) -> void:
	_tutorial_hints.clear()
	if _level_id != 1 or bool(SaveManager.get_setting("tutorial_seen", false)):
		return
	_tutorial_hints[1] = "Swipe  ◀ ▶  to change lanes"
	var first_jump := -1
	var first_slide := -1
	var first_dodge := -1
	for ob in data.get("obstacles", []):
		if not (ob is Dictionary):
			continue
		var row := int(ob.get("row", 0))
		match str(ob.get("type", "")):
			"log":
				if first_jump < 0 or row < first_jump:
					first_jump = row
			"branch", "low_branch":
				if first_slide < 0 or row < first_slide:
					first_slide = row
			_:
				if first_dodge < 0 or row < first_dodge:
					first_dodge = row
	if first_dodge > 3:
		_tutorial_hints[first_dodge - 3] = "Rock ahead — swipe  ◀ ▶  to dodge!"
	if first_jump > 3:
		_tutorial_hints[first_jump - 3] = "Log ahead — swipe  ▲  to JUMP!"
	if first_slide > 3:
		_tutorial_hints[first_slide - 3] = "Branch ahead — swipe  ▼  to SLIDE!"

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
		7:   # Wildlands Settlement — warm working morning
			return {
				"background": Color(0.55, 0.66, 0.78),
				"ambient": Color(0.78, 0.76, 0.58),
				"ambient_energy": 0.42,
				"fog": Color(0.62, 0.62, 0.44),
				"fog_density": 0.015,
				"sun_color": Color(1.00, 0.92, 0.72),
				"sun_energy": 1.22,
				"fill_color": Color(0.60, 0.54, 0.38),
				"fill_energy": 0.28,
			}
		8:   # Foundation Run — dusty build site, clay haze
			return {
				"background": Color(0.62, 0.56, 0.44),
				"ambient": Color(0.80, 0.70, 0.54),
				"ambient_energy": 0.40,
				"fog": Color(0.70, 0.58, 0.42),
				"fog_density": 0.018,
				"sun_color": Color(1.00, 0.86, 0.62),
				"sun_energy": 1.16,
				"fill_color": Color(0.56, 0.46, 0.32),
				"fill_energy": 0.28,
			}
		9:   # Timber Trail — deep jungle canopy gloom
			return {
				"background": Color(0.12, 0.22, 0.14),
				"ambient": Color(0.30, 0.48, 0.28),
				"ambient_energy": 0.34,
				"fog": Color(0.16, 0.30, 0.18),
				"fog_density": 0.026,
				"sun_color": Color(0.76, 0.90, 0.62),
				"sun_energy": 0.92,
				"fill_color": Color(0.22, 0.38, 0.26),
				"fill_energy": 0.26,
			}
		10:  # Lost Paw Trail — golden savanna edge
			return {
				"background": Color(0.66, 0.72, 0.62),
				"ambient": Color(0.84, 0.80, 0.56),
				"ambient_energy": 0.44,
				"fog": Color(0.72, 0.68, 0.44),
				"fog_density": 0.013,
				"sun_color": Color(1.00, 0.92, 0.60),
				"sun_energy": 1.28,
				"fill_color": Color(0.62, 0.56, 0.36),
				"fill_energy": 0.28,
			}
		11:  # Rabbit Tracks — lush green valley
			return {
				"background": Color(0.44, 0.66, 0.70),
				"ambient": Color(0.62, 0.84, 0.56),
				"ambient_energy": 0.44,
				"fog": Color(0.44, 0.66, 0.42),
				"fog_density": 0.015,
				"sun_color": Color(0.96, 1.00, 0.84),
				"sun_energy": 1.22,
				"fill_color": Color(0.40, 0.58, 0.40),
				"fill_energy": 0.28,
			}
		12:  # Water Slide Trail — cool teal gorge mist
			return {
				"background": Color(0.34, 0.52, 0.56),
				"ambient": Color(0.50, 0.72, 0.72),
				"ambient_energy": 0.42,
				"fog": Color(0.40, 0.62, 0.64),
				"fog_density": 0.024,
				"sun_color": Color(0.80, 0.96, 0.94),
				"sun_energy": 1.04,
				"fill_color": Color(0.30, 0.50, 0.54),
				"fill_energy": 0.32,
			}
		13:  # Park Guide Path — bright open clearing
			return {
				"background": Color(0.58, 0.76, 0.90),
				"ambient": Color(0.82, 0.86, 0.66),
				"ambient_energy": 0.46,
				"fog": Color(0.66, 0.74, 0.52),
				"fog_density": 0.011,
				"sun_color": Color(1.00, 0.98, 0.82),
				"sun_energy": 1.30,
				"fill_color": Color(0.62, 0.62, 0.44),
				"fill_energy": 0.28,
			}
		14:  # Warthog Watch — warm sandstone afternoon
			return {
				"background": Color(0.64, 0.60, 0.48),
				"ambient": Color(0.82, 0.72, 0.54),
				"ambient_energy": 0.42,
				"fog": Color(0.68, 0.58, 0.40),
				"fog_density": 0.016,
				"sun_color": Color(1.00, 0.84, 0.56),
				"sun_energy": 1.18,
				"fill_color": Color(0.56, 0.46, 0.32),
				"fill_energy": 0.28,
			}
		15:  # Market Skate & River Dock — festive late day
			return {
				"background": Color(0.70, 0.62, 0.52),
				"ambient": Color(0.86, 0.74, 0.58),
				"ambient_energy": 0.44,
				"fog": Color(0.70, 0.58, 0.44),
				"fog_density": 0.014,
				"sun_color": Color(1.00, 0.80, 0.52),
				"sun_energy": 1.20,
				"fill_color": Color(0.58, 0.46, 0.34),
				"fill_energy": 0.30,
			}
		16:  # Antelope Trail — dark urgent thicket
			return {
				"background": Color(0.14, 0.20, 0.14),
				"ambient": Color(0.32, 0.44, 0.28),
				"ambient_energy": 0.32,
				"fog": Color(0.18, 0.28, 0.17),
				"fog_density": 0.028,
				"sun_color": Color(0.74, 0.84, 0.58),
				"sun_energy": 0.90,
				"fill_color": Color(0.22, 0.34, 0.22),
				"fill_energy": 0.24,
			}
		17:  # Rapids Run — dark wet river mist
			return {
				"background": Color(0.28, 0.40, 0.46),
				"ambient": Color(0.44, 0.62, 0.64),
				"ambient_energy": 0.40,
				"fog": Color(0.34, 0.50, 0.54),
				"fog_density": 0.027,
				"sun_color": Color(0.74, 0.90, 0.92),
				"sun_energy": 0.96,
				"fill_color": Color(0.26, 0.42, 0.46),
				"fill_energy": 0.32,
			}
		18:  # Hound of the Hidden Trail — violet dusk among relics
			return {
				"background": Color(0.24, 0.20, 0.32),
				"ambient": Color(0.44, 0.38, 0.54),
				"ambient_energy": 0.36,
				"fog": Color(0.30, 0.24, 0.40),
				"fog_density": 0.024,
				"sun_color": Color(0.86, 0.70, 0.92),
				"sun_energy": 0.92,
				"fill_color": Color(0.34, 0.28, 0.44),
				"fill_energy": 0.28,
			}
		19:  # Boar Escape — red dust panic run
			return {
				"background": Color(0.56, 0.40, 0.30),
				"ambient": Color(0.76, 0.56, 0.40),
				"ambient_energy": 0.40,
				"fog": Color(0.62, 0.42, 0.28),
				"fog_density": 0.020,
				"sun_color": Color(1.00, 0.72, 0.44),
				"sun_energy": 1.14,
				"fill_color": Color(0.52, 0.36, 0.24),
				"fill_energy": 0.28,
			}
		20:  # Treasure Beneath the Baobab — golden amber finale
			return {
				"background": Color(0.72, 0.58, 0.36),
				"ambient": Color(0.90, 0.76, 0.50),
				"ambient_energy": 0.46,
				"fog": Color(0.78, 0.62, 0.38),
				"fog_density": 0.015,
				"sun_color": Color(1.00, 0.84, 0.46),
				"sun_energy": 1.30,
				"fill_color": Color(0.62, 0.50, 0.30),
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
	_last_row = row
	_last_guidance = [row, center, fwd, right, surface, mode, width, lanes]
	GameManager.last_fail_row = row
	if _endless:
		_endless_distance_m = int(float(_stage_rows_done + row) * 3.0)
		hud.call("set_progress_text", "Stage %d  •  %d m" % [_stage, _endless_distance_m])
	if _tutorial_hints.has(row):
		hud.call("show_hint", str(_tutorial_hints[row]))
		_tutorial_hints.erase(row)
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
	level_mgr.spawn_vfx("hit", player.global_position + Vector3(0.0, 0.9, 0.0))
	# Brief slow-motion beat so the player sees what killed them
	Engine.time_scale = 0.35
	await get_tree().create_timer(0.5, true, false, true).timeout
	Engine.time_scale = 1.0
	if not is_inside_tree():
		return
	GameManager.state = GameManager.GameState.GAME_OVER
	get_tree().paused = true
	var can_revive := not _revive_used and SaveManager.get_gems() >= REVIVE_GEM_COST

	if _endless:
		var best := int(SaveManager.get_setting("endless_best_m", 0))
		var is_record := _endless_distance_m > best
		if is_record:
			SaveManager.set_setting("endless_best_m", _endless_distance_m)
			best = _endless_distance_m
		var elapsed := Time.get_ticks_msec() / 1000.0 - GameManager._level_start_time
		Analytics.level_fail(0, "endless_end", _last_row, elapsed, _stage)
		SupabaseClient.submit_endless_score(best)
		game_over.call("show_endless_over", _endless_distance_m, best, is_record, can_revive, REVIVE_GEM_COST)
		return

	# Feed the fail into analytics + adaptive difficulty (was previously
	# only wired for the 2D grid mode)
	EventBus.level_failed.emit(_level_id, "obstacle")
	var message := "You hit an obstacle!"
	if _level_id > 3:
		var lost_life := SaveManager.lose_life(_level_id)
		if lost_life:
			message += "\n\nExpedition Life lost. " + SaveManager.get_lives_display() + " remain."
		else:
			message += "\n\nNo Expedition Lives were available."
	game_over.call("show_fail", message, can_revive, REVIVE_GEM_COST)

func _advance_endless_stage() -> void:
	_stage_rows_done += _stage_length
	_stage += 1
	_active_mode = "run"
	_apply_level_atmosphere(EndlessLevel.theme_for_stage(_stage))
	_build_endless_stage()
	player.reset(1)
	player.global_position = Vector3(0.0, 0.5, 0.0)
	player.set_run_speed(EndlessLevel.speed_for_stage(_stage))
	_cam_xz = Vector2(0.0, 4.5)
	_finished = false
	hud.call("show_hint", "STAGE %d" % _stage, 1.8)
	EventBus.play_sfx.emit("gate_open")

func _on_revive_requested() -> void:
	if _revive_used or not SaveManager.spend_gems(REVIVE_GEM_COST):
		return
	_revive_used = true
	_dead = false
	get_tree().paused = false
	GameManager.state = GameManager.GameState.PLAYING
	game_over.visible = false
	var safe_row: int = max(_last_row - 1, 0)
	var safe_pos: Vector3 = level_mgr.get_row_center(safe_row) + Vector3(0.0, 0.6, 0.0)
	level_mgr.clear_obstacles_near(safe_pos, 15.0)
	player.revive(safe_pos)
	if _last_guidance.size() == 8:
		player.set_path_guidance(_last_guidance[0], _last_guidance[1], _last_guidance[2],
			_last_guidance[3], _last_guidance[4], _last_guidance[5], _last_guidance[6], _last_guidance[7])

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _on_finish_reached() -> void:
	if _finished or _dead:
		return
	if _endless:
		# Seamless stage chain — deferred so the finish Area3D isn't freed
		# while its body_entered signal is still being flushed.
		if not _finished:
			_finished = true
			_advance_endless_stage.call_deferred()
		return
	_finished = true
	if _level_id == 1:
		SaveManager.set_setting("tutorial_seen", true)
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
