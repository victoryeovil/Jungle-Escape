extends CharacterBody3D
class_name Player3D

const LANES: Array[float] = [-1.8, 0.0, 1.8]
const LANE_SWITCH_SPEED: float = 20.0
const RUN_SPEED: float = 8.0
const JUMP_VELOCITY: float = 8.5
const SLIDE_DURATION: float = 0.7
const GRAVITY: float = 22.0
const CHARACTER_SCENE_PATHS := {
	"explorer": "res://assets/3d/characters/kairo/Kairo.tscn",
	"jungle_girl": "res://assets/3d/characters/zuri/Zuri.tscn",
}
const DEFAULT_CHARACTER_SCENE := "res://assets/3d/characters/kairo/Kairo.tscn"
const ANIM_IDLE := "CharacterArmature|Idle"
const ANIM_RUN := "CharacterArmature|Run"
const ANIM_STRAFE_LEFT := "CharacterArmature|Run_Left"
const ANIM_STRAFE_RIGHT := "CharacterArmature|Run_Right"
const ANIM_SLIDE := "CharacterArmature|Roll"
const ANIM_COLLECT := "CharacterArmature|Interact"
const ANIM_HIT := "CharacterArmature|HitRecieve"
const ANIM_VICTORY := "CharacterArmature|Wave"
const ANIM_DEFEAT := "CharacterArmature|Death"
const SLIDE_COLLISION_HEIGHT: float = 0.85
const SLIDE_COLLISION_Y: float = 0.42

enum State { RUN, JUMP, SLIDE, DEAD }

@onready var _collision_shape: CollisionShape3D = $CollisionShape3D

var current_lane: int = 1
var state: State = State.RUN
var _is_dead: bool = false
var _slide_timer: float = 0.0
var _strafe_anim_timer: float = 0.0
var _strafe_anim_name: String = ""
var _character_model: Node3D = null
var _animation_player: AnimationPlayer = null
var _active_animation: String = ""
var _standing_collision_height: float = 1.8
var _standing_collision_y: float = 0.9
var _current_surface: String = "dirt"
# Direction system — updated when player turns
var _move_fwd: Vector3 = Vector3(0.0, 0.0, -1.0)
var _move_right: Vector3 = Vector3(1.0, 0.0, 0.0)
# Baseline right-axis value at the path centre for the current heading segment.
# After a turn the player's absolute world position no longer equals its lane
# offset, so lane snapping targets become  _right_comp_baseline + LANES[lane].
var _right_comp_baseline: float = 0.0
# Turn-zone state
var _at_turn_zone: bool = false
var _turn_zone_dir: int = 0
var _turn_corner_pos: Vector3 = Vector3.ZERO
var _queued_turn: int = 0   # swipe queued early; executes when near corner

signal died
signal sand_blocked   # emitted when player tries to jump on sand without Sand Shoes

func _ready() -> void:
	_cache_collision_shape()
	_apply_selected_character_model()
	_update_character_animation(true)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# Safety net — kill on world fall (no ground tiles below)
	if position.y < -4.0:
		die()
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif state == State.JUMP:
		state = State.RUN

	# Forward velocity along current heading
	var effective_speed := RUN_SPEED
	if _current_surface == "sand" and not SaveManager.has_upgrade("sand_shoes"):
		effective_speed *= 0.45
	velocity.x = _move_fwd.x * effective_speed
	velocity.z = _move_fwd.z * effective_speed
	# Lateral lane snapping — project position onto right axis, lerp toward lane target.
	# _right_comp_baseline keeps the target relative so it stays correct after turns.
	var right_comp: float = position.x * _move_right.x + position.z * _move_right.z
	var new_right_comp: float = lerp(right_comp, _right_comp_baseline + LANES[current_lane], min(1.0, LANE_SWITCH_SPEED * delta))
	var right_delta: float = new_right_comp - right_comp
	position.x += _move_right.x * right_delta
	position.z += _move_right.z * right_delta

	if state == State.SLIDE:
		_slide_timer -= delta
		if _slide_timer <= 0.0:
			state = State.RUN
			_set_slide_collision(false)

	move_and_slide()

	# Auto-execute a queued turn — fires within one full tile (3 m) of the corner
	if _queued_turn != 0:
		var dist_to_corner := (position - _turn_corner_pos).dot(_move_fwd)
		if dist_to_corner >= -3.0:
			_execute_turn(_queued_turn)
			_queued_turn = 0

	_update_character_animation()
	_detect_surface()

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider != null and collider.has_meta("obstacle"):
			die()
			return

func jump() -> void:
	if _is_dead:
		return
	# Sand blocks jumping entirely without Sand Shoes
	if _current_surface == "sand" and not SaveManager.has_upgrade("sand_shoes"):
		sand_blocked.emit()
		return
	if is_on_floor() or state == State.RUN:
		_set_slide_collision(false)
		var jump_vel := JUMP_VELOCITY
		match _current_surface:
			"mud":
				jump_vel *= 0.70
			"stone":
				jump_vel *= 1.06
		velocity.y = jump_vel
		state = State.JUMP
		_update_character_animation(true)

func slide() -> void:
	if _is_dead:
		return
	if state == State.RUN:
		state = State.SLIDE
		_slide_timer = SLIDE_DURATION
		_set_slide_collision(true)
		_update_character_animation(true)

