extends BaseTile
class_name SwitchTile

# Toggling a switch opens or closes a set of gates labelled with a matching id.
@export var switch_id: String = "A"
var activated: bool = false

func _ready() -> void:
	tile_type = Constants.TILE_SWITCH
	color = Color(1.0, 0.2, 0.8)  # magenta
	texture_path = "res://assets/sprites/tiles/switch.png"
	super()

func on_player_enter(player) -> void:
	if activated:
		return
	activated = true
	color = Color(0.4, 0.1, 0.4)
	_update_visual()
	EventBus.play_sfx.emit("switch")
	# Notify the grid to handle switch_id linked gates
	player.get_parent().activate_switch(switch_id)

func _update_visual() -> void:
	set_visual_texture("res://assets/sprites/tiles/switch_active.png")
