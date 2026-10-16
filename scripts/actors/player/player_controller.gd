class_name PlayerController
extends CharacterBody2D

const STATE_IDLE: StringName = &"idle"
const STATE_MOVE: StringName = &"move"
const STATE_JUMP: StringName = &"jump"
const STATE_FALL: StringName = &"fall"
const STATE_GUARD: StringName = &"guard"
const STATE_PARRY: StringName = &"parry"
const STATE_BURROW: StringName = &"burrow"
const STATE_DODGE: StringName = &"dodge"
const STATE_ATTACK: StringName = &"attack"
const STATE_HIT: StringName = &"hit"
const STATE_DEAD: StringName = &"dead"

const ATTACK_LIGHT: StringName = &"light"
const ATTACK_HEAVY: StringName = &"heavy"
const ATTACK_AIR_LIGHT: StringName = &"air_light"
const ATTACK_AIR_SLAM: StringName = &"air_slam"
const ATTACK_COUNTER: StringName = &"counter"
const ATTACK_GROUND_FINISHER: StringName = &"ground_finisher"
const ATTACK_SWITCH: StringName = &"switch"
const ATTACK_BURROW_EMERGE: StringName = &"burrow_emerge"

const INPUT_NONE: StringName = &""
const INPUT_LIGHT: StringName = &"input_light"
const INPUT_HEAVY: StringName = &"input_heavy"
const INPUT_UP_LIGHT: StringName = &"input_up_light"
const INPUT_FORWARD_LIGHT: StringName = &"input_forward_light"
const INPUT_SWITCH: StringName = &"input_switch"

@export_range(0.0, 1000.0, 1.0) var move_speed: float = 380.0
@export_range(0.0, 6000.0, 1.0) var ground_acceleration: float = 2600.0
@export_range(0.0, 6000.0, 1.0) var ground_deceleration: float = 3000.0
@export_range(0.0, 5000.0, 1.0) var gravity: float = 2200.0
@export_range(0.0, 2000.0, 1.0) var jump_velocity: float = 900.0
@export_range(0.0, 128.0, 1.0) var floor_snap_length_pixels: float = 8.0
@export_range(1, 30, 1) var parry_active_frames: int = 8
@export_range(0, 120, 1) var parry_recovery_frames: int = 14
@export_range(0.0, 100.0, 0.1) var parry_qi_restore: float = 15.0
@export_range(0.0, 100.0, 0.1) var parry_shi_gain: float = 20.0
@export_range(0.0, 100.0, 0.1) var guard_qi_per_second: float = 6.0
@export_range(0.0, 300.0, 1.0) var counter_range: float = 110.0
@export_range(0.0, 100.0, 0.1) var emergency_parry_qi_threshold: float = 70.0
@export_range(0.0, 100.0, 0.1) var emergency_parry_qi_restore: float = 10.0
@export_range(1, 6, 1) var max_air_actions: int = 3
@export_range(0.0, 100.0, 0.1) var burrow_entry_cost: float = 10.0
@export_range(0.0, 100.0, 0.1) var burrow_qi_per_second: float = 15.0
@export_range(0.5, 3.0, 0.05) var burrow_speed_multiplier: float = 1.1
@export_range(0, 120, 1) var burrow_cooldown_frames: int = 24
@export_range(0.0, 128.0, 1.0) var burrow_depth: float = 36.0
@export_range(0.0, 100.0, 0.1) var dodge_qi_cost: float = 20.0
@export_range(0.0, 1200.0, 1.0) var dodge_speed: float = 640.0
@export_range(1, 60, 1) var dodge_duration_frames: int = 18
@export_range(1, 40, 1) var dodge_invulnerable_frames: int = 10
@export_range(0.0, 240.0, 1.0) var dodge_actor_contact_distance: float = 88.0
@export var weapons: Array[WeaponData] = []

@onready var state_machine: ActorStateMachine = $StateMachine
@onready var health: HealthComponent = $HealthComponent
@onready var posture: PostureComponent = $PostureComponent
@onready var qi: QiComponent = $QiComponent
@onready var shi: ShiComponent = $ShiComponent
@onready var hitbox: HitboxComponent = $AttackHitbox
@onready var visual: Polygon2D = $Visual
@onready var burrow_detector: Area2D = $BurrowDetector
@onready var burrow_crack: Line2D = $BurrowCrack

var facing_direction: int = 1
var hitstun_frames_remaining: int = 0
var weapon_index: int = 0

