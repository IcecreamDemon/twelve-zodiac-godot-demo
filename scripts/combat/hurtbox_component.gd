class_name HurtboxComponent
extends Area2D

signal attack_received(attacker: Node, attack_data: AttackData)

@export var receive_hits: bool = true


func receive_attack(attacker: Node, attack_data: AttackData, direction: int) -> bool:
	if not receive_hits:
		return false

	var actor := get_parent()
	if not actor.has_method("receive_hit"):
		return false

	var accepted: bool = actor.call("receive_hit", attacker, attack_data, direction)
	if accepted:
		attack_received.emit(attacker, attack_data)
	return accepted
