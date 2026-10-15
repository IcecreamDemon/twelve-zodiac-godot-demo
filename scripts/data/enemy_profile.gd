class_name EnemyProfile
extends Resource

enum Archetype {
	TIAN_BING,
	GUARDIAN,
	CLERIC_OFFICER,
}

@export var enemy_id: StringName = &"enemy"
@export var display_name: String = "Enemy"
@export var archetype: Archetype = Archetype.TIAN_BING
@export_range(1.0, 9999.0, 1.0) var max_health: float = 100.0
@export_range(1.0, 9999.0, 1.0) var max_posture: float = 80.0
@export_range(1.0, 9999.0, 1.0) var max_qi: float = 100.0
@export_range(0.0, 999.0, 0.1) var qi_recovery_per_second: float = 18.0
@export_range(0.0, 1000.0, 1.0) var move_speed: float = 130.0
@export_range(0.0, 1000.0, 1.0) var preferred_range_min: float = 48.0
@export_range(0.0, 1000.0, 1.0) var preferred_range_max: float = 96.0
@export_range(0.0, 1.0, 0.01) var guard_chance: float = 0.25
@export var uses_guard: bool = true
@export var melee_attacks: Array[AttackData] = []
@export var unblockable_attack: AttackData
@export var projectile_attack: AttackData
@export var projectile_scene: PackedScene
