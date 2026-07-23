extends Control

# Hands-on home construction. Players choose the land and plan, then tap the
# actual building site to place every piece. Partial progress survives leaving.

const STAGE_PIECES := {1: 6, 2: 10, 3: 6, 4: 2, 5: 5}
const SITE_RECT := Rect2(18, 86, 444, 500)
const LAND_ART_PATH := "res://assets/backgrounds/bg_land_selection_v2.png"

var _status_label: Label
var _instruction_label: Label
var _stage_label: Label
var _progress_fill: ColorRect
var _resource_label: Label
var _site_button: Button
var _land_panel: Control
var _plan_panel: Control
var _pulse := 0.0
var _using_land_art := false

func _ready() -> void:
	if _selected_plot().is_empty():
		_build_land_art_screen()
		EventBus.play_music.emit("menu")
		return
	_build_interface()
	_refresh()
	EventBus.play_music.emit("menu")

func _process(delta: float) -> void:
	_pulse += delta
	queue_redraw()

func _draw() -> void:
	if _using_land_art:
		return
	# Layered sky and ground give the construction view depth without hiding it
	# behind a pre-rendered purchase screen.
	draw_rect(Rect2(0, 0, 480, 854), Color("102917"))
	draw_rect(SITE_RECT, Color("78b8c5"))
	draw_rect(Rect2(18, 270, 444, 316), _plot_ground_color())
	draw_circle(Vector2(405, 132), 42.0, Color(1.0, 0.78, 0.24, 0.85))
	_draw_distant_jungle()
	_draw_plot_features()
	if not _selected_plot().is_empty():
		_draw_house()
		_draw_build_marker()

func _build_land_art_screen() -> void:
	_using_land_art = true
	var background := TextureRect.new()
	background.texture = load(LAND_ART_PATH)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# The illustrated cards are the controls. Transparent hit areas preserve the
	# supplied design while keeping the choices fully functional.
	_land_art_hit(Rect2(8, 12, 56, 52), _on_back)
	var card_rects := [
		Rect2(24, 152, 434, 168),
		Rect2(24, 324, 434, 155),
		Rect2(24, 485, 434, 151),
	]
	for i in range(Constants.LAND_PLOTS.size()):
		var plot: Dictionary = Constants.LAND_PLOTS[i]
		var button := _land_art_hit(card_rects[i], _choose_land.bind(plot))
		button.disabled = not SaveManager.is_level_completed(int(plot.get("unlock_level", 1)))
	_land_art_hit(Rect2(98, 741, 287, 72), _on_back)

	# Replace the sample currency values in the artwork with live save values.
	_land_counter(Vector2(244, 19), Vector2(78, 31), str(SaveManager.get_coins()))
	_land_counter(Vector2(361, 19), Vector2(70, 31), str(SaveManager.get_gems()))
	_status_label = Label.new()
	_status_label.position = Vector2(42, 700)
	_status_label.size = Vector2(396, 34)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 13)
	_status_label.add_theme_color_override("font_color", Color("fff2b4"))
	_status_label.add_theme_color_override("font_outline_color", Color("21330e"))
	_status_label.add_theme_constant_override("outline_size", 4)
	add_child(_status_label)

func _land_art_hit(rect: Rect2, callback: Callable) -> Button:
	var button := Button.new()
	button.flat = true
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	add_child(button)
	return button

func _land_counter(pos: Vector2, counter_size: Vector2, value: String) -> void:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.size = counter_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("fff0bd"))
	var style := StyleBoxFlat.new()
	style.bg_color = Color("3d2812")
	style.set_corner_radius_all(12)
	label.add_theme_stylebox_override("normal", style)
	add_child(label)

func _draw_distant_jungle() -> void:
	var tree_color := Color("245e31")
	for i in range(10):
		var x := 30.0 + float(i) * 46.0
		var h := 52.0 + float((i * 23) % 50)
		draw_rect(Rect2(x - 4, 270 - h * 0.45, 8, h), Color("4f3b24"))
		draw_circle(Vector2(x, 235 - h * 0.45), 30.0, tree_color)

