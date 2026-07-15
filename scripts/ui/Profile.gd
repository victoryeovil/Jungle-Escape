extends Control

const C_BG    := Color(0.02, 0.05, 0.02, 1.0)
const C_PANEL := Color(0.04, 0.10, 0.04, 0.98)
const C_GOLD  := Color(0.96, 0.82, 0.26)
const C_GREEN := Color(0.52, 0.80, 0.42)
const C_TEXT  := Color(0.90, 0.92, 0.84)
const C_DIM   := Color(0.46, 0.48, 0.40)
const C_RED   := Color(0.90, 0.32, 0.24)

func _ready() -> void:
	for child in get_children():
		child.visible = false
	_build_ui()

# ── Build ─────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	_build_header()
	_build_avatar_strip()
	_build_stats_panel()
	_build_level_history()
	_build_action_buttons()

func _build_header() -> void:
	var hdr := ColorRect.new()
	hdr.color = Color(0.02, 0.06, 0.02, 0.98)
	hdr.size  = Vector2(480, 62)
	add_child(hdr)

	var border := ColorRect.new()
	border.color    = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.75)
	border.size     = Vector2(480, 2)
	border.position = Vector2(0, 62)
	add_child(border)

	var btn_back := Button.new()
	btn_back.text = "←"
	btn_back.custom_minimum_size = Vector2(52, 44)
	btn_back.position = Vector2(8, 9)
	btn_back.flat = true
	btn_back.add_theme_font_size_override("font_size", 22)
	btn_back.add_theme_color_override("font_color", C_GOLD)
	btn_back.pressed.connect(_on_back)
	hdr.add_child(btn_back)

	var lbl := Label.new()
	lbl.text = "👤   PROFILE"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", C_GOLD)
	lbl.size = Vector2(380, 62)
	lbl.position = Vector2(50, 0)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hdr.add_child(lbl)

func _build_avatar_strip() -> void:
	var strip := ColorRect.new()
	strip.color    = Color(0.04, 0.12, 0.04, 0.95)
	strip.size     = Vector2(480, 90)
	strip.position = Vector2(0, 64)
	add_child(strip)

	# Avatar circle
	var name_str: String = GameManager.player_name if not GameManager.player_name.is_empty() else "E"
	var initial: String  = name_str.left(1).to_upper()
	var avatar := ColorRect.new()
	avatar.color    = Color(0.10, 0.36, 0.14)
	avatar.size     = Vector2(66, 66)
	avatar.position = Vector2(14, 12)
	strip.add_child(avatar)
	var av_lbl := Label.new()
	av_lbl.text = initial
	av_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	av_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	av_lbl.add_theme_font_size_override("font_size", 32)
	av_lbl.add_theme_color_override("font_color", C_GOLD)
	av_lbl.size = Vector2(66, 66)
	av_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(av_lbl)

	# Name + status
	var lbl_name := Label.new()
	lbl_name.text = name_str
	lbl_name.add_theme_font_size_override("font_size", 20)
	lbl_name.add_theme_color_override("font_color", C_TEXT)
	lbl_name.size     = Vector2(360, 32)
	lbl_name.position = Vector2(88, 14)
	strip.add_child(lbl_name)

	var status_text := "☁  Cloud Backup Active" if GameManager.is_logged_in else "📱  Playing Locally"
	var status_col  := C_GREEN if GameManager.is_logged_in else C_DIM
	var lbl_status := Label.new()
	lbl_status.text = status_text
	lbl_status.add_theme_font_size_override("font_size", 12)
	lbl_status.add_theme_color_override("font_color", status_col)
	lbl_status.size     = Vector2(360, 22)
	lbl_status.position = Vector2(88, 50)
	strip.add_child(lbl_status)

	# Level badge
	var level_badge := ColorRect.new()
	level_badge.color    = Color(0.18, 0.10, 0.04)
	level_badge.size     = Vector2(72, 66)
	level_badge.position = Vector2(394, 12)
	strip.add_child(level_badge)
	var lv_top := Label.new()
	lv_top.text = "LEVEL"
	lv_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_top.add_theme_font_size_override("font_size", 9)
	lv_top.add_theme_color_override("font_color", C_DIM)
	lv_top.size = Vector2(72, 20); lv_top.position = Vector2(0, 4)
	lv_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_badge.add_child(lv_top)
	var lv_num := Label.new()
	lv_num.text = str(SaveManager.get_current_level())
	lv_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_num.add_theme_font_size_override("font_size", 26)
	lv_num.add_theme_color_override("font_color", C_GOLD)
	lv_num.size = Vector2(72, 40); lv_num.position = Vector2(0, 22)
	lv_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_badge.add_child(lv_num)

