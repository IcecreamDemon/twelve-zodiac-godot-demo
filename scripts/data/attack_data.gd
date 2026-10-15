class_name AttackData
extends Resource

enum AttackType {
	NORMAL,
	UNBLOCKABLE,
	ANTI_BURROW,
}

enum ReactionType {
	STUN,
	LAUNCH,
	KNOCKDOWN,
}

@export var attack_id: StringName = &"attack"
@export var animation_name: StringName = &"attack"
@export var attack_type: AttackType = AttackType.NORMAL
@export_range(0, 120, 1) var startup_frames: int = 6
@export_range(1, 120, 1) var active_frames: int = 3
@export_range(0, 240, 1) var recovery_frames: int = 10
@export_range(0.0, 999.0, 0.1) var damage: float = 10.0
@export_range(0.0, 999.0, 0.1) var posture_damage: float = 10.0
@export_range(0.0, 999.0, 0.1) var guard_qi_damage: float = 8.0
@export var hitbox_offset: Vector2 = Vector2(42.0, 0.0)
@export var hitbox_size: Vector2 = Vector2(64.0, 48.0)
@export var knockback: Vector2 = Vector2(120.0, 0.0)
@export var launch_velocity: Vector2 = Vector2(120.0, -420.0)
@export_range(0, 120, 1) var hitstun_frames: int = 12
@export_range(0, 240, 1) var knockdown_frames: int = 28
@export var reaction_type: ReactionType = ReactionType.STUN
@export_range(0, 5, 1) var juggle_cost: int = 0
@export var is_air_attack: bool = false
@export var is_ground_finisher: bool = false
@export_range(0.0, 100.0, 0.1) var shi_gain_on_hit: float = 10.0
@export_range(0.0, 100.0, 0.1) var shi_cost: float = 0.0
@export_range(0.0, 100.0, 0.1) var qi_cost: float = 0.0
@export_range(0, 120, 1) var buffer_start_frame: int = 0
@export_range(0, 120, 1) var buffer_end_frame: int = 0
@export_range(0, 30, 1) var hitstop_frames: int = 3
@export_range(0.0, 2.0, 0.01) var screen_shake_strength: float = 0.1

var total_frames: int:
	get:
		return startup_frames + active_frames + recovery_frames