func _draw_plot_features() -> void:
	match str(SaveManager.get_setting("home_plot", "")):
		"riverside":
			draw_colored_polygon(PackedVector2Array([Vector2(18, 512), Vector2(462, 474), Vector2(462, 586), Vector2(18, 586)]), Color("2787ad"))
			for i in range(6):
				draw_line(Vector2(30 + i * 68, 535), Vector2(76 + i * 68, 528), Color(0.7, 0.94, 1.0, 0.55), 2.0)
		"savanna":
			draw_circle(Vector2(84, 356), 58, Color("bc9a47"))
			draw_line(Vector2(84, 300), Vector2(84, 400), Color("5a3d1f"), 12)
		"baobab":
			draw_line(Vector2(392, 210), Vector2(386, 440), Color("6f4b2a"), 42)
			draw_circle(Vector2(382, 206), 74, Color("36743c"))
		_:
			pass

func _draw_house() -> void:
	var current := SaveManager.get_home_stage()
	var center := Vector2(240, 414)
	# Cleared land / construction pad.
	draw_colored_polygon(PackedVector2Array([center + Vector2(-158, 100), center + Vector2(0, 154), center + Vector2(158, 100), center + Vector2(0, 48)]), Color("ad8950"))

	var foundation_parts := _visible_piece_count(1)
	for i in range(foundation_parts):
		var col := i % 3
		var row := i / 3
		var p := center + Vector2(-116 + col * 78, 84 + row * 28)
		draw_colored_polygon(PackedVector2Array([p, p + Vector2(58, -18), p + Vector2(112, 0), p + Vector2(54, 20)]), Color("b98b55"))
		draw_polyline(PackedVector2Array([p, p + Vector2(58, -18), p + Vector2(112, 0), p + Vector2(54, 20), p]), Color("69482d"), 2)

	var wall_parts := _visible_piece_count(2)
	for i in range(wall_parts):
		var side_right := i >= 5
		var row := (i if not side_right else i - 5)
		if not side_right:
			var y := 438.0 - row * 25.0
			draw_rect(Rect2(128, y, 224, 23), Color("c58a4b"))
			draw_line(Vector2(128, y), Vector2(352, y), Color("704427"), 2)
			for brick in range(1, 5):
				draw_line(Vector2(128 + brick * 45 + (22 if row % 2 else 0), y), Vector2(128 + brick * 45 + (22 if row % 2 else 0), y + 23), Color("8b5934"), 1)
		else:
			var y2 := 438.0 - row * 25.0
			draw_colored_polygon(PackedVector2Array([Vector2(352, y2), Vector2(400, y2 - 18), Vector2(400, y2 + 5), Vector2(352, y2 + 23)]), Color("a9703e"))

	var roof_parts := _visible_piece_count(3)
	if roof_parts > 0:
		var roof_color := Color("a94125")
		var roof_points := [
			PackedVector2Array([Vector2(112, 334), Vector2(240, 274), Vector2(260, 300), Vector2(134, 359)]),
			PackedVector2Array([Vector2(240, 274), Vector2(408, 326), Vector2(382, 351), Vector2(260, 300)]),
			PackedVector2Array([Vector2(134, 359), Vector2(260, 300), Vector2(382, 351), Vector2(256, 410)]),
			PackedVector2Array([Vector2(112, 334), Vector2(134, 359), Vector2(256, 410), Vector2(228, 379)]),
			PackedVector2Array([Vector2(228, 379), Vector2(256, 410), Vector2(382, 351), Vector2(350, 382)]),
			PackedVector2Array([Vector2(226, 278), Vector2(244, 268), Vector2(416, 320), Vector2(401, 332)]),
		]
		for i in range(mini(roof_parts, roof_points.size())):
			draw_colored_polygon(roof_points[i], roof_color.lightened(float(i % 2) * 0.09))
			draw_polyline(roof_points[i], Color("612618"), 2)

	var window_parts := _visible_piece_count(4)
	if window_parts >= 1:
		_draw_window(Rect2(156, 370, 42, 48))
	if window_parts >= 2:
		_draw_window(Rect2(284, 370, 42, 48))

	var finish_parts := _visible_piece_count(5)
	if finish_parts >= 1:
		draw_rect(Rect2(218, 388, 52, 70), Color("654225"))
		draw_circle(Vector2(258, 424), 3, Color("f5c84b"))
	if finish_parts >= 2:
		draw_line(Vector2(240, 458), Vector2(240, 540), Color("d6bd77"), 38)
	if finish_parts >= 3:
		draw_circle(Vector2(105, 474), 32, Color("3e873f"))
	if finish_parts >= 4:
		draw_circle(Vector2(372, 474), 30, Color("3e873f"))
	if finish_parts >= 5:
		draw_string(ThemeDB.fallback_font, Vector2(178, 558), "YOUR JUNGLE HOME", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("ffe08a"))

	if current >= Constants.HOME_STAGES.size():
		draw_arc(Vector2(240, 330), 176 + sin(_pulse * 2.0) * 4.0, 0, TAU, 48, Color(1.0, 0.82, 0.25, 0.45), 4)

