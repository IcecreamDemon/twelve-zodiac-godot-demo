class_name HurtboxComponent
extends Area2D

enum ReceiveResult {
	IGNORED,
	HIT,
	PARRY,
	BLOCK,
}

signal attack_received(attacker: Node, attack_data: AttackData)

@export var receive_hits: bool = true


func receive_attack(attacker: Node, attack_data: AttackData, direction: int) -> ReceiveResult:
	if not receive_hits:
		return ReceiveResult.IGNORED

	var actor := get_parent()
	if not actor.has_method("receive_hit"):
		return ReceiveResult.IGNORED

	var result: ReceiveResult = actor.call("receive_hit", attacker, attack_data, direction)
	if result != ReceiveResult.IGNORED:
		attack_received.emit(attacker, attack_data)
	return result
