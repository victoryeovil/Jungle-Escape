extends Control

@onready var lbl_reason: Label  = $Panel/VBox/LblReason
@onready var btn_retry:  Button = $Panel/VBox/Buttons/BtnRetry
@onready var btn_map:    Button = $Panel/VBox/Buttons/BtnMap

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_retry.pressed.connect(_on_retry)
	btn_map.pressed.connect(_on_map)
	visible = false

func show_fail(reason: String = "") -> void:
	lbl_reason.text = reason if reason != "" else "Try Again!"
	visible = true

func _on_retry() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_gameplay_3d(GameManager.current_level_id)

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_level_select()
