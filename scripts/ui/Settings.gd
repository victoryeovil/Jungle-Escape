extends Control

# ── palette ───────────────────────────────────────────────────────────────────
const C_GOLD    := Color(0.96, 0.82, 0.26)
const C_BG      := Color(0.02, 0.05, 0.02, 0.96)
const C_PANEL   := Color(0.04, 0.08, 0.04, 0.99)
const C_SECTION := Color(0.52, 0.80, 0.42)
const C_TEXT    := Color(0.90, 0.92, 0.84)
const C_DIM     := Color(0.46, 0.48, 0.40)
const C_ON      := Color(0.14, 0.50, 0.10)
const C_OFF     := Color(0.10, 0.10, 0.09)

# panel geometry
const PW  := 444.0
const PH  := 428.0
const PAD := 20.0
const IW  := PW - PAD * 2.0   # 404

# column positions (panel-relative x)
const COL_LABEL  := PAD                           # 20
const COL_TOGGLE := PAD + 190.0 + 6.0            # 216
const COL_SLIDER := PAD + 190.0 + 6.0 + 62.0 + 8.0  # 286
const TOGGLE_W   := 62.0
const SLIDER_W   := PAD + IW - COL_SLIDER        # 138

var _sfx_toggle   : Button
var _sfx_slider   : HSlider
var _music_toggle : Button
var _music_slider : HSlider
var _vib_toggle   : Button

# ── build ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Full-screen dark overlay
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Centred card panel
	var panel := Panel.new()
	panel.position = Vector2(18.0, (854.0 - PH) * 0.5)
	panel.size     = Vector2(PW, PH)
	var psb := StyleBoxFlat.new()
	psb.bg_color            = C_PANEL
	psb.border_color        = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.60)
	psb.border_width_left   = 2; psb.border_width_right  = 2
	psb.border_width_top    = 2; psb.border_width_bottom = 2
	psb.corner_radius_top_left     = 10
	psb.corner_radius_top_right    = 10
	psb.corner_radius_bottom_left  = 10
	psb.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", psb)
	add_child(panel)

	# ── Title bar ──
	_cr(panel, Vector2(0, 0), Vector2(PW, 58), Color(0.02, 0.03, 0.02))
	_cr(panel, Vector2(0, 58), Vector2(PW, 2), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.75))
	var title := Label.new()
	title.text = "⚙   SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", C_GOLD)
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.size         = Vector2(PW, 58)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(title)

	var y := 70.0

	# ── AUDIO ──
	_section_lbl(panel, "AUDIO", y)
	y += 32.0

	_row_lbl(panel, "🔊  Sound Effects", y)
	_sfx_toggle = _mk_toggle(panel, SaveManager.get_setting("sfx_on", true),
		COL_TOGGLE, y)
	_sfx_slider = _mk_slider(panel, SaveManager.get_setting("sfx_volume", 1.0),
		COL_SLIDER, y)
	y += 48.0

	_row_lbl(panel, "🎵  Music", y)
	_music_toggle = _mk_toggle(panel, SaveManager.get_setting("music_on", true),
		COL_TOGGLE, y)
	_music_slider = _mk_slider(panel, SaveManager.get_setting("music_volume", 0.7),
		COL_SLIDER, y)
	y += 48.0

	_cr(panel, Vector2(PAD, y), Vector2(IW, 1), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.28))
	y += 14.0

	# ── GAMEPLAY ──
	_section_lbl(panel, "GAMEPLAY", y)
	y += 32.0

	_row_lbl(panel, "📳  Vibration", y)
	_vib_toggle = _mk_toggle(panel, SaveManager.get_setting("vibration_on", true),
		PAD + IW - TOGGLE_W, y)
	y += 48.0

	_cr(panel, Vector2(PAD, y), Vector2(IW, 1), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.28))
	y += 18.0

	# ── Action buttons ──
	var btn_back  := _mk_action_btn(panel, "←   BACK", y, false)
	y += 54.0
	var btn_reset := _mk_action_btn(panel, "⚠   RESET ALL PROGRESS", y, true)

	# ── Connections ──
	_sfx_toggle.pressed.connect(_on_sfx_toggle)
	_music_toggle.pressed.connect(_on_music_toggle)
	_vib_toggle.pressed.connect(_on_vib_toggle)
	_sfx_slider.value_changed.connect(func(v: float) -> void:
		SaveManager.set_setting("sfx_volume", v)
		EventBus.settings_changed.emit())
	_music_slider.value_changed.connect(func(v: float) -> void:
		SaveManager.set_setting("music_volume", v)
		EventBus.settings_changed.emit())
	btn_back.pressed.connect(_on_back)
	btn_reset.pressed.connect(_on_reset)

# ── helpers ───────────────────────────────────────────────────────────────────
func _cr(parent: Node, pos: Vector2, size: Vector2, color: Color) -> void:
	var r := ColorRect.new()
	r.position = pos; r.size = size; r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)

func _section_lbl(parent: Node, text: String, y: float) -> void:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 10)
	l.add_theme_color_override("font_color", C_SECTION)
	l.size         = Vector2(PW, 24)
	l.position     = Vector2(0, y)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)

