extends SceneTree

const ATTACK_DATA_SCRIPT := preload("res://scripts/data/attack_data.gd")
const WEAPON_DATA_SCRIPT := preload("res://scripts/data/weapon_data.gd")
const ENEMY_PROFILE_SCRIPT := preload("res://scripts/data/enemy_profile.gd")

const SHORT_BLADE_DIR := "res://resources/attacks/short_blade/"
const SPEAR_DIR := "res://resources/attacks/spear/"
const ENEMY_ATTACK_DIR := "res://resources/attacks/enemies/"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://resources/weapons/"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHORT_BLADE_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SPEAR_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ENEMY_ATTACK_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://resources/enemies/"))

	var short_blade := _build_short_blade()
	var spear := _build_spear()
	var enemy_attacks := _build_enemy_attacks()

	ResourceSaver.save(short_blade, "res://resources/weapons/short_blade.tres")
	ResourceSaver.save(spear, "res://resources/weapons/spear.tres")
	_build_enemy_profiles(enemy_attacks)
	print("WEAPON RESOURCE GENERATION PASS")
	quit(0)


func _build_short_blade() -> WeaponData:
	var weapon := WEAPON_DATA_SCRIPT.new()
	weapon.weapon_id = &"short_blade"
	weapon.display_name = "残锋短刃"
	weapon.light_chain = [
		_save_attack("short_l1", "short_blade", {
			"startup_frames": 5,
			"active_frames": 4,
			"recovery_frames": 8,
			"damage": 7.0,
			"posture_damage": 8.0,
			"hitbox_offset": Vector2(42.0, -44.0),
			"hitbox_size": Vector2(66.0, 52.0),
			"knockback": Vector2(80.0, 0.0),
			"hitstun_frames": 10,
			"shi_gain_on_hit": 10.0,
			"qi_cost": 1.0,
		}),
		_save_attack("short_l2", "short_blade", {
			"startup_frames": 5,
			"active_frames": 4,
			"recovery_frames": 10,
			"damage": 8.0,
			"posture_damage": 9.0,
			"hitbox_offset": Vector2(46.0, -44.0),
			"hitbox_size": Vector2(72.0, 54.0),
			"knockback": Vector2(90.0, 0.0),
			"hitstun_frames": 11,
			"shi_gain_on_hit": 10.0,
			"qi_cost": 1.0,
		}),
	]
	weapon.neutral_finisher = _save_attack("short_neutral", "short_blade", {
		"startup_frames": 6,
		"active_frames": 4,
		"recovery_frames": 14,
		"damage": 10.0,
		"posture_damage": 12.0,
		"hitbox_offset": Vector2(48.0, -44.0),
		"hitbox_size": Vector2(78.0, 56.0),
		"knockback": Vector2(120.0, 0.0),
		"hitstun_frames": 14,
		"shi_gain_on_hit": 12.0,
		"qi_cost": 1.0,
	})
	weapon.forward_finisher = _save_attack("short_forward", "short_blade", {
		"startup_frames": 7,
		"active_frames": 5,
		"recovery_frames": 16,
		"damage": 12.0,
		"posture_damage": 14.0,
		"hitbox_offset": Vector2(62.0, -42.0),
		"hitbox_size": Vector2(92.0, 56.0),
		"knockback": Vector2(180.0, 0.0),
		"hitstun_frames": 16,
		"shi_gain_on_hit": 12.0,
		"qi_cost": 1.0,
	})
	weapon.up_finisher = _save_attack("short_up", "short_blade", {
		"startup_frames": 7,
		"active_frames": 4,
		"recovery_frames": 16,
		"damage": 9.0,
		"posture_damage": 10.0,
		"hitbox_offset": Vector2(36.0, -74.0),
		"hitbox_size": Vector2(68.0, 76.0),
		"knockback": Vector2(90.0, -380.0),
		"launch_velocity": Vector2(110.0, -430.0),
		"reaction_type": 1,
		"juggle_cost": 1,
		"hitstun_frames": 20,
		"shi_gain_on_hit": 12.0,
		"qi_cost": 2.0,
	})
	weapon.heavy_finisher = _save_attack("short_heavy", "short_blade", {
		"startup_frames": 13,
		"active_frames": 5,
		"recovery_frames": 18,
		"damage": 18.0,
		"posture_damage": 24.0,
		"guard_qi_damage": 18.0,
		"hitbox_offset": Vector2(52.0, -46.0),
		"hitbox_size": Vector2(90.0, 64.0),
		"knockback": Vector2(180.0, -80.0),
		"reaction_type": 2,
		"knockdown_frames": 30,
		"hitstun_frames": 18,
		"shi_gain_on_hit": 18.0,
		"qi_cost": 3.0,
	})
	weapon.switch_attack = _save_attack("short_switch", "short_blade", {
		"startup_frames": 4,
		"active_frames": 3,
		"recovery_frames": 7,
		"damage": 6.0,
		"posture_damage": 8.0,
		"hitbox_offset": Vector2(38.0, -44.0),
		"hitbox_size": Vector2(62.0, 50.0),
		"knockback": Vector2(70.0, 0.0),
		"hitstun_frames": 9,
		"shi_gain_on_hit": 8.0,
		"qi_cost": 1.0,
	})
	weapon.counter_chain = [
		_counter_attack("short_counter_1", "short_blade", 5.0, 6.0, Vector2(48.0, -44.0)),
		_counter_attack("short_counter_2", "short_blade", 6.0, 7.0, Vector2(40.0, -48.0)),
		_counter_attack("short_counter_3", "short_blade", 8.0, 10.0, Vector2(54.0, -42.0)),
	]
	weapon.air_light = _save_attack("short_air_light", "short_blade", {
		"startup_frames": 4,
		"active_frames": 4,
		"recovery_frames": 8,
		"damage": 7.0,
		"posture_damage": 8.0,
		"hitbox_offset": Vector2(44.0, -48.0),
		"hitbox_size": Vector2(68.0, 56.0),
		"knockback": Vector2(70.0, 0.0),
		"hitstun_frames": 10,
		"juggle_cost": 1,
		"is_air_attack": true,
		"shi_gain_on_hit": 10.0,
	})
	weapon.air_slam = _save_attack("short_air_slam", "short_blade", {
		"startup_frames": 11,
		"active_frames": 8,
		"recovery_frames": 18,
		"damage": 20.0,
		"posture_damage": 24.0,
		"guard_qi_damage": 20.0,
		"hitbox_offset": Vector2(0.0, -20.0),
		"hitbox_size": Vector2(98.0, 82.0),
		"knockback": Vector2(120.0, 0.0),
		"reaction_type": 2,
		"knockdown_frames": 34,
		"juggle_cost": 2,
		"is_air_attack": true,
		"shi_gain_on_hit": 18.0,
		"qi_cost": 2.0,
	})
	weapon.ground_finisher = _ground_finisher("short_ground_finisher", "short_blade", 22.0)
	weapon.burrow_emerge = _save_attack("short_burrow_emerge", "short_blade", {
		"startup_frames": 5,
		"active_frames": 5,
		"recovery_frames": 10,
		"damage": 12.0,
		"posture_damage": 12.0,
		"hitbox_offset": Vector2(34.0, -72.0),
		"hitbox_size": Vector2(76.0, 86.0),
		"knockback": Vector2(80.0, -380.0),
		"launch_velocity": Vector2(100.0, -410.0),
		"reaction_type": 1,
		"juggle_cost": 1,
		"hitstun_frames": 20,
		"shi_cost": 15.0,
		"qi_cost": 2.0,
	})
	return weapon


