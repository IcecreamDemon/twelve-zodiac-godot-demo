extends SceneTree

const ENEMY_LAB_SCENE := preload("res://scenes/tests/enemy_lab.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var lab := ENEMY_LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	await physics_frame
	await physics_frame

	var enemy := lab.get_node("TianBing") as EnemyController
	enemy.decision_cooldown = 999.0
	var start_x := enemy.global_position.x
	var attack := AttackData.new()
	attack.damage = 8.0
	attack.posture_damage = 8.0
	attack.knockback = Vector2(180.0, 0.0)
	attack.hitstun_frames = 16
	attack.reaction_type = AttackData.ReactionType.STUN

	var result := enemy.receive_hit(null, attack, 1)
	if result != HurtboxComponent.ReceiveResult.HIT:
		failures.append("Enemy did not accept the hit.")
	if not enemy.state_machine.is_state(EnemyController.STATE_HIT):
		failures.append("Enemy did not enter hitstun.")

	for _frame: int in range(8):
		await physics_frame

	if enemy.global_position.x <= start_x + 10.0:
		failures.append("Enemy was not visibly knocked back.")
	if not enemy.state_machine.is_state(EnemyController.STATE_HIT):
		failures.append("Enemy left hitstun too early.")

	if failures.is_empty():
		print("ENEMY HIT REACTION TEST PASS: knockback and hitstun are visible.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
