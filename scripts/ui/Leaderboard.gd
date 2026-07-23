extends Control

# ─── Weekly Leaderboard ──────────────────────────────────────────────────────
# Endless Run standings: This Week + All-Time tabs.
# Weekly rewards: when a new week starts, last week's top finishers claim gems
# the first time they open this screen.

const WEEKLY_REWARDS := [25, 15, 10, 5, 5, 5, 5, 5, 5, 5]   # gems for ranks 1-10

var _list_box: VBoxContainer = null
var _lbl_status: Label = null
var _lbl_my_best: Label = null
var _tab_week: Button = null
var _tab_alltime: Button = null
var _showing_week: bool = true

func _ready() -> void:
	_build_ui()
	_claim_last_week_reward()
	_load_board()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.07, 0.03)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var hdr := ColorRect.new()
	hdr.color = Color(0.05, 0.10, 0.04, 0.96)
	hdr.size = Vector2(480, 60)
	add_child(hdr)

	var btn_back := Button.new()
	btn_back.text = "←"
	btn_back.custom_minimum_size = Vector2(52, 44)
	btn_back.position = Vector2(6, 8)
	btn_back.pressed.connect(func() -> void:
		EventBus.play_sfx.emit("button")
		GameManager.go_to_menu()
	)
	hdr.add_child(btn_back)

	var title := Label.new()
	title.text = "🏆 Endless Leaderboard"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.96, 0.84, 0.42))
	title.size = Vector2(360, 44)
	title.position = Vector2(60, 10)
	hdr.add_child(title)

	# Tabs
	_tab_week = Button.new()
	_tab_week.text = "This Week"
	_tab_week.custom_minimum_size = Vector2(220, 42)
	_tab_week.position = Vector2(14, 70)
	_tab_week.pressed.connect(func() -> void: _switch_tab(true))
	add_child(_tab_week)

	_tab_alltime = Button.new()
	_tab_alltime.text = "All-Time"
	_tab_alltime.custom_minimum_size = Vector2(220, 42)
	_tab_alltime.position = Vector2(246, 70)
	_tab_alltime.pressed.connect(func() -> void: _switch_tab(false))
	add_child(_tab_alltime)

	# Weekly rewards banner
	var banner := Label.new()
	banner.text = "Weekly rewards every Monday:  🥇 25 💎   🥈 15 💎   🥉 10 💎   Top 10: 5 💎"
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 12)
	banner.add_theme_color_override("font_color", Color(0.78, 0.88, 0.60))
	banner.size = Vector2(480, 30)
	banner.position = Vector2(0, 118)
	add_child(banner)

	_lbl_my_best = Label.new()
	_lbl_my_best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_my_best.add_theme_font_size_override("font_size", 14)
	_lbl_my_best.add_theme_color_override("font_color", Color(0.55, 0.90, 1.0))
	_lbl_my_best.size = Vector2(480, 28)
	_lbl_my_best.position = Vector2(0, 148)
	add_child(_lbl_my_best)
	_lbl_my_best.text = "Your best run: %d m" % int(SaveManager.get_setting("endless_best_m", 0))

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(14, 184)
	scroll.size = Vector2(452, 590)
	add_child(scroll)
	_list_box = VBoxContainer.new()
	_list_box.custom_minimum_size = Vector2(436, 0)
	_list_box.add_theme_constant_override("separation", 8)
	scroll.add_child(_list_box)

	_lbl_status = Label.new()
	_lbl_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_status.add_theme_font_size_override("font_size", 14)
	_lbl_status.add_theme_color_override("font_color", Color(0.85, 0.80, 0.55))
	_lbl_status.size = Vector2(480, 60)
	_lbl_status.position = Vector2(0, 790)
	add_child(_lbl_status)
	_style_tabs()

func _switch_tab(week: bool) -> void:
	if _showing_week == week:
		return
	EventBus.play_sfx.emit("button")
	_showing_week = week
	_style_tabs()
	_load_board()

