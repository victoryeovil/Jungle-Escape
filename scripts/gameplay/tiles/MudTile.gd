extends BaseTile
class_name MudTile

# Mud slows the player: each step on mud costs 2 moves.

func _ready() -> void:
	tile_type = Constants.TILE_MUD
	color = Color(0.45, 0.3, 0.1)  # muddy brown
	texture_path = "res://assets/sprites/tiles/mud.png"
	super()

func on_player_enter(_player) -> void:
	# Extra move cost handled by Grid
	GameManager.register_move()  # double move cost
	EventBus.play_sfx.emit("mud")