func _draw_window(rect: Rect2) -> void:
	draw_rect(rect, Color("52b7d6"))
	draw_rect(rect, Color("f5d96e"), false, 3)
	draw_line(rect.position + Vector2(rect.size.x * 0.5, 0), rect.position + Vector2(rect.size.x * 0.5, rect.size.y), Color("704427"), 2)
	draw_line(rect.position + Vector2(0, rect.size.y * 0.5), rect.position + Vector2(rect.size.x, rect.size.y * 0.5), Color("704427"), 2)

func _draw_build_marker() -> void:
	var stage := SaveManager.get_home_stage()
	if stage <= 0 or stage >= Constants.HOME_STAGES.size():
		return
	var y := 320.0 + sin(_pulse * 4.0) * 7.0
	draw_circle(Vector2(240, y), 24, Color(1.0, 0.78, 0.18, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(232, y + 8), "+", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)

func _visible_piece_count(stage: int) -> int:
	var current := SaveManager.get_home_stage()
	var goal := int(STAGE_PIECES.get(stage, 0))
	if current > stage:
		return goal
	if current < stage:
		return 0
	return clampi(int(SaveManager.get_setting(_progress_key(stage), 0)), 0, goal)

func _build_interface() -> void:
	var header := ColorRect.new()
	header.color = Color(0.02, 0.08, 0.03, 0.95)
	header.position = Vector2(0, 0)
	header.size = Vector2(480, 72)
	add_child(header)

	var back := Button.new()
	back.text = "<"
	back.position = Vector2(10, 12)
	back.size = Vector2(52, 46)
	_style_button(back, Color("315526"))
	back.pressed.connect(_on_back)
	header.add_child(back)

	var title := Label.new()
	title.text = "BUILD YOUR HOME"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.position = Vector2(72, 10)
	title.size = Vector2(280, 48)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("ffe08a"))
	header.add_child(title)

	_resource_label = Label.new()
	_resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_resource_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_resource_label.position = Vector2(350, 10)
	_resource_label.size = Vector2(118, 48)
	_resource_label.add_theme_font_size_override("font_size", 13)
	_resource_label.add_theme_color_override("font_color", Color("ffd44f"))
	header.add_child(_resource_label)

	_site_button = Button.new()
	_site_button.flat = true
	_site_button.position = SITE_RECT.position
	_site_button.size = SITE_RECT.size
	_site_button.focus_mode = Control.FOCUS_NONE
	_site_button.pressed.connect(_on_site_tapped)
	add_child(_site_button)

	var tray := ColorRect.new()
	tray.color = Color(0.025, 0.075, 0.025, 0.96)
	tray.position = Vector2(0, 602)
	tray.size = Vector2(480, 252)
	add_child(tray)

	_stage_label = Label.new()
	_stage_label.position = Vector2(20, 14)
	_stage_label.size = Vector2(440, 32)
	_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stage_label.add_theme_font_size_override("font_size", 20)
	_stage_label.add_theme_color_override("font_color", Color("ffe08a"))
	tray.add_child(_stage_label)

	_instruction_label = Label.new()
	_instruction_label.position = Vector2(24, 52)
	_instruction_label.size = Vector2(432, 48)
	_instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_instruction_label.add_theme_font_size_override("font_size", 14)
	_instruction_label.add_theme_color_override("font_color", Color("d7edbb"))
	tray.add_child(_instruction_label)

	var progress_bg := ColorRect.new()
	progress_bg.color = Color("142313")
	progress_bg.position = Vector2(38, 112)
	progress_bg.size = Vector2(404, 20)
	tray.add_child(progress_bg)
	_progress_fill = ColorRect.new()
	_progress_fill.color = Color("e7a72d")
	_progress_fill.size = Vector2(0, 20)
	progress_bg.add_child(_progress_fill)

	_status_label = Label.new()
	_status_label.position = Vector2(20, 144)
	_status_label.size = Vector2(440, 30)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 13)
	_status_label.add_theme_color_override("font_color", Color("ffc85a"))
	tray.add_child(_status_label)

	var explore := Button.new()
	explore.text = "EXPLORE FOR MATERIALS"
	explore.position = Vector2(94, 188)
	explore.size = Vector2(292, 48)
	_style_button(explore, Color("286d36"))
	explore.pressed.connect(_on_back)
	tray.add_child(explore)

