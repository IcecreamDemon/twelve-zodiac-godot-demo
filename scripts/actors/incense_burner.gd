class_name IncenseBurner
extends StaticBody2D

@export_range(0.0, 100.0, 0.1) var restore_shi: float = 30.0

@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $Hurtbox
@onready var visual: Polygon2D = $Visual


func _ready() -> void:
	health.died.connect(_on_died)


func receive_hit(
	attacker: Node,
	attack_data: AttackData,
	direction: int,
) -> HurtboxComponent.ReceiveResult:
	if health.current_health <= 0.0:
		return HurtboxComponent.ReceiveResult.IGNORED
	if CombatResolver.resolve_hit(attacker, self, attack_data, direction, 1.0):
		return HurtboxComponent.ReceiveResult.HIT
	return HurtboxComponent.ReceiveResult.IGNORED


func apply_hit_reaction(_attack_data: AttackData, _direction: int) -> void:
	var tween := create_tween()
	visual.modulate = Color(1.0, 0.55, 0.2, 1.0)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.14)


func _on_died() -> void:
	hurtbox.receive_hits = false
	var player := get_tree().get_first_node_in_group(&"player") as PlayerController
	if player != null:
		player.shi.add(restore_shi)
	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
