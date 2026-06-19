extends CanvasLayer

@onready var lbl_coins: Label  = $TopBar/LblCoins
@onready var lbl_level: Label  = $TopBar/LblLevel
@onready var btn_pause: Button = $TopBar/BtnPause

var _turn_lbl     : Label = null
var _sand_warn_lbl: Label = null
var _sand_warn_timer: float = 0.0
var _res_bar      : Control = null
var _res_labels   : Dictionary = {}

func _ready() -> void:
	btn_pause.pressed.connect(_on_pause)
	EventBus.coin_collected.connect(_on_coin)
	EventBus.resource_collected.connect(_on_resource)
	_build_turn_label()
	_build_sand_warning()
	_build_resource_bar()

func _process(delta: float) -> void:
	if _sand_warn_timer > 0.0:
		_sand_warn_timer -= delta
		if _sand_warn_timer <= 0.0:
			if _sand_warn_lbl != null:
				_sand_warn_lbl.visible = false

# ─── Turn prompt ─────────────────────────────────────────────────────────────

func _build_turn_label() -> void:
	_turn_lbl = Label.new()
	_turn_lbl.name = "LblTurnPrompt"
	_turn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_turn_lbl.add_theme_font_size_override("font_size", 44)
	_turn_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1))
	_turn_lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	_turn_lbl.add_theme_constant_override("shadow_offset_x", 3)
	_turn_lbl.add_theme_constant_override("shadow_offset_y", 3)
	_turn_lbl.size = Vector2(480, 70)
	_turn_lbl.position = Vector2(0, 680)
	_turn_lbl.visible = false
	_turn_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_turn_lbl)

func show_turn_prompt(dir: int, _corner: Vector3) -> void:
	_turn_lbl.text = "◀  TURN LEFT" if dir < 0 else "TURN RIGHT  ▶"
	_turn_lbl.visible = true

func hide_turn_prompt() -> void:
	_turn_lbl.visible = false

# ─── Sand warning ─────────────────────────────────────────────────────────────

func _build_sand_warning() -> void:
	var bg := ColorRect.new()
	bg.name = "SandWarnBg"
	bg.color = Color(0.55, 0.40, 0.08, 0.92)
	bg.size = Vector2(400, 52)
	bg.position = Vector2(40, 620)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	_sand_warn_lbl = Label.new()
	_sand_warn_lbl.name = "LblSandWarning"
	_sand_warn_lbl.text = "👟  Sand Shoes Required to Jump!"
	_sand_warn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sand_warn_lbl.add_theme_font_size_override("font_size", 16)
	_sand_warn_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.70))
	_sand_warn_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.70))
	_sand_warn_lbl.add_theme_constant_override("shadow_offset_x", 1)
	_sand_warn_lbl.add_theme_constant_override("shadow_offset_y", 1)
	_sand_warn_lbl.size = Vector2(400, 52)
	_sand_warn_lbl.position = Vector2(40, 620)
	_sand_warn_lbl.visible = false
	_sand_warn_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sand_warn_lbl)
	# Keep bg sync'd with label
	bg.visible = false
	_sand_warn_lbl.set_meta("bg", bg)

func show_sand_warning() -> void:
	if _sand_warn_lbl == null:
		return
	_sand_warn_lbl.visible = true
	var bg := _sand_warn_lbl.get_meta("bg") as ColorRect
	if bg != null:
		bg.visible = true
	_sand_warn_timer = 2.2

# ─── Resource bar (shown during gameplay for current level resources) ─────────

func _build_resource_bar() -> void:
	_res_bar = Control.new()
	_res_bar.name = "ResourceBar"
	_res_bar.size = Vector2(480, 28)
	_res_bar.position = Vector2(0, 62)
	_res_bar.visible = false
	_res_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_res_bar)

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.06, 0.02, 0.80)
	bg.size = Vector2(480, 28)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_res_bar.add_child(bg)

func show_resource_bar(resources: Array) -> void:
	if _res_bar == null:
		return
	for child in _res_bar.get_children():
		if child is Label:
			child.queue_free()
	_res_labels.clear()
	var x: float = 8.0
	for res_id in resources:
		var info := _find_resource_info(res_id)
		var lbl := Label.new()
		lbl.name = "Res_" + res_id
		lbl.text = info.get("icon", "?") + " 0"
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.90, 0.85, 0.60))
		lbl.size = Vector2(80, 28)
		lbl.position = Vector2(x, 0)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_res_bar.add_child(lbl)
		_res_labels[res_id] = lbl
		x += 84.0
	_res_bar.visible = true

func _on_resource(resource_id: String, _amount: int) -> void:
	if not _res_labels.has(resource_id):
		return
	var info := _find_resource_info(resource_id)
	var lbl := _res_labels[resource_id] as Label
	var total: int = SaveManager.get_resource(resource_id)
	lbl.text = info.get("icon", "?") + " " + str(total)

func _find_resource_info(resource_id: String) -> Dictionary:
	for r: Dictionary in Constants.RESOURCES:
		if r.get("id", "") == resource_id:
			return r
	return { "id": resource_id, "name": resource_id, "icon": "?" }

# ─── Setup / events ───────────────────────────────────────────────────────────

func setup(level_id: int) -> void:
	lbl_level.text = "Level " + str(level_id)
	lbl_coins.text = "🪙 0"
	# Show resource bar for Level 6 with relevant resources
	if level_id == 6:
		show_resource_bar(["food", "bricks", "wood", "sunstone_shards"])

func _on_coin(total: int) -> void:
	lbl_coins.text = "🪙 " + str(total)

func _on_pause() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.pause_game()
