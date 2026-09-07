extends Node

# Run this scene with an isolated APPDATA directory and -- --daily-test-isolated.
class NavigationStub extends "res://scripts/autoload/GameManager.gd":
	var launches: int = 0

	func _ready() -> void:
		set_process(false)

	func go_to_gameplay_3d(level_id: int, preserve_daily_challenge: bool = false) -> void:
		if not preserve_daily_challenge:
			clear_daily_challenge()
		launches += 1
		start_level(level_id)

var _failures: int = 0
var _checks: int = 0
var _manager: NavigationStub

func _ready() -> void:
	_run.call_deferred()

func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("DAILY CHECK: " + message)

func _challenge(target: String = "coins_10") -> Dictionary:
	return {"date_key": GameManager.get_daily_date_key(), "level_id": 1, "target": target, "reward_gems": 3}

func _start(target: String) -> void:
	SaveManager._settings.erase("daily_done_date")
	_check(_manager.start_daily_challenge(_challenge(target)), "fresh " + target + " challenge starts")

func _run() -> void:
	if "--daily-test-isolated" not in OS.get_cmdline_user_args() or not OS.get_user_data_dir().contains("daily-test-profile"):
		push_error("Use isolated APPDATA .godot/daily-test-profile and -- --daily-test-isolated.")
		get_tree().quit(2)
		return
	SupabaseClient._access_token = ""
	SupabaseClient._user_id = ""
	GameManager.is_logged_in = false
	SaveManager._settings = {"cloud_backup": false}
	SaveManager._save_data = {"completed_levels": [], "gems": 0, "coins": 0}
	_manager = NavigationStub.new()
	add_child(_manager)

	_check(_manager.get_previous_daily_date_key("2026-01-01") == "2025-12-31", "year boundary")
	_check(_manager.get_previous_daily_date_key("2024-03-01") == "2024-02-29", "leap day")
	_check(_manager.get_previous_daily_date_key("2026-03-01") == "2026-02-28", "ordinary February")
	_check(_manager.get_daily_date_key() == Time.get_date_string_from_system(false), "local calendar date")
	_check(_manager.is_daily_level_accessible(1), "starter level accessible")
	_check(not _manager.is_daily_level_accessible(2), "locked level excluded")
	SaveManager._save_data["completed_levels"] = [1, 2, 3, 4, 5]
	_check(not _manager.is_daily_level_accessible(4), "registration gate honored")
	var key_file := FileAccess.open(SupabaseClient.REG_KEY_PATH, FileAccess.WRITE)
	key_file.store_string("{}")
	key_file.close()
	_check(_manager.is_daily_level_accessible(4), "registered unlocked trail accessible")
	_check(not _manager.is_daily_level_accessible(6), "Sand Shoes gate honored")
	SaveManager.unlock_upgrade("sand_shoes")
	_check(_manager.is_daily_level_accessible(6), "Sand Shoes permit trail six")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SupabaseClient.REG_KEY_PATH))
	SaveManager._save_data["completed_levels"] = []

	var daily: Control = load("res://scripts/ui/DailyChallenge.gd").new()
	add_child(daily)
	var first: Dictionary = daily._today_challenge()
	_check(int(first["level_id"]) == 1, "first-time player's daily uses level one")
	SaveManager._save_data["completed_levels"] = [1, 2]
	_check(daily._today_challenge() == first, "daily remains stable after campaign unlocks")
	daily._displayed_date = "2000-01-01"
	daily._update_countdown()
	_check(daily._displayed_date == _manager.get_daily_date_key(), "open screen refreshes after date changes")
	_check(is_instance_valid(daily._countdown_label), "countdown rebuilt after rollover")
	daily.queue_free()

	_start("coins_10")
	_manager.session_coins = 12
	_manager._challenge_collected_coins = 9
	_manager._award_daily_challenge()
	_check(not _manager.last_daily_result["passed"], "bonus currency cannot satisfy trail coin target")
	_manager.restart_level()
	_manager._challenge_collected_coins = 10
	_manager._award_daily_challenge()
	_check(_manager.last_daily_result["passed"], "coin target rewards after retry")
	var awarded_gems := SaveManager.get_gems()
	_manager._award_daily_challenge()
	_check(SaveManager.get_gems() == awarded_gems, "repeat award call does not duplicate currency")
	_check(not _manager.start_daily_challenge(_challenge()), "claimed day cannot start again")
	_manager.in_daily_challenge = true
	_manager.daily_challenge_data = _challenge()
	_manager._challenge_award_evaluated = false
	_manager._award_daily_challenge()
	_check(SaveManager.get_gems() == awarded_gems, "claimed day protected even after state reset")

	_start("no_fail")
	_manager._on_level_failed(1, "test")
	_manager.restart_level()
	_check(_manager._challenge_fail_count == 1, "failure count survives retry")
	_manager._award_daily_challenge()
	_check(not _manager.last_daily_result["passed"], "stumble cannot be erased by retry")
	_start("no_fail")
	_check(_manager._challenge_fail_count == 0, "new challenge resets past failures")
	_manager._award_daily_challenge()
	_check(_manager.last_daily_result["passed"], "fresh clean run rewards")

	_start("one_shot")
	_manager.restart_level()
	_manager._award_daily_challenge()
	_check(not _manager.last_daily_result["passed"], "single attempt excludes retry")
	_start("one_shot")
	_manager._on_level_failed(1, "revived")
	_manager._award_daily_challenge()
	_check(not _manager.last_daily_result["passed"], "single attempt excludes revive")
	_start("one_shot")
	_check(not _manager._challenge_retry_used, "fresh challenge resets retry flag")

	_start("coins_half")
	_manager._challenge_total_coins = 17
	_manager._challenge_collected_coins = 8
	_manager._award_daily_challenge()
	_check(not _manager.last_daily_result["passed"], "half coin target rounds up")
	_manager.restart_level()
	_manager._challenge_total_coins = 17
	_manager._challenge_collected_coins = 9
	_manager._award_daily_challenge()
	_check(_manager.last_daily_result["passed"], "reachable half coin target awards")
	_start("stars_2")
	_manager._challenge_completion_stars = 2
	_manager._award_daily_challenge()
	_check(_manager.last_daily_result["passed"], "two stars earn daily reward")

	_start("speed_60")
	_manager._level_elapsed_seconds = 60.0
	_manager._award_daily_challenge()
	_check(not _manager.last_daily_result["passed"], "under sixty is strictly less than sixty")
	_manager.restart_level()
	_manager._level_elapsed_seconds = 59.9
	_manager._award_daily_challenge()
	_check(_manager.last_daily_result["passed"], "sub-sixty active time succeeds")
	_start("speed_60")
	_manager._level_elapsed_seconds = 0.0
	_manager._last_elapsed_tick = Time.get_ticks_msec() - 1000
	_manager.state = _manager.GameState.PAUSED
	_manager._process(1.0)
	_check(_manager.get_level_elapsed_seconds() == 0.0, "pauses excluded from active time")
	_manager.state = _manager.GameState.PLAYING
	_manager._last_elapsed_tick = Time.get_ticks_msec() - 1000
	Engine.time_scale = 0.35
	_manager._process(0.35)
	Engine.time_scale = 1.0
	_check(_manager.get_level_elapsed_seconds() >= 1.0, "slow motion uses real elapsed time")

	_start("coins_10")
	_manager.daily_challenge_data["date_key"] = _manager.get_previous_daily_date_key()
	_manager._challenge_collected_coins = 10
	awarded_gems = SaveManager.get_gems()
	_manager._award_daily_challenge()
	_check(SaveManager.get_gems() == awarded_gems, "old challenge cannot collect new day's reward")
	_check(not _manager.in_daily_challenge, "expired challenge clears mode")
	_start("coins_10")
	_manager.go_to_gameplay_3d(1)
	_check(not _manager.in_daily_challenge and _manager.last_daily_result.is_empty(), "campaign navigation clears challenge")
	_manager.clear_daily_challenge()
	_check(_manager.daily_challenge_data.is_empty(), "explicit clear removes challenge context")
	print("DAILY CHECKS: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)