func _refresh() -> void:
	_clear_picker()
	_resource_label.text = "%d coins\n%d gems" % [SaveManager.get_coins(), SaveManager.get_gems()]
	var plot := _selected_plot()
	if plot.is_empty():
		_site_button.disabled = true
		_stage_label.text = "CHOOSE YOUR LAND"
		_instruction_label.text = "Pick the place where your home will stand. Each plot has its own scenery and perk."
		_progress_fill.size.x = 0
		_show_land_choices()
		queue_redraw()
		return

	var stage := SaveManager.get_home_stage()
	_site_button.disabled = stage >= Constants.HOME_STAGES.size()
	if stage >= Constants.HOME_STAGES.size():
		_stage_label.text = "%s COMPLETE" % str(_selected_plan().get("name", "HOME")).to_upper()
		_instruction_label.text = "Your home is standing! Tap Explore to collect more treasures."
		_progress_fill.size.x = 404
		queue_redraw()
		return

	if stage == 1 and _selected_plan().is_empty():
		_site_button.disabled = true
		_stage_label.text = "CHOOSE A HOUSE PLAN"
		_instruction_label.text = "Decide what you want to build before laying the first stone."
		_progress_fill.size.x = 0
		_show_plan_choices()
		queue_redraw()
		return

	var goal := int(STAGE_PIECES.get(stage, 1))
	var placed := int(SaveManager.get_setting(_progress_key(stage), 0))
	_stage_label.text = "STAGE %d: %s" % [stage + 1, str(Constants.HOME_STAGES[stage].get("name", "Build"))]
	if bool(SaveManager.get_setting(_paid_key(stage), false)):
		_instruction_label.text = "Tap the glowing marker to place each piece.  %d / %d placed." % [placed, goal]
	else:
		_instruction_label.text = "Tap the site to begin. Materials: %s" % _cost_text(_effective_cost(stage))
	_progress_fill.size.x = 404.0 * float(placed) / float(goal)
	queue_redraw()

