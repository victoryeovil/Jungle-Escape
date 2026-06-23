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
const PH  := 780.0
const PAD := 20.0
const IW  := PW - PAD * 2.0

# column positions (panel-relative x)
const COL_LABEL  := PAD
const COL_TOGGLE := PAD + 190.0 + 6.0
const COL_SLIDER := PAD + 190.0 + 6.0 + 62.0 + 8.0
const TOGGLE_W   := 62.0
const SLIDER_W   := PAD + IW - COL_SLIDER

var _sfx_toggle   : Button
var _sfx_slider   : HSlider
var _music_toggle : Button
var _music_slider : HSlider
var _vib_toggle   : Button
var _notif_toggle : Button
var _backup_toggle: Button   # null when not logged in
var _gfx_btn      : Button

# ── build ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var panel := Panel.new()
	panel.position = Vector2(18.0, (854.0 - PH) * 0.5)
	panel.size     = Vector2(PW, PH)
	var psb := StyleBoxFlat.new()
	psb.bg_color            = C_PANEL
	psb.border_color        = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.60)
	psb.border_width_left   = 2; psb.border_width_right  = 2
	psb.border_width_top    = 2; psb.border_width_bottom = 2
	psb.corner_radius_top_left     = 10; psb.corner_radius_top_right    = 10
	psb.corner_radius_bottom_left  = 10; psb.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", psb)
	add_child(panel)

	# Fixed title bar
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

	# Scrollable content area below the title bar
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 62)
	scroll.size     = Vector2(PW, PH - 62)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	var content := Control.new()
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(content)

	var y := 12.0

	# ── AUDIO ─────────────────────────────────────────────────────────────────
	_section_lbl(content, "AUDIO", y);  y += 32.0

	_row_lbl(content, "🔊  Sound Effects", y)
	_sfx_toggle = _mk_toggle(content, SaveManager.get_setting("sfx_on", true), COL_TOGGLE, y)
	_sfx_slider = _mk_slider(content, SaveManager.get_setting("sfx_volume", 1.0), COL_SLIDER, y)
	y += 48.0

	_row_lbl(content, "🎵  Music", y)
	_music_toggle = _mk_toggle(content, SaveManager.get_setting("music_on", true), COL_TOGGLE, y)
	_music_slider = _mk_slider(content, SaveManager.get_setting("music_volume", 0.7), COL_SLIDER, y)
	y += 48.0

	_divider(content, y);  y += 20.0

	# ── DISPLAY ───────────────────────────────────────────────────────────────
	_section_lbl(content, "DISPLAY", y);  y += 32.0

	_row_lbl(content, "📱  Graphics", y)
	_gfx_btn = _mk_cycle_btn(content, _gfx_label(), y)
	y += 48.0

	_row_lbl(content, "🔔  Notifications", y)
	_notif_toggle = _mk_toggle(content, SaveManager.get_setting("notifications_on", true),
		PAD + IW - TOGGLE_W, y)
	y += 48.0

	_divider(content, y);  y += 20.0

	# ── GAMEPLAY ──────────────────────────────────────────────────────────────
	_section_lbl(content, "GAMEPLAY", y);  y += 32.0

	_row_lbl(content, "📳  Vibration", y)
	_vib_toggle = _mk_toggle(content, SaveManager.get_setting("vibration_on", true),
		PAD + IW - TOGGLE_W, y)
	y += 48.0

	_divider(content, y);  y += 20.0

	# ── ACCOUNT ───────────────────────────────────────────────────────────────
	_section_lbl(content, "ACCOUNT", y);  y += 32.0

	if GameManager.is_logged_in:
		# Logged-in state
		var name_lbl := Label.new()
		name_lbl.text = "👤  " + GameManager.player_name
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", C_GOLD)
		name_lbl.size         = Vector2(IW, 36)
		name_lbl.position     = Vector2(PAD, y + 6.0)
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(name_lbl)
		y += 48.0

		_row_lbl(content, "☁  Cloud Backup", y)
		_backup_toggle = _mk_toggle(content, SaveManager.get_setting("cloud_backup", true),
			PAD + IW - TOGGLE_W, y)
		y += 48.0

		var sub_lbl := Label.new()
		sub_lbl.text = "Progress is backed up after each level."
		sub_lbl.add_theme_font_size_override("font_size", 11)
		sub_lbl.add_theme_color_override("font_color", C_DIM)
		sub_lbl.size         = Vector2(IW, 20)
		sub_lbl.position     = Vector2(PAD, y)
		sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(sub_lbl)
		y += 28.0

		var btn_backup := _mk_action_btn(content, "⬆   BACK UP NOW", y, false)
		btn_backup.pressed.connect(_on_backup_now)
		y += 54.0

		var btn_delete := _mk_action_btn(content, "🗑   DELETE MY ACCOUNT", y, true)
		btn_delete.pressed.connect(_on_delete_account)
		y += 54.0
	else:
		# Guest state — invite to sign in
		var guest_lbl := Label.new()
		guest_lbl.text = "Sign in to keep your progress\nacross all your devices."
		guest_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		guest_lbl.add_theme_font_size_override("font_size", 12)
		guest_lbl.add_theme_color_override("font_color", C_DIM)
		guest_lbl.size         = Vector2(IW, 42)
		guest_lbl.position     = Vector2(PAD, y)
		guest_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(guest_lbl)
		y += 48.0

		var btn_login := _mk_action_btn(content, "👤   SIGN IN / REGISTER", y, false)
		btn_login.pressed.connect(_on_login)
		y += 54.0

	_divider(content, y);  y += 20.0

	# ── Action buttons ─────────────────────────────────────────────────────────
	var btn_back  := _mk_action_btn(content, "←   BACK", y, false);  y += 54.0
	var btn_reset := _mk_action_btn(content, "⚠   RESET ALL PROGRESS", y, true);  y += 10.0

	content.custom_minimum_size = Vector2(PW, y)

	# ── Connections ────────────────────────────────────────────────────────────
	_sfx_toggle.pressed.connect(_on_sfx_toggle)
	_music_toggle.pressed.connect(_on_music_toggle)
	_vib_toggle.pressed.connect(_on_vib_toggle)
	_notif_toggle.pressed.connect(_on_notif_toggle)
	if _backup_toggle:
		_backup_toggle.pressed.connect(_on_backup_toggle)
	_gfx_btn.pressed.connect(_on_gfx_cycle)
	_sfx_slider.value_changed.connect(func(v: float) -> void:
		SaveManager.set_setting("sfx_volume", v); EventBus.settings_changed.emit())
	_music_slider.value_changed.connect(func(v: float) -> void:
		SaveManager.set_setting("music_volume", v); EventBus.settings_changed.emit())
	btn_back.pressed.connect(_on_back)
	btn_reset.pressed.connect(_on_reset)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _cr(parent: Node, pos: Vector2, sz: Vector2, color: Color) -> void:
	var r := ColorRect.new()
	r.position = pos; r.size = sz; r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)

