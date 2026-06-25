extends Node

# ── State ──────────────────────────────────────────────────────────────────────
enum GameState { MENU, PLAYING, PAUSED, LEVEL_COMPLETE, GAME_OVER, SHOP, SETTINGS }

var state: GameState = GameState.MENU
var current_level_id: int = 1
var session_coins: int = 0   # coins earned this level run
var session_keys: int = 0
var moves_used: int = 0
var move_limit: int = 0
var is_guest: bool = true
var is_logged_in: bool = false
var player_name: String = "Explorer"

var levels_since_login_prompt: int = 0
var _level_start_time: float = 0.0
var last_fail_row: int = 0
var login_required: bool = false
var pending_level_after_login: int = 0
var in_daily_challenge: bool = false
var daily_challenge_data: Dictionary = {}

# Challenge run tracking — reset on every level start
var _challenge_fail_count: int = 0
var _challenge_retry_used: bool = false
var _challenge_total_coins: int = 0    # set by Game3D before level_completed fires
var _challenge_completion_stars: int = 0  # set by Game3D before level_completed fires

func _ready() -> void:
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)
	EventBus.login_completed.connect(_on_login_completed)
	_apply_graphics_quality()

func _apply_graphics_quality() -> void:
	var vp := get_viewport()
	if not vp:
		return
	match SaveManager.get_setting("graphics_quality", "MED"):
		"LOW":
			vp.scaling_3d_scale = 0.66
			vp.msaa_3d = Viewport.MSAA_DISABLED
		"MED":
			vp.scaling_3d_scale = 1.0
			vp.msaa_3d = Viewport.MSAA_2X
		"HIGH":
			vp.scaling_3d_scale = 1.0
			vp.msaa_3d = Viewport.MSAA_4X

# ── Public API ─────────────────────────────────────────────────────────────────

func start_level(level_id: int) -> void:
	current_level_id = level_id
	session_coins = 0
	session_keys = 0
	moves_used = 0
	last_fail_row = 0
	_level_start_time = Time.get_ticks_msec() / 1000.0
	_challenge_fail_count = 0
	_challenge_total_coins = 0
	_challenge_completion_stars = 0
	state = GameState.PLAYING
	AdaptiveDifficulty.on_level_start(level_id)
	Analytics.level_start(level_id, SaveManager.get_selected_skin(), AdaptiveDifficulty.get_current_attempt(level_id))

func pause_game() -> void:
	if state == GameState.PLAYING:
		state = GameState.PAUSED
		get_tree().paused = true
		EventBus.pause_toggled.emit(true)

func resume_game() -> void:
	if state == GameState.PAUSED:
		state = GameState.PLAYING
		get_tree().paused = false
		EventBus.pause_toggled.emit(false)

func collect_coin() -> void:
	session_coins += 1
	EventBus.coin_collected.emit(session_coins)
	# Golden Explorer: lucky — earns bonus coins every 3 collected
	if SaveManager.get_selected_skin() == "golden":
		var player := _get_active_player()
		if player != null:
			player._golden_coin_counter += 1
			if player._golden_coin_counter >= 3:
				player._golden_coin_counter = 0
				session_coins += 1
				SaveManager.add_coins(1)
				EventBus.coin_collected.emit(session_coins)

func _get_active_player() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	var nodes := tree.get_nodes_in_group("player3d")
	return nodes[0] if not nodes.is_empty() else null

func collect_gem() -> void:
	SaveManager.add_gems(1)
	EventBus.gem_collected.emit(SaveManager.get_gems())

func collect_key() -> void:
	session_keys += 1
	EventBus.key_collected.emit(session_keys)

func spend_key() -> bool:
	if session_keys > 0:
		session_keys -= 1
		EventBus.key_collected.emit(session_keys)
		return true
	return false

func register_move() -> void:
	moves_used += 1
	EventBus.player_moved.emit(Vector2i.ZERO)

func calculate_stars(perfect_moves: int) -> int:
	if moves_used <= perfect_moves:
		return 3
	elif move_limit == 0 or moves_used <= move_limit:
		return 2
	else:
		return 1

func complete_current_level(perfect_moves: int) -> void:
	var stars := calculate_stars(perfect_moves)
	state = GameState.LEVEL_COMPLETE
	SaveManager.complete_level(current_level_id, stars, session_coins)
	levels_since_login_prompt += 1
	EventBus.level_completed.emit(current_level_id, stars, session_coins, moves_used)

func fail_current_level(reason: String = "trap") -> void:
	state = GameState.GAME_OVER
	EventBus.level_failed.emit(current_level_id, reason)

func should_show_login_prompt() -> bool:
	# Show after every 5 levels completed if still a guest
	if is_guest and levels_since_login_prompt >= 5:
		levels_since_login_prompt = 0
		return true
	return false

