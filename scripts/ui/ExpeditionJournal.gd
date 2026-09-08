extends Control

const GOLD := Color("edc567")
const CREAM := Color("fff2ce")
const MUTED := Color("c7d8ba")
const FOREST := Color("193c2d")
const CAMPAIGN_LEVELS := 20

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	var rank: Dictionary = ExpeditionProgress.get_rank_progress()
	_build_ui(rank)
	Analytics.event("expedition_journal_opened", {"rank": int(rank.get("rank", 1))})
	EventBus.play_music.emit("menu")

func _build_ui(rank: Dictionary) -> void:
	var background := ColorRect.new()
	background.color = Color("0d241b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)
	var layout := _column(margin, 14)
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	layout.add_child(header)
	var back := _button(header, "< BACK", Color("294b39"), _on_back, 12)
	back.custom_minimum_size = Vector2(80, 48)
	var heading := _column(header, 0)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text(heading, "YOUR EXPEDITION", 12, GOLD)
	_text(heading, "Explorer journal", 23, CREAM)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	layout.add_child(scroll)
	var content := _column(scroll, 12)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build_rank(content, rank)

	var goals_header := _column(content, 3)
	_text(goals_header, "THREE GOALS. EVERY RUN COUNTS.", 14, GOLD)
	_text(goals_header, "Progress carries across runs. Goals never expire; coin rewards arrive automatically when you finish them.", 12, MUTED)
	for mission: Dictionary in ExpeditionProgress.get_missions():
		_build_mission(content, mission)
	_build_campaign(content)

	var actions := _column(layout, 8)
	var primary := _button(actions, "ENDLESS RUN", Color("aa6f17"), _on_endless, 18)
	primary.custom_minimum_size.y = 50
	primary.tooltip_text = "Collect coins and travel toward your goals. Endless Run costs no lives."
	primary.grab_focus.call_deferred()
	var map_button := _button(actions, "EXPEDITION MAP", Color("235d65"), _on_map, 14)
	map_button.custom_minimum_size.y = 42
	var hint := _text(actions, "Endless Run costs no lives. Campaign replays count toward goals.", 11, MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_rank(parent: Node, rank: Dictionary) -> void:
	var card := _card(parent, Color("234b36"))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	card.add_child(top)
	var rank_label := _text(top, "RANK %d" % int(rank.get("rank", 1)), 14, GOLD)
	rank_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rank_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var total_xp := _text(top, "%d total XP" % int(rank.get("xp", 0)), 12, MUTED)
	total_xp.autowrap_mode = TextServer.AUTOWRAP_OFF
	_text(card, str(rank.get("title", "New Explorer")), 24, CREAM)
	var needed := maxi(1, int(rank.get("needed", 100)))
	var current := clampi(int(rank.get("current", 0)), 0, needed)
	_progress(card, current, needed, GOLD, 10)
	_text(card, "%d / %d XP  •  %d XP to the next rank" % [current, needed, needed - current], 12, MUTED)
	_text(card, "Earn XP from coins, distance and completed levels.", 12, MUTED)

func _build_mission(parent: Node, mission: Dictionary) -> void:
	var card := _card(parent, FOREST)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 12)
	card.add_child(title_row)
	var title := _text(title_row, str(mission.get("title", "Explore the jungle")), 17, CREAM)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var reward := _text(title_row, "+%d coins" % int(mission.get("reward_coins", 0)), 13, GOLD)
	reward.autowrap_mode = TextServer.AUTOWRAP_OFF
	reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_text(card, str(mission.get("description", "Across any number of runs.")), 12, MUTED)
	var target := maxi(1, int(mission.get("target", 1)))
	var progress := clampi(int(mission.get("progress", 0)), 0, target)
	_progress(card, progress, target, Color("91bd76"), 9)
	var unit := str(mission.get("unit", ""))
	_text(card, "%d / %d %s" % [progress, target, unit], 12, MUTED)

func _build_campaign(parent: Node) -> void:
	var card := _card(parent, Color("18352b"))
	_text(card, "YOUR JOURNEY", 12, GOLD)
	var completed := SaveManager.get_completed_levels().size()
	var stars := SaveManager.get_total_stars()
	_text(card, "%d / %d levels complete   •   %d / %d stars" % [completed, CAMPAIGN_LEVELS, stars, CAMPAIGN_LEVELS * 3], 13, CREAM)
	_text(card, "Replay a favorite level to earn more stars and advance your goals.", 12, MUTED)

func _card(parent: Node, color: Color) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := _style(color)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return _column(panel, 6)

func _column(parent: Node, separation: int) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", separation)
	parent.add_child(column)
	return column

func _text(parent: Node, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _progress(parent: Node, value: int, maximum: int, color: Color, height: int) -> void:
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = height
	bar.max_value = maximum
	bar.value = value
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var track := StyleBoxFlat.new()
	track.bg_color = Color("0c2319")
	track.set_corner_radius_all(5)
	bar.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(5)
	bar.add_theme_stylebox_override("fill", fill)
	parent.add_child(bar)

func _style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(GOLD, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style

func _button(parent: Node, title: String, color: Color, callback: Callable, font_size: int) -> Button:
	var button := Button.new()
	button.text = title
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", CREAM)
	button.add_theme_color_override("font_pressed_color", CREAM)
	button.add_theme_stylebox_override("normal", _style(color))
	button.add_theme_stylebox_override("hover", _style(color.lightened(0.12)))
	button.add_theme_stylebox_override("pressed", _style(color.darkened(0.12)))
	var focus := _style(Color.TRANSPARENT)
	focus.border_color = CREAM
	focus.set_border_width_all(3)
	button.add_theme_stylebox_override("focus", focus)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back()

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

func _on_endless() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_endless()

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()
