class_name WeaponData
extends Resource

@export var weapon_id: StringName = &"weapon"
@export var display_name: String = "Weapon"
@export var light_chain: Array[AttackData] = []
@export var neutral_finisher: AttackData
@export var forward_finisher: AttackData
@export var up_finisher: AttackData
@export var heavy_finisher: AttackData
@export var switch_attack: AttackData
@export var counter_chain: Array[AttackData] = []
@export var air_light: AttackData
@export var air_slam: AttackData
@export var ground_finisher: AttackData


func is_valid() -> bool:
	return (
		light_chain.size() >= 2
		and neutral_finisher != null
		and forward_finisher != null
		and up_finisher != null
		and heavy_finisher != null
		and switch_attack != null
		and not counter_chain.is_empty()
		and air_light != null
		and air_slam != null
		and ground_finisher != null
	)
