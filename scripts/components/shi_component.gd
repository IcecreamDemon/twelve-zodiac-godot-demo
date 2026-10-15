class_name ShiComponent
extends Node

signal shi_changed(current: float, maximum: float)

@export_range(1.0, 9999.0, 1.0) var max_shi: float = 100.0

var current_shi: float = 0.0


func add(amount: float) -> void:
	if amount <= 0.0:
		return
	current_shi = minf(current_shi + amount, max_shi)
	shi_changed.emit(current_shi, max_shi)


func consume(amount: float) -> bool:
	if amount < 0.0:
		return false
	if current_shi < amount:
		return false

	current_shi -= amount
	shi_changed.emit(current_shi, max_shi)
	return true


func reset() -> void:
	current_shi = 0.0
	shi_changed.emit(current_shi, max_shi)


func get_ratio() -> float:
	return current_shi / max_shi