var current_attack_data: AttackData
var attack_mode: StringName = &""
var combo_step: int = 0
var counter_index: int = 0
var buffered_input: StringName = INPUT_NONE
var air_actions_remaining: int = 3
var _parry_is_emergency: bool = false
var burrow_cooldown_remaining: int = 0
var behavior_recorder: BehaviorRecorder


func _ready() -> void:
	floor_snap_length = floor_snap_length_pixels
	air_actions_remaining = max_air_actions
	health.died.connect(_on_died)
	state_machine.transition_to(STATE_IDLE)
	_update_weapon_visual()


func _physics_process(delta: float) -> void:
	state_machine.tick()
	burrow_cooldown_remaining = maxi(burrow_cooldown_remaining - 1, 0)
	_apply_gravity(delta)
	_handle_emergency_parry()

	match state_machine.current_state:
		STATE_IDLE, STATE_MOVE, STATE_JUMP, STATE_FALL:
			_process_ground_and_air(delta)
		STATE_GUARD:
			_process_guard(delta)
		STATE_PARRY:
			_process_parry()
		STATE_BURROW:
			_process_burrow(delta)
		STATE_DODGE:
			_process_dodge(delta)
		STATE_ATTACK:
			_process_attack(delta)
		STATE_HIT:
			_process_hit()
		STATE_DEAD:
			velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)

	move_and_slide()
	_update_visual_direction()
	_update_landing_state()


func _process_ground_and_air(delta: float) -> void:
	var input_axis := Input.get_axis(&"move_left", &"move_right")
	var target_speed := input_axis * move_speed
	var acceleration := ground_acceleration if not is_zero_approx(input_axis) else ground_deceleration
	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)

	if not is_zero_approx(input_axis):
		facing_direction = 1 if input_axis > 0.0 else -1

	_apply_actor_block()

	if Input.is_action_just_pressed(&"perfect_parry") and is_on_floor():
		_start_parry(false)
		return

	if Input.is_action_just_pressed(&"burrow") and _can_start_burrow():
		_start_burrow()
		return

	if Input.is_action_just_pressed(&"dodge"):
		_start_dodge(input_axis)
		return

	if Input.is_action_just_pressed(&"switch_weapon") and is_on_floor():
		_switch_weapon(false)
		return

	if Input.is_action_just_pressed(&"light_attack"):
		if is_on_floor():
			_start_ground_light()
		else:
			_start_air_attack(false)
		return

	if Input.is_action_just_pressed(&"heavy_attack"):
		if is_on_floor():
			_start_heavy_or_ground_finisher()
		else:
			_start_air_attack(true)
		return

	if Input.is_action_pressed(&"guard") and is_on_floor():
		state_machine.transition_to(STATE_GUARD)
		return

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = -jump_velocity
		state_machine.transition_to(STATE_JUMP)

	if is_on_floor():
		air_actions_remaining = max_air_actions
		state_machine.transition_to(STATE_MOVE if not is_zero_approx(input_axis) else STATE_IDLE)
	elif velocity.y < 0.0:
		state_machine.transition_to(STATE_JUMP)
	else:
		state_machine.transition_to(STATE_FALL)


func _process_guard(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
	if qi.current_qi <= 0.0 or not Input.is_action_pressed(&"guard"):
		state_machine.transition_to(STATE_IDLE)
		return
	if not qi.consume(guard_qi_per_second * delta):
		state_machine.transition_to(STATE_IDLE)


func _process_parry() -> void:
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * get_physics_process_delta_time())
	if state_machine.frames_in_state >= parry_active_frames + parry_recovery_frames:
		_parry_is_emergency = false
		state_machine.transition_to(STATE_IDLE)


func _process_burrow(delta: float) -> void:
	if Input.is_action_just_pressed(&"burrow") or qi.current_qi <= 0.0:
		_exit_burrow(false)
		return

	if Input.is_action_just_pressed(&"light_attack") or Input.is_action_just_pressed(&"heavy_attack"):
		_exit_burrow(true)
		return

	var input_axis := Input.get_axis(&"move_left", &"move_right")
	velocity.x = input_axis * move_speed * burrow_speed_multiplier
	velocity.y = 0.0
	if not is_zero_approx(input_axis):
		facing_direction = 1 if input_axis > 0.0 else -1

	if not qi.consume(burrow_qi_per_second * delta):
		_exit_burrow(false)


