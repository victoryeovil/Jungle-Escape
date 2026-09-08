extends Node

var _checks := 0
var _failures := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()

func _check(ok: bool, message: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error("SKILL CHECK: " + message)

func _run() -> void:
	if not OS.get_user_data_dir().contains("skill-test-profile") or "--skill-test-isolated" not in OS.get_cmdline_user_args():
		push_error("Use APPDATA .godot/skill-test-profile and -- --skill-test-isolated.")
		get_tree().quit(2)
		return
	ProjectSettings.set_setting("jungle_escape/backend_url", "http://127.0.0.1:1")
	Analytics._queue.clear()
	Analytics.set_process(false)
	SaveManager._save_data = {"coins": 0, "gems": 5, "completed_levels": []}
	SaveManager._settings = {"cloud_backup": false}
	SupabaseClient._access_token = ""
	SupabaseClient._user_id = ""
	GameManager.is_logged_in = false
	GameManager.endless_mode = false
	GameManager.clear_daily_challenge()
	GameManager.start_level(1)
	var game: Node = load("res://scenes/game3d/Game3D.tscn").instantiate()
	add_child(game)
	game.player.set_physics_process(false)
	await get_tree().process_frame
	await get_tree().process_frame
	var coins: Array[Node3D] = []
	for node: Node3D in game.level_mgr._coin_nodes:
		if not bool(node.get_meta("is_gem", false)):
			coins.append(node)
	_check(game.level_mgr.get_star_coin_target() == 14, "Level 1 star target permits choosing one lane at split coin rows")
	for i in 5:
		game.level_mgr._collect_coin_node(coins[i])
	_check(GameManager.session_coins == 7, "five real pickups earn exactly two chain bonus coins")
	_check(GameManager._challenge_collected_coins == 5, "bonus coins cannot satisfy trail-coin daily goals")
	_check(game.level_mgr.get_collected_coins() == 5, "physical pickup count excludes bonus currency")
	game.level_mgr._collect_coin_node(coins[4])
	_check(GameManager.session_coins == 7 and game._chain_count == 5, "duplicate pickup does not extend or reward chain")
	var remaining: float = game._chain_remaining
	GameManager.pause_game()
	await get_tree().create_timer(0.12, true).timeout
	_check(game._chain_remaining == remaining, "pausing preserves chain time")
	GameManager.resume_game()
	game._tick_coin_chain(3.01)
	_check(game._chain_count == 0 and GameManager.session_coins == 7, "expired chain resets without removing earned bonus")
	for i in range(5, 10):
		game.level_mgr._collect_coin_node(coins[i])
	_check(GameManager.session_coins == 14 and game._chain_bonus_coins == 4, "a new five-coin chain earns its own bonus once")
	_check(game._calc_stars(game.level_mgr.get_collected_coins(), game.level_mgr.get_star_coin_target()) == 2, "bonus currency does not inflate star rating")
	await _capture("coin-chain")
	game._on_finish_reached()
	_check(SaveManager.get_stars(1) == 2, "actual completion uses physical coins for stars")
	_check(SaveManager.get_coins() == 49, "finish banks fourteen run coins including bonuses, plus 35 goal reward")
	await get_tree().create_timer(1.2).timeout
	await _capture("chain-result")
	get_tree().paused = false
	remove_child(game)
	game.free()
	print("SKILL GAMEPLAY CHECKS: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures else 0)

func _capture(capture_name: String) -> void:
	if "--capture-visuals" not in OS.get_cmdline_user_args():
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/gameplay-captures")
	get_viewport().get_texture().get_image().save_png("res://.godot/gameplay-captures/%s.png" % capture_name)
