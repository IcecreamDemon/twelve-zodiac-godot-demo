class_name HealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal died

@export_range(1.0, 9999.0, 1.0) var max_health: float = 100.0

var current_health: float


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> bool:
	if amount <= 0.0 or current_health <= 0.0:
		return current_health <= 0.0

	current_health = maxf(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)

	if is_zero_approx(current_health):
		died.emit()
		return true

	return false


func restore(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func get_ratio() -> float:
	return current_health / max_health
