class_name ActorStateMachine
extends Node

signal state_changed(previous_state: StringName, next_state: StringName)

@export var initial_state: StringName = &"idle"

var current_state: StringName
var previous_state: StringName = &""
var frames_in_state: int = 0


func _ready() -> void:
	current_state = initial_state


func tick() -> void:
	frames_in_state += 1


func transition_to(next_state: StringName) -> void:
	if current_state == next_state:
		return

	previous_state = current_state
	current_state = next_state
	frames_in_state = 0
	state_changed.emit(previous_state, current_state)


func is_state(state: StringName) -> bool:
	return current_state == state
