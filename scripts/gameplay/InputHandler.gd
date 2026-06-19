extends Node
class_name InputHandler

# Emits directional swipe signals for mobile and keyboard fallback.

signal swiped(direction: Vector2i)

const SWIPE_THRESHOLD := 30.0  # pixels

var _touch_start: Vector2 = Vector2.ZERO
var _touch_active: bool = false
var _enabled: bool = true

func enable() -> void:  _enabled = true
func disable() -> void: _enabled = false

func _unhandled_input(event: InputEvent) -> void:
	if not _enabled:
		return

	# ── Touch / swipe ──────────────────────────────────────────────────────────
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_start = touch.position
			_touch_active = true
		else:
			_touch_active = false

	if event is InputEventScreenDrag and _touch_active:
		var drag := event as InputEventScreenDrag
		var delta: Vector2 = drag.position - _touch_start
		if delta.length() >= SWIPE_THRESHOLD:
			_touch_active = false
			_emit_swipe(delta)

	# ── Keyboard fallback (desktop testing) ───────────────────────────────────
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo:
			match key.keycode:
				KEY_UP, KEY_W:    swiped.emit(Vector2i.UP)
				KEY_DOWN, KEY_S:  swiped.emit(Vector2i.DOWN)
				KEY_LEFT, KEY_A:  swiped.emit(Vector2i.LEFT)
				KEY_RIGHT, KEY_D: swiped.emit(Vector2i.RIGHT)

func _emit_swipe(delta: Vector2) -> void:
	if abs(delta.x) > abs(delta.y):
		swiped.emit(Vector2i.RIGHT if delta.x > 0 else Vector2i.LEFT)
	else:
		swiped.emit(Vector2i.DOWN if delta.y > 0 else Vector2i.UP)
