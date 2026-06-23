extends Control

const SHOP_ART_PATH := "res://assets/backgrounds/bg_choose_explorer.png"

@onready var lbl_coins: Label    = $Header/LblCoins
@onready var lbl_gems: Label     = $Header/LblGems
@onready var tab_skins: TabBar   = $TabBar
@onready var list_container: VBoxContainer = $ScrollContainer/List
@onready var btn_back: Button    = $Header/BtnBack
@onready var lbl_hints: Label    = $HintRow/LblHints
@onready var btn_buy_hints: Button = $HintRow/BtnBuyHints

var _shop_particles: Array = []
var _campfire_glow: ColorRect = null
var _shop_time: float = 0.0
var _shop_art_texture: Texture2D = null
var _selected_badge: Control = null
var _gate_badges: Array[Control] = []
var _status_lbl: Label = null
var _preview_panel: Control = null
var _preview_skin_id: String = ""

func _ready() -> void:
	_shop_art_texture = _load_art_texture(SHOP_ART_PATH)
	if _using_art_plate():
		_hide_scene_controls()
		_build_art_plate()
		queue_redraw()
		return
	_add_jungle_background()
	UIStyle.apply(self)
	btn_back.pressed.connect(_on_back)
	btn_buy_hints.pressed.connect(_on_buy_hints)
	_refresh_header()
	_build_skin_list()

func _add_jungle_background() -> void:
	var bg_base := get_node_or_null("Background") as ColorRect
	if bg_base:
		bg_base.color = Color(0.04, 0.12, 0.05, 1.0)

	var layers := Control.new()
	layers.name = "JungleLayers"
	layers.set_anchors_preset(Control.PRESET_FULL_RECT)
	layers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layers)
	move_child(layers, 1)

	var mid := ColorRect.new()
	mid.color = Color(0.03, 0.11, 0.04, 0.75)
	mid.set_anchors_preset(Control.PRESET_FULL_RECT)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layers.add_child(mid)

	var tree_data := [
		[15.0, 140.0, 52.0, 310.0],
		[68.0, 160.0, 38.0, 285.0],
		[395.0, 155.0, 46.0, 320.0],
		[430.0, 170.0, 36.0, 270.0],
		[0.0, 200.0, 30.0, 350.0],
		[455.0, 210.0, 25.0, 280.0],
	]
	for td in tree_data:
		var t := ColorRect.new()
		t.color = Color(0.03, 0.09, 0.03, 0.82)
		t.position = Vector2(td[0], td[1])
		t.size = Vector2(td[2], td[3])
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layers.add_child(t)

	var fire_root := Control.new()
	fire_root.name = "Campfire"
	fire_root.position = Vector2(215.0, 630.0)
	fire_root.size = Vector2(50.0, 40.0)
	fire_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layers.add_child(fire_root)

	_campfire_glow = ColorRect.new()
	_campfire_glow.color = Color(1.0, 0.48, 0.08, 0.22)
	_campfire_glow.position = Vector2(-30.0, -22.0)
	_campfire_glow.size = Vector2(110.0, 72.0)
	_campfire_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fire_root.add_child(_campfire_glow)

	var flame := ColorRect.new()
	flame.color = Color(1.0, 0.55, 0.10, 0.80)
	flame.position = Vector2(10.0, 4.0)
	flame.size = Vector2(30.0, 22.0)
	flame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fire_root.add_child(flame)

	var rng := RandomNumberGenerator.new()
	for i in range(18):
		rng.seed = i * 211 + 7
		var is_firefly := i < 7
		var dot := ColorRect.new()
		var sz := rng.randf_range(2.5, 6.5)
		dot.size = Vector2(sz, sz)
		dot.color = Color(
			rng.randf_range(0.55, 0.95) if is_firefly else rng.randf_range(0.12, 0.45),
			rng.randf_range(0.75, 1.00) if is_firefly else rng.randf_range(0.50, 0.82),
			rng.randf_range(0.10, 0.35) if is_firefly else rng.randf_range(0.08, 0.28),
			rng.randf_range(0.55, 0.92)
		)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layers.add_child(dot)
		_shop_particles.append({
			"node": dot,
			"x": rng.randf_range(0.0, 480.0),
			"y": rng.randf_range(180.0, 854.0),
			"vy": rng.randf_range(-20.0, -6.0),
			"vx": rng.randf_range(-4.0, 4.0),
			"phase": rng.randf_range(0.0, PI * 2.0),
			"wave": rng.randf_range(0.3, 0.8),
			"is_firefly": is_firefly
		})

