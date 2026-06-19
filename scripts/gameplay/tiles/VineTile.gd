extends BaseTile
class_name VineTile

# Vine teleports the player to the paired vine on the level.
var destination: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	tile_type = Constants.TILE_VINE
	color = Color(0.0, 0.7, 0.2)  # bright vine green
	texture_path = "res://assets/sprites/tiles/vine.png"
	super()

func on_player_enter(player) -> void:
	if destination == Vector2i(-1, -1):
		return
	EventBus.play_sfx.emit("vine_teleport")
	# Tell the grid to teleport the player
	player.get_parent().teleport_player(destination)
