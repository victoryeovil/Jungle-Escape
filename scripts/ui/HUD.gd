extends CanvasLayer

@onready var lbl_level: Label  = $TopBar/LblLevel
@onready var lbl_coins: Label  = $TopBar/LblCoins
@onready var lbl_keys: Label   = $TopBar/LblKeys
@onready var lbl_moves: Label  = $TopBar/LblMoves
@onready var btn_pause: Button = $TopBar/BtnPause
@onready var btn_hint: Button  = $BottomBar/BtnHint
@onready var btn_restart: Button = $BottomBar/BtnRestart

var _key_icon: TextureRect

func _ready() -> void:
	UIStyle.apply(self)
	UIStyle.set_button_icon(btn_pause, UIStyle.ICON_PAUSE, true)
	UIStyle.set_button_icon(btn_hint, UIStyle.ICON_HINT)
	UIStyle.set_button_icon(btn_restart, UIStyle.ICON_RESTART)
	btn_hint.text = "Hint"
	btn_restart.text = "Restart"
	_insert_counter_icon(lbl_coins, UIStyle.ICON_COIN)
	_key_icon = _insert_counter_icon(lbl_keys, UIStyle.ICON_KEY)

	btn_pause.pressed.connect(_on_pause)
	btn_hint.pressed.connect(_on_hint)
	btn_restart.pressed.connect(_on_restart)

	EventBus.coin_collected.connect(_on_coins_changed)
	EventBus.key_collected.connect(_on_keys_changed)
	EventBus.player_moved.connect(_on_moves_changed)

	lbl_level.text  = "Level " + str(GameManager.current_level_id)
	lbl_coins.text  = "0"
	lbl_keys.text   = "0"
	lbl_keys.visible = false
	_key_icon.visible = false
	_update_moves()

func _on_coins_changed(total: int) -> void:
	lbl_coins.text = str(total)

func _on_keys_changed(total: int) -> void:
	lbl_keys.text = str(total)
	lbl_keys.visible = total > 0
	_key_icon.visible = total > 0

func _on_moves_changed(_pos: Vector2i) -> void:
	_update_moves()

func _update_moves() -> void:
	var limit := GameManager.move_limit
	var used  := GameManager.moves_used
	if limit > 0:
		lbl_moves.text = str(used) + "/" + str(limit)
		lbl_moves.modulate = Color.RED if used >= limit else Color.WHITE
	else:
		lbl_moves.text = str(used)

func _on_pause() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.pause_game()

func _on_hint() -> void:
	EventBus.play_sfx.emit("button")
	if SaveManager.get_hints() > 0:
		SaveManager.use_hint()
		# TODO: show hint overlay on the grid
	else:
		# Not enough hints — show shop
		EventBus.shop_opened.emit()

func _on_restart() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.restart_level()

func _insert_counter_icon(label: Label, texture: Texture2D) -> TextureRect:
	var icon := UIStyle.make_counter_icon(texture)
	var parent := label.get_parent()
	parent.add_child(icon)
	parent.move_child(icon, label.get_index())
	return icon
