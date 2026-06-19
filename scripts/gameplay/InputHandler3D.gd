extends Node
class_name InputHandler3D

const SWIPE_MIN_DIST: float = 40.0
const SWIPE_MAX_TIME: float = 0.5

var player = null  # set by Game3D to a Player3D instance after scene load

var _touch_start: Vector2 = Vector2.ZERO
var _touch_time: float = 0.0
var _tracking: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if player == null or player._is_dead:
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_start = touch.position
			_touch_time = 0.0
			_tracking = true
		else:
			_finish_swipe(touch.position)
		return

	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed or key.echo:
			return
		_handle_key(key.keycode)

func _process(delta: float) -> void:
	if not _tracking:
		return
	_touch_time += delta
	if _touch_time > SWIPE_MAX_TIME:
		_tracking = false

func _finish_swipe(end_position: Vector2) -> void:
	if not _tracking:
		return
	var elapsed := _touch_time
	_tracking = false

	var diff := end_position - _touch_start
	if diff.length() < SWIPE_MIN_DIST:
		return
	if elapsed > SWIPE_MAX_TIME:
		return

	if abs(diff.x) > abs(diff.y):
		if diff.x > 0.0:
			player.move_lane(1)
		else:
			player.move_lane(-1)
	else:
		if diff.y < 0.0:
			player.jump()
		else:
			player.slide()

func _handle_key(keycode: int) -> void:
	match keycode:
		KEY_A, KEY_LEFT:
			player.move_lane(-1)
		KEY_D, KEY_RIGHT:
			player.move_lane(1)
		KEY_W, KEY_UP, KEY_SPACE:
			player.jump()
		KEY_S, KEY_DOWN:
			player.slide()
