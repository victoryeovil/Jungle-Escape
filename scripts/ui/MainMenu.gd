extends Control

const BG_PATH := "res://assets/backgrounds/bg_main_home_v2.png"
const CAMPAIGN_LEVELS := 20
const JOURNAL_PATH := "res://scenes/menus/ExpeditionJournal.tscn"
const GOLD := Color("edc567")
const CREAM := Color("fff2ce")

var _continue_level: int = 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	_continue_level = _next_campaign_level()
	GameManager.clear_daily_challenge()
	_build_background()
	_build_counters()
	_build_logo()
	_build_expedition_card()
	_build_menu()
	EventBus.play_music.emit("menu")

func _build_background() -> void:
	var background := TextureRect.new()
	background.texture = load(BG_PATH)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.03, 0.01, 0.12)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

func _build_counters() -> void:
	_counter("COINS", str(SaveManager.get_coins()), Vector2(12, 12), Color("8a5b18"))
	_counter("GEMS", str(SaveManager.get_gems()), Vector2(178, 12), Color("175d76"))
	if SaveManager.should_show_lives():
		_counter("LIVES", SaveManager.get_lives_display(), Vector2(344, 12), Color("80362d"))

func _counter(kind: String, value: String, pos: Vector2, color: Color) -> void:
	var label := _label("%s  %s" % [kind, value], pos, Vector2(124, 40), 12, CREAM)
	label.add_theme_stylebox_override("normal", _panel_style(color, 14))

func _build_logo() -> void:
	var panel := Panel.new()
	panel.position = Vector2(100, 68)
	panel.size = Vector2(280, 116)
	panel.add_theme_stylebox_override("panel", _panel_style(Color("2a1709"), 18))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	var title := _label("JUNGLE", Vector2(108, 70), Vector2(264, 45), 32, Color("ffc231"))
	title.add_theme_constant_override("outline_size", 4)
	title.add_theme_color_override("font_outline_color", Color("4a240e"))
	_label("ESCAPE", Vector2(108, 108), Vector2(264, 40), 29, CREAM)
	_label("LOST PATH", Vector2(108, 150), Vector2(264, 24), 13, GOLD)

func _build_expedition_card() -> void:
	var rank: Dictionary = ExpeditionProgress.get_rank_progress()
	var missions: Array = ExpeditionProgress.get_missions()
	var journal := Button.new()
	journal.position = Vector2(28, 200)
	journal.size = Vector2(424, 112)
	journal.tooltip_text = "Open your expedition journal to see all three goals and explorer rank."
	_style_button(journal, Color("193c2d"), 13)
	journal.pressed.connect(_on_journal)
	add_child(journal)
	_button_label(journal, "RANK %d  /  %s" % [int(rank.get("rank", 1)), str(rank.get("title", "New Explorer"))], Vector2(16, 8), Vector2(296, 24), 13, GOLD)
	_button_label(journal, "JOURNAL >", Vector2(317, 8), Vector2(96, 24), 11, CREAM)
	if missions.is_empty():
		_button_label(journal, "Your next adventure starts here", Vector2(16, 36), Vector2(392, 30), 16, CREAM)
		return
	# Surface the goal closest to its reward, so returning players have a clear next step.
	var featured: Dictionary = missions[0]
	for entry: Dictionary in missions:
		if _mission_fraction(entry) > _mission_fraction(featured):
			featured = entry
	_button_label(journal, str(featured.get("title", "Explore the jungle")), Vector2(16, 35), Vector2(392, 28), 16, CREAM)
	var target := maxi(1, int(featured.get("target", 1)))
	var progress := clampi(int(featured.get("progress", 0)), 0, target)
	_progress_bar(journal, Vector2(16, 70), Vector2(392, 8), progress, target)
	_button_label(journal, "%d / %d  %s" % [progress, target, str(featured.get("unit", ""))], Vector2(16, 83), Vector2(242, 20), 12, Color("c7d8ba"))
	_button_label(journal, "+%d coins" % int(featured.get("reward_coins", 0)), Vector2(299, 83), Vector2(108, 20), 12, GOLD)

func _build_menu() -> void:
	var primary := _menu_button(_journey_title(), _journey_subtitle(), Rect2(28, 328, 424, 70), Color("aa6f17"), _on_continue, 19)
	primary.grab_focus.call_deferred()
	_menu_button("ENDLESS RUN", _endless_subtitle(), Rect2(28, 412, 206, 70), Color("375f28"), _on_endless, 15)
	_menu_button("DAILY EXPEDITION", _daily_subtitle(), Rect2(246, 412, 206, 70), Color("88511e"), _on_daily_challenge, 14)
	_menu_button("EXPEDITION MAP", "Choose a level or earn more stars", Rect2(156, 500, 296, 50), Color("235d65"), _on_map)
	_menu_button("CHOOSE EXPLORER", "Find your next unlock", Rect2(156, 560, 296, 50), Color("63455c"), _on_shop)
	_menu_button("YOUR LAND", "Grow your jungle home", Rect2(156, 620, 296, 50), Color("365b4a"), _on_home_building)
	if not SupabaseClient.is_authenticated():
		_menu_button("LOG IN", "Connect your explorer account", Rect2(156, 680, 296, 50), Color("59401f"), _on_login)
	_small_button("SETTINGS", Rect2(18, 798, 118, 40), _on_settings)
	_small_button("RANKS", Rect2(344, 798, 118, 40), _on_leaderboard)