func _build_enemy_attacks() -> Dictionary:
	return {
		"tian_light": _save_enemy_attack("tian_light", {
			"startup_frames": 9,
			"active_frames": 4,
			"recovery_frames": 14,
			"damage": 10.0,
			"posture_damage": 10.0,
			"guard_qi_damage": 12.0,
			"hitbox_offset": Vector2(52.0, -44.0),
			"hitbox_size": Vector2(76.0, 54.0),
			"knockback": Vector2(110.0, 0.0),
			"hitstun_frames": 12,
		}),
		"tian_heavy": _save_enemy_attack("tian_heavy", {
			"startup_frames": 17,
			"active_frames": 5,
			"recovery_frames": 22,
			"damage": 17.0,
			"posture_damage": 22.0,
			"guard_qi_damage": 20.0,
			"hitbox_offset": Vector2(58.0, -44.0),
			"hitbox_size": Vector2(88.0, 60.0),
			"knockback": Vector2(180.0, -60.0),
			"reaction_type": 2,
			"knockdown_frames": 28,
			"hitstun_frames": 18,
		}),
		"guardian_heavy": _save_enemy_attack("guardian_heavy", {
			"startup_frames": 21,
			"active_frames": 6,
			"recovery_frames": 26,
			"damage": 15.0,
			"posture_damage": 30.0,
			"guard_qi_damage": 24.0,
			"hitbox_offset": Vector2(56.0, -44.0),
			"hitbox_size": Vector2(86.0, 62.0),
			"knockback": Vector2(130.0, 0.0),
			"hitstun_frames": 18,
		}),
		"guardian_break": _save_enemy_attack("guardian_break", {
			"attack_type": 1,
			"startup_frames": 28,
			"active_frames": 6,
			"recovery_frames": 30,
			"damage": 20.0,
			"posture_damage": 34.0,
			"hitbox_offset": Vector2(62.0, -42.0),
			"hitbox_size": Vector2(94.0, 68.0),
			"knockback": Vector2(220.0, -80.0),
			"reaction_type": 2,
			"knockdown_frames": 30,
			"hitstun_frames": 22,
		}),
		"clerk_projectile": _save_enemy_attack("clerk_projectile", {
			"startup_frames": 14,
			"active_frames": 1,
			"recovery_frames": 22,
			"damage": 9.0,
			"posture_damage": 8.0,
			"guard_qi_damage": 14.0,
			"knockback": Vector2(90.0, 0.0),
			"hitstun_frames": 12,
		}),
		"clerk_red": _save_enemy_attack("clerk_red", {
			"attack_type": 1,
			"startup_frames": 26,
			"active_frames": 5,
			"recovery_frames": 28,
			"damage": 18.0,
			"posture_damage": 26.0,
			"hitbox_offset": Vector2(70.0, -46.0),
			"hitbox_size": Vector2(120.0, 70.0),
			"knockback": Vector2(180.0, -80.0),
			"reaction_type": 2,
			"knockdown_frames": 28,
			"hitstun_frames": 20,
		}),
		"anti_burrow_pulse": _save_enemy_attack("anti_burrow_pulse", {
			"attack_type": 2,
			"startup_frames": 16,
			"active_frames": 6,
			"recovery_frames": 24,
			"damage": 13.0,
			"posture_damage": 18.0,
			"hitbox_offset": Vector2(0.0, -6.0),
			"hitbox_size": Vector2(190.0, 80.0),
			"knockback": Vector2(160.0, -80.0),
			"reaction_type": 2,
			"knockdown_frames": 26,
			"hitstun_frames": 18,
		}),
		"boss_swipe": _save_enemy_attack("boss_swipe", {
			"startup_frames": 14,
			"active_frames": 5,
			"recovery_frames": 18,
			"damage": 14.0,
			"posture_damage": 18.0,
			"guard_qi_damage": 18.0,
			"hitbox_offset": Vector2(68.0, -44.0),
			"hitbox_size": Vector2(112.0, 62.0),
			"knockback": Vector2(150.0, 0.0),
			"hitstun_frames": 14,
		}),
		"boss_smash": _save_enemy_attack("boss_smash", {
			"startup_frames": 24,
			"active_frames": 7,
			"recovery_frames": 28,
			"damage": 22.0,
			"posture_damage": 34.0,
			"guard_qi_damage": 28.0,
			"hitbox_offset": Vector2(70.0, -40.0),
			"hitbox_size": Vector2(126.0, 72.0),
			"knockback": Vector2(220.0, -90.0),
			"reaction_type": 2,
			"knockdown_frames": 32,
			"hitstun_frames": 22,
		}),
		"boss_unblockable": _save_enemy_attack("boss_unblockable", {
			"attack_type": 1,
			"startup_frames": 32,
			"active_frames": 7,
			"recovery_frames": 34,
			"damage": 25.0,
			"posture_damage": 42.0,
			"hitbox_offset": Vector2(86.0, -42.0),
			"hitbox_size": Vector2(150.0, 82.0),
			"knockback": Vector2(260.0, -100.0),
			"reaction_type": 2,
			"knockdown_frames": 34,
			"hitstun_frames": 24,
		}),
	}


