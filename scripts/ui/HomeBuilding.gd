extends Control

# ─── Home Building Screen ─────────────────────────────────────────────────────
# Shows the 6-stage home construction progress.
# Each stage has a cost (from Constants.HOME_STAGES); player spends resources to advance.

const HOME_ART_PATH := "res://assets/backgrounds/bg_home_building.png"

var _stage_cards: Array[Control] = []
var _status_lbl: Label = null
var _progress_bar: ColorRect = null
var _home_art_texture: Texture2D = null

func _ready() -> void:
	_home_art_texture = _load_art_texture(HOME_ART_PATH)
	if _using_art_plate():
		_build_art_plate()
		_build_status_label()
		queue_redraw()
		return
	_build_background()
	_build_header()
	_build_progress_header()
	_build_stage_list()
	_build_status_label()
	_refresh()

# ─── Build ────────────────────────────────────────────────────────────────────

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.14, 0.09, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Savanna sky gradient at top
	var sky := ColorRect.new()
	sky.color = Color(0.62, 0.52, 0.30, 0.40)
	sky.size = Vector2(480, 110)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sky)

func _draw() -> void:
	if _using_art_plate():
		var draw_size := size
		if draw_size.x <= 0.0 or draw_size.y <= 0.0:
			draw_size = get_viewport_rect().size
		draw_texture_rect(_home_art_texture, Rect2(Vector2.ZERO, draw_size), false)

func _build_art_plate() -> void:
	_art_hit(Rect2(10, 10, 58, 44)).pressed.connect(_on_back)
	_art_hit(Rect2(430, 12, 42, 44)).pressed.connect(_on_plus)

	var stage_rows := [
		Rect2(350, 302, 106, 42),
		Rect2(350, 392, 106, 42),
		Rect2(350, 480, 106, 42),
		Rect2(350, 571, 106, 42),
		Rect2(350, 660, 106, 42),
		Rect2(350, 750, 106, 42),
	]
	for i in range(stage_rows.size()):
		_art_hit(stage_rows[i]).pressed.connect(_on_build.bind(i))

func _build_header() -> void:
	var hdr := ColorRect.new()
	hdr.color = Color(0.12, 0.08, 0.03, 0.96)
	hdr.size = Vector2(480, 60)
	add_child(hdr)

	var btn_back := Button.new()
	btn_back.text = "←"
	btn_back.custom_minimum_size = Vector2(52, 44)
	btn_back.position = Vector2(6, 8)
	btn_back.pressed.connect(_on_back)
	_style_btn(btn_back, Color(0.28, 0.18, 0.08))
	hdr.add_child(btn_back)

	var lbl_title := Label.new()
	lbl_title.text = "Build Your Home"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 20)
	lbl_title.add_theme_color_override("font_color", Color(0.96, 0.84, 0.42))
	lbl_title.size = Vector2(260, 44)
	lbl_title.position = Vector2(110, 10)
	hdr.add_child(lbl_title)

	var lbl_coins := Label.new()
	lbl_coins.name = "HdrCoins"
	lbl_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_coins.add_theme_font_size_override("font_size", 14)
	lbl_coins.add_theme_color_override("font_color", Color(1.0, 0.90, 0.30))
	lbl_coins.size = Vector2(90, 44)
	lbl_coins.position = Vector2(382, 10)
	hdr.add_child(lbl_coins)

func _build_progress_header() -> void:
	var prog_bg := ColorRect.new()
	prog_bg.name = "ProgBg"
	prog_bg.color = Color(0.08, 0.05, 0.02, 0.90)
	prog_bg.size = Vector2(480, 44)
	prog_bg.position = Vector2(0, 60)
	add_child(prog_bg)

	var lbl_prog := Label.new()
	lbl_prog.name = "LblProgress"
	lbl_prog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_prog.add_theme_font_size_override("font_size", 13)
	lbl_prog.add_theme_color_override("font_color", Color(0.88, 0.78, 0.52))
	lbl_prog.size = Vector2(480, 44)
	lbl_prog.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prog_bg.add_child(lbl_prog)

	# Resource inventory row below
	var inv := ColorRect.new()
	inv.name = "InvStrip"
	inv.color = Color(0.06, 0.04, 0.01, 0.85)
	inv.size = Vector2(480, 36)
	inv.position = Vector2(0, 104)
	add_child(inv)
	var x := 8.0
	for r: Dictionary in Constants.RESOURCES:
		var lbl := Label.new()
		lbl.name = "ResLbl_" + str(r.get("id", ""))
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.88, 0.82, 0.58))
		lbl.size = Vector2(74, 36)
		lbl.position = Vector2(x, 2)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		inv.add_child(lbl)
		x += 76.0

