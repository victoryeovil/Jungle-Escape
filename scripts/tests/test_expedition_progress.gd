extends Node

# Run as a normal scene with autoloads, preferably using an isolated user-data
# directory. The test itself uses an in-memory SaveManager and never writes the
# player's wallet. Its JSON round trip exercises the real serialization types.
const ProgressScript = preload("res://scripts/autoload/ExpeditionProgress.gd")

class MemorySave:
	extends "res://scripts/autoload/SaveManager.gd"
	var writes := 0
	var disk: Dictionary = {}
	func save_game() -> void:
		writes += 1
		disk = JSON.parse_string(JSON.stringify(get_save_snapshot()))
	func sync_to_cloud() -> void:
		pass
	func reload_from_disk() -> void:
		_save_data = disk.duplicate(true)

var _failures := 0
var _checks := 0

func _ready() -> void:
	_test_persistence_and_revive()
	_test_overflow_and_endless()
	_test_cloud_merge()
	print("EXPEDITION TESTS: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)

func _test_persistence_and_revive() -> void:
	var store := MemorySave.new()
	store._save_data = {"coins": 7, "completed_levels": [1, 2], "current_level": 3}
	var journal := ProgressScript.new()
	journal._save_store = store
	_check(journal.get_missions().size() == 3, "old saves receive three active goals")
	_check(journal.get_rank_progress()["xp"] == 0 and store.get_coins() == 7, "migration preserves the old wallet without retroactive rewards")
	journal.begin_run()
	var summary: Dictionary = journal.record_run(19, 149, false, 1)
	_check(summary["reward_coins"] == 0, "just below both thresholds awards nothing")
	_check(summary["xp_earned"] == 48, "failed runs keep coin and distance XP")
	_check(journal.get_missions()[0]["progress"] == 19, "failed run progress persists")
	var writes_before := store.writes
	summary = journal.record_run(20, 150, true, 1, 3)
	_check(summary["reward_coins"] == 80 and store.get_coins() == 87, "exact thresholds pay all three mission rewards")
	_check(summary["completed_missions"].size() == 3, "summary lists each completed goal")
	_check(summary["xp_earned"] == 120 and summary["rank_up"], "completion XP promotes the explorer")
	_check(journal.get_rank_progress()["rank"] == 2 and journal.get_rank_progress()["current"] == 20, "rank threshold leaves correct XP toward the next rank")
	_check(store.writes == writes_before + 1, "all mission rewards and progress commit in one save")
	_check(int(store.disk["coins"]) == 87 and int(store.disk["expedition_progress"]["missions"]["coins"]["stage"]) == 1, "wallet and paid mission marker share the persisted snapshot")

	# Recreate the journal after JSON deserialization, like a process restart.
	journal.free()
	store.reload_from_disk()
	journal = ProgressScript.new()
	journal._save_store = store
	writes_before = store.writes
	summary = journal.record_run(20, 150, true, 1, 3)
	_check(store.writes == writes_before and store.get_coins() == 87, "duplicate report after reload cannot pay rewards twice")
	_check(summary["xp_earned"] == 120 and journal.get_rank_progress()["xp"] == 120, "duplicate completion cannot award completion XP twice")
	var detached := store.get_expedition_progress()
	detached["missions"]["coins"]["stage"] = 999
	_check(journal.get_missions()[0]["stage"] == 2, "callers cannot mutate the stored journal through getter aliases")

	journal.begin_run()
	_check(journal.get_last_run_summary()["xp_earned"] == 0, "fresh run clears its summary")
	summary = journal.record_run(5, 4, false, 2)
	_check(summary["xp_earned"] == 5, "distance XP waits for five cumulative metres")
	summary = journal.record_run(8, 5, false, 2)
	_check(summary["xp_earned"] == 9 and journal.get_missions()[0]["progress"] == 8, "revive contributes only new coins and preserves metre rounding")
	journal.record_run(-10, -10, false, 2)
	_check(journal.get_last_run_summary()["xp_earned"] == 9 and journal.get_missions()[1]["progress"] == 5, "negative or decreasing reports cannot erase progress")
	journal.begin_run()
	journal.record_run(0, 0, true, 2, 1)
	_check(journal.get_missions()[2]["progress"] == 1, "a new completed campaign run advances the replacement goal")
	journal.free()
	store.free()

func _test_overflow_and_endless() -> void:
	var store := MemorySave.new()
	var journal := ProgressScript.new()
	journal._save_store = store
	journal.begin_run()
	var summary: Dictionary = journal.record_run(200, 1450, true, 0, 3)
	var missions: Array[Dictionary] = journal.get_missions()
	_check(missions[0]["target"] == 100 and missions[0]["progress"] == 20, "large runs carry coin overflow through replacement goals")
	_check(missions[1]["target"] == 800 and missions[1]["progress"] == 500, "large runs carry distance overflow")
	_check(summary["completed_missions"].size() == 7 and summary["reward_coins"] == 230, "all crossed goals pay exactly their configured rewards")
	_check(missions[2]["progress"] == 0 and summary["xp_earned"] == 490, "endless stages do not count as campaign completions")
	_check(journal.get_rank_progress()["rank"] == 4 and journal.get_rank_progress()["current"] == 40, "one run may earn multiple explorer ranks")
	journal.free()
	store.free()

func _test_cloud_merge() -> void:
	var store := MemorySave.new()
	var journal := ProgressScript.new()
	journal._save_store = store
	journal.begin_run()
	journal.record_run(19, 0, false, 1)
	var stale_cloud := store.get_save_snapshot()
	journal.record_run(20, 0, false, 1)
	store.restore_from_cloud(stale_cloud)
	_check(journal.get_missions()[0]["stage"] == 2, "stale cloud saves cannot reopen paid mission stages")
	journal.record_run(20, 0, false, 1)
	_check(store.get_coins() == 20, "duplicate report remains safe after cloud merge")
	var newer_cloud := store.get_save_snapshot()
	newer_cloud["expedition_progress"]["missions"]["coins"] = {"stage": 3, "progress": 7}
	newer_cloud["expedition_progress"]["xp"] = 300
	newer_cloud["coins"] = 90
	store.restore_from_cloud(newer_cloud)
	_check(journal.get_missions()[0]["stage"] == 4 and journal.get_missions()[0]["progress"] == 7, "newer cloud missions bring their matching progress forward")
	_check(store.get_coins() == 90 and journal.get_rank_progress()["xp"] == 300, "cloud restores rewards and XP without paying cleared missions again")
	journal.free()
	store.free()

func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("EXPEDITION FAIL: " + description)
