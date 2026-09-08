extends Node

# Normal scene execution retains autoload resolution; the isolated profile
# prevents these deterministic generation checks from touching player saves.
const Generator = preload("res://scripts/gameplay/EndlessLevel.gd")
const ACTIONS := ["log", "branch", "floating_log"]
const STAGES := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 16, 25, 50, 100]
var _checks := 0
var _failures := 0
var _surfaces: Dictionary = {}
var _modes: Dictionary = {}
var _types: Dictionary = {}
var _gates := 0
var _water_jumps := 0
var _breathers := 0

func _ready() -> void:
	_run.call_deferred()

func _check(passed: bool, message: String) -> void:
	_checks += 1
	if not passed:
		_failures += 1
		if _failures <= 20:
			push_error("ENDLESS FAIRNESS: " + message)

func _run() -> void:
	if "--endless-test-isolated" not in OS.get_cmdline_user_args() or not OS.get_user_data_dir().contains("endless-test-profile"):
		push_error("Use APPDATA .godot/endless-test-profile and -- --endless-test-isolated.")
		get_tree().quit(2)
		return
	ProjectSettings.set_setting("jungle_escape/backend_url", "http://127.0.0.1:1")
	Analytics._queue.clear()
	Analytics.set_process(false)
	SaveManager._settings = {"cloud_backup": false}
	SupabaseClient._access_token = ""
	SupabaseClient._user_id = ""
	GameManager.is_logged_in = false
	var parsed_level := LevelManager3D.new()
	for stage in STAGES:
		for seed_index in range(50):
			var run_seed: int = seed_index * 104729 - 17071
			var data: Dictionary = Generator.generate(stage, run_seed)
			_check(data == Generator.generate(stage, run_seed), "same seed reproduces stage %d" % stage)
			_check(data != Generator.generate(stage, run_seed + 1), "different seed varies stage %d" % stage)
			_verify_layout(data, stage, parsed_level)
	parsed_level.free()
	for surface in ["dirt", "stone", "sand", "mud", "wood", "water_slide", "boat", "skating"]:
		_check(_surfaces.has(surface), "seed sweep includes " + surface)
	for mode in ["run", "water_slide", "boat", "skating", "chase", "escape"]:
		_check(_modes.has(mode), "seed sweep includes " + mode)
	for kind in ["log", "branch", "rock", "floating_log", "whirlpool", "crocodile_zone", "broken_plank", "crate"]:
		_check(_types.has(kind), "seed sweep includes " + kind)
	_check(_gates > 0, "later stages have deliberate gates with an open route")
	_check(_water_jumps > 0, "one-lane slides include achievable jump challenges")
	_check(_breathers > 100, "challenge sets include recovery stretches")
	# Regresion for the old high-stage two-row gap: even the fastest mode and
	# longest supported jump must finish before another compulsory action.
	var longest_airtime := 2.0 * 8.5 * 1.28 * 1.06 / 22.0
	_check(Generator.recovery_rows(100, true) * 3.0 / (10.4 * 1.24) > longest_airtime + 0.20, "high-stage spacing accommodates Monkey's stone jump")
	print("ENDLESS FAIRNESS: %d checks across %d seeded stages, %d failures; %d gates, %d water jumps, %d breathers" % [_checks, STAGES.size() * 50, _failures, _gates, _water_jumps, _breathers])
	get_tree().quit(0 if _failures == 0 else 1)

func _verify_layout(data: Dictionary, stage: int, parsed_level: LevelManager3D) -> void:
	parsed_level._setup_theme(int(data["id"]))
	parsed_level._parse_path_modules(data, data["path_modules"])
	var length := int(data["length"])
	var lanes: Array[int] = []
	var surfaces: Array[String] = []
	var modes: Array[String] = []
	for module: Dictionary in data["path_modules"]:
		for local_row in range(int(module["rows"])):
			lanes.append(int(module["lanes"]))
			surfaces.append(str(module["surface"]))
			modes.append(str(module["mode"]))
	_check(lanes.size() == length, "length matches module rows")
	var protected_rows: Dictionary = {}
	for row in range(length):
		_surfaces[surfaces[row]] = true
		_modes[modes[row]] = true
		_check(parsed_level._seg_lane_count[row] == lanes[row] and parsed_level._seg_surface[row] == surfaces[row] and parsed_level._seg_mode[row] == modes[row], "generator metadata matches LevelManager3D")
		if row > 0 and (lanes[row] != lanes[row - 1] or surfaces[row] != surfaces[row - 1] or modes[row] != modes[row - 1]):
			for near_row in range(maxi(0, row - 3), mini(length, row + 3)):
				protected_rows[near_row] = true
	var by_row: Dictionary = {}
	for obstacle: Dictionary in data["obstacles"]:
		var row := int(obstacle["row"])
		var lane := int(obstacle["lane"])
		var kind := str(obstacle["type"])
		_types[kind] = true
		_check(row >= 6 and row < length - 7, "start and finish are clear")
		_check(not protected_rows.has(row), "lane/mode/terrain transition has a clear approach and exit")
		_check(lane >= 0 and lane < lanes[row], "obstacle lane exists")
		if lanes[row] == 1:
			_check(kind in ACTIONS, "one-lane obstacles can be jumped or slid under")
			if surfaces[row] == "water_slide":
				_water_jumps += 1
				_check(kind == "floating_log", "one-lane water does not demand a dodge")
		if surfaces[row] in ["sand", "mud"]:
			_check(kind != "log" and kind != "floating_log", "sand/mud never requires a boosted or upgrade-only jump")
		if not by_row.has(row):
			by_row[row] = []
		by_row[row].append(obstacle)
	var last_row := -1
	var last_action := false
	for row: int in by_row:
		var obstacles: Array = by_row[row]
		var action: bool = str(obstacles[0]["type"]) in ACTIONS
		if action:
			_check(obstacles.size() == 1, "jump and slide rows never mix in lane blockers")
		else:
			_check(obstacles.size() < lanes[row], "every dodge gate leaves a safe lane")
			if obstacles.size() == 2:
				_gates += 1
		if last_row >= 0:
			var seconds: float = float(row - last_row) * 3.0 / (Generator.speed_for_stage(stage) * 1.24)
			_check(seconds >= (1.30 if action or last_action else 0.80), "obstacle spacing preserves physical recovery and reaction")
			if seconds >= 2.0:
				_breathers += 1
		last_row = row
		last_action = action
	var last_coin: Dictionary = {}
	for coin: Dictionary in data["coins"]:
		var row := int(coin["row"])
		var lane := int(coin["lane"])
		_check(lane >= 0 and lane < lanes[row], "coin lane exists")
		for obstacle: Dictionary in by_row.get(row, []):
			_check(str(obstacle["type"]) not in ACTIONS and int(obstacle["lane"]) != lane, "coin trail never overlaps a lethal obstacle")
		if not last_coin.is_empty():
			var previous_row := int(last_coin["row"])
			if row == previous_row + 1 and lanes[row] == lanes[previous_row]:
				_check(absi(lane - int(last_coin["lane"])) <= 1, "consecutive coins never demand a two-lane snap")
		last_coin = coin
