class_name QiComponent
extends Node

signal qi_changed(current: float, maximum: float)

@export_range(1.0, 9999.0, 1.0) var max_qi: float = 100.0
@export_range(0.0, 999.0, 0.1) var recovery_per_second: float = 0.0

var current_qi: float


func _ready() -> void:
	current_qi = max_qi


func _process(delta: float) -> void:
	if recovery_per_second <= 0.0 or current_qi >= max_qi:
		return
	restore(recovery_per_second * delta)


func consume(amount: float) -> bool:
	if amount < 0.0:
		return false
	if current_qi < amount:
		return false

	current_qi -= amount
	qi_changed.emit(current_qi, max_qi)
	return true


func restore(amount: float) -> void:
	if amount <= 0.0:
		return
	current_qi = minf(current_qi + amount, max_qi)
	qi_changed.emit(current_qi, max_qi)


func reset() -> void:
	current_qi = max_qi
	qi_changed.emit(current_qi, max_qi)


func get_ratio() -> float:
	return current_qi / max_qi
