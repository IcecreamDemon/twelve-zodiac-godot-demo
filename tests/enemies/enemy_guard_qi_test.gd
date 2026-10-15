extends SceneTree

const ENEMY_SCENE := preload("res://scenes/actors/enemies/tian_bing.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var enemy := ENEMY_SCENE.instantiate() as EnemyController
	root.add_child(enemy)
	await process_frame

	var attack := AttackData.new()
	attack.attack_type = AttackData.AttackType.NORMAL
	attack.damage = 10.0
	attack.posture_damage = 12.0
	attack.guard_qi_damage = 25.0

	var health_before := enemy.health.current_health
	var qi_before := enemy.qi.current_qi
	enemy.state_machine.transition_to(EnemyController.STATE_GUARD)
	var blocked := enemy.receive_hit(null, attack, 1)
	if blocked != HurtboxComponent.ReceiveResult.BLOCK:
		failures.append("Enemy guard did not return BLOCK.")
	if enemy.health.current_health != health_before:
		failures.append("Blocked attack should not damage enemy health.")
	if enemy.qi.current_qi >= qi_before:
		failures.append("Blocked attack did not consume guard qi.")

	enemy.qi.current_qi = 5.0
	enemy.state_machine.transition_to(EnemyController.STATE_GUARD)
	var broke_guard := enemy.receive_hit(null, attack, 1)
	if broke_guard != HurtboxComponent.ReceiveResult.HIT:
		failures.append("Insufficient guard qi did not allow the hit through.")
	if enemy.health.current_health >= health_before:
		failures.append("Guard break did not damage enemy health.")

	if failures.is_empty():
		print("ENEMY GUARD TEST PASS: qi consumption and guard break are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