func _row_lbl(parent: Node, text: String, y: float) -> void:
	var l := Label.new()
	l.text = text
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", C_TEXT)
	l.size         = Vector2(190, 38)
	l.position     = Vector2(COL_LABEL, y + 5.0)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)

func _mk_toggle(parent: Node, is_on: bool, x: float, y: float) -> Button:
	var btn := Button.new()
	btn.text       = "ON" if is_on else "OFF"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(TOGGLE_W, 36)
	btn.position   = Vector2(x, y + 6.0)
	btn.add_theme_font_size_override("font_size", 12)
	_apply_toggle_style(btn, is_on)
	parent.add_child(btn)
	return btn

func _apply_toggle_style(btn: Button, is_on: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color          = C_ON if is_on else C_OFF
	sb.border_color      = Color(0.42, 0.36, 0.18, 0.80)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left     = 18
	sb.corner_radius_top_right    = 18
	sb.corner_radius_bottom_left  = 18
	sb.corner_radius_bottom_right = 18
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("pressed", sb)
	var sbh        := sb.duplicate() as StyleBoxFlat
	sbh.bg_color   = sb.bg_color.lightened(0.14)
	btn.add_theme_stylebox_override("hover", sbh)
	btn.add_theme_color_override("font_color",
		Color(0.94, 1.0, 0.90) if is_on else C_DIM)

func _mk_slider(parent: Node, value: float, x: float, y: float) -> HSlider:
	var sl := HSlider.new()
	sl.min_value = 0.0; sl.max_value = 1.0; sl.step = 0.05
	sl.value     = value
	sl.focus_mode = Control.FOCUS_NONE
	sl.size       = Vector2(SLIDER_W, 20)
	sl.position   = Vector2(x, y + 16.0)

	var sb_track := StyleBoxFlat.new()
	sb_track.bg_color            = Color(0.12, 0.12, 0.10)
	sb_track.corner_radius_top_left     = 3
	sb_track.corner_radius_top_right    = 3
	sb_track.corner_radius_bottom_left  = 3
	sb_track.corner_radius_bottom_right = 3
	sl.add_theme_stylebox_override("slider", sb_track)

	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color            = C_GOLD.darkened(0.15)
	sb_fill.corner_radius_top_left     = 3
	sb_fill.corner_radius_top_right    = 3
	sb_fill.corner_radius_bottom_left  = 3
	sb_fill.corner_radius_bottom_right = 3
	sl.add_theme_stylebox_override("grabber_area", sb_fill)

	sl.add_theme_color_override("font_color", C_GOLD)
	parent.add_child(sl)
	return sl

func _mk_action_btn(parent: Node, text: String, y: float, danger: bool) -> Button:
	var btn := Button.new()
	btn.text       = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(IW, 46)
	btn.position   = Vector2(PAD, y)
	btn.add_theme_font_size_override("font_size", danger ? 13 : 16)

	var sb := StyleBoxFlat.new()
	if danger:
		sb.bg_color     = Color(0.24, 0.07, 0.05, 0.92)
		sb.border_color = Color(0.76, 0.22, 0.14)
		btn.add_theme_color_override("font_color", Color(1.0, 0.50, 0.40))
	else:
		sb.bg_color     = Color(0.06, 0.10, 0.05, 0.92)
		sb.border_color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.85)
		btn.add_theme_color_override("font_color", C_GOLD)
	sb.border_width_left   = 2; sb.border_width_right  = 2
	sb.border_width_top    = 2; sb.border_width_bottom = 2
	sb.corner_radius_top_left     = 8
	sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8
	sb.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("pressed", sb)
	var sbh        := sb.duplicate() as StyleBoxFlat
	sbh.bg_color   = sb.bg_color.lightened(0.10)
	btn.add_theme_stylebox_override("hover", sbh)
	parent.add_child(btn)
	return btn

# ── toggle handlers ───────────────────────────────────────────────────────────
func _on_sfx_toggle() -> void:
	var v := not SaveManager.get_setting("sfx_on", true)
	SaveManager.set_setting("sfx_on", v)
	_apply_toggle_style(_sfx_toggle, v)
	EventBus.settings_changed.emit()

func _on_music_toggle() -> void:
	var v := not SaveManager.get_setting("music_on", true)
	SaveManager.set_setting("music_on", v)
	_apply_toggle_style(_music_toggle, v)
	EventBus.settings_changed.emit()

func _on_vib_toggle() -> void:
	var v := not SaveManager.get_setting("vibration_on", true)
	SaveManager.set_setting("vibration_on", v)
	_apply_toggle_style(_vib_toggle, v)

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	EventBus.settings_changed.emit()
	if GameManager.state == GameManager.GameState.PAUSED:
		GameManager.restart_level()
	else:
		GameManager.go_to_menu()

func _on_reset() -> void:
	EventBus.play_sfx.emit("button")
	var dialog := AcceptDialog.new()
	dialog.title       = "Reset Progress?"
	dialog.dialog_text = "This will erase ALL your progress. Are you sure?"
	dialog.confirmed.connect(_confirm_reset)
	add_child(dialog)
	dialog.popup_centered()

func _confirm_reset() -> void:
	SaveManager.reset_all_data()
	get_tree().change_scene_to_file("res://scenes/splash/SplashScreen.tscn")
