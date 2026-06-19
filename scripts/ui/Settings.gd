extends Control

@onready var slider_sfx: HSlider   = $Panel/VBox/SFXRow/SliderSFX
@onready var toggle_sfx: CheckBox  = $Panel/VBox/SFXRow/ToggleSFX
@onready var slider_music: HSlider = $Panel/VBox/MusicRow/SliderMusic
@onready var toggle_music: CheckBox = $Panel/VBox/MusicRow/ToggleMusic
@onready var toggle_vibration: CheckBox = $Panel/VBox/ToggleVibration
@onready var btn_back: Button      = $Panel/VBox/BtnBack
@onready var btn_reset: Button     = $Panel/VBox/BtnReset

func _ready() -> void:
	UIStyle.apply(self)
	_load_settings()
	slider_sfx.value_changed.connect(func(v): SaveManager.set_setting("sfx_volume", v))
	toggle_sfx.toggled.connect(func(v): SaveManager.set_setting("sfx_on", v))
	slider_music.value_changed.connect(func(v): SaveManager.set_setting("music_volume", v))
	toggle_music.toggled.connect(func(v): SaveManager.set_setting("music_on", v))
	toggle_vibration.toggled.connect(func(v): SaveManager.set_setting("vibration_on", v))
	btn_back.pressed.connect(_on_back)
	btn_reset.pressed.connect(_on_reset)

func _load_settings() -> void:
	slider_sfx.value        = SaveManager.get_setting("sfx_volume", 1.0)
	toggle_sfx.button_pressed = SaveManager.get_setting("sfx_on", true)
	slider_music.value      = SaveManager.get_setting("music_volume", 0.7)
	toggle_music.button_pressed = SaveManager.get_setting("music_on", true)
	toggle_vibration.button_pressed = SaveManager.get_setting("vibration_on", true)

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	EventBus.settings_changed.emit()
	if GameManager.state == GameManager.GameState.PAUSED:
		# Came from PauseMenu — scene was replaced, so restart level to return
		GameManager.restart_level()
	else:
		GameManager.go_to_menu()

func _on_reset() -> void:
	EventBus.play_sfx.emit("button")
	# Show a confirmation dialog before resetting
	var dialog := AcceptDialog.new()
	dialog.title = "Reset Progress?"
	dialog.dialog_text = "This will erase ALL your progress. Are you sure?"
	dialog.confirmed.connect(_confirm_reset)
	add_child(dialog)
	dialog.popup_centered()

func _confirm_reset() -> void:
	SaveManager.reset_all_data()
	get_tree().change_scene_to_file("res://scenes/splash/SplashScreen.tscn")