func _draw() -> void:
	if _using_art_plate():
		var draw_size := size
		if draw_size.x <= 0.0 or draw_size.y <= 0.0:
			draw_size = get_viewport_rect().size
		draw_texture_rect(_shop_art_texture, Rect2(Vector2.ZERO, draw_size), false)

func _build_art_plate() -> void:
	_art_hit(Rect2(10, 10, 58, 44)).pressed.connect(_on_back)
	_art_hit(Rect2(430, 12, 42, 42)).pressed.connect(_on_art_plus)
	_art_hit(Rect2(430, 61, 42, 42)).pressed.connect(_on_art_plus)

	var skin_ids := ["explorer", "jungle_girl", "monkey", "robot", "treasure", "tribal", "golden"]
	var row_ys := [94.0, 187.0, 280.0, 373.0, 466.0, 559.0, 652.0]
	for i in range(skin_ids.size()):
		_art_hit(Rect2(8, row_ys[i], 160, 84)).pressed.connect(_on_art_skin_pressed.bind(skin_ids[i]))

	_art_hit(Rect2(114, 772, 252, 62)).pressed.connect(_on_art_explore)
	_build_status_label()
	_refresh_art_overlays()

func _process(delta: float) -> void:
	if _using_art_plate():
		return
	_shop_time += delta
	_animate_shop_bg(delta)

func _animate_shop_bg(delta: float) -> void:
	if is_instance_valid(_campfire_glow):
		_campfire_glow.color.a = 0.15 + sin(_shop_time * 7.0) * 0.08
	for item in _shop_particles:
		var node := item["node"] as ColorRect
		if not is_instance_valid(node):
			continue
		item["y"] = (item["y"] as float) + (item["vy"] as float) * delta
		item["x"] = (item["x"] as float) + (item["vx"] as float) * delta + sin(_shop_time * (item["wave"] as float) + (item["phase"] as float)) * 10.0 * delta
		if (item["y"] as float) < 150.0:
			item["y"] = randf_range(700.0, 870.0)
			item["x"] = randf_range(0.0, 480.0)
		node.position = Vector2(item["x"], item["y"])
		if item["is_firefly"]:
			node.color.a = 0.35 + sin(_shop_time * 2.5 + (item["phase"] as float)) * 0.45

func _refresh_header() -> void:
	lbl_coins.text = str(SaveManager.get_coins()) + " coins"
	lbl_gems.text  = str(SaveManager.get_gems()) + " gems"
	lbl_hints.text = "Hints: " + str(SaveManager.get_hints())

func _build_skin_list() -> void:
	for child in list_container.get_children():
		child.queue_free()

	for skin in Constants.SKINS:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 64)

		var preview := TextureRect.new()
		preview.custom_minimum_size = Vector2(56, 56)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		preview.clip_contents = true
		preview.texture = _load_art_texture(str(skin.get("preview_path", "")))
		row.add_child(preview)

		var lbl := Label.new()
		lbl.text = skin["name"]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var unlocked := SaveManager.is_skin_unlocked(skin["id"])
		if unlocked:
			var btn_equip := Button.new()
			btn_equip.text     = "Equip" if SaveManager.get_selected_skin() != skin["id"] else "✓ On"
			btn_equip.disabled = SaveManager.get_selected_skin() == skin["id"]
			btn_equip.pressed.connect(_equip_skin.bind(skin["id"]))
			btn_equip.custom_minimum_size = Vector2(64, 0)
			row.add_child(btn_equip)
			var btn_info := Button.new()
			btn_info.text     = "Info"
			btn_info.pressed.connect(_show_skin_preview.bind(skin))
			btn_info.custom_minimum_size = Vector2(52, 0)
			row.add_child(btn_info)
		else:
			var btn_prev := Button.new()
			btn_prev.text = "Preview"
			btn_prev.pressed.connect(_show_skin_preview.bind(skin))
			row.add_child(btn_prev)
		list_container.add_child(row)
	UIStyle.apply(list_container)

