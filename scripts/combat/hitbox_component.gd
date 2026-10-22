class_name HitboxComponent
extends Area2D

signal attack_started(attack_data: AttackData)
signal attack_finished(attack_data: AttackData)
signal hit_confirmed(target: Node, attack_data: AttackData)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var attack_data: AttackData
var direction: int = 1
var frame_index: int = 0
var is_active: bool = false

var _hit_targets: Dictionary = {}
var _hitstop_running: bool = false


func _ready() -> void:
	monitoring = false
	monitorable = false
	collision_shape.disabled = true


func begin_attack(data: AttackData, facing_direction: int) -> void:
	attack_data = data
	direction = 1 if facing_direction >= 0 else -1
	frame_index = 0
	is_active = false
	_hit_targets.clear()
	position = Vector2(
		attack_data.hitbox_offset.x * direction,
		attack_data.hitbox_offset.y,
	)

	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = attack_data.hitbox_size

	collision_shape.disabled = true
	monitoring = true
	attack_started.emit(attack_data)


func _physics_process(_delta: float) -> void:
	if attack_data == null:
		return

	frame_index += 1
	var active_from := attack_data.startup_frames
	var active_until := active_from + attack_data.active_frames
	is_active = frame_index >= active_from and frame_index < active_until
	collision_shape.disabled = not is_active

	if is_active:
		for area: Area2D in get_overlapping_areas():
			_try_hit(area)

	if frame_index >= attack_data.total_frames:
		_finish_attack()


func _try_hit(area: Area2D) -> void:
	if area is not HurtboxComponent:
		return
	if _hit_targets.has(area):
		return

	var hurtbox := area as HurtboxComponent
	var result := hurtbox.receive_attack(get_parent(), attack_data, direction)
	if result != HurtboxComponent.ReceiveResult.IGNORED:
		_hit_targets[area] = true
		hit_confirmed.emit(hurtbox.get_parent(), attack_data)
		_play_hit_feedback(result, hurtbox.get_parent())


func _play_hit_feedback(result: HurtboxComponent.ReceiveResult, target: Node) -> void:
	var events := get_node_or_null("/root/GameEvents")
	if events != null:
		if result == HurtboxComponent.ReceiveResult.PARRY:
			var weapon_id: StringName = &""
			if target.has_method("get_current_weapon_id"):
				weapon_id = target.call("get_current_weapon_id")
			events.emit_parry_succeeded(global_position, weapon_id)
		elif result == HurtboxComponent.ReceiveResult.BLOCK:
			events.emit_block_succeeded(global_position)
		else:
			var strength := attack_data.screen_shake_strength
			events.emit_hit_resolved(global_position, strength)

	if not _hitstop_running:
		var frames := attack_data.hitstop_frames
		if result == HurtboxComponent.ReceiveResult.PARRY:
			frames = maxi(frames + 3, 7)
		if frames > 0:
			_apply_hitstop(frames)


func _apply_hitstop(frames: int) -> void:
	_hitstop_running = true
	Engine.time_scale = 0.08
	await get_tree().create_timer(
		float(frames) / 60.0,
		true,
		false,
		true,
	).timeout
	Engine.time_scale = 1.0
	_hitstop_running = false


func _finish_attack() -> void:
	var finished_data := attack_data
	attack_data = null
	frame_index = 0
	is_active = false
	_hit_targets.clear()
	collision_shape.disabled = true
	monitoring = false
	attack_finished.emit(finished_data)


func cancel_attack() -> void:
	if attack_data == null:
		return
	_finish_attack()
