extends Control

# Post-Level-5 story transition: Wildlands of Peace + Sand Shoes unlock screen.
# Shown automatically after completing Level 5 (before Level 6 unlocks).

const PANELS: Array[Dictionary] = [
	{
		"title": "The Jungle Opens",
		"body": "Beyond the Temple of the First Sun lies a warmer world of sand paths,\nopen plains, and peaceful wildlife.\n\nThe expedition continues into the Wildlands of Peace.",
		"tip": "",
	},
	{
		"title": "Peaceful Coexistence",
		"body": "In places like Victoria Falls, Zimbabwe, elephants move freely through town areas\nand visitors share parks with warthogs and birds.\n\nDid you know people and animals can live side by side in peace?\n\nThe next leg of your expedition is about respect, sharing space,\nand preparing for new terrain.",
		"tip": "Wildlife Tip: Respect animals from a safe distance.",
	},
	{
		"title": "Sand Shoes — New Gear Required",
		"body": "The Wildlands path is covered in deep sand.\n\nTo walk safely, jump, and continue the expedition,\nyou need Sand Shoes.\n\nCost: 150 Coins\n\nReplay earlier levels to collect more coins, or visit the Upgrade Shop.",
		"tip": "Wildlife Tip: The jungle is home to many creatures. Move with care.",
	},
]

var _panel_idx: int = 0
var _title_lbl  : Label  = null
var _body_lbl   : Label  = null
var _tip_lbl    : Label  = null
var _btn_next   : Button = null
var _btn_skip   : Button = null
var _indicator  : Label  = null
var _particles  : Array[Dictionary] = []
var _time       : float = 0.0
var _rng        := RandomNumberGenerator.new()

# ─── SETUP ──────────────────────────────────────────────────────────────────

func _ready() -> void:
	_rng.seed = 8842
	_build_background()
	_build_particles()
	_build_ui()
	_show_panel(0)

func _process(delta: float) -> void:
	_time += delta
	_animate_particles(delta)

# ─── BACKGROUND ─────────────────────────────────────────────────────────────

func _build_background() -> void:
	# Warm sandy sky
	_cr(self, Vector2(0,   0), Vector2(480, 280), Color(0.52, 0.42, 0.20, 1.0))
	# Savanna midground
	_cr(self, Vector2(0, 280), Vector2(480, 280), Color(0.38, 0.30, 0.10, 1.0))
	# Ground
	_cr(self, Vector2(0, 560), Vector2(480, 294), Color(0.28, 0.22, 0.08, 1.0))
	# Horizon haze
	_cr(self, Vector2(0, 262), Vector2(480, 36), Color(0.62, 0.52, 0.26, 0.55))
	# Acacia tree silhouettes
	_cr(self, Vector2(40,  160), Vector2(8, 60), Color(0.22, 0.14, 0.06, 0.80))
	_cr(self, Vector2(24,  148), Vector2(40, 18), Color(0.28, 0.24, 0.08, 0.75))
	_cr(self, Vector2(400, 170), Vector2(8, 52), Color(0.22, 0.14, 0.06, 0.80))
	_cr(self, Vector2(384, 158), Vector2(44, 18), Color(0.28, 0.24, 0.08, 0.75))
	_cr(self, Vector2(200, 200), Vector2(6, 44), Color(0.22, 0.14, 0.06, 0.70))
	_cr(self, Vector2(188, 190), Vector2(30, 14), Color(0.28, 0.24, 0.08, 0.65))
	# Elephant silhouette
	_cr(self, Vector2(310, 270), Vector2(42, 34), Color(0.35, 0.28, 0.18, 0.60))
	_cr(self, Vector2(304, 258), Vector2(22, 18), Color(0.35, 0.28, 0.18, 0.60))
	_cr(self, Vector2(312, 302), Vector2(5, 22), Color(0.35, 0.28, 0.18, 0.50))
	_cr(self, Vector2(322, 302), Vector2(5, 22), Color(0.35, 0.28, 0.18, 0.50))
	_cr(self, Vector2(332, 302), Vector2(5, 22), Color(0.35, 0.28, 0.18, 0.50))
	_cr(self, Vector2(344, 302), Vector2(5, 22), Color(0.35, 0.28, 0.18, 0.50))
	# Warthog silhouette
	_cr(self, Vector2(80, 306), Vector2(28, 14), Color(0.30, 0.22, 0.12, 0.55))
	_cr(self, Vector2(76, 300), Vector2(14, 12), Color(0.30, 0.22, 0.12, 0.55))
	_cr(self, Vector2(82, 318), Vector2(4, 12), Color(0.30, 0.22, 0.12, 0.45))
	_cr(self, Vector2(90, 318), Vector2(4, 12), Color(0.30, 0.22, 0.12, 0.45))
	# Sandy path suggestion
	_cr(self, Vector2(180, 340), Vector2(120, 28), Color(0.58, 0.48, 0.24, 0.55))
	_cr(self, Vector2(160, 368), Vector2(160, 20), Color(0.58, 0.48, 0.24, 0.45))

func _build_particles() -> void:
	for i in range(18):
		var p := {
			"node": ColorRect.new(),
			"speed": _rng.randf_range(12.0, 28.0),
			"x":     _rng.randf_range(0.0, 480.0),
			"y":     _rng.randf_range(100.0, 500.0),
			"size":  _rng.randf_range(3.0, 6.0),
			"alpha": _rng.randf_range(0.18, 0.42),
		}
		var r := p["node"] as ColorRect
		r.size = Vector2(p["size"], p["size"])
		r.position = Vector2(p["x"], p["y"])
		r.color = Color(0.88, 0.78, 0.38, p["alpha"])
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(r)
		_particles.append(p)