func _save_enemy_attack(attack_id: String, overrides: Dictionary) -> AttackData:
	var attack: AttackData = ATTACK_DATA_SCRIPT.new()
	attack.attack_id = StringName(attack_id)
	attack.animation_name = StringName(attack_id)
	attack.damage = 0.0
	attack.posture_damage = 0.0
	attack.hitstun_frames = 10
	for property_name: String in overrides:
		attack.set(property_name, overrides[property_name])
	_apply_enemy_attack_feedback(attack_id, attack)
	ResourceSaver.save(attack, "%s%s.tres" % [ENEMY_ATTACK_DIR, attack_id])
	return attack


func _apply_enemy_attack_feedback(attack_id: String, attack: AttackData) -> void:
	if attack_id.contains("boss_unblockable"):
		attack.hitstop_frames = 9
		attack.screen_shake_strength = 0.38
	elif attack_id.contains("boss_smash") or attack_id.contains("guardian_break"):
		attack.hitstop_frames = 7
		attack.screen_shake_strength = 0.28
	elif attack_id.contains("heavy") or attack_id.contains("red"):
		attack.hitstop_frames = 6
		attack.screen_shake_strength = 0.24
	elif attack_id.contains("projectile"):
		attack.hitstop_frames = 3
		attack.screen_shake_strength = 0.14
	else:
		attack.hitstop_frames = 4
		attack.screen_shake_strength = 0.16


