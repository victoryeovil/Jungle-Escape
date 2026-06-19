extends Node2D
class_name BaseTile

# Every tile on the grid extends this. Override interact() for special behaviour.

var tile_type: String = "."
var grid_pos: Vector2i = Vector2i.ZERO
var is_passable: bool = true
var is_solid: bool = false     # blocks movement
var is_collected: bool = false # for collectibles that disappear after pickup

@export var color: Color = Color.WHITE  # placeholder — replace with Sprite2D
@export var texture_path: String = ""

func _ready() -> void:
	_draw_visual()

func set_visual_texture(path: String) -> void:
	texture_path = path
	if is_inside_tree():
		_redraw_visual()

func _redraw_visual() -> void:
	var existing := get_node_or_null("Visual")
	if existing:
		existing.free()
	_draw_visual()

func _draw_visual() -> void:
	if get_node_or_null("Visual") != null:
		return
	if _draw_sprite():
		return
	_draw_placeholder()

func _draw_sprite() -> bool:
	if texture_path.is_empty() or not ResourceLoader.exists(texture_path):
		return false
	var texture: Texture2D = load(texture_path)
	if texture == null:
		return false
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
	return true

func _draw_placeholder() -> void:
	# Fallback visual using a ColorRect child when art is unavailable.
	var rect := ColorRect.new()
	rect.name = "Visual"
	rect.size = Vector2(Constants.TILE_SIZE - 2, Constants.TILE_SIZE - 2)
	rect.position = Vector2(1, 1)
	rect.color = color
	add_child(rect)

# Called when the player attempts to enter this tile's cell.
# Returns true if the player may actually move here.
func interact(player) -> bool:
	return is_passable and not is_solid

# Called once after the player has successfully moved onto this tile.
func on_player_enter(player) -> void:
	pass
