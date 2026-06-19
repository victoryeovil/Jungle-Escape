extends Control

@onready var btn_resume:  Button = $Panel/VBox/BtnResume
@onready var btn_restart: Button = $Panel/VBox/BtnRestart
@onready var btn_menu:    Button = $Panel/VBox/BtnMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_resume.pressed.connect(_on_resume)
	btn_restart.pressed.connect(_on_restart)
	btn_menu.pressed.connect(_on_menu)
	EventBus.pause_toggled.connect(func(p): visible = p)
	visible = false

func _on_resume() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()

func _on_restart() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()
	GameManager.go_to_gameplay_3d(GameManager.current_level_id)

func _on_menu() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.resume_game()
	GameManager.go_to_menu()