func _build_enemy_profiles(attacks: Dictionary) -> void:
	var projectile_scene: PackedScene = load("res://scenes/combat/enemy_projectile.tscn")

	var tian := ENEMY_PROFILE_SCRIPT.new()
	tian.enemy_id = &"tian_bing"
	tian.display_name = "天兵"
	tian.archetype = 0
	tian.max_health = 100.0
	tian.max_posture = 80.0
	tian.max_qi = 100.0
	tian.qi_recovery_per_second = 18.0
	tian.move_speed = 145.0
	tian.preferred_range_min = 48.0
	tian.preferred_range_max = 92.0
	tian.guard_chance = 0.25
	tian.melee_attacks = [attacks["tian_light"], attacks["tian_heavy"]]
	tian.unblockable_attack = attacks["tian_heavy"]
	tian.anti_burrow_attack = attacks["anti_burrow_pulse"]
	ResourceSaver.save(tian, "res://resources/enemies/tian_bing.tres")

	var guardian := ENEMY_PROFILE_SCRIPT.new()
	guardian.enemy_id = &"guardian"
	guardian.display_name = "镇守"
	guardian.archetype = 1
	guardian.max_health = 140.0
	guardian.max_posture = 120.0
	guardian.max_qi = 140.0
	guardian.qi_recovery_per_second = 14.0
	guardian.move_speed = 95.0
	guardian.preferred_range_min = 44.0
	guardian.preferred_range_max = 86.0
	guardian.guard_chance = 0.65
	guardian.melee_attacks = [attacks["guardian_heavy"]]
	guardian.unblockable_attack = attacks["guardian_break"]
	guardian.anti_burrow_attack = attacks["anti_burrow_pulse"]
	ResourceSaver.save(guardian, "res://resources/enemies/guardian.tres")

	var clerk := ENEMY_PROFILE_SCRIPT.new()
	clerk.enemy_id = &"cleric_officer"
	clerk.display_name = "法吏"
	clerk.archetype = 2
	clerk.max_health = 85.0
	clerk.max_posture = 60.0
	clerk.max_qi = 100.0
	clerk.qi_recovery_per_second = 22.0
	clerk.move_speed = 120.0
	clerk.preferred_range_min = 180.0
	clerk.preferred_range_max = 320.0
	clerk.guard_chance = 0.1
	clerk.melee_attacks = [attacks["tian_light"]]
	clerk.unblockable_attack = attacks["clerk_red"]
	clerk.anti_burrow_attack = attacks["anti_burrow_pulse"]
	clerk.projectile_attack = attacks["clerk_projectile"]
	clerk.projectile_scene = projectile_scene
	ResourceSaver.save(clerk, "res://resources/enemies/cleric_officer.tres")

	var boss := ENEMY_PROFILE_SCRIPT.new()
	boss.enemy_id = &"duo_yuan_shen"
	boss.display_name = "夺愿神"
	boss.archetype = 1
	boss.max_health = 320.0
	boss.max_posture = 180.0
	boss.max_qi = 200.0
	boss.qi_recovery_per_second = 20.0
	boss.move_speed = 112.0
	boss.preferred_range_min = 56.0
	boss.preferred_range_max = 104.0
	boss.guard_chance = 0.12
	boss.melee_attacks = [attacks["boss_swipe"], attacks["boss_smash"]]
	boss.unblockable_attack = attacks["boss_unblockable"]
	boss.anti_burrow_attack = attacks["anti_burrow_pulse"]
	ResourceSaver.save(boss, "res://resources/enemies/duo_yuan_shen.tres")


