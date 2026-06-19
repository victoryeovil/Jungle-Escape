extends BaseTile
class_name RiverTile

func _ready() -> void:
	tile_type = Constants.TILE_RIVER
	color = Color(0.1, 0.4, 0.9)  # blue
	texture_path = "res://assets/sprites/tiles/river.png"
	super()

func on_player_enter(player) -> void:
	EventBus.play_sfx.emit("splash")
	EventBus.trap_triggered.emit(player.grid_pos)
	GameManager.fail_current_level("river")