func _process_dodge(delta: float) -> void:
	if state_machine.frames_in_state >= dodge_duration_frames:
		state_machine.transition_to(STATE_IDLE if is_on_floor() else STATE_FALL)
		return

	_apply_actor_block()
	var trailing_frames := maxi(dodge_duration_frames - dodge_invulnerable_frames, 1)
	if state_machine.frames_in_state >= trailing_frames:
		velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)


func _apply_actor_block() -> void:
	if is_zero_approx(velocity.x):
		return

	var movement_direction := 1 if velocity.x > 0.0 else -1
	for group: StringName in [&"training_dummy", &"enemy"]:
		for node: Node in get_tree().get_nodes_in_group(group):
			var actor := node as Node2D
			if actor == null:
				continue
			if absf(actor.global_position.y - global_position.y) > 64.0:
				continue
			var horizontal_delta := actor.global_position.x - global_position.x
			if signi(roundi(horizontal_delta)) != movement_direction:
				continue
			if absf(horizontal_delta) <= dodge_actor_contact_distance:
				velocity.x = 0.0
				return


func _process_attack(delta: float) -> void:
	if attack_mode == ATTACK_AIR_SLAM:
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		velocity.y = maxf(velocity.y, 520.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)

	_sample_attack_buffer()

	if attack_mode == ATTACK_AIR_SLAM and is_on_floor() and state_machine.frames_in_state >= current_attack_data.startup_frames:
		_finish_current_attack()
		return

	if state_machine.frames_in_state < current_attack_data.total_frames:
		return

	_finish_current_attack()


func _process_hit() -> void:
	hitstun_frames_remaining -= 1
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * get_physics_process_delta_time())
	if hitstun_frames_remaining <= 0:
		state_machine.transition_to(STATE_IDLE if is_on_floor() else STATE_FALL)


func _sample_attack_buffer() -> void:
	if state_machine.frames_in_state < current_attack_data.buffer_start_frame:
		return
	if current_attack_data.buffer_end_frame > 0 and state_machine.frames_in_state > current_attack_data.buffer_end_frame:
		return

	if Input.is_action_just_pressed(&"switch_weapon"):
		buffered_input = INPUT_SWITCH
	elif Input.is_action_just_pressed(&"heavy_attack"):
		buffered_input = INPUT_HEAVY
	elif Input.is_action_just_pressed(&"light_attack"):
		var input_axis := Input.get_axis(&"move_left", &"move_right")
		if Input.is_action_pressed(&"aim_up"):
			buffered_input = INPUT_UP_LIGHT
		elif is_zero_approx(input_axis) or signf(input_axis) == signf(float(facing_direction)):
			buffered_input = INPUT_FORWARD_LIGHT if not is_zero_approx(input_axis) else INPUT_LIGHT
		else:
			buffered_input = INPUT_LIGHT


func _finish_current_attack() -> void:
	var finished_mode := attack_mode

	if finished_mode == ATTACK_COUNTER:
		counter_index += 1
		if counter_index < _current_weapon().counter_chain.size():
			_start_attack(_current_weapon().counter_chain[counter_index], ATTACK_COUNTER, true)
			return
	elif finished_mode == ATTACK_BURROW_EMERGE and buffered_input == INPUT_LIGHT:
		combo_step = 0
		_start_attack(_current_weapon().light_chain[0], ATTACK_LIGHT, false)
		return
	elif finished_mode == ATTACK_LIGHT:
		if combo_step == 0 and buffered_input == INPUT_LIGHT:
			combo_step = 1
			_start_attack(_current_weapon().light_chain[1], ATTACK_LIGHT, false)
			return
		if combo_step == 1:
			if buffered_input == INPUT_HEAVY:
				_start_attack(_current_weapon().heavy_finisher, ATTACK_HEAVY, false)
				return
			if buffered_input == INPUT_SWITCH:
				_switch_weapon(true)
				return
			if buffered_input == INPUT_UP_LIGHT:
				_start_attack(_current_weapon().up_finisher, ATTACK_LIGHT, false)
				return
			if buffered_input == INPUT_FORWARD_LIGHT:
				_start_attack(_current_weapon().forward_finisher, ATTACK_LIGHT, false)
				return
			if buffered_input == INPUT_LIGHT:
				_start_attack(_current_weapon().neutral_finisher, ATTACK_LIGHT, false)
				return

	current_attack_data = null
	attack_mode = &""
	combo_step = 0
	counter_index = 0
	buffered_input = INPUT_NONE
	state_machine.transition_to(STATE_IDLE if is_on_floor() else STATE_FALL)