func _divider(parent: Node, y: float) -> void:
	_cr(parent, Vector2(PAD, y), Vector2(IW, 1), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.28))

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
	sb.corner_radius_top_left     = 18; sb.corner_radius_top_right    = 18
	sb.corner_radius_bottom_left  = 18; sb.corner_radius_bottom_right = 18
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("pressed", sb)
	var sbh      := sb.duplicate() as StyleBoxFlat
	sbh.bg_color  = sb.bg_color.lightened(0.14)
	btn.add_theme_stylebox_override("hover", sbh)
	btn.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90) if is_on else C_DIM)
	btn.text = "ON" if is_on else "OFF"

func _mk_slider(parent: Node, value: float, x: float, y: float) -> HSlider:
	var sl := HSlider.new()
	sl.min_value = 0.0; sl.max_value = 1.0; sl.step = 0.05
	sl.value     = value
	sl.focus_mode = Control.FOCUS_NONE
	sl.size       = Vector2(SLIDER_W, 20)
	sl.position   = Vector2(x, y + 16.0)
	var sb_track := StyleBoxFlat.new()
	sb_track.bg_color = Color(0.12, 0.12, 0.10)
	sb_track.corner_radius_top_left = 3; sb_track.corner_radius_top_right = 3
	sb_track.corner_radius_bottom_left = 3; sb_track.corner_radius_bottom_right = 3
	sl.add_theme_stylebox_override("slider", sb_track)
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = C_GOLD.darkened(0.15)
	sb_fill.corner_radius_top_left = 3; sb_fill.corner_radius_top_right = 3
	sb_fill.corner_radius_bottom_left = 3; sb_fill.corner_radius_bottom_right = 3
	sl.add_theme_stylebox_override("grabber_area", sb_fill)
	parent.add_child(sl)
	return sl