func _style_tabs() -> void:
	for entry in [[_tab_week, _showing_week], [_tab_alltime, not _showing_week]]:
		var btn := entry[0] as Button
		var active := bool(entry[1])
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.16, 0.28, 0.10, 0.95) if active else Color(0.06, 0.10, 0.05, 0.85)
		sb.border_color = Color(0.90, 0.74, 0.22) if active else Color(0.35, 0.32, 0.20)
		sb.border_width_bottom = 3
		sb.corner_radius_top_left = 8
		sb.corner_radius_top_right = 8
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		btn.add_theme_color_override("font_color", Color(0.96, 0.90, 0.70) if active else Color(0.62, 0.60, 0.48))

func _load_board() -> void:
	for child in _list_box.get_children():
		child.queue_free()
	if not SupabaseClient.is_authenticated():
		_lbl_status.text = "Log in to compete and win weekly gem rewards!"
		return
	_lbl_status.text = "Loading standings…"
	if _showing_week:
		SupabaseClient.fetch_weekly_top(SupabaseClient.week_key(), 10, _on_rows)
	else:
		SupabaseClient.fetch_endless_top(10, _on_rows)

func _on_rows(rows: Array) -> void:
	if not is_inside_tree():
		return
	if rows.is_empty():
		_lbl_status.text = "No runs yet this week — set the first record!" if _showing_week else "No runs recorded yet."
		return
	_lbl_status.text = ""
	var my_id := SupabaseClient.get_user_id()
	var rank := 1
	for raw in rows:
		if not (raw is Dictionary):
			continue
		var row: Dictionary = raw
		var is_me := str(row.get("user_id", "")) == my_id and not my_id.is_empty()
		_list_box.add_child(_make_row(rank, str(row.get("display_name", "Explorer")), int(row.get("best_distance_m", 0)), is_me))
		rank += 1

func _make_row(rank: int, display_name: String, distance: int, highlight: bool) -> Control:
	var row := ColorRect.new()
	row.custom_minimum_size = Vector2(436, 52)
	row.color = Color(0.14, 0.22, 0.08, 0.92) if highlight else Color(0.07, 0.10, 0.04, 0.88)

	var medal: String = ["🥇", "🥈", "🥉"][rank - 1] if rank <= 3 else str(rank) + "."
	var lbl_rank := Label.new()
	lbl_rank.text = medal
	lbl_rank.add_theme_font_size_override("font_size", 18)
	lbl_rank.size = Vector2(56, 52)
	lbl_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_rank.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl_rank)

	var lbl_name := Label.new()
	lbl_name.text = display_name + ("   ← you" if highlight else "")
	lbl_name.add_theme_font_size_override("font_size", 15)
	lbl_name.add_theme_color_override("font_color", Color(0.96, 0.92, 0.72) if highlight else Color(0.85, 0.82, 0.64))
	lbl_name.position = Vector2(60, 0)
	lbl_name.size = Vector2(250, 52)
	lbl_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(lbl_name)

	var lbl_dist := Label.new()
	lbl_dist.text = str(distance) + " m"
	lbl_dist.add_theme_font_size_override("font_size", 16)
	lbl_dist.add_theme_color_override("font_color", Color(0.55, 0.90, 1.0))
	lbl_dist.position = Vector2(316, 0)
	lbl_dist.size = Vector2(110, 52)
	lbl_dist.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_dist.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl_dist)
	return row

# ─── Weekly reward claim ─────────────────────────────────────────────────────

func _claim_last_week_reward() -> void:
	if not SupabaseClient.is_authenticated():
		return
	var last_week := SupabaseClient.week_key(1)
	var claim_key := "weekly_reward_claimed_" + last_week
	if bool(SaveManager.get_setting(claim_key, false)):
		return
	SupabaseClient.fetch_weekly_top(last_week, WEEKLY_REWARDS.size(), func(rows: Array) -> void:
		if not is_inside_tree():
			return
		SaveManager.set_setting(claim_key, true)   # one claim check per week
		var my_id := SupabaseClient.get_user_id()
		var rank := 1
		for raw in rows:
			if raw is Dictionary and str((raw as Dictionary).get("user_id", "")) == my_id:
				var gems: int = WEEKLY_REWARDS[rank - 1]
				SaveManager.add_gems(gems)
				EventBus.play_sfx.emit("stars_3")
				_lbl_status.text = "🏆 Last week you placed #%d — reward: %d 💎!" % [rank, gems]
				return
			rank += 1
	)