func _build_spear() -> WeaponData:
	var weapon := WEAPON_DATA_SCRIPT.new()
	weapon.weapon_id = &"spear"
	weapon.display_name = "守关长枪"
	weapon.light_chain = [
		_save_attack("spear_l1", "spear", {
			"startup_frames": 7,
			"active_frames": 4,
			"recovery_frames": 10,
			"damage": 8.0,
			"posture_damage": 10.0,
			"hitbox_offset": Vector2(68.0, -42.0),
			"hitbox_size": Vector2(104.0, 48.0),
			"knockback": Vector2(110.0, 0.0),
			"hitstun_frames": 12,
			"shi_gain_on_hit": 10.0,
			"qi_cost": 1.0,
		}),
		_save_attack("spear_l2", "spear", {
			"startup_frames": 7,
			"active_frames": 5,
			"recovery_frames": 12,
			"damage": 9.0,
			"posture_damage": 11.0,
			"hitbox_offset": Vector2(76.0, -42.0),
			"hitbox_size": Vector2(116.0, 50.0),
			"knockback": Vector2(120.0, 0.0),
			"hitstun_frames": 13,
			"shi_gain_on_hit": 10.0,
			"qi_cost": 1.0,
		}),
	]
	weapon.neutral_finisher = _save_attack("spear_neutral", "spear", {
		"startup_frames": 8,
		"active_frames": 5,
		"recovery_frames": 16,
		"damage": 12.0,
		"posture_damage": 15.0,
		"hitbox_offset": Vector2(90.0, -42.0),
		"hitbox_size": Vector2(132.0, 52.0),
		"knockback": Vector2(150.0, 0.0),
		"hitstun_frames": 15,
		"shi_gain_on_hit": 12.0,
		"qi_cost": 1.0,
	})
	weapon.forward_finisher = _save_attack("spear_forward", "spear", {
		"startup_frames": 10,
		"active_frames": 6,
		"recovery_frames": 18,
		"damage": 14.0,
		"posture_damage": 18.0,
		"hitbox_offset": Vector2(108.0, -42.0),
		"hitbox_size": Vector2(150.0, 54.0),
		"knockback": Vector2(230.0, 0.0),
		"hitstun_frames": 18,
		"shi_gain_on_hit": 12.0,
		"qi_cost": 2.0,
	})
	weapon.up_finisher = _save_attack("spear_up", "spear", {
		"startup_frames": 9,
		"active_frames": 5,
		"recovery_frames": 18,
		"damage": 10.0,
		"posture_damage": 12.0,
		"hitbox_offset": Vector2(48.0, -78.0),
		"hitbox_size": Vector2(94.0, 92.0),
		"knockback": Vector2(90.0, -390.0),
		"launch_velocity": Vector2(100.0, -450.0),
		"reaction_type": 1,
		"juggle_cost": 1,
		"hitstun_frames": 22,
		"shi_gain_on_hit": 12.0,
		"qi_cost": 2.0,
	})
	weapon.heavy_finisher = _save_attack("spear_heavy", "spear", {
		"startup_frames": 15,
		"active_frames": 5,
		"recovery_frames": 20,
		"damage": 20.0,
		"posture_damage": 28.0,
		"guard_qi_damage": 24.0,
		"hitbox_offset": Vector2(92.0, -42.0),
		"hitbox_size": Vector2(142.0, 58.0),
		"knockback": Vector2(230.0, -70.0),
		"reaction_type": 2,
		"knockdown_frames": 32,
		"hitstun_frames": 20,
		"shi_gain_on_hit": 18.0,
		"qi_cost": 3.0,
	})
	weapon.switch_attack = _save_attack("spear_switch", "spear", {
		"startup_frames": 6,
		"active_frames": 4,
		"recovery_frames": 12,
		"damage": 7.0,
		"posture_damage": 10.0,
		"hitbox_offset": Vector2(54.0, -42.0),
		"hitbox_size": Vector2(88.0, 50.0),
		"knockback": Vector2(-90.0, 0.0),
		"hitstun_frames": 10,
		"shi_gain_on_hit": 8.0,
		"qi_cost": 1.0,
	})
	weapon.counter_chain = [
		_counter_attack("spear_counter", "spear", 18.0, 24.0, Vector2(92.0, -42.0)),
	]
	weapon.air_light = _save_attack("spear_air_light", "spear", {
		"startup_frames": 5,
		"active_frames": 4,
		"recovery_frames": 9,
		"damage": 8.0,
		"posture_damage": 10.0,
		"hitbox_offset": Vector2(62.0, -48.0),
		"hitbox_size": Vector2(102.0, 54.0),
		"knockback": Vector2(80.0, 0.0),
		"hitstun_frames": 11,
		"juggle_cost": 1,
		"is_air_attack": true,
		"shi_gain_on_hit": 10.0,
	})
	weapon.air_slam = _save_attack("spear_air_slam", "spear", {
		"startup_frames": 12,
		"active_frames": 8,
		"recovery_frames": 20,
		"damage": 21.0,
		"posture_damage": 26.0,
		"guard_qi_damage": 22.0,
		"hitbox_offset": Vector2(0.0, -20.0),
		"hitbox_size": Vector2(104.0, 86.0),
		"knockback": Vector2(120.0, 0.0),
		"reaction_type": 2,
		"knockdown_frames": 34,
		"juggle_cost": 2,
		"is_air_attack": true,
		"shi_gain_on_hit": 18.0,
		"qi_cost": 2.0,
	})
	weapon.ground_finisher = _ground_finisher("spear_ground_finisher", "spear", 24.0)
	weapon.burrow_emerge = _save_attack("spear_burrow_emerge", "spear", {
		"startup_frames": 6,
		"active_frames": 5,
		"recovery_frames": 12,
		"damage": 13.0,
		"posture_damage": 14.0,
		"hitbox_offset": Vector2(44.0, -78.0),
		"hitbox_size": Vector2(104.0, 92.0),
		"knockback": Vector2(90.0, -390.0),
		"launch_velocity": Vector2(100.0, -430.0),
		"reaction_type": 1,
		"juggle_cost": 1,
		"hitstun_frames": 21,
		"shi_cost": 15.0,
		"qi_cost": 2.0,
	})
	return weapon


