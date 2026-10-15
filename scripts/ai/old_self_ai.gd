class_name OldSelfAI
extends EnemyController

@export var behavior_profile: OldSelfProfile
@export_range(0.0, 500.0, 1.0) var replay_dodge_speed: float = 210.0

var combo_index: int = 0
var _recorded_dodge_frames: int = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _recorded_dodge_frames <= 0:
		return
	_recorded_dodge_frames -= 1
	if behavior_profile != null:
		velocity.x = replay_dodge_speed * float(behavior_profile.dodge_direction)


func _can_act_from_distance(distance: float) -> bool:
	if behavior_profile == null:
		return super._can_act_from_distance(distance)
	return (
		distance >= maxf(behavior_profile.preferred_distance_min - 20.0, 0.0)
		and distance <= behavior_profile.preferred_distance_max + 20.0
	)


func _choose_action(distance: float) -> void:
	if behavior_profile == null:
		super._choose_action(distance)
		return

	if distance < behavior_profile.preferred_distance_min:
		state_machine.transition_to(STATE_RETREAT)
		return
	if distance > behavior_profile.preferred_distance_max:
		state_machine.transition_to(STATE_APPROACH)
		return
	if behavior_profile.combo_sequence.is_empty():
		super._choose_action(distance)
		return

	var attack := behavior_profile.combo_sequence[combo_index % behavior_profile.combo_sequence.size()]
	combo_index += 1
	_start_melee(attack)


func _process_attack(delta: float) -> void:
	var was_attacking := state_machine.is_state(STATE_ATTACK)
	super._process_attack(delta)
	if was_attacking and not state_machine.is_state(STATE_ATTACK):
		_recorded_dodge_frames = 14


func _on_died() -> void:
	super._on_died()
	var face_reveal := get_node_or_null("FaceReveal") as Polygon2D
	if face_reveal != null:
		face_reveal.visible = true
