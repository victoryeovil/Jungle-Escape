extends Node3D

# Use APPDATA .godot/controls-test-profile and -- --controls-test-isolated.
class TestRunner extends Player3D:
	func _ready() -> void:
		_cache_collision_shape()

	func _refresh_outfit() -> void:
		pass

	func _set_mode_vehicle(_mode: String) -> void:
		pass

class InputSpy extends Node:
	var _is_dead := false
	var actions: Array[String] = []

	func jump() -> void:
		actions.append("jump")

	func slide() -> void:
		actions.append("slide")

	func move_lane(direction: int) -> void:
		actions.append("left" if direction < 0 else "right")

var _checks := 0
var _failures := 0
var _runner: TestRunner
var _floor: StaticBody3D
var _actions: Array[String] = []
var _input: InputHandler3D
var _spy: InputSpy

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()

func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("RUNNER CONTROL CHECK: " + message)

func _run() -> void:
	if "--controls-test-isolated" not in OS.get_cmdline_user_args() or not OS.get_user_data_dir().contains("controls-test-profile"):
		push_error("Use APPDATA .godot/controls-test-profile and -- --controls-test-isolated.")
		get_tree().quit(2)
		return
	ProjectSettings.set_setting("jungle_escape/backend_url", "http://127.0.0.1:1")
	Analytics._queue.clear()
	Analytics.set_process(false)
	SaveManager._settings = {"cloud_backup": false, "vibration_on": false, "sfx_on": false, "music_on": false}
	SaveManager._save_data = {"coins": 0, "gems": 0, "upgrades": []}
	SupabaseClient._access_token = ""
	SupabaseClient._user_id = ""
	GameManager.is_logged_in = false
	_test_gestures()
	_floor = _box(Vector3(30.0, 0.5, 30.0), Vector3(0.0, -0.25, 0.0))
	await _test_jumps()
	await _test_slides()
	await _test_existing_rules()
	print("RUNNER CONTROL CHECKS: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures else 0)

func _test_gestures() -> void:
	_spy = InputSpy.new()
	add_child(_spy)
	_input = InputHandler3D.new()
	add_child(_input)
	_input.process_mode = Node.PROCESS_MODE_PAUSABLE
	_input.set_process(false)
	_input.player = _spy
	_touch(3, true, Vector2.ZERO)
	_drag(3, Vector2(39.0, 0.0))
	_check(_spy.actions.is_empty(), "small touch movement stays a tap")
	_drag(3, Vector2(60.0, 0.0))
	_check(_spy.actions == ["right"], "swipe fires before finger release")
	_drag(3, Vector2(150.0, 0.0))
	_touch(3, false, Vector2(180.0, 0.0))
	_check(_spy.actions.size() == 1, "drag continuation and release cannot repeat a swipe")
	_touch(2, true, Vector2.ZERO)
	_touch(7, true, Vector2.ZERO)
	_drag(7, Vector2(0.0, -90.0))
	_touch(7, false, Vector2(0.0, -90.0))
	_check(_spy.actions.size() == 1 and _input._tracking, "second finger cannot hijack or end active swipe")
	_drag(2, Vector2(0.0, -80.0))
	_touch(2, false, Vector2(0.0, -80.0))
	_check(_spy.actions.back() == "jump", "original finger keeps control")
	_touch(0, true, Vector2.ZERO)
	_input._process(0.6)
	_drag(0, Vector2(0.0, 90.0))
	_touch(0, false, Vector2(0.0, 90.0))
	_check(_spy.actions.size() == 2, "long holds cannot become stale swipes")
	_touch(0, true, Vector2.ZERO)
	get_tree().paused = true
	get_tree().paused = false
	_touch(0, false, Vector2(0.0, 90.0))
	_check(_spy.actions.size() == 2, "resuming cannot complete a pre-pause gesture")
	_touch(0, true, Vector2.ZERO)
	_input.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	_drag(0, Vector2(0.0, 90.0))
	_touch(0, false, Vector2(0.0, 90.0))
	_check(_spy.actions.size() == 2, "focus loss clears touch state")
	_mouse_button(true, Vector2.ZERO)
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(0.0, 70.0)
	_input._unhandled_input(motion)
	_mouse_button(false, motion.position)
	_check(_spy.actions == ["right", "jump", "slide"], "desktop mouse drag also fires once")
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_LEFT
	_input._unhandled_input(key)
	key.echo = true
	_input._unhandled_input(key)
	_check(_spy.actions.size() == 4 and _spy.actions.back() == "left", "keyboard stays responsive without key-repeat spam")
	_spy._is_dead = true
	key.echo = false
	_input._unhandled_input(key)
	_check(_spy.actions.size() == 4, "dead runner ignores controls")
	_spy._is_dead = false

func _test_jumps() -> void:
	await _fresh_runner()
	_check(_runner.is_on_floor(), "physics fixture starts grounded")
	_runner.jump()
	_check(_runner.velocity.y == Player3D.JUMP_VELOCITY, "grounded jump launches immediately")
	_runner.jump()
	_check(_actions.count("jump") == 1, "stale floor contact cannot permit a second jump")
	await _step(18)
	var rising_speed := _runner.velocity.y
	_runner.jump()
	_check(_runner.velocity.y == rising_speed and _actions.count("jump") == 1, "airborne jump press does not add height")
	await _step(65)
	_check(_runner.is_on_floor() and _actions.count("jump") == 1, "expired midair input cannot jump on landing")
	_runner.jump()
	for frame in 100:
		await _step()
		if _runner.velocity.y < -5.0 and _runner.position.y < 0.45:
			break
	_runner.jump()
	for frame in 12:
		await _step()
		if _actions.count("jump") == 3:
			break
	_check(_actions.count("jump") == 3 and _runner.velocity.y > 0.0, "pre-landing input buffers the next jump")
	await _fresh_runner()
	_floor.position.x = 100.0
	await _step(2)
	_check(not _runner.is_on_floor(), "fixture leaves the ledge")
	_runner.jump()
	_check(_actions.count("jump") == 1 and _runner.velocity.y > 0.0, "late ledge jump uses coyote window")
	await _fresh_runner()
	_floor.position.x = 100.0
	await _step(10)
	_runner.jump()
	_check(_actions.is_empty() and _runner.velocity.y <= 0.0, "RUN state does not allow a jump after coyote window")
	await _fresh_runner(3.0, false)
	await _step()
	_runner.jump()
	_check(_actions.is_empty(), "spawning airborne does not grant an air jump")
	_runner._landing_slide_timer = 0.3
	get_tree().paused = true
	get_tree().paused = false
	_check(_runner._jump_buffer_timer == 0.0 and _runner._landing_slide_timer == 0.0, "pause clears pending player actions")

func _test_slides() -> void:
	await _fresh_runner()
	_runner.jump()
	await _step(12)
	_runner.slide()
	_check(_runner.velocity.y <= -Player3D.FAST_FALL_SPEED, "down swipe cuts a jump short immediately")
	for frame in 40:
		await _step()
		if _runner.state == Player3D.State.SLIDE:
			break
	_check(_runner.is_on_floor() and _runner.state == Player3D.State.SLIDE, "fast fall rolls on landing")
	_check(is_equal_approx((_runner._collision_shape.shape as CapsuleShape3D).height, Player3D.SLIDE_COLLISION_HEIGHT), "landing roll uses crouched collision")
	_runner.jump()
	_check(_runner.state == Player3D.State.JUMP and _runner.velocity.y > 0.0, "jump cancels a roll in open space")
	_check(is_equal_approx((_runner._collision_shape.shape as CapsuleShape3D).height, 1.8), "roll cancel restores standing collision")
	await _fresh_runner(20.0, false)
	_runner.slide()
	await _step(32)
	_check(_runner._landing_slide_timer == 0.0, "landing roll queue has a bounded lifetime")
	for frame in 100:
		await _step()
		if _runner.is_on_floor():
			break
	_check(_runner.is_on_floor() and _runner.state == Player3D.State.RUN, "long falls cannot execute stale landing rolls")
	await _fresh_runner()
	_runner.slide()
	var ceiling := _box(Vector3(3.0, 0.2, 3.0), Vector3(0.0, 1.5, 0.0))
	await _step(2)
	_runner.jump()
	_check(_runner.state == Player3D.State.SLIDE and _runner.velocity.y <= 0.0, "roll cannot jump upright into an overhead obstacle")
	_runner._slide_timer = 0.01
	await _step(2)
	_check(_runner.state == Player3D.State.SLIDE, "roll stays crouched when its timer expires under a ceiling")
	ceiling.position.x = 100.0
	await _step(2)
	_check(_runner.state == Player3D.State.JUMP, "buffered roll cancel executes after overhead clearance")
	ceiling.queue_free()

func _test_existing_rules() -> void:
	await _fresh_runner()
	_runner._current_surface = "sand"
	_runner.jump()
	_check(_actions.is_empty(), "sand still blocks jumping without Sand Shoes")
	SaveManager._save_data["upgrades"] = ["sand_shoes"]
	_runner.jump()
	_check(_actions.count("jump") == 1, "Sand Shoes still unlock sand jumps")
	await _fresh_runner()
	_runner._skin_id = "monkey"
	_runner.jump()
	_check(is_equal_approx(_runner.velocity.y, Player3D.JUMP_VELOCITY * 1.28), "Monkey retains its jump bonus")
	await _fresh_runner()
	_runner._skin_id = "jungle_girl"
	_runner.slide()
	_check(is_equal_approx(_runner._slide_timer, Player3D.SLIDE_DURATION * 0.55), "Zuri retains her shorter roll")
	_runner._jump_buffer_timer = 0.12
	_runner._landing_slide_timer = 0.3
	_runner.die()
	_check(_runner._jump_buffer_timer == 0.0 and _runner._landing_slide_timer == 0.0, "death clears action queues")
	_runner.revive(Vector3(0.0, 0.05, 0.0))
	_check(not _runner._is_dead and _runner.state == Player3D.State.RUN and _runner._invincible_timer > 0.0, "revive preserves standing state and grace period")
	_check(not _runner._jump_consumed and _runner._jump_buffer_timer == 0.0, "revive clears consumed jump and stale input")

func _fresh_runner(height: float = 0.01, settle: bool = true) -> void:
	if is_instance_valid(_runner):
		_runner.free()
	_floor.position.x = 0.0
	_runner = TestRunner.new()
	_runner.process_mode = Node.PROCESS_MODE_PAUSABLE
	_runner.position.y = height
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.9
	_runner.add_child(collision)
	add_child(_runner)
	_runner.set_run_speed(0.0)
	_runner.set_physics_process(false)
	_runner.action_performed.connect(func(action: String): _actions.append(action))
	_actions.clear()
	if settle:
		await _step(10)

func _step(frames: int = 1) -> void:
	for frame in frames:
		await get_tree().physics_frame
		_runner._physics_process(1.0 / 60.0)

func _box(size: Vector3, at: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	return body

func _touch(index: int, pressed: bool, at: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	event.position = at
	_input._unhandled_input(event)

func _drag(index: int, at: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = at
	_input._unhandled_input(event)

func _mouse_button(pressed: bool, at: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	_input._unhandled_input(event)
