extends Control

@onready var lbl_name: Label    = $Panel/VBox/LblName
@onready var lbl_coins: Label   = $Panel/VBox/StatsGrid/LblCoins
@onready var lbl_gems: Label    = $Panel/VBox/StatsGrid/LblGems
@onready var lbl_stars: Label   = $Panel/VBox/StatsGrid/LblStars
@onready var lbl_levels: Label  = $Panel/VBox/StatsGrid/LblLevels
@onready var btn_logout: Button = $Panel/VBox/BtnLogout
@onready var btn_back: Button   = $Panel/VBox/BtnBack

func _ready() -> void:
	btn_back.pressed.connect(_on_back)
	btn_logout.pressed.connect(_on_logout)
	_refresh()

func _refresh() -> void:
	lbl_name.text   = GameManager.player_name
	lbl_coins.text  = "Coins:  " + str(SaveManager.get_coins())
	lbl_gems.text   = "Gems:   " + str(SaveManager.get_gems())
	lbl_stars.text  = "Stars:  " + str(SaveManager.get_total_stars())
	lbl_levels.text = "Levels: " + str(SaveManager.get_levels_completed_count())

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

func _on_logout() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.is_logged_in = false
	GameManager.is_guest = true
	GameManager.player_name = "Explorer"
	GameManager.go_to_menu()
