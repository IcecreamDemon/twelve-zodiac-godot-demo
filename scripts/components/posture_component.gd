class_name PostureComponent
extends Node

signal posture_changed(current: float, maximum: float)
signal guard_broken

@export_range(1.0, 9999.0, 1.0) var max_posture: float = 80.0
@export_range(0.0, 999.0, 0.1) var recovery_per_second: float = 12.0
@export_range(0.0, 10.0, 0.01) var recovery_delay: float = 1.5

var current_posture: float
var _recovery_timer: float = 0.0


func _ready() -> void:
	current_posture = max_posture


func _process(delta: float) -> void:
	if current_posture >= max_posture:
		return

	_recovery_timer = maxf(_recovery_timer - delta, 0.0)
	if _recovery_timer > 0.0:
		return

	current_posture = minf(current_posture + recovery_per_second * delta, max_posture)
	posture_changed.emit(current_posture, max_posture)


func take_posture_damage(amount: float) -> bool:
	if amount <= 0.0:
		return false

	_recovery_timer = recovery_delay
	current_posture = maxf(current_posture - amount, 0.0)
	posture_changed.emit(current_posture, max_posture)

	if is_zero_approx(current_posture):
		guard_broken.emit()
		return true

	return false


func reset() -> void:
	current_posture = max_posture
	_recovery_timer = 0.0
	posture_changed.emit(current_posture, max_posture)


func get_ratio() -> float:
	return current_posture / max_posture
