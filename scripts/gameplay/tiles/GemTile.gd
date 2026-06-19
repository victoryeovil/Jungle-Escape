extends BaseTile
class_name GemTile

func _ready() -> void:
	tile_type = Constants.TILE_GEM
	color = Color(0.0, 0.8, 1.0)  # cyan
	texture_path = "res://assets/sprites/tiles/gem.png"
	super()

func on_player_enter(_player) -> void:
	if is_collected:
		return
	is_collected = true
	GameManager.collect_gem()
	EventBus.play_sfx.emit("gem")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
