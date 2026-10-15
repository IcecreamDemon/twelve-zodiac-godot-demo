class_name TrainingDummy
extends CharacterBody2D

const STATE_IDLE: StringName = &"idle"
const STATE_HIT: StringName = &"hit"
const STATE_DEAD: StringName = &"dead"

@export_range(0.0, 5000.0, 1.0) var gravity: float = 1500.0

@onready var state_machine: ActorStateMachine = $StateMachine
@onready var health: HealthComponent = $HealthComponent
@onready var posture: PostureComponent = $PostureComponent
@onready var qi: QiComponent = $QiComponent
@onready var shi: ShiComponent = $ShiComponent
@onready var visual: Polygon2D = $Visual

var hitstun_frames_remaining: int = 0


func _ready() -> void:
	health.died.connect(_on_died)
	state_machine.transition_to(STATE_IDLE)


func _physics_process(delta: float) -> void:
	state_machine.tick()

	if not is_on_floor():
		velocity.y += gravity * delta

	if state_machine.is_state(STATE_HIT):
		hitstun_frames_remaining -= 1
		velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
		if hitstun_frames_remaining <= 0:
			state_machine.transition_to(STATE_IDLE)
	elif state_machine.is_state(STATE_DEAD):
		velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)

	move_and_slide()


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

	var tween := create_tween()
	visual.modulate = Color(1.0, 0.35, 0.35, 1.0)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.12)


func _on_died() -> void:
	state_machine.transition_to(STATE_DEAD)
	visual.modulate = Color(0.25, 0.25, 0.25, 1.0)


func reset_dummy() -> void:
	health.reset()
	posture.reset()
	qi.reset()
	shi.reset()
	velocity = Vector2.ZERO
	visual.modulate = Color.WHITE
	state_machine.transition_to(STATE_IDLE)
