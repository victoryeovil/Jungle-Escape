extends Node

# Run this scene with APPDATA redirected to .godot/pickup-test-profile and
# -- --pickup-test-isolated. Rewards exercise real autoloads in that profile.
class TestRunner:
	extends Player3D
	var collect_animations := 0
	func _ready() -> void:
		add_to_group("player3d")
	func _physics_process(_delta: float) -> void:
		pass
	func play_collect() -> void:
		collect_animations += 1

class TestLevel:
	extends LevelManager3D
	var pickup_effects := 0
	func spawn_vfx(_kind: String, _world_pos: Vector3) -> void:
		pickup_effects += 1
	func _place_glb(_parent: Node3D, _path: String, _offset: Vector3, _scale: Vector3) -> Node3D:
		return null

var _checks := 0
var _failures := 0

func _enter_tree() -> void:
	ProjectSettings.set_setting("jungle_escape/backend_url", "http://127.0.0.1:1")

func _ready() -> void:
	var profile := OS.get_environment("APPDATA").replace("\\", "/")
	if not OS.get_cmdline_user_args().has("--pickup-test-isolated") or not profile.ends_with("/.godot/pickup-test-profile"):
		push_error("Pickup tests require a dedicated .godot/pickup-test-profile APPDATA and --pickup-test-isolated flag.")
		get_tree().quit(2)
		return
	GameManager.state = GameManager.GameState.PLAYING
	GameManager.session_coins = 0
	SaveManager.set_selected_skin("explorer")
	_test_single_awards_and_dead_runner()
	_test_attainable_star_targets()
	print("PICKUP FAIRNESS TESTS: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)

func _test_single_awards_and_dead_runner() -> void:
	var manager := TestLevel.new()
	add_child(manager)
	var runner := TestRunner.new()
	add_child(runner)
	var collected_totals: Array[int] = []
	manager.coin_collected.connect(func(total: int): collected_totals.append(total))
	manager._spawn_coin(1, 2, false)
	var coin: Node3D = manager._coin_nodes.back()
	manager.coin_collected.connect(func(_total: int): manager._collect_coin_node(coin), CONNECT_ONE_SHOT)
	manager._on_coin_body_entered(runner, coin)
	manager._on_coin_body_entered(runner, coin)
	manager._collect_coin_node(coin)
	_check(GameManager.session_coins == 1 and manager.get_collected_coins() == 1, "contact, magnet and reward re-entry award one normal coin")
	_check(collected_totals == [1], "normal pickup emits one progress event")
	_check(runner.collect_animations == 1 and manager.pickup_effects == 1, "repeated contact cannot repeat feedback")
	_check(coin.is_queued_for_deletion() and not coin.visible, "claimed pickup disappears immediately")

	var gems_before := SaveManager.get_gems()
	manager._spawn_coin(1, 4, true)
	var gem: Node3D = manager._coin_nodes.back()
	manager.attract_coins(gem.global_position, 0.5)
	manager._on_coin_body_entered(runner, gem)
	_check(SaveManager.get_gems() == gems_before + 1, "magnet preserves gem currency and contact cannot pay twice")
	_check(GameManager.session_coins == 1 and manager.get_collected_coins() == 1 and collected_totals == [1], "gem pickup does not inflate normal coin progress")
	_check(manager.pickup_effects == 2, "magnet pickup has the same visual feedback")

	manager._spawn_coin(1, 6, true)
	gem = manager._coin_nodes.back()
	manager._on_coin_body_entered(runner, gem)
	manager._collect_coin_node(gem)
	_check(SaveManager.get_gems() == gems_before + 2, "direct gem contact keeps its type and ignores a later magnet call")

	manager._spawn_single_collectable("wood", 1, 8)
	var resource: Node3D = manager._collectable_nodes.back()
	var wood_before := SaveManager.get_resource("wood")
	manager._on_collectable_body_entered(runner, resource, "wood")
	manager._on_collectable_body_entered(runner, resource, "wood")
	_check(SaveManager.get_resource("wood") == wood_before + 1, "resource contact awards only once")

	manager._spawn_coin(1, 10, false)
	coin = manager._coin_nodes.back()
	manager._spawn_coin(1, 10, true)
	gem = manager._coin_nodes.back()
	manager._spawn_single_collectable("wood", 1, 10)
	resource = manager._collectable_nodes.back()
	runner._is_dead = true
	manager._on_coin_body_entered(runner, coin)
	manager._on_coin_body_entered(runner, gem)
	manager._on_collectable_body_entered(runner, resource, "wood")
	manager.attract_coins(coin.global_position, 3.0)
	_check(GameManager.session_coins == 1 and SaveManager.get_gems() == gems_before + 2, "death animation rejects direct and magnet currency pickups")
	_check(SaveManager.get_resource("wood") == wood_before + 1 and not resource.is_queued_for_deletion(), "dead runner leaves resources available for revival")
	_check(not coin.is_queued_for_deletion() and not gem.is_queued_for_deletion(), "dead runner leaves currency available for revival")
	runner._is_dead = false
	GameManager.state = GameManager.GameState.LEVEL_COMPLETE
	manager.attract_coins(coin.global_position, 3.0)
	manager._on_coin_body_entered(runner, coin)
	manager._on_collectable_body_entered(runner, resource, "wood")
	_check(not coin.is_queued_for_deletion() and not resource.is_queued_for_deletion(), "finished run rejects late overlap events")
	GameManager.state = GameManager.GameState.PLAYING
	manager.attract_coins(coin.global_position, 3.0)
	manager._on_collectable_body_entered(runner, resource, "wood")
	_check(GameManager.session_coins == 2 and SaveManager.get_gems() == gems_before + 3 and SaveManager.get_resource("wood") == wood_before + 2, "revived runner can collect untouched pickups normally")
	_check(collected_totals == [1, 2] and manager.get_collected_coins() == 2, "only actual normal coins advance the chain")
	manager.free()
	runner.free()

func _test_attainable_star_targets() -> void:
	for level_id in range(1, 21):
		var file := FileAccess.open("res://data/levels3d/level3d_%03d.json" % level_id, FileAccess.READ)
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		var manager := TestLevel.new()
		add_child(manager)
		manager.level_data = data
		manager._parse_turns(data)
		manager._spawn_coins(data)
		manager._count_total_coins(data)
		_check(manager.get_star_coin_target() > 0 and manager.get_star_coin_target() <= manager.get_total_coins(), "level %d has a bounded normal-coin star target" % level_id)
		if level_id == 1:
			_check(manager.get_total_coins() == 16 and manager.get_star_coin_target() == 14, "level 1 does not require all three simultaneous lanes at row 18")
		manager.free()

	var manager := TestLevel.new()
	add_child(manager)
	manager.level_data = {"length": 20}
	manager._spawn_coin(0, 4, false)
	manager._spawn_coin(1, 4, false)
	manager._spawn_coin(2, 4, false)
	manager._spawn_coin(1, 4, true)
	_check(manager.get_star_coin_target() == 1, "different lanes on one row and gems do not inflate the target")
	manager._spawn_coin(1, 4, false)
	_check(manager.get_star_coin_target() == 2, "overlapping rewards in the chosen physical lane both count")
	manager._seg_lane_count[5] = 1
	manager._spawn_coin(0, 5, false)
	manager._spawn_coin(2, 5, false)
	_check(manager.get_star_coin_target() == 4, "authored lanes that collapse to a single lane remain fully collectible")
	manager._spawn_coin(1, 20, false)
	_check(manager.get_star_coin_target() == 4, "unreachable coins beyond the finish gate are excluded")
	manager._junction_defs["test_route"] = {"row": 8}
	manager.apply_junction_choice("test_route", "left", {"reward": "coins"})
	_check(manager.get_star_coin_target() == 9 and manager.get_total_coins() == 5, "chosen-route coins join the star budget while the raw total still tracks their full count")
	manager.build({"id": 1, "length": 4, "coins": [{"lane": 1, "row": 2}]})
	_check(manager.get_star_coin_target() == 1 and manager.get_total_coins() == 1 and manager.get_collected_coins() == 0, "a new build resets collected count and its row budget")
	manager.free()

func _check(passed: bool, message: String) -> void:
	_checks += 1
	if not passed:
		_failures += 1
		push_error("PICKUP FAIL: " + message)
