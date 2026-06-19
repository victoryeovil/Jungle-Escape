extends Control

@onready var btn_play: Button = $VBox/BtnPlay
@onready var btn_settings: Button = $VBox/BtnSettings
@onready var btn_login: Button = $VBox/BtnLogin
@onready var btn_shop: Button = $VBox/BtnShop
@onready var btn_continue_offline: Button = $VBox/BtnContinueOffline
@onready var btn_daily_challenge: Button = $VBox/BtnDailyChallenge
@onready var lbl_coins: Label = $TopBar/LblCoins
@onready var lbl_gems: Label = $TopBar/LblGems

const _BACKGROUND_TEX := "res://assets/backgrounds/bg_main_menu.png"
const _LEVEL_SELECT_SCENE := "res://scenes/menus/LevelSelect.tscn"
const _LOG_PREFIX := "[NAV][MainMenu] "

var _navigation_pending: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	_log("ready; scene_file_path=" + scene_file_path + "; tree_paused=" + str(get_tree().paused))
	_apply_background()
	UIStyle.apply(self)
	_refresh_ui()
	btn_play.pressed.connect(_on_play_pressed)
	btn_settings.pressed.connect(_on_settings)
	btn_login.pressed.connect(_on_login)
	btn_shop.pressed.connect(_on_shop)
	btn_continue_offline.pressed.connect(_on_continue_offline)
	btn_daily_challenge.pressed.connect(_on_daily_challenge)
	_log("buttons connected")
	EventBus.play_music.emit("menu")

func _apply_background() -> void:
	if not ResourceLoader.exists(_BACKGROUND_TEX):
		_log("background missing, keeping scene ColorRect: " + _BACKGROUND_TEX)
		return
	var old_bg := get_node_or_null("Background")
	if old_bg:
		old_bg.queue_free()
	var bg := TextureRect.new()
	bg.name = "Background"
	bg.texture = load(_BACKGROUND_TEX)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.offset_left = 0.0
	bg.offset_top = 0.0
	bg.offset_right = 0.0
	bg.offset_bottom = 0.0
	add_child(bg)
	move_child(bg, 0)
	_log("background applied with mouse_filter=IGNORE")

func _refresh_ui() -> void:
	lbl_coins.text = str(SaveManager.get_coins())
	lbl_gems.text = str(SaveManager.get_gems())
	btn_login.text = "Profile" if GameManager.is_logged_in else "Log In"

func _on_play_pressed() -> void:
	_handle_play("pressed")

func _handle_play(source: String) -> void:
	_log("Play signal received from " + source + "; navigation_pending=" + str(_navigation_pending))
	if _navigation_pending:
		_log("Play ignored because navigation is already pending")
		return
	_navigation_pending = true
	btn_play.disabled = true
	EventBus.play_sfx.emit("button")
	_log("Play accepted; deferred open_level_select queued")
	call_deferred("_open_level_select")

func _open_level_select() -> void:
	_log("open_level_select start; target_exists=" + str(ResourceLoader.exists(_LEVEL_SELECT_SCENE)) + "; current_scene=" + _current_scene_path())
	get_tree().paused = false
	if not ResourceLoader.exists(_LEVEL_SELECT_SCENE):
		_navigation_pending = false
		btn_play.disabled = false
		push_error("MainMenu: LevelSelect.tscn is missing")
		return
	GameManager.go_to_level_select()
	_log("scene change requested successfully")

func _on_settings() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/Settings.tscn")

func _on_login() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	if GameManager.is_logged_in:
		get_tree().change_scene_to_file("res://scenes/menus/Profile.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")

func _on_shop() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/Shop.tscn")

func _on_continue_offline() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

func _on_daily_challenge() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/DailyChallenge.tscn")

func _current_scene_path() -> String:
	if get_tree().current_scene == null:
		return "<none>"
	return get_tree().current_scene.scene_file_path


func _log(message: String) -> void:
	print(_LOG_PREFIX + message)
