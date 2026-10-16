extends Node

const DEMO_FLOW_SCENE := "res://scenes/flow/demo_flow.tscn"


func _ready() -> void:
	get_tree().change_scene_to_file.call_deferred(DEMO_FLOW_SCENE)
