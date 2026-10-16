class_name TrainingDummy
extends CharacterBody2D

const STATE_IDLE: StringName = &"idle"
const STATE_HIT: StringName = &"hit"
const STATE_LAUNCHED: StringName = &"launched"
const STATE_KNOCKDOWN: StringName = &"knockdown"
const STATE_DEAD: StringName = &"dead"

const JUGGLE_DAMAGE_SCALE: Array[float] = [1.0, 0.85, 0.7, 0.55]

@export_range(0.0, 5000.0, 1.0) var gravity: float = 1500.0
@export_range(1, 6, 1) var max_juggle_hits: int = 3

@onready var state_machine: ActorStateMachine = $StateMachine
@onready var health: HealthComponent = $HealthComponent
@onready var posture: PostureComponent = $PostureComponent
@onready var qi: QiComponent = $QiComponent
@onready var shi: ShiComponent = $ShiComponent
@onready var visual: Polygon2D = $Visual

var hitstun_frames_remaining: int = 0
var knockdown_frames_remaining: int = 0
var current_juggle_hits: int = 0


func _ready() -> void:
	floor_snap_length = 8.0
	floor_stop_on_slope = true
	health.died.connect(_on_died)
	state_machine.transition_to(STATE_IDLE)


func _physics_process(delta: float) -> void:
	state_machine.tick()

	var gravity_multiplier := 2.5 if current_juggle_hits >= max_juggle_hits else 1.0
	if not is_on_floor():
		velocity.y += gravity * gravity_multiplier * delta

	match state_machine.current_state:
		STATE_HIT:
			hitstun_frames_remaining -= 1
			velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
			if hitstun_frames_remaining <= 0:
				state_machine.transition_to(STATE_IDLE)
		STATE_LAUNCHED:
			if is_on_floor():
				_enter_knockdown(30)
		STATE_KNOCKDOWN:
			knockdown_frames_remaining -= 1
			velocity.x = move_toward(velocity.x, 0.0, 1000.0 * delta)
			if knockdown_frames_remaining <= 0:
				current_juggle_hits = 0
				state_machine.transition_to(STATE_IDLE)
		STATE_DEAD:
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)

	move_and_slide()


func receive_hit(
	attacker: Node,
	attack_data: AttackData,
	direction: int,
) -> HurtboxComponent.ReceiveResult:
	if state_machine.is_state(STATE_DEAD):
		return HurtboxComponent.ReceiveResult.IGNORED

	var target_is_launched := state_machine.is_state(STATE_LAUNCHED)
	if target_is_launched and attack_data.juggle_cost > 0 and current_juggle_hits >= max_juggle_hits:
		return HurtboxComponent.ReceiveResult.IGNORED

	var damage_scale := 1.0
	if target_is_launched:
		damage_scale = JUGGLE_DAMAGE_SCALE[mini(current_juggle_hits, JUGGLE_DAMAGE_SCALE.size() - 1)]

	if not CombatResolver.resolve_hit(attacker, self, attack_data, direction, damage_scale):
		return HurtboxComponent.ReceiveResult.IGNORED

	if target_is_launched or attack_data.reaction_type == AttackData.ReactionType.LAUNCH:
		current_juggle_hits += maxi(attack_data.juggle_cost, 1)

	return HurtboxComponent.ReceiveResult.HIT


func apply_hit_reaction(attack_data: AttackData, direction: int) -> void:
	match attack_data.reaction_type:
		AttackData.ReactionType.LAUNCH:
			state_machine.transition_to(STATE_LAUNCHED)
			velocity = Vector2(
				attack_data.launch_velocity.x * direction,
				attack_data.launch_velocity.y,
			)
		AttackData.ReactionType.KNOCKDOWN:
			_enter_knockdown(attack_data.knockdown_frames)
			velocity.x = attack_data.knockback.x * direction
		_:
			hitstun_frames_remaining = attack_data.hitstun_frames
			velocity = Vector2(
				attack_data.knockback.x * direction,
				attack_data.knockback.y,
			)
			state_machine.transition_to(STATE_HIT)

	var tween := create_tween()
	visual.modulate = Color(1.0, 0.35, 0.35, 1.0)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.12)


func apply_parry_stun(frames: int) -> void:
	hitstun_frames_remaining = frames
	velocity.x = 0.0
	state_machine.transition_to(STATE_HIT)


func is_knockdown() -> bool:
	return state_machine.is_state(STATE_KNOCKDOWN)


func _enter_knockdown(frames: int) -> void:
	knockdown_frames_remaining = maxi(frames, 1)
	state_machine.transition_to(STATE_KNOCKDOWN)


func _on_died() -> void:
	state_machine.transition_to(STATE_DEAD)
	visual.modulate = Color(0.25, 0.25, 0.25, 1.0)


func reset_dummy() -> void:
	health.reset()
	posture.reset()
	qi.reset()
	shi.reset()
	velocity = Vector2.ZERO
	hitstun_frames_remaining = 0
	knockdown_frames_remaining = 0
	current_juggle_hits = 0
	visual.modulate = Color.WHITE
	state_machine.transition_to(STATE_IDLE)
