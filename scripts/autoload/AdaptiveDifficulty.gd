extends Node

# On-device AI difficulty adaptation.
#
# After a player fails the same level repeatedly, a small fraction of
# obstacles are silently skipped so the level becomes passable without
# feeling broken.  Difficulty resets to full when the player succeeds.
#
# No server, no flags, no mode-select — the game just quietly responds
# to the player's actual skill level.

# How many consecutive fails trigger each tier
const TIER_1_FAILS := 3    # 15 % obstacle skip
const TIER_2_FAILS := 5    # 28 % obstacle skip
const TIER_3_FAILS := 8    # 38 % obstacle skip (cap — level stays a real challenge)

# ── Attempt counter (in memory only; SaveManager stores persistence) ──────────

var _attempt: Dictionary = {}   # level_id -> attempt number for this session

# ── Public API ────────────────────────────────────────────────────────────────

# Returns a 0.0–0.38 probability that any given obstacle is skipped.
# Called from LevelManager3D._spawn_obstacles() for every level load.
func get_obstacle_skip_chance(level_id: int) -> float:
	var fails := SaveManager.get_level_fail_count(level_id)
	if fails < TIER_1_FAILS: return 0.0
	if fails < TIER_2_FAILS: return 0.15
	if fails < TIER_3_FAILS: return 0.28
	return 0.38

# Returns a context-sensitive tip after repeated failures, or "" if none.
# Show this on the game-over screen; hide it on first/second fail.
func get_hint_text(level_id: int) -> String:
	var fails := SaveManager.get_level_fail_count(level_id)
	if fails < TIER_1_FAILS:
		return ""
	if fails < 6:
		return "Tip: Swipe before the obstacle reaches you — react early."
	if fails < 9:
		return "Tip: The center lane usually has fewer hazards — stay there when unsure."
	return "Tip: Look further ahead. The camera shows what's coming — plan your next two moves."

# How many times has this level been attempted this session?
func get_current_attempt(level_id: int) -> int:
	return _attempt.get(level_id, 0)

# Call at the start of every level run
func on_level_start(level_id: int) -> void:
	_attempt[level_id] = get_current_attempt(level_id) + 1

# Call when the player dies — records the fail and triggers next difficulty tier
func on_level_fail(level_id: int) -> void:
	SaveManager.increment_level_fail_count(level_id)

# Call when the player clears the level — resets difficulty to full
func on_level_complete(level_id: int) -> void:
	SaveManager.reset_level_fail_count(level_id)
