extends BaseTile
class_name GateTile

var is_open: bool = false

func _ready() -> void:
	tile_type = Constants.TILE_GATE
	color = Color(0.5, 0.3, 0.1)  # brown
	texture_path = "res://assets/sprites/tiles/gate.png"
	is_solid = true
	is_passable = false
	super()

func interact(player) -> bool:
	if is_open:
		return true
	if GameManager.session_keys > 0:
		open_gate()
		GameManager.spend_key()
		return true
	EventBus.play_sfx.emit("locked")
	return false

func open_gate() -> void:
	is_open = true
	is_solid = false
	is_passable = true
	EventBus.play_sfx.emit("gate_open")
	EventBus.gate_opened.emit(grid_pos)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func on_player_enter(_player) -> void:
	pass
