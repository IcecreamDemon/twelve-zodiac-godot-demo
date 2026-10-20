extends Node

signal combat_started(context: Dictionary)
signal combat_finished(context: Dictionary)
signal actor_died(actor: Node, context: Dictionary)
signal flow_state_changed(previous_state: StringName, next_state: StringName)
signal hit_resolved(world_position: Vector2, strength: float)
signal parry_succeeded(world_position: Vector2)


func emit_combat_started(context: Dictionary = {}) -> void:
	combat_started.emit(context)


func emit_combat_finished(context: Dictionary = {}) -> void:
	combat_finished.emit(context)


func emit_actor_died(actor: Node, context: Dictionary = {}) -> void:
	actor_died.emit(actor, context)


func emit_flow_state_changed(previous_state: StringName, next_state: StringName) -> void:
	flow_state_changed.emit(previous_state, next_state)


func emit_hit_resolved(world_position: Vector2, strength: float) -> void:
	hit_resolved.emit(world_position, strength)


func emit_parry_succeeded(world_position: Vector2) -> void:
	parry_succeeded.emit(world_position)
