extends BaseTile
class_name CoinTile

func _ready() -> void:
	tile_type = Constants.TILE_COIN
	color = Color(1.0, 0.85, 0.0)  # gold
	texture_path = "res://assets/sprites/tiles/coin.png"
	super()

func on_player_enter(_player) -> void:
	if is_collected:
		return
	is_collected = true
	GameManager.collect_coin()
	EventBus.play_sfx.emit("coin")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
