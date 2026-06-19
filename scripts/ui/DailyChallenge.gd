extends Control

@onready var btn_back: Button = $VBox/BtnBack

func _ready() -> void:
	UIStyle.apply(self)
	btn_back.pressed.connect(_on_back)

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()
