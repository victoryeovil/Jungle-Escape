extends Control

const STORY_PANELS: Array = [
	{
		"title": "The Temple of the First Sun",
		"text": "Long ago, the Temple of the First Sun protected the jungle with the power of the Sunstone Heart.",
		"accent": Color(1.0, 0.88, 0.30)
	},
	{
		"title": "The Shattered Relic",
		"text": "But the relic shattered, the temple vanished, and the jungle began to change.\nThe path was lost.",
		"accent": Color(0.58, 0.92, 0.48)
	},
	{
		"title": "The Expedition Begins",
		"text": "Now Kairo and Zuri must follow the lost path, recover the broken shards, and uncover the mystery hidden deep within the jungle.",
		"accent": Color(1.0, 0.72, 0.18)
	}
]

var _panel_index: int = 0
var _time: float = 0.0
var _particles: Array = []
var _lbl_title: Label
var _lbl_text: Label
var _btn_next: Button
var _btn_skip: Button
var _lbl_panel_count: Label
var _relic_glow: ColorRect

func _ready() -> void:
	_build_scene()
	_show_panel(0)

func _build_scene() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.10, 0.04, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var mid := ColorRect.new()
	mid.color = Color(0.06, 0.16, 0.07, 0.80)
	mid.set_anchors_preset(Control.PRESET_FULL_RECT)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mid)

	var rng := RandomNumberGenerator.new()
	for i in range(22):
		rng.seed = i * 173 + 31
		var dot := ColorRect.new()
		var sz := rng.randf_range(3.5, 10.0)
		dot.custom_minimum_size = Vector2(sz, sz)
		dot.size = Vector2(sz, sz)
		dot.color = Color(
			rng.randf_range(0.15, 0.50),
			rng.randf_range(0.48, 0.82),
			rng.randf_range(0.10, 0.32),
			rng.randf_range(0.25, 0.65)
		)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(dot)
		_particles.append({
			"node": dot,
			"x": rng.randf_range(0.0, 480.0),
			"y": rng.randf_range(0.0, 854.0),
			"vy": rng.randf_range(-25.0, -8.0),
			"vx": rng.randf_range(-6.0, 6.0),
			"phase": rng.randf_range(0.0, PI * 2.0),
			"wave": rng.randf_range(0.4, 0.9)
		})

	_relic_glow = ColorRect.new()
	_relic_glow.color = Color(0.85, 0.62, 0.08, 0.06)
	_relic_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_relic_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_relic_glow)

	var panel := VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 40.0
	panel.offset_right = -40.0
	panel.offset_top = 130.0
	panel.offset_bottom = -20.0
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 18)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	_lbl_title = Label.new()
	_lbl_title.add_theme_font_size_override("font_size", 24)
	_lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_lbl_title)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 2)
	divider.color = Color(0.85, 0.68, 0.18, 0.50)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(divider)

	_lbl_text = Label.new()
	_lbl_text.add_theme_font_size_override("font_size", 18)
	_lbl_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_text.add_theme_color_override("font_color", Color(0.88, 0.96, 0.80))
	_lbl_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(_lbl_text)

	_lbl_panel_count = Label.new()
	_lbl_panel_count.add_theme_font_size_override("font_size", 13)
	_lbl_panel_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_panel_count.add_theme_color_override("font_color", Color(0.55, 0.78, 0.45, 0.75))
	panel.add_child(_lbl_panel_count)

	_btn_next = Button.new()
	_btn_next.add_theme_font_size_override("font_size", 20)
	_btn_next.custom_minimum_size = Vector2(0, 52)
	panel.add_child(_btn_next)
	_btn_next.pressed.connect(_on_next)

	_btn_skip = Button.new()
	_btn_skip.text = "Skip Story"
	_btn_skip.add_theme_font_size_override("font_size", 14)
	_btn_skip.add_theme_color_override("font_color", Color(0.55, 0.78, 0.45, 0.75))
	panel.add_child(_btn_skip)
	_btn_skip.pressed.connect(_go_to_menu)

	UIStyle.apply(self)

func _show_panel(index: int) -> void:
	_panel_index = index
	var p: Dictionary = STORY_PANELS[index]
	_lbl_title.text = p["title"]
	_lbl_text.text = p["text"]
	_lbl_title.add_theme_color_override("font_color", p["accent"])
	_lbl_panel_count.text = str(index + 1) + " / " + str(STORY_PANELS.size())
	if index >= STORY_PANELS.size() - 1:
		_btn_next.text = "Begin Journey"
		_btn_skip.visible = false
	else:
		_btn_next.text = "Continue  ›"
		_btn_skip.visible = true

func _on_next() -> void:
	EventBus.play_sfx.emit("button")
	if _panel_index >= STORY_PANELS.size() - 1:
		_go_to_menu()
	else:
		_show_panel(_panel_index + 1)

func _go_to_menu() -> void:
	SaveManager.mark_first_launch_done()
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _process(delta: float) -> void:
	_time += delta
	_animate_particles(delta)
	_relic_glow.color.a = 0.04 + sin(_time * 1.2) * 0.03

func _animate_particles(delta: float) -> void:
	for item in _particles:
		var node := item["node"] as ColorRect
		if not is_instance_valid(node):
			continue
		item["y"] = (item["y"] as float) + (item["vy"] as float) * delta
		item["x"] = (item["x"] as float) + (item["vx"] as float) * delta + sin(_time * (item["wave"] as float) + (item["phase"] as float)) * 14.0 * delta
		if (item["y"] as float) < -15.0:
			item["y"] = 870.0
			item["x"] = randf_range(0.0, 480.0)
		node.position = Vector2(item["x"], item["y"])