func _equip_skin(skin_id: String) -> void:
	EventBus.play_sfx.emit("button")
	if not SaveManager.is_skin_unlocked(skin_id):
		_show_status("This explorer is not unlocked yet.")
		return
	SaveManager.set_selected_skin(skin_id)
	var skin := _find_skin(skin_id)
	var skin_name: String = str(skin.get("name", skin_id)) if not skin.is_empty() else skin_id
	_show_status(str(skin_name) + " equipped.")
	_refresh_shop_state()

func _buy_skin(skin: Dictionary) -> bool:
	EventBus.play_sfx.emit("button")
	if skin.is_empty():
		return false

	var skin_id: String = skin.get("id", "")
	if SaveManager.is_skin_unlocked(skin_id):
		SaveManager.set_selected_skin(skin_id)
		_refresh_shop_state()
		return true
	if not _meets_level_requirement(skin):
		_show_status(_level_requirement_text(skin))
		return false
	if skin.get("unlock_method", "") == "stars" and SaveManager.get_total_stars() < int(skin.get("unlock_stars", 0)):
		_show_status(str(skin.get("unlock_stars", 0)) + " stars needed.")
		return false

	var bought := false
	if int(skin.get("cost_coins", 0)) > 0:
		bought = SaveManager.spend_coins(int(skin.get("cost_coins", 0)))
	elif int(skin.get("cost_gems", 0)) > 0 and SaveManager.get_gems() >= int(skin.get("cost_gems", 0)):
		SaveManager.add_gems(-int(skin.get("cost_gems", 0)))
		bought = true
	elif skin.get("unlock_method", "") == "default" or skin.get("unlock_method", "") == "stars":
		bought = true

	if not bought:
		_show_status("Not enough currency.")
		return false

	SaveManager.unlock_skin(skin_id)
	SaveManager.set_selected_skin(skin_id)
	_show_status(str(skin.get("name", skin_id)) + " unlocked and equipped.")
	_hide_skin_preview()
	_refresh_shop_state()
	return true

func _on_buy_hints() -> void:
	EventBus.play_sfx.emit("button")
	if SaveManager.spend_coins(Constants.HINT_COIN_COST):
		SaveManager.add_hints(1)
		_refresh_header()

func _on_art_plus() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_upgrade_shop()

func _on_art_explore() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

func _on_art_skin_pressed(skin_id: String) -> void:
	var skin := _find_skin(skin_id)
	if skin.is_empty():
		return
	_show_skin_preview(skin)

