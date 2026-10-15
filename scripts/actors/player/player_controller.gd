class_name PlayerController
extends CharacterBody2D

const STATE_IDLE: StringName = &"idle"
const STATE_MOVE: StringName = &"move"
const STATE_JUMP: StringName = &"jump"
const STATE_FALL: StringName = &"fall"
const STATE_LIGHT_ATTACK: StringName = &"light_attack"
const STATE_HIT: StringName = &"hit"
const STATE_DEAD: StringName = &"dead"

@export_range(0.0, 1000.0, 1.0) var move_speed: float = 260.0
@export_range(0.0, 5000.0, 1.0) var ground_acceleration: float = 1800.0
@export_range(0.0, 5000.0, 1.0) var ground_deceleration: float = 2200.0
@export_range(0.0, 5000.0, 1.0) var gravity: float = 1500.0
@export_range(0.0, 2000.0, 1.0) var jump_velocity: float = 520.0
@export_range(0.0, 128.0, 1.0) var floor_snap_length_pixels: float = 8.0
@export var light_attack: AttackData

@onready var state_machine: ActorStateMachine = $StateMachine
@onready var health: HealthComponent = $HealthComponent
@onready var posture: PostureComponent = $PostureComponent
@onready var qi: QiComponent = $QiComponent
@onready var shi: ShiComponent = $ShiComponent
@onready var hitbox: HitboxComponent = $AttackHitbox
@onready var visual: Polygon2D = $Visual

var facing_direction: int = 1
var hitstun_frames_remaining: int = 0


func _ready() -> void:
	floor_snap_length = floor_snap_length_pixels
	health.died.connect(_on_died)
	state_machine.transition_to(STATE_IDLE)


func _physics_process(delta: float) -> void:
	state_machine.tick()
	_apply_gravity(delta)

	match state_machine.current_state:
		STATE_IDLE, STATE_MOVE, STATE_JUMP, STATE_FALL:
			_process_ground_and_air(delta)
		STATE_LIGHT_ATTACK:
			_process_attack()
		STATE_HIT:
			_process_hit()
		STATE_DEAD:
			velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)

	move_and_slide()
	_update_visual_direction()
	_update_airborne_state()


func _process_ground_and_air(delta: float) -> void:
	var input_axis := Input.get_axis(&"move_left", &"move_right")
	var target_speed := input_axis * move_speed
	var acceleration := ground_acceleration if not is_zero_approx(input_axis) else ground_deceleration
	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)

	if not is_zero_approx(input_axis):
		facing_direction = 1 if input_axis > 0.0 else -1

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = -jump_velocity
		state_machine.transition_to(STATE_JUMP)

	if Input.is_action_just_pressed(&"light_attack") and is_on_floor():
		_start_light_attack()
		return

	if is_on_floor():
		state_machine.transition_to(STATE_MOVE if not is_zero_approx(input_axis) else STATE_IDLE)
	elif velocity.y < 0.0:
		state_machine.transition_to(STATE_JUMP)
	else:
		state_machine.transition_to(STATE_FALL)


func _process_attack() -> void:
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * get_physics_process_delta_time())
	if state_machine.frames_in_state >= light_attack.total_frames:
		state_machine.transition_to(STATE_IDLE if is_on_floor() else STATE_FALL)


func _process_hit() -> void:
	hitstun_frames_remaining -= 1
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * get_physics_process_delta_time())
	if hitstun_frames_remaining <= 0:
		state_machine.transition_to(STATE_IDLE if is_on_floor() else STATE_FALL)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _update_airborne_state() -> void:
	if is_on_floor() and state_machine.is_state(STATE_FALL):
		state_machine.transition_to(STATE_IDLE)


func _update_visual_direction() -> void:
	visual.scale.x = float(facing_direction)


func _start_light_attack() -> void:
	if light_attack == null:
		push_warning("Player has no light attack assigned.")
		return
	if not qi.consume(light_attack.qi_cost):
		return
	if not shi.consume(light_attack.shi_cost):
		qi.restore(light_attack.qi_cost)
		return

	state_machine.transition_to(STATE_LIGHT_ATTACK)
	hitbox.begin_attack(light_attack, facing_direction)


func receive_hit(attacker: Node, attack_data: AttackData, direction: int) -> bool:
	if state_machine.is_state(STATE_DEAD):
		return false

	return CombatResolver.resolve_hit(attacker, self, attack_data, direction)


func apply_hit_reaction(attack_data: AttackData, direction: int) -> void:
	hitstun_frames_remaining = attack_data.hitstun_frames
	velocity = Vector2(
		attack_data.knockback.x * direction,
		attack_data.knockback.y,
	)
	state_machine.transition_to(STATE_HIT)


func _on_died() -> void:
	hitbox.cancel_attack()
	state_machine.transition_to(STATE_DEAD)
