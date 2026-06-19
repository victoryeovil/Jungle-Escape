extends Node2D

@onready var grid: Grid              = $Grid
@onready var player: Player          = $Grid/Player
@onready var input_handler: InputHandler = $InputHandler
@onready var hud: CanvasLayer        = $HUD
@onready var pause_menu: Control     = $PauseMenu
@onready var level_complete: Control = $LevelComplete
@onready var game_over: Control      = $GameOver

const _BACKGROUND_TEX := "res://assets/backgrounds/bg_gameplay.png"

func _ready() -> void:
	_build_background()
	grid.player = player
	grid.input_handler = input_handler
	grid.load_level(GameManager.current_level_id)
	EventBus.play_music.emit("gameplay")

# ── Background ─────────────────────────────────────────────────────────────────

func _build_background() -> void:
	var vp: Vector2 = get_viewport_rect().size

	var old_bg := get_node_or_null("Background")
	if old_bg:
		old_bg.queue_free()

	if ResourceLoader.exists(_BACKGROUND_TEX):
		var tex_rect := TextureRect.new()
		tex_rect.name = "Background"
		tex_rect.texture = load(_BACKGROUND_TEX) as Texture2D
		tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tex_rect.position = Vector2.ZERO
		tex_rect.size = vp
		tex_rect.z_index = -20
		add_child(tex_rect)
		move_child(tex_rect, 0)
	else:
		var rect := ColorRect.new()
		rect.name = "Background"
		rect.color = Color(0.06, 0.20, 0.06, 1)
		rect.size = vp
		rect.z_index = -20
		add_child(rect)
		move_child(rect, 0)

	# Layer 1 — dark vignette border so the grid pops on screen
	# Built after load_level so grid dimensions are known; Grid calls _center_grid
	# which sets Grid.position. We hook it after the level is loaded.
	grid.level_ready.connect(_add_grid_frame, CONNECT_ONE_SHOT)

func _add_grid_frame() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var grid_px := Vector2(
		grid.grid_width  * Constants.TILE_SIZE,
		grid.grid_height * Constants.TILE_SIZE
	)
	var grid_origin: Vector2 = grid.position

	# Semi-transparent dark panel behind the grid to frame it
	var panel := ColorRect.new()
	panel.name = "GridFrame"
	panel.color = Color(0.0, 0.0, 0.0, 0.45)
	panel.position = grid_origin - Vector2(6, 6)
	panel.size = grid_px + Vector2(12, 12)
	panel.z_index = -10
	add_child(panel)
	move_child(panel, 1)   # just above the Background
