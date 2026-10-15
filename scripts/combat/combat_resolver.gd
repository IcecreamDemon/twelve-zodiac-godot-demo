class_name CombatResolver
extends RefCounted


static func resolve_hit(
	attacker: Node,
	target: Node,
	attack_data: AttackData,
	direction: int,
) -> bool:
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false

	var health := target.get_node_or_null("HealthComponent") as HealthComponent
	if health == null or health.current_health <= 0.0:
		return false

	var posture := target.get_node_or_null("PostureComponent") as PostureComponent
	var attacker_shi := attacker.get_node_or_null("ShiComponent") as ShiComponent

	health.take_damage(attack_data.damage)
	if posture != null:
		posture.take_posture_damage(attack_data.posture_damage)
	if attacker_shi != null:
		attacker_shi.add(attack_data.shi_gain_on_hit)

	if target.has_method("apply_hit_reaction"):
		target.call("apply_hit_reaction", attack_data, direction)

	return true
