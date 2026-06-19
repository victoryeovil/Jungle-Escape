extends Control

@onready var btn_resume: Button   = $Panel/VBox/BtnResume
@onready var btn_restart: Button  = $Panel/VBox/BtnRestart
@onready var btn_settings: Button = $Panel/VBox/BtnSettings
@onready var btn_quit: Button     = $Panel/VBox/BtnQuit

func _ready() -> void:
	UIStyle.apply(self)
	btn_resume.pressed.connect(_on_resume)
	btn_restart.pressed.connect(_on_restart)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)
	EventBus.pause_toggled.connect(_on_pause_toggled)

func _on_pause_toggled(is_paused: bool) -> void:
	visible = is_paused

func _on_resume() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()

func _on_restart() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()
	GameManager.restart_level()

func _on_settings() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/Settings.tscn")

func _on_quit() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()
	GameManager.go_to_menu()
