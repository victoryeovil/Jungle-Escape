extends Node

const SAVE_PATH := "user://save_data.json"
const SETTINGS_PATH := "user://settings.json"
const DEFAULT_UNLOCKED_SKINS := ["explorer", "jungle_girl"]
const LIVES_UNLOCK_LEVEL := 4
const MAX_EXPEDITION_LIVES := 5
const LIFE_REGEN_SECONDS := 15 * 60
const LIFE_COIN_COST := 50
const FULL_LIFE_COIN_COST := 200
const LIFE_GEM_COST := 1
const FULL_LIFE_GEM_COST := 4

var _save_data: Dictionary = {}
var _settings: Dictionary = {}

func _ready() -> void:
	load_all()

# ── Public API ────────────────────────────────────────────────────────────────

func get_current_level() -> int:
	return _save_data.get("current_level", 1)

func set_current_level(level: int) -> void:
	_save_data["current_level"] = level
	save_game()

func get_completed_levels() -> Array:
	return _save_data.get("completed_levels", [])

func is_level_completed(level_id: int) -> bool:
	return level_id in get_completed_levels()

func is_level_unlocked(level_id: int) -> bool:
	if level_id == 1:
		return true
	return is_level_completed(level_id - 1)

func get_stars(level_id: int) -> int:
	var stars_map: Dictionary = _save_data.get("stars", {})
	return stars_map.get(str(level_id), 0)

func set_stars(level_id: int, stars: int) -> void:
	if not _save_data.has("stars"):
		_save_data["stars"] = {}
	var prev = get_stars(level_id)
	if stars > prev:
		_save_data["stars"][str(level_id)] = stars
	save_game()

func complete_level(level_id: int, stars: int, coins_earned: int) -> void:
	var completed: Array = get_completed_levels()
	if level_id not in completed:
		completed.append(level_id)
		_save_data["completed_levels"] = completed
		EventBus.level_unlocked.emit(level_id + 1)
	set_stars(level_id, stars)
	add_coins(coins_earned)
	if level_id >= get_current_level():
		set_current_level(level_id + 1)
	if level_id == 3:
		_activate_lives_if_needed()

func get_total_stars() -> int:
	var total := 0
	var stars_map: Dictionary = _save_data.get("stars", {})
	for v in stars_map.values():
		total += int(v)
	return total

func get_coins() -> int:
	return _save_data.get("coins", 0)

func add_coins(amount: int) -> void:
	_save_data["coins"] = get_coins() + amount
	save_game()

func spend_coins(amount: int) -> bool:
	if get_coins() >= amount:
		_save_data["coins"] = get_coins() - amount
		save_game()
		return true
	return false

func get_gems() -> int:
	return _save_data.get("gems", 0)

func add_gems(amount: int) -> void:
	_save_data["gems"] = get_gems() + amount
	save_game()

func spend_gems(amount: int) -> bool:
	if get_gems() >= amount:
		_save_data["gems"] = get_gems() - amount
		save_game()
		return true
	return false

func get_hints() -> int:
	return _save_data.get("hints", 3)

func use_hint() -> bool:
	if get_hints() > 0:
		_save_data["hints"] = get_hints() - 1
		save_game()
		EventBus.hint_used.emit(get_hints())
		return true
	return false

func add_hints(amount: int) -> void:
	_save_data["hints"] = get_hints() + amount
	save_game()

func get_selected_skin() -> String:
	return _save_data.get("selected_skin", "explorer")

func set_selected_skin(skin_id: String) -> void:
	_save_data["selected_skin"] = skin_id
	save_game()

func get_unlocked_skins() -> Array:
	var skins: Array = _save_data.get("unlocked_skins", DEFAULT_UNLOCKED_SKINS.duplicate())
	for skin_id in DEFAULT_UNLOCKED_SKINS:
		if skin_id not in skins:
			skins.append(skin_id)
	return skins

func unlock_skin(skin_id: String) -> void:
	var skins: Array = get_unlocked_skins()
	if skin_id not in skins:
		skins.append(skin_id)
		_save_data["unlocked_skins"] = skins
		save_game()
		EventBus.skin_unlocked.emit(skin_id)

func is_skin_unlocked(skin_id: String) -> bool:
	return skin_id in get_unlocked_skins()

func get_setting(key: String, default_value = null):
	return _settings.get(key, default_value)

func set_setting(key: String, value) -> void:
	_settings[key] = value
	save_settings()
	EventBus.settings_changed.emit()

func is_first_launch() -> bool:
	return _save_data.get("first_launch_done", false) == false

func mark_first_launch_done() -> void:
	_save_data["first_launch_done"] = true
	save_game()

func get_levels_completed_count() -> int:
	return get_completed_levels().size()

# --- Expedition Lives -------------------------------------------------------

func should_show_lives() -> bool:
	return bool(_save_data.get("expedition_lives_active", false)) or get_current_level() >= LIVES_UNLOCK_LEVEL or is_level_completed(3)

