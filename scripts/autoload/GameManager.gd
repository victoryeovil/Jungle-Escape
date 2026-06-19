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

# Tracks how many levels played since last login prompt (to avoid spam)
var levels_since_login_prompt: int = 0

func _ready() -> void:
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)
	EventBus.login_completed.connect(_on_login_completed)

# ── Public API ─────────────────────────────────────────────────────────────────

func start_level(level_id: int) -> void:
	current_level_id = level_id
	session_coins = 0
	session_keys = 0
	moves_used = 0
	state = GameState.PLAYING

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
	start_level(level_id)
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/game3d/Game3D.tscn")
	print("[NAV][GameManager] go_to_gameplay_3d change_scene result=" + str(err))

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
	get_tree().paused = false
	go_to_gameplay_3d(current_level_id)

# ── Signal handlers ────────────────────────────────────────────────────────────

func _on_level_completed(_level_id: int, _stars: int, _coins: int, _moves: int) -> void:
	if should_show_login_prompt():
		EventBus.login_requested.emit()

func _on_level_failed(_level_id: int, _reason: String) -> void:
	pass

func _on_login_completed(success: bool) -> void:
	if success:
		is_guest = false
		is_logged_in = true
