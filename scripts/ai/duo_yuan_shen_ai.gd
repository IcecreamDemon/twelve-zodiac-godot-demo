class_name DuoYuanShenAI
extends EnemyController

signal phase_changed(phase: int)
signal shield_changed(current: float, maximum: float)

@export_range(0.0, 100.0, 0.1) var shield_minimum: float = 60.0
@export_range(0.0, 10.0, 0.1) var shield_per_stolen_shi: float = 1.5

var phase: int = 0
var shield: float = 0.0
var shield_maximum: float = 0.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_phase()


func _update_phase() -> void:
	var ratio := health.current_health / health.max_health
	var next_phase := 0
	if ratio <= 0.33:
		next_phase = 2
	elif ratio <= 0.66:
		next_phase = 1

	if next_phase == phase:
		return
	phase = next_phase
	if phase == 1:
		_enter_shield_phase()
	phase_changed.emit(phase)


func _enter_shield_phase() -> void:
	var stolen_shi := 0.0
	var player := get_tree().get_first_node_in_group(&"player") as PlayerController
	if player != null:
		stolen_shi = player.shi.current_shi
		player.shi.consume(stolen_shi)

	shield_maximum = maxf(shield_minimum, stolen_shi * shield_per_stolen_shi)
	shield = shield_maximum
	shield_changed.emit(shield, shield_maximum)


func _choose_action(distance: float) -> void:
	if _player != null and _player.is_burrowed():
		if phase == 0:
			state_machine.transition_to(STATE_APPROACH)
			return
		if phase == 2 or randf() < 0.45:
			_start_melee(profile.anti_burrow_attack)
			return

	super._choose_action(distance)


func receive_hit(
	attacker: Node,
	attack_data: AttackData,
	direction: int,
) -> HurtboxComponent.ReceiveResult:
	if state_machine.is_state(STATE_DEAD):
		return HurtboxComponent.ReceiveResult.IGNORED

	if shield > 0.0:
		shield = maxf(shield - attack_data.damage, 0.0)
		shield_changed.emit(shield, shield_maximum)
		if shield <= 0.0:
			var attacker_shi := attacker.get_node_or_null("ShiComponent") as ShiComponent
			if attacker_shi != null:
				attacker_shi.add(15.0)
		return HurtboxComponent.ReceiveResult.HIT

	return super.receive_hit(attacker, attack_data, direction)
