extends Control

var _particles: Array = []
var _splash_time: float = 0.0
var _glow: ColorRect

func _ready() -> void:
	_add_atmosphere()
	print("[NAV][Splash] ready; waiting " + str(Constants.SPLASH_DURATION) + "s")
	await get_tree().create_timer(Constants.SPLASH_DURATION).timeout
	_navigate()

func _add_atmosphere() -> void:
	var bg := get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = Color(0.04, 0.11, 0.04, 1.0)

	_glow = ColorRect.new()
	_glow.color = Color(0.78, 0.60, 0.08, 0.07)
	_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_glow)
	move_child(_glow, 1)

	var rng := RandomNumberGenerator.new()
	for i in range(16):
		rng.seed = i * 167 + 23
		var dot := ColorRect.new()
		var sz := rng.randf_range(3.0, 9.0)
		dot.size = Vector2(sz, sz)
		dot.color = Color(
			rng.randf_range(0.15, 0.45),
			rng.randf_range(0.50, 0.82),
			rng.randf_range(0.10, 0.30),
			rng.randf_range(0.30, 0.65)
		)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(dot)
		move_child(dot, 2)
		_particles.append({
			"node": dot,
			"x": rng.randf_range(0.0, 480.0),
			"y": rng.randf_range(0.0, 854.0),
			"vy": rng.randf_range(-22.0, -7.0),
			"vx": rng.randf_range(-5.0, 5.0),
			"phase": rng.randf_range(0.0, PI * 2.0),
			"wave": rng.randf_range(0.4, 0.9)
		})

func _process(delta: float) -> void:
	_splash_time += delta
	if is_instance_valid(_glow):
		_glow.color.a = 0.05 + sin(_splash_time * 1.1) * 0.04
	for item in _particles:
		var node := item["node"] as ColorRect
		if not is_instance_valid(node):
			continue
		item["y"] = (item["y"] as float) + (item["vy"] as float) * delta
		item["x"] = (item["x"] as float) + (item["vx"] as float) * delta + sin(_splash_time * (item["wave"] as float) + (item["phase"] as float)) * 12.0 * delta
		if (item["y"] as float) < -12.0:
			item["y"] = 870.0
			item["x"] = randf_range(0.0, 480.0)
		node.position = Vector2(item["x"], item["y"])

func _navigate() -> void:
	if SaveManager.is_first_launch():
		print("[NAV][Splash] first launch — showing story intro")
		get_tree().change_scene_to_file("res://scenes/menus/StoryIntro.tscn")
	else:
		print("[NAV][Splash] returning player — going to MainMenu")
		get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
