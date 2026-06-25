extends Control

@onready var lbl_stars:  Label  = $Panel/VBox/LblStars
@onready var lbl_coins:  Label  = $Panel/VBox/LblCoins
@onready var btn_next:   Button = $Panel/VBox/Buttons/BtnNext
@onready var btn_replay: Button = $Panel/VBox/Buttons/BtnReplay
@onready var btn_map:    Button = $Panel/VBox/Buttons/BtnMap

var lbl_story: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	var panel := $Panel as Panel
	panel.offset_left = -190
	panel.offset_right = 190
	panel.offset_top = -216
	panel.offset_bottom = 216
	_ensure_story_label()
	btn_next.pressed.connect(_on_next)
	btn_replay.pressed.connect(_on_replay)
	btn_map.pressed.connect(_on_map)
	visible = false

func show_result(stars: int, coins: int, level_id: int = -1, resources: Dictionary = {}) -> void:
	lbl_stars.text = ""   # cleared — star animation fills this
	lbl_coins.text = "+0 Coins"
	var active_level := level_id if level_id > 0 else GameManager.current_level_id
	lbl_story.text = _story_message(active_level)
	if active_level == 3 and SaveManager.is_lives_intro_pending():
		SaveManager.mark_lives_intro_seen()
	_show_resource_rewards(resources)
	visible = true
	_animate_stars(stars)
	_animate_coins(coins)

func _animate_stars(stars: int) -> void:
	# Build 3 individual star labels layered over lbl_stars
	for i in 3:
		var sl := Label.new()
		sl.text = "★" if i < stars else "☆"
		sl.add_theme_font_size_override("font_size", 38)
		sl.add_theme_color_override("font_color",
			Color(0.98, 0.84, 0.12) if i < stars else Color(0.35, 0.33, 0.28))
		sl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.60))
		sl.add_theme_constant_override("shadow_offset_x", 2)
		sl.add_theme_constant_override("shadow_offset_y", 2)
		sl.size = Vector2(48, 48)
		sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		# Position relative to the Panel; lbl_stars is inside Panel/VBox
		# We place stars directly on Panel so we can control their position
		var panel := $Panel as Panel
		var panel_w: float = panel.offset_right - panel.offset_left   # ~380
		var cx: float = panel_w * 0.5
		sl.position = Vector2(cx - 72 + i * 62 - 24, 12)
		sl.scale    = Vector2.ZERO
		sl.modulate = Color(1, 1, 1, 0)
		panel.add_child(sl)

		var delay := 0.08 + i * 0.22
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_interval(delay)
		tw.parallel().tween_property(sl, "scale",   Vector2(1.18, 1.18), 0.22)
		tw.parallel().tween_property(sl, "modulate", Color(1, 1, 1, 1), 0.18)
		tw.tween_property(sl, "scale", Vector2.ONE, 0.12)

func _animate_coins(coins: int) -> void:
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var dummy := {"v": 0}
	tw.tween_method(func(v: int) -> void:
		lbl_coins.text = "+" + str(v) + " Coins"
	, 0, coins, 0.70).set_delay(0.45)

func _show_resource_rewards(resources: Dictionary) -> void:
	var existing := get_node_or_null("Panel/VBox/ResRewards")
	if existing != null:
		existing.queue_free()
	if resources.is_empty():
		return
	var vbox := lbl_coins.get_parent()
	var hbox := HBoxContainer.new()
	hbox.name = "ResRewards"
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 6)
	for res_id: String in resources:
		var info := _find_resource_info(res_id)
		var icon_path: String = str(info.get("icon_path", ""))
		var cell := VBoxContainer.new()
		cell.alignment = BoxContainer.ALIGNMENT_CENTER
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			var tex := load(icon_path) as Texture2D
			if tex != null:
				var tr := TextureRect.new()
				tr.texture = tex
				tr.custom_minimum_size = Vector2(20, 20)
				tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				cell.add_child(tr)
			else:
				_res_icon_label(cell, str(info.get("icon", "?")))
		else:
			_res_icon_label(cell, str(info.get("icon", "?")))
		var amt := Label.new()
		amt.text = "+" + str(resources[res_id])
		amt.add_theme_font_size_override("font_size", 10)
		amt.add_theme_color_override("font_color", Color(0.80, 0.88, 0.60))
		amt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(amt)
		hbox.add_child(cell)
	vbox.add_child(hbox)
	vbox.move_child(hbox, max(0, vbox.get_child_count() - 2))

func _res_icon_label(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.80, 0.88, 0.60))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(lbl)

func _find_resource_info(resource_id: String) -> Dictionary:
	for r: Dictionary in Constants.RESOURCES:
		if r.get("id", "") == resource_id:
			return r
	return { "id": resource_id, "name": resource_id, "icon": "?" }

func _ensure_story_label() -> void:
	var vbox := lbl_coins.get_parent()
	lbl_story = Label.new()
	lbl_story.name = "LblStory"
	lbl_story.custom_minimum_size = Vector2(344.0, 122.0)
	lbl_story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_story.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_story.add_theme_font_size_override("font_size", 12)
	lbl_story.modulate = Color(0.93, 0.82, 0.48, 0.92)
	vbox.add_child(lbl_story)
	vbox.move_child(lbl_story, max(0, vbox.get_child_count() - 2))

func _story_message(level_id: int) -> String:
	match level_id:
		1:
			return "The first trail marker points deeper into the jungle."
		2:
			return "The forest opens, but the lost path grows darker."
		3:
			if SaveManager.is_lives_intro_pending():
				return "The River of Echoes has tested your courage.\n\nFrom here, the Lost Path becomes more dangerous. Ancient ruins, wild trails, deep forests, and hidden traps await.\n\nYou now have Expedition Lives. Lose a life when you fail a run, but recover them over time, earn them through rewards, or continue your journey with help from the expedition camp."
			return "The River of Echoes guards another Sunstone shard."
		4:
			return "A strange symbol glows on the ancient temple stone."
		5:
			return "The Temple of the First Sun is near. The Heart is calling."
		6:
			return "The Wildlands of Peace hold ancient secrets and rare resources."
		_:
			return "Kairo and Zuri continue the expedition."

func _on_next() -> void:
	EventBus.play_sfx.emit("button")
	var completed := GameManager.current_level_id
	# After Level 5, route to the Wildlands story unlock screen
	if completed == 5 and not SaveManager.has_upgrade("sand_shoes"):
		get_tree().paused = false
		GameManager.go_to_wildlands_unlock()
		return
	var next := completed + 1
	# Registration gate: level 4+ requires an account
	if next > 3 and not SupabaseClient.has_registration_key():
		get_tree().paused = false
		GameManager.go_to_login_prompt(true, next)
		return
	if SaveManager.is_level_unlocked(next):
		_try_start_level(next)
	else:
		get_tree().paused = false
		GameManager.go_to_level_select()

func _on_replay() -> void:
	EventBus.play_sfx.emit("button")
	_try_start_level(GameManager.current_level_id)

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_level_select()

func _try_start_level(level_id: int) -> bool:
	if not SaveManager.can_start_level(level_id):
		get_tree().paused = true
		lbl_story.text = "No Expedition Lives left.\n\nRest at camp, recover lives on the map, or refill with coins or gems before continuing."
		return false
	get_tree().paused = false
	GameManager.go_to_gameplay_3d(level_id)
	return true
