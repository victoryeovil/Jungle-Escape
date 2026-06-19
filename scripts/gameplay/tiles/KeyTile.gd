extends BaseTile
class_name KeyTile

func _ready() -> void:
	tile_type = Constants.TILE_KEY
	color = Color(1.0, 0.6, 0.0)  # amber
	texture_path = "res://assets/sprites/tiles/key.png"
	super()

func on_player_enter(_player) -> void:
	if is_collected:
		return
	is_collected = true
	GameManager.collect_key()
	EventBus.play_sfx.emit("key")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