func _next_campaign_level() -> int:
	var next_level := 1
	for level_id in range(1, CAMPAIGN_LEVELS + 1):
		if SaveManager.is_level_unlocked(level_id):
			next_level = level_id
	return next_level

func _journey_title() -> String:
	if SaveManager.get_completed_levels().is_empty():
		return "BEGIN JOURNEY"
	if SaveManager.is_level_completed(CAMPAIGN_LEVELS):
		return "REPLAY JOURNEY"
	return "CONTINUE JOURNEY"

func _journey_subtitle() -> String:
	if _continue_level > 3 and not SupabaseClient.has_registration_key():
		return "Level %d awaits - connect your account" % _continue_level
	if not SaveManager.can_start_level(_continue_level):
		return "Restock lives on the map, or try Endless Run"
	if SaveManager.is_level_completed(CAMPAIGN_LEVELS):
		return "Level %d - improve your stars and goals" % _continue_level
	return "Level %d of %d - your next adventure" % [_continue_level, CAMPAIGN_LEVELS]

func _endless_subtitle() -> String:
	var best := int(SaveManager.get_setting("endless_best_m", 0))
	var goal := (int(best / 100.0) + 1) * 100
	return "Aim for %d m - no lives cost" % goal if best <= 0 else "Best %d m  /  Next %d m" % [best, goal]

func _daily_subtitle() -> String:
	var d := Time.get_date_dict_from_system()
	var today := "%d-%02d-%02d" % [int(d.get("year", 0)), int(d.get("month", 0)), int(d.get("day", 0))]
	if str(SaveManager.get_setting("daily_done_date", "")) == today:
		return "Completed - new quest tomorrow"
	return "Today's challenge is ready"

func _menu_button(title: String, subtitle: String, rect: Rect2, color: Color, callback: Callable, font_size: int = 14) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.tooltip_text = title + ". " + subtitle
	_style_button(button, color, font_size)
	button.pressed.connect(callback)
	add_child(button)
	var top := 9.0 if rect.size.y > 60 else 2.0
	var title_label := _button_label(button, title, Vector2(8, top), Vector2(rect.size.x - 16, 27), font_size, CREAM)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var subtitle_label := _button_label(button, subtitle, Vector2(8, top + 27), Vector2(rect.size.x - 16, 19), 11, Color("f2e2b8"))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button

func _small_button(title: String, rect: Rect2, callback: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.position = rect.position
	button.size = rect.size
	_style_button(button, Color("493719"), 11)
	button.pressed.connect(callback)
	add_child(button)

func _panel_style(color: Color, radius: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color, 0.97)
	style.border_color = Color(GOLD, 0.75)
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	return style

func _style_button(button: Button, color: Color, font_size: int) -> void:
	var normal := _panel_style(color)
	normal.shadow_color = Color(0, 0, 0, 0.4)
	normal.shadow_size = 3
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = color.lightened(0.13)
	button.add_theme_stylebox_override("hover", hover)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = color.darkened(0.14)
	button.add_theme_stylebox_override("pressed", pressed)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = CREAM
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(10)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", CREAM)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _label(text: String, pos: Vector2, label_size: Vector2, font_size: int, color: Color) -> Label:
	var label := _button_label(self, text, pos, label_size, font_size, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func _button_label(parent: Node, text: String, pos: Vector2, label_size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = label_size
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _progress_bar(parent: Node, pos: Vector2, bar_size: Vector2, progress: int, target: int) -> void:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = bar_size
	bar.max_value = target
	bar.value = progress
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var track := StyleBoxFlat.new()
	track.bg_color = Color("10281e")
	track.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = GOLD
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", fill)
	# Assign the final size after replacing the theme's taller default track.
	bar.size = bar_size
	parent.add_child(bar)
	bar.set_deferred("size", bar_size)

func _mission_fraction(mission: Dictionary) -> float:
	return float(mission.get("progress", 0)) / float(maxi(1, int(mission.get("target", 1))))

func _on_continue() -> void:
	EventBus.play_sfx.emit("button")
	Analytics.event("home_action", {"action": "continue", "level_id": _continue_level})
	GameManager.clear_daily_challenge()
	if _continue_level > 3 and not SupabaseClient.has_registration_key():
		GameManager.go_to_login_prompt(true, _continue_level)
		return
	if not SaveManager.can_start_level(_continue_level) or (_continue_level == 6 and not SaveManager.has_upgrade("sand_shoes")):
		GameManager.go_to_level_select()
		return
	GameManager.go_to_gameplay_3d(_continue_level)

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

func _on_journal() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file(JOURNAL_PATH)

func _on_endless() -> void:
	EventBus.play_sfx.emit("button")
	Analytics.event("home_action", {"action": "endless"})
	GameManager.go_to_endless()

func _on_shop() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/Shop.tscn")

func _on_daily_challenge() -> void:
	EventBus.play_sfx.emit("button")
	Analytics.event("home_action", {"action": "daily"})
	get_tree().change_scene_to_file("res://scenes/menus/DailyChallenge.tscn")

func _on_login() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_login_prompt()

func _on_home_building() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_home_building()

func _on_settings() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/Settings.tscn")

func _on_leaderboard() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/Leaderboard.tscn")