func is_lives_system_active() -> bool:
	if bool(_save_data.get("expedition_lives_active", false)):
		_ensure_lives_state()
		return true
	if get_current_level() >= LIVES_UNLOCK_LEVEL or is_level_completed(3):
		_activate_lives_if_needed()
		return true
	return false

func activate_expedition_lives() -> void:
	_activate_lives_if_needed()

func can_start_level(level_id: int) -> bool:
	if level_id <= 3:
		return true
	if not is_lives_system_active():
		return false
	return get_lives() > 0

func get_lives() -> int:
	if not is_lives_system_active():
		return MAX_EXPEDITION_LIVES
	regenerate_lives()
	return int(_save_data.get("expedition_lives", MAX_EXPEDITION_LIVES))

func get_max_lives() -> int:
	return MAX_EXPEDITION_LIVES

func get_lives_display() -> String:
	if not should_show_lives():
		return ""
	return str(get_lives()) + "/" + str(MAX_EXPEDITION_LIVES)

func get_life_regen_seconds_remaining() -> int:
	if not is_lives_system_active() or get_lives() >= MAX_EXPEDITION_LIVES:
		return 0
	var now := int(Time.get_unix_time_from_system())
	var last := int(_save_data.get("last_life_regen_time", now))
	var elapsed: int = max(0, now - last)
	return int(max(0, LIFE_REGEN_SECONDS - (elapsed % LIFE_REGEN_SECONDS)))

func lose_life(level_id: int) -> bool:
	if level_id <= 3:
		return false
	if not is_lives_system_active():
		return false
	regenerate_lives()
	var current := int(_save_data.get("expedition_lives", MAX_EXPEDITION_LIVES))
	if current <= 0:
		return false
	_save_data["expedition_lives"] = current - 1
	_save_data["last_life_regen_time"] = int(Time.get_unix_time_from_system())
	save_game()
	EventBus.lives_changed.emit(current - 1, MAX_EXPEDITION_LIVES)
	return true

func add_life(amount: int = 1) -> void:
	if amount <= 0:
		return
	if not is_lives_system_active():
		return
	regenerate_lives()
	var current := int(_save_data.get("expedition_lives", MAX_EXPEDITION_LIVES))
	var updated: int = min(MAX_EXPEDITION_LIVES, current + amount)
	if updated == current:
		return
	_save_data["expedition_lives"] = updated
	if updated >= MAX_EXPEDITION_LIVES:
		_save_data["last_life_regen_time"] = int(Time.get_unix_time_from_system())
	save_game()
	EventBus.lives_changed.emit(updated, MAX_EXPEDITION_LIVES)

func regenerate_lives() -> void:
	if not bool(_save_data.get("expedition_lives_active", false)):
		return
	_ensure_lives_state()
	var current := int(_save_data.get("expedition_lives", MAX_EXPEDITION_LIVES))
	if current >= MAX_EXPEDITION_LIVES:
		return
	var now := int(Time.get_unix_time_from_system())
	var last := int(_save_data.get("last_life_regen_time", now))
	var elapsed: int = max(0, now - last)
	var lives_to_add := int(elapsed / LIFE_REGEN_SECONDS)
	if lives_to_add <= 0:
		return
	var updated: int = min(MAX_EXPEDITION_LIVES, current + lives_to_add)
	_save_data["expedition_lives"] = updated
	_save_data["last_life_regen_time"] = now if updated >= MAX_EXPEDITION_LIVES else last + lives_to_add * LIFE_REGEN_SECONDS
	save_game()
	EventBus.lives_changed.emit(updated, MAX_EXPEDITION_LIVES)

func buy_life_with_coins() -> bool:
	if not is_lives_system_active() or get_lives() >= MAX_EXPEDITION_LIVES:
		return false
	if not spend_coins(LIFE_COIN_COST):
		return false
	add_life(1)
	return true

func buy_full_lives_with_coins() -> bool:
	if not is_lives_system_active() or get_lives() >= MAX_EXPEDITION_LIVES:
		return false
	if not spend_coins(FULL_LIFE_COIN_COST):
		return false
	add_life(MAX_EXPEDITION_LIVES)
	return true

func buy_life_with_gems() -> bool:
	if not is_lives_system_active() or get_lives() >= MAX_EXPEDITION_LIVES:
		return false
	if not spend_gems(LIFE_GEM_COST):
		return false
	add_life(1)
	return true

func buy_full_lives_with_gems() -> bool:
	if not is_lives_system_active() or get_lives() >= MAX_EXPEDITION_LIVES:
		return false
	if not spend_gems(FULL_LIFE_GEM_COST):
		return false
	add_life(MAX_EXPEDITION_LIVES)
	return true

func reward_ad_life_available() -> bool:
	return false

func try_reward_ad_life() -> bool:
	return false

func is_lives_intro_pending() -> bool:
	return is_lives_system_active() and not bool(_save_data.get("lives_intro_seen", false))