func _start_ground_light() -> void:
	combo_step = 0
	buffered_input = INPUT_NONE
	_start_attack(_current_weapon().light_chain[0], ATTACK_LIGHT, false)


func _start_heavy_or_ground_finisher() -> void:
	var knockdown_target := _find_knockdown_target()
	if knockdown_target != null:
		face_position(knockdown_target.global_position)
		_start_attack(_current_weapon().ground_finisher, ATTACK_GROUND_FINISHER, false)
		return
	_start_attack(_current_weapon().heavy_finisher, ATTACK_HEAVY, false)


func _start_air_attack(is_slam: bool) -> void:
	if air_actions_remaining <= 0:
		return
	var attack := _current_weapon().air_slam if is_slam else _current_weapon().air_light
	var mode := ATTACK_AIR_SLAM if is_slam else ATTACK_AIR_LIGHT
	if _start_attack(attack, mode, false):
		air_actions_remaining -= 1


func _start_attack(data: AttackData, mode: StringName, is_chain: bool) -> bool:
	if data == null:
		return false
	if not qi.consume(data.qi_cost):
		return false
	if not shi.consume(data.shi_cost):
		qi.restore(data.qi_cost)
		return false

	if behavior_recorder != null:
		behavior_recorder.record_attack(data, _distance_to_nearest_enemy())

	current_attack_data = data
	attack_mode = mode
	buffered_input = INPUT_NONE
	state_machine.transition_to(STATE_ATTACK)
	hitbox.begin_attack(data, facing_direction)
	if not is_chain and mode != ATTACK_COUNTER:
		counter_index = 0
	return true


func _start_dodge(input_axis: float) -> bool:
	if state_machine.is_state(STATE_DODGE) or state_machine.is_state(STATE_DEAD):
		return false
	if not qi.consume(dodge_qi_cost):
		return false

	var direction := 0
	if not is_zero_approx(input_axis):
		direction = 1 if input_axis > 0.0 else -1
	else:
		direction = facing_direction

	facing_direction = direction
	velocity = Vector2(dodge_speed * float(direction), 0.0)
	state_machine.transition_to(STATE_DODGE)
	if behavior_recorder != null:
		behavior_recorder.record_dodge(direction)
	return true


func _distance_to_nearest_enemy() -> float:
	var nearest := 9999.0
	for group: StringName in [&"training_dummy", &"enemy"]:
		for node: Node in get_tree().get_nodes_in_group(group):
			var target := node as Node2D
			if target == null:
				continue
			nearest = minf(nearest, global_position.distance_to(target.global_position))
	return nearest


func _start_parry(is_emergency: bool) -> void:
	if state_machine.is_state(STATE_ATTACK) or state_machine.is_state(STATE_DEAD):
		return
	_parry_is_emergency = is_emergency
	state_machine.transition_to(STATE_PARRY)


func _can_start_burrow() -> bool:
	return (
		burrow_cooldown_remaining <= 0
		and qi.current_qi >= burrow_entry_cost
		and burrow_detector.get_overlapping_areas().size() > 0
	)


func _start_burrow() -> bool:
	if not _can_start_burrow():
		return false
	if not qi.consume(burrow_entry_cost):
		return false

	hitbox.cancel_attack()
	current_attack_data = null
	attack_mode = &""
	collision_layer = 0
	position.y += burrow_depth
	velocity = Vector2.ZERO
	visual.modulate = Color(1.0, 1.0, 1.0, 0.28)
	burrow_crack.visible = true
	state_machine.transition_to(STATE_BURROW)
	return true


func _exit_burrow(attack_on_exit: bool) -> void:
	if not state_machine.is_state(STATE_BURROW):
		return

	collision_layer = 2
	position.y -= burrow_depth
	visual.modulate = Color.WHITE
	burrow_crack.visible = false
	burrow_cooldown_remaining = burrow_cooldown_frames

	if attack_on_exit and _current_weapon().burrow_emerge != null:
		if _start_attack(_current_weapon().burrow_emerge, ATTACK_BURROW_EMERGE, false):
			return

	state_machine.transition_to(STATE_IDLE if is_on_floor() else STATE_FALL)


func _handle_emergency_parry() -> void:
	if not state_machine.is_state(STATE_HIT):
		return
	if not Input.is_action_just_pressed(&"perfect_parry"):
		return
	try_emergency_parry()


func try_emergency_parry() -> bool:
	if not state_machine.is_state(STATE_HIT):
		return false
	if qi.current_qi < emergency_parry_qi_threshold:
		return false

	qi.consume(qi.current_qi)
	_start_parry(true)
	return true


