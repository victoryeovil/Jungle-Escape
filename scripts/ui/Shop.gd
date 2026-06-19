extends Control

@onready var lbl_coins: Label    = $Header/LblCoins
@onready var lbl_gems: Label     = $Header/LblGems
@onready var tab_skins: TabBar   = $TabBar
@onready var list_container: VBoxContainer = $ScrollContainer/List
@onready var btn_back: Button    = $Header/BtnBack
@onready var lbl_hints: Label    = $HintRow/LblHints
@onready var btn_buy_hints: Button = $HintRow/BtnBuyHints

var _shop_particles: Array = []
var _campfire_glow: ColorRect = null
var _shop_time: float = 0.0

func _ready() -> void:
	_add_jungle_background()
	UIStyle.apply(self)
	btn_back.pressed.connect(_on_back)
	btn_buy_hints.pressed.connect(_on_buy_hints)
	_refresh_header()
	_build_skin_list()

func _add_jungle_background() -> void:
	var bg_base := get_node_or_null("Background") as ColorRect
	if bg_base:
		bg_base.color = Color(0.04, 0.12, 0.05, 1.0)

	var layers := Control.new()
	layers.name = "JungleLayers"
	layers.set_anchors_preset(Control.PRESET_FULL_RECT)
	layers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layers)
	move_child(layers, 1)

	var mid := ColorRect.new()
	mid.color = Color(0.03, 0.11, 0.04, 0.75)
	mid.set_anchors_preset(Control.PRESET_FULL_RECT)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layers.add_child(mid)

	var tree_data := [
		[15.0, 140.0, 52.0, 310.0],
		[68.0, 160.0, 38.0, 285.0],
		[395.0, 155.0, 46.0, 320.0],
		[430.0, 170.0, 36.0, 270.0],
		[0.0, 200.0, 30.0, 350.0],
		[455.0, 210.0, 25.0, 280.0],
	]
	for td in tree_data:
		var t := ColorRect.new()
		t.color = Color(0.03, 0.09, 0.03, 0.82)
		t.position = Vector2(td[0], td[1])
		t.size = Vector2(td[2], td[3])
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layers.add_child(t)

	var fire_root := Control.new()
	fire_root.name = "Campfire"
	fire_root.position = Vector2(215.0, 630.0)
	fire_root.size = Vector2(50.0, 40.0)
	fire_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layers.add_child(fire_root)

	_campfire_glow = ColorRect.new()
	_campfire_glow.color = Color(1.0, 0.48, 0.08, 0.22)
	_campfire_glow.position = Vector2(-30.0, -22.0)
	_campfire_glow.size = Vector2(110.0, 72.0)
	_campfire_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fire_root.add_child(_campfire_glow)

	var flame := ColorRect.new()
	flame.color = Color(1.0, 0.55, 0.10, 0.80)
	flame.position = Vector2(10.0, 4.0)
	flame.size = Vector2(30.0, 22.0)
	flame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fire_root.add_child(flame)

	var rng := RandomNumberGenerator.new()
	for i in range(18):
		rng.seed = i * 211 + 7
		var is_firefly := i < 7
		var dot := ColorRect.new()
		var sz := rng.randf_range(2.5, 6.5)
		dot.size = Vector2(sz, sz)
		dot.color = Color(
			rng.randf_range(0.55, 0.95) if is_firefly else rng.randf_range(0.12, 0.45),
			rng.randf_range(0.75, 1.00) if is_firefly else rng.randf_range(0.50, 0.82),
			rng.randf_range(0.10, 0.35) if is_firefly else rng.randf_range(0.08, 0.28),
			rng.randf_range(0.55, 0.92)
		)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layers.add_child(dot)
		_shop_particles.append({
			"node": dot,
			"x": rng.randf_range(0.0, 480.0),
			"y": rng.randf_range(180.0, 854.0),
			"vy": rng.randf_range(-20.0, -6.0),
			"vx": rng.randf_range(-4.0, 4.0),
			"phase": rng.randf_range(0.0, PI * 2.0),
			"wave": rng.randf_range(0.3, 0.8),
			"is_firefly": is_firefly
		})