func mark_lives_intro_seen() -> void:
	if not is_lives_system_active():
		return
	_save_data["lives_intro_seen"] = true
	save_game()

func _activate_lives_if_needed() -> void:
	if bool(_save_data.get("expedition_lives_active", false)):
		_ensure_lives_state()
		return
	_save_data["expedition_lives_active"] = true
	_save_data["expedition_lives"] = MAX_EXPEDITION_LIVES
	_save_data["last_life_regen_time"] = int(Time.get_unix_time_from_system())
	_save_data["lives_intro_seen"] = false
	save_game()
	EventBus.lives_changed.emit(MAX_EXPEDITION_LIVES, MAX_EXPEDITION_LIVES)

func _ensure_lives_state() -> void:
	var changed := false
	if not _save_data.has("expedition_lives"):
		_save_data["expedition_lives"] = MAX_EXPEDITION_LIVES
		changed = true
	else:
		var clamped := clampi(int(_save_data["expedition_lives"]), 0, MAX_EXPEDITION_LIVES)
		if clamped != int(_save_data["expedition_lives"]):
			_save_data["expedition_lives"] = clamped
			changed = true
	if not _save_data.has("last_life_regen_time"):
		_save_data["last_life_regen_time"] = int(Time.get_unix_time_from_system())
		changed = true
	if not _save_data.has("lives_intro_seen"):
		_save_data["lives_intro_seen"] = false
		changed = true
	if changed:
		save_game()

# ── Pending sync queue ─────────────────────────────────────────────────────────

func add_pending_sync(action: Dictionary) -> void:
	var pending: Array = _save_data.get("pending_sync", [])
	pending.append(action)
	_save_data["pending_sync"] = pending
	save_game()

func get_pending_sync() -> Array:
	return _save_data.get("pending_sync", [])

func clear_pending_sync() -> void:
	_save_data["pending_sync"] = []
	save_game()

# ── Persistence ────────────────────────────────────────────────────────────────

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_save_data, "\t"))
		file.close()
	EventBus.save_completed.emit()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_save_data = {}
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		file.close()
		var result: Variant = JSON.parse_string(text)
		if result is Dictionary:
			_save_data = result

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_settings, "\t"))
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		_settings = {
			"sfx_volume": 1.0,
			"music_volume": 0.7,
			"sfx_on": true,
			"music_on": true,
			"vibration_on": true,
			"notifications_on": true,
		}
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		file.close()
		var result: Variant = JSON.parse_string(text)
		if result is Dictionary:
			_settings = result

func load_all() -> void:
	load_game()
	load_settings()

func reset_all_data() -> void:
	_save_data = {}
	_settings = {}
	save_game()
	save_settings()

# ── Resources (bricks, wood, food, tools, etc.) ────────────────────────────

func get_resource(resource_id: String) -> int:
	var resources: Dictionary = _save_data.get("resources", {})
	return int(resources.get(resource_id, 0))

func add_resource(resource_id: String, amount: int) -> void:
	if not _save_data.has("resources"):
		_save_data["resources"] = {}
	_save_data["resources"][resource_id] = get_resource(resource_id) + amount
	save_game()

func spend_resource(resource_id: String, amount: int) -> bool:
	if get_resource(resource_id) >= amount:
		if not _save_data.has("resources"):
			_save_data["resources"] = {}
		_save_data["resources"][resource_id] = get_resource(resource_id) - amount
		save_game()
		return true
	return false

func get_all_resources() -> Dictionary:
	return _save_data.get("resources", {})

# ── Upgrades (sand_shoes, etc.) ────────────────────────────────────────────

func has_upgrade(upgrade_id: String) -> bool:
	var upgrades: Array = _save_data.get("upgrades", [])
	return upgrade_id in upgrades

func unlock_upgrade(upgrade_id: String) -> void:
	var upgrades: Array = _save_data.get("upgrades", [])
	if upgrade_id not in upgrades:
		upgrades.append(upgrade_id)
		_save_data["upgrades"] = upgrades
		save_game()

func buy_upgrade(upgrade_id: String) -> bool:
	for upg: Dictionary in Constants.UPGRADES:
		if upg["id"] != upgrade_id:
			continue
		if has_upgrade(upgrade_id):
			return true  # already owned
		var cost: Dictionary = upg["cost"]
		# Verify affordability first
		for res_id: String in cost:
			var needed: int = int(cost[res_id])
			if res_id == "coins":
				if get_coins() < needed:
					return false
			elif get_resource(res_id) < needed:
				return false
		# Spend all resources
		for res_id: String in cost:
			var needed: int = int(cost[res_id])
			if res_id == "coins":
				spend_coins(needed)
			else:
				spend_resource(res_id, needed)
		unlock_upgrade(upgrade_id)
		return true
	return false

# ── Home building stage ────────────────────────────────────────────────────

func get_home_stage() -> int:
	return int(_save_data.get("home_stage", 0))

func set_home_stage(stage: int) -> void:
	_save_data["home_stage"] = stage
	save_game()
