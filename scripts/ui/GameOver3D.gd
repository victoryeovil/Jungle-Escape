extends Control

signal revive_requested

@onready var lbl_reason: Label  = $Panel/VBox/LblReason
@onready var btn_retry:  Button = $Panel/VBox/Buttons/BtnRetry
@onready var btn_map:    Button = $Panel/VBox/Buttons/BtnMap

var _btn_revive: Button = null
var _lbl_top: Label = null
var _run_progress: VBoxContainer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	var panel := $Panel as Panel
	panel.offset_left = -210
	panel.offset_right = 210
	panel.offset_top = -290
	panel.offset_bottom = 290
	RunProgressSummary.style_panel(panel, $Panel/VBox)
	lbl_reason.custom_minimum_size = Vector2(0, 114)
	lbl_reason.add_theme_font_size_override("font_size", 20)
	btn_retry.custom_minimum_size.y = 48
	btn_map.custom_minimum_size.y = 48
	lbl_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_reason.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_build_revive_button()
	_build_top_label()
	var endless := Button.new()
	endless.text = "Endless Run · free to play"
	endless.custom_minimum_size.y = 44
	endless.pressed.connect(func() -> void: GameManager.go_to_endless())
	($Panel/VBox as VBoxContainer).add_child(endless)
	btn_retry.pressed.connect(_on_retry)
	btn_map.pressed.connect(_on_map)
	visible = false

func _build_revive_button() -> void:
	# Second-chance revive. Costs gems today; swap the cost for a rewarded ad
	# callback once an ad SDK is integrated (this is the hook point).
	_btn_revive = Button.new()
	_btn_revive.name = "BtnRevive"
	_btn_revive.custom_minimum_size = Vector2(280, 52)
	_btn_revive.add_theme_font_size_override("font_size", 18)
	_btn_revive.add_theme_color_override("font_color", Color(0.06, 0.04, 0.01))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.30, 0.86, 0.94)
	sb.border_color = Color(0.10, 0.55, 0.65)
	sb.border_width_left = 2; sb.border_width_right  = 2
	sb.border_width_top  = 2; sb.border_width_bottom = 2
	sb.corner_radius_top_left    = 10; sb.corner_radius_top_right    = 10
	sb.corner_radius_bottom_left = 10; sb.corner_radius_bottom_right = 10
	_btn_revive.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate() as StyleBoxFlat
	sbh.bg_color = Color(0.44, 0.94, 1.0)
	_btn_revive.add_theme_stylebox_override("hover", sbh)
	_btn_revive.add_theme_stylebox_override("pressed", sbh)
	var vbox := $Panel/VBox as VBoxContainer
	vbox.add_child(_btn_revive)
	vbox.move_child(_btn_revive, 1)   # directly under the reason label
	_btn_revive.pressed.connect(_on_revive)
	_btn_revive.visible = false

func _build_top_label() -> void:
	_lbl_top = Label.new()
	_lbl_top.name = "LblTopExplorers"
	_lbl_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_top.add_theme_font_size_override("font_size", 13)
	_lbl_top.add_theme_color_override("font_color", Color(0.80, 0.88, 0.72))
	_lbl_top.visible = false
	($Panel/VBox as VBoxContainer).add_child(_lbl_top)

func show_fail(reason: String = "", can_revive: bool = false, revive_cost: int = 5) -> void:
	var body := reason if reason != "" else "Try Again!"
	if GameManager.current_level_id > 3:
		var can_retry := SaveManager.can_start_level(GameManager.current_level_id)
		btn_retry.disabled = not can_retry
		btn_retry.text = "↺ Retry" if can_retry else "No Lives"
	else:
		btn_retry.disabled = false
		btn_retry.text = "↺ Retry"
	lbl_reason.text = body
	_show_run_progress()
	_lbl_top.visible = false
	_set_revive(can_revive, revive_cost)
	visible = true

func show_endless_over(distance_m: int, best_m: int, is_record: bool, can_revive: bool, revive_cost: int) -> void:
	var body := "Run over!\n\nDistance:  %d m" % distance_m
	if is_record:
		body += "\n★ NEW RECORD! ★"
	else:
		body += "\nBest:  %d m" % best_m
		body += "\nOnly %d m to beat your best" % maxi(1, best_m - distance_m + 1)
	lbl_reason.text = body
	_show_run_progress()
	btn_retry.disabled = false
	btn_retry.text = "↺ New Run"
	_set_revive(can_revive, revive_cost)
	_lbl_top.visible = false
	_fetch_leaderboard()
	visible = true

func _show_run_progress() -> void:
	if is_instance_valid(_run_progress):
		_run_progress.get_parent().remove_child(_run_progress)
		_run_progress.queue_free()
	_run_progress = RunProgressSummary.build()
	var vbox := $Panel/VBox as VBoxContainer
	vbox.add_child(_run_progress)
	vbox.move_child(_run_progress, 1)
	var coins := Label.new()
	coins.text = "%d coins collected · saved to your wallet" % GameManager.session_coins
	coins.add_theme_font_size_override("font_size", 13)
	coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_run_progress.add_child(coins)

func _set_revive(can_revive: bool, revive_cost: int) -> void:
	_btn_revive.visible = can_revive
	_btn_revive.text = "⟳  REVIVE  (◆ %d gems)" % revive_cost

func _fetch_leaderboard() -> void:
	if not SupabaseClient.is_authenticated():
		return
	SupabaseClient.fetch_endless_top(5, func(rows: Array) -> void:
		if rows.is_empty() or not is_instance_valid(_lbl_top):
			return
		var lines: Array[String] = ["— TOP EXPLORERS —"]
		var rank := 1
		for row in rows:
			if row is Dictionary:
				lines.append("%d. %s — %d m" % [rank, str(row.get("display_name", "Explorer")), int(row.get("best_distance_m", 0))])
				rank += 1
		_lbl_top.text = "\n".join(lines)
		_lbl_top.visible = true
	)

func _on_revive() -> void:
	EventBus.play_sfx.emit("button")
	revive_requested.emit()

func _on_retry() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	GameManager.restart_level()

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	get_tree().paused = false
	if GameManager.endless_mode:
		GameManager.go_to_menu()
	else:
		GameManager.go_to_level_select()
