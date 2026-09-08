extends Node
class_name InputHandler3D

const SWIPE_MIN_DIST: float = 40.0
const SWIPE_MAX_TIME: float = 0.5

var player = null  # set by Game3D to a Player3D instance after scene load

var _touch_start: Vector2 = Vector2.ZERO
var _touch_time: float = 0.0
var _tracking: bool = false
var _active_touch_index: int = -1
var _tracking_mouse: bool = false
var _gesture_consumed: bool = false

func _notification(what: int) -> void:
	if what in [NOTIFICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		_clear_gesture()

func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(player) or player._is_dead or get_tree().paused:
		_clear_gesture()
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if not _tracking:
				_active_touch_index = touch.index
				_begin_gesture(touch.position)
		elif touch.index == _active_touch_index:
			_finish_swipe(touch.position)
		return

	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _active_touch_index:
			_try_swipe(drag.position)
		return

	# Ignore emulated mouse events so a touch cannot trigger a second action.
	if event is InputEventMouseButton and event.device >= 0:
		var button := event as InputEventMouseButton
		if button.button_index != MOUSE_BUTTON_LEFT:
			return
		if button.pressed and not _tracking:
			_tracking_mouse = true
			_begin_gesture(button.position)
		elif not button.pressed and _tracking_mouse:
			_finish_swipe(button.position)
		return

	if event is InputEventMouseMotion and _tracking_mouse and event.device >= 0:
		_try_swipe((event as InputEventMouseMotion).position)
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
		_gesture_consumed = true

func _begin_gesture(start_position: Vector2) -> void:
	_touch_start = start_position
	_touch_time = 0.0
	_tracking = true
	_gesture_consumed = false

func _clear_gesture() -> void:
	_tracking = false
	_tracking_mouse = false
	_active_touch_index = -1
	_gesture_consumed = false
	_touch_time = 0.0

func _finish_swipe(end_position: Vector2) -> void:
	_try_swipe(end_position)
	_clear_gesture()

func _try_swipe(end_position: Vector2) -> void:
	if not _tracking or _gesture_consumed:
		return

	var diff := end_position - _touch_start
	if diff.length() < SWIPE_MIN_DIST:
		return
	if _touch_time > SWIPE_MAX_TIME:
		return
	# One action per gesture, fired as soon as the threshold is crossed.
	_gesture_consumed = true

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