func _build_stats_panel() -> void:
	var panel := _mk_panel(Vector2(14, 162), Vector2(452, 148))
	add_child(panel)

	var stats := [
		["🪙", "Coins",          str(SaveManager.get_coins())],
		["💎", "Gems",           str(SaveManager.get_gems())],
		["⭐", "Total Stars",    str(SaveManager.get_total_stars())],
		["🗺", "Levels Done",   str(SaveManager.get_levels_completed_count())],
		["❤", "Lives",          _lives_text()],
		["🔥", "Daily Streak",  str(int(SaveManager.get_setting("daily_streak", 0))) + " days"],
	]

	var col := 0; var row := 0
	for stat in stats:
		var x := 14.0 + col * 226.0
		var y := 12.0 + row * 56.0
		var icon_lbl := Label.new()
		icon_lbl.text = str(stat[0])
		icon_lbl.position = Vector2(x, y + 4)
		icon_lbl.size = Vector2(28, 36)
		icon_lbl.add_theme_font_size_override("font_size", 18)
		icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(icon_lbl)
		var key_lbl := Label.new()
		key_lbl.text = str(stat[1])
		key_lbl.position = Vector2(x + 32, y + 2)
		key_lbl.size = Vector2(100, 18)
		key_lbl.add_theme_font_size_override("font_size", 11)
		key_lbl.add_theme_color_override("font_color", C_DIM)
		key_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(key_lbl)
		var val_lbl := Label.new()
		val_lbl.text = str(stat[2])
		val_lbl.position = Vector2(x + 32, y + 20)
		val_lbl.size = Vector2(150, 26)
		val_lbl.add_theme_font_size_override("font_size", 17)
		val_lbl.add_theme_color_override("font_color", C_TEXT)
		val_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(val_lbl)
		col += 1
		if col >= 2:
			col = 0
			row += 1

func _build_level_history() -> void:
	var header := Label.new()
	header.text = "LEVEL HISTORY"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 10)
	header.add_theme_color_override("font_color", C_GREEN)
	header.size     = Vector2(480, 24)
	header.position = Vector2(0, 320)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(14, 346)
	scroll.size     = Vector2(452, 338)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	scroll.add_child(list)

	var completed := SaveManager.get_completed_levels()
	if completed.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No levels completed yet — get running!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", C_DIM)
		empty_lbl.custom_minimum_size = Vector2(452, 60)
		list.add_child(empty_lbl)
	else:
		for lvl_id in completed:
			var row := _mk_history_row(int(lvl_id))
			list.add_child(row)

func _mk_history_row(lvl_id: int) -> Control:
	var row := ColorRect.new()
	row.color = Color(0.04, 0.09, 0.03, 0.85)
	row.custom_minimum_size = Vector2(452, 44)

	var lbl_lvl := Label.new()
	lbl_lvl.text = "Level " + str(lvl_id)
	lbl_lvl.add_theme_font_size_override("font_size", 14)
	lbl_lvl.add_theme_color_override("font_color", C_TEXT)
	lbl_lvl.size     = Vector2(160, 44)
	lbl_lvl.position = Vector2(12, 0)
	lbl_lvl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_lvl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lbl_lvl)

	var stars: int = SaveManager.get_stars(lvl_id)
	var lbl_stars := Label.new()
	lbl_stars.text = "★".repeat(stars) + "☆".repeat(3 - stars)
	lbl_stars.add_theme_font_size_override("font_size", 16)
	lbl_stars.add_theme_color_override("font_color", C_GOLD)
	lbl_stars.size     = Vector2(120, 44)
	lbl_stars.position = Vector2(300, 0)
	lbl_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_stars.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl_stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lbl_stars)

	return row