func _mk_cycle_btn(parent: Node, text: String, y: float) -> Button:
	var btn := Button.new()
	btn.text       = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(TOGGLE_W + 16, 36)
	btn.position   = Vector2(COL_TOGGLE, y + 6.0)
	btn.add_theme_font_size_override("font_size", 11)
	_apply_toggle_style(btn, true)
	parent.add_child(btn)
	return btn

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
	sb.corner_radius_top_left     = 8; sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8; sb.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("pressed", sb)
	var sbh      := sb.duplicate() as StyleBoxFlat
	sbh.bg_color  = sb.bg_color.lightened(0.10)
	btn.add_theme_stylebox_override("hover", sbh)
	parent.add_child(btn)
	return btn

# ── Toggle / cycle handlers ───────────────────────────────────────────────────

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

func _on_notif_toggle() -> void:
	var v := not SaveManager.get_setting("notifications_on", true)
	SaveManager.set_setting("notifications_on", v)
	_apply_toggle_style(_notif_toggle, v)

func _on_backup_toggle() -> void:
	var v := not SaveManager.get_setting("cloud_backup", true)
	SaveManager.set_setting("cloud_backup", v)
	_apply_toggle_style(_backup_toggle, v)

func _on_gfx_cycle() -> void:
	var cur := SaveManager.get_setting("graphics_quality", "MED")
	var next: String
	match cur:
		"LOW":  next = "MED"
		"MED":  next = "HIGH"
		_:      next = "LOW"
	SaveManager.set_setting("graphics_quality", next)
	_gfx_btn.text = _gfx_label()
	GameManager._apply_graphics_quality()
	EventBus.settings_changed.emit()

func _gfx_label() -> String:
	match SaveManager.get_setting("graphics_quality", "MED"):
		"LOW":  return "LOW"
		"HIGH": return "HIGH"
		_:      return "MED"

# ── Account actions ───────────────────────────────────────────────────────────

func _on_login() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")

func _on_backup_now() -> void:
	EventBus.play_sfx.emit("button")
	if GameManager.is_logged_in:
		SaveManager.sync_to_cloud()

func _on_delete_account() -> void:
	EventBus.play_sfx.emit("button")
	_show_delete_dialog()

