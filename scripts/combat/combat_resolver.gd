class_name CombatResolver
extends RefCounted


static func resolve_hit(
	attacker: Node,
	target: Node,
	attack_data: AttackData,
	direction: int,
	damage_multiplier: float = 1.0,
) -> bool:
	if not is_instance_valid(target):
		return false

	var health := target.get_node_or_null("HealthComponent") as HealthComponent
	if health == null or health.current_health <= 0.0:
		return false

	var posture := target.get_node_or_null("PostureComponent") as PostureComponent
	var attacker_shi: ShiComponent
	if is_instance_valid(attacker):
		attacker_shi = attacker.get_node_or_null("ShiComponent") as ShiComponent

	var bonus_damage := 0.0
	if is_instance_valid(attacker):
		bonus_damage = float(attacker.get("bonus_damage")) if attacker.get("bonus_damage") != null else 0.0
	health.take_damage(attack_data.damage * damage_multiplier + bonus_damage)
	if posture != null:
		posture.take_posture_damage(attack_data.posture_damage)
	if attacker_shi != null:
		attacker_shi.add(attack_data.shi_gain_on_hit)

	if target.has_method("apply_hit_reaction"):
		target.call("apply_hit_reaction", attack_data, direction)

	return true