func _build_action_buttons() -> void:
	var y := 692.0
	var w := 218.0

	# Share
	var btn_share := _mk_btn("Share Progress", Vector2(14, y), Vector2(w, 46))
	btn_share.pressed.connect(_on_share)
	add_child(btn_share)

	# Logout / Login
	if GameManager.is_logged_in:
		var btn_out := _mk_btn("Sign Out", Vector2(248, y), Vector2(w, 46), true)
		btn_out.pressed.connect(_on_logout)
		add_child(btn_out)
	else:
		var btn_in := _mk_btn("Sign In", Vector2(248, y), Vector2(w, 46))
		btn_in.pressed.connect(func() -> void:
			get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")
		)
		add_child(btn_in)

# ── Handlers ──────────────────────────────────────────────────────────────────

func _on_share() -> void:
	EventBus.play_sfx.emit("button")
	var completed := SaveManager.get_levels_completed_count()
	var stars     := SaveManager.get_total_stars()
	var streak    := int(SaveManager.get_setting("daily_streak", 0))
	var msg := "I've completed %d levels with %d ⭐ on Jungle Escape: Lost Path! 🌿 Daily streak: %d days. Can you beat me?" % [completed, stars, streak]
	DisplayServer.clipboard_set(msg)
	_show_toast("Copied to clipboard! 📋")

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

func _on_logout() -> void:
	EventBus.play_sfx.emit("button")
	SupabaseClient.sign_out()
	GameManager.is_logged_in = false
	GameManager.is_guest     = true
	GameManager.player_name  = "Explorer"
	GameManager.go_to_menu()

# ── Helpers ───────────────────────────────────────────────────────────────────

func _lives_text() -> String:
	if not SaveManager.is_lives_system_active():
		return "∞"
	return str(SaveManager.get_lives()) + " / " + str(SaveManager.MAX_EXPEDITION_LIVES)

func _mk_panel(pos: Vector2, sz: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos; p.size = sz
	var sb := StyleBoxFlat.new()
	sb.bg_color     = C_PANEL
	sb.border_color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.40)
	sb.border_width_left  = 1; sb.border_width_right  = 1
	sb.border_width_top   = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left     = 8; sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8; sb.corner_radius_bottom_right = 8
	p.add_theme_stylebox_override("panel", sb)
	return p

func _mk_btn(text: String, pos: Vector2, sz: Vector2, danger: bool = false) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.position = pos
	btn.custom_minimum_size = sz
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 15)
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.24, 0.07, 0.05, 0.92) if danger else Color(0.06, 0.12, 0.04, 0.92)
	sb.border_color = Color(0.76, 0.22, 0.14) if danger else Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.85)
	sb.border_width_left  = 2; sb.border_width_right  = 2
	sb.border_width_top   = 2; sb.border_width_bottom = 2
	sb.corner_radius_top_left     = 8; sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8; sb.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	var sbh := sb.duplicate() as StyleBoxFlat
	sbh.bg_color = sb.bg_color.lightened(0.10)
	btn.add_theme_stylebox_override("hover", sbh)
	btn.add_theme_color_override("font_color", C_RED if danger else C_GOLD)
	return btn

func _show_toast(msg: String) -> void:
	var toast := Label.new()
	toast.text = msg
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_font_size_override("font_size", 13)
	toast.add_theme_color_override("font_color", C_TEXT)
	toast.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	toast.add_theme_constant_override("shadow_offset_x", 1)
	toast.add_theme_constant_override("shadow_offset_y", 1)
	toast.size     = Vector2(480, 44)
	toast.position = Vector2(0, 396)
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast)
	get_tree().create_timer(2.5).timeout.connect(func():
		if is_instance_valid(toast): toast.queue_free()
	)
