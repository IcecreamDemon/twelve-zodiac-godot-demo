class_name CombatCamera
extends Camera2D

@export var max_shake_offset: float = 14.0
@export var max_shake_rotation: float = 0.012
@export var trauma_decay_per_second: float = 2.8

var trauma: float = 0.0
var _parry_zoom_running: bool = false


func _ready() -> void:
	make_current()
	var events := get_node_or_null("/root/GameEvents")
	if events != null:
		events.hit_resolved.connect(_on_hit_resolved)
		events.block_succeeded.connect(_on_block_succeeded)
		events.parry_succeeded.connect(_on_parry_succeeded)


func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = maxf(trauma - trauma_decay_per_second * delta, 0.0)
		var strength := trauma * trauma
		offset = Vector2(
			randf_range(-max_shake_offset, max_shake_offset),
			randf_range(-max_shake_offset, max_shake_offset),
		) * strength
		rotation = randf_range(-max_shake_rotation, max_shake_rotation) * strength
	else:
		offset = offset.lerp(Vector2.ZERO, minf(delta * 18.0, 1.0))
		rotation = lerpf(rotation, 0.0, minf(delta * 18.0, 1.0))


func _on_hit_resolved(_world_position: Vector2, strength: float) -> void:
	trauma = minf(trauma + maxf(strength, 0.0) * 3.0, 1.0)


func _on_block_succeeded(_world_position: Vector2) -> void:
	trauma = minf(trauma + 0.2, 1.0)


func _on_parry_succeeded(_world_position: Vector2, _weapon_id: StringName) -> void:
	trauma = minf(trauma + 0.7, 1.0)
	if not _parry_zoom_running:
		_parry_zoom_running = true
		var tween := create_tween()
		tween.tween_property(self, "zoom", Vector2(1.02, 1.02), 0.05)
		tween.tween_property(self, "zoom", Vector2.ONE, 0.12)
		await tween.finished
		_parry_zoom_running = false
