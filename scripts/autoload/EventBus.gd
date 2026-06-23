extends Node

# Central signal bus — all game systems communicate through here.

# --- Gameplay ---
@warning_ignore("unused_signal")
signal level_loaded(level_id: int)
@warning_ignore("unused_signal")
signal player_moved(new_pos: Vector2i)
@warning_ignore("unused_signal")
signal coin_collected(total_coins: int)
@warning_ignore("unused_signal")
signal gem_collected(total_gems: int)
@warning_ignore("unused_signal")
signal key_collected(keys_held: int)
@warning_ignore("unused_signal")
signal gate_opened(gate_pos: Vector2i)
@warning_ignore("unused_signal")
signal trap_triggered(player_pos: Vector2i)
@warning_ignore("unused_signal")
signal level_completed(level_id: int, stars: int, coins_earned: int, moves_used: int)
@warning_ignore("unused_signal")
signal level_failed(level_id: int, reason: String)
@warning_ignore("unused_signal")
signal hint_used(hints_remaining: int)

# --- Progression ---
@warning_ignore("unused_signal")
signal level_unlocked(level_id: int)
@warning_ignore("unused_signal")
signal skin_unlocked(skin_id: String)
@warning_ignore("unused_signal")
signal stars_updated(total_stars: int)
@warning_ignore("unused_signal")
signal lives_changed(current: int, max_lives: int)

# --- UI ---
@warning_ignore("unused_signal")
signal pause_toggled(is_paused: bool)
@warning_ignore("unused_signal")
signal settings_changed()
@warning_ignore("unused_signal")
signal login_requested()
@warning_ignore("unused_signal")
signal login_completed(success: bool)
@warning_ignore("unused_signal")
signal shop_opened()
@warning_ignore("unused_signal")
signal daily_challenge_requested()

# --- Social ---
@warning_ignore("unused_signal")
signal friend_invite_triggered()
@warning_ignore("unused_signal")
signal score_share_triggered(level_id: int, score: int, stars: int)
@warning_ignore("unused_signal")
signal challenge_sent(challenge_code: String)

# --- Save/Sync ---
@warning_ignore("unused_signal")
signal save_completed()
@warning_ignore("unused_signal")
signal sync_started()
@warning_ignore("unused_signal")
signal sync_completed(success: bool)

# --- Resources ---
@warning_ignore("unused_signal")
signal resource_collected(resource_id: String, amount: int)

# --- Audio ---
@warning_ignore("unused_signal")
signal play_sfx(sfx_name: String)
@warning_ignore("unused_signal")
signal play_music(track_name: String)
@warning_ignore("unused_signal")
signal stop_music()
