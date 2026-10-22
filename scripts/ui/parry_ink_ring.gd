class_name ParryInkRing
extends Control

var radius: float = 0.0
var alpha: float = 0.0
var ring_color: Color = Color(0.95, 0.82, 0.5, 1.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _draw() -> void:
	if alpha <= 0.0 or radius <= 0.0:
		return
	var color := Color(ring_color.r, ring_color.g, ring_color.b, alpha)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, color, 5.0, true)
	draw_arc(
		Vector2.ZERO,
		radius * 0.68,
		0.0,
		TAU,
		40,
		Color(color.r, color.g, color.b, alpha * 0.65),
		2.0,
		true,
	)


func play(world_position: Vector2, color: Color) -> void:
	position = world_position
	ring_color = color
	radius = 10.0
	alpha = 0.9
	visible = true
	queue_redraw()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "radius", 92.0, 0.34)
	tween.tween_property(self, "alpha", 0.0, 0.34)
	await tween.finished
	visible = false