func _switch_weapon(from_combo: bool) -> void:
	if weapons.size() < 2:
		return
	weapon_index = (weapon_index + 1) % weapons.size()
	_update_weapon_visual()
	if from_combo:
		_start_attack(_current_weapon().switch_attack, ATTACK_SWITCH, false)


func _current_weapon() -> WeaponData:
	if weapons.is_empty():
		return null
	return weapons[weapon_index]


func _update_weapon_visual() -> void:
	var weapon := _current_weapon()
	if weapon == null:
		return
	if weapon.weapon_id == &"spear":
		visual.color = Color(0.18, 0.16, 0.14, 1.0)
	else:
		visual.color = Color(0.12, 0.15, 0.18, 1)


func _find_knockdown_target() -> Node2D:
	for candidate: Node in get_tree().get_nodes_in_group(&"training_dummy"):
		var target := candidate as Node2D
		if target == null or not target.has_method("is_knockdown"):
			continue
		if not target.call("is_knockdown"):
			continue
		if absf(target.global_position.x - global_position.x) <= counter_range:
			return target
	return null


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _update_landing_state() -> void:
	if not is_on_floor():
		return
	air_actions_remaining = max_air_actions
	if state_machine.is_state(STATE_FALL):
		state_machine.transition_to(STATE_IDLE)


func _update_visual_direction() -> void:
	visual.scale.x = float(facing_direction)


func face_position(target_position: Vector2) -> void:
	facing_direction = 1 if target_position.x >= global_position.x else -1


func receive_hit(attacker: Node, attack_data: AttackData, direction: int) -> HurtboxComponent.ReceiveResult:
	if state_machine.is_state(STATE_DEAD):
		return HurtboxComponent.ReceiveResult.IGNORED
	if state_machine.is_state(STATE_BURROW):
		if attack_data.attack_type != AttackData.AttackType.ANTI_BURROW:
			return HurtboxComponent.ReceiveResult.IGNORED
		_exit_burrow(false)
	if state_machine.is_state(STATE_DODGE) and state_machine.frames_in_state < dodge_invulnerable_frames:
		return HurtboxComponent.ReceiveResult.IGNORED

	if state_machine.is_state(STATE_PARRY) and state_machine.frames_in_state < parry_active_frames:
		if attack_data.attack_type != AttackData.AttackType.UNBLOCKABLE:
			_resolve_parry_success(attacker)
			return HurtboxComponent.ReceiveResult.PARRY

	if state_machine.is_state(STATE_GUARD) and attack_data.attack_type == AttackData.AttackType.NORMAL:
		if qi.consume(attack_data.guard_qi_damage):
			posture.take_posture_damage(attack_data.posture_damage)
			return HurtboxComponent.ReceiveResult.BLOCK

	if CombatResolver.resolve_hit(attacker, self, attack_data, direction, 1.0):
		return HurtboxComponent.ReceiveResult.HIT
	return HurtboxComponent.ReceiveResult.IGNORED


func _resolve_parry_success(attacker: Node) -> void:
	qi.restore(emergency_parry_qi_restore if _parry_is_emergency else parry_qi_restore)
	shi.add(parry_shi_gain)
	_parry_is_emergency = false

	if is_instance_valid(attacker) and attacker.has_method("apply_parry_stun"):
		attacker.call("apply_parry_stun", 18)

	if not is_instance_valid(attacker):
		state_machine.transition_to(STATE_IDLE)
		return

	var attacker_2d := attacker as Node2D
	if attacker_2d == null or global_position.distance_to(attacker_2d.global_position) > counter_range:
		state_machine.transition_to(STATE_IDLE)
		return

	face_position(attacker_2d.global_position)
	counter_index = 0
	_start_attack(_current_weapon().counter_chain[0], ATTACK_COUNTER, true)


func apply_hit_reaction(attack_data: AttackData, direction: int) -> void:
	hitstun_frames_remaining = attack_data.hitstun_frames
	velocity = Vector2(
		attack_data.knockback.x * direction,
		attack_data.knockback.y,
	)
	hitbox.cancel_attack()
	current_attack_data = null
	attack_mode = &""
	state_machine.transition_to(STATE_HIT)


func _on_died() -> void:
	hitbox.cancel_attack()
	state_machine.transition_to(STATE_DEAD)


func is_burrowed() -> bool:
	return state_machine.is_state(STATE_BURROW)
