extends BaseTile
class_name BridgeTile

# Bridge sits over a river — safe to walk on.

func _ready() -> void:
	tile_type = Constants.TILE_BRIDGE
	color = Color(0.6, 0.4, 0.2)  # wood
	texture_path = "res://assets/sprites/tiles/bridge.png"
	super()

func on_player_enter(_player) -> void:
	EventBus.play_sfx.emit("wood_step")
