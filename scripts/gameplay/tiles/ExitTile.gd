extends BaseTile
class_name ExitTile

func _ready() -> void:
	tile_type = Constants.TILE_EXIT
	color = Color(0.1, 0.9, 0.3)  # bright green
	texture_path = "res://assets/sprites/tiles/exit.png"
	super()
	_pulse()

func _pulse() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "modulate", Color(0.8, 1.0, 0.8), 0.8)
	tween.tween_property(self, "modulate", Color.WHITE, 0.8)

func on_player_enter(player) -> void:
	EventBus.play_sfx.emit("exit")
	# Level complete is triggered by Grid after this call