func _build_stage_list() -> void:
	var list := Control.new()
	list.name = "StageList"
	list.position = Vector2(0, 148)
	list.size = Vector2(480, 600)
	add_child(list)

	var y := 0.0
	for i in range(Constants.HOME_STAGES.size()):
		var stage_data: Dictionary = Constants.HOME_STAGES[i]
		var card := _build_stage_card(i, stage_data, Vector2(14, y))
		list.add_child(card)
		_stage_cards.append(card)
		y += 120.0

func _build_stage_card(stage_idx: int, stage_data: Dictionary, card_pos: Vector2) -> Control:
	var card := ColorRect.new()
	card.name = "StageCard_%d" % stage_idx
	card.color = Color(0.10, 0.07, 0.03, 0.88)
	card.size = Vector2(452, 112)
	card.position = card_pos

	# Stage number badge
	var badge := ColorRect.new()
	badge.color = Color(0.22, 0.14, 0.06, 1.0)
	badge.size = Vector2(44, 112)
	card.add_child(badge)
	var lbl_num := Label.new()
	lbl_num.text = str(stage_idx + 1)
	lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_num.add_theme_font_size_override("font_size", 22)
	lbl_num.add_theme_color_override("font_color", Color(0.96, 0.84, 0.42))
	lbl_num.size = Vector2(44, 112)
	card.add_child(lbl_num)

	var lbl_name := Label.new()
	lbl_name.text = stage_data.get("name", "Stage " + str(stage_idx + 1))
	lbl_name.add_theme_font_size_override("font_size", 16)
	lbl_name.add_theme_color_override("font_color", Color(0.92, 0.85, 0.58))
	lbl_name.size = Vector2(240, 28)
	lbl_name.position = Vector2(52, 8)
	card.add_child(lbl_name)

	var lbl_desc := Label.new()
	lbl_desc.text = stage_data.get("description", "")
	lbl_desc.add_theme_font_size_override("font_size", 11)
	lbl_desc.add_theme_color_override("font_color", Color(0.75, 0.70, 0.55))
	lbl_desc.size = Vector2(240, 36)
	lbl_desc.position = Vector2(52, 34)
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(lbl_desc)

	var cost: Dictionary = stage_data.get("cost", {})
	var lbl_cost := Label.new()
	lbl_cost.name = "LblCost"
	lbl_cost.text = _build_cost_text(cost)
	lbl_cost.add_theme_font_size_override("font_size", 11)
	lbl_cost.add_theme_color_override("font_color", Color(0.90, 0.75, 0.28))
	lbl_cost.size = Vector2(240, 32)
	lbl_cost.position = Vector2(52, 70)
	lbl_cost.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(lbl_cost)

	var btn_build := Button.new()
	btn_build.name = "BtnBuild"
	btn_build.text = "Build"
	btn_build.custom_minimum_size = Vector2(82, 34)
	btn_build.position = Vector2(360, 66)
	btn_build.pressed.connect(func() -> void: _on_build(stage_idx))
	_style_btn(btn_build, Color(0.42, 0.22, 0.06))
	card.add_child(btn_build)

	var lbl_status := Label.new()
	lbl_status.name = "LblStatus"
	lbl_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_status.add_theme_font_size_override("font_size", 13)
	lbl_status.size = Vector2(90, 36)
	lbl_status.position = Vector2(356, 26)
	card.add_child(lbl_status)

	return card

func _build_status_label() -> void:
	_status_lbl = Label.new()
	_status_lbl.name = "GlobalStatus"
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_font_size_override("font_size", 13)
	_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.65, 0.25))
	_status_lbl.size = Vector2(440, 32)
	_status_lbl.position = Vector2(20, 812)
	_status_lbl.visible = false
	add_child(_status_lbl)

# ─── Refresh ──────────────────────────────────────────────────────────────────

func _refresh() -> void:
	var current_stage: int = SaveManager.get_home_stage()

	# Header coins
	var hdr_coins := find_child("HdrCoins", true, false) as Label
	if hdr_coins != null:
		hdr_coins.text = "🪙 " + str(SaveManager.get_coins())

	# Progress label
	var lbl_prog := find_child("LblProgress", true, false) as Label
	if lbl_prog != null:
		if current_stage >= Constants.HOME_STAGES.size():
			lbl_prog.text = "🏠 Home Complete! All 6 stages built."
		else:
			var stage_name: String = Constants.HOME_STAGES[current_stage].get("name", "")
			lbl_prog.text = "Stage " + str(current_stage + 1) + " / " + str(Constants.HOME_STAGES.size()) + "  →  " + stage_name

	# Resource inventory strip
	var inv := find_child("InvStrip", true, false)
	if inv != null:
		for r: Dictionary in Constants.RESOURCES:
			var res_id: String = r.get("id", "")
			var lbl := inv.find_child("ResLbl_" + res_id, false, false) as Label
			if lbl != null:
				lbl.text = r.get("icon", "?") + " " + str(SaveManager.get_resource(res_id))

	# Per-stage cards
	for i in range(_stage_cards.size()):
		_refresh_stage_card(i, current_stage)

