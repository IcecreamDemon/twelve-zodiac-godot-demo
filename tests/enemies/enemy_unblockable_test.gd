extends SceneTree

const ENEMY_SCENE := preload("res://scenes/actors/enemies/guardian.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var enemy := ENEMY_SCENE.instantiate() as EnemyController
	root.add_child(enemy)
	await process_frame

	var attack := AttackData.new()
	attack.attack_type = AttackData.AttackType.UNBLOCKABLE
	attack.damage = 12.0
	attack.posture_damage = 12.0
	attack.guard_qi_damage = 30.0

	var health_before := enemy.health.current_health
	enemy.state_machine.transition_to(EnemyController.STATE_GUARD)
	var result := enemy.receive_hit(null, attack, 1)
	if result != HurtboxComponent.ReceiveResult.HIT:
		failures.append("Unblockable attack did not bypass guard.")
	if enemy.health.current_health >= health_before:
		failures.append("Unblockable attack did not damage health.")

	if failures.is_empty():
		print("ENEMY UNBLOCKABLE TEST PASS: red attacks bypass guard.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
