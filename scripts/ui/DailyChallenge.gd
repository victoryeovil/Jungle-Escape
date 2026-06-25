extends Control

# ── palette ───────────────────────────────────────────────────────────────────
const C_BG    := Color(0.02, 0.05, 0.02, 1.0)
const C_PANEL := Color(0.04, 0.10, 0.04, 0.98)
const C_GOLD  := Color(0.96, 0.82, 0.26)
const C_GREEN := Color(0.52, 0.80, 0.42)
const C_TEXT  := Color(0.90, 0.92, 0.84)
const C_DIM   := Color(0.46, 0.48, 0.40)
const C_BLUE  := Color(0.42, 0.82, 1.00)

const CHALLENGES := [
	{"title": "Coin Rush",     "desc": "Complete Level %d collecting 10 or more coins.", "target": "coins_10",  "reward_gems": 3},
	{"title": "No Stumbles",   "desc": "Complete Level %d without falling once.",         "target": "no_fail",   "reward_gems": 4},
	{"title": "Speed Run",     "desc": "Complete Level %d in under 60 seconds.",          "target": "speed_60",  "reward_gems": 5},
	{"title": "3-Star Run",    "desc": "Earn 3 stars on Level %d.",                       "target": "stars_3",   "reward_gems": 4},
	{"title": "Resource Hunt", "desc": "Complete Level %d picking up every item.",        "target": "all_items", "reward_gems": 3},
	{"title": "Flawless Run",  "desc": "Complete Level %d in a single attempt.",          "target": "one_shot",  "reward_gems": 5},
]

var _countdown_label: Label = null
var _timer: Timer = null

func _ready() -> void:
	# Hide any nodes that came from the .tscn
	for child in get_children():
		child.visible = false
	_build_ui()
	_start_countdown_timer()

# ── Build ─────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Jungle-stripe decoration
	for i in 4:
		var stripe := ColorRect.new()
		stripe.color = Color(0.04, 0.10, 0.03, 0.22)
		stripe.size = Vector2(480, 80)
		stripe.position = Vector2(0, 80 + i * 200)
		stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(stripe)

	_build_header()
	var challenge := _today_challenge()
	_build_challenge_card(challenge)
	_build_streak_row()
	_build_countdown_row()

func _build_header() -> void:
	var hdr := ColorRect.new()
	hdr.color = Color(0.02, 0.06, 0.02, 0.98)
	hdr.size = Vector2(480, 62)
	add_child(hdr)

	var border := ColorRect.new()
	border.color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.75)
	border.size = Vector2(480, 2)
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
	lbl.text = "🌟   DAILY CHALLENGE"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", C_GOLD)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.size = Vector2(400, 62)
	lbl.position = Vector2(40, 0)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hdr.add_child(lbl)

func _build_challenge_card(challenge: Dictionary) -> void:
	var panel := _mk_panel(Vector2(18, 78), Vector2(444, 276))
	add_child(panel)

	# Date badge strip
	var badge := ColorRect.new()
	badge.color = Color(0.06, 0.16, 0.04, 1.0)
	badge.size  = Vector2(444, 32)
	panel.add_child(badge)

	var date_dict := Time.get_date_dict_from_system()
	var months: Array[String] = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
	var month_name: String = months[int(date_dict.get("month", 1)) - 1]
	var date_str := month_name + " " + str(date_dict.get("day", 1)) + ", " + str(date_dict.get("year", 2025))
	var lbl_date := Label.new()
	lbl_date.text = date_str
	lbl_date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_date.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl_date.add_theme_font_size_override("font_size", 11)
	lbl_date.add_theme_color_override("font_color", C_GREEN)
	lbl_date.size = Vector2(444, 32)
	lbl_date.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(lbl_date)

	# Challenge title
	var lbl_type := Label.new()
	lbl_type.text = str(challenge.get("title", "Daily Run"))
	lbl_type.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_type.add_theme_font_size_override("font_size", 24)
	lbl_type.add_theme_color_override("font_color", C_GOLD)
	lbl_type.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	lbl_type.add_theme_constant_override("shadow_offset_x", 1)
	lbl_type.add_theme_constant_override("shadow_offset_y", 2)
	lbl_type.size = Vector2(404, 44)
	lbl_type.position = Vector2(20, 40)
	panel.add_child(lbl_type)

	# Description
	var lbl_desc := Label.new()
	lbl_desc.text = str(challenge.get("desc", ""))
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.add_theme_font_size_override("font_size", 14)
	lbl_desc.add_theme_color_override("font_color", C_TEXT)
	lbl_desc.size = Vector2(404, 52)
	lbl_desc.position = Vector2(20, 90)
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(lbl_desc)

	# Reward
	var lbl_reward := Label.new()
	var gems: int = int(challenge.get("reward_gems", 3))
	lbl_reward.text = "Reward: " + str(gems) + " 💎 Gems"
	lbl_reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_reward.add_theme_font_size_override("font_size", 15)
	lbl_reward.add_theme_color_override("font_color", C_BLUE)
	lbl_reward.size = Vector2(404, 28)
	lbl_reward.position = Vector2(20, 150)
	panel.add_child(lbl_reward)

	# Start / completed button
	var already_done := _is_today_done()
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(366, 52)
	btn.position = Vector2(38, 188)
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 18)
	if already_done:
		btn.text     = "✓   Completed Today!"
		btn.disabled = true
		_style_btn(btn, Color(0.08, 0.24, 0.08))
		btn.add_theme_color_override("font_color", C_GREEN)
	else:
		btn.text = "▶   Start Challenge"
		btn.pressed.connect(func() -> void: _on_start(challenge))
		_style_btn(btn, Color(0.10, 0.42, 0.18))
	panel.add_child(btn)