func _show_land_choices() -> void:
	_land_panel = Control.new()
	_land_panel.position = Vector2(20, 100)
	_land_panel.size = Vector2(440, 470)
	add_child(_land_panel)
	var colors := [Color("26758c"), Color("bd8c39"), Color("4e7136")]
	for i in range(Constants.LAND_PLOTS.size()):
		var plot: Dictionary = Constants.LAND_PLOTS[i]
		var card := Button.new()
		card.position = Vector2(8, 10 + i * 148)
		card.size = Vector2(424, 132)
		card.text = "%s\n%s\n%s\nCost: %s" % [str(plot.get("name", "Land")), str(plot.get("perk", "")), "Available after Level %d" % int(plot.get("unlock_level", 1)), _cost_text(plot.get("cost", {}))]
		card.disabled = not SaveManager.is_level_unlocked(int(plot.get("unlock_level", 1)))
		_style_button(card, colors[i])
		var chosen: Dictionary = plot
		card.pressed.connect(func(): _choose_land(chosen))
		_land_panel.add_child(card)

func _show_plan_choices() -> void:
	_plan_panel = Control.new()
	_plan_panel.position = Vector2(20, 100)
	_plan_panel.size = Vector2(440, 470)
	add_child(_plan_panel)
	var colors := [Color("6d4a25"), Color("38605a"), Color("5a3b66")]
	for i in range(Constants.HOUSE_PLANS.size()):
		var plan: Dictionary = Constants.HOUSE_PLANS[i]
		var card := Button.new()
		card.position = Vector2(8, 10 + i * 148)
		card.size = Vector2(424, 132)
		card.text = "%s\n%s\nBuild cost x%.1f  |  Completion: %d gems" % [str(plan.get("name", "Plan")), str(plan.get("desc", "")), float(plan.get("cost_scale", 1.0)), int(plan.get("reward_gems", 10))]
		_style_button(card, colors[i])
		var chosen: Dictionary = plan
		card.pressed.connect(func(): _choose_plan(chosen))
		_plan_panel.add_child(card)

func _choose_land(plot: Dictionary) -> void:
	var cost: Dictionary = plot.get("cost", {})
	if not _can_afford(cost):
		_show_status("You need more materials for this land.")
		return
	_spend(cost)
	SaveManager.set_setting("home_plot", str(plot.get("id", "")))
	SaveManager.set_home_stage(1)
	SaveManager.add_gems(Constants.HOME_STAGE_REWARD_GEMS)
	EventBus.play_sfx.emit("stars_2")
	_show_status("Land chosen. Now choose the home you want to build.")
	if _using_land_art:
		get_tree().reload_current_scene()
		return
	_refresh()

func _choose_plan(plan: Dictionary) -> void:
	SaveManager.set_setting("home_plan", str(plan.get("id", "")))
	EventBus.play_sfx.emit("button")
	_show_status("Plan selected. Tap the site to lay your foundation.")
	_refresh()

func _on_site_tapped() -> void:
	var stage := SaveManager.get_home_stage()
	if stage <= 0 or stage >= Constants.HOME_STAGES.size():
		return
	if stage == 1 and _selected_plan().is_empty():
		_refresh()
		return
	var paid_key := _paid_key(stage)
	if not bool(SaveManager.get_setting(paid_key, false)):
		var cost := _effective_cost(stage)
		if not _can_afford(cost):
			_show_status("Not enough materials. Explore more, then come back.")
			return
		_spend(cost)
		SaveManager.set_setting(paid_key, true)

	var key := _progress_key(stage)
	var goal := int(STAGE_PIECES.get(stage, 1))
	var placed := mini(goal, int(SaveManager.get_setting(key, 0)) + 1)
	SaveManager.set_setting(key, placed)
	EventBus.play_sfx.emit("button")
	Input.vibrate_handheld(35)
	_spawn_build_feedback(stage)
	if placed >= goal:
		_finish_stage(stage)
	else:
		_show_status(_placement_message(stage, placed, goal))
	_refresh()

