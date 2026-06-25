extends Control

@onready var lbl_reason: Label  = $Panel/VBox/LblReason
@onready var btn_retry:  Button = $Panel/VBox/Buttons/BtnRetry
@onready var btn_map:    Button = $Panel/VBox/Buttons/BtnMap

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	var panel := $Panel as Panel
	panel.offset_left = -174
	panel.offset_right = 174
	panel.offset_top = -164
	panel.offset_bottom = 164
	lbl_reason.custom_minimum_size = Vector2(306, 132)
	lbl_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_reason.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	btn_retry.pressed.connect(_on_retry)
	btn_map.pressed.connect(_on_map)
	visible = false

func show_fail(reason: String = "") -> void:
	var body := reason if reason != "" else "Try Again!"
	if GameManager.current_level_id > 3:
		body += "\n\nContinue Run?\nRetry uses your next Expedition Life. Rewarded revive coming soon."
		var can_retry := SaveManager.can_start_level(GameManager.current_level_id)
		btn_retry.disabled = not can_retry
		btn_retry.text = "Retry" if can_retry else "No Lives"
	else:
		btn_retry.disabled = false
		btn_retry.text = "Retry"
	lbl_reason.text = body
	visible = true

func _on_retry() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_gameplay_3d(GameManager.current_level_id)

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.go_to_level_select()
