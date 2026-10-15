class_name CombatDebugOverlay
extends Control

@onready var state_label: Label = $StateLabel
@onready var frame_label: Label = $FrameLabel

var _player: PlayerController
var _dummy: TrainingDummy


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	_resolve_actors()
	queue_redraw()

	if _player == null:
		state_label.text = "PLAYER  --"
		frame_label.text = "FRAME  --"
		return

	var hitbox := _player.hitbox
	state_label.text = "PLAYER  %s" % String(_player.state_machine.current_state).to_upper()
	frame_label.text = "ATTACK FRAME  %02d / %02d   ACTIVE  %s" % [
		hitbox.frame_index,
		hitbox.attack_data.total_frames if hitbox.attack_data != null else 0,
		str(hitbox.is_active).to_upper(),
	]


func _draw() -> void:
	var debug_flags := get_node_or_null("/root/DebugFlags")
	if debug_flags == null or not debug_flags.show_hitboxes:
		return

	for node: Node in get_tree().get_nodes_in_group(&"combat_hitbox"):
		var hitbox := node as HitboxComponent
		if hitbox == null or not hitbox.is_active:
			continue

		var rectangle := hitbox.collision_shape.shape as RectangleShape2D
		if rectangle == null:
			continue
		var draw_position := hitbox.global_position - rectangle.size * 0.5
		draw_rect(Rect2(draw_position, rectangle.size), Color(1.0, 0.1, 0.1, 0.28), true)
		draw_rect(Rect2(draw_position, rectangle.size), Color(1.0, 0.2, 0.2, 0.9), false, 2.0)


func _resolve_actors() -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(&"player") as PlayerController
	if not is_instance_valid(_dummy):
		_dummy = get_tree().get_first_node_in_group(&"training_dummy") as TrainingDummy
