extends Node2D
class_name Player

signal move_started(direction: Vector2i)
signal move_finished(new_grid_pos: Vector2i)

var grid_pos: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var skin_id: String = "explorer"

func _ready() -> void:
	skin_id = SaveManager.get_selected_skin()
	_setup_visual()

func _setup_visual() -> void:
	if get_child_count() > 0:
		return
	var texture_path := "res://assets/sprites/characters/%s.png" % skin_id
	if ResourceLoader.exists(texture_path):
		var texture: Texture2D = load(texture_path)
		if texture != null:
			var sprite := Sprite2D.new()
			sprite.name = "Visual"
			sprite.texture = texture
			sprite.centered = false
			var texture_size := texture.get_size()
			if texture_size.x > 0.0 and texture_size.y > 0.0:
				sprite.scale = Vector2(
					Constants.TILE_SIZE / texture_size.x,
					Constants.TILE_SIZE / texture_size.y
				)
			add_child(sprite)
			return
	_draw_placeholder_visual()

func _draw_placeholder_visual() -> void:
	# Fallback for custom skins without an asset yet.
	var rect := ColorRect.new()
	rect.size = Vector2(Constants.TILE_SIZE - 8, Constants.TILE_SIZE - 8)
	rect.position = Vector2(4, 4)
	rect.color = Color(0.2, 0.6, 1.0)  # blue player
	add_child(rect)
	var label := Label.new()
	label.text = "P"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	label.position = Vector2(0, 0)
	add_child(label)

func move_to(new_grid_pos: Vector2i, duration: float = Constants.MOVE_DURATION) -> void:
	if is_moving:
		return
	is_moving = true
	grid_pos = new_grid_pos
	var target_world := _grid_to_world(new_grid_pos)
	emit_signal("move_started", new_grid_pos)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position", target_world, duration)
	tween.tween_callback(_on_move_finished.bind(new_grid_pos))

func teleport_to(new_grid_pos: Vector2i) -> void:
	grid_pos = new_grid_pos
	position = _grid_to_world(new_grid_pos)

func _on_move_finished(new_pos: Vector2i) -> void:
	is_moving = false
	emit_signal("move_finished", new_pos)

func _grid_to_world(gp: Vector2i) -> Vector2:
	return Vector2(gp.x * Constants.TILE_SIZE, gp.y * Constants.TILE_SIZE)

func play_collect_anim() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func play_death_anim(on_done: Callable) -> void:
	is_moving = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.4)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(on_done)