func _process(delta: float) -> void:
	_shop_time += delta
	_animate_shop_bg(delta)

func _animate_shop_bg(delta: float) -> void:
	if is_instance_valid(_campfire_glow):
		_campfire_glow.color.a = 0.15 + sin(_shop_time * 7.0) * 0.08
	for item in _shop_particles:
		var node := item["node"] as ColorRect
		if not is_instance_valid(node):
			continue
		item["y"] = (item["y"] as float) + (item["vy"] as float) * delta
		item["x"] = (item["x"] as float) + (item["vx"] as float) * delta + sin(_shop_time * (item["wave"] as float) + (item["phase"] as float)) * 10.0 * delta
		if (item["y"] as float) < 150.0:
			item["y"] = randf_range(700.0, 870.0)
			item["x"] = randf_range(0.0, 480.0)
		node.position = Vector2(item["x"], item["y"])
		if item["is_firefly"]:
			node.color.a = 0.35 + sin(_shop_time * 2.5 + (item["phase"] as float)) * 0.45

func _refresh_header() -> void:
	lbl_coins.text = str(SaveManager.get_coins()) + " coins"
	lbl_gems.text  = str(SaveManager.get_gems()) + " gems"
	lbl_hints.text = "Hints: " + str(SaveManager.get_hints())

func _build_skin_list() -> void:
	for child in list_container.get_children():
		child.queue_free()

	for skin in Constants.SKINS:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 64)

		var preview := TextureRect.new()
		preview.custom_minimum_size = Vector2(56, 56)
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var texture_path := "res://assets/sprites/characters/%s.png" % skin["id"]
		if ResourceLoader.exists(texture_path):
			preview.texture = load(texture_path)
		row.add_child(preview)

		var lbl := Label.new()
		lbl.text = skin["name"]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var btn := Button.new()
		var unlocked := SaveManager.is_skin_unlocked(skin["id"])
		if unlocked:
			btn.text = "Equip" if SaveManager.get_selected_skin() != skin["id"] else "Equipped"
			btn.disabled = SaveManager.get_selected_skin() == skin["id"]
			btn.pressed.connect(_equip_skin.bind(skin["id"]))
		else:
			if skin["cost_coins"] > 0:
				btn.text = "Buy " + str(skin["cost_coins"]) + "c"
			elif skin["cost_gems"] > 0:
				btn.text = "Buy " + str(skin["cost_gems"]) + "g"
			elif skin["unlock_method"] == "stars":
				btn.text = str(skin.get("unlock_stars", 0)) + "★ needed"
				btn.disabled = true
			btn.pressed.connect(_buy_skin.bind(skin))
		row.add_child(btn)
		list_container.add_child(row)
	UIStyle.apply(list_container)

func _equip_skin(skin_id: String) -> void:
	EventBus.play_sfx.emit("button")
	SaveManager.set_selected_skin(skin_id)
	_build_skin_list()

func _buy_skin(skin: Dictionary) -> void:
	EventBus.play_sfx.emit("button")
	if skin["cost_coins"] > 0 and SaveManager.spend_coins(skin["cost_coins"]):
		SaveManager.unlock_skin(skin["id"])
	elif skin["cost_gems"] > 0 and SaveManager.get_gems() >= skin["cost_gems"]:
		SaveManager.add_gems(-skin["cost_gems"])
		SaveManager.unlock_skin(skin["id"])
	_refresh_header()
	_build_skin_list()

func _on_buy_hints() -> void:
	EventBus.play_sfx.emit("button")
	if SaveManager.spend_coins(Constants.HINT_COIN_COST):
		SaveManager.add_hints(1)
		_refresh_header()

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()