func _show_skin_preview(skin: Dictionary) -> void:
	if skin.is_empty():
		return
	if _preview_panel == null:
		_build_preview_panel()
	_preview_skin_id = skin.get("id", "")
	var unlocked := SaveManager.is_skin_unlocked(_preview_skin_id)
	var title  := _preview_panel.get_node("Title")     as Label
	var req    := _preview_panel.get_node("Req")       as Label
	var action := _preview_panel.get_node("BtnAction") as Button

	# Portrait
	var portrait := _preview_panel.get_node("CharPortrait") as TextureRect
	if portrait != null:
		var tex_path := str(skin.get("preview_path", ""))
		portrait.texture = _load_art_texture(tex_path)
		if portrait.texture == null:
			push_warning("Shop: could not load character preview: " + tex_path)

	title.text = str(skin.get("name", "Explorer"))

	# Stats dots
	var stats: Dictionary = skin.get("stats", {})
	var speed   := int(stats.get("speed",   3))
	var agility := int(stats.get("agility", 3))
	(_preview_panel.get_node("StatsDots0") as Label).text = _stat_dots(speed)
	(_preview_panel.get_node("StatsDots1") as Label).text = _stat_dots(agility)

	# Special ability
	(_preview_panel.get_node("Special") as Label).text = str(skin.get("special", ""))

	# Lore
	(_preview_panel.get_node("Lore") as Label).text = str(skin.get("lore", ""))

	# Color variant swatches
	var variant_row := _preview_panel.get_node("VariantRow") as HBoxContainer
	for child in variant_row.get_children():
		child.queue_free()
	var selected_variant := SaveManager.get_selected_skin_variant(_preview_skin_id)
	var variants: Array = skin.get("color_variants", [])
	for v: Dictionary in variants:
		var vid    := str(v.get("id", "default"))
		var vname  := str(v.get("name", "Default"))
		var vcolor: Color = v.get("modulate", Color.WHITE)
		var is_sel := (vid == selected_variant)
		var sw := Button.new()
		sw.custom_minimum_size = Vector2(44, 44)
		sw.focus_mode = Control.FOCUS_NONE
		sw.tooltip_text = vname
		sw.text = ""
		var sw_sb := StyleBoxFlat.new()
		sw_sb.bg_color = vcolor if vcolor != Color.WHITE else Color(0.58, 0.48, 0.28)
		sw_sb.corner_radius_top_left    = 22; sw_sb.corner_radius_top_right    = 22
		sw_sb.corner_radius_bottom_left = 22; sw_sb.corner_radius_bottom_right = 22
		sw_sb.border_width_left  = 3 if is_sel else 1
		sw_sb.border_width_right = 3 if is_sel else 1
		sw_sb.border_width_top   = 3 if is_sel else 1
		sw_sb.border_width_bottom = 3 if is_sel else 1
		sw_sb.border_color = Color.WHITE if is_sel else Color(0.42, 0.36, 0.18, 0.80)
		sw.add_theme_stylebox_override("normal",  sw_sb)
		sw.add_theme_stylebox_override("pressed", sw_sb)
		if unlocked:
			sw.pressed.connect(func() -> void:
				SaveManager.set_selected_skin_variant(_preview_skin_id, vid)
				_show_skin_preview(skin)
			)
		else:
			sw.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		variant_row.add_child(sw)

	# Req / cost / action
	if unlocked:
		req.text    = "✓  Unlocked"
		action.text = "▶  Equip"
	elif not _meets_level_requirement(skin):
		req.text    = _level_requirement_text(skin)
		action.text = "🔒  Locked"
	elif skin.get("unlock_method", "") == "stars" and SaveManager.get_total_stars() < int(skin.get("unlock_stars", 0)):
		req.text    = str(skin.get("unlock_stars", 0)) + " stars needed"
		action.text = "🔒  Locked"
	else:
		req.text    = "Cost: " + _cost_text(skin)
		action.text = "Buy  ▶"
	_preview_panel.visible = true

func _stat_dots(value: int) -> String:
	var out := ""
	for i in 5:
		out += ("■" if i < value else "□") + (" " if i < 4 else "")
	return out

