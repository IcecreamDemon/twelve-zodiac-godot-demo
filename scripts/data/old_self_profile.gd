class_name OldSelfProfile
extends Resource

@export_range(0.0, 1000.0, 1.0) var preferred_distance_min: float = 48.0
@export_range(0.0, 1000.0, 1.0) var preferred_distance_max: float = 96.0
@export var combo_sequence: Array[AttackData] = []
@export_range(-1, 1, 2) var dodge_direction: int = 1