func _finish_stage(stage: int) -> void:
	SaveManager.set_home_stage(stage + 1)
	SaveManager.set_setting(_paid_key(stage), false)
	SaveManager.add_gems(Constants.HOME_STAGE_REWARD_GEMS)
	Input.vibrate_handheld(120)
	if stage + 1 >= Constants.HOME_STAGES.size():
		var bonus := int(_selected_plan().get("reward_gems", 10))
		SaveManager.add_gems(bonus)
		EventBus.play_sfx.emit("stars_3")
		_show_status("Home complete! You built every part. +%d gems" % (bonus + Constants.HOME_STAGE_REWARD_GEMS))
	else:
		EventBus.play_sfx.emit("stars_2")
		_show_status("Stage complete! The house is taking shape.")

func _spawn_build_feedback(stage: int) -> void:
	var chip := Label.new()
	chip.text = ["STONE", "BRICK", "TILE", "WINDOW", "DETAIL"][clampi(stage - 1, 0, 4)]
	chip.position = Vector2(188, 322)
	chip.size = Vector2(104, 34)
	chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.add_theme_font_size_override("font_size", 16)
	chip.add_theme_color_override("font_color", Color("fff1a1"))
	add_child(chip)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(chip, "position:y", 270.0, 0.45)
	tween.tween_property(chip, "modulate:a", 0.0, 0.45)
	tween.chain().tween_callback(chip.queue_free)

func _placement_message(stage: int, placed: int, goal: int) -> String:
	var verbs := ["Foundation stone laid", "Wall block fitted", "Roof section secured", "Window installed", "Finishing detail added"]
	return "%s - %d of %d" % [verbs[clampi(stage - 1, 0, 4)], placed, goal]

func _selected_plot() -> Dictionary:
	var selected := str(SaveManager.get_setting("home_plot", ""))
	for plot: Dictionary in Constants.LAND_PLOTS:
		if str(plot.get("id", "")) == selected:
			return plot
	return {}

func _selected_plan() -> Dictionary:
	var selected := str(SaveManager.get_setting("home_plan", ""))
	for plan: Dictionary in Constants.HOUSE_PLANS:
		if str(plan.get("id", "")) == selected:
			return plan
	return {}

func _effective_cost(stage: int) -> Dictionary:
	var base: Dictionary = Constants.HOME_STAGES[stage].get("cost", {})
	var scale := float(_selected_plan().get("cost_scale", 1.0))
	var result: Dictionary = {}
	for key: String in base:
		result[key] = int(ceil(float(base[key]) * scale))
	return result

func _can_afford(cost: Dictionary) -> bool:
	for key: String in cost:
		var have := SaveManager.get_coins() if key == "coins" else SaveManager.get_resource(key)
		if have < int(cost[key]):
			return false
	return true

func _spend(cost: Dictionary) -> void:
	for key: String in cost:
		if key == "coins":
			SaveManager.spend_coins(int(cost[key]))
		else:
			SaveManager.spend_resource(key, int(cost[key]))

func _cost_text(cost: Dictionary) -> String:
	var pieces: Array[String] = []
	for key: String in cost:
		pieces.append("%d %s" % [int(cost[key]), "coins" if key == "coins" else key.replace("_", " ")])
	return " + ".join(pieces)

func _progress_key(stage: int) -> String:
	return "home_build_progress_%d" % stage

func _paid_key(stage: int) -> String:
	return "home_build_paid_%d" % stage

func _plot_ground_color() -> Color:
	match str(SaveManager.get_setting("home_plot", "")):
		"riverside": return Color("508e52")
		"savanna": return Color("b49345")
		"baobab": return Color("628442")
		_: return Color("477c42")

func _clear_picker() -> void:
	if is_instance_valid(_land_panel):
		_land_panel.queue_free()
	if is_instance_valid(_plan_panel):
		_plan_panel.queue_free()
	_land_panel = null
	_plan_panel = null

func _show_status(message: String) -> void:
	_status_label.text = message
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_instance_valid(_status_label) and _status_label.text == message:
			_status_label.text = "")

func _style_button(button: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.border_color = Color(1.0, 0.78, 0.25, 0.72)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = color.lightened(0.15)
	button.add_theme_stylebox_override("hover", hover)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = color.darkened(0.15)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color.WHITE)

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()