func _build_preview_panel() -> void:
	_preview_panel = Panel.new()
	_preview_panel.name     = "SkinPreview"
	_preview_panel.position = Vector2(16, 78)
	_preview_panel.size     = Vector2(448, 640)
	var sb := StyleBoxFlat.new()
	sb.bg_color            = Color(0.02, 0.06, 0.03, 0.97)
	sb.border_color        = Color(0.82, 0.62, 0.18, 0.96)
	sb.border_width_left   = 2; sb.border_width_right  = 2
	sb.border_width_top    = 2; sb.border_width_bottom = 2
	sb.corner_radius_top_left     = 10; sb.corner_radius_top_right    = 10
	sb.corner_radius_bottom_left  = 10; sb.corner_radius_bottom_right = 10
	_preview_panel.add_theme_stylebox_override("panel", sb)
	add_child(_preview_panel)

	# Character portrait (reduced height to make room for stats)
	var portrait := TextureRect.new()
	portrait.name             = "CharPortrait"
	portrait.position         = Vector2(10, 10)
	portrait.size             = Vector2(428, 290)
	portrait.expand_mode      = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode     = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.clip_contents    = true
	portrait.mouse_filter     = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(portrait)

	# Dark gradient on portrait bottom for name readability
	var grad := ColorRect.new()
	grad.color        = Color(0.02, 0.04, 0.02, 0.82)
	grad.position     = Vector2(10, 254)
	grad.size         = Vector2(428, 46)
	grad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(grad)

	# Character name overlaid on gradient
	var title := _preview_label("Title", Vector2(20, 260), Vector2(408, 36), 24, Color(0.98, 0.86, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Unlock requirement / cost
	var req := _preview_label("Req", Vector2(20, 308), Vector2(408, 22), 13, Color(0.70, 0.92, 0.58))
	req.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# ── Stats rows ──────────────────────────────────────────────────────────────
	var stats_lbl := _preview_label("StatsSpeed", Vector2(20, 338), Vector2(90, 18), 11, Color(0.70, 0.92, 0.58))
	stats_lbl.text = "Speed:"
	_preview_label("StatsDots0", Vector2(116, 338), Vector2(200, 18), 12, Color(0.92, 0.74, 0.22))  # filled by _show_skin_preview
	_preview_label("StatsAgility", Vector2(20, 362), Vector2(90, 18), 11, Color(0.70, 0.92, 0.58)).text = "Agility:"
	_preview_label("StatsDots1", Vector2(116, 362), Vector2(200, 18), 12, Color(0.92, 0.74, 0.22))

	# Special ability
	var spec := _preview_label("Special", Vector2(20, 392), Vector2(408, 20), 12, Color(0.62, 0.84, 0.98))
	spec.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# ── Color variants ──────────────────────────────────────────────────────────
	var vstyle_lbl := _preview_label("VariantLabel", Vector2(20, 420), Vector2(100, 18), 11, Color(0.70, 0.92, 0.58))
	vstyle_lbl.text = "Style:"

	var variant_row := HBoxContainer.new()
	variant_row.name     = "VariantRow"
	variant_row.position = Vector2(20, 440)
	variant_row.size     = Vector2(408, 44)
	variant_row.add_theme_constant_override("separation", 14)
	_preview_panel.add_child(variant_row)

	# Lore text
	var lore := _preview_label("Lore", Vector2(20, 490), Vector2(408, 38), 11, Color(0.62, 0.62, 0.54))
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Action + Close buttons
	var action := Button.new()
	action.name                = "BtnAction"
	action.position            = Vector2(20, 540)
	action.size                = Vector2(195, 52)
	action.custom_minimum_size = Vector2(195, 52)
	action.add_theme_font_size_override("font_size", 17)
	action.pressed.connect(_on_preview_action)
	_style_preview_button(action, Color(0.10, 0.42, 0.18))
	_preview_panel.add_child(action)

	var close := Button.new()
	close.name                 = "BtnClose"
	close.text                 = "✕  Close"
	close.position             = Vector2(228, 540)
	close.size                 = Vector2(200, 52)
	close.custom_minimum_size  = Vector2(200, 52)
	close.add_theme_font_size_override("font_size", 17)
	close.pressed.connect(_hide_skin_preview)
	_style_preview_button(close, Color(0.28, 0.18, 0.06))
	_preview_panel.add_child(close)
	_preview_panel.visible = false

func _preview_label(node_name: String, pos: Vector2, label_size: Vector2, font_size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.name = node_name
	lbl.position = pos
	lbl.size = label_size
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	_preview_panel.add_child(lbl)
	return lbl

func _style_preview_button(btn: Button, col: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.border_color = Color(0.84, 0.68, 0.24, 0.95)
	sb.border_width_left = 1; sb.border_width_right = 1
	sb.border_width_top = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", sb)
	var sb_h := sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = col.lightened(0.18)
	btn.add_theme_stylebox_override("hover", sb_h)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", Color(0.98, 0.90, 0.62))

func _on_preview_action() -> void:
	var skin := _find_skin(_preview_skin_id)
	if skin.is_empty():
		return
	if SaveManager.is_skin_unlocked(_preview_skin_id):
		_hide_skin_preview()
		_equip_skin(_preview_skin_id)
	else:
		_buy_skin(skin)

func _hide_skin_preview() -> void:
	if _preview_panel != null:
		_preview_panel.visible = false

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

func _build_status_label() -> void:
	_status_lbl = Label.new()
	_status_lbl.name = "ShopStatus"
	_status_lbl.position = Vector2(28, 738)
	_status_lbl.size = Vector2(424, 28)
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_font_size_override("font_size", 14)
	_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.42))
	_status_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_status_lbl.add_theme_constant_override("shadow_offset_x", 1)
	_status_lbl.add_theme_constant_override("shadow_offset_y", 1)
	_status_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status_lbl.visible = false
	add_child(_status_lbl)

func _show_status(message: String) -> void:
	if _status_lbl == null:
		_build_status_label()
	_status_lbl.text = message
	_status_lbl.visible = true
	get_tree().create_timer(2.2).timeout.connect(func() -> void:
		if _status_lbl != null:
			_status_lbl.visible = false
	)

func _refresh_shop_state() -> void:
	if _using_art_plate():
		_refresh_art_overlays()
	else:
		_refresh_header()
		_build_skin_list()

func _refresh_art_overlays() -> void:
	if is_instance_valid(_selected_badge):
		_selected_badge.queue_free()
	_selected_badge = null
	for badge in _gate_badges:
		if is_instance_valid(badge):
			badge.queue_free()
	_gate_badges.clear()

	var skin_ids := ["explorer", "jungle_girl", "monkey", "robot", "treasure", "tribal", "golden"]
	var button_ys := [140.0, 233.0, 326.0, 419.0, 512.0, 604.0, 696.0]
	var selected_idx := skin_ids.find(SaveManager.get_selected_skin())
	if selected_idx >= 0:
		_selected_badge = _overlay_pill(Rect2(94, button_ys[selected_idx], 72, 33), "Equipped", Color(0.05, 0.36, 0.16), Color(0.32, 0.95, 0.48))

	for i in range(skin_ids.size()):
		var skin := _find_skin(skin_ids[i])
		if skin.is_empty() or SaveManager.is_skin_unlocked(skin_ids[i]):
			continue
		if not _meets_level_requirement(skin):
			_gate_badges.append(_overlay_pill(Rect2(94, button_ys[i], 72, 33), "Lvl " + str(skin.get("available_after_level", 0)), Color(0.14, 0.12, 0.08), Color(0.88, 0.70, 0.28)))

func _overlay_pill(rect: Rect2, text: String, bg_color: Color, border_color: Color) -> Control:
	var pill := Panel.new()
	pill.position = rect.position
	pill.size = rect.size
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.border_width_left = 1; sb.border_width_right = 1
	sb.border_width_top = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	pill.add_theme_stylebox_override("panel", sb)
	add_child(pill)

	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.98, 0.92, 0.62))
	lbl.size = rect.size
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(lbl)
	return pill

