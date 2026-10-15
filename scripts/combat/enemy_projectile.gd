class_name EnemyProjectile
extends Area2D

@export_range(0.0, 2000.0, 1.0) var speed: float = 460.0
@export_range(0.1, 10.0, 0.1) var lifetime: float = 2.5

var attack_data: AttackData
var direction: int = 1
var source: Node


func setup(data: AttackData, facing_direction: int, source_actor: Node) -> void:
	attack_data = data
	direction = 1 if facing_direction >= 0 else -1
	source = source_actor


func _ready() -> void:
	collision_layer = 0
	collision_mask = 8
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta


func _on_area_entered(area: Area2D) -> void:
	if area is not HurtboxComponent:
		return
	var hurtbox := area as HurtboxComponent
	var result := hurtbox.receive_attack(source, attack_data, direction)
	if result != HurtboxComponent.ReceiveResult.IGNORED:
		queue_free()