func _animate_particles(delta: float) -> void:
	for p: Dictionary in _particles:
		p["y"] -= float(p["speed"]) * delta * 0.25
		p["x"] += sin(_time * 0.5 + float(p["y"]) * 0.02) * 0.4
		if p["y"] < 80.0:
			p["y"] = 540.0
			p["x"] = _rng.randf_range(0.0, 480.0)
		var r := p["node"] as ColorRect
		r.position = Vector2(p["x"], p["y"])

# ─── UI ──────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Panel background
	var panel := ColorRect.new()
	panel.color = Color(0.04, 0.08, 0.03, 0.93)
	panel.size = Vector2(440, 360)
	panel.position = Vector2(20, 246)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	# Top accent line
	var top_line := ColorRect.new()
	top_line.color = Color(0.84, 0.66, 0.18)
	top_line.size = Vector2(440, 3)
	top_line.position = Vector2(20, 246)
	top_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_line)

	# Title
	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 22)
	_title_lbl.add_theme_color_override("font_color", Color(0.96, 0.84, 0.32))
	_title_lbl.size = Vector2(420, 36); _title_lbl.position = Vector2(30, 262)
	_title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title_lbl)

	# Divider
	var div := ColorRect.new()
	div.color = Color(0.56, 0.44, 0.12, 0.50)
	div.size = Vector2(380, 1); div.position = Vector2(50, 304)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(div)

	# Body
	_body_lbl = Label.new()
	_body_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	_body_lbl.add_theme_font_size_override("font_size", 13)
	_body_lbl.add_theme_color_override("font_color", Color(0.84, 0.88, 0.72))
	_body_lbl.size = Vector2(400, 180); _body_lbl.position = Vector2(40, 314)
	_body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_body_lbl)

	# Wildlife tip
	_tip_lbl = Label.new()
	_tip_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_lbl.add_theme_font_size_override("font_size", 11)
	_tip_lbl.add_theme_color_override("font_color", Color(0.62, 0.88, 0.52, 0.82))
	_tip_lbl.size = Vector2(400, 22); _tip_lbl.position = Vector2(40, 500)
	_tip_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tip_lbl)

	# Panel indicator dots
	_indicator = Label.new()
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 14)
	_indicator.add_theme_color_override("font_color", Color(0.72, 0.65, 0.38))
	_indicator.size = Vector2(120, 22); _indicator.position = Vector2(180, 530)
	_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_indicator)

	# Skip button
	_btn_skip = Button.new()
	_btn_skip.text = "Skip"
	_btn_skip.custom_minimum_size = Vector2(90, 44)
	_btn_skip.position = Vector2(20, 752)
	_btn_skip.add_theme_font_size_override("font_size", 14)
	_btn_skip.pressed.connect(_on_skip)
	add_child(_btn_skip)

	# Next / Continue button
	_btn_next = Button.new()
	_btn_next.text = "Continue ›"
	_btn_next.custom_minimum_size = Vector2(200, 52)
	_btn_next.position = Vector2(140, 748)
	_btn_next.add_theme_font_size_override("font_size", 18)
	_btn_next.pressed.connect(_on_next)
	add_child(_btn_next)

	# Map button
	var btn_map := Button.new()
	btn_map.text = "← Back to Map"
	btn_map.custom_minimum_size = Vector2(140, 44)
	btn_map.position = Vector2(332, 752)
	btn_map.add_theme_font_size_override("font_size", 13)
	btn_map.pressed.connect(func() -> void: GameManager.go_to_level_select())
	add_child(btn_map)

	# Home Building shortcut — shown only on last panel
	var btn_home := Button.new()
	btn_home.name = "BtnHomeBuild"
	btn_home.text = "🏠  Build Your Home"
	btn_home.custom_minimum_size = Vector2(440, 42)
	btn_home.position = Vector2(20, 700)
	btn_home.add_theme_font_size_override("font_size", 14)
	btn_home.visible = false
	btn_home.pressed.connect(func() -> void: GameManager.go_to_home_building())
	add_child(btn_home)

# ─── PANEL LOGIC ────────────────────────────────────────────────────────────

func _show_panel(idx: int) -> void:
	_panel_idx = idx
	var data: Dictionary = PANELS[idx]
	_title_lbl.text = data["title"]
	_body_lbl.text  = data["body"]
	_tip_lbl.text   = data["tip"]
	_tip_lbl.visible = data["tip"] != ""
	# Dot indicator
	var dots := ""
	for i in range(PANELS.size()):
		dots += "●  " if i == idx else "○  "
	_indicator.text = dots.strip_edges()
	# Last panel: change button text and reveal home building shortcut
	var btn_home := find_child("BtnHomeBuild", true, false) as Button
	if idx == PANELS.size() - 1:
		_btn_next.text = "Go to Jungle Map"
		_btn_skip.visible = false
		if btn_home != null:
			btn_home.visible = true
	else:
		_btn_next.text = "Continue ›"
		_btn_skip.visible = true
		if btn_home != null:
			btn_home.visible = false

func _on_next() -> void:
	EventBus.play_sfx.emit("button")
	if _panel_idx < PANELS.size() - 1:
		_show_panel(_panel_idx + 1)
	else:
		GameManager.go_to_level_select()

func _on_skip() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

# ─── HELPER ─────────────────────────────────────────────────────────────────

func _cr(parent: Node, pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.position     = pos
	r.size         = size
	r.color        = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r
