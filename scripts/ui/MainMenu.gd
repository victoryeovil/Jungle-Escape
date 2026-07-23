extends Control

const BG_PATH := "res://assets/backgrounds/bg_main_home_v2.png"
const LEVEL_SELECT := "res://scenes/menus/LevelSelect.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	_build_background()
	_build_counters()
	_build_logo()
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
	shade.color = Color(0.0, 0.03, 0.01, 0.08)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

func _build_counters() -> void:
	_counter("COINS", str(SaveManager.get_coins()), Vector2(12, 10), Vector2(124, 40), Color("8a5b18"))
	_counter("GEMS", str(SaveManager.get_gems()), Vector2(178, 10), Vector2(124, 40), Color("175d76"))
	if SaveManager.should_show_lives():
		_counter("LIVES", SaveManager.get_lives_display(), Vector2(344, 10), Vector2(124, 40), Color("80362d"))

func _counter(kind: String, value: String, pos: Vector2, counter_size: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = "%s  %s" % [kind, value]
	label.position = pos
	label.size = counter_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("fff0bd"))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color, 0.94)
	style.border_color = Color("d5a132")
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	label.add_theme_stylebox_override("normal", style)
	add_child(label)

func _build_logo() -> void:
	var panel := Panel.new()
	panel.position = Vector2(100, 66)
	panel.size = Vector2(280, 132)
	var plaque := StyleBoxFlat.new()
	plaque.bg_color = Color(0.14, 0.065, 0.02, 0.95)
	plaque.border_color = Color("d29424")
	plaque.set_border_width_all(3)
	plaque.set_corner_radius_all(18)
	panel.add_theme_stylebox_override("panel", plaque)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	var title := _label("JUNGLE", Vector2(108, 74), Vector2(264, 48), 32, Color("ffc231"))
	title.add_theme_constant_override("outline_size", 5)
	title.add_theme_color_override("font_outline_color", Color("4a240e"))
	var second := _label("ESCAPE", Vector2(108, 111), Vector2(264, 44), 29, Color("fff1d0"))
	second.add_theme_constant_override("outline_size", 4)
	second.add_theme_color_override("font_outline_color", Color("4a240e"))
	_label("LOST PATH", Vector2(108, 157), Vector2(264, 28), 14, Color("ffc64b"))

func _build_menu() -> void:
	var entries: Array = [
		["BEGIN JOURNEY", "Start your adventure", Color("d79a24"), _on_play],
		["ENDLESS RUN", _endless_subtitle(), Color("52742b"), _on_endless],
		["CONTINUE EXPEDITION", "Pick up where you left off", Color("277b82"), _on_continue],
		["CHOOSE EXPLORER", "Select your adventurer", Color("74546f"), _on_shop],
		["DAILY EXPEDITION", "New challenges every day", Color("bd651d"), _on_daily_challenge],
		["YOUR LAND", "Build your jungle base", Color("365b6c"), _on_home_building],
	]
	if not SupabaseClient.is_authenticated():
		entries.append(["LOG IN", "Save your progress", Color("65441f"), _on_login])
	var item_height := 50.0
	var y := 218.0
	for entry: Array in entries:
		_menu_button(str(entry[0]), str(entry[1]), y, item_height, entry[2], entry[3])
		y += item_height + 6.0

	var settings := Button.new()
	settings.text = "SETTINGS"
	settings.position = Vector2(18, 800)
	settings.size = Vector2(118, 38)
	_style_button(settings, Color("503817"), 11)
	settings.pressed.connect(_on_settings)
	add_child(settings)
	var ranks := Button.new()
	ranks.text = "RANKS"
	ranks.position = Vector2(344, 800)
	ranks.size = Vector2(118, 38)
	_style_button(ranks, Color("594719"), 11)
	ranks.pressed.connect(_on_leaderboard)
	add_child(ranks)

func _endless_subtitle() -> String:
	var best := int(SaveManager.get_setting("endless_best_m", 0))
	return "How far can you go?" if best <= 0 else "Best distance: %d m" % best

func _menu_button(title: String, subtitle: String, y: float, height: float, color: Color, callback: Callable) -> void:
	var button := Button.new()
	button.text = "%s\n%s" % [title, subtitle]
	button.position = Vector2(156, y)
	button.size = Vector2(294, height)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_button(button, color, 13)
	button.pressed.connect(callback)
	add_child(button)

func _style_button(button: Button, color: Color, font_size: int) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color, 0.96)
	normal.border_color = Color("e0b251")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(10)
	normal.shadow_color = Color(0, 0, 0, 0.45)
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
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("fff2ce"))
	button.focus_mode = Control.FOCUS_NONE

func _label(text: String, pos: Vector2, label_size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _on_play() -> void:
	EventBus.play_sfx.emit("button")
	if ResourceLoader.exists(LEVEL_SELECT):
		GameManager.go_to_level_select()

func _on_endless() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_endless()

func _on_continue() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

func _on_shop() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/Shop.tscn")

func _on_daily_challenge() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/DailyChallenge.tscn")

func _on_login() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")

func _on_home_building() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_home_building()

func _on_settings() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/Settings.tscn")

func _on_leaderboard() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().change_scene_to_file("res://scenes/menus/Leaderboard.tscn")
