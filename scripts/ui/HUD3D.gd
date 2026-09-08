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
var _hint_lbl     : Label = null
var _hint_timer   : float = 0.0
var _run_progress: ProgressBar = null
var _skill_card: Panel = null
var _star_goal: Label = null
var _chain_label: Label = null
var _chain_timer: ProgressBar = null
var _chain_popup: Label = null
var _chain_popup_tween: Tween = null

func _ready() -> void:
	btn_pause.pressed.connect(_on_pause)
	EventBus.coin_collected.connect(_on_coin)
	EventBus.resource_collected.connect(_on_resource)
	EventBus.lives_changed.connect(_on_lives_changed)
	_build_turn_label()
	_build_sand_warning()
	_build_resource_bar()
	_build_mode_labels()
	_build_skill_meter()
	_run_progress = ProgressBar.new()
	_run_progress.name = "TrailProgress"
	_run_progress.position = Vector2(14, 58)
	_run_progress.size = Vector2(452, 5)
	_run_progress.show_percentage = false
	_run_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.04, 0.12, 0.07, 0.75)
	track.set_corner_radius_all(3)
	_run_progress.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("edc567")
	fill.set_corner_radius_all(3)
	_run_progress.add_theme_stylebox_override("fill", fill)
	_run_progress.size = Vector2(452, 5)
	_run_progress.visible = not GameManager.endless_mode
	add_child(_run_progress)
	_run_progress.set_deferred("size", Vector2(452, 5))

func set_run_progress(row: int, total_rows: int) -> void:
	if _run_progress == null:
		return
	_run_progress.max_value = maxi(1, total_rows)
	_run_progress.value = row
	lbl_level.text = "Level %d · %d%%" % [_level_id, clampi(int(100.0 * float(row) / maxf(1.0, float(total_rows))), 0, 100)]

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
	if _hint_timer > 0.0:
		_hint_timer -= delta
		if _hint_timer <= 0.0 and _hint_lbl != null:
			_hint_lbl.visible = false

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

# ─── Tutorial hints + endless progress ───────────────────────────────────────

func set_progress_text(text: String) -> void:
	lbl_level.text = text

func show_hint(text: String, seconds: float = 2.6) -> void:
	if _hint_lbl == null:
		_hint_lbl = _hud_label("LblHint", Vector2(22, 500), Vector2(436, 88), 26)
		_hint_lbl.add_theme_color_override("font_color", Color(1.0, 0.97, 0.82))
		add_child(_hint_lbl)
	_hint_lbl.text = text
	_hint_lbl.visible = true
	_hint_timer = seconds

func _build_skill_meter() -> void:
	_skill_card = Panel.new()
	_skill_card.name = "SkillMeter"
	_skill_card.position = Vector2(24, 760)
	_skill_card.size = Vector2(432, 72)
	_skill_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.03, 0.10, 0.06, 0.88)
	background.set_corner_radius_all(12)
	background.border_color = Color(0.92, 0.76, 0.40, 0.55)
	background.set_border_width_all(1)
	_skill_card.add_theme_stylebox_override("panel", background)
	add_child(_skill_card)
	_star_goal = _hud_label("StarGoal", Vector2(12, 6), Vector2(408, 25), 14)
	_skill_card.add_child(_star_goal)
	_chain_label = _hud_label("CoinChain", Vector2(12, 30), Vector2(408, 24), 13)
	_chain_label.add_theme_color_override("font_color", Color("d9eacb"))
	_skill_card.add_child(_chain_label)
	_chain_timer = ProgressBar.new()
	_chain_timer.show_percentage = false
	_chain_timer.max_value = 1.0
	_chain_timer.position = Vector2(14, 60)
	_chain_timer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var track := StyleBoxFlat.new()
	track.bg_color = Color("0e2419")
	track.set_corner_radius_all(3)
	_chain_timer.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("edc567")
	fill.set_corner_radius_all(3)
	_chain_timer.add_theme_stylebox_override("fill", fill)
	_skill_card.add_child(_chain_timer)
	_chain_timer.set_deferred("size", Vector2(404, 5))

func set_skill_progress(coins: int, target: int, chain: int, remaining: float, endless: bool) -> void:
	if _star_goal == null:
		return
	_star_goal.text = "STAGE COINS  %d" % coins if endless else "3-STAR GOAL  %d / %d trail coins" % [mini(coins, target), target]
	var next_bonus := (int(chain / 5.0) + 1) * 5
	_chain_label.text = "Link 5 pickups for +2 bonus coins" if chain == 0 else "COIN CHAIN  %d / %d  ·  Next bonus +2" % [chain, next_bonus]
	_chain_timer.value = remaining

func show_chain_bonus(chain: int, bonus: int) -> void:
	if _chain_popup == null:
		_chain_popup = _hud_label("ChainBonus", Vector2(50, 365), Vector2(380, 62), 24)
		add_child(_chain_popup)
	if _chain_popup_tween != null and _chain_popup_tween.is_valid():
		_chain_popup_tween.kill()
	_chain_popup.text = "%d-COIN CHAIN!\n+%d bonus coins" % [chain, bonus]
	_chain_popup.position.y = 365
	_chain_popup.modulate.a = 1.0
	_chain_popup.visible = true
	_chain_popup_tween = create_tween()
	_chain_popup_tween.tween_property(_chain_popup, "position:y", 340.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_chain_popup_tween.tween_property(_chain_popup, "modulate:a", 0.0, 0.3)
	_chain_popup_tween.tween_callback(func() -> void: _chain_popup.visible = false)

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
