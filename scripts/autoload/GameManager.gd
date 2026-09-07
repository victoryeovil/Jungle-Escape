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
var last_daily_result: Dictionary = {}

# Endless Run mode — no lives cost, score-chasing loop
var endless_mode: bool = false
var endless_run_seed: int = 0

# Failure/retry history belongs to a challenge, not to each retry.
var _challenge_fail_count: int = 0
var _challenge_retry_used: bool = false
var _challenge_total_coins: int = 0    # set by Game3D before level_completed fires
var _challenge_completion_stars: int = 0  # set by Game3D before level_completed fires
var _challenge_collected_coins: int = 0 # excludes skin and land bonus coins
var _challenge_award_evaluated: bool = false
var _level_elapsed_seconds: float = 0.0
var _last_elapsed_tick: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_last_elapsed_tick = Time.get_ticks_msec()
	is_logged_in = SupabaseClient.is_authenticated()
	is_guest = not is_logged_in
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)
	EventBus.login_completed.connect(_on_login_completed)
	_apply_graphics_quality()

func _process(_delta: float) -> void:
	# Real time, unaffected by hit slow-motion, with menus and pauses excluded.
	var now := Time.get_ticks_msec()
	if state == GameState.PLAYING and not get_tree().paused:
		_level_elapsed_seconds += maxf(0.0, float(now - _last_elapsed_tick) / 1000.0)
	_last_elapsed_tick = now

func get_level_elapsed_seconds() -> float:
	return _level_elapsed_seconds

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
	_level_elapsed_seconds = 0.0
	_last_elapsed_tick = Time.get_ticks_msec()
	last_daily_result = {}
	_challenge_total_coins = 0
	_challenge_completion_stars = 0
	_challenge_collected_coins = 0
	_challenge_award_evaluated = false
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
	_challenge_collected_coins += 1
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
	clear_daily_challenge()
	print("[NAV][GameManager] go_to_menu called")
	state = GameState.MENU
	endless_mode = false
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
	print("[NAV][GameManager] go_to_menu change_scene result=" + str(err))

func go_to_level_map() -> void:
	clear_daily_challenge()
	endless_mode = false
	get_tree().paused = false
	print("[NAV][GameManager] go_to_level_map called")
	state = GameState.MENU
	var err := get_tree().change_scene_to_file("res://scenes/level_map/LevelMap.tscn")
	print("[NAV][GameManager] go_to_level_map change_scene result=" + str(err))

func go_to_level_select() -> void:
	clear_daily_challenge()
	endless_mode = false
	print("[NAV][GameManager] go_to_level_select called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/LevelSelect.tscn")
	print("[NAV][GameManager] go_to_level_select change_scene result=" + str(err))

func go_to_gameplay(level_id: int) -> void:
	clear_daily_challenge()
	endless_mode = false
	print("[NAV][GameManager] go_to_gameplay called; level_id=" + str(level_id))
	start_level(level_id)
	var err := get_tree().change_scene_to_file("res://scenes/gameplay/GameplayScreen.tscn")
	print("[NAV][GameManager] go_to_gameplay change_scene result=" + str(err))

func go_to_endless() -> void:
	clear_daily_challenge()
	print("[NAV][GameManager] go_to_endless called")
	endless_mode = true
	endless_run_seed = randi()
	current_level_id = 0
	session_coins = 0
	session_keys = 0
	last_fail_row = 0
	_level_start_time = Time.get_ticks_msec() / 1000.0
	_level_elapsed_seconds = 0.0
	_last_elapsed_tick = Time.get_ticks_msec()
	state = GameState.PLAYING
	Analytics.level_start(0, SaveManager.get_selected_skin(), 1)
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/game3d/Game3D.tscn")
	print("[NAV][GameManager] go_to_endless change_scene result=" + str(err))

func go_to_gameplay_3d(level_id: int, preserve_daily_challenge: bool = false) -> void:
	if not preserve_daily_challenge:
		clear_daily_challenge()
	print("[NAV][GameManager] go_to_gameplay_3d called; level_id=" + str(level_id))
	endless_mode = false
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
	clear_daily_challenge()
	login_required = required
	pending_level_after_login = pending_level
	state = GameState.MENU
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")

