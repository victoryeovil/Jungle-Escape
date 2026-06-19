extends Control

const TOTAL_LEVELS := 20   # MVP
const LEVELS_PER_PAGE := 10

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer
@onready var lbl_world: Label              = $Header/LblWorld
@onready var btn_back: Button              = $Header/BtnBack
@onready var lbl_coins: Label              = $TopBar/LblCoins
@onready var lbl_stars: Label              = $TopBar/LblStars

var _current_world: int = 1

func _ready() -> void:
	print("[NAV][LevelMap] ready; scene_file_path=" + scene_file_path + "; tree_paused=" + str(get_tree().paused))
	UIStyle.apply(self)
	_insert_counter_icon(lbl_coins, UIStyle.ICON_COIN)
	_insert_counter_icon(lbl_stars, UIStyle.ICON_STAR)
	btn_back.pressed.connect(_on_back)
	lbl_coins.text = str(SaveManager.get_coins())
	lbl_stars.text = str(SaveManager.get_total_stars())
	_build_level_buttons()
	UIStyle.apply(grid_container)
	print("[NAV][LevelMap] ready complete; level_buttons=" + str(grid_container.get_child_count()))

func _build_level_buttons() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	for i in range(1, TOTAL_LEVELS + 1):
		var btn := Button.new()
		var stars := SaveManager.get_stars(i)
		var unlocked := SaveManager.is_level_unlocked(i)

		btn.custom_minimum_size = Vector2(80, 80)
		btn.text = str(i) + "\n" + _star_str(stars)
		btn.disabled = not unlocked

		if not unlocked:
			btn.modulate = Color(0.4, 0.4, 0.4)

		btn.pressed.connect(_on_level_selected.bind(i))
		grid_container.add_child(btn)

		# Teasers for locked world boundaries
		if i == 11 and not SaveManager.is_level_unlocked(11):
			_add_teaser_row("Complete Level 10 to unlock Hidden Gates!")
		elif i == 21 and not SaveManager.is_level_unlocked(21):
			_add_teaser_row("Complete all of World 2 to enter the Snake Temple!")

func _add_teaser_row(msg: String) -> void:
	var lbl := Label.new()
	lbl.text = msg
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.modulate = Color(1.0, 0.8, 0.2)
	grid_container.add_child(lbl)

func _star_str(stars: int) -> String:
	return "★".repeat(stars) + "☆".repeat(3 - stars)

func _on_level_selected(level_id: int) -> void:
	print("[NAV][LevelMap] level selected: " + str(level_id))
	EventBus.play_sfx.emit("button")
	GameManager.go_to_gameplay(level_id)

func _on_back() -> void:
	print("[NAV][LevelMap] back clicked")
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

func _insert_counter_icon(label: Label, texture: Texture2D) -> void:
	var icon := UIStyle.make_counter_icon(texture)
	var parent := label.get_parent()
	parent.add_child(icon)
	parent.move_child(icon, label.get_index())
