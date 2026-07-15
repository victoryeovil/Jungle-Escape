extends Control

const _BG_TEX          := "res://assets/backgrounds/bg_main_menu.png"
const _LEVEL_SELECT    := "res://scenes/menus/LevelSelect.tscn"
const H                := 64.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	_build_background()
	_build_top_bar()
	_build_title()
	_build_buttons()
	_build_version()
	EventBus.play_music.emit("menu")
	print("[NAV][MainMenu] ready; scene_file_path=" + scene_file_path)

# ── BACKGROUND ───────────────────────────────────────────────────────────────

func _build_background() -> void:
	if ResourceLoader.exists(_BG_TEX):
		var bg := TextureRect.new()
		bg.name = "Background"
		bg.texture = load(_BG_TEX)
		bg.stretch_mode = TextureRect.STRETCH_SCALE
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
	else:
		var bg := ColorRect.new()
		bg.name = "Background"
		bg.color = Color(0.04, 0.10, 0.03)
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
	# Darkening overlay so text stays readable regardless of image brightness
	var ov := ColorRect.new()
	ov.color = Color(0.0, 0.0, 0.0, 0.42)
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ov)

# ── TOP BAR ──────────────────────────────────────────────────────────────────

func _build_top_bar() -> void:
	var hdr := ColorRect.new()
	hdr.color = Color(0.02, 0.04, 0.01, 0.92)
	hdr.size = Vector2(480, 60)
	hdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hdr)

	var coins_lbl := Label.new()
	coins_lbl.name = "LblCoins"
	coins_lbl.text = "🪙  " + str(SaveManager.get_coins())
	coins_lbl.add_theme_font_size_override("font_size", 16)
	coins_lbl.add_theme_color_override("font_color", Color(1.00, 0.88, 0.24))
	coins_lbl.size = Vector2(130, 36)
	coins_lbl.position = Vector2(12, 12)
	coins_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(coins_lbl)

	var gems_lbl := Label.new()
	gems_lbl.name = "LblGems"
	gems_lbl.text = "💎  " + str(SaveManager.get_gems())
	gems_lbl.add_theme_font_size_override("font_size", 16)
	gems_lbl.add_theme_color_override("font_color", Color(0.48, 0.84, 1.00))
	gems_lbl.size = Vector2(120, 36)
	gems_lbl.position = Vector2(154, 12)
	gems_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gems_lbl)

	if SaveManager.should_show_lives():
		var lives_lbl := Label.new()
		lives_lbl.name = "LblLives"
		lives_lbl.text = "LIFE  " + SaveManager.get_lives_display()
		lives_lbl.add_theme_font_size_override("font_size", 15)
		lives_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.36))
		lives_lbl.size = Vector2(176, 36)
		lives_lbl.position = Vector2(286, 12)
		lives_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(lives_lbl)

	# Gold separator
	var sep := ColorRect.new()
	sep.color = Color(0.60, 0.48, 0.14, 0.72)
	sep.size = Vector2(480, 2)
	sep.position = Vector2(0, 60)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sep)

# ── TITLE ────────────────────────────────────────────────────────────────────

func _build_title() -> void:
	# Translucent title panel
	var panel := ColorRect.new()
	panel.color = Color(0.0, 0.0, 0.0, 0.28)
	panel.size = Vector2(480, 198)
	panel.position = Vector2(0, 78)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	# Leaf accent lines either side of title
	var _l := _cr(Vector2(20, 104), Vector2(60, 2), Color(0.56, 0.44, 0.12, 0.60))
	var _r := _cr(Vector2(400, 104), Vector2(60, 2), Color(0.56, 0.44, 0.12, 0.60))

	_lbl("JUNGLE ESCAPE",
		Vector2(0, 90), Vector2(480, 60), 42,
		Color(0.96, 0.82, 0.24), 3)

	_lbl("·   LOST PATH   ·",
		Vector2(0, 152), Vector2(480, 30), 19,
		Color(0.78, 0.64, 0.20), 1)

	_lbl("☀",
		Vector2(0, 186), Vector2(480, 26), 17,
		Color(0.94, 0.76, 0.20, 0.80), 0)

	_lbl("The Temple of the First Sun awaits...",
		Vector2(0, 218), Vector2(480, 22), 13,
		Color(0.82, 0.92, 0.60, 0.68), 0)

# ── BUTTONS ──────────────────────────────────────────────────────────────────

