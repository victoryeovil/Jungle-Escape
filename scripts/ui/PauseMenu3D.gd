extends Control

@onready var btn_resume:  Button = $Panel/VBox/BtnResume
@onready var btn_restart: Button = $Panel/VBox/BtnRestart
@onready var btn_menu:    Button = $Panel/VBox/BtnMenu

# The .tscn does not have a BtnSettings node, so we add one at runtime.
var _btn_settings: Button = null
var _settings_overlay: Control = null

const C_GOLD := Color(0.96, 0.82, 0.26)
const C_DIM  := Color(0.46, 0.48, 0.40)
const C_ON   := Color(0.14, 0.50, 0.10)
const C_OFF  := Color(0.10, 0.10, 0.09)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_resume.pressed.connect(_on_resume)
	btn_restart.pressed.connect(_on_restart)
	btn_menu.pressed.connect(_on_menu)
	EventBus.pause_toggled.connect(func(p): visible = p)
	visible = false

	# Add Settings button below the existing buttons
	_btn_settings = Button.new()
	_btn_settings.text = "⚙  Settings"
	_btn_settings.pressed.connect(_on_settings)
	_btn_settings.custom_minimum_size = Vector2(0, 44)
	_btn_settings.add_theme_font_size_override("font_size", 16)
	$Panel/VBox.add_child(_btn_settings)

func _on_resume() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()

func _on_restart() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()
	GameManager.go_to_gameplay_3d(GameManager.current_level_id)

func _on_menu() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()
	GameManager.go_to_menu()

func _on_settings() -> void:
	EventBus.play_sfx.emit("button")
	if _settings_overlay != null and is_instance_valid(_settings_overlay):
		_settings_overlay.queue_free()
		_settings_overlay = null
		return
	_build_settings_overlay()

# ── In-game settings overlay ──────────────────────────────────────────────────

func _build_settings_overlay() -> void:
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_settings_overlay = overlay
	add_child(overlay)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)

	var pw := 420.0; var ph := 380.0
	var panel := Panel.new()
	panel.position = Vector2((480.0 - pw) * 0.5, (854.0 - ph) * 0.5)
	panel.size     = Vector2(pw, ph)
	var sb := StyleBoxFlat.new()
	sb.bg_color           = Color(0.04, 0.08, 0.04, 0.99)
	sb.border_color       = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.60)
	sb.border_width_left  = 2; sb.border_width_right  = 2
	sb.border_width_top   = 2; sb.border_width_bottom = 2
	sb.corner_radius_top_left     = 10; sb.corner_radius_top_right    = 10
	sb.corner_radius_bottom_left  = 10; sb.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", sb)
	overlay.add_child(panel)

	# Title
	var title_bg := ColorRect.new()
	title_bg.color = Color(0.02, 0.04, 0.02)
	title_bg.size  = Vector2(pw, 50)
	panel.add_child(title_bg)
	var title_lbl := Label.new()
	title_lbl.text = "⚙   SETTINGS"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", C_GOLD)
	title_lbl.size = Vector2(pw, 50)
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(title_lbl)

	var y := 62.0
	y = _overlay_row(panel, "🔊  Sound Effects", "sfx_on", y)
	y = _overlay_slider(panel, "sfx_volume", y)
	y = _overlay_row(panel, "🎵  Music", "music_on", y)
	y = _overlay_slider(panel, "music_volume", y)
	y = _overlay_row(panel, "📳  Vibration", "vibration_on", y)

	y += 16.0
	var btn_close := Button.new()
	btn_close.text = "Done"
	btn_close.custom_minimum_size = Vector2(pw - 40.0, 46.0)
	btn_close.position = Vector2(20.0, y)
	btn_close.add_theme_font_size_override("font_size", 17)
	btn_close.pressed.connect(func():
		overlay.queue_free()
		_settings_overlay = null
	)
	var csb := StyleBoxFlat.new()
	csb.bg_color     = Color(0.06, 0.12, 0.04, 0.92)
	csb.border_color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.85)
	csb.border_width_left  = 2; csb.border_width_right  = 2
	csb.border_width_top   = 2; csb.border_width_bottom = 2
	csb.corner_radius_top_left     = 8; csb.corner_radius_top_right    = 8
	csb.corner_radius_bottom_left  = 8; csb.corner_radius_bottom_right = 8
	btn_close.add_theme_stylebox_override("normal",  csb)
	btn_close.add_theme_stylebox_override("pressed", csb)
	btn_close.add_theme_color_override("font_color", C_GOLD)
	panel.add_child(btn_close)

func _overlay_row(parent: Node, label: String, setting_key: String, y: float) -> float:
	var lbl := Label.new()
	lbl.text = label
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(0.90, 0.92, 0.84))
	lbl.size     = Vector2(210, 36)
	lbl.position = Vector2(18, y + 4)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(lbl)

	var is_on: bool = bool(SaveManager.get_setting(setting_key, true))
	var btn   := Button.new()
	btn.text  = "ON" if is_on else "OFF"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(62, 34)
	btn.position = Vector2(344, y + 5)
	btn.add_theme_font_size_override("font_size", 12)
	_apply_toggle(btn, is_on)
	btn.pressed.connect(func():
		var v: bool = not bool(SaveManager.get_setting(setting_key, true))
		SaveManager.set_setting(setting_key, v)
		_apply_toggle(btn, v)
		EventBus.settings_changed.emit()
	)
	parent.add_child(btn)
	return y + 44.0

func _overlay_slider(parent: Node, key: String, y: float) -> float:
	var sl := HSlider.new()
	sl.min_value = 0.0; sl.max_value = 1.0; sl.step = 0.05
	sl.value    = SaveManager.get_setting(key, 0.8)
	sl.focus_mode = Control.FOCUS_NONE
	sl.size     = Vector2(380, 20)
	sl.position = Vector2(18, y + 4)
	var sb_track := StyleBoxFlat.new()
	sb_track.bg_color = Color(0.12, 0.12, 0.10)
	sb_track.corner_radius_top_left    = 3; sb_track.corner_radius_top_right    = 3
	sb_track.corner_radius_bottom_left = 3; sb_track.corner_radius_bottom_right = 3
	sl.add_theme_stylebox_override("slider", sb_track)
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = C_GOLD.darkened(0.15)
	sb_fill.corner_radius_top_left    = 3; sb_fill.corner_radius_top_right    = 3
	sb_fill.corner_radius_bottom_left = 3; sb_fill.corner_radius_bottom_right = 3
	sl.add_theme_stylebox_override("grabber_area", sb_fill)
	sl.value_changed.connect(func(v: float):
		SaveManager.set_setting(key, v)
		EventBus.settings_changed.emit()
	)
	parent.add_child(sl)
	return y + 32.0

func _apply_toggle(btn: Button, is_on: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color    = C_ON if is_on else C_OFF
	sb.border_color = Color(0.42, 0.36, 0.18, 0.80)
	sb.border_width_left  = 1; sb.border_width_right  = 1
	sb.border_width_top   = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left     = 18; sb.corner_radius_top_right    = 18
	sb.corner_radius_bottom_left  = 18; sb.corner_radius_bottom_right = 18
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90) if is_on else C_DIM)
	btn.text = "ON" if is_on else "OFF"