func _save_attack(
	attack_id: String,
	weapon_dir: String,
	overrides: Dictionary,
) -> AttackData:
	var attack: AttackData = ATTACK_DATA_SCRIPT.new()
	attack.attack_id = StringName(attack_id)
	attack.animation_name = StringName(attack_id)
	attack.damage = 0.0
	attack.posture_damage = 0.0
	attack.hitstun_frames = 10
	attack.shi_gain_on_hit = 0.0
	var converted_shi_cost := 0.0
	for property_name: String in overrides:
		if property_name == "qi_cost":
			converted_shi_cost = maxf(converted_shi_cost, float(overrides[property_name]))
			continue
		attack.set(property_name, overrides[property_name])
	attack.shi_cost = maxf(attack.shi_cost, converted_shi_cost)
	attack.qi_cost = 0.0
	_apply_attack_shi_cost(attack_id, attack)
	_apply_player_attack_feedback(attack_id, attack)
	_apply_player_attack_motion(attack_id, attack)

	var directory := SHORT_BLADE_DIR if weapon_dir == "short_blade" else SPEAR_DIR
	ResourceSaver.save(attack, "%s%s.tres" % [directory, attack_id])
	return attack


func _apply_attack_shi_cost(attack_id: String, attack: AttackData) -> void:
	if attack_id.contains("counter"):
		attack.shi_cost = 0.0
	elif attack_id.contains("air_slam"):
		attack.shi_cost = 20.0
	elif attack_id.contains("ground_finisher"):
		attack.shi_cost = 20.0
	elif attack_id.contains("burrow_emerge"):
		attack.shi_cost = 15.0
	elif attack_id.contains("heavy"):
		attack.shi_cost = 25.0
	elif attack_id.contains("air_light"):
		attack.shi_cost = 8.0
	elif attack_id.contains("switch"):
		attack.shi_cost = 8.0
	elif attack_id.contains("up"):
		attack.shi_cost = 15.0
	elif attack_id.contains("forward"):
		attack.shi_cost = 15.0
	elif attack_id.contains("neutral"):
		attack.shi_cost = 12.0
	elif attack_id.ends_with("_l1") or attack_id.ends_with("_l2"):
		attack.shi_cost = 8.0


