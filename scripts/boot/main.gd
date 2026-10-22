extends Node

const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"


func _ready() -> void:
	get_tree().change_scene_to_file.call_deferred(TITLE_SCENE)