func go_to_menu() -> void:
	print("[NAV][GameManager] go_to_menu called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
	print("[NAV][GameManager] go_to_menu change_scene result=" + str(err))

func go_to_level_map() -> void:
	print("[NAV][GameManager] go_to_level_map called")
	state = GameState.MENU
	var err := get_tree().change_scene_to_file("res://scenes/level_map/LevelMap.tscn")
	print("[NAV][GameManager] go_to_level_map change_scene result=" + str(err))

func go_to_level_select() -> void:
	print("[NAV][GameManager] go_to_level_select called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/LevelSelect.tscn")
	print("[NAV][GameManager] go_to_level_select change_scene result=" + str(err))

func go_to_gameplay(level_id: int) -> void:
	print("[NAV][GameManager] go_to_gameplay called; level_id=" + str(level_id))
	start_level(level_id)
	var err := get_tree().change_scene_to_file("res://scenes/gameplay/GameplayScreen.tscn")
	print("[NAV][GameManager] go_to_gameplay change_scene result=" + str(err))

func go_to_gameplay_3d(level_id: int) -> void:
	print("[NAV][GameManager] go_to_gameplay_3d called; level_id=" + str(level_id))
	if level_id > 3 and not SupabaseClient.has_registration_key():
		print("[NAV][GameManager] go_to_gameplay_3d blocked; registration required for level", level_id)
		go_to_login_prompt(true, level_id)
		return
	if not SaveManager.can_start_level(level_id):
		print("[NAV][GameManager] go_to_gameplay_3d blocked; no expedition lives")
		state = GameState.MENU
		get_tree().paused = false
		return
	start_level(level_id)
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/game3d/Game3D.tscn")
	print("[NAV][GameManager] go_to_gameplay_3d change_scene result=" + str(err))

func go_to_login_prompt(required: bool = false, pending_level: int = 0) -> void:
	login_required = required
	pending_level_after_login = pending_level
	state = GameState.MENU
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")

func collect_resource(resource_id: String, amount: int) -> void:
	SaveManager.add_resource(resource_id, amount)
	EventBus.resource_collected.emit(resource_id, amount)

func go_to_upgrade_shop() -> void:
	print("[NAV][GameManager] go_to_upgrade_shop called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/UpgradeShop.tscn")
	print("[NAV][GameManager] go_to_upgrade_shop change_scene result=" + str(err))

func go_to_home_building() -> void:
	print("[NAV][GameManager] go_to_home_building called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/HomeBuilding.tscn")
	print("[NAV][GameManager] go_to_home_building change_scene result=" + str(err))

func go_to_wildlands_unlock() -> void:
	print("[NAV][GameManager] go_to_wildlands_unlock called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/WildlandsUnlock.tscn")
	print("[NAV][GameManager] go_to_wildlands_unlock change_scene result=" + str(err))

func restart_level() -> void:
	if in_daily_challenge:
		_challenge_retry_used = true
	get_tree().paused = false
	go_to_gameplay_3d(current_level_id)

# ── Signal handlers ────────────────────────────────────────────────────────────

func _on_level_completed(level_id: int, stars: int, coins: int, _moves: int) -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _level_start_time
	AdaptiveDifficulty.on_level_complete(level_id)
	Analytics.level_complete(level_id, stars, coins, elapsed, AdaptiveDifficulty.get_current_attempt(level_id))
	if in_daily_challenge:
		_award_daily_challenge()
	if is_logged_in and SaveManager.get_setting("cloud_backup", true):
		SaveManager.sync_to_cloud()
	if should_show_login_prompt():
		EventBus.login_requested.emit()

func _award_daily_challenge() -> void:
	in_daily_challenge = false
	var target: String = str(daily_challenge_data.get("target", ""))
	var elapsed: float = Time.get_ticks_msec() / 1000.0 - _level_start_time
	var passed := false
	match target:
		"no_fail":
			passed = _challenge_fail_count == 0
		"speed_60":
			passed = elapsed <= 60.0
		"coins_10":
			passed = session_coins >= 10
		"stars_3":
			passed = _challenge_completion_stars >= 3
		"all_items":
			passed = _challenge_total_coins > 0 and session_coins >= _challenge_total_coins
		"one_shot":
			passed = not _challenge_retry_used
		_:
			passed = true
	_challenge_fail_count = 0
	_challenge_total_coins = 0
	_challenge_completion_stars = 0
	if not passed:
		daily_challenge_data = {}
		return

	var gems: int = int(daily_challenge_data.get("reward_gems", 3))
	SaveManager.add_gems(gems)
	var today := _date_key()
	# Streak logic
	var last: String = SaveManager.get_setting("daily_last_done", "")
	var streak: int  = int(SaveManager.get_setting("daily_streak", 0))
	if last == _yesterday_key():
		streak += 1
	else:
		streak = 1
	SaveManager.set_setting("daily_done_date", today)
	SaveManager.set_setting("daily_last_done", today)
	SaveManager.set_setting("daily_streak", streak)
	var best: int = int(SaveManager.get_setting("daily_best_streak", 0))
	if streak > best:
		SaveManager.set_setting("daily_best_streak", streak)
	daily_challenge_data = {}

func _date_key() -> String:
	var d := Time.get_date_dict_from_system()
	return "%d-%02d-%02d" % [int(d.get("year", 0)), int(d.get("month", 0)), int(d.get("day", 0))]

func _yesterday_key() -> String:
	var unix := Time.get_unix_time_from_system() - 86400
	var d    := Time.get_datetime_dict_from_unix_time(int(unix))
	return "%d-%02d-%02d" % [int(d.get("year", 0)), int(d.get("month", 0)), int(d.get("day", 0))]

func _on_level_failed(level_id: int, reason: String) -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _level_start_time
	AdaptiveDifficulty.on_level_fail(level_id)
	Analytics.level_fail(level_id, reason, last_fail_row, elapsed, AdaptiveDifficulty.get_current_attempt(level_id))

func _on_login_completed(success: bool) -> void:
	if success:
		is_guest = false
		is_logged_in = true
		if not player_name.is_empty() and player_name != "Explorer":
			pass  # already set by LoginPrompt before emitting the signal
