extends Node

# Requires an isolated APPDATA .godot/retention-test-profile and
# -- --retention-test-isolated. Add --capture-visuals with a real renderer
# to save the actual menus/results under .godot/retention-captures/.
var _checks := 0
var _failures := 0
var _capture := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()

func _check(passed: bool, message: String) -> void:
	_checks += 1
	if not passed:
		_failures += 1
		push_error("RETENTION CHECK: " + message)

func _run() -> void:
	if "--retention-test-isolated" not in OS.get_cmdline_user_args() or not OS.get_user_data_dir().contains("retention-test-profile"):
		push_error("Use APPDATA .godot/retention-test-profile and -- --retention-test-isolated.")
		get_tree().quit(2)
		return
	_capture = "--capture-visuals" in OS.get_cmdline_user_args()
	ProjectSettings.set_setting("jungle_escape/backend_url", "http://127.0.0.1:1")
	Analytics._queue.clear()
	Analytics.set_process(false)
	SaveManager._settings = {"cloud_backup": false}
	SaveManager._save_data = {"coins": 0, "gems": 5, "completed_levels": []}
	SupabaseClient._access_token = ""
	SupabaseClient._user_id = ""
	GameManager.is_logged_in = false
	GameManager.clear_daily_challenge()
	await _menu("res://scenes/main_menu/MainMenu.tscn", "home-new")
	await _menu("res://scenes/menus/ExpeditionJournal.tscn", "journal-new")
	await _menu("res://scenes/menus/DailyChallenge.tscn", "daily")

	var game := _game(false)
	await _settle()
	for i in 12:
		GameManager.collect_coin()
	game._run_distance_m = 30
	game._last_row = 10
	await game._on_player_died()
	_check(SaveManager.get_coins() == 12, "failed run banks its twelve coins")
	_check(int(ExpeditionProgress.get_last_run_summary().get("coins_collected", 0)) == 12, "failed run advances missions")
	await _settle()
	_check_layout(game.game_over.get_node("Panel/VBox"))
	await _snapshot("run-failed")
	game._on_revive_requested()
	_check(SaveManager.get_gems() == 0 and not game._dead, "revive consumes five gems and resumes")
	for i in 3:
		GameManager.collect_coin()
	game._on_finish_reached()
	_check(SaveManager.get_coins() == 50, "revived completion adds only three new coins plus 35 mission reward")
	_check(int(ExpeditionProgress.get_last_run_summary().get("coins_collected", 0)) == 15, "revive continues original cumulative run")
	_check(int(ExpeditionProgress.get_last_run_summary().get("distance_m", 0)) == 78, "completion records whole trail distance")
	_check(SaveManager.is_level_completed(1), "completion still unlocks campaign progress")
	game._on_finish_reached()
	_check(SaveManager.get_coins() == 50, "duplicate finish doesn't pay twice")
	await get_tree().create_timer(1.3).timeout
	_check_layout(game.level_complete.get_node("Panel/VBox"))
	await _snapshot("run-complete")
	_dispose(game)

	game = _game(false)
	await _settle()
	for i in 2:
		GameManager.collect_coin()
	game._run_distance_m = 12
	# Navigation resets session counters before removing the previous scene.
	GameManager.session_coins = 0
	_dispose(game)
	_check(SaveManager.get_coins() == 52, "leaving mid-run banks cached coins despite next-run counter reset")
	_check(int(ExpeditionProgress.get_last_run_summary().get("distance_m", 0)) == 12, "leaving mid-run keeps distance progress")

	game = _game(true)
	await _settle()
	for i in 3:
		GameManager.collect_coin()
	game._run_distance_m = 60
	game._endless_distance_m = 60
	await game._on_player_died()
	_check(SaveManager.get_coins() == 100, "endless coins plus coin/distance mission rewards are banked")
	_check(ExpeditionProgress.get_missions()[2].progress == 0, "endless does not complete campaign mission")
	await _settle()
	_check_layout(game.game_over.get_node("Panel/VBox"))
	await _snapshot("endless-result")
	_dispose(game)
	await _menu("res://scenes/main_menu/MainMenu.tscn", "home-returning")
	await _menu("res://scenes/menus/ExpeditionJournal.tscn", "journal-returning")
	print("RETENTION CHECKS: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures else 0)

func _game(endless: bool) -> Node:
	get_tree().paused = false
	GameManager.endless_mode = endless
	GameManager.endless_run_seed = 12345
	GameManager.start_level(0 if endless else 1)
	var game: Node = load("res://scenes/game3d/Game3D.tscn").instantiate()
	add_child(game)
	game.set_process(false)
	game.player.set_physics_process(false)
	return game

func _dispose(node: Node) -> void:
	get_tree().paused = false
	remove_child(node)
	node.free()

func _menu(path: String, capture_name: String) -> void:
	if not ResourceLoader.exists(path):
		_check(false, "missing screen " + path)
		return
	var menu: Node = load(path).instantiate()
	add_child(menu)
	await _settle()
	_check_layout(menu)
	await _snapshot(capture_name)
	_dispose(menu)

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

func _check_layout(node: Node) -> void:
	for child in node.get_children():
		if child is Control and child.is_visible_in_tree():
			var rect: Rect2 = child.get_global_rect()
			if child is Button:
				_check(rect.position.x >= -1 and rect.position.y >= -1 and rect.end.x <= 481 and rect.end.y <= 855, "button stays inside viewport: " + str(child.get_path()))
			if child is Container and child.get_parent() is Panel:
				var panel_rect: Rect2 = child.get_parent().get_global_rect()
				_check(panel_rect.grow(1).encloses(rect), "result contents stay inside panel")
		_check_layout(child)

func _snapshot(capture_name: String) -> void:
	if not _capture:
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/retention-captures")
	get_viewport().get_texture().get_image().save_png("res://.godot/retention-captures/%s.png" % capture_name)
