extends CanvasLayer

@onready var flash: ColorRect = $Root/Flash
@onready var stamp: Label = $Root/Stamp
@onready var ink_ring: ParryInkRing = $Root/InkRing


func _ready() -> void:
	var events := get_node_or_null("/root/GameEvents")
	if events != null:
		events.parry_succeeded.connect(_on_parry_succeeded)


func _on_parry_succeeded(world_position: Vector2, weapon_id: StringName) -> void:
	var color := Color(0.96, 0.9, 0.72, 1.0)
	if weapon_id == &"spear":
		color = Color(0.95, 0.67, 0.28, 1.0)

	_play_flash(color)
	_play_stamp(world_position, color)
	ink_ring.play(world_position, color)


func _play_flash(color: Color) -> void:
	flash.color = Color(color.r, color.g, color.b, 0.2)
	flash.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.2)


func _play_stamp(world_position: Vector2, color: Color) -> void:
	stamp.position = world_position + Vector2(-52.0, -168.0)
	stamp.modulate = Color(color.r, color.g, color.b, 0.0)
	stamp.scale = Vector2(0.45, 0.45)
	stamp.visible = true
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(stamp, "modulate", Color(color.r, color.g, color.b, 1.0), 0.07)
	tween.tween_property(stamp, "scale", Vector2(1.08, 1.08), 0.1)
	tween.chain().tween_interval(0.1)
	tween.chain().tween_property(stamp, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(_hide_stamp)


func _hide_stamp() -> void:
	stamp.visible = false