func collect_resource(resource_id: String, amount: int) -> void:
	SaveManager.add_resource(resource_id, amount)
	EventBus.resource_collected.emit(resource_id, amount)

func go_to_upgrade_shop() -> void:
	clear_daily_challenge()
	print("[NAV][GameManager] go_to_upgrade_shop called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/UpgradeShop.tscn")
	print("[NAV][GameManager] go_to_upgrade_shop change_scene result=" + str(err))

func go_to_home_building() -> void:
	clear_daily_challenge()
	print("[NAV][GameManager] go_to_home_building called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/HomeBuilding.tscn")
	print("[NAV][GameManager] go_to_home_building change_scene result=" + str(err))

func go_to_wildlands_unlock() -> void:
	clear_daily_challenge()
	print("[NAV][GameManager] go_to_wildlands_unlock called")
	state = GameState.MENU
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/menus/WildlandsUnlock.tscn")
	print("[NAV][GameManager] go_to_wildlands_unlock change_scene result=" + str(err))

func get_daily_date_key() -> String:
	return Time.get_date_string_from_system(false)

func get_previous_daily_date_key(date_key: String = "") -> String:
	# Calendar arithmetic on a local date avoids mixing local days with UTC.
	var local_date := get_daily_date_key() if date_key.is_empty() else date_key
	var calendar_seconds := Time.get_unix_time_from_datetime_string(local_date + "T12:00:00")
	return Time.get_date_string_from_unix_time(calendar_seconds - 86400)

func is_daily_level_accessible(level_id: int) -> bool:
	if level_id < 1 or level_id > 6 or not SaveManager.is_level_unlocked(level_id):
		return false
	if level_id > 3 and not SupabaseClient.has_registration_key():
		return false
	if level_id == 6 and not SaveManager.has_upgrade("sand_shoes"):
		return false
	return true

func get_daily_challenge_start_error(challenge: Dictionary) -> String:
	var today := get_daily_date_key()
	if str(challenge.get("date_key", "")) != today:
		return "A new daily expedition is ready. Reopen today's challenge."
	if str(SaveManager.get_setting("daily_done_date", "")) == today:
		return "Today's reward is already collected. Come back tomorrow."
	var level_id := int(challenge.get("level_id", 0))
	if not is_daily_level_accessible(level_id):
		return "This trail is not available yet. Reopen today's challenge."
	if not SaveManager.can_start_level(level_id):
		return "No Expedition Lives left. Recover lives at camp, or play Endless Run."
	if str(challenge.get("target", "")) not in ["coins_10", "no_fail", "speed_60", "stars_2", "coins_half", "one_shot"]:
		return "This challenge is unavailable. Reopen today's challenge."
	return ""

func start_daily_challenge(challenge: Dictionary) -> bool:
	if not get_daily_challenge_start_error(challenge).is_empty():
		return false
	clear_daily_challenge()
	in_daily_challenge = true
	daily_challenge_data = challenge.duplicate(true)
	go_to_gameplay_3d(int(challenge["level_id"]), true)
	return true

func clear_daily_challenge(clear_result: bool = true) -> void:
	in_daily_challenge = false
	daily_challenge_data = {}
	_challenge_fail_count = 0
	_challenge_retry_used = false
	_challenge_total_coins = 0
	_challenge_completion_stars = 0
	_challenge_collected_coins = 0
	_challenge_award_evaluated = false
	if clear_result:
		last_daily_result = {}

func restart_level() -> void:
	if endless_mode:
		get_tree().paused = false
		go_to_endless()
		return
	if in_daily_challenge:
		_challenge_retry_used = true
	get_tree().paused = false
	go_to_gameplay_3d(current_level_id, in_daily_challenge)

# ── Signal handlers ────────────────────────────────────────────────────────────

func _on_level_completed(level_id: int, stars: int, coins: int, _moves: int) -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _level_start_time
	AdaptiveDifficulty.on_level_complete(level_id)
	Analytics.level_complete(level_id, stars, coins, elapsed, AdaptiveDifficulty.get_current_attempt(level_id))
	if in_daily_challenge and level_id == int(daily_challenge_data.get("level_id", 0)):
		_challenge_completion_stars = stars
		_award_daily_challenge()
	if is_logged_in and SaveManager.get_setting("cloud_backup", true):
		SaveManager.sync_to_cloud()
	if should_show_login_prompt():
		EventBus.login_requested.emit()

