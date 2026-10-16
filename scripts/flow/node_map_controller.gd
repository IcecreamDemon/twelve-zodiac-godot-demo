class_name NodeMapController
extends CanvasLayer

signal option_selected(option_id: StringName)

@onready var title_label: Label = $Root/MapPanel/Title
@onready var option_list: VBoxContainer = $Root/MapPanel/OptionList


func show_options(title: String, options: Array[Dictionary]) -> void:
	visible = true
	title_label.text = title
	for child: Node in option_list.get_children():
		child.queue_free()

	for option: Dictionary in options:
		var button := Button.new()
		button.text = option.get("title", "继续")
		button.custom_minimum_size = Vector2(430.0, 54.0)
		button.pressed.connect(_on_option_pressed.bind(StringName(option["id"])))
		option_list.add_child(button)


func hide_options() -> void:
	visible = false


func _on_option_pressed(option_id: StringName) -> void:
	hide_options()
	option_selected.emit(option_id)