func _apply_player_attack_feedback(attack_id: String, attack: AttackData) -> void:
	if attack_id.contains("air_slam") or attack_id.contains("ground_finisher"):
		attack.hitstop_frames = 8
		attack.screen_shake_strength = 0.32
	elif attack_id.contains("heavy"):
		attack.hitstop_frames = 7
		attack.screen_shake_strength = 0.28
	elif attack_id.contains("up") or attack_id.contains("forward"):
		attack.hitstop_frames = 6
		attack.screen_shake_strength = 0.24
	elif attack_id.contains("neutral"):
		attack.hitstop_frames = 5
		attack.screen_shake_strength = 0.2
	elif attack_id.contains("counter"):
		attack.hitstop_frames = 3
		attack.screen_shake_strength = 0.12
	else:
		attack.hitstop_frames = 3
		attack.screen_shake_strength = 0.12


func _apply_player_attack_motion(attack_id: String, attack: AttackData) -> void:
	if attack_id.contains("air_") or attack_id.contains("ground_finisher") or attack_id.contains("burrow_emerge"):
		attack.forward_motion_speed = 0.0
	elif attack_id.contains("forward"):
		attack.forward_motion_speed = 155.0
	elif attack_id.contains("heavy"):
		attack.forward_motion_speed = 85.0
	elif attack_id.contains("neutral"):
		attack.forward_motion_speed = 70.0
	elif attack_id.contains("up"):
		attack.forward_motion_speed = 35.0
	elif attack_id.contains("switch"):
		attack.forward_motion_speed = 55.0
	elif attack_id.contains("counter"):
		attack.forward_motion_speed = 25.0
	elif attack_id.ends_with("_l1"):
		attack.forward_motion_speed = 38.0
	elif attack_id.ends_with("_l2"):
		attack.forward_motion_speed = 32.0
	else:
		attack.forward_motion_speed = 0.0


func _counter_attack(
	attack_id: String,
	weapon_dir: String,
	damage: float,
	posture_damage: float,
	hitbox_offset: Vector2,
) -> AttackData:
	return _save_attack(attack_id, weapon_dir, {
		"startup_frames": 3,
		"active_frames": 3,
		"recovery_frames": 5,
		"damage": damage,
		"posture_damage": posture_damage,
		"hitbox_offset": hitbox_offset,
		"hitbox_size": Vector2(72.0, 54.0),
		"knockback": Vector2(70.0, 0.0),
		"hitstun_frames": 8,
		"shi_gain_on_hit": 8.0,
	})


func _ground_finisher(
	attack_id: String,
	weapon_dir: String,
	damage: float,
) -> AttackData:
	return _save_attack(attack_id, weapon_dir, {
		"startup_frames": 12,
		"active_frames": 5,
		"recovery_frames": 20,
		"damage": damage,
		"posture_damage": 30.0,
		"hitbox_offset": Vector2(48.0, -22.0),
		"hitbox_size": Vector2(96.0, 52.0),
		"knockback": Vector2(80.0, -80.0),
		"reaction_type": 2,
		"knockdown_frames": 36,
		"is_ground_finisher": true,
		"hitstun_frames": 24,
		"shi_gain_on_hit": 20.0,
		"qi_cost": 2.0,
	})