func _build_streak_row() -> void:
	var panel := _mk_panel(Vector2(18, 366), Vector2(444, 76))
	add_child(panel)

	var streak: int = int(SaveManager.get_setting("daily_streak", 0))
	var lbl := Label.new()
	lbl.text = "🔥  Streak:  " + str(streak) + " day" + ("s" if streak != 1 else "")
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.68, 0.22))
	lbl.size = Vector2(444, 76)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(lbl)

	var best: int = int(SaveManager.get_setting("daily_best_streak", 0))
	if best > 0:
		var lbl_best := Label.new()
		lbl_best.text = "Best: " + str(best)
		lbl_best.position = Vector2(350, 6)
		lbl_best.size = Vector2(88, 20)
		lbl_best.add_theme_font_size_override("font_size", 11)
		lbl_best.add_theme_color_override("font_color", C_DIM)
		lbl_best.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(lbl_best)

func _build_countdown_row() -> void:
	var panel := _mk_panel(Vector2(18, 454), Vector2(444, 72))
	add_child(panel)

	var prefix := Label.new()
	prefix.text = "⏰  Next challenge in:"
	prefix.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prefix.add_theme_font_size_override("font_size", 13)
	prefix.add_theme_color_override("font_color", C_DIM)
	prefix.size = Vector2(444, 30)
	prefix.position = Vector2(0, 2)
	prefix.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(prefix)

	_countdown_label = Label.new()
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_size_override("font_size", 20)
	_countdown_label.add_theme_color_override("font_color", C_GOLD)
	_countdown_label.size = Vector2(444, 36)
	_countdown_label.position = Vector2(0, 34)
	_countdown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_countdown_label)

	_update_countdown()

# ── Daily challenge logic ─────────────────────────────────────────────────────

func _today_challenge() -> Dictionary:
	var d := Time.get_date_dict_from_system()
	var seed_val := int(d.get("day", 1)) + int(d.get("month", 1)) * 31 + int(d.get("year", 2025)) * 366
	var idx  := seed_val % CHALLENGES.size()
	var lvl  := (seed_val % 6) + 1
	var c: Dictionary = CHALLENGES[idx].duplicate()
	c["level_id"] = lvl
	c["desc"]     = c["desc"] % lvl
	return c

func _is_today_done() -> bool:
	var today := _date_key()
	return SaveManager.get_setting("daily_done_date", "") == today

func _date_key() -> String:
	var d := Time.get_date_dict_from_system()
	return "%d-%02d-%02d" % [int(d.get("year", 0)), int(d.get("month", 0)), int(d.get("day", 0))]

func _update_countdown() -> void:
	if _countdown_label == null:
		return
	var now    := Time.get_unix_time_from_system()
	var dt     := Time.get_datetime_dict_from_unix_time(int(now))
	# Seconds until midnight
	var secs   := (23 - int(dt.get("hour", 0))) * 3600 + (59 - int(dt.get("minute", 0))) * 60 + (59 - int(dt.get("second", 0)))
	var h      := secs / 3600
	var m      := (secs % 3600) / 60
	var s      := secs % 60
	_countdown_label.text = "%02d : %02d : %02d" % [h, m, s]

func _start_countdown_timer() -> void:
	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.autostart = true
	_timer.timeout.connect(_update_countdown)
	add_child(_timer)

# ── Handlers ──────────────────────────────────────────────────────────────────

func _on_start(challenge: Dictionary) -> void:
	EventBus.play_sfx.emit("button")
	GameManager.in_daily_challenge     = true
	GameManager.daily_challenge_data   = challenge
	GameManager.go_to_gameplay_3d(int(challenge.get("level_id", 1)))

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

# ── Helpers ───────────────────────────────────────────────────────────────────

func _mk_panel(pos: Vector2, sz: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size     = sz
	var sb := StyleBoxFlat.new()
	sb.bg_color           = C_PANEL
	sb.border_color       = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.45)
	sb.border_width_left  = 1; sb.border_width_right  = 1
	sb.border_width_top   = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left     = 8; sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8; sb.corner_radius_bottom_right = 8
	p.add_theme_stylebox_override("panel", sb)
	return p

func _style_btn(btn: Button, col: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.corner_radius_top_left     = 8; sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8; sb.corner_radius_bottom_right = 8
	sb.border_color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.60)
	sb.border_width_left  = 1; sb.border_width_right  = 1
	sb.border_width_top   = 1; sb.border_width_bottom = 1
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("pressed", sb)
	var sbh := sb.duplicate() as StyleBoxFlat
	sbh.bg_color = col.lightened(0.12)
	btn.add_theme_stylebox_override("hover", sbh)
	btn.add_theme_color_override("font_color", C_GOLD)
