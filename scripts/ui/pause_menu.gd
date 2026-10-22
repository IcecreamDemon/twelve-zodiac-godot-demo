extends CanvasLayer

signal restart_requested
signal title_requested

@onready var root: Control = $Root
@onready var panel: Panel = $Root/Panel
@onready var resume_button: Button = $Root/Panel/ResumeButton
@onready var restart_button: Button = $Root/Panel/RestartButton
@onready var controls_button: Button = $Root/Panel/ControlsButton
@onready var title_button: Button = $Root/Panel/TitleButton
@onready var quit_button: Button = $Root/Panel/QuitButton
@onready var volume_slider: HSlider = $Root/Panel/VolumeSlider
@onready var volume_value: Label = $Root/Panel/VolumeValue
@onready var controls_panel: Panel = $Root/ControlsPanel
@onready var close_controls_button: Button = $Root/ControlsPanel/CloseButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	resume_button.pressed.connect(close_menu)
	restart_button.pressed.connect(_request_restart)
	controls_button.pressed.connect(_show_controls)
	title_button.pressed.connect(_request_title)
	quit_button.pressed.connect(_quit)
	close_controls_button.pressed.connect(_hide_controls)
	volume_slider.value_changed.connect(_on_volume_changed)
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null:
		volume_slider.value = audio.get_master_volume()
	_update_volume_label(volume_slider.value)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return
	get_viewport().set_input_as_handled()
	if not root.visible:
		open_menu()
	elif controls_panel.visible:
		_hide_controls()
	else:
		close_menu()


func open_menu() -> void:
	root.visible = true
	controls_panel.visible = false
	get_tree().paused = true


func close_menu() -> void:
	_play_ui()
	get_tree().paused = false
	root.visible = false


func _show_controls() -> void:
	_play_ui()
	controls_panel.visible = true


func _hide_controls() -> void:
	_play_ui()
	controls_panel.visible = false


func _request_restart() -> void:
	close_menu()
	restart_requested.emit()


func _request_title() -> void:
	close_menu()
	title_requested.emit()


func _quit() -> void:
	_play_ui()
	get_tree().paused = false
	get_tree().quit()


func _exit_tree() -> void:
	get_tree().paused = false


func _on_volume_changed(value: float) -> void:
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null:
		audio.set_master_volume(value)
	_update_volume_label(value)


func _update_volume_label(value: float) -> void:
	volume_value.text = "%d%%" % roundi(value)


func _play_ui() -> void:
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null:
		audio.play_ui()
