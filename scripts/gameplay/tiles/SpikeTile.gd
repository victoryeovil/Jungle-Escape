extends BaseTile
class_name SpikeTile

func _ready() -> void:
	tile_type = Constants.TILE_SPIKE
	color = Color(0.6, 0.6, 0.6)  # grey
	texture_path = "res://assets/sprites/tiles/spike.png"
	super()

func on_player_enter(player) -> void:
	EventBus.play_sfx.emit("damage")
	EventBus.trap_triggered.emit(player.grid_pos)
	GameManager.fail_current_level("spike")
