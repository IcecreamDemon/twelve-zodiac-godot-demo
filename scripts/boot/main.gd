extends Node

const COMBAT_LAB_SCENE := "res://scenes/tests/combat_lab.tscn"


func _ready() -> void:
	get_tree().change_scene_to_file.call_deferred(COMBAT_LAB_SCENE)