func _award_daily_challenge() -> void:
	if not in_daily_challenge or _challenge_award_evaluated:
		return
	_challenge_award_evaluated = true
	last_daily_result = {"attempted": true, "passed": false, "reward_gems": 0, "message": ""}
	var today := get_daily_date_key()
	if str(daily_challenge_data.get("date_key", "")) != today:
		last_daily_result["message"] = "A new day has begun. Today's challenge is ready at camp."
		clear_daily_challenge(false)
		return
	if str(SaveManager.get_setting("daily_done_date", "")) == today:
		last_daily_result["message"] = "Today's reward has already been collected."
		clear_daily_challenge(false)
		return
	if current_level_id != int(daily_challenge_data.get("level_id", 0)):
		last_daily_result["message"] = "This run was outside today's challenge trail."
		clear_daily_challenge(false)
		return

	var target := str(daily_challenge_data.get("target", ""))
	var passed := false
	var message := "Challenge not completed. Start a fresh challenge at camp."
	match target:
		"no_fail":
			passed = _challenge_fail_count == 0
			message = "A stumble was recorded. Start a fresh challenge from camp."
		"speed_60":
			passed = get_level_elapsed_seconds() < 60.0
			message = "Finished in %.1fs. Replay and aim for under 60s; pauses don't count." % get_level_elapsed_seconds()
		"coins_10":
			passed = _challenge_collected_coins >= 10
			message = "Collected %d/10 trail coins. Replay to reach the target." % _challenge_collected_coins
		"stars_2":
			passed = _challenge_completion_stars >= 2
			message = "Earned %d/2 stars. Replay and collect more trail coins." % _challenge_completion_stars
		"coins_half":
			var required := maxi(1, ceili(float(_challenge_total_coins) * 0.5))
			passed = _challenge_total_coins > 0 and _challenge_collected_coins >= required
			message = "Collected %d/%d required trail coins. Replay to reach half." % [_challenge_collected_coins, required]
		"one_shot":
			passed = not _challenge_retry_used and _challenge_fail_count == 0
			message = "A retry or revive was used. Start a fresh challenge from camp."
	last_daily_result["message"] = message
	if not passed:
		# The replay button can preserve this challenge's failure/retry history.
		return

	var gems := maxi(0, int(daily_challenge_data.get("reward_gems", 3)))
	if str(SaveManager.get_setting("home_plot", "")) == "savanna":
		gems += 1
	var last := str(SaveManager.get_setting("daily_last_done", ""))
	var streak := int(SaveManager.get_setting("daily_streak", 0))
	streak = streak + 1 if last == get_previous_daily_date_key(today) else 1
	# Record the claim before issuing currency; repeated completion signals are safe.
	SaveManager.set_setting("daily_done_date", today)
	SaveManager.set_setting("daily_last_done", today)
	SaveManager.set_setting("daily_streak", streak)
	var best := int(SaveManager.get_setting("daily_best_streak", 0))
	if streak > best:
		SaveManager.set_setting("daily_best_streak", streak)
	SaveManager.add_gems(gems)
	last_daily_result = {
		"attempted": true, "passed": true, "reward_gems": gems,
		"message": "Daily expedition complete! +%d gems. %d-day streak." % [gems, streak],
	}
	clear_daily_challenge(false)

func _on_level_failed(level_id: int, reason: String) -> void:
	if in_daily_challenge and level_id == int(daily_challenge_data.get("level_id", 0)):
		_challenge_fail_count += 1
	var elapsed := Time.get_ticks_msec() / 1000.0 - _level_start_time
	AdaptiveDifficulty.on_level_fail(level_id)
	Analytics.level_fail(level_id, reason, last_fail_row, elapsed, AdaptiveDifficulty.get_current_attempt(level_id))

func _on_login_completed(success: bool) -> void:
	if success:
		is_guest = false
		is_logged_in = true
		if not player_name.is_empty() and player_name != "Explorer":
			pass  # already set by LoginPrompt before emitting the signal