func move_lane(direction: int) -> void:
	if _is_dead:
		return
	if _at_turn_zone:
		# Any swipe while inside the turn zone queues the turn in the required
		# direction — the player doesn't need to swipe the exact correct side.
		_queued_turn = _turn_zone_dir
		var dist := (position - _turn_corner_pos).dot(_move_fwd)
		if dist >= -3.0:
			_execute_turn(_queued_turn)
			_queued_turn = 0
		return
	current_lane = clamp(current_lane + direction, 0, 2)
	_strafe_anim_name = ANIM_STRAFE_LEFT if direction < 0 else ANIM_STRAFE_RIGHT
	_strafe_anim_timer = 0.20
	_update_character_animation(true)

func _execute_turn(dir: int) -> void:
	_at_turn_zone = false
	_turn_zone_dir = 0
	current_lane = 1  # snap to centre lane on turn
	var angle := -float(dir) * PI * 0.5
	_move_fwd = _move_fwd.rotated(Vector3.UP, angle).normalized()
	_move_right = _move_right.rotated(Vector3.UP, angle).normalized()
	_right_comp_baseline = _turn_corner_pos.x * _move_right.x + _turn_corner_pos.z * _move_right.z
	# Rotate the character node so the mesh faces the new forward direction.
	# Character model faces local -Z; world-forward of rotation.y=θ is (-sinθ, 0, -cosθ),
	# so θ = atan2(-fwd.x, -fwd.z) makes local -Z align with _move_fwd.
	rotation.y = atan2(-_move_fwd.x, -_move_fwd.z)

func _on_turn_zone_entered(dir: int, corner_pos: Vector3) -> void:
	_at_turn_zone = true
	_turn_zone_dir = dir
	_turn_corner_pos = corner_pos
	_queued_turn = 0

func _on_turn_zone_exited() -> void:
	_at_turn_zone = false
	_turn_zone_dir = 0
	_queued_turn = 0

func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	state = State.DEAD
	velocity = Vector3.ZERO
	_set_slide_collision(false)
	_play_character_animation(ANIM_HIT, true)
	died.emit()

func reset(lane: int = 1) -> void:
	_is_dead = false
	current_lane = lane
	state = State.RUN
	velocity = Vector3.ZERO
	_slide_timer = 0.0
	_strafe_anim_timer = 0.0
	_strafe_anim_name = ""
	_move_fwd = Vector3(0.0, 0.0, -1.0)
	_move_right = Vector3(1.0, 0.0, 0.0)
	rotation.y = 0.0  # face -Z (default start direction)
	_at_turn_zone = false
	_turn_zone_dir = 0
	_queued_turn = 0
	_turn_corner_pos = Vector3.ZERO
	_right_comp_baseline = 0.0
	_current_surface = "dirt"
	_set_slide_collision(false)
	_update_character_animation(true)

func play_collect() -> void:
	_play_character_animation(ANIM_COLLECT, true)

func play_victory() -> void:
	_play_character_animation(ANIM_VICTORY, true)

func play_defeat() -> void:
	_play_character_animation(ANIM_DEFEAT, true)

func _detect_surface() -> void:
	if not is_on_floor():
		return
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider != null and collider.has_meta("surface"):
			_current_surface = str(collider.get_meta("surface"))
			return

func _apply_selected_character_model() -> void:
	var skin_id := SaveManager.get_selected_skin()
	var scene_path: String = CHARACTER_SCENE_PATHS.get(skin_id, DEFAULT_CHARACTER_SCENE)
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_warning("Player3D: could not load character model: " + scene_path)
		_set_placeholder_visible(true)
		return

	if _character_model != null:
		_character_model.queue_free()

	_character_model = packed_scene.instantiate() as Node3D
	if _character_model == null:
		push_warning("Player3D: character scene is not Node3D: " + scene_path)
		_set_placeholder_visible(true)
		return

	_character_model.name = "CharacterModel"
	add_child(_character_model)
	_set_placeholder_visible(false)
	_animation_player = _find_animation_player(_character_model)
	if _animation_player == null:
		push_warning("Player3D: no AnimationPlayer found in " + scene_path)

func _set_placeholder_visible(is_visible: bool) -> void:
	var body := get_node_or_null("Body") as Node3D
	var head := get_node_or_null("Head") as Node3D
	if body != null:
		body.visible = is_visible
	if head != null:
		head.visible = is_visible

func _cache_collision_shape() -> void:
	if _collision_shape == null:
		return
	var capsule := _collision_shape.shape as CapsuleShape3D
	if capsule != null:
		_standing_collision_height = capsule.height
	_standing_collision_y = _collision_shape.position.y

func _set_slide_collision(is_sliding: bool) -> void:
	if _collision_shape == null:
		return
	var capsule := _collision_shape.shape as CapsuleShape3D
	if capsule == null:
		return
	if is_sliding:
		capsule.height = SLIDE_COLLISION_HEIGHT
		_collision_shape.position.y = SLIDE_COLLISION_Y
	else:
		capsule.height = _standing_collision_height
		_collision_shape.position.y = _standing_collision_y

func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root
	for child in root.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _update_character_animation(force: bool = false) -> void:
	if _strafe_anim_timer > 0.0:
		_strafe_anim_timer -= get_physics_process_delta_time()
		_play_character_animation(_strafe_anim_name, force)
		return

	match state:
		State.SLIDE:
			_play_character_animation(ANIM_SLIDE, force)
		State.DEAD:
			_play_character_animation(ANIM_HIT, force)
		_:
			_play_character_animation(ANIM_RUN, force)

func _play_character_animation(animation_name: String, force: bool = false) -> void:
	if _animation_player == null or animation_name.is_empty():
		return
	if not _animation_player.has_animation(animation_name):
		return
	if not force and _active_animation == animation_name and _animation_player.is_playing():
		return
	_animation_player.play(animation_name)
	_active_animation = animation_name
