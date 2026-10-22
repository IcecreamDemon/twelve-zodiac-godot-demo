extends Control

const DEMO_FLOW_SCENE := "res://scenes/flow/demo_flow.tscn"

@onready var start_button: Button = $StartButton
@onready var controls_button: Button = $ControlsButton
@onready var quit_button: Button = $QuitButton
@onready var controls_panel: Panel = $ControlsPanel
@onready var close_controls_button: Button = $ControlsPanel/CloseButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_controls_button.pressed.connect(_hide_controls)
	controls_panel.visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and controls_panel.visible:
		get_viewport().set_input_as_handled()
		_hide_controls()


func _on_start_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(DEMO_FLOW_SCENE)


func _on_controls_pressed() -> void:
	controls_panel.visible = true


func _hide_controls() -> void:
	controls_panel.visible = false


func _on_quit_pressed() -> void:
	get_tree().quit()