func _show_delete_dialog() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.72)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var dw := 420.0; var dh := 310.0
	var dp := Panel.new()
	dp.position = Vector2((480.0 - dw) * 0.5, (854.0 - dh) * 0.5)
	dp.size     = Vector2(dw, dh)
	var dsb := StyleBoxFlat.new()
	dsb.bg_color            = C_PANEL
	dsb.border_color        = Color(0.76, 0.22, 0.14, 0.85)
	dsb.border_width_left   = 2; dsb.border_width_right  = 2
	dsb.border_width_top    = 2; dsb.border_width_bottom = 2
	dsb.corner_radius_top_left     = 10; dsb.corner_radius_top_right    = 10
	dsb.corner_radius_bottom_left  = 10; dsb.corner_radius_bottom_right = 10
	dp.add_theme_stylebox_override("panel", dsb)
	add_child(dp)

	var dlbl_title := Label.new()
	dlbl_title.text = "Delete Account?"
	dlbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dlbl_title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	dlbl_title.add_theme_font_size_override("font_size", 20)
	dlbl_title.add_theme_color_override("font_color", Color(1.0, 0.38, 0.28))
	dlbl_title.size         = Vector2(dw, 56)
	dlbl_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dp.add_child(dlbl_title)

	var dlbl_body := Label.new()
	dlbl_body.text = "Your account will be permanently deleted\nafter 14 days.\n\nYou can recover it at any time within\nthose 14 days by signing back in."
	dlbl_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dlbl_body.add_theme_font_size_override("font_size", 13)
	dlbl_body.add_theme_color_override("font_color", C_TEXT)
	dlbl_body.size         = Vector2(dw - 40.0, 120.0)
	dlbl_body.position     = Vector2(20.0, 60.0)
	dlbl_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dlbl_body.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	dp.add_child(dlbl_body)

	# KEEP button
	var btn_keep := Button.new()
	btn_keep.text       = "KEEP MY ACCOUNT"
	btn_keep.focus_mode = Control.FOCUS_NONE
	btn_keep.custom_minimum_size = Vector2(dw - 40.0, 46.0)
	btn_keep.position   = Vector2(20.0, 196.0)
	btn_keep.add_theme_font_size_override("font_size", 15)
	btn_keep.add_theme_color_override("font_color", C_GOLD)
	var sb_keep := StyleBoxFlat.new()
	sb_keep.bg_color     = Color(0.06, 0.10, 0.05, 0.92)
	sb_keep.border_color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.85)
	sb_keep.border_width_left = 2; sb_keep.border_width_right  = 2
	sb_keep.border_width_top  = 2; sb_keep.border_width_bottom = 2
	sb_keep.corner_radius_top_left     = 8; sb_keep.corner_radius_top_right    = 8
	sb_keep.corner_radius_bottom_left  = 8; sb_keep.corner_radius_bottom_right = 8
	btn_keep.add_theme_stylebox_override("normal",  sb_keep)
	btn_keep.add_theme_stylebox_override("pressed", sb_keep)
	btn_keep.pressed.connect(func():
		overlay.queue_free()
		dp.queue_free()
	)
	dp.add_child(btn_keep)

	# DELETE button
	var btn_del := Button.new()
	btn_del.text       = "DELETE IN 14 DAYS"
	btn_del.focus_mode = Control.FOCUS_NONE
	btn_del.custom_minimum_size = Vector2(dw - 40.0, 46.0)
	btn_del.position   = Vector2(20.0, 252.0)
	btn_del.add_theme_font_size_override("font_size", 14)
	btn_del.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	var sb_del := StyleBoxFlat.new()
	sb_del.bg_color     = Color(0.24, 0.07, 0.05, 0.92)
	sb_del.border_color = Color(0.76, 0.22, 0.14)
	sb_del.border_width_left = 2; sb_del.border_width_right  = 2
	sb_del.border_width_top  = 2; sb_del.border_width_bottom = 2
	sb_del.corner_radius_top_left     = 8; sb_del.corner_radius_top_right    = 8
	sb_del.corner_radius_bottom_left  = 8; sb_del.corner_radius_bottom_right = 8
	btn_del.add_theme_stylebox_override("normal",  sb_del)
	btn_del.add_theme_stylebox_override("pressed", sb_del)
	btn_del.pressed.connect(func():
		overlay.queue_free()
		dp.queue_free()
		_confirm_delete()
	)
	dp.add_child(btn_del)

func _confirm_delete() -> void:
	SupabaseClient.request_deletion(func(ok: bool) -> void:
		if not ok:
			return
		SupabaseClient.sign_out()
		GameManager.is_logged_in = false
		GameManager.is_guest     = true
		GameManager.player_name  = "Explorer"
		_show_toast("Deletion scheduled.\nSign in within 14 days to cancel.", 4.0)
		get_tree().create_timer(3.5).timeout.connect(_on_back)
	)

# ── Navigation ────────────────────────────────────────────────────────────────

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	EventBus.settings_changed.emit()
	GameManager.go_to_menu()

func _on_reset() -> void:
	EventBus.play_sfx.emit("button")
	var dialog := AcceptDialog.new()
	dialog.title       = "Reset Progress?"
	dialog.dialog_text = "This will erase ALL your local progress. Are you sure?"
	dialog.confirmed.connect(_confirm_reset)
	add_child(dialog)
	dialog.popup_centered()

func _confirm_reset() -> void:
	SaveManager.reset_all_data()
	get_tree().change_scene_to_file("res://scenes/splash/SplashScreen.tscn")

# ── Toast ─────────────────────────────────────────────────────────────────────

func _show_toast(msg: String, duration: float) -> void:
	var toast := Label.new()
	toast.text                 = msg
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	toast.add_theme_font_size_override("font_size", 13)
	toast.add_theme_color_override("font_color", C_TEXT)
	toast.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	toast.add_theme_constant_override("shadow_offset_x", 1)
	toast.add_theme_constant_override("shadow_offset_y", 1)
	toast.size     = Vector2(480, 80)
	toast.position = Vector2(0, 380)
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast)
	get_tree().create_timer(duration).timeout.connect(func():
		if is_instance_valid(toast): toast.queue_free()
	)
