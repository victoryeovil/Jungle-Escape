extends Control

@onready var lbl_stars:  Label  = $Panel/VBox/LblStars
@onready var lbl_coins:  Label  = $Panel/VBox/LblCoins
@onready var btn_next:   Button = $Panel/VBox/Buttons/BtnNext
@onready var btn_replay: Button = $Panel/VBox/Buttons/BtnReplay
@onready var btn_map:    Button = $Panel/VBox/Buttons/BtnMap

var lbl_story: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_ensure_story_label()
	btn_next.pressed.connect(_on_next)
	btn_replay.pressed.connect(_on_replay)
	btn_map.pressed.connect(_on_map)
	visible = false

func show_result(stars: int, coins: int, level_id: int = -1, resources: Dictionary = {}) -> void:
	lbl_stars.text = "★".repeat(stars) + "☆".repeat(3 - stars)
	lbl_coins.text = "+" + str(coins) + " Coins"
	var active_level := level_id if level_id > 0 else GameManager.current_level_id
	lbl_story.text = _story_message(active_level)
	_show_resource_rewards(resources)
	visible = true

func _show_resource_rewards(resources: Dictionary) -> void:
	var existing := get_node_or_null("Panel/VBox/LblResources")
	if existing != null:
		existing.queue_free()
	if resources.is_empty():
		return
	var parts: Array[String] = []
	for res_id: String in resources:
		var info := _find_resource_info(res_id)
		parts.append(info.get("icon", "?") + " " + info.get("name", res_id) + " +" + str(resources[res_id]))
	var vbox := lbl_coins.get_parent()
	var lbl := Label.new()
	lbl.name = "LblResources"
	lbl.text = "  ".join(parts)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.80, 0.88, 0.60))
	lbl.custom_minimum_size = Vector2(260.0, 22.0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl)
	vbox.move_child(lbl, max(0, vbox.get_child_count() - 2))

func _find_resource_info(resource_id: String) -> Dictionary:
	for r: Dictionary in Constants.RESOURCES:
		if r.get("id", "") == resource_id:
			return r
	return { "id": resource_id, "name": resource_id, "icon": "?" }

func _ensure_story_label() -> void:
	var vbox := lbl_coins.get_parent()
	lbl_story = Label.new()
	lbl_story.name = "LblStory"
	lbl_story.custom_minimum_size = Vector2(260.0, 44.0)
	lbl_story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_story.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_story.add_theme_font_size_override("font_size", 14)
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
	get_tree().paused = false
	var completed := GameManager.current_level_id
	# After Level 5, route to the Wildlands story unlock screen
	if completed == 5 and not SaveManager.has_upgrade("sand_shoes"):
		GameManager.go_to_wildlands_unlock()
		return
	var next := completed + 1
	if SaveManager.is_level_unlocked(next):
		GameManager.go_to_gameplay_3d(next)
	else:
		GameManager.go_to_level_select()

func _on_replay() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_gameplay_3d(GameManager.current_level_id)

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_level_select()
