extends Node

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer

# Populated at runtime — only entries whose files exist on disk are added.
var _sfx_map: Dictionary = {}
var _music_map: Dictionary = {}

# Candidate paths — add new sounds here as files land in assets/sounds/
const _SFX_PATHS := {
	"coin":           "res://assets/sounds/coin.wav",
	"gem":            "res://assets/sounds/gem.wav",
	"key":            "res://assets/sounds/key.wav",
	"fruit":          "res://assets/sounds/fruit.wav",
	"gate_open":      "res://assets/sounds/gate_open.wav",
	"locked":         "res://assets/sounds/locked.wav",
	"exit":           "res://assets/sounds/exit.wav",
	"damage":         "res://assets/sounds/damage.wav",
	"snake":          "res://assets/sounds/snake.wav",
	"splash":         "res://assets/sounds/splash.wav",
	"wood_step":      "res://assets/sounds/wood_step.wav",
	"mud":            "res://assets/sounds/mud.wav",
	"switch":         "res://assets/sounds/switch.wav",
	"vine_teleport":  "res://assets/sounds/vine_teleport.wav",
	"button":         "res://assets/sounds/button.wav",
	"bump":           "res://assets/sounds/bump.wav",
	"jump":           "res://assets/sounds/jump.wav",
	"slide":          "res://assets/sounds/slide.wav",
	"land":           "res://assets/sounds/land.wav",
	"level_complete": "res://assets/sounds/level_complete.wav",
	"game_over":      "res://assets/sounds/game_over.wav",
	"stars_1":        "res://assets/sounds/stars_1.wav",
	"stars_2":        "res://assets/sounds/stars_2.wav",
	"stars_3":        "res://assets/sounds/stars_3.wav",
}

const _MUSIC_PATHS := {
	"menu":     "res://assets/sounds/music_menu.wav",
	"gameplay": "res://assets/sounds/music_gameplay.wav",
}

func _ready() -> void:
	_ensure_bus("SFX")
	_ensure_bus("Music")

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_load_sounds()

	EventBus.play_sfx.connect(_play_sfx)
	EventBus.play_music.connect(_play_music)
	EventBus.stop_music.connect(_stop_music)
	EventBus.settings_changed.connect(_apply_settings)
	_apply_settings()

func _load_sounds() -> void:
	for key in _SFX_PATHS:
		var path: String = _SFX_PATHS[key]
		if ResourceLoader.exists(path):
			_sfx_map[key] = load(path)

	for key in _MUSIC_PATHS:
		var path: String = _MUSIC_PATHS[key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream is AudioStreamWAV:
				(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
			_music_map[key] = stream

func _play_sfx(sfx_name: String) -> void:
	if not SaveManager.get_setting("sfx_on", true):
		return
	if _sfx_map.has(sfx_name):
		_sfx_player.stream = _sfx_map[sfx_name]
		_sfx_player.play()

func _play_music(track_name: String) -> void:
	if not SaveManager.get_setting("music_on", true):
		return
	if _music_map.has(track_name):
		if _music_player.stream == _music_map[track_name] and _music_player.playing:
			return
		_music_player.stream = _music_map[track_name]
		_music_player.play()

func _stop_music() -> void:
	_music_player.stop()

func _apply_settings() -> void:
	var sfx_vol: float = SaveManager.get_setting("sfx_volume", 1.0)
	var music_vol: float = SaveManager.get_setting("music_volume", 0.7)
	_sfx_player.volume_db = linear_to_db(sfx_vol)
	_music_player.volume_db = linear_to_db(music_vol)
	if not SaveManager.get_setting("music_on", true):
		_music_player.stop()

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var bus_index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_send(bus_index, "Master")