func _build_buttons() -> void:
	var y := 262.0
	const GAP := 11.0

	_nav_btn("BtnPlay",            "✦   BEGIN JOURNEY",         y, _on_play);           y += H + GAP
	_nav_btn("BtnContinue",        "›   CONTINUE EXPEDITION",   y, _on_continue);        y += H + GAP
	_nav_btn("BtnShop",            "◎   CHOOSE EXPLORER",       y, _on_shop);            y += H + GAP
	_nav_btn("BtnDaily",           "☀   DAILY EXPEDITION",      y, _on_daily_challenge); y += H + GAP
	_nav_btn("BtnLogin",           "◉   LOG IN",                y, _on_login);           y += H + GAP

	# Show "Your Land" only after Level 5 is beaten
	if SaveManager.get_stars(5) > 0:
		_nav_btn("BtnHome", "🏠   YOUR LAND", y, _on_home_building); y += H + GAP

	# Settings — smaller, muted style
	_nav_btn("BtnSettings", "⚙   SETTINGS", y, _on_settings, true)

func _nav_btn(node_name: String, label: String, y: float,
		callback: Callable, small: bool = false) -> Button:
	var btn := Button.new()
	btn.name  = node_name
	btn.text  = label
	var h: float = 48.0 if small else H
	btn.custom_minimum_size = Vector2(444, h)
	btn.position = Vector2(18, y)
	btn.add_theme_font_size_override("font_size", 14 if small else 17)
	btn.pressed.connect(callback)
	_style_btn(btn, small)
	add_child(btn)
	return btn

func _style_btn(btn: Button, small: bool = false) -> void:
	var alpha: float = 0.72 if small else 0.88
	var sb := StyleBoxFlat.new()
	sb.bg_color        = Color(0.03, 0.07, 0.02, alpha)
	sb.border_width_left   = 2; sb.border_width_right  = 2
	sb.border_width_top    = 2; sb.border_width_bottom = 2
	sb.border_color    = Color(0.60, 0.48, 0.16, 0.80 if small else 1.00)
	sb.corner_radius_top_left     = 8; sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8; sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 18.0; sb.content_margin_right = 18.0
	btn.add_theme_stylebox_override("normal", sb)

	var sbh := sb.duplicate() as StyleBoxFlat
	sbh.bg_color     = Color(0.08, 0.16, 0.05, 0.95)
	sbh.border_color = Color(0.90, 0.74, 0.22)
	btn.add_theme_stylebox_override("hover", sbh)

	var sbp := sb.duplicate() as StyleBoxFlat
	sbp.bg_color = Color(0.12, 0.22, 0.08, 0.98)
	btn.add_theme_stylebox_override("pressed", sbp)

	var text_col: Color = Color(0.80, 0.76, 0.60) if small else Color(0.96, 0.90, 0.70)
	btn.add_theme_color_override("font_color", text_col)

# ── VERSION LABEL ────────────────────────────────────────────────────────────

func _build_version() -> void:
	var lbl := Label.new()
	lbl.text = "v0.1.0 MVP"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.44, 0.44, 0.38, 0.65))
	lbl.size = Vector2(160, 20)
	lbl.position = Vector2(308, 830)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)

# ── NAVIGATION ───────────────────────────────────────────────────────────────

func _on_play() -> void:
	print("[NAV][MainMenu] Play signal received from pressed; navigation_pending=false")
	print("[NAV][MainMenu] Play accepted; deferred open_level_select queued")
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	if not ResourceLoader.exists(_LEVEL_SELECT):
		push_error("MainMenu: LevelSelect.tscn missing")
		return
	print("[NAV][MainMenu] open_level_select start; target_exists=true")
	GameManager.go_to_level_select()
	print("[NAV][MainMenu] scene change requested successfully")

func _on_continue() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

func _on_shop() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/Shop.tscn")

func _on_daily_challenge() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/DailyChallenge.tscn")

func _on_login() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	if GameManager.is_logged_in:
		get_tree().change_scene_to_file("res://scenes/menus/Profile.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")

func _on_settings() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/Settings.tscn")

func _on_home_building() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_home_building()

# ── HELPERS ──────────────────────────────────────────────────────────────────

func _lbl(text: String, pos: Vector2, size: Vector2,
		font_size: int, color: Color, shadow: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	if shadow > 0:
		l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
		l.add_theme_constant_override("shadow_offset_x", shadow)
		l.add_theme_constant_override("shadow_offset_y", shadow)
	l.size = size; l.position = pos
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _cr(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos; r.size = size; r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r
