extends Node

var show_hitboxes: bool = true
var show_combat_state: bool = true
var show_frame_counters: bool = true


func toggle_hitboxes() -> void:
	show_hitboxes = not show_hitboxes
