extends Node

# Three permanent goals: no calendar, expiry, login requirement or streak reset.
# Call begin_run() only on a fresh start. record_run() accepts CUMULATIVE values
# for that run; a revive continues it. Repeated reports and reloads are safe.
const MISSION_KEYS := ["coins", "distance", "levels"]
const TARGETS := {
	"coins": [20, 35, 50, 75, 100],
	"distance": [150, 300, 500, 800, 1200],
	"levels": [1, 2, 3, 4, 5],
}
const REWARDS := {
	"coins": [20, 25, 35, 45, 60],
	"distance": [25, 35, 45, 60, 80],
	"levels": [35, 55, 75, 100, 125],
}
const RANK_TITLES := ["New Explorer", "Trail Scout", "Jungle Guide", "Pathfinder", "Expedition Expert", "Jungle Legend"]

# A store may be supplied by offline tools/tests; normal play uses SaveManager.
var _save_store: Node

func _store() -> Node:
	return _save_store if is_instance_valid(_save_store) else SaveManager

func begin_run() -> void:
	var data := _get_data()
	data["active_run"] = _new_run()
	_store().set_expedition_progress(data)

func record_run(coins: int, distance_m: int, completed: bool, level_id: int, stars: int = 0) -> Dictionary:
	var data := _get_data()
	var run: Dictionary = data["active_run"]
	var previous_coins := maxi(0, int(run.get("coins", 0)))
	var previous_distance := maxi(0, int(run.get("distance", 0)))
	var current_coins := maxi(previous_coins, coins)
	var current_distance := maxi(previous_distance, distance_m)
	var coin_delta := current_coins - previous_coins
	var distance_delta := current_distance - previous_distance
	var new_completion := completed and level_id > 0 and not bool(run.get("completed", false))
	var summary: Dictionary = run["summary"]
	if coin_delta == 0 and distance_delta == 0 and not new_completion:
		return summary.duplicate(true)

	var old_rank := _rank_for_xp(int(data["xp"]))
	# Quantize cumulative distance, so short revive segments never lose XP.
	var earned_xp := coin_delta + int(current_distance / 5.0) - int(previous_distance / 5.0)
	if new_completion:
		earned_xp += 40 + 10 * clampi(stars, 0, 3)
	data["xp"] = int(data["xp"]) + earned_xp
	data["total_coins"] = int(data["total_coins"]) + coin_delta
	data["total_distance"] = int(data["total_distance"]) + distance_delta
	data["completed_runs"] = int(data["completed_runs"]) + int(new_completion)

	var rewards := 0
	var finished: Array = summary.get("completed_missions", []).duplicate()
	var increments := {"coins": coin_delta, "distance": distance_delta, "levels": int(new_completion)}
	var missions: Dictionary = data["missions"]
	for key: String in MISSION_KEYS:
		var mission: Dictionary = missions[key]
		var stage := int(mission["stage"])
		var progress := int(mission["progress"]) + int(increments[key])
		# Carry overflow into the replacement mission, including long endless
		# runs that finish several goals. Each paid stage is persisted below.
		while progress >= _target(key, stage):
			finished.append(_mission_title(key, _target(key, stage)))
			rewards += _reward(key, stage)
			progress -= _target(key, stage)
			stage += 1
		missions[key] = {"stage": stage, "progress": progress}
	data["missions"] = missions

	run["coins"] = current_coins
	run["distance"] = current_distance
	run["completed"] = bool(run.get("completed", false)) or new_completion
	run["level_id"] = level_id
	summary["xp_earned"] = int(summary.get("xp_earned", 0)) + earned_xp
	summary["reward_coins"] = int(summary.get("reward_coins", 0)) + rewards
	summary["completed_missions"] = finished
	summary["rank_up"] = bool(summary.get("rank_up", false)) or int(_rank_for_xp(int(data["xp"]))["rank"]) > int(old_rank["rank"])
	summary["coins_collected"] = current_coins
	summary["distance_m"] = current_distance
	summary["completed"] = run["completed"]
	summary["level_id"] = level_id
	run["summary"] = summary
	data["active_run"] = run
	# One transaction writes paid mission stages, the run watermark, XP and
	# the wallet. Never award coins in a separate call before saving progress.
	_store().set_expedition_progress(data, rewards)
	return summary.duplicate(true)

func get_missions() -> Array[Dictionary]:
	var data := _get_data()
	var result: Array[Dictionary] = []
	for key: String in MISSION_KEYS:
		var mission: Dictionary = data["missions"][key]
		var stage := int(mission["stage"])
		var target := _target(key, stage)
		result.append({
			"id": key,
			"title": _mission_title(key, target),
			"description": "Campaign replays count." if key == "levels" else "Across any number of runs.",
			"progress": int(mission["progress"]),
			"target": target,
			"reward_coins": _reward(key, stage),
			"unit": "m" if key == "distance" else key,
			"stage": stage + 1,
		})
	return result

func get_rank_progress() -> Dictionary:
	return _rank_for_xp(int(_get_data()["xp"]))

func get_last_run_summary() -> Dictionary:
	return (_get_data()["active_run"]["summary"] as Dictionary).duplicate(true)

func _rank_for_xp(xp: int) -> Dictionary:
	var rank := 1
	var remaining := maxi(0, xp)
	var needed := 100
	while remaining >= needed:
		remaining -= needed
		rank += 1
		needed = 100 + (rank - 1) * 50
	return {"rank": rank, "title": RANK_TITLES[mini(rank - 1, RANK_TITLES.size() - 1)], "xp": maxi(0, xp), "current": remaining, "needed": needed}

func _target(key: String, stage: int) -> int:
	var values: Array = TARGETS[key]
	return int(values[clampi(stage, 0, values.size() - 1)])

func _reward(key: String, stage: int) -> int:
	var values: Array = REWARDS[key]
	return int(values[clampi(stage, 0, values.size() - 1)])

func _mission_title(key: String, target: int) -> String:
	match key:
		"coins": return "Collect %d coins" % target
		"distance": return "Travel %s m" % ("1,200" if target == 1200 else str(target))
		_: return "Finish %d campaign %s" % [target, "level" if target == 1 else "levels"]

func _new_run() -> Dictionary:
	return {
		"coins": 0, "distance": 0, "completed": false, "level_id": -1,
		"summary": {
			"xp_earned": 0, "reward_coins": 0, "completed_missions": [],
			"rank_up": false, "coins_collected": 0, "distance_m": 0,
			"completed": false, "level_id": -1,
		},
	}

func _get_data() -> Dictionary:
	var data: Dictionary = _store().get_expedition_progress()
	data["version"] = 1
	for key in ["xp", "total_coins", "total_distance", "completed_runs"]:
		data[key] = maxi(0, int(data.get(key, 0)))
	var raw_missions: Variant = data.get("missions", {})
	var missions: Dictionary = raw_missions if raw_missions is Dictionary else {}
	for key: String in MISSION_KEYS:
		var raw_mission: Variant = missions.get(key, {})
		var mission: Dictionary = raw_mission if raw_mission is Dictionary else {}
		mission["stage"] = maxi(0, int(mission.get("stage", 0)))
		mission["progress"] = maxi(0, int(mission.get("progress", 0)))
		missions[key] = mission
	data["missions"] = missions
	var raw_run: Variant = data.get("active_run", {})
	var run: Dictionary = raw_run if raw_run is Dictionary else {}
	var defaults := _new_run()
	for key: String in defaults:
		if not run.has(key):
			run[key] = defaults[key]
	if not (run.get("summary") is Dictionary):
		run["summary"] = defaults["summary"]
	data["active_run"] = run
	return data
