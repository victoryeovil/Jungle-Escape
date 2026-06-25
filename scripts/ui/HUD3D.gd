extends CanvasLayer

@onready var lbl_coins: Label  = $TopBar/LblCoins
@onready var lbl_level: Label  = $TopBar/LblLevel
@onready var btn_pause: Button = $TopBar/BtnPause

var _turn_lbl     : Label = null
var _sand_warn_lbl: Label = null
var _sand_warn_timer: float = 0.0
var _res_bar      : Control = null
var _res_labels   : Dictionary = {}
var _mode_lbl     : Label = null
var _mode_timer: float = 0.0
var _route_lbl    : Label = null
var _route_timer: float = 0.0
var _junction_lbl : Label = null
var _lives_lbl    : Label = null
var _level_id     : int = 1

func _ready() -> void:
	btn_pause.pressed.connect(_on_pause)
	EventBus.coin_collected.connect(_on_coin)
	EventBus.resource_collected.connect(_on_resource)
	EventBus.lives_changed.connect(_on_lives_changed)
	_build_turn_label()
	_build_sand_warning()
	_build_resource_bar()
	_build_mode_labels()

func _process(delta: float) -> void:
	if _sand_warn_timer > 0.0:
		_sand_warn_timer -= delta
		if _sand_warn_timer <= 0.0:
			if _sand_warn_lbl != null:
				_sand_warn_lbl.visible = false
				var bg := _sand_warn_lbl.get_meta("bg") as ColorRect
				if bg != null:
					bg.visible = false
	if _mode_timer > 0.0:
		_mode_timer -= delta
		if _mode_timer <= 0.0 and _mode_lbl != null:
			_mode_lbl.visible = false
	if _route_timer > 0.0:
		_route_timer -= delta
		if _route_timer <= 0.0 and _route_lbl != null:
			_route_lbl.visible = false

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

func _build_mode_labels() -> void:
	_mode_lbl = _hud_label("LblMode", Vector2(22, 94), Vector2(436, 58), 18)
	_mode_lbl.visible = false
	add_child(_mode_lbl)

	_route_lbl = _hud_label("LblRouteChosen", Vector2(32, 154), Vector2(416, 42), 17)
	_route_lbl.visible = false
	add_child(_route_lbl)

	_junction_lbl = _hud_label("LblJunctionPrompt", Vector2(22, 610), Vector2(436, 76), 17)
	_junction_lbl.visible = false
	add_child(_junction_lbl)

func _hud_label(node_name: String, pos: Vector2, box_size: Vector2, font_size: int) -> Label:
	var lbl := Label.new()
	lbl.name = node_name
	lbl.position = pos
	lbl.size = box_size
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.44))
	lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl

func show_mode(mode: String, title: String, message: String) -> void:
	if _mode_lbl == null:
		return
	if mode == "run" or title.is_empty():
		_mode_lbl.visible = false
		return
	_mode_lbl.text = title + "\n" + message
	_mode_lbl.visible = true
	_mode_timer = 3.0

func show_junction_prompt(routes: Array) -> void:
	if _junction_lbl == null:
		return
	var prompt := ""
	for raw_route in routes:
		if not (raw_route is Dictionary):
			continue
		var route: Dictionary = raw_route
		var direction := str(route.get("direction", "right"))
		var label := str(route.get("label", "Route"))
		var part := ""
		match direction:
			"left":
				part = "LEFT: " + label
			"right":
				part = "RIGHT: " + label
			"up":
				part = "UP: " + label
			_:
				part = label
		if not prompt.is_empty():
			prompt += "  |  "
		prompt += part
	_junction_lbl.text = "CHOOSE TRAIL\n" + prompt
	_junction_lbl.visible = true

func hide_junction_prompt() -> void:
	if _junction_lbl != null:
		_junction_lbl.visible = false

func show_tribal_routes(routes: Array) -> void:
	if _junction_lbl == null:
		return
	var REWARD_ICONS := {
		"coins": "🪙", "gems": "💎", "map_piece": "🗺", "animal_badge": "★",
		"sunstone_shards": "✦", "relic_keys": "🗝", "food": "🥫", "wood": "🪵",
		"bricks": "🧱", "water_token": "💧", "fish_token": "🐟",
		"river_relic": "⚱", "trade_token": "🔶",
	}
	var parts: Array[String] = []
	for raw_route in routes:
		if not (raw_route is Dictionary):
			continue
		var route: Dictionary = raw_route
		var direction := str(route.get("direction", "right"))
		var reward := str(route.get("reward", "coins"))
		var icon: String = REWARD_ICONS.get(reward, "●")
		var dir_arrow: String = "←" if direction == "left" else ("→" if direction == "right" else "↑")
		parts.append("%s %s %s" % [dir_arrow, icon, str(route.get("label", "Route"))])
	_junction_lbl.text = "✦ TRACKER VISION\n" + "   ".join(parts)
	_junction_lbl.visible = true

func show_route_chosen(route_label: String) -> void:
	if _route_lbl == null:
		return
	_route_lbl.text = "Trail Chosen: " + route_label
	_route_lbl.visible = true
	_route_timer = 2.4

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
	_level_id = level_id
	lbl_level.text = "Level " + str(level_id)
	_update_lives_label()
	lbl_coins.text = "🪙 0"
	# Show resource bar for Level 6 with relevant resources
	if level_id == 6:
		show_resource_bar(["food", "bricks", "wood", "sunstone_shards"])

func _on_coin(total: int) -> void:
	lbl_coins.text = "🪙 " + str(total)

func _on_lives_changed(_current: int, _max_lives: int) -> void:
	_update_lives_label()

func _update_lives_label() -> void:
	if _level_id <= 3 or not SaveManager.should_show_lives():
		if _lives_lbl != null:
			_lives_lbl.visible = false
		return
	if _lives_lbl == null:
		_lives_lbl = Label.new()
		_lives_lbl.name = "LblLives"
		_lives_lbl.add_theme_font_size_override("font_size", 18)
		_lives_lbl.add_theme_color_override("font_color", Color(1.0, 0.42, 0.34))
		_lives_lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
		_lives_lbl.add_theme_constant_override("shadow_offset_x", 1)
		_lives_lbl.add_theme_constant_override("shadow_offset_y", 1)
		_lives_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl_coins.get_parent().add_child(_lives_lbl)
	_lives_lbl.text = "LIFE " + SaveManager.get_lives_display()
	_lives_lbl.visible = true

func _on_pause() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.pause_game()