func _refresh_stage_card(stage_idx: int, current_stage: int) -> void:
	var card := _stage_cards[stage_idx] as Control
	if card == null:
		return
	var btn_build := card.find_child("BtnBuild", false, false) as Button
	var lbl_status := card.find_child("LblStatus", false, false) as Label
	if stage_idx < current_stage:
		# Already built
		card.color = Color(0.06, 0.12, 0.04, 0.88)
		if btn_build != null:
			btn_build.visible = false
		if lbl_status != null:
			lbl_status.text = "✓ Built"
			lbl_status.add_theme_color_override("font_color", Color(0.40, 0.88, 0.36))
	elif stage_idx == current_stage:
		# Current buildable stage
		card.color = Color(0.18, 0.12, 0.04, 0.92)
		if btn_build != null:
			btn_build.visible = true
			btn_build.disabled = not _can_afford_stage(stage_idx)
		if lbl_status != null:
			lbl_status.text = ""
	else:
		# Locked future stage
		card.color = Color(0.06, 0.04, 0.02, 0.80)
		if btn_build != null:
			btn_build.visible = false
		if lbl_status != null:
			lbl_status.text = "🔒"
			lbl_status.add_theme_color_override("font_color", Color(0.55, 0.50, 0.40))

# ─── Actions ──────────────────────────────────────────────────────────────────

func _on_build(stage_idx: int) -> void:
	EventBus.play_sfx.emit("button")
	var current := SaveManager.get_home_stage()
	if stage_idx != current:
		_show_status("Build stages in order!")
		return
	if not _can_afford_stage(stage_idx):
		_show_status("Not enough resources.")
		return
	# Spend resources
	var stage_data: Dictionary = Constants.HOME_STAGES[stage_idx]
	var cost: Dictionary = stage_data.get("cost", {})
	for key: String in cost:
		if key == "coins":
			SaveManager.spend_coins(int(cost[key]))
		else:
			SaveManager.spend_resource(key, int(cost[key]))
	SaveManager.set_home_stage(stage_idx + 1)
	if stage_idx + 1 >= Constants.HOME_STAGES.size():
		_show_status("🏠 Home Complete! Congratulations!")
	else:
		_show_status("Stage " + str(stage_idx + 1) + " built! 🎉")
	_refresh()

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

func _on_plus() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_upgrade_shop()

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _art_hit(rect: Rect2) -> Button:
	var btn := Button.new()
	btn.text = ""
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.position = rect.position
	btn.size = rect.size
	btn.custom_minimum_size = rect.size
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("hover", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("focus", empty)
	add_child(btn)
	return btn

func _load_art_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var tex := load(path)
		if tex is Texture2D:
			return tex as Texture2D

	var img := Image.new()
	if img.load(path) == OK:
		return ImageTexture.create_from_image(img)
	return null

func _using_art_plate() -> bool:
	return _home_art_texture != null

func _can_afford_stage(stage_idx: int) -> bool:
	if stage_idx >= Constants.HOME_STAGES.size():
		return false
	var stage_data: Dictionary = Constants.HOME_STAGES[stage_idx]
	var cost: Dictionary = stage_data.get("cost", {})
	for key: String in cost:
		if key == "coins":
			if SaveManager.get_coins() < int(cost[key]):
				return false
		else:
			if SaveManager.get_resource(key) < int(cost[key]):
				return false
	return true

func _build_cost_text(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for key: String in cost:
		var val: int = int(cost[key])
		if key == "coins":
			parts.append("🪙 " + str(val))
		else:
			var info := _find_resource_info(key)
			parts.append(info.get("icon", "?") + " " + str(val) + " " + info.get("name", key))
	return "  ".join(parts)

func _find_resource_info(resource_id: String) -> Dictionary:
	for r: Dictionary in Constants.RESOURCES:
		if r.get("id", "") == resource_id:
			return r
	return { "id": resource_id, "name": resource_id, "icon": "?" }

func _show_status(msg: String) -> void:
	if _status_lbl == null:
		return
	_status_lbl.text = msg
	_status_lbl.visible = true
	get_tree().create_timer(2.6).timeout.connect(func() -> void:
		if _status_lbl != null:
			_status_lbl.visible = false
	)

func _style_btn(btn: Button, col: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	btn.add_theme_stylebox_override("normal", sb)
	var sb_h := sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = col.lightened(0.18)
	btn.add_theme_stylebox_override("hover", sb_h)
	var sb_p := sb.duplicate() as StyleBoxFlat
	sb_p.bg_color = col.darkened(0.18)
	btn.add_theme_stylebox_override("pressed", sb_p)
