extends BaseTile
class_name SnakeTile

func _ready() -> void:
	tile_type = Constants.TILE_SNAKE
	color = Color(0.2, 0.6, 0.1)  # dark green
	texture_path = "res://assets/sprites/tiles/snake.png"
	super()
	_animate()

func _animate() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "rotation_degrees", 10.0, 0.4)
	tween.tween_property(self, "rotation_degrees", -10.0, 0.4)

func on_player_enter(player) -> void:
	EventBus.play_sfx.emit("snake")
	EventBus.trap_triggered.emit(player.grid_pos)
	GameManager.fail_current_level("snake")
