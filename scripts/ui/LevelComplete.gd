extends Control

@onready var lbl_level: Label     = $Panel/VBox/LblLevel
@onready var lbl_stars: Label     = $Panel/VBox/LblStars
@onready var lbl_coins: Label     = $Panel/VBox/LblCoins
@onready var lbl_moves: Label     = $Panel/VBox/LblMoves
@onready var btn_next: Button     = $Panel/VBox/Buttons/BtnNext
@onready var btn_replay: Button   = $Panel/VBox/Buttons/BtnReplay
@onready var btn_map: Button      = $Panel/VBox/Buttons/BtnMap
@onready var btn_share: Button    = $Panel/VBox/BtnShare
@onready var btn_challenge: Button = $Panel/VBox/BtnChallenge

func _ready() -> void:
	UIStyle.apply(self)
	visible = false
	btn_next.pressed.connect(_on_next)
	btn_replay.pressed.connect(_on_replay)
	btn_map.pressed.connect(_on_map)
	btn_share.pressed.connect(_on_share)
	btn_challenge.pressed.connect(_on_challenge)
	EventBus.level_completed.connect(_on_level_completed)

func _on_level_completed(level_id: int, stars: int, coins: int, moves: int) -> void:
	visible = true
	lbl_level.text  = "Level " + str(level_id) + " Complete!"
	lbl_stars.text  = "★".repeat(stars) + "☆".repeat(3 - stars)
	lbl_coins.text  = "+" + str(coins) + " Coins"
	lbl_moves.text  = str(moves) + " Moves"

	EventBus.play_sfx.emit("level_complete")
	EventBus.play_sfx.emit("stars_" + str(stars))

	# Next level button only if more levels exist
	var next_id := level_id + 1
	btn_next.visible = SaveManager.is_level_unlocked(next_id)

	# Show login prompt if appropriate
	if GameManager.should_show_login_prompt():
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scenes/menus/LoginPrompt.tscn")

func _on_next() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_gameplay(GameManager.current_level_id + 1)

func _on_replay() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.restart_level()

func _on_map() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_map()

func _on_share() -> void:
	EventBus.play_sfx.emit("button")
	EventBus.score_share_triggered.emit(
		GameManager.current_level_id,
		GameManager.session_coins,
		SaveManager.get_stars(GameManager.current_level_id)
	)
	# TODO: hook into OS.shell_open() with a deep link or share sheet

func _on_challenge() -> void:
	EventBus.play_sfx.emit("button")
	EventBus.challenge_sent.emit("LEVEL%03d" % GameManager.current_level_id)
	# TODO: generate shareable challenge code / link
