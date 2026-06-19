extends Control

@onready var lbl_reason: Label    = $Panel/VBox/LblReason
@onready var btn_retry: Button    = $Panel/VBox/Buttons/BtnRetry
@onready var btn_map: Button      = $Panel/VBox/Buttons/BtnMap

func _ready() -> void:
	UIStyle.apply(self)
	visible = false
	btn_retry.pressed.connect(_on_retry)
	btn_map.pressed.connect(_on_map)
	EventBus.level_failed.connect(_on_level_failed)

func _on_level_failed(_level_id: int, reason: String) -> void:
	visible = true
	match reason:
		"spike":   lbl_reason.text = "Ouch! You hit a spike!"
		"snake":   lbl_reason.text = "A snake got you!"
		"river":   lbl_reason.text = "You fell in the river!"
		_:         lbl_reason.text = "Try again!"
	EventBus.play_sfx.emit("game_over")

func _on_retry() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.restart_level()

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_map()