func _meets_level_requirement(skin: Dictionary) -> bool:
	var required := int(skin.get("available_after_level", 0))
	return required <= 0 or SaveManager.get_current_level() > required or SaveManager.is_level_completed(required)

func _level_requirement_text(skin: Dictionary) -> String:
	var required := int(skin.get("available_after_level", 0))
	if required <= 0:
		return "Available now."
	return "Complete Level " + str(required) + " to unlock this explorer."

func _cost_text(skin: Dictionary) -> String:
	if int(skin.get("cost_coins", 0)) > 0:
		return str(skin.get("cost_coins", 0)) + " coins"
	if int(skin.get("cost_gems", 0)) > 0:
		return str(skin.get("cost_gems", 0)) + " gems"
	if skin.get("unlock_method", "") == "stars":
		return str(skin.get("unlock_stars", 0)) + " stars"
	return "Free"

func _skin_preview_desc(skin_id: String) -> String:
	match skin_id:
		"explorer":
			return "Balanced explorer. A reliable choice for every jungle route."
		"jungle_girl":
			return "Fast and focused. Great for narrow paths and quick reactions."
		"monkey":
			return "Quick, curious, and agile. Built for fast jungle movement."
		"robot":
			return "Scans hazards and keeps steady through tricky ruins."
		"treasure":
			return "Finds extra rewards and makes coin routes more valuable."
		"tribal":
			return "Strong survival instincts for deeper jungle chapters."
		"golden":
			return "Prestige explorer for players who master the early worlds."
		_:
			return "Preview this explorer before adding them to your team."

func _hide_scene_controls() -> void:
	for node_name in ["Background", "Header", "TabBar", "HintRow", "ScrollContainer"]:
		var n := get_node_or_null(node_name) as CanvasItem
		if n != null:
			n.visible = false

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
	return _shop_art_texture != null

func _find_skin(skin_id: String) -> Dictionary:
	return Constants.get_skin(skin_id)
