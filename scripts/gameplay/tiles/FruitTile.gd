extends BaseTile
class_name FruitTile

func _ready() -> void:
	tile_type = Constants.TILE_FRUIT
	color = Color(1.0, 0.4, 0.1)  # orange
	texture_path = "res://assets/sprites/tiles/fruit.png"
	super()

func on_player_enter(_player) -> void:
	if is_collected:
		return
	is_collected = true
	GameManager.collect_coin()   # fruit counts as 2 coins
	GameManager.collect_coin()
	EventBus.play_sfx.emit("fruit")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
